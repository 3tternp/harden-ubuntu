#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Disabling DCCP (Datagram Congestion Control Protocol)..."

# Step 1: Disable DCCP module immediately
echo "Unloading DCCP kernel module (if loaded)..."
if lsmod | grep -q dccp; then
    modprobe -r dccp
    echo "DCCP kernel module unloaded."
else
    echo "DCCP kernel module is not currently loaded."
fi

# Step 2: Permanently disable DCCP in modprobe configuration
MODPROBE_CONF="/etc/modprobe.d/disable-dccp.conf"
echo "Ensuring DCCP module is disabled in $MODPROBE_CONF..."
cat <<EOF > "$MODPROBE_CONF"
# Disable DCCP kernel module
blacklist dccp
EOF
echo "DCCP module has been blacklisted."

# Step 3: Disable DCCP in sysctl configuration
SYSCTL_CONF="/etc/sysctl.conf"
echo "Disabling DCCP in sysctl configuration..."
grep -q "^net.ipv4.dccp.disable=" "$SYSCTL_CONF" 2>/dev/null || echo "net.ipv4.dccp.disable=1" >> "$SYSCTL_CONF"
grep -q "^net.ipv6.dccp.disable=" "$SYSCTL_CONF" 2>/dev/null || echo "net.ipv6.dccp.disable=1" >> "$SYSCTL_CONF"

# Apply sysctl changes
sysctl -p

echo "DCCP has been disabled successfully."
