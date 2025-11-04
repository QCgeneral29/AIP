# Arch Install Plus 

> [!IMPORTANT]
> Before running the setup script, you must install Arch Linux.

Archinstall

https://wiki.archlinux.org/title/Archinstall

The long guide

https://wiki.archlinux.org/title/Installation_guide

# TLDR Arch Install

After booting into the installation medium, do the following:
```bash
# Connect to the internet
# Single command
iwctl --passphrase (passphrase) station (name) connect (SSID)

# Interactive Prompt
iwctl
device list
# (If not powered on)
device (name) set-property Powered on
adapter (adapter) set-property Powered on
# Scan and connect
station (name) scan
station (name) get-networks
station (name) connect (SSID)
exit
# Test connection
ping 1.1.1.1

# Run archinstall and follow the on screen prompts
archinstall

# I recommend installing some basic packages during installation like vim, NetworkManager, git, etc.
```

# Setup script
After running archinstall, reboot into the real system. 

Install git and clone this repo to your system

> [!IMPORTANT]
> If you intend to symlink the dotfiles using GNU Stow, you must clone this repo to your home directory.

```bash
# Connect to the internet with NetworkManager
nmcli device wifi connect SSID_or_BSSID --ask

sudo pacman -S git # If not installed already

git clone https://github.com/QCgeneral29/AIP.git
```

Run the setup script
```bash
chmod +x setup.sh

./setup.sh
```

Running the setup script does the following
- Update the package mirrorlist
- Enable multilib packages
- Run system update
- Install recommended packages
- Enable system services
- Setup printer discovery 
- Install yay and vim-plug

> [!NOTE]
> The setup script does not install any yay packages. You need to do this yourself.
> See comments in the setup script for more details and recommendations.

# Symlink dotfiles
After running the setup script, run the following command to symlink all configuration files (dotfiles)

> [!WARNING]
> As of writing, the default hyprland.conf rotates the monitor by 270 degrees because I am using a 2-1 tablet.
> Remove the text "transform, 3" in the monitors section to prevent this.

```bash
# Create symlinks for all dot files
stow .

# To undo
stow -D .
```

# Start hyprland
If you want to use a login manger, install one
``` bash
sudo pacman -S sddm

sudo systemctl enable sddm
```

Otherwise, just launch hyprland from the terminal
```bash
hyprland
```

