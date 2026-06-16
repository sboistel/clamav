# TL;DR

Run one script to install and configure ClamAV + ClamUI on Ubuntu/Debian.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sboistel/clamav/main/setup.sh)
```

or

```bash
chmod +x setup.sh
./setup.sh
```

What it does:

- Installs `clamav` and `clamav-daemon`.
- Ensures required tools are available (`curl`, `jq`, `rsync`).
- Downloads and applies `clamd.conf`, replacing `USER_NAME` with your current user.
- Enables and starts `clamav-daemon`.
- Installs or updates `clamui` from the latest GitHub release.

Requirements:
- `sudo` privileges.
- Internet access (GitHub API + release download).
- APT-based Linux distro.
