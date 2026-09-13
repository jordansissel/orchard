#!/bin/sh

: > '/PRE_PIVOT'

# Find the biggest disk
disk="$(lsblk --bytes --json | jq -r '.blockdevices | sort_by(-.size) | .[0].name')"

if [ -z "$disk" ] ; then
	echo "[ vvvvvv  ERROR  vvvvvv ]"
	echo "CANNOT FIND ANY DISK OOH MYYYYYYY"
	echo "[ ^^^^^^  ERROR  ^^^^^^ ]"
	exit 1
fi

echo "Disk: $disk" > /PRE_PIVOT

url=http://192.168.12.100:29145/fedora/linux/releases/44/Cloud/x86_64/images/Fedora-Cloud-Base-AmazonEC2-44-1.7.x86_64.raw.xz
curl "$url" | xz -dc > "/dev/${disk}"

# fedora cloud images use partition 3 for the main filessystem
mkdir /mnt
mount /dev/${disk}3 /mnt

kernel="$(ls -t /mnt/boot/vmlinuz* | sed -ne 1p)"
version="${kernel#*vmlinuz-}"

kexec --initrd "/mnt/boot/initramfs-$version.img" --append "root=/dev/${disk}3 rootflags=subvol=root console=tty1 console=ttyS0,115200n8 ds=nocloud;s=http://192.168.12.100:29145/installer/cloud-init/" "$kernel" 
