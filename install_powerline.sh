#!/usr/bin/env bash
# Fail on any command.
set -euxo pipefail

cd "$(dirname "$0")"

# Install Powerline for VIM.
sudo apt install -y python3-pip
# Ubuntu marks the system Python as "externally managed" (PEP 668), so pip
# refuses to install without this flag.
pip3 install --user --break-system-packages powerline-status
cp configs/.vimrc ~/.vimrc
sudo apt install -y fonts-powerline

# Install Patched Font
mkdir -p ~/.fonts
cp -a fonts/. ~/.fonts/
fc-cache -vf ~/.fonts/
