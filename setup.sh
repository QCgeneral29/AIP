#!/bin/bash
# setup.sh - Post-install Arch Linux setup script
# I recommend reading all the comments so you understand the installation process.
# There are also some packages that are not installed, but are recommended in the comments.

# Exit on errors
set -e

start=$(date +%s)

# Uncomment multilib in pacman.conf. Used for installing 32bit apps e.g. Steam 
sudo sed -i '/^\s*#\[multilib\]$/,/^$/ s/^#//' /etc/pacman.conf

echo "==> Updating system"
sudo pacman -Syu --noconfirm

# List of packages from official repos
# 	Feel free to add and remove packages as you please.
# 	BUT, be aware some packages require others to work properly.
# 	e.g. pipewire needing pipewire-pulse for compatibility
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
	ttf-dejavu
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
	hyprpicker
	wl-clipboard # For hyprpicker
	polkit
	hyprpolkitagent
	dunst
	qt5-wayland
	qt6-wayland
	noto-fonts
	noto-fonts-emoji
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
	iio-sensor-proxy # for device rotation to update screen rotation
	# System backup and restore
	cronie
	timeshift
	# Bluetooth backages
	bluez
	bluez-utils
	blueberry # GUI for bluetooth
	# Japanese fonts and input manager
	# Right click the keyboard icon in the tray -> configure -> enable mozc
	adobe-source-han-sans-jp-fonts
	adobe-source-han-serif-jp-fonts
	noto-fonts-cjk
	fcitx5-im
	fcitx5-mozc
	# You can bookmark this ip for the cups web interface
	# http://localhost:631/
	cups
	cups-pdf # Print to PDF. You can also just use web browser print to pdf.
	avahi # Printer discovery
	nss-mdns # For above
	# You might not need proton VPN, but I recommend their services.
	proton-vpn-gtk-app
)

echo "==> Installing packages..."
sudo pacman -S --noconfirm --needed "${PKGS[@]}"
echo "==> Finished installing packages"

echo "==> Enabling services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now nftables.service
sudo systemctl enable --now cronie.service
sudo systemctl enable --now reflector.service

# Enable printer service, configure avahi, and allow discovery through firewall
sudo systemctl enable --now avahi-daemon.service
# Enbable local hostname resolution for avahi
sudo sed -i '/^hosts: mymachines resolve \[!UNAVAIL=return] files myhostname dns$/c\hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns' /etc/nsswitch.conf
sudo systemctl enable --now cups.service
# Allow udp port for avahi in nftables
sudo nft list chain inet filter input | grep -q 'udp dport 5353 accept' || \
sudo nft add rule inet filter input udp dport 5353 accept comment "allow_mdns"


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
# - iio-hyprland - If you need auto orientation e.g. 2-in-1 tablet.
# 		See https://github.com/JeanSchoeller/iio-hyprland for more info.
# 		It requires jq as a dependency. (iio-hyprland is on the AUR)

# We don't auto install yay packages because they are technically unsecure.

# Sets the default URL opener for things such as terminal.
# You can change it if you have another preference (e.g. chrome)
echo "==> Setting default xdg web browser to firefox"
xdg-settings set default-web-browser firefox.desktop

echo "==> Setting up wallpaper at ~/Pictures/Wallpaper (Will not overwrite existing)"
# Create wallpaper directory and copy wallpaper to it.
mkdir -p ~/Pictures/Wallpaper
cp -n wallpaper.jpg ~/Pictures/Wallpaper/

# Install vim plugin manager
# This isn't super secure...
echo "==> Installing vim-plug plugin manager..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Increase vm.max_map_count for game compatibility
GAME_COMPAT_FILE="/etc/sysctl.d/80-gamecompatibility.conf"
if [ ! -f "$GAME_COMPAT_FILE" ]; then
	echo "==> Creating vm.max_map_count game compatibility file"
    echo "vm.max_map_count = 2147483642" | sudo tee "$GAME_COMPAT_FILE" > /dev/null
    sudo sysctl --system
else
    echo "==> vm.max_map_count increase already exists"
fi

echo "==> Setup complete!"

end=$(date +%s)
elapsed=$((end - start))
minutes=$((elapsed / 60))
seconds=$((elapsed % 60))
echo "==> Finished in ${minutes}m ${seconds}s"
