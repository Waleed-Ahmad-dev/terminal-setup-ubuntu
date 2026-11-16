#!/usr/bin/env bash
# Fail on any command.
set -euxo pipefail

# Install ZSH
sudo apt install -y git zsh curl
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
