#!/usr/bin/env python3
"""Work VPN command and OpenVPN management-protocol client."""

from __future__ import annotations

import argparse
import base64
import json
import os
import pwd
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Mapping, Sequence

SERVICE_NAME = "work-vpn"
DEFAULT_CONFIG_PATH = Path.home() / ".config" / "vpn" / "config.json"
DEFAULT_START_TIMEOUT = 60.0

SYSTEMD_UNIT = """\
[Unit]
Description=Work VPN for %i
After=network-online.target
Wants=network-online.target
Documentation=man:openvpn(8)

[Service]
Type=notify
EnvironmentFile=/etc/work-vpn/%i.conf
RuntimeDirectory=work-vpn-%i
RuntimeDirectoryMode=0755
ExecStart=/usr/sbin/openvpn --suppress-timestamps --config ${VPN_PROFILE} --management /run/work-vpn-%i/management.sock unix --management-client-user %i --management-query-passwords --management-hold --management-log-cache 50 --auth-retry nointeract
KillSignal=SIGTERM
TimeoutStopSec=15
Restart=no
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
NoNewPrivileges=true
LockPersonality=true
CapabilityBoundingSet=CAP_IPC_LOCK CAP_NET_ADMIN CAP_NET_RAW CAP_SETGID CAP_SETUID CAP_SETPCAP CAP_SYS_CHROOT CAP_DAC_OVERRIDE CAP_SYS_NICE
DeviceAllow=/dev/null rw
DeviceAllow=/dev/net/tun rw
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX AF_NETLINK

[Install]
WantedBy=multi-user.target
"""


class VpnError(RuntimeError):
    """Base class for expected VPN errors."""


class AuthenticationError(VpnError):
    """OpenVPN rejected the supplied authentication data."""


class ManagementError(VpnError):
    """The OpenVPN management channel failed."""


@dataclass(frozen=True)
class VpnConfig:
    profile: Path
    username_ref: str
    password_ref: str
    otp_ref: str

    @classmethod
    def from_mapping(cls, values: Mapping[str, object]) -> "VpnConfig":
        required = ("profile", "username_ref", "password_ref", "otp_ref")
        missing = [name for name in required if not values.get(name)]
        if missing:
            raise ValueError("missing configuration: " + ", ".join(missing))

        profile = Path(str(values["profile"])).expanduser()
        if not profile.is_absolute():
            raise ValueError("profile must be an absolute path")

        references = {}
        for name in ("username_ref", "password_ref", "otp_ref"):
            value = str(values[name])
            if not value.startswith("op://"):
                raise ValueError(f"{name} must be an op:// reference")
            if "\n" in value or "\r" in value:
                raise ValueError(f"{name} contains an invalid newline")
            references[name] = value

        return cls(profile=profile, **references)

    def to_mapping(self) -> dict[str, str]:
        return {
            "profile": os.fspath(self.profile),
            "username_ref": self.username_ref,
            "password_ref": self.password_ref,
            "otp_ref": self.otp_ref,
        }


def encode_static_response(password: str, otp: str) -> str:
    """Encode an OpenVPN static challenge response without logging its inputs."""

    password64 = base64.b64encode(password.encode()).decode("ascii")
    otp64 = base64.b64encode(otp.encode()).decode("ascii")
    return f"SCRV1:{password64}:{otp64}"


def quote_management_value(value: str) -> str:
    """Quote one value for the line-oriented OpenVPN management protocol."""

    if "\n" in value or "\r" in value or "\x00" in value:
        raise ManagementError("a credential contains an unsupported control character")
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


