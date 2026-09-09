#!/bin/sh

set -e 

if [ -z "$1" ] ; then
	echo "Usage: $0 <nexus host>"
	exit 1
fi

#sudo dnf install -y kexec-tools
#sudo apt-get install -y kexec-tools

dlhost="$(getent hosts "$1" | head -n1 | sed -e 's/ .*$//')"
#dlhost="10.0.2.2"

arch="$(uname -m)"
mirror="http://${dlhost}:29145/fedora/linux/releases/44"
repo="${mirror}/Everything/${arch}/os"

cd /tmp

curl -Lo vmlinuz.part "${repo}/images/pxeboot/vmlinuz" && mv vmlinuz.part vmlinuz
curl -Lo initrd.img "${repo}/images/pxeboot/initrd.img" && mv initrd.img.part initrd.img

echo "Let's goooooo"
set -x

sudo kexec \
	--initrd initrd.img \
	--append "console=tty1 console=ttyS0,115200n8 inst.repo=${repo} inst.ks=http://${dlhost}:29145/installer/fedora.ks" \
	vmlinuz

	#--append "console=tty1 console=ttyS0,115200n8 inst.repo=${repo} inst.ks=http://${dlhost}:29145/installer/fedora.ks" \
