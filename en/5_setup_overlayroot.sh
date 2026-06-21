#!/bin/bash
set -e

echo "=== 1. Installing the official overlayroot package ==="
sudo apt update && sudo apt install -y overlayroot

echo -e "\n=== 2. Configuring overlayroot ==="
# Configure overlayroot to activate ONLY when the kernel
# detects a specific parameter from grub-btrfs. By default, the main system remains untouched.
sudo tee /etc/overlayroot.conf > /dev/null << 'EOF'
overlayroot_auth="disabled"
overlayroot=""
EOF
echo "Base overlayroot configuration created in standby mode."

echo -e "\n=== 3. Linking overlayroot to the GRUB snapshot menu ==="
CONFIG_FILE="/etc/default/grub-btrfs/config"

# Set up the overlayroot activation trigger for initramfs-tools
if grep -q "GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS=" "$CONFIG_FILE"; then
    sudo sed -i 's/^[# ]*GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS=.*/GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="overlayroot=tmpfs"/' "$CONFIG_FILE"
else
    echo 'GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="overlayroot=tmpfs"' | sudo tee -a "$CONFIG_FILE"
fi
echo "Kernel parameters for grub-btrfs successfully updated."

echo -e "\n=== 4. Updating initramfs and GRUB menu ==="
sudo update-initramfs -u -k all
sudo update-grub

echo -e "\n[SUCCESS] Configuration complete! The system is ready to boot into RAM."
