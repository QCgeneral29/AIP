#!/bin/bash

### setup.sh - Post-install Arch Linux setup script
# I recommend reading all the comments so you understand the installation process.
# There are also some packages that are not installed, but are recommended in the comments.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
INDENT="${GREEN}==>${NC}"

# Exit on errors, unset vars, or pipefails
set -e 
set -u
set -o pipefail

start=$(date +%s)

# Install and run reflector before updating
echo -e "${INDENT} Installing reflector"
sudo pacman -S --noconfirm --needed reflector
echo -e "${INDENT} Searching for best mirrors. Press Ctrl+C to skip this process. "
echo -e "${INDENT} This will take a few minutes..."
sudo reflector --protocol https --download-timeout 15 --latest 10 --sort rate --fastest 5 --save /etc/pacman.d/mirrorlist >/dev/null 2>&1

# Uncomment multilib in pacman.conf. Used for installing 32bit apps e.g. Steam 
sudo sed -i '/^\s*#\[multilib\]$/,/^$/ s/^#//' /etc/pacman.conf

echo -e "${INDENT} Updating system"
sudo pacman -Syu --noconfirm

# List of packages from official repos
# 	Feel free to add and remove packages as you please.
# 	BUT, be aware some packages require others to work properly.
# 	e.g. pipewire needing pipewire-pulse for compatibility
PKGS=(
	### Optional packages. Uncomment what you need.
	# code # Open source alternative to Visual Studio Code
	# blender # Free and open source 3D modeling software (and more!).
	# godot # Free and open source 2D and 3D game engine.
	# proton-vpn-gtk-app # Proton VPN. Refferal code: https://pr.tn/ref/VXSDWNRS
	fastfetch # Alternative to neofetch.
	feh # Image viewer
	mdcat # cat but for reading markdown files.
	mpv # Video player
	obsidian # Note taking application
	font-manager
	ttf-dejavu
	discord
	qbittorrent
	7zip
	obs-studio
	spotify-launcher
	libreoffice-still # Free and open source productivity suite. E.g. Microsoft Word, Excel, etc.
	steam
	ttf-liberation # Font for steam
	### Bare essential packages
	base-devel
	jre-openjdk
	unzip
	zip
	reflector
	git
	vim
	man-db
	less
	curl
	wget
	stow
	networkmanager
	network-manager-applet
	nftables	
	ffmpeg
	imagemagick
	firefox
	ttf-bigblueterminal-nerd # Used in kitty config
	### Hyprland Desktop Environment and related packages
	hyprland
	hyprlock
	hyprpaper
	hyprpicker # Color picker
	wl-clipboard # For hyprpicker
	polkit
	hyprpolkitagent
	swaync # Notifications
	qt5-wayland
	qt6-wayland
	noto-fonts
	noto-fonts-emoji
	wofi # App launcher
	waybar
	dolphin # File explorer
	otf-font-awesome
	brightnessctl # Control screen brightness
	kitty # Terminal Emulator
	pipewire # Audio backend
	pipewire-pulse
	pipewire-alsa
	wireplumber
	pavucontrol # Audio GUI
	playerctl
	xdg-desktop-portal-hyprland # Something to do with screen sharing
	xdg-desktop-portal-gtk # Fallback 
	grim # Dependencies for above.
	slurp # Same as above. Who names these?
	# iio-sensor-proxy # for device rotation to update screen rotation
	### The next two are for system backup and restore
	cronie
	timeshift
	# Bluetooth packages
	bluez
	bluez-utils
	blueman # Bluetooth manager GUI 
	### Japanese fonts and input manager
	# Right click the keyboard icon in the tray -> configure -> enable mozc
	adobe-source-han-sans-jp-fonts
	adobe-source-han-serif-jp-fonts
	noto-fonts-cjk
	fcitx5-im
	fcitx5-mozc
	# You can bookmark this ip for the cups web interface
	# http://localhost:631/admin
	cups
	cups-pdf # Print to PDF. You can also just use web browser print to pdf.
	avahi # Printer discovery
	nss-mdns # For above

)

