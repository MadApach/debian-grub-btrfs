#!/bin/bash

set -e

echo "Создание сабволов для каталогов, не попадающих в снапшоты..."

for dir in /var/cache /var/tmp; do
echo
echo "Обработка $dir"

sudo mv "$dir" "${dir}.old"

sudo btrfs subvolume create "$dir"

sudo cp -a "${dir}.old"/. "$dir"/

sudo rm -rf "${dir}.old"

done

echoq
echo "Готово."
echo

echo "Проверка:"
sudo btrfs subvolume list /
