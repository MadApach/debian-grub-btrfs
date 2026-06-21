#!/bin/bash

set -e

echo "Создание сабволов для каталогов, не попадающих в снапшоты..."

for dir in /var/cache /var/tmp; do
echo
echo "Обработка $dir"

mv "$dir" "${dir}.old"

btrfs subvolume create "$dir"

cp -a "${dir}.old"/. "$dir"/

rm -rf "${dir}.old"

done

echoq
echo "Готово."
echo

echo "Проверка:"
btrfs subvolume list /
