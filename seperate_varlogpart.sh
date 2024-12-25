#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Creating separate partitions for /var/log and /var/log/audit..."

# Step 1: Identify available disk space
echo "Checking available disk space..."
lsblk
echo "Please ensure you have unallocated disk space or a spare disk/partition available."
read -p "Enter the disk or partition for /var/log (e.g., /dev/sdb1): " VAR_LOG_DISK
read -p "Enter the disk or partition for /var/log/audit (e.g., /dev/sdb2): " VAR_LOG_AUDIT_DISK

# Step 2: Create file systems
echo "Creating filesystems on the selected partitions..."
mkfs.ext4 "$VAR_LOG_DISK"
mkfs.ext4 "$VAR_LOG_AUDIT_DISK"

# Step 3: Backup existing data
echo "Backing up existing /var/log and /var/log/audit data..."
mkdir -p /backup/var_log
cp -a /var/log/* /backup/var_log/

mkdir -p /backup/var_log_audit
cp -a /var/log/audit/* /backup/var_log_audit/ 2>/dev/null || echo "/var/log/audit is empty or doesn't exist."

# Step 4: Mount new partitions
echo "Mounting new partitions..."
mkdir -p /mnt/var_log /mnt/var_log_audit
mount "$VAR_LOG_DISK" /mnt/var_log
mount "$VAR_LOG_AUDIT_DISK" /mnt/var_log_audit

# Step 5: Move data to new partitions
echo "Moving data to new partitions..."
rsync -av /backup/var_log/ /mnt/var_log/
rsync -av /backup/var_log_audit/ /mnt/var_log_audit/

# Step 6: Update fstab
echo "Updating /etc/fstab to mount partitions at boot..."
UUID_VAR_LOG=$(blkid -s UUID -o value "$VAR_LOG_DISK")
UUID_VAR_LOG_AUDIT=$(blkid -s UUID -o value "$VAR_LOG_AUDIT_DISK")

echo "UUID=$UUID_VAR_LOG /var/log ext4 defaults 0 2" >> /etc/fstab
echo "UUID=$UUID_VAR_LOG_AUDIT /var/log/audit ext4 defaults 0 2" >> /etc/fstab

# Step 7: Apply changes
echo "Applying changes..."
umount /mnt/var_log
umount /mnt/var_log_audit
mount -a

# Step 8: Verify mounts
echo "Verifying new mounts..."
mount | grep -E '/var/log|/var/log/audit'

# Cleanup
echo "Cleaning up..."
rm -rf /backup/var_log /backup/var_log_audit
rmdir /mnt/var_log /mnt/var_log_audit

echo "Separate partitions for /var/log and /var/log/audit have been created and mounted successfully."
