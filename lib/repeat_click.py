#!/usr/bin/env python3
"""Select one X11 coordinate and click it at a fixed interval."""

from __future__ import annotations

import argparse
import math
import os
import queue
import re
import shutil
import subprocess
import sys
import threading
import time
from dataclasses import dataclass
from typing import Iterable, Iterator, Sequence, TextIO

DEFAULT_FREQUENCY_SECONDS = 5.0
MINIMUM_FREQUENCY_SECONDS = 1.0
CONTROL_MASK = 1 << 2


class RepeatClickError(RuntimeError):
    """An expected repeat-click failure."""


@dataclass(frozen=True)
class Point:
    x: int
    y: int


@dataclass(frozen=True)
class Rectangle:
    x: int
    y: int
    width: int
    height: int

    def contains(self, point: Point) -> bool:
        return (
            self.x <= point.x < self.x + self.width
            and self.y <= point.y < self.y + self.height
        )


@dataclass(frozen=True)
class XInputEvent:
    name: str
    detail: int | None = None
    root_x: float | None = None
    root_y: float | None = None
    modifiers: int = 0


_EVENT_HEADER = re.compile(r"^EVENT type \d+ \(([^)]+)\)")
_ROOT_POSITION = re.compile(r"^\s*root:\s*(-?\d+(?:\.\d+)?)/(-?\d+(?:\.\d+)?)")
_DETAIL = re.compile(r"^\s*detail:\s*(\d+)")
_EFFECTIVE_MODIFIERS = re.compile(
    r"^\s*modifiers:.*\beffective:\s*(0x[0-9a-fA-F]+|\d+)"
)
_MONITOR_GEOMETRY = re.compile(
    r"\b(\d+)x(\d+)([+-]\d+)([+-]\d+)(?:\s|$)"
)
_KEYCODE_LINE = re.compile(r"^\s*(\d+)\s+.*\(c\)(?:\s|$)")


def parse_frequency(value: str) -> float:
    try:
        frequency = float(value)
    except ValueError as error:
        raise argparse.ArgumentTypeError("must be a number") from error
    if not math.isfinite(frequency) or frequency < MINIMUM_FREQUENCY_SECONDS:
        raise argparse.ArgumentTypeError(
            "must be a finite number of at least 1 second"
        )
    return frequency


def parse_xinput_events(lines: Iterable[str]) -> Iterator[XInputEvent]:
    current: dict[str, object] | None = None

    for raw_line in lines:
        line = raw_line.rstrip("\n")
        header = _EVENT_HEADER.match(line)
        if header:
            if current is not None:
                yield XInputEvent(**current)
            current = {"name": header.group(1)}
            continue
        if current is None:
            continue
        if not line.strip():
            yield XInputEvent(**current)
            current = None
            continue

        if match := _DETAIL.match(line):
            current["detail"] = int(match.group(1))
        elif match := _ROOT_POSITION.match(line):
            current["root_x"] = float(match.group(1))
            current["root_y"] = float(match.group(2))
        elif match := _EFFECTIVE_MODIFIERS.match(line):
            current["modifiers"] = int(match.group(1), 0)

    if current is not None:
        yield XInputEvent(**current)


def parse_monitor_geometries(output: str) -> list[Rectangle]:
    rectangles = [
        Rectangle(
            x=int(match.group(3)),
            y=int(match.group(4)),
            width=int(match.group(1)),
            height=int(match.group(2)),
        )
        for match in _MONITOR_GEOMETRY.finditer(output)
    ]
    if not rectangles:
        raise RepeatClickError("xrandr did not report an active screen")
    return rectangles


def parse_c_keycodes(output: str) -> set[int]:
    keycodes = {
        int(match.group(1))
        for line in output.splitlines()
        if (match := _KEYCODE_LINE.match(line))
    }
    if not keycodes:
        raise RepeatClickError("could not find the 'c' key in the X11 keyboard map")
    return keycodes


def is_stop_event(event: XInputEvent, c_keycodes: set[int]) -> bool:
    return (
        event.name == "KeyPress"
        and event.detail in c_keycodes
        and bool(event.modifiers & CONTROL_MASK)
    )


def selected_point(event: XInputEvent) -> Point | None:
    if (
        event.name != "ButtonPress"
        or event.detail != 1
        or event.root_x is None
        or event.root_y is None
    ):
        return None
    return Point(math.floor(event.root_x), math.floor(event.root_y))


