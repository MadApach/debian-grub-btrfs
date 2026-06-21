#!/bin/bash

# Script to automatically configure stable GRUB-BTRFS menu updates
# via systemd.path monitoring as a replacement for the buggy grub-btrfsd.

set -e  # Exit immediately if a command exits with a non-zero status

echo "=== 1. Disabling the old grub-btrfsd daemon ==="
if systemctl is-enabled grub-btrfsd.service &>/dev/null; then
    sudo systemctl disable --now grub-btrfsd.service
    echo "The old grub-btrfsd daemon has been successfully disabled."
else
    echo "The old grub-btrfsd daemon was already disabled or is missing."
fi

echo -e "\n=== 2. Creating the systemd.path file ==="
sudo tee /etc/systemd/system/grub-btrfs-watcher.path > /dev/null << 'EOF'
[Unit]
Description=Watch Snapper directory for GRUB menu updates
Documentation=https://github.com

[Path]
PathChanged=/.snapshots
Unit=grub-btrfs-watcher.service

[Install]
WantedBy=multi-user.target
EOF
echo "The grub-btrfs-watcher.path file has been successfully created."

echo -e "\n=== 3. Creating the systemd.service file ==="
sudo tee /etc/systemd/system/grub-btrfs-watcher.service > /dev/null << 'EOF'
[Unit]
Description=Regenerate GRUB-BTRFS Menu
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "if [ -s /boot/grub/grub-btrfs.cfg ]; then /etc/grub.d/41_snapshots-btrfs; else grub-mkconfig -o /boot/grub/grub.cfg; fi"
EOF
echo "The grub-btrfs-watcher.service file has been successfully created."

echo -e "\n=== 4. Reloading systemd daemon and activating the new watcher ==="
sudo systemctl daemon-reload
sudo systemctl enable --now grub-btrfs-watcher.path

echo -e "\n=== 5. Checking the status of the new watcher ==="
if systemctl is-active grub-btrfs-watcher.path &>/dev/null; then
    echo "SUCCESS: New systemd.path monitoring is successfully running and active!"
else
    echo "ERROR: Something went wrong, the .path service is not active."
    exit 1
fi

echo -e "\nConfiguration complete! Now, whenever snapshots are created or deleted (including APT pre/post snapshots), the GRUB menu will update automatically."
