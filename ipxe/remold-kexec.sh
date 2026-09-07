#!/bin/sh

set -e 

sudo dnf install -y kexec-tools

install_params="auto=true priority=critical preseed/url=http://10.0.2.2:29145/installer/debian-preseed.txt"
mirror=http://10.0.2.2:29145
base_dir=debian
debian_version=trixie
arch=amd64
mirrorcfg=mirror/suite=${debian_version}
dir="${mirror}/${base_dir}/dists/${debian_version}/main/installer-${arch}/current/images/netboot/debian-installer/amd64/"

cd /tmp
curl -LO "$dir/linux"
curl -LO "$dir/initrd.gz"

sudo kexec /tmp/linux --initrd=/tmp/initrd.gz --append="${install_params} ${mirrorcfg} -- quiet initrd=initrd.gz"
