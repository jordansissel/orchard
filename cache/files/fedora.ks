graphical

# XXX: How to know what the drive names are?
# XXX: use a %pre script?
clearpart --all --drives=vda|sda|nvme0n1
lang en_US.UTF-8
keyboard --vckeymap us --xlayouts us
timezone America/Los_Angeles

autopart --type=plain
bootloader --location mbr --append="console=tty1 console=ttyS0,115200n8"

rootpw dev

firewall --enabled --ssh

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
augeas-libs
libvirt-libs
%end

%post
# Installation assets are hosted by {{ .Host }}

curl -o "/usr/local/bin/mgmt" "http://{{ .Host }}:29145/mgmt/current"
chmod 755 /usr/local/bin/mgmt

curl -o /etc/systemd/system/mgmt.service "http://{{ .Host }}:29145/installer/mgmt.service"
systemctl enable mgmt
%end
