#!/bin/sh

set -e 

sudo dnf install -y kexec-tools
#sudo apt-get install -y kexec-tools

install_params="auto=true priority=critical preseed/url=http://10.0.2.2:29145/installer/debian-preseed.txt"
mirror=http://10.0.2.2:29145
base_dir=debian
debian_version=trixie
arch=arm64
mirrorcfg=mirror/suite=${debian_version}
dir="${mirror}/${base_dir}/dists/${debian_version}/main/installer-${arch}/current/images/netboot/debian-installer/${arch}/"

cd /tmp
curl -Lo "linux" "$dir/linux"
curl -Lo "initrd.gz" "$dir/initrd.gz"

#sudo kexec /boot/vmlinuz-$(uname -r) --initrd=/tmp/initrd.gz --append="${install_params} ${mirrorcfg} --- console=/dev/tty1 console=/dev/ttyAMA0,115200n8 initrd=initrd.gz"
sudo kexec --help
#set -x

#sudo kexec --type=uki --initrd=/tmp/initrd.gz --append="${install_params} ${mirrorcfg} --- console=/dev/tty1 console=/dev/ttyAMA0,115200n8 initrd=initrd.gz" linux

#for i in vmlinux vmlinuz Image uki uImage ; do
  #echo ">>> $i"
  #sudo kexec -l --type=$i --command-line="console=/dev/tty1 console=/dev/ttyAMA0,115200n8 initrd=initrd.gz" linux
#done
sudo kexec -l --type=Image linux
sudo kexec -e
#--append="console=/dev/tty1 console=/dev/ttyAMA0,115200n8 initrd=initrd.gz" linux
#sudo kexec linux --type=vmlinuz --initrd=/tmp/initrd.gz --append="${install_params} ${mirrorcfg} --- console=/dev/tty1 console=/dev/ttyAMA0,115200n8 initrd=initrd.gz"
#sudo kexec linux --type=vmlinux --initrd=/tmp/initrd.gz --append="${install_params} ${mirrorcfg} --- console=/dev/tty1 console=/dev/ttyAMA0,115200n8 initrd=initrd.gz"
#sudo kexec linux --type=Image --initrd=/tmp/initrd.gz --append="${install_params} ${mirrorcfg} --- console=/dev/tty1 console=/dev/ttyAMA0,115200n8 initrd=initrd.gz"
#--append="${install_params} ${mirrorcfg} --- console=/dev/tty1 console=/dev/ttyAMA0,115200n8 initrd=initrd.gz"
