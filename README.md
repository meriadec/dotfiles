# dotfiles

![](colors.png)

## Install

```bash
make install
```

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

`vpn start` asks for sudo once, requests one 1Password authorization, and waits
for OpenVPN to confirm the connection. Run the tests with `make test`.

## Structure

```
.
├── assets            # static assets
│   ├── fonts
│   └── images
│
├── bin               # user-defined commands (the folder
│                     # is added to $PATH)
│
├── colors            # theme colors
│
├── config            # bunch of configs, including awesome wm config
│   ├── awesome
│   └── ...etc.
│
└── dot               # actually dotfiles.
    ├── gitconfig
    ├── profile
    ├── vimrc
    ├── zshrc
    └── ...etc.
```