echo -e "${INDENT} Installing packages..."
sudo pacman -S --noconfirm --needed "${PKGS[@]}"
echo -e "${INDENT} Finished installing packages"

echo -e "${INDENT} Enabling services..."
sudo timedatectl set-ntp true # Enable systemd-timesyncd for time syncronization.
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now nftables.service
sudo systemctl enable --now cronie.service
sudo systemctl enable --now reflector.service

### Enable printer service, configure avahi, and allow discovery through firewall
sudo systemctl enable --now avahi-daemon.service
# Enbable local hostname resolution for avahi
sudo sed -i '/^hosts: mymachines resolve \[!UNAVAIL=return] files myhostname dns$/c\hosts: mymachines mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] files myhostname dns' /etc/nsswitch.conf
sudo systemctl enable --now cups.service
# Allow udp port for avahi in nftables
sudo nft list chain inet filter input | grep -q 'udp dport 5353 accept' || \
sudo nft add rule inet filter input udp dport 5353 accept comment "allow_mdns"

# Install yay (AUR helper) if not already installed
if ! command -v yay &>/dev/null; then
	echo -e "${INDENT} Installing yay..."
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	(cd /tmp/yay && makepkg -si --noconfirm)
	rm -rf /tmp/yay
else
	echo -e "${INDENT} yay is already installed"
fi

### After yay is installed, I recommend installing the following:
# - informant - Informs you of important news before a system upgrade
# - yt-dlp-ejs - For downloading videos, you need deno and a solver script.
# - iio-hyprland - If you need auto orientation e.g. 2-in-1 tablet.
# 		See https://github.com/JeanSchoeller/iio-hyprland for more info.
# 		It requires jq as a dependency. (iio-hyprland is on the AUR)
# - visual-studio-code-bin - Binary blob for Visual Studio Code.

# We don't auto install yay packages because they are technically unsecure.

### Sets the default URL opener for things such as terminal.
# You can change it if you have another preference (e.g. chrome)
echo -e "${INDENT} Setting default xdg web browser to firefox"
xdg-settings set default-web-browser firefox.desktop

echo -e "${INDENT} Setting up wallpaper at ~/Pictures/Wallpaper (Will not overwrite existing)"
# Create wallpaper directory and copy wallpaper to it.
mkdir -p ~/Pictures/Wallpaper
cp -n wallpaper.jpg ~/Pictures/Wallpaper/

# Install vim plugin manager
# This isn't super secure...
echo -e "${INDENT} Installing vim-plug plugin manager..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Increase vm.max_map_count for game compatibility
GAME_COMPAT_FILE="/etc/sysctl.d/80-gamecompatibility.conf"
if [ ! -f "$GAME_COMPAT_FILE" ]; then
	echo -e "${INDENT} Creating vm.max_map_count game compatibility file"
    echo "vm.max_map_count = 2147483642" | sudo tee "$GAME_COMPAT_FILE" > /dev/null
    sudo sysctl --system
else
    echo -e "${INDENT} vm.max_map_count increase already exists"
fi

### Inform users of steps that require manual intervention.
echo -e "${INDENT} ${RED}To Configure Japanese Input:${NC}"
echo "Right click the keyboard icon in the tray -> configure -> enable mozc"

echo -e "${INDENT} ${RED}Configure printers at${NC} ${BLUE}http://localhost:631/admin${NC}"
echo "Login to the admin page using your root username and password. (Bookmark recommended)"

echo -e "${INDENT} ${RED}The default hyprland configuration is located in .config/hypr/hyprland.conf${NC}"
echo "The default configuration rotates the screen by 180 degrees. Remove 'transform, 3' to disable this."

### Calculate script runtime and finish.
end=$(date +%s)
elapsed=$((end - start))
minutes=$((elapsed / 60))
seconds=$((elapsed % 60))

echo -e "${INDENT} ${GREEN}Setup complete!${NC}"
echo -e "${INDENT} ${BLUE}Finished in ${minutes}m ${seconds}s${NC}"
