#!/bin/sh

set -e 

sudo dnf install -y kexec-tools
#sudo apt-get install -y kexec-tools

arch="$(uname -m)"
mirror="http://10.0.2.2:29145/fedora/linux/releases/44"
repo="${mirror}/Everything/${arch}/os"

cd /tmp
curl -LO "${repo}/images/pxeboot/vmlinuz"
curl -LO "${repo}/images/pxeboot/initrd.img"

echo "Let's goooooo"
set -x

sudo kexec \
	--initrd initrd.img \
	--append "console=tty1 console=ttyS0,115200n8 inst.repo=${repo} inst.ks=http://10.0.2.2:29145/installer/fedora.ks" \
	vmlinuz
