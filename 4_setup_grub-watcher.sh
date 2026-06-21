#!/bin/bash

# Скрипт для автоматической настройки стабильного обновления меню GRUB-BTRFS
# через системный мониторинг путей systemd.path взамен багнутого grub-btrfsd.

set -e  # Прерывать выполнение при любой ошибке

echo "=== 1. Отключение старого демона grub-btrfsd ==="
if systemctl is-enabled grub-btrfsd.service &>/dev/null; then
    sudo systemctl disable --now grub-btrfsd.service
    echo "Старый демон grub-btrfsd успешно отключен."
else
    echo "Старый демон grub-btrfsd уже был отключен или отсутствует."
fi

echo -e "\n=== 2. Создание systemd.path файла ==="
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
echo "Файл grub-btrfs-watcher.path успешно создан."

echo -e "\n=== 3. Создание systemd.service файла ==="
sudo tee /etc/systemd/system/grub-btrfs-watcher.service > /dev/null << 'EOF'
[Unit]
Description=Regenerate GRUB-BTRFS Menu
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "if [ -s /boot/grub/grub-btrfs.cfg ]; then /etc/grub.d/41_snapshots-btrfs; else grub-mkconfig -o /boot/grub/grub.cfg; fi"
EOF
echo "Файл grub-btrfs-watcher.service успешно создан."

echo -e "\n=== 4. Перезапуск демона systemd и активация нового вотчера ==="
sudo systemctl daemon-reload
sudo systemctl enable --now grub-btrfs-watcher.path

echo -e "\n=== 5. Проверка статуса нового вотчера ==="
if systemctl is-active grub-btrfs-watcher.path &>/dev/null; then
    echo "УСПЕХ: Новый systemd.path мониторинг успешно запущен и работает!"
else
    echo "ОШИБКА: Что-то пошло не так, служба .path не активна."
    exit 1
fi

echo -e "\nНастройка завершена! Теперь при любом создании/удалении снимков (включая pre/post от APT) меню GRUB обновится автоматически."
