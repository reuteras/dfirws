# Adding New Tools to DFIRWS

This guide explains how to add new tools to the DFIRWS tool collection using the interactive `add-tool.ps1` script.

## Quick Start

```powershell
# Run the interactive wizard
.\resources\download\add-tool.ps1

# Or specify some parameters to skip prompts
.\resources\download\add-tool.ps1 -Name "mytool" -Category "forensics"
```

## Overview

The `add-tool.ps1` script provides an interactive wizard that:
- **Validates input** - Ensures all required fields are provided with correct format
- **Checks GitHub repos** - Verifies repository exists and shows description
- **Validates URLs** - Ensures URLs are properly formatted
- **Generates YAML** - Creates properly formatted YAML with correct indentation
- **Validates syntax** - Parses the YAML to catch errors before you commit
- **Updates category files** - Automatically appends to the correct category file

## Interactive Wizard Flow

The wizard will guide you through the following steps:

### 1. Tool Name

```text
Tool name: mytool
```
- Only letters, numbers, hyphens, underscores, and dots allowed
- Will be used as the tool identifier

### 2. Description

```text
Description: A brief description of what this tool does
```
- Brief, one-line description
- Will be displayed in tool listings

### 3. Category

```text
Category: forensics
```
Available categories:
- `forensics` - General forensics tools
- `malware-analysis` - Malware analysis and sandboxing
- `reverse-engineering` - Reverse engineering and disassembly
- `memory-forensics` - Memory analysis tools
- `data-analysis` - Data parsing and analysis
- `windows-forensics` - Windows-specific forensics
- `disk-forensics` - Disk and filesystem analysis
- `document-analysis` - Document and file format analysis
- `email-forensics` - Email analysis tools
- `threat-intelligence` - Threat intel and IOC tools
- `active-directory` - Active Directory analysis
- `network-analysis` - Network traffic analysis
- `utilities` - General utilities

### 4. Source Type

```text
Source (github/http): github
```
- `github` - Download from GitHub releases
- `http` - Download from HTTP/HTTPS URL

### 5. Source-Specific Fields

#### For GitHub sources

```text
GitHub repository (owner/repo): puffyCid/artemis
  ✓ Found: puffyCid/artemis - Fast forensic collection tool

Asset filename pattern (regular expression): x86_64-pc-windows-msvc\.zip$
```

- Repository will be validated via GitHub API
- Match pattern is a regular expression to identify the correct release asset

#### For HTTP sources

**Static URL:**

```text
Use dynamic URL detection? (y/n): n
Direct download URL: https://example.com/tool.zip
```

**Dynamic URL (scraping):**

```text
Use dynamic URL detection? (y/n): y
URL pattern (page to scrape): https://example.com/downloads
Download link regular expression pattern: tool-.*\.zip
```

### 6. Version Pinning

```text
Pin to specific version? (y/n): n
```

If yes:

```text
Version number: 1.2.3
```

### 7. SHA256 Checksum

```text
Add SHA256 checksum? (y/n): y
SHA256 checksum (or leave empty to calculate later): abc123...
```
- Recommended for security and integrity validation
- Can be added later by downloading the file and calculating the hash

### 8. Update Policy

```text
Update policy (manual/auto/notify): notify
```
- `notify` (default) - Show update available, require approval
- `manual` - Never check for updates
- `auto` - Automatically update to latest version

### 9. File Type

```text
File type (zip/exe/msi/jar/war): zip
```
- `zip` - ZIP archive
- `exe` - Windows executable
- `msi` - Windows installer
- `jar` - Java archive
- `war` - Web application archive

### 10. Install Method

```text
Install method (extract/run/copy): extract
```

#### Extract method

```text
Extract to path: ${TOOLS}/mytool
```

Extracts archive to specified directory.

#### Run method

```text
Run arguments (e.g., /S /D=path): /S /D=${TOOLS}\mytool
```

Executes installer with arguments.

#### Copy method

```text
Copy to path: ${TOOLS}/mytool.exe
```
Copies file to destination.

### 11. Post-Install Steps

```text
Add post-install steps? (y/n): y
```

Available step types:

**Rename:**

```text
Post-install step type (or 'done' to finish): rename
  Pattern to match: mytool-*
  New name: mytool
```

**Move:**

```text
Post-install step type: move
  Source path: ${TOOLS}/mytool/bin
  Destination path: ${TOOLS}/mytool-bin
```

**Delete:**

```text
Post-install step type: delete
  Path to delete: ${TOOLS}/mytool/temp
```

**Symlink:**

```text
Post-install step type: symlink
  Source path: ${TOOLS}/mytool/mytool.exe
  Link path: ${TOOLS}/bin/mytool.exe
```

### 12. Priority

```text
Priority (critical/high/medium/low): medium
```
- `critical` - Essential tools, installed first
- `high` - Important tools
- `medium` - Standard priority
- `low` - Optional/specialty tools

### 13. Enabled

```text
Enable tool? (true/false): true
```
- `true` - Tool will be installed
- `false` - Tool definition exists but won't be installed

## Example Complete Session

