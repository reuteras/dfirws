# VirusTotal CLI

**Category:** Signatures and information / Online tools

**Homepage:** <https://github.com/VirusTotal/vt-cli>

**Vendor:** VirusTotal

**License:** [Apache-2.0](https://github.com/VirusTotal/vt-cli/blob/HEAD/LICENSE)

**Source:** Winget

**Profiles:** Full (not included in Basic profile)

**Tags:** malware-analysis, threat-intelligence, ioc-scanner

VirusTotal CLI is a command-line tool for interacting with VirusTotal, allowing you to analyze files and URLs for malware and other threats.

## Tips
Run 'vt init' or set VTCLI_APIKEY first and use the network sandbox. Look up by hash with 'vt file <hash>' to avoid uploading, and remember that uploads share the sample with the VirusTotal community.

## Usage
vt file <sha256 or file path>

## Sample Commands
- `vt file sample.exe`
- `vt url http://example.com`
- `vt ip 8.8.8.8`
