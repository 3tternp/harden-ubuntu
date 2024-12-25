#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Setting up a separate partition for /var/tmp..."

# Step 1: Check if /var/tmp already has a separate partition
MOUNT_INFO=$(mount | grep "/var/tmp")
if [ -n "$MOUNT_INFO" ]; then
    echo "/var/tmp already has a separate partition:"
    echo "$MOUNT_INFO"
    exit 0
fi

# Step 2: Create a new file system for /var/tmp
PARTITION="/dev/sdX1"  # Replace this with the actual partition name
echo "WARNING: This script assumes you have an available partition at $PARTITION."
echo "Please update the script with the correct partition before running."
echo "Press Ctrl+C to abort, or wait 10 seconds to continue..."
sleep 10

# Format the partition
echo "Formatting $PARTITION as ext4..."
mkfs.ext4 "$PARTITION"

# Step 3: Backup existing data in /var/tmp
echo "Backing up existing /var/tmp data to /tmp/var_tmp_backup..."
mkdir -p /tmp/var_tmp_backup
cp -a /var/tmp/* /tmp/var_tmp_backup

# Step 4: Update /etc/fstab to mount the partition
echo "Adding entry to /etc/fstab for /var/tmp..."
echo "$PARTITION    /var/tmp    ext4    defaults,nodev,nosuid,noexec    0 2" >> /etc/fstab

# Step 5: Mount the new partition
echo "Mounting the new /var/tmp partition..."
mount /var/tmp

# Step 6: Restore backup data
echo "Restoring backup data to /var/tmp..."
cp -a /tmp/var_tmp_backup/* /var/tmp
rm -rf /tmp/var_tmp_backup

# Step 7: Verify the setup
echo "Verifying the new /var/tmp partition..."
mount | grep "/var/tmp" && echo "/var/tmp partition setup successfully." || echo "Failed to set up /var/tmp partition."

echo "Process completed. Please reboot the system to ensure the changes take effect."
