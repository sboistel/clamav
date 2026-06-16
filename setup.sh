#!/usr/bin/env bash
#############################################################
#
# Author:       @sboistel
# Owner:        @sboistel
# Topic:        ClamAV Installation
# Date:         DATE
#
#############################################################

# Errors handling
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
# set -o xtrace          # Trace the execution of the script (debug)

# VARIABLES
repo_owner="linx-systems"
repo_name="clamui"

# COLORS
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Resolve script directory so local files are found regardless of cwd.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Get non-root username in both interactive and sudo contexts.
USER_NAME="${SUDO_USER:-${LOGNAME:-$(id -un)}}"

# Prerequisites used by this script.
for cmd in curl jq rsync; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Missing required command: $cmd${NC}"
        echo -e "${BLUE}Installing prerequisites...${NC}"
        sudo apt install -y curl jq rsync
        break
    fi
done

# ClamAV
echo -e "\n${BLUE}Welcome $USER_NAME to ClamAV Installation...${NC}"
sudo apt install -y clamav clamav-daemon

# Update ClamAV Configuration
echo -e "\n${BLUE}Updating ClamAV Configuration...${NC}"
sudo mv /etc/clamav/clamd.conf /etc/clamav/clamd.conf.bak
curl -fsSL "https://raw.githubusercontent.com/sboistel/clamav/refs/heads/main/clamd.conf" -o "/tmp/clamd.conf"
sudo mv /tmp/clamd.conf /etc/clamav/clamd.conf
sudo sed -i "s/USER_NAME/${USER_NAME}/g" /etc/clamav/clamd.conf

# Enable & Start ClamAV service
echo -e "\n${BLUE}Enabling & Starting ClamAV service...${NC}"
sudo systemctl enable --now clamav-daemon

# ClamUI
echo -e "\n${BLUE}Installing ClamUI...${NC}"
current_version=$(dpkg -s clamui 2>/dev/null | awk '/Version/ {print $2}' || true)
tag=$(curl -fsSL "https://api.github.com/repos/${repo_owner}/${repo_name}/releases/latest" | jq -r '.tag_name')
tag_no_v="${tag#v}"
if [ -z "$current_version" ] || [ "$current_version" != "$tag_no_v" ]; then
    echo -e "\n${BLUE}ClamUI...${NC}"
    echo -e "From version ${GREEN}${current_version:-not installed}${NC} to ${GREEN}${tag_no_v}${NC}"
    curl -fsSL "https://github.com/${repo_owner}/${repo_name}/releases/download/${tag}/clamui_${tag_no_v}_all.deb" -o "/tmp/clamui_${tag_no_v}_all.deb"
    if sudo apt install -y "/tmp/clamui_${tag_no_v}_all.deb"; then
        echo -e "${GREEN}ClamUI updated to ${tag_no_v}${NC}"
    else
        echo -e "${RED}ClamUI update failed${NC}"
        exit 1
    fi
    rm -f "/tmp/clamui_${tag_no_v}_all.deb"
fi

echo -e "\n${BLUE}ClamAV Installation completed.${NC}"
echo -e "\n${BLUE}You can now run ClamUI from your applications menu.${NC}"

# EOF
