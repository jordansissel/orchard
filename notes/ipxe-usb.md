
make bin-x86_64-efi/ipxe-efi

# Generate autoexec.ipxe
#...

# Generate a tiny usb disk image including our basic autoexec.ipxe
util/genfsimg -o bin-x86_64-efi/ipxe.usb -s ~/projects/orchard/autoexec.ipxe bin-x86_64-efi/ipxe.efi

# Test it with qemu
qemu-kvm -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,readonly=on,format=raw -nographic -hdd bin-x86_64-efi/ipxe.usb
