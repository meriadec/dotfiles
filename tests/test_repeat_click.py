import argparse
import io
import unittest
from unittest import mock

from lib.repeat_click import (
    CONTROL_MASK,
    Point,
    Rectangle,
    RepeatClickError,
    X11Backend,
    XInputEvent,
    build_parser,
    is_stop_event,
    parse_c_keycodes,
    parse_frequency,
    parse_monitor_geometries,
    parse_xinput_events,
    repeat_clicks,
    selected_point,
)


class CommandLineTests(unittest.TestCase):
    def test_uses_five_second_default(self):
        args = build_parser().parse_args([])

        self.assertEqual(args.frequency_seconds, 5.0)

    def test_accepts_documented_and_compatible_frequency_options(self):
        documented = build_parser().parse_args(["--frequency-seconds", "1.25"])
        compatible = build_parser().parse_args(["--frequencySeconds", "2"])

        self.assertEqual(documented.frequency_seconds, 1.25)
        self.assertEqual(compatible.frequency_seconds, 2.0)

    def test_rejects_frequency_below_one_second(self):
        with self.assertRaises(argparse.ArgumentTypeError):
            parse_frequency("0.99")

    def test_rejects_non_finite_frequency(self):
        for value in ("nan", "inf", "-inf"):
            with self.subTest(value=value), self.assertRaises(
                argparse.ArgumentTypeError
            ):
                parse_frequency(value)


class InputEventTests(unittest.TestCase):
    def test_reads_left_click_coordinates_from_xinput_event(self):
        events = list(
            parse_xinput_events(
                [
                    "EVENT type 4 (ButtonPress)\n",
                    "    device: 12 (12)\n",
                    "    detail: 1\n",
                    "    root: -10.25/720.90\n",
                    "    modifiers: locked 0 latched 0 base 0 effective: 0\n",
                    "\n",
                ]
            )
        )

        self.assertEqual(selected_point(events[0]), Point(-11, 720))

    def test_detects_control_c_key_press(self):
        events = list(
            parse_xinput_events(
                [
                    "EVENT type 2 (KeyPress)\n",
                    "    detail: 31\n",
                    "    modifiers: locked 0 latched 0 base 4 effective: 0x4\n",
                    "\n",
                ]
            )
        )

        self.assertTrue(is_stop_event(events[0], {31}))
        self.assertFalse(
            is_stop_event(XInputEvent("KeyPress", detail=31), {31})
        )
        self.assertFalse(
            is_stop_event(
                XInputEvent("KeyPress", detail=32, modifiers=CONTROL_MASK), {31}
            )
        )

    def test_finds_c_keycode_in_xmodmap_output(self):
        output = """
     30         0x0075 (u)  0x0055 (U)
     31         0x0063 (c)  0x0043 (C)  0x00e7 (ccedilla)
"""

        self.assertEqual(parse_c_keycodes(output), {31})


class RepeatModeTests(unittest.TestCase):
    class Backend:
        def __init__(self, on_screen=True):
            self.on_screen = on_screen
            self.clicks = []

        def c_keycodes(self):
            return {31}

        def screen_contains(self, _point):
            return self.on_screen

        def click(self, point):
            self.clicks.append(point)

    class Monitor:
        def __init__(self):
            self.timeouts = []
            self.calls = 0

        def next_event(self, timeout=None):
            self.timeouts.append(timeout)
            self.calls += 1
            if self.calls == 1:
                return None
            return XInputEvent("KeyPress", detail=31, modifiers=CONTROL_MASK)

    def test_waits_one_interval_then_clicks_until_control_c(self):
        backend = self.Backend()
        monitor = self.Monitor()
        point = Point(100, 200)
        output = io.StringIO()

        repeat_clicks(backend, monitor, point, frequency=2.0, output=output)

        self.assertEqual(backend.clicks, [point])
        self.assertGreater(monitor.timeouts[0], 1.9)
        self.assertEqual(output.getvalue(), "Clicked at (100, 200).\n")

    def test_stops_if_selected_point_is_no_longer_on_a_screen(self):
        backend = self.Backend(on_screen=False)
        monitor = self.Monitor()

        with self.assertRaisesRegex(RepeatClickError, "no longer on an active screen"):
            repeat_clicks(
                backend,
                monitor,
                Point(100, 200),
                frequency=2.0,
                output=io.StringIO(),
            )

        self.assertEqual(backend.clicks, [])


class BackendCommandTests(unittest.TestCase):
    def test_click_does_not_wait_for_pointer_motion(self):
        backend = X11Backend.__new__(X11Backend)

        with mock.patch.object(backend, "_output") as output:
            backend.click(Point(100, 200))

        output.assert_called_once_with(
            ["xdotool", "mousemove", "100", "200", "click", "1"]
        )


class ScreenGeometryTests(unittest.TestCase):
    def test_parses_multiple_monitors_with_negative_offsets(self):
        output = """
DP-1 connected 1920x1080+0+0 (normal left inverted right x axis y axis)
eDP-1 connected primary 1920x1080-1920+120 (normal left inverted right x axis y axis)
"""

        rectangles = parse_monitor_geometries(output)

        self.assertEqual(
            rectangles,
            [Rectangle(0, 0, 1920, 1080), Rectangle(-1920, 120, 1920, 1080)],
        )
        self.assertTrue(rectangles[1].contains(Point(-1, 1199)))
        self.assertFalse(rectangles[1].contains(Point(0, 1199)))


if __name__ == "__main__":
    unittest.main()
