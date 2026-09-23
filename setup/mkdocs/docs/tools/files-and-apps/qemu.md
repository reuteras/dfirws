# QEMU

**Category:** Files and apps

**Homepage:** <https://qemu.weilnetz.de/>

**Vendor:** QEMU Community

**License:** [GPL-2.0](https://wiki.qemu.org/License)

**Source:** Winget

**Profiles:** Full (not included in Basic profile)

**File Extensions:** `.qcow2`, `.vmdk`, `.vdi`, `.img`, `.iso`

**Tags:** emulation

QEMU is a generic and open-source machine emulator and virtualizer. It can be used to run operating systems and applications for different architectures on a host system, making it useful for testing, development, and analysis.

## Tips
qemu-img converts between VMDK, VHDX, QCOW2 and raw so other tools can parse the disk, and 'qemu-img info' shows the format and snapshots. Full system emulation works but is slow inside the sandbox.

## Usage
qemu-img convert -f vmdk -O raw disk.vmdk disk.raw
