text

bootloader --location mbr --append="console=tty1 console=ttyS0,115200"
# XXX: How to know what the drive names are?
# XXX: use a %pre script?
#clearpart --all --drives=vda
clearpart --all --drives=nvme0n1
lang en_US.UTF-8
autopart --type=plain

rootpw dev

#firewall --enabled --ssh

#user --name dev --password dev  --plaintext 

reboot

%packages
@core

# for mgmt
PackageKit

# for mdns lookups
avahi
nss-mdns

# also for mgmt, even though I don't use these libs.
augeas
libvirt
%end

%post

echo "POST. Readying mgmt."
set -x
curl -o /usr/local/bin/mgmt "http://192.168.12.100:29145/mgmt/1.1.0/mgmt-linux-amd64-1.1.0"
chmod 755 /usr/local/bin/mgmt
/usr/local/bin/mgmt run empty --converged-exit --seeds http://mgmt.local:2380
%end
