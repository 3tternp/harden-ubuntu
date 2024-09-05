#!/bin/bash

# Update the system
apt-get update
apt-get upgrade -y

# Install and configure firewall (ufw)
apt-get install ufw -y
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh

# Configure secure SSH
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Configure password policies
sed -i 's/PASS_MAX_DAYS\s+99999/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS\s+0/PASS_MIN_DAYS 7/' /etc/login.defs
sed -i 's/PASS_WARN_AGE\s+7/PASS_WARN_AGE 14/' /etc/login.defs

# Install and configure fail2ban
apt-get install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/bantime\s*=\s*600/bantime = 3600/' /etc/fail2ban/jail.local
systemctl restart fail2ban

# Disable unused services
systemctl disable avahi-daemon
systemctl disable cups
systemctl disable isc-dhcp-server
systemctl disable isc-dhcp-server6
systemctl disable slapd
systemctl disable nfs-server
systemctl disable rpcbind

# Enable kernel security features
echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
echo "kernel.exec-shield = 1" >> /etc/sysctl.conf
echo "kernel.dmesg_restrict = 1" >> /etc/sysctl.conf
echo "kernel.kptr_restrict = 1" >> /etc/sysctl.conf
echo "kernel.perf_event_paranoid = 2" >> /etc/sysctl.conf
echo "kernel.yama.ptrace_scope = 1" >> /etc/sysctl.conf
echo "kernel.unprivileged_bpf_disabled = 1" >> /etc/sysctl.conf
sysctl -p

# Install and configure auditd
apt-get install auditd -y
auditctl -e 1

# Configure file system hardening
echo "tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
echo "tmpfs /var/log tmpfs defaults,noexec,nosuid,nodev,size=100M 0 0" >> /etc/fstab
echo "tmpfs /var/log/audit tmpfs defaults,noexec,nosuid,nodev,size=100M 0 0" >> /etc/fstab
echo "tmpfs /home/tmp tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab

# Step 1: Ensure AppArmor is installed and enabled
echo "Installing AppArmor..."
apt update
apt install -y apparmor apparmor-utils auditd

# Step 2: Enable AppArmor to start at boot
echo "Enabling AppArmor..."
systemctl enable apparmor
systemctl start apparmor

# Step 3: Enforce AppArmor profiles
echo "Setting AppArmor profiles to enforce mode..."
aa-enforce /etc/apparmor.d/*

# Step 4: Apply additional hardening
echo "Applying CIS-based hardening..."

# Ensure Auditd service is running (for AppArmor logging)
echo "Ensuring Auditd is running..."
systemctl enable auditd
systemctl start auditd

# Set kernel parameter for hardening
echo "Setting kernel parameters for hardening..."
sysctl -w kernel.dmesg_restrict=1
sysctl -w kernel.kptr_restrict=2

# Save parameters to apply after reboot
cat >> /etc/sysctl.conf <<EOF
kernel.dmesg_restrict=1
kernel.kptr_restrict=2

# Restart the system to apply changes
reboot
