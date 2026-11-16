#!/usr/bin/env bash
# Fail on any command.
set -euxo pipefail

cd "$(dirname "$0")"

# Install plug-ins (you can git-pull to update them later).
ZSH_PLUGINS=~/.oh-my-zsh/custom/plugins
[ -d "$ZSH_PLUGINS/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGINS/zsh-syntax-highlighting"
[ -d "$ZSH_PLUGINS/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS/zsh-autosuggestions"

# Replace the configs with the saved one.
cp configs/.zshrc ~/.zshrc

# Copy the modified Agnoster Theme
cp configs/pixegami-agnoster.zsh-theme ~/.oh-my-zsh/themes/pixegami-agnoster.zsh-theme

# ---------------------------------------------------------------------------
# Color Theme
# ---------------------------------------------------------------------------
PROFILE_NAME="Pixegami"
FONT="Roboto Mono for Powerline 14"

# Ptyxis (default terminal since Ubuntu 25.10 / 26.04).
# Ptyxis does not read GNOME Terminal's dconf keys; colors come from a
# .palette file and the profile just references it by name.
if command -v ptyxis >/dev/null 2>&1; then
	PTYXIS_UUID=fb358fc949ea4252ad341d25c649e633
	PALETTE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/org.gnome.Ptyxis/palettes"
	mkdir -p "$PALETTE_DIR"
	cp configs/pixegami.palette "$PALETTE_DIR/pixegami.palette"

	# Flatpak build of Ptyxis keeps its data inside the sandbox.
	if [ -d "$HOME/.var/app/app.devsuite.Ptyxis" ]; then
		mkdir -p "$HOME/.var/app/app.devsuite.Ptyxis/data/org.gnome.Ptyxis/palettes"
		cp configs/pixegami.palette "$HOME/.var/app/app.devsuite.Ptyxis/data/org.gnome.Ptyxis/palettes/pixegami.palette"
	fi

	PROFILE_PATH="/org/gnome/Ptyxis/Profiles/$PTYXIS_UUID/"
	dconf write "${PROFILE_PATH}label" "'$PROFILE_NAME'"
	dconf write "${PROFILE_PATH}palette" "'pixegami'"
	dconf write "${PROFILE_PATH}opacity" "0.97"
	dconf write "${PROFILE_PATH}login-shell" "false"
	dconf write "${PROFILE_PATH}use-custom-command" "false"

	# Font is a global setting in Ptyxis, not per-profile.
	dconf write /org/gnome/Ptyxis/use-system-font "false"
	dconf write /org/gnome/Ptyxis/font-name "'$FONT'"

	# Add the profile to the list (once) and make it the default.
	old_list=$(dconf read /org/gnome/Ptyxis/profile-uuids || true)
	if ! grep -q "$PTYXIS_UUID" <<<"$old_list"; then
		old_list=$(tr -d "]" <<<"$old_list")
		if [ -z "$old_list" ] || [ "$old_list" = "[" ] || [ "$old_list" = "@as [" ]; then
			new_list="['$PTYXIS_UUID']"
		else
			new_list="$old_list, '$PTYXIS_UUID']"
		fi
		dconf write /org/gnome/Ptyxis/profile-uuids "$new_list"
	fi
	dconf write /org/gnome/Ptyxis/default-profile-uuid "'$PTYXIS_UUID'"
fi

# GNOME Terminal (default up to Ubuntu 24.04, still installable on newer).
if command -v gnome-terminal >/dev/null 2>&1; then
	GT_UUID=fb358fc9-49ea-4252-ad34-1d25c649e633
	dconf load "/org/gnome/terminal/legacy/profiles:/:$GT_UUID/" < configs/terminal_profile.dconf

	old_list=$(dconf read /org/gnome/terminal/legacy/profiles:/list || true)
	if ! grep -q "$GT_UUID" <<<"$old_list"; then
		old_list=$(tr -d "]" <<<"$old_list")
		if [ -z "$old_list" ] || [ "$old_list" = "[" ]; then
			new_list="['$GT_UUID']"
		else
			new_list="$old_list, '$GT_UUID']"
		fi
		dconf write /org/gnome/terminal/legacy/profiles:/list "$new_list"
	fi
	dconf write /org/gnome/terminal/legacy/profiles:/default "'$GT_UUID'"
fi

# Switch the shell.
chsh -s "$(which zsh)"
