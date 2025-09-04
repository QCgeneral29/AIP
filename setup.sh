#!/bin/bash
# setup.sh - Post-install Arch Linux setup script
# I recommend reading all the comments so you understand the installation process.
# There are also some packages that are not installed but are recommended in comments.

# Exit on errors
set -e

# Uncomment multilib in pacman.conf. Used for installing 32bit apps e.g. Steam 
sudo sed -i '/^\s*#\[multilib\]$/,/^$/ s/^#//' /etc/pacman.conf

# Update system 
echo "==> Updating system..."
sudo pacman -Syu --noconfirm

# List of packages from official repos
PKGS=(
	# Bare essential packages
	base-devel
	jre-openjdk
	unzip
	zip
	reflector
	git
	mdcat
	vim
	man-db
	less
	curl
	wget
	stow
	networkmanager
	network-manager-applet
	nftables	
	fastfetch
	firefox
	mpv
	obsidian
	font-manager
	nerd-fonts
	discord
	qbittorrent
	7zip
	obs-studio
	spotify-launcher
	blender
	godot
	libreoffice-still
	steam
	ttf-liberation # Font for steam
	# Hyprland Desktop Environment and related packages
	hyprland
	hyprlock
	hyprpaper
	polkit
	hyprpolkitagent
	dunst
	qt5-wayland
	qt6-wayland
	noto-fonts
	wofi
	waybar
	dolphin
	otf-font-awesome
	brightnessctl
	kitty
	pipewire
	pipewire-pulse
	pipewire-alsa
	wireplumber
	pavucontrol
	playerctl
	xdg-desktop-portal-hyprland # Something to do with screen sharing
	xdg-desktop-portal-gtk # Fallback 
	grim # Dependencies for above.
	slurp # Who names these?
	# iio-sensor-proxy is used for device rotation to update screen rotation
	iio-sensor-proxy
	# System backup and restore
	cronie
	timeshift
	# Bluetooth backages
	bluez
	bluez-utils
	blueberry # GUI for bluetooth
	# Japanese fonts and input manager
	# You need to enable mozc in fcitx for Japanese IM
	adobe-source-han-sans-jp-fonts
	adobe-source-han-serif-jp-fonts
	noto-fonts-cjk
	fcitx5-im
	fcitx5-mozc
	# You can bookmark this ip for the cups web interface
	# http://localhost:631/
	cups
	cups-pdf # Print to PDF
	avahi # Printer discovery
	nss-mdns # For above
	# You might not need proton VPN, but I recommend their services.
	proton-vpn-gtk-app
)

echo "==> Installing packages..."
for PKG in "${PKGS[@]}"; do
	if ! pacman -Qi $PKG &>/dev/null; then
		sudo pacman -S --noconfirm --needed $PKG
	fi
done

# Enable services
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now nftables.service
sudo systemctl enable --now cups.service
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now reflector.service
sudo systemctl enable --now cronie.service
# I don't know if this is necessary
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# Install yay (AUR helper) if not already installed
if ! command -v yay &>/dev/null; then
	echo "==> Installing yay..."
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	(cd /tmp/yay && makepkg -si --noconfirm)
	rm -rf /tmp/yay
else
	echo "==> yay is already installed"
fi

# After yay is installed, I recommend installing the following:
# - informant - Infoms you of important news before a system upgrade
# - iio-hyprland - If you need auto orientation e.g. 2 in 1 tablet.
# 		For iio-sensor, if you want auto-rotate, you need to download
# 		iio-hyprland from https://github.com/JeanSchoeller/iio-hyprland
# 		It requires jq as a dependency. (iio-hyprland is on the AUR)

# We don't auto install yay packages because they are technically very unsecure.

echo "==> Setting up wallpaper at ~/Pictures/Wallpaper (Will not overwrite existing)"
# Create wallpaper directory
mkdir -p ~/Pictures/Wallpaper
cp -n wallpaper.jpg ~/Pictures/Wallpaper/

# Install vim plugin manager
# This isn't super secure...
echo "==> Installing vim-plug plugin manager"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Increase vm.max_map_count for game compatibility
GAME_COMPAT_FILE="/etc/sysctl.d/80-gamecompatibility.conf"

if [ ! -f "$GAME_COMPAT_FILE" ]; then
	echo "==> Creating vm.max_map_count game compatibility file..."
    echo "vm.max_map_count = 2147483642" | sudo tee "$GAME_COMPAT_FILE" > /dev/null
    sudo sysctl --system
else
    echo "==> vm.max_map_count increase already exists, not overwriting."
fi

echo "==> Setup complete."
