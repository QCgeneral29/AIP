# Arch Install Plus 
Only run the setup script after installing Arch Linux

# Installation
Install git and clone this repo to your system

Run the setup script to install the recommened packages, enable system services,
and install yay.

NOTE: The setup script does not install yay packages. You need to do this yourself.
See comments in the setup script for more details and recommendations.

```bash
chmod +x setup.sh
./setup.sh
```

# Useful commands
Remove all symlinks created by Gnu Stow
```bash
stow -D .
```
