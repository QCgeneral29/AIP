# Arch Install Plus 
Only run the setup script after installing Arch Linux

# Installation
Install git and clone this repo to your system

```bash
sudo pacman -S git

git clone https://github.com/QCgeneral29/AIP
```

Running the setup script does the following
- Enable multilib packages
- Run system update
- Install recommended packages
- Enable system services
- Install yay


NOTE: The setup script does not install any yay packages. You need to do this yourself.
See comments in the setup script for more details and recommendations.

Run the setup script
```bash
chmod +x setup.sh
./setup.sh
```

# Useful commands
```bash
# Create symlinks for all dot files
stow .

# Remove all symlinks created by Gnu Stow
stow -D .
```
