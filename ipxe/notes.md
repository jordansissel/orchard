
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

Default script automatically loaded: /boot/efi/EFI/autoexec.ipxe
```
