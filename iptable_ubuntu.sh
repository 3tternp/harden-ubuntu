#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

# Add or update the IP forwarding setting in /etc/sysctl.conf
echo "Enabling IP forwarding permanently..."
if grep -q "^net.ipv4.ip_forward" /etc/sysctl.conf; then
    sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
else
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi

# Apply the changes immediately
echo "Applying the changes..."
sysctl -p

# Verify the change
echo "Verification:"
sysctl net.ipv4.ip_forward
