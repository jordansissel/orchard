# To Research

* how to control boot process (pxe? efi?)
* ipxe, ways to launch, features...
* dracut: linux kernel+initrd for netbootable basics.

## Dracut

* dracut pre-mount can be interrupted to drop to emergency_shell
* dracut-mount loads 

* `$hookdir` /lib/dracut/hooks
* `$NEWFS` /sysfs

## Use iPXE on next boot

```
sudo cp /usr/share/ipxe/ipxe-x86_64.efi /boot/efi/EFI

// Finding disk for the EFI path:
check stat /boot/efi, device `major,minor`
read /proc/self/mountinfo 
	* 3rd column is `major:minor`
	* 5th column is /dev/whatever
?

// lsblk to find the disk device that has a partition(?) mounting /boot/efi
lsblk --json | jq '.blockdevices[] | select (.children and (.children[].mountpoints | contains(["/boot/efi"]))) | .name'

# For an efi loader on /dev/vda2, you need to specify disk and partition separately
# -d /dev/vda -p 2
sudo efibootmgr -c -l "\\EFI\\ipxe-x86_64.efi" -L ipxe -d /dev/vda -p 2

sudo efibootmgr -n $(sudo efibootmgr  | sed -Ene '/ipxe-x86_64.efi/s/^Boot([0-9A-Fa-f]+).*/\1/p')

```

## Create autoexec.ipxe

iPXE automatically loads this from the EFI partition, so we don't need to customize and rebuild the iPXE binaries.

iPXE kernel/initrd are relative to the script itself, but does this also work with autoexec.ipxe?

```
kernel http://....
initrd http://....

# If desired, add other files to the initramfs on the fly
initrd http://

## Generating kernel+initrd

* Exclude modules that aren't needed
* Use `--install` to include `curl` binary and dependencies
* Use `--include` to include files directly.
* Module hooks are in /lib/dracut/hooks/<module>/
		* such as emergency, mount, etc.

```
dracut -N \
	-o "iscsi nfs nss-softokn fips fips-crypto-policies pcmcia ppcmac" \
  --install "curl" \
  --include /tmp/hello /hello \
	--include mounthook.sh /lib/dracut/hooks/mount/ok.sh \
  /tmp/initrd $(uname -r)
```

Minimal-ish dracut?

About 73mb compared to dracut's default of 200-250mb initrd size. Works in qemu.

```
dracut -N -m "base systemd systemd-network-management warpclock systemd-initrd systemd-journald systemd-ldconfig systemd-modules-load systemd-networkd systemd-tmpfiles systemd-udevd network-manager network systemd-sysusers dbus-broker systemd-emergency dracut-systemd" --install "curl" --include /tmp/hello /hello --include /tmp/lol.sh /lib/dracut/hooks/emergency/ok.sh /tmp/initrd $(uname -r)
```
