#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Verifying and enabling XD/NX support..."

# Step 1: Check CPU support for NX/XD
CPU_FLAGS=$(grep -oE ' nx ' /proc/cpuinfo | head -n 1)
if [[ -z "$CPU_FLAGS" ]]; then
    echo "Your CPU does not support NX/XD. Please check your hardware."
    exit 1
else
    echo "CPU supports NX/XD."
fi

# Step 2: Check if NX is enabled in the kernel
NX_STATUS=$(dmesg | grep -i 'NX (Execute Disable) protection' || echo "disabled")
if [[ "$NX_STATUS" == *"disabled"* ]]; then
    echo "NX support is not enabled in the kernel. Enabling it now..."
    
    # Step 3: Update GRUB configuration to enab
