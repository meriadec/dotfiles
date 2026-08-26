import contextlib
import io
import stat
import base64
import os
import socket
import tempfile
import threading
import unittest
from pathlib import Path
from unittest import mock

import lib.work_vpn as work_vpn

from lib.work_vpn import (
    AuthenticationError,
    OpenVPNManagement,
    VpnConfig,
    encode_static_response,
    quote_management_value,
)


class StaticResponseTests(unittest.TestCase):
    def test_encodes_password_and_otp_as_scrv1(self):
        response = encode_static_response("correct horse", "123456")

        self.assertEqual(
            response,
            "SCRV1:"
            + base64.b64encode(b"correct horse").decode("ascii")
            + ":"
            + base64.b64encode(b"123456").decode("ascii"),
        )

    def test_quotes_management_protocol_values(self):
        self.assertEqual(
            quote_management_value('value with "quotes" and \\slashes'),
            '"value with \\"quotes\\" and \\\\slashes"',
        )


class ConfigTests(unittest.TestCase):
    def test_accepts_an_absolute_profile_and_op_references(self):
        config = VpnConfig.from_mapping(
            {
                "profile": "/home/user/work.ovpn",
                "username_ref": "op://Work/VPN/username",
                "password_ref": "op://Work/VPN/password",
                "otp_ref": "op://Work/VPN/one-time password",
            }
        )

        self.assertEqual(config.profile, Path("/home/user/work.ovpn"))

    def test_rejects_a_non_op_secret_reference(self):
        with self.assertRaisesRegex(ValueError, "password_ref"):
            VpnConfig.from_mapping(
                {
                    "profile": "/home/user/work.ovpn",
                    "username_ref": "op://Work/VPN/username",
                    "password_ref": "plaintext-password",
                    "otp_ref": "op://Work/VPN/one-time password",
                }
            )


class CommandBehaviorTests(unittest.TestCase):
    def test_start_is_idempotent_when_connected(self):
        output = io.StringIO()
        with (
            mock.patch.object(work_vpn, "service_state", return_value="active"),
            mock.patch.object(work_vpn, "management_state", return_value="CONNECTED"),
            mock.patch.object(work_vpn, "load_config") as load_config,
            contextlib.redirect_stdout(output),
        ):
            work_vpn.start_service(Path("/unused/config.json"), 60)

        load_config.assert_not_called()
        self.assertEqual(output.getvalue(), "VPN already connected\n")

    def test_start_resumes_an_abandoned_management_hold(self):
        with tempfile.TemporaryDirectory() as directory:
            profile = Path(directory) / "work.ovpn"
            profile.touch()
            config = VpnConfig.from_mapping(
                {
                    "profile": str(profile),
                    "username_ref": "op://Work/VPN/username",
                    "password_ref": "op://Work/VPN/password",
                    "otp_ref": "op://Work/VPN/one-time password",
                }
            )
            management = mock.Mock()
            with (
                mock.patch.object(work_vpn, "service_state", return_value="active"),
                mock.patch.object(
                    work_vpn, "management_state", return_value="RECONNECTING"
                ),
                mock.patch.object(work_vpn, "load_config", return_value=config),
                mock.patch.object(work_vpn, "require_program"),
                mock.patch.object(
                    work_vpn,
                    "read_op_reference",
                    side_effect=["user", "password", "123456"],
                ),
                mock.patch.object(work_vpn, "run_command") as run_command,
                mock.patch.object(work_vpn, "wait_for_management_socket"),
                mock.patch.object(
                    work_vpn, "OpenVPNManagement", return_value=management
                ),
                contextlib.redirect_stdout(io.StringIO()),
            ):
                work_vpn.start_service(Path("/unused/config.json"), 60)

        commands = [call.args[0] for call in run_command.call_args_list]
        self.assertEqual(commands, [["sudo", "-v"]])
        management.connect.assert_called_once_with("user", "password", "123456")

    def test_status_reports_reconnecting_process_as_disconnected(self):
        output = io.StringIO()
        with (
            mock.patch.object(work_vpn, "service_state", return_value="active"),
            mock.patch.object(
                work_vpn, "management_state", return_value="RECONNECTING"
            ),
            contextlib.redirect_stdout(output),
        ):
            result = work_vpn.main(["status"])

        self.assertEqual(result, 1)
        self.assertEqual(output.getvalue(), "VPN reconnecting\n")

    def test_stop_is_idempotent_when_stopped(self):
        output = io.StringIO()
        with (
            mock.patch.object(work_vpn, "service_state", return_value="stopped"),
            mock.patch.object(work_vpn, "run_command") as run_command,
            contextlib.redirect_stdout(output),
        ):
            work_vpn.stop_service()

        run_command.assert_not_called()
        self.assertEqual(output.getvalue(), "VPN already stopped\n")

    def test_local_configuration_is_private(self):
        config = VpnConfig.from_mapping(
            {
                "profile": "/home/user/work.ovpn",
                "username_ref": "op://Work/VPN/username",
                "password_ref": "op://Work/VPN/password",
                "otp_ref": "op://Work/VPN/one-time password",
            }
        )
        with tempfile.TemporaryDirectory() as directory:
            config_path = Path(directory) / "vpn" / "config.json"
            work_vpn.install_config(config, config_path)

            mode = stat.S_IMODE(config_path.stat().st_mode)
            self.assertEqual(mode, 0o600)
            self.assertEqual(work_vpn.load_config(config_path), config)

class ManagementProtocolTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.socket_path = Path(self.temp_dir.name) / "management.sock"
        self.server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.server.bind(os.fspath(self.socket_path))
        self.server.listen(1)
        self.server_error = None

    def tearDown(self):
        self.server.close()
        self.temp_dir.cleanup()
        if self.server_error:
            raise self.server_error

    def run_server(self, exchange):
        def target():
            try:
                connection, _ = self.server.accept()
                with connection, connection.makefile("rwb", buffering=0) as stream:
                    exchange(stream)
            except BaseException as error:  # Preserve failures from the server thread.
                self.server_error = error

        thread = threading.Thread(target=target, daemon=True)
        thread.start()
        return thread

    def test_reads_the_current_openvpn_state(self):
        def exchange(stream):
            stream.write(
                b">INFO:OpenVPN Management Interface Version 5\n"
                b">HOLD:Waiting for hold release:10\n"
            )
            self.assertEqual(stream.readline().decode().strip(), "state")
            stream.write(
                b"1,RECONNECTING,server-pushed-connection-reset,,,,,\nEND\n"
            )

        thread = self.run_server(exchange)

        state = work_vpn.management_state(self.socket_path)
        thread.join(timeout=2)

        self.assertEqual(state, "RECONNECTING")

    def test_answers_static_challenge_and_waits_for_connected_state(self):
        received = []

        def exchange(stream):
            stream.write(b">INFO:OpenVPN Management Interface Version 5\n")
            received.append(stream.readline().decode().strip())
            received.append(stream.readline().decode().strip())
            received.append(stream.readline().decode().strip())
            stream.write(
                b">PASSWORD:Need 'Auth' username/password "
                b"SC:1,Enter Authenticator Code\n"
            )
            received.append(stream.readline().decode().strip())
            received.append(stream.readline().decode().strip())
            stream.write(b">STATE:1,CONNECTED,SUCCESS,10.0.0.2,server,1.2.3.4,1194\n")

        thread = self.run_server(exchange)
        management = OpenVPNManagement(self.socket_path, timeout=2)

        management.connect("user@example.com", "password", "123456")
        thread.join(timeout=2)

        self.assertEqual(
            received[0:3], ["state on", "hold off", "hold release"]
        )
        self.assertEqual(received[3], 'username "Auth" "user@example.com"')
        self.assertEqual(
            received[4],
            'password "Auth" "SCRV1:cGFzc3dvcmQ=:MTIzNDU2"',
        )

    def test_reports_authentication_failure_without_including_secrets(self):
        def exchange(stream):
            stream.write(b">INFO:OpenVPN Management Interface Version 5\n")
            stream.readline()
            stream.readline()
            stream.write(b">PASSWORD:Verification Failed: 'Auth'\n")

        thread = self.run_server(exchange)
        management = OpenVPNManagement(self.socket_path, timeout=2)

        with self.assertRaisesRegex(AuthenticationError, "authentication failed") as caught:
            management.connect("user", "very-secret-password", "654321")
        thread.join(timeout=2)

        self.assertNotIn("very-secret-password", str(caught.exception))
        self.assertNotIn("654321", str(caught.exception))


if __name__ == "__main__":
    unittest.main()
