# apkid

**Category:** OS / Android

**Homepage:** <https://github.com/rednaga/APKiD>

**Vendor:** RedNaga

**License:** [GNU General Public License v3.0](https://github.com/rednaga/APKiD/blob/master/LICENSE.COMMERCIAL)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.apk`, `.dex`

**Tags:** android, packer-detection, malware-analysis

APKiD identifies the compiler, packer, protector and obfuscator used to build an Android APK or DEX file - PEiD for Android.

## Tips
Run apkid before decompiling with jadx or apktool to know which packer or obfuscator you are dealing with. Use -r to scan recursively and -j for JSON output.

## Usage
apkid sample.apk

## Sample Commands
- `apkid sample.apk`
- `apkid -j sample.apk`
- `apkid -r C:\Users\WDAGUtilityAccount\Desktop\readwrite\apks`
