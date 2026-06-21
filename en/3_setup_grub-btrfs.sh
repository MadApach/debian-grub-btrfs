#!/bin/bash

sudo apt install gawk inotify-tools
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sudo make install
rm -rf grub-btrfs
