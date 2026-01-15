# Arch Install Plus 

> [!IMPORTANT]
> Before running the setup script, you must install Arch Linux.

## 0. TLDR Arch Install

After booting into the installation medium, connect to the internet (ignore if on LAN). Then run archinstall.
```bash
### Connect to wifi

### Single command
iwctl --passphrase (passphrase) station (name) connect (SSID)

### OR

### Interactive Prompt
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

### Test connection
ping 1.1.1.1
```

```bash
# Run archinstall and follow the on-screen prompts.
archinstall
```
> [!NOTE]
>I recommend installing some basic packages during installation. E.g. vim, NetworkManager, git, etc.

## 1. Run the setup script
After running archinstall, reboot into the real system. 

Install git and clone this repo to your system

> [!IMPORTANT]
> If you intend to symlink the dotfiles using GNU Stow, you must clone this repo into your home directory.

```bash
# (optional) List available wifi connections.
nmcli device wifi list
# Connect to the internet with NetworkManager.
nmcli device wifi connect (SSID_or_BSSID) --ask

# Install Git.
sudo pacman -S git

# Clone AIP into your home folder with the name 'dotfiles'
cd ~ && git clone https://github.com/QCgeneral29/AIP.git dotfiles/
```

Run the setup script
```bash
chmod +x setup.sh && ./setup.sh
```

Running the setup script does the following
- Update the package mirrorlist
- Enable multilib packages
- Run system update
- Install packages (See packagelist in setup.sh)
- Enable system services
- Setup printer discovery 
- Install yay and vim-plug

> [!NOTE]
> The setup script does not install any yay packages. You need to do this yourself.
> See the comments in setup.sh for more details and recommendations.

## 2. Symlink the Dotfiles
After running setup.sh, run the following command to symlink all configuration files (dotfiles)

> [!WARNING]
> As of writing, the default hyprland.conf rotates the monitor by 270 degrees because I am using a 2-1 tablet.
> Remove the text 'transform, 3' in the 'monitors' section of .config/hypr/hyprland.conf to prevent this.

```bash
# THE AIP (or 'dotfiles') DIRECTORY MUST BE LOCATED IN YOUR HOME FOLDER!
cd ~/dotfiles

# Then, create symlinks for all dot files
stow .

# To delete the symlinks (undo)
stow -D .
```

## 3. Start hyprland
If you want to use a login manger, install one.
``` bash
sudo pacman -S sddm && sudo systemctl enable sddm
```

Otherwise, just launch hyprland from the terminal.
```bash
start-hyprland
```

## Congratulations!
お疲れ様でした！

You now have a working Arch Linux desktop environment. Please enjoy!
