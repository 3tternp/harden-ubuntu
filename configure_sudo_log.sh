#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Configuring sudo log file..."

# Step 1: Define the log file path
SUDO_LOG_FILE="/var/log/sudo.log"

# Step 2: Create the log file if it doesn't exist
if [ ! -f "$SUDO_LOG_FILE" ]; then
    echo "Creating sudo log file at $SUDO_LOG_FILE..."
    touch "$SUDO_LOG_FILE"
    chmod 600 "$SUDO_LOG_FILE"
    chown root:root "$SUDO_LOG_FILE"
    echo "Sudo log file created."
else
    echo "Sudo log file already exists at $SUDO_LOG_FILE."
fi

# Step 3: Update sudoers configuration to enable logging
SUDOERS_FILE="/etc/sudoers"

# Check if logging directive already exists
if ! grep -q "Defaults log_output" "$SUDOERS_FILE"; then
    echo "Enabling sudo logging in sudoers configuration..."
    echo "Defaults log_output" >> "$SUDOERS_FILE"
    echo "Defaults logfile=\"$SUDO_LOG_FILE\"" >> "$SUDOERS_FILE"
    echo "Sudo logging enabled."
else
    echo "Sudo logging is already enabled in sudoers configuration."
fi

# Step 4: Test the sudoers configuration
echo "Validating sudoers configuration..."
if visudo -c; then
    echo "Sudoers configuration is valid."
else
    echo "Sudoers configuration is invalid. Please check /etc/sudoers for errors."
    exit 1
fi

echo "Sudo logging has been configured successfully. Logs will be written to $SUDO_LOG_FILE."
