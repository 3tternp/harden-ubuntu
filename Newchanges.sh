#!/bin/bash

# Banner
echo "#############################################"
echo "#           Linux Hardening Script          #"
echo "#           Prepared by Your Astra          #"
echo "#############################################"

# Function to check if the script is running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root or use sudo."
        exit 1
    fi
}

# Function to update the system
update_system() {
    echo "Updating the system..."
    apt-get update -y && apt-get upgrade -y
    echo "System updated successfully!"
}

# Function to install and configure UFW firewall
configure_firewall() {
    echo "Installing and configuring UFW firewall..."
    apt-get install ufw -y
    ufw enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    echo "Firewall configuration complete. SSH allowed."
}

# Function to configure secure SSH settings
secure_ssh() {
    echo "Configuring secure SSH settings..."
    sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Secure SSH settings applied (Root login disabled, password authentication disabled)."
}

# Function to configure password policies
configure_password_policies() {
    echo "Configuring password policies..."
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs
    echo "Password policies configured (90-day max, 7-day min, 14-day warning)."
}

# Function to install and configure fail2ban
install_fail2ban() {
    echo "Installing and configuring Fail2Ban..."
    apt-get install fail2ban -y
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    sed -i 's/^bantime.*/bantime = 3600/' /etc/fail2ban/jail.local
    systemctl restart fail2ban
    echo "Fail2Ban installed and configured (ban time: 1 hour)."
}

# Function to disable unused services
disable_unused_services() {
    echo "Disabling unused services..."
    for service in avahi-daemon cups isc-dhcp-server isc-dhcp-server6 slapd nfs-server rpcbind; do
        systemctl disable $service 2>/dev/null
    done
    echo "Unused services disabled."
}

# Function to apply kernel hardening settings
apply_kernel_hardening() {
    echo "Applying kernel hardening settings..."
    cat >> /etc/sysctl.conf <<EOF
kernel.randomize_va_space = 2
kernel.exec-shield = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 1
kernel.perf_event_paranoid = 2
kernel.yama.ptrace_scope = 1
kernel.unprivileged_bpf_disabled = 1
EOF
    sysctl -p
    echo "Kernel hardening settings applied."
}

# Function to install and configure auditd
configure_auditd() {
    echo "Installing and configuring Auditd..."
    apt-get install auditd -y
    systemctl enable auditd
    systemctl start auditd
    echo "Auditd installed and running."
}

# Function to configure filesystem hardening
harden_filesystem() {
    echo "Applying filesystem hardening..."
    cat >> /etc/fstab <<EOF
tmpfs /tmp tmpfs defaults,noexec,nosuid,nodev 0 0
tmpfs /var/tmp tmpfs defaults,noexec,nosuid,nodev 0 0
tmpfs /var/log tmpfs defaults,noexec,nosuid,nodev,size=100M 0 0
tmpfs /var/log/audit tmpfs defaults,noexec,nosuid,nodev,size=100M 0 0
EOF
    mount -a
    echo "Filesystem hardening applied."
}

# Function to install and configure AppArmor
configure_apparmor() {
    echo "Installing and configuring AppArmor..."
    apt-get install -y apparmor apparmor-utils
    systemctl enable apparmor
    systemctl start apparmor
    aa-enforce /etc/apparmor.d/*
    echo "AppArmor installed and enforced."
}

# Function to reboot the system
reboot_system() {
    echo "System reboot is required to apply all changes. Reboot now? (yes/no)"
    read reboot_choice
    if [[ "$reboot_choice" == "yes" || "$reboot_choice" == "y" ]]; then
        echo "Rebooting system..."
        reboot
    else
        echo "Reboot skipped. Please reboot manually later."
    fi
}

# Main script execution
check_root
update_system
configure_firewall
secure_ssh
configure_password_policies
install_fail2ban
disable_unused_services
apply_kernel_hardening
configure_auditd
harden_filesystem
configure_apparmor
reboot_system

echo "#############################################"
echo "#         Linux Hardening Completed         #"
echo "#       Ensure to review applied settings   #"
echo "#############################################"
