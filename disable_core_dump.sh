#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Disabling core dumps permanently..."

# Update limits.conf to disable core dumps
echo "Updating /etc/security/limits.conf..."
if ! grep -q '^\* hard core 0' /etc/security/limits.conf; then
    echo "* hard core 0" | sudo tee -a /etc/security/limits.conf > /dev/null
fi

# Ensure PAM includes limits for all sessions
echo "Ensuring PAM configuration includes limits..."
for file in /etc/pam.d/common-session /etc/pam.d/common-session-noninteractive; do
    if ! grep -q '^session required pam_limits.so' "$file"; then
        echo "session required pam_limits.so" | sudo tee -a "$file" > /dev/null
    fi
done

# Update sysctl.conf to disable core dumps
echo "Updating /etc/sysctl.conf..."
if ! grep -q '^kernel.core_pattern=|/bin/false' /etc/sysctl.conf; then
    echo "kernel.core_pattern=|/bin/false" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

# Apply sysctl changes immediately
echo "Applying sysctl changes..."
sudo sysctl -p

# Verify settings
echo "Verification:"
ulimit -c
cat /proc/sys/kernel/core_pattern

echo "Core dumps have been permanently disabled."
