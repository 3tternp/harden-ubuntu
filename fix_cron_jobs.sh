#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

# Directories to fix
CRON_DIRECTORIES=(
    "/etc/cron.hourly"
    "/etc/cron.daily"
    "/etc/cron.weekly"
    "/etc/cron.monthly"
    "/etc/cron.d"
    "/var/spool/cron/crontabs"
)

# Fix ownership and permissions
echo "Fixing permissions and ownership for cron directories and files..."
for DIR in "${CRON_DIRECTORIES[@]}"; do
    if [ -d "$DIR" ]; then
        echo "Processing $DIR..."
        # Set correct ownership (root:root)
        chown -R root:root "$DIR"

        # Set permissions
        find "$DIR" -type d -exec chmod 755 {} \;  # Directories
        find "$DIR" -type f -exec chmod 644 {} \;  # Files
    else
        echo "Directory $DIR does not exist, skipping..."
    fi
done

# Ensure /var/spool/cron/crontabs has special permissions
if [ -d "/var/spool/cron/crontabs" ]; then
    chmod 730 /var/spool/cron/crontabs
    chown root:crontab /var/spool/cron/crontabs
    echo "Special permissions applied to /var/spool/cron/crontabs."
fi

# Restart cron service
echo "Restarting cron service..."
systemctl restart cron

# Verify the changes
echo "Verifying permissions..."
for DIR in "${CRON_DIRECTORIES[@]}"; do
    if [ -d "$DIR" ]; then
        ls -ld "$DIR"
        find "$DIR" -type f -exec ls -l {} \;
    fi
done

echo "All cron jobs and directories have been fixed."