class OpenVPNManagement:
    """Supply credentials and wait for OpenVPN to enter CONNECTED state."""

    def __init__(self, socket_path: Path, timeout: float = DEFAULT_START_TIMEOUT):
        self.socket_path = socket_path
        self.timeout = timeout

    def connect(self, username: str, password: str, otp: str) -> None:
        deadline = time.monotonic() + self.timeout
        management_socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        management_socket.settimeout(max(0.1, self.timeout))

        try:
            management_socket.connect(os.fspath(self.socket_path))
            with management_socket.makefile("rwb", buffering=0) as stream:
                self._send(stream, "state on")
                self._send(stream, "hold release")

                while time.monotonic() < deadline:
                    remaining = max(0.1, deadline - time.monotonic())
                    management_socket.settimeout(remaining)
                    raw_line = stream.readline()
                    if not raw_line:
                        raise ManagementError("OpenVPN closed its management connection")
                    line = raw_line.decode("utf-8", errors="replace").rstrip("\r\n")

                    if line.startswith(">PASSWORD:Verification Failed"):
                        raise AuthenticationError("VPN authentication failed")

                    if line.startswith(">PASSWORD:Need 'Auth'"):
                        if " SC:" not in line:
                            raise ManagementError(
                                "OpenVPN requested credentials without the expected OTP challenge"
                            )
                        response = encode_static_response(password, otp)
                        self._send(
                            stream,
                            "username \"Auth\" " + quote_management_value(username),
                        )
                        self._send(
                            stream,
                            "password \"Auth\" " + quote_management_value(response),
                        )
                        continue

                    if line.startswith(">STATE:"):
                        fields = line.removeprefix(">STATE:").split(",")
                        state = fields[1] if len(fields) > 1 else ""
                        detail = fields[2] if len(fields) > 2 else ""
                        if state == "CONNECTED" and detail == "SUCCESS":
                            return
                        if state == "EXITING":
                            if "auth" in detail.lower():
                                raise AuthenticationError("VPN authentication failed")
                            raise ManagementError(
                                f"OpenVPN exited before it connected ({detail or 'unknown reason'})"
                            )

                    if line.startswith(">FATAL:"):
                        reason = line.removeprefix(">FATAL:").strip()
                        raise ManagementError(f"OpenVPN failed: {reason}")
        except socket.timeout as error:
            raise ManagementError("timed out while waiting for OpenVPN") from error
        except OSError as error:
            raise ManagementError(f"cannot use OpenVPN management socket: {error}") from error
        finally:
            management_socket.close()

        raise ManagementError("timed out while waiting for OpenVPN to connect")

    @staticmethod
    def _send(stream, command: str) -> None:
        stream.write((command + "\n").encode("utf-8"))


def load_config(path: Path = DEFAULT_CONFIG_PATH) -> VpnConfig:
    try:
        with path.open(encoding="utf-8") as config_file:
            values = json.load(config_file)
    except FileNotFoundError as error:
        raise VpnError(f"VPN is not configured; run 'vpn install' first") from error
    except (OSError, json.JSONDecodeError) as error:
        raise VpnError(f"cannot read {path}: {error}") from error

    try:
        return VpnConfig.from_mapping(values)
    except (TypeError, ValueError) as error:
        raise VpnError(f"invalid VPN configuration in {path}: {error}") from error


def current_username() -> str:
    username = pwd.getpwuid(os.getuid()).pw_name
    if not re.fullmatch(r"[a-z_][a-z0-9_-]*", username):
        raise VpnError(f"unsupported local user name: {username}")
    return username


def unit_name(username: str | None = None) -> str:
    return f"{SERVICE_NAME}@{username or current_username()}.service"


def management_socket_path(username: str | None = None) -> Path:
    return Path("/run") / f"work-vpn-{username or current_username()}" / "management.sock"


