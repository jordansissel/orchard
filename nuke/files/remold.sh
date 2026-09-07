#!/bin/sh

set -e 

sudo dnf install -y ipxe-bootimgs-x86 jq

#sudo apt-get install -y ipxe jq efibootmgr

_jq() {
	jq --arg efiroot /boot/efi "$@"
}

arch="$(uname -m)"

devinfo="$(lsblk --json | _jq -r '.blockdevices[] | select (.children and (.children[].mountpoints | contains([$efiroot])))')"

dev="$(echo "$devinfo" | jq -r .name)"

# Find the partition number by getting the index of the children array contains the /boot/efi mountpoint entry.
#
# in jq, map(truthy) | index(true) reports the index contasdfasdf
# 
# If it's not found, index() returns null
# Also, the index, if found, is zero offset. So, add 1 to make it a partition number.
# Null becomes zero, in this case, indicating an error finding the /boot/efi device partiition.
partition="$(echo "$devinfo" | _jq '.children | map(.mountpoints | contains([$efiroot])) | (index(true) // 0) + 1')"

# Grab the final numbers of the mount device, like vda15 => 15, or nvme0n1p3 -> 3
partdev="$(echo "$devinfo" | _jq -r '.children[] | select (.mountpoints | contains([$efiroot])) | .name' | grep -Eo '[0-9]+$')"

if [ "$partition" -eq 0 ] ; then
	echo "Couldn't find device with /boot/efi mounted?"
	exit 1
fi

echo "Device: $dev"
echo "Partition: $partition"

# Generate autoexec.ipxe
sudo tee /boot/efi/EFI/autoexec.ipxe > /dev/null << AUTOEXEC
#!ipxe

echo Hello world -- \${buildarch}
sleep 1

# Set repository URI
set arch x86_64
set mirror http://10.0.2.2:29145/fedora/linux/releases/44
set repo \${mirror}/Everything/\${buildarch}/os


echo Using : \${repo}
dhcp

echo 

# Start installer
kernel \${repo}/images/pxeboot/vmlinuz inst.repo=\${repo} -- console=/dev/tty1 console=/dev/ttyAMA0,115200n8
initrd \${repo}/images/pxeboot/initrd.img
shim ${repo}/EFI/BOOT/BOOTX64.EFI

echo Booting...
boot
AUTOEXEC

# Install ipxe and set nextboot to use it.

sudo cp /usr/share/ipxe/ipxe-x86_64.efi /boot/efi/EFI
#sudo cp /usr/lib/ipxe/ipxe-${arch}.efi /boot/efi/EFI

# Delete any old entry
sudo efibootmgr -B -L ipxe || true

# Create new entry
sudo efibootmgr -c -l "\\EFI\\ipxe-${arch}.efi" -L ipxe -d "/dev/$dev" -p "$partdev"

# Set it as next boot
sudo efibootmgr -n $(sudo efibootmgr  | sed -Ene "/ipxe-${arch}.efi/s/^Boot([0-9A-Fa-f]+).*/\1/p")

# Let's gooooooo
sudo reboot
