#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Disabling mounting of HFS, FreeVxFS, and JFFS2 filesystems..."

# Disable HFS filesystem support (remove hfs module)
echo "Disabling HFS filesystem..."
echo "install hfs /bin/true" > /etc/modprobe.d/blacklist-hfs.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/blacklist-hfs.conf

# Disable FreeVxFS filesystem support (remove freevxfs module)
echo "Disabling FreeVxFS filesystem..."
echo "install freevxfs /bin/true" > /etc/modprobe.d/blacklist-freevxfs.conf

# Disable JFFS2 filesystem support (remove jffs2 module)
echo "Disabling JFFS2 filesystem..."
echo "install jffs2 /bin/true" > /etc/modprobe.d/blacklist-jffs2.conf

# Update the initramfs to reflect the changes (important for kernel module changes)
echo "Updating initramfs to apply changes..."
update-initramfs -u

# Disable mounting these filesystems in /etc/fstab
echo "Disabling filesystem mounts in /etc/fstab..."

# Backup /etc/fstab before modifying it
cp /etc/fstab /etc/fstab.bak

# Remove any HFS, FreeVxFS, and JFFS2 filesystem entries from /etc/fstab
sed -i '/hfs/d' /etc/fstab
sed -i '/freevxfs/d' /etc/fstab
sed -i '/jffs2/d' /etc/fstab

# Verify changes
echo "Verifying the changes..."
echo "Checking if the filesystems are blacklisted:"
grep -i 'hfs\|freevxfs\|jffs2' /etc/modprobe.d/*
echo "Checking /etc/fstab for entries:"
grep -i 'hfs\|freevxfs\|jffs2' /etc/fstab

echo "Filesystems HFS, FreeVxFS, and JFFS2 have been disabled."