def run_command(
    command: Sequence[str], *, capture: bool = False, check: bool = True
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        check=check,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def service_state(username: str | None = None) -> str:
    result = run_command(
        ["systemctl", "show", unit_name(username), "--property=ActiveState", "--value"],
        capture=True,
        check=False,
    )
    if result.returncode != 0:
        return "stopped"
    state = result.stdout.strip()
    return state if state in {"active", "activating", "failed"} else "stopped"


def read_op_reference(reference: str) -> str:
    try:
        result = run_command(["op", "read", reference], capture=True)
    except FileNotFoundError as error:
        raise VpnError("1Password CLI ('op') is not installed") from error
    except subprocess.CalledProcessError as error:
        message = (error.stderr or "").strip()
        suffix = f": {message}" if message else ""
        raise VpnError(f"1Password could not read a configured item{suffix}") from error

    value = result.stdout.rstrip("\r\n")
    if not value:
        raise VpnError("1Password returned an empty credential")
    if "\n" in value or "\r" in value:
        raise VpnError("1Password returned a credential with an unsupported newline")
    return value


def require_program(name: str) -> None:
    if shutil.which(name) is None:
        raise VpnError(f"required command is not installed: {name}")


def wait_for_management_socket(path: Path, timeout: float) -> None:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if path.exists():
            return
        if service_state() == "failed":
            raise ManagementError("OpenVPN service failed before authentication")
        time.sleep(0.1)
    raise ManagementError("OpenVPN did not create its management socket")


def stop_service(*, quiet: bool = False) -> None:
    state = service_state()
    if state == "stopped":
        if not quiet:
            print("VPN already stopped")
        return

    run_command(["sudo", "-v"])
    run_command(["sudo", "systemctl", "stop", unit_name()])
    if not quiet:
        print("VPN stopped")


def start_service(config_path: Path, timeout: float) -> None:
    state = service_state()
    if state == "active":
        print("VPN already connected")
        return
    resume_start = state == "activating"

    config = load_config(config_path)
    if not config.profile.is_file():
        raise VpnError(f"OpenVPN profile does not exist: {config.profile}")
    for program in ("op", "sudo", "systemctl"):
        require_program(program)

    # Authenticate sudo before reading the short-lived OTP.
    run_command(["sudo", "-v"])

    print("Authorizing with 1Password...", flush=True)
    username = read_op_reference(config.username_ref)
    password = read_op_reference(config.password_ref)
    otp = read_op_reference(config.otp_ref)

    deadline = time.monotonic() + timeout
    if resume_start:
        print("VPN is already starting; completing authentication...", flush=True)
    else:
        print("Starting VPN...", flush=True)
        run_command(
            ["sudo", "systemctl", "start", "--no-block", unit_name()],
            capture=True,
        )

    socket_path = management_socket_path()
    try:
        wait_for_management_socket(socket_path, min(timeout, 10.0))
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise ManagementError("timed out while waiting for OpenVPN")
        OpenVPNManagement(socket_path, timeout=remaining).connect(
            username, password, otp
        )
    except BaseException:
        run_command(
            ["sudo", "systemctl", "stop", unit_name()], capture=True, check=False
        )
        raise

    print("VPN connected")


def prompt_value(label: str, current: str | None = None) -> str:
    suffix = f" [{current}]" if current else ""
    value = input(f"{label}{suffix}: ").strip()
    return value or current or ""


def systemd_environment_value(value: str) -> str:
    if "\n" in value or "\r" in value or "\x00" in value:
        raise VpnError("profile path contains an unsupported control character")
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def install_config(config: VpnConfig, config_path: Path) -> None:
    config_path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    temporary_path = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=config_path.parent,
            prefix=f".{config_path.name}.",
            delete=False,
        ) as config_file:
            temporary_path = Path(config_file.name)
            os.fchmod(config_file.fileno(), 0o600)
            json.dump(config.to_mapping(), config_file, indent=2)
            config_file.write("\n")
        temporary_path.replace(config_path)
    finally:
        if temporary_path and temporary_path.exists():
            temporary_path.unlink()


def install_service(config: VpnConfig, username: str) -> None:
    environment = f"VPN_PROFILE={systemd_environment_value(os.fspath(config.profile))}\n"
    with tempfile.TemporaryDirectory(prefix="vpn-install-") as directory:
        unit_source = Path(directory) / f"{SERVICE_NAME}@.service"
        environment_source = Path(directory) / f"{username}.conf"
        unit_source.write_text(SYSTEMD_UNIT, encoding="utf-8")
        environment_source.write_text(environment, encoding="utf-8")

        run_command(["sudo", "-v"])
        run_command(
            [
                "sudo",
                "install",
                "-D",
                "-m",
                "0644",
                os.fspath(unit_source),
                f"/etc/systemd/system/{SERVICE_NAME}@.service",
            ]
        )
        run_command(
            [
                "sudo",
                "install",
                "-D",
                "-m",
                "0644",
                os.fspath(environment_source),
                f"/etc/work-vpn/{username}.conf",
            ]
        )
        run_command(["sudo", "systemctl", "daemon-reload"])


