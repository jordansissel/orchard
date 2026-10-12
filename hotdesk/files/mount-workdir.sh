#!/bin/sh

hotdesk_fw() {
	if [ ! -d "/sys/firmware/qemu_fw_cfg" ] ; then
		echo "Missing qemu fw_cfg directory. Is this running in qemu?"
		return 1
	fi

	hotdesk_fw_path="/sys/firmware/qemu_fw_cfg/by_name/opt/com.oakandspark.hotdesk"

	n="$1"
	p="${hotdesk_fw_path}/${n}/raw"
	if [ ! -e "$p" ] ; then
		echo "No qemu fw_cfg for '$p'" >&2
		return 1
	fi
	cat "$p"
}

set -e
	
hostpath="$(hotdesk_fw workdir-path | sed -e 's@^/@@')"
uid="$(hotdesk_fw host-uid)"
gid="$(hotdesk_fw host-gid)"

if [ -z "$uid" ] ; then
	echo "Missing host-uid fw_cfg setting"
	exit 1
fi

[ -d "/mnt/host" ] || mkdir /mnt/host
[ -d "/mnt/upper" ] || mkdir /mnt/upper
[ -d "/mnt/workdir" ] || mkdir /mnt/workdir

[ -d "/mnt/host/$hostpath" ] || mkdir -p "/mnt/host/$hostpath"
[ -d "/mnt/upper/$hostpath" ] || mkdir -p "/mnt/upper/$hostpath"
[ -d "/mnt/workdir/$hostpath" ] || mkdir -p "/mnt/workdir/$hostpath"

dev_uid="$(id -u dev)"
dev_gid="$(id -g dev)"
mount -t 9p -o ro,cache=none workdir "/mnt/host/$hostpath"

[ ! -d "/work" ] && mkdir /work
chown $dev_uid:$dev_gid /work

# Ensure the directory itself is owned by dev after mounting.
# A weird quirk of overlay mounts?
chown $dev_uid:$dev_gid /mnt/upper/$hostpath

options="rw,lowerdir=/mnt/host/$hostpath,upperdir=/mnt/upper/$hostpath,workdir=/mnt/workdir/$hostpath"
mount -t overlay -o "$options" overlay /work
