# lessmsi

**Category:** Files and apps

**Homepage:** <https://lessmsi.activescott.com>

**Vendor:** activescott

**License:** MIT

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.msi`

**Tags:** windows

lessmsi is a tool to view and extract the contents of a Windows Installer (.msi) file.

## Tips
Use lessmsi-gui to browse tables and streams or 'lessmsi l -t Property' to list properties. For malicious MSIs also run msidump, which flags suspicious custom actions and runs YARA on embedded files.

## Usage
lessmsi x <file.msi> <output dir>\