class X11Backend:
    def __init__(self) -> None:
        self._require_x11()
        for command in ("xinput", "xdotool", "xrandr", "xmodmap"):
            if shutil.which(command) is None:
                raise RepeatClickError(
                    f"required command is not installed: {command}"
                )

    @staticmethod
    def _require_x11() -> None:
        if not os.environ.get("DISPLAY"):
            raise RepeatClickError("DISPLAY is not set; repeat-click requires X11")
        session_type = os.environ.get("XDG_SESSION_TYPE")
        if session_type and session_type.lower() != "x11":
            raise RepeatClickError("repeat-click supports X11 sessions only")

    @staticmethod
    def _output(command: Sequence[str]) -> str:
        try:
            result = subprocess.run(
                command,
                check=True,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
        except FileNotFoundError as error:
            raise RepeatClickError(
                f"required command is not installed: {command[0]}"
            ) from error
        except subprocess.CalledProcessError as error:
            message = (error.stderr or "").strip()
            suffix = f": {message}" if message else ""
            raise RepeatClickError(f"{command[0]} failed{suffix}") from error
        return result.stdout

    def c_keycodes(self) -> set[int]:
        return parse_c_keycodes(self._output(["xmodmap", "-pk"]))

    def screen_contains(self, point: Point) -> bool:
        output = self._output(["xrandr", "--current"])
        rectangles = parse_monitor_geometries(output)
        return any(rectangle.contains(point) for rectangle in rectangles)

    def click(self, point: Point) -> None:
        self._output(
            [
                "xdotool",
                "mousemove",
                "--sync",
                str(point.x),
                str(point.y),
                "click",
                "1",
            ]
        )


class InputMonitor:
    """Stream ungrabbed pointer and keyboard events from the X11 root window."""

    def __init__(self) -> None:
        self.events: queue.Queue[XInputEvent | RepeatClickError] = queue.Queue()
        self.process: subprocess.Popen[str] | None = None
        self.reader: threading.Thread | None = None

    def __enter__(self) -> "InputMonitor":
        try:
            self.process = subprocess.Popen(
                ["xinput", "test-xi2", "--root"],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                bufsize=1,
            )
        except OSError as error:
            raise RepeatClickError(f"could not start xinput: {error}") from error

        self.reader = threading.Thread(target=self._read_events, daemon=True)
        self.reader.start()
        # Give xinput time to subscribe before the selection prompt is shown.
        time.sleep(0.05)
        if self.process.poll() is not None:
            raise RepeatClickError("xinput stopped before it could monitor input")
        return self

    def _read_events(self) -> None:
        assert self.process is not None and self.process.stdout is not None
        for event in parse_xinput_events(self.process.stdout):
            self.events.put(event)
        failed = (
            self.process.poll() is not None
            and self.process.returncode not in (None, 0, -15)
        )
        if failed:
            error = RepeatClickError("xinput stopped while monitoring input")
            self.events.put(error)

    def next_event(self, timeout: float | None = None) -> XInputEvent | None:
        try:
            item = self.events.get(timeout=timeout)
        except queue.Empty:
            return None
        if isinstance(item, RepeatClickError):
            raise item
        return item

    def __exit__(self, *_args: object) -> None:
        if self.process is not None and self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=1)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait()
        if self.reader is not None:
            self.reader.join(timeout=1)


def wait_for_selection(monitor: InputMonitor, c_keycodes: set[int]) -> Point:
    while True:
        event = monitor.next_event()
        assert event is not None
        if is_stop_event(event, c_keycodes):
            raise KeyboardInterrupt
        point = selected_point(event)
        if point is not None:
            return point


def repeat_clicks(
    backend: X11Backend,
    monitor: InputMonitor,
    point: Point,
    frequency: float,
    output: TextIO,
) -> None:
    c_keycodes = backend.c_keycodes()
    deadline = time.monotonic() + frequency

    while True:
        remaining = deadline - time.monotonic()
        if remaining > 0:
            event = monitor.next_event(timeout=remaining)
            if event is not None:
                if is_stop_event(event, c_keycodes):
                    return
                continue
        if not backend.screen_contains(point):
            raise RepeatClickError(
                f"selected coordinates ({point.x}, {point.y}) are no longer "
                "on an active screen"
            )
        backend.click(point)
        print(f"Clicked at ({point.x}, {point.y}).", file=output, flush=True)
        deadline += frequency
        now = time.monotonic()
        if deadline <= now:
            deadline = now + frequency


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="repeat-click",
        description="Repeatedly left-click one selected X11 screen coordinate.",
    )
    parser.add_argument(
        "--frequency-seconds",
        "--frequencySeconds",
        dest="frequency_seconds",
        type=parse_frequency,
        default=DEFAULT_FREQUENCY_SECONDS,
        metavar="SECONDS",
        help="seconds between clicks, minimum 1 (default: 5)",
    )
    return parser


def run(frequency: float, backend: X11Backend, output: TextIO) -> None:
    c_keycodes = backend.c_keycodes()
    with InputMonitor() as monitor:
        print(
            "Click the target location. Press Ctrl+C to cancel.",
            file=output,
            flush=True,
        )
        point = wait_for_selection(monitor, c_keycodes)
        interval = f"{frequency:g}"
        print(
            f"Repeating at ({point.x}, {point.y}) every {interval} seconds. "
            "Press Ctrl+C to stop.",
            file=output,
            flush=True,
        )
        repeat_clicks(backend, monitor, point, frequency, output)


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        backend = X11Backend()
        run(args.frequency_seconds, backend, output=sys.stdout)
    except KeyboardInterrupt:
        print("Stopped.")
        return 130
    except RepeatClickError as error:
        print(f"repeat-click: error: {error}", file=sys.stderr)
        return 1

    print("Stopped.")
    return 130


if __name__ == "__main__":
    raise SystemExit(main())
