#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Disabling automounting on Ubuntu..."

# Disable GNOME automounting (if GNOME is being used)
echo "Checking GNOME automounting settings..."
gsettings set org.gnome.desktop.media-handling automount false
gsettings set org.gnome.desktop.media-handling automount-open false

# Disable USB automount via udisks2 (common backend for automounting)
echo "Disabling USB automount via udisks2 rules..."
sudo tee /etc/udev/rules.d/85-disable-automount.rules > /dev/null <<EOL
ENV{ID_FS_USAGE}=="filesystem|other", ENV{UDISKS_IGNORE}="1"
EOL

# Reload udev rules
echo "Reloading udev rules..."
sudo udevadm control --reload-rules && sudo udevadm trigger

# Optionally stop and disable udisks2 service (if it's not required)
echo "Stopping and disabling udisks2 service (optional)..."
sudo systemctl stop udisks2.service
sudo systemctl disable udisks2.service

echo "Automounting has been disabled. Please restart the system to ensure all changes take effect."
