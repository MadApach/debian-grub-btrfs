#!/bin/bash

CONFIG="/etc/default/snapper"

# Create config file if it does not exist
if [ ! -f "$CONFIG" ]; then
    sudo mkdir -p "$(dirname "$CONFIG")"
    echo 'DISABLE_APT_SNAPSHOT="no"' | sudo tee "$CONFIG" >/dev/null
fi

# Get the current value
CURRENT=$(grep '^DISABLE_APT_SNAPSHOT=' "$CONFIG" | cut -d'"' -f2)

if [ "$CURRENT" = "yes" ]; then
    echo "APT snapshot creation is currently: DISABLED"
else
    echo "APT snapshot creation is currently: ENABLED"
fi

echo
echo "1) Enable APT snapshots"
echo "2) Disable APT snapshots"
echo "0) Exit"
echo

read -rp "Your choice: " CHOICE

case "$CHOICE" in
    1)
        VALUE="no"
        MESSAGE="enabled"
        ;;
    2)
        VALUE="yes"
        MESSAGE="disabled"
        ;;
    0)
        exit 0
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

if grep -q '^DISABLE_APT_SNAPSHOT=' "$CONFIG"; then
    sudo sed -i "s/^DISABLE_APT_SNAPSHOT=.*/DISABLE_APT_SNAPSHOT=\"$VALUE\"/" "$CONFIG"
else
    echo "DISABLE_APT_SNAPSHOT=\"$VALUE\"" | sudo tee -a "$CONFIG" >/dev/null
fi

echo
echo "Done. APT snapshot creation is now $MESSAGE."
echo
grep '^DISABLE_APT_SNAPSHOT=' "$CONFIG"
