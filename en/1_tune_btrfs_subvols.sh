#!/bin/bash

set -e

echo "Creating subvolumes for directories excluded from snapshots..."

for dir in /var/cache /var/tmp; do
    echo
    echo "Processing $dir..."

    mv "$dir" "${dir}.old"

    btrfs subvolume create "$dir"

    cp -a "${dir}.old"/. "$dir"/

    rm -rf "${dir}.old"
done

echo
echo "Done."
echo

echo "Verification:"
btrfs subvolume list /
