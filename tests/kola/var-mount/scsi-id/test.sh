#!/bin/bash
## kola:
##   # additionalDisks is only supported on QEMU
##   platforms: qemu
##   additionalDisks: ["5G:channel=scsi,wwn=123456789"]
##   description: Verify udev rules /dev/disk/by-id/scsi-* symlinks exist
##     in initramfs.

# See https://bugzilla.redhat.com/show_bug.cgi?id=1990506

set -xeuo pipefail

# shellcheck disable=SC1091
. "$KOLA_EXT_DATA/commonlib.sh"

fstype=$(findmnt -nvr /var -o FSTYPE)
if [ $fstype != xfs ]; then
    fatal "Error: /var fstype is $fstype, expected is xfs"
fi

ostree_conf=$(ls /boot/loader/entries/*.conf)

initramfs=/boot$(grep initrd ${ostree_conf} | sed 's/initrd //g')
tempfile=$(mktemp)
lsinitrd $initramfs > $tempfile
if ! grep -q "61-scsi-sg3_id.rules" $tempfile; then
    fatal "Error: can not find 61-scsi-sg3_id.rules in $initramfs"
fi

if ! grep -q "63-scsi-sg3_symlink.rules" $tempfile; then
    fatal "Error: can not find 63-scsi-sg3_symlink.rules in $initramfs"
fi

rm -f $tempfile
