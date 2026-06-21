#!/bin/bash

sudo apt install snapper btrfs-assistant curl
sudo snapper -c root create-config /
sudo snapper -c root set-config TIMELINE_CREATE=no
sudo systemctl disable --now snapper-timeline.timer
sudo systemctl enable snapper-boot.timer
./tune_apt_snapshots.sh