```powershell
PS> .\resources\download\add-tool.ps1

========================================
   DFIRWS Tool Addition Wizard
========================================

Tool name: artemis
Description: Fast forensic collection tool
Category: forensics
Source (github/http) [github]: github
GitHub repository (owner/repo): puffyCid/artemis
  ✓ Found: puffyCid/artemis - Fast forensic collection tool written in Rust
Asset filename pattern (regex): x86_64-pc-windows-msvc\.zip$
Pin to specific version? (y/n) [n]: n
Add SHA256 checksum? (y/n) [n]: y
SHA256 checksum (or leave empty to calculate later):
Update policy (manual/auto/notify) [notify]: notify
File type (zip/exe/msi/jar/war) [zip]: zip
Install method (extract/run/copy) [extract]: extract
Extract to path [${TOOLS}/artemis]: ${TOOLS}/artemis
Add post-install steps? (y/n) [n]: y
Post-install step type (or 'done' to finish): rename
  Pattern to match: artemis-*
  New name: artemis
Post-install step type (or 'done' to finish): done
Priority (critical/high/medium/low) [medium]: high
Enable tool? (true/false) [true]: true

========================================
   Tool Summary
========================================

category: forensics
description: Fast forensic collection tool
enabled: true
extract_to: ${TOOLS}/artemis
file_type: zip
install_method: extract
match: x86_64-pc-windows-msvc\.zip$
name: artemis
post_install:
  - type: rename
    pattern: artemis-*
    target: artemis
priority: high
repo: puffyCid/artemis
source: github
update_policy: notify

Add this tool? (y/n) [y]: y

Generated YAML:
----------------------------------------
- name: artemis
  description: "Fast forensic collection tool"
  source: github
  repo: puffyCid/artemis
  match: "x86_64-pc-windows-msvc\.zip$"
  update_policy: "notify"
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/artemis"
  post_install:
    - type: rename
      pattern: "artemis-*"
      target: "artemis"
  enabled: true
  priority: high
----------------------------------------

✓ Tool added to forensics.yaml
Validating YAML syntax...
✓ YAML validation passed - 8 tools in file

✓ Tool 'artemis' successfully added!

Next steps:
  1. Review the YAML in: .\resources\tools\forensics.yaml
  2. Test installation: .\install-tools.ps1 -Category forensics -DryRun
  3. Install the tool: .\install-tools.ps1 -Category forensics
```

## Generated YAML Structure

The script generates YAML in the following format:

```yaml
- name: tool-name
  description: "Tool description"
  source: github
  repo: owner/repository
  match: "asset-pattern\.zip$"
  version: "1.2.3"                    # Optional: pin version
  sha256: "abc123..."                 # Optional: checksum
  update_policy: "notify"             # Optional: manual/auto/notify
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/tool-name"
  post_install:                       # Optional
    - type: rename
      pattern: "tool-*"
      target: "tool"
  enabled: true
  priority: medium
```

## Validation Features

The script performs the following validations:

### Input Validation
- **Tool name**: Alphanumeric, hyphens, underscores, dots only
- **URLs**: Must start with http:// or https://
- **GitHub repositories**: Validates format (owner/repository) and checks if repository exists
- **Categories**: Must match predefined list
- **Enums**: File type, install method, priority, etc.

### YAML Validation
After adding the tool, the script:
1. Parses the complete category YAML file
2. Validates syntax using Import-ToolDefinitions
3. Reports number of tools successfully parsed
4. Shows warnings for potential issues

### Common Issues Prevented
- Invalid YAML indentation
- Missing required fields
- Malformed GitHub repository names
- Invalid URLs
- Incorrect file types or install methods
- Duplicate tool entries (manual check recommended)

## Advanced Usage

### Non-Interactive Mode
You can provide parameters to skip some prompts:

```powershell
.\resources\download\add-tool.ps1 `
    -Name "mytool" `
    -Category "forensics"
```

The script will still prompt for fields not provided as parameters.

### Editing Existing Tools
To modify an existing tool:
1. Manually edit the YAML file in `resources/tools/`
2. Or delete the tool entry and re-run the wizard

### Adding SHA256 Later
If you skip SHA256 during initial addition:

```powershell
# Download the tool first
.\install-tools.ps1 -Category forensics

# Calculate SHA256
Get-FileHash .\downloads\mytool.zip -Algorithm SHA256

# Manually add to YAML:
#   sha256: "calculated-hash-here"
```

## Troubleshooting

### GitHub Repository Not Found

```text
✗ Repository not found
```

**Solution**: Check the repository name format (owner/repository) and ensure it's public

### YAML Validation Failed

```text
✗ YAML validation failed: ...
```
**Solution**: Review the generated YAML for syntax errors, check indentation

### Tool Already Exists
The script doesn't check for duplicates. Before adding:
```powershell
# Search existing tools
Get-ChildItem .\resources\tools\*.yaml | Select-String "name: mytool"
```

## Best Practices

1. **Test installations**: Always test with `-DryRun` first
```powershell
.\install-tools.ps1 -Category forensics -DryRun
```

2. **Add SHA256 checksums**: Enhances security and enables integrity validation
```powershell
.\install-tools.ps1 -ValidateChecksums
```

3. **Use version pinning**: For production environments, pin versions
```yaml
version: "1.2.3"
update_policy: "manual"
```

4. **Document in description**: Include key features or use cases
```yaml
description: "Memory forensics - Volatility 3 with Windows 10/11 support"
```

5. **Set appropriate priority**:
   - `critical`: Core tools (always needed)
   - `high`: Commonly used tools
   - `medium`: Standard tools
   - `low`: Specialty/niche tools

## See Also

- [Modular Architecture Guide](MODULAR-ARCHITECTURE.md)
- [Version Management](VERSION-MANAGEMENT.md)
- [Migration Guide](MIGRATION-GUIDE.md)
