#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Setting a password for GRUB bootloader..."

# Step 1: Generate a hashed password
read -sp "Enter a new GRUB password: " GRUB_PASSWORD
echo
read -sp "Confirm the GRUB password: " GRUB_PASSWORD_CONFIRM
echo

if [ "$GRUB_PASSWORD" != "$GRUB_PASSWORD_CONFIRM" ]; then
    echo "Passwords do not match. Exiting."
    exit 1
fi

HASHED_PASSWORD=$(echo -e "$GRUB_PASSWORD" | grub-mkpasswd-pbkdf2 | grep -oP 'grub.pbkdf2.*')

if [ -z "$HASHED_PASSWORD" ]; then
    echo "Failed to generate hashed password. Exiting."
    exit 1
fi

echo "Hashed password generated successfully."

# Step 2: Update GRUB configuration
echo "Updating GRUB configuration to include the password..."
CUSTOM_CONFIG="/etc/grub.d/40_custom"

if ! grep -q "set superusers" "$CUSTOM_CONFIG"; then
    cat <<EOF >> "$CUSTOM_CONFIG"

# GRUB password configuration
set superusers="root"
password_pbkdf2 root $HASHED_PASSWORD
EOF
    echo "Password added to $CUSTOM_CONFIG."
else
    echo "Password already configured in $CUSTOM_CONFIG. Skipping."
fi

# Step 3: Update GRUB to apply changes
echo "Updating GRUB to apply changes..."
update-grub

echo "GRUB bootloader password has been set successfully."
