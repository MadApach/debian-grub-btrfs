#!/bin/bash
set -e

echo "=== 1. Установка официального пакета overlayroot ==="
sudo apt update && sudo apt install -y overlayroot

echo -e "\n=== 2. Конфигурация overlayroot ==="
# Настраиваем overlayroot так, чтобы он активировался ТОЛЬКО если ядро
# видит специальный параметр от grub-btrfs. По умолчанию обычная система не трогается.
sudo tee /etc/overlayroot.conf > /dev/null << 'EOF'
overlayroot_auth="disabled"
overlayroot=""
EOF
echo "Базовый конфиг overlayroot создан в режиме ожидания."

echo -e "\n=== 3. Привязка overlayroot к меню снимков GRUB ==="
CONFIG_FILE="/etc/default/grub-btrfs/config"

# Прописываем триггер активации overlayroot для initramfs-tools
if grep -q "GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS=" "$CONFIG_FILE"; then
    sudo sed -i 's/^[# ]*GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS=.*/GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="overlayroot=tmpfs"/' "$CONFIG_FILE"
else
    echo 'GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="overlayroot=tmpfs"' | sudo tee -a "$CONFIG_FILE"
fi
echo "Параметры ядра для grub-btrfs успешно обновлены."

echo -e "\n=== 4. Обновление initramfs и меню GRUB ==="
sudo update-initramfs -u -k all
sudo update-grub

echo -e "\n[УСПЕХ] Настройка завершена! Система готова к загрузке в ОЗУ."
