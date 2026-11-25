# dotfiles

## Install

```bash
make install                        # symlink everything into $HOME
./install --dry-run        # show what would change
./install --force          # back up conflicting files as <name>.bak
```

The list of links is at the top of `./install`. The script is safe to
run again, and warns about files in `home/` or `config/` that it does not install.

### Repeat Click

`repeat-click` selects one screen coordinate and left-clicks it at a fixed
interval. It supports Linux X11 sessions and requires `xinput`, `xdotool`,
`xrandr`, and `xmodmap`.

```bash
repeat-click                              # click every 5 seconds
repeat-click --frequency-seconds 1.5      # custom interval
```

Left-click the target coordinate when prompted. Press `Ctrl+C` from any focused
application to stop. The compatible `--frequencySeconds` spelling is also
accepted.

### Work VPN

The `vpn` command manages OpenVPN through systemd and reads its credentials from
the official 1Password CLI. It does not write the password or OTP to a file.

Requirements:

- OpenVPN
- systemd
- [1Password CLI](https://developer.1password.com/docs/cli/) with desktop app integration

Run the guided one-time setup:

```bash
vpn install
```

Enter the OpenVPN profile path and three `op://` references for the username,
password, and one-time password. The machine-specific configuration is stored at
`~/.config/vpn/config.json`, outside this repository.

Use these commands:

```bash
vpn start
vpn stop
vpn status
vpn logs
vpn logs --follow
```

`vpn start` asks for sudo once. If necessary, it starts the 1Password app,
requests one authorization, and waits for OpenVPN to confirm the connection. Run
the tests with `make test`.

## Structure

```
.
├── install    # symlinks everything into $HOME (see "Install")
├── home/      # dotfiles: home/zshrc is linked to ~/.zshrc, etc.
├── config/    # ~/.config/<name>: i3, polybar, nvim, kitty, ...
├── bin/       # personal commands, linked to ~/bin
├── lib/       # Python code behind some commands in bin/ (vpn, repeat-click)
├── tests/     # tests for lib/ (make test)
├── docs/      # notes
└── assets/    # images and icons used by the configs
```

### Mouse buttons (Logitech MX Vertical)

Find button numbers with `xinput test <id>` (`xinput list` shows the id).
Thumb "Back" is button 8, "Forward" is button 9. i3 binds button 8 to
`~/bin/screenshot` with `bindsym --whole-window`; i3 consumes the click, so
apps no longer get "Back" from it.
