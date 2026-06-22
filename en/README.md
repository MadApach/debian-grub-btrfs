# Script Set for Configuring an Unbreakable Btrfs + Snapper + GRUB Setup

This repository contains tools to automate the advanced configuration of the Btrfs filesystem in Debian (Testing/Sid). The scripts resolve common issues with default packages (such as the broken `grub-btrfs.path` service and the inability to boot into read-only snapshots) to ensure a stable and reliable system recovery process.

## Folder Structure and Script Descriptions

Each step is numbered and must be executed sequentially.

### 1. `1_tune_btrfs_subvols.sh` — Subvolume Structure Optimization
* **What it does:** Moves the `/var/cache` and `/var/tmp` directories into dedicated Btrfs subvolumes.
* **Why it's needed:** Excludes temporary files, apt caches, and flatpak caches from system snapshots. This prevents snapshots from bloating in size and keeps them clean.

### 2. `2_setup_btrfs_tools.sh` — Snapper Installation and Base Setup
* **What it does:** Installs `snapper`, `btrfs-assistant`, and `curl` packages. It automatically initializes the Snapper configuration for the root directory (`/`).
* **Features:** Completely disables scheduled snapshot creation (`TIMELINE`), activates snapshot creation on every boot (`boot-timer`), and launches the interactive APT snapshot configurator.

### ── `tune_apt_snapshots.sh` — APT Snapshot Toggle (Helper Script)
* **What it does:** Triggered automatically by script #2. Provides an interactive menu in the terminal.
* **Why it's needed:** Allows enabling or disabling automatic paired snapshots (Pre/Post) before running `apt upgrade` or `apt install` with a single command. Useful when you need to temporarily pause snapshots while installing a large number of small packages.

### 3. `3_setup_grub-btrfs.sh` — Clean GRUB-BTRFS Installation
* **What it does:** Clones the latest version of `grub-btrfs` directly from its official GitHub repository, compiles it, integrates it into the system, and correctly removes all temporary build files afterward.

### 4. `4_setup_grub_watcher.sh` — Fixing GRUB Menu Auto-Updates
* **What it does:** Completely disables the default `grub-btrfsd.service` daemon. Instead, it creates a custom combination of a `systemd.path` unit and a `systemd.service` unit to force GRUB menu updates whenever any snapshot operation occurs.
* **Why it's needed:** The default Debian service does not work because the Linux kernel's `Inotify` cannot track Snapper's API calls during subvolume creation. This script fixes the "blind" bootloader issue.

### 5. `5_setup_overlayroot.sh` — Enabling Booting into Read-Only Snapshots (Boot to RAM)
* **What it does:** Installs the `overlayroot` utility and sets it to standby mode. It integrates the special `overlayroot=tmpfs` parameter into the `grub-btrfs` menu generation config, rebuilds `initramfs` images for all kernels, and updates GRUB.
* **Why it's needed:** Snapper snapshots are created in read-only mode by default, making a standard boot into them impossible (since the system needs to write logs, temporary files, sockets, etc.). This script forces the kernel to mount a virtual filesystem in RAM on top of the snapshot when selected in GRUB. The system boots and works flawlessly, but any modifications disappear upon reboot.

## How to Use

1. Make the scripts executable:
   ```bash
   chmod +x *.sh
   ```
2. Run them strictly in order from 1 to 5:
   ```bash
   ./1_tune_btrfs_subvols.sh
   ./2_setup_btrfs_tools.sh
   ./3_setup_grub-btrfs.sh
   ./4_setup_grub_watcher.sh
   ./5_setup_overlayroot.sh
   ```

**P.S.** The **Btrfs Assistant** utility installed in step 2 provides a user-friendly graphical interface (GUI) for managing Snapper. You can use it at any time to manually create, delete, compare, and restore snapshots, as well as modify retention settings (via the *Snapper Settings* tab). It becomes fully operational right after script #2 finishes.
