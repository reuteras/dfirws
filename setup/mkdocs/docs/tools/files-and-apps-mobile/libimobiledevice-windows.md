# libimobiledevice-windows

**Category:** Files and apps / Mobile

**Homepage:** <https://github.com/iFred09/libimobiledevice-windows>

**Vendor:** iFred09


**Source:** Git

**Profiles:** Full, Basic

**Tags:** mobile-forensics, forensics

A Windows port of libimobiledevice, a cross-platform library to communicate with iOS devices. It includes tools for extracting data from iOS devices, such as lockdown, idevicebackup2, and more.

## Tips
Needed by ULogViewer to read logs from an iOS device. The binaries are under C:\git\libimobiledevice-windows; the sandbox cannot see USB devices, so in practice you work with backups and logs copied into the readwrite folder.

## Usage
idevice_id -l
