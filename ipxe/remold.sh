#!/bin/sh

set -e 

sudo dnf install -y ipxe-bootimgs-x86 jq
sudo cp /usr/share/ipxe/ipxe-x86_64.efi /boot/efi/EFI

_jq() {
	jq --arg efiroot /boot/efi "$@"
}

devinfo="$(lsblk --json | _jq -r '.blockdevices[] | select (.children and (.children[].mountpoints | contains([$efiroot])))')"

dev="$(echo "$devinfo" | jq -r .name)"

# Find the partition number by getting the index of the children array contains the /boot/efi mountpoint entry.
#
# in jq, map(truthy) | index(true) reports the index contasdfasdf
# 
# If it's not found, index() returns null
# Also, the index, if found, is zero offset. So, add 1 to make it a partition number.
# Null becomes zero, in this case, indicating an error finding the /boot/efi device partiition.
partition="$(echo "$devinfo" | _jq '.children | map(.mountpoints | contains([$efiroot])) | (index(true) // -1) + 1')"

if [ "$partition" -eq 0 ] ; then
	echo "Couldn't find device with /boot/efi mounted?"
	exit 1
fi

echo "Device: $dev"
echo "Partition: $partition"

# Generate autoexec.ipxe
sudo tee /boot/efi/EFI/autoexec.ipxe << AUTOEXEC
#!ipxe

echo Hello world
sleep 1

# Set repository URI
set mirror http://10.0.2.2:29145/fedora/linux/releases/44
set repo \${mirror}/Everything/x86_64/os

dhcp

# Start installer
kernel \${repo}/images/pxeboot/vmlinuz inst.repo=\${repo}
initrd \${repo}/images/pxeboot/initrd.img
boot
AUTOEXEC

# Install ipxe and set nextboot to use it.

sudo cp /usr/share/ipxe/ipxe-x86_64.efi /boot/efi/EFI

# Delete any old entry
sudo efibootmgr -B -L ipxe || true

sudo efibootmgr -c -l "\\EFI\\ipxe-x86_64.efi" -L ipxe -d "/dev/$dev" -p "$partition"
sudo efibootmgr -n $(sudo efibootmgr  | sed -Ene '/ipxe-x86_64.efi/s/^Boot([0-9A-Fa-f]+).*/\1/p')

sudo reboot
