#!/bin/sh

dl="192.168.12.86"

curl --retry 10 --retry-all-errors --retry-delay 3 \
	-o /boot/efi/EFI/ipxe.efi "http://${dl}:29145/installer/ipxe-x86_64.efi"

curl --retry 10 --retry-all-errors --retry-delay 3 \
	-o /boot/efi/EFI/autoexec.ipxe "http://${dl}:29145/installer/autoexec.ipxe"


label="orchard-reimage"
efibootmgr -B -L "$label"

# Find the disk device and partition that houses /boot/efi
set -- $(lsblk --json \
				| jq -r '.blockdevices[] | select(.children).children[] | select (.mountpoints | contains(["/boot/efi"])) | .name' \
				| sed -Ee '/^nvme/{ s/^(.*)p([0-9]+)$/\1 \2/; q }; s/^(.*)([0-9]+)$/\1 \2/')

dev=$1 partition=$2

echo "Dev: $dev - Partition: $partition"
efibootmgr -c -l '\EFI\ipxe.efi' -L "$label" -d "/dev/${dev}" -p "$partition"
ipxe_boot="$(efibootmgr | sed -Ene "/${label}/s/^Boot([0-9A-Fa-f]+).*/\\1/p")"

efibootmgr -n "$ipxe_boot"
