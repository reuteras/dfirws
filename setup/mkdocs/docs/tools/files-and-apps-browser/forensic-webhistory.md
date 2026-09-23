# forensic-webhistory

**Category:** Files and apps / Browser

**Homepage:** <https://github.com/acquiredsecurity/forensic-webhistory>

**Vendor:** acquiredsecurity

**License:** [MIT License](https://github.com/acquiredsecurity/forensic-webhistory/blob/main/README.md)

**Source:** GitHub Release

**Profiles:** Full, Basic

**File Extensions:** `.sqlite`, `.dat`

**Tags:** browser-forensics, forensics, data-extraction

forensic-webhistory is a Rust command line tool that extracts browser artifacts (history, downloads, keyword searches, cookies, autofill, bookmarks, login metadata and extensions) from Chromium based browsers, Firefox, Safari and IE/Edge Legacy ESE databases, and can carve deleted history from freelist pages and WAL files.

## Tips
Point the scan subcommand at a KAPE or Velociraptor triage folder and it finds every browser profile by itself; output is one CSV per browser, artifact and profile. Use extract for a single History or places.sqlite file and carve to recover deleted rows. Run without arguments for an interactive menu.

## Usage
forensic-webhistory scan -d <triage folder> -o <output folder>

## Sample Commands
- `forensic-webhistory scan -d C:\Users\WDAGUtilityAccount\Desktop\readwrite\triage -o C:\Users\WDAGUtilityAccount\Desktop\readwrite\webhistory`
- `forensic-webhistory extract -i History -o history.csv --browser chrome`
- `forensic-webhistory carve -i History -o carved.csv`
