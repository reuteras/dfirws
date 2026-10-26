# KAPE

**Category:** IR

**Homepage:** <https://www.kroll.com/en/insights/publications/cyber/kroll-artifact-parser-extractor-kape>

**Vendor:** Kroll

**License:** Commercial

**Source:** Installer

**Profiles:** Full, Basic

**Tags:** forensics, incident-response, acquisition, artifact-extraction, triage

Kroll Artifact Parser and Extractor (KAPE) is an efficient and highly configurable triage program that will target essentially any device or storage location, find forensically useful artifacts, and parse them within a few minutes.

## Tips
KAPE is only included when you place kape.zip in the local folder. Use gkape for the GUI, --module to run parsers on a collection and --mdest for module output. Targets and modules are updated separately from the binary.

## Usage
kape --tsource C: --tdest <destination> --target !SANS_Triage

## Sample Commands
- `kape --help`
