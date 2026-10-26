# hashcat

**Category:** Utilities / Cryptography

**Homepage:** <https://hashcat.net/hashcat/>

**Vendor:** hashcat

**License:** MIT License

**Source:** HTTP

**Profiles:** Full (not included in Basic profile)

**Tags:** password-cracking, hashing

hashcat is a password recovery tool.

## Tips
After installation, the shortcut is replaced with the installed application. To crack on CPU install the bundled Intel OpenCL runtime (downloads\intel_driver.exe) once, then add -D 1 to select the CPU device. hashcat looks for its OpenCL kernel folder relative to the current directory, so if you see './OpenCL/: No such file or directory' run it from its install directory (cd "${env:ProgramFiles}\hashcat") - the desktop shortcut already does this.

## Usage
hashcat supports GPU- and CPU-accelerated password recovery. For CPU: cd "${env:ProgramFiles}\hashcat"; .\hashcat.exe -m 0 -a 0 -D 1 hashes.txt wordlist.txt. Use hashcat -I to list detected OpenCL devices and -D 1 to restrict to the CPU.

## Sample Commands
- `hashcat --help`
- `hashcat -I`
- `hashcat -b -D 1`

## Sample Files
- N/A
