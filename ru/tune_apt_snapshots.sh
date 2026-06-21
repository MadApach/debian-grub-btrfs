#!/bin/bash

CONFIG="/etc/default/snapper"

# Создать файл, если его нет
if [ ! -f "$CONFIG" ]; then
    sudo mkdir -p "$(dirname "$CONFIG")"
    echo 'DISABLE_APT_SNAPSHOT="no"' | sudo tee "$CONFIG" >/dev/null
fi

# Получить текущее значение
CURRENT=$(grep '^DISABLE_APT_SNAPSHOT=' "$CONFIG" | cut -d'"' -f2)

if [ "$CURRENT" = "yes" ]; then
    echo "Сейчас создание снапшотов при работе apt: ОТКЛЮЧЕНО"
else
    echo "Сейчас создание снапшотов при работе apt: ВКЛЮЧЕНО"
fi

echo
echo "1) Включить снапшоты apt"
echo "2) Отключить снапшоты apt"
echo "0) Выход"
echo

read -rp "Ваш выбор: " CHOICE

case "$CHOICE" in
    1)
        VALUE="no"
        MESSAGE="включено"
        ;;
    2)
        VALUE="yes"
        MESSAGE="отключено"
        ;;
    0)
        exit 0
        ;;
    *)
        echo "Неверный выбор."
        exit 1
        ;;
esac

if grep -q '^DISABLE_APT_SNAPSHOT=' "$CONFIG"; then
    sudo sed -i "s/^DISABLE_APT_SNAPSHOT=.*/DISABLE_APT_SNAPSHOT=\"$VALUE\"/" "$CONFIG"
else
    echo "DISABLE_APT_SNAPSHOT=\"$VALUE\"" | sudo tee -a "$CONFIG" >/dev/null
fi

echo
echo "Готово. Создание снапшотов при работе apt $MESSAGE."
echo
grep '^DISABLE_APT_SNAPSHOT=' "$CONFIG"
