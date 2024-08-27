# harden-ubuntu
Currently this script contain following hardening actions: 

Updates and upgrades the system packages.

Installs and configures the Uncomplicated Firewall (ufw) with default rules to deny incoming traffic and allow outgoing traffic.

Configures secure SSH by disabling root login and password authentication.

Configures password policies to set maximum password age, minimum days between password changes, and warning days before password expiration.

Installs and configures fail2ban to protect against brute-force attacks.

Disables unused services to reduce attack surface.

Enables kernel security features to improve system security.

Installs and configures auditd for auditing system events.

Reboots the system to apply changes.