def install(args: argparse.Namespace) -> None:
    existing = None
    try:
        existing = load_config(args.config)
    except VpnError:
        pass

    profile = args.profile or prompt_value(
        "OpenVPN profile", os.fspath(existing.profile) if existing else None
    )
    username_ref = args.username_ref or prompt_value(
        "1Password username reference", existing.username_ref if existing else None
    )
    password_ref = args.password_ref or prompt_value(
        "1Password password reference", existing.password_ref if existing else None
    )
    otp_ref = args.otp_ref or prompt_value(
        "1Password OTP reference", existing.otp_ref if existing else None
    )

    try:
        config = VpnConfig.from_mapping(
            {
                "profile": profile,
                "username_ref": username_ref,
                "password_ref": password_ref,
                "otp_ref": otp_ref,
            }
        )
    except ValueError as error:
        raise VpnError(str(error)) from error

    if not config.profile.is_file():
        raise VpnError(f"OpenVPN profile does not exist: {config.profile}")

    install_config(config, args.config)
    install_service(config, current_username())
    print(f"VPN configuration installed in {args.config}")
    print("Run 'vpn start' to connect")


def print_status(quiet: bool) -> int:
    state = service_state()
    if quiet:
        return 0 if state == "active" else 1

    messages = {
        "active": "VPN connected",
        "activating": "VPN starting",
        "failed": "VPN failed",
        "stopped": "VPN stopped",
    }
    print(messages[state])
    return 0 if state in {"active", "activating"} else 1


def show_logs(follow: bool) -> int:
    command = ["journalctl", "--unit", unit_name(), "--no-pager", "--lines", "100"]
    if follow:
        command.extend(["--follow"])
    return run_command(command, check=False).returncode


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="vpn", description="Manage the work VPN")
    parser.add_argument(
        "--config",
        type=Path,
        default=DEFAULT_CONFIG_PATH,
        help=argparse.SUPPRESS,
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    install_parser = subparsers.add_parser("install", help="install VPN configuration")
    install_parser.add_argument("--profile")
    install_parser.add_argument("--username-ref")
    install_parser.add_argument("--password-ref")
    install_parser.add_argument("--otp-ref")

    start_parser = subparsers.add_parser("start", help="start the VPN")
    start_parser.add_argument("--timeout", type=float, default=DEFAULT_START_TIMEOUT)

    subparsers.add_parser("stop", help="stop the VPN")

    status_parser = subparsers.add_parser("status", help="show VPN status")
    status_parser.add_argument("--quiet", action="store_true")

    logs_parser = subparsers.add_parser("logs", help="show OpenVPN logs")
    logs_parser.add_argument("--follow", "-f", action="store_true")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        if args.command == "install":
            install(args)
            return 0
        if args.command == "start":
            if args.timeout <= 0:
                raise VpnError("timeout must be greater than zero")
            start_service(args.config, args.timeout)
            return 0
        if args.command == "stop":
            stop_service()
            return 0
        if args.command == "status":
            return print_status(args.quiet)
        if args.command == "logs":
            return show_logs(args.follow)
    except (VpnError, subprocess.CalledProcessError) as error:
        if isinstance(error, subprocess.CalledProcessError):
            message = (error.stderr or "").strip() if error.stderr else ""
            detail = f": {message}" if message else ""
            print(f"vpn: command failed{detail}", file=sys.stderr)
        else:
            print(f"vpn: {error}", file=sys.stderr)
        if isinstance(error, (AuthenticationError, ManagementError)):
            print("Run 'vpn logs' for OpenVPN details", file=sys.stderr)
        return 1

    parser.error("unknown command")
    return 2
