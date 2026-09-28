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

url=http://192.168.12.86:29145/fedora/linux/releases/44/Cloud/x86_64/images/Fedora-Cloud-Base-AmazonEC2-44-1.7.x86_64.raw.xz
curl "$url" | xz -dc > "/dev/${disk}"

# fedora cloud images use partition 3 for the main filessystem
mkdir /mnt

# Fedora 44's Cloud image uses gpt and gpt requires(?) that the "gpt alternate header" live at the end of the physical disk.
# Because the Cloud image is only a few hundred megabytes, this means the
# image's alt header is at the end of the disk image, but not the physical
# disk.
# We can insist parted correct this for us (-sf flag) while also extending the partition to the end of the disk.
#
# In the absence of this specific fix, the kernel will panic when it tries to mount this disk as the root filesystem.
parted -sf /dev/${disk} resizepart 3 100%

partition=/dev/${disk}3
	
if [ -z "${disk##nvme*}" ] ; then
	partition=/dev/${disk}p3
fi

mount -o ro $partition /mnt
kernel="$(ls -t /mnt/boot/vmlinuz* | sed -ne 1p)"
version="${kernel#*vmlinuz-}"

kexec --initrd "/mnt/boot/initramfs-$version.img" --append "root=${partition} rootflags=subvol=root console=tty1 console=ttyS0,115200n8 ds=nocloud;s=http://192.168.12.86:29145/installer/cloud-init/" "$kernel" 
