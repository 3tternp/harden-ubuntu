#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo to execute it."
    exit 1
fi

echo "Configuring password creation requirements..."

# Step 1: Ensure the required package is installed
echo "Installing libpam-pwquality package..."
sudo apt-get update -y
sudo apt-get install libpam-pwquality -y

# Step 2: Configure password requirements
PWQUALITY_CONF="/etc/security/pwquality.conf"

echo "Configuring password requirements in $PWQUALITY_CONF..."

cat <<EOF > "$PWQUALITY_CONF"
# Minimum password length
minlen = 10

# Require at least one uppercase letter
ucredit = -1

# Require at least one lowercase letter
lcredit = -1

# Require at least one digit
dcredit = -1

# Require at least one special character
ocredit = -1

# Enforce password history
remember = 3
EOF

echo "Password requirements configured in $PWQUALITY_CONF."

# Step 3: Update PAM common-password file
PAM_COMMON_PASSWORD="/etc/pam.d/common-password"

echo "Updating PAM configuration in $PAM_COMMON_PASSWORD..."
if ! grep -q "pam_pwquality.so" "$PAM_COMMON_PASSWORD"; then
    sed -i '/^password\s*requisite\s*pam_pwquality.so/!s/^password\s*requisite\s*pam_pwquality.so.*/password requisite pam_pwquality.so retry=3/' "$PAM_COMMON_PASSWORD"
else
    echo "pam_pwquality.so is already configured in $PAM_COMMON_PASSWORD."
fi

# Step 4: Restart services if necessary
echo "Password creation requirements have been configured."
