# DFIRWS Tool Definitions

This directory contains YAML definitions for all tools that can be installed in DFIRWS.

## Quick Start

### Install All Tools

```powershell
.\resources\download\install-tools.ps1 -All -Parallel
```

### Install By Category

```powershell
# Forensics tools only
.\resources\download\install-tools.ps1 -Category forensics -Parallel

# Malware analysis tools
.\resources\download\install-tools.ps1 -Category malware-analysis -Parallel
```

### Add a New Tool

1. Edit the appropriate category file (e.g., `forensics.yaml`)
2. Add your tool definition following the schema below
3. Test with: `.\resources\download\install-tools.ps1 -Category forensics -DryRun`
4. Install: `.\resources\download\install-tools.ps1 -Category forensics`

## File Organization

```text
resources/tools/
├── README.md                  # This file
├── forensics.yaml             # Digital forensics tools
├── malware-analysis.yaml      # Malware analysis and RE tools
├── network-analysis.yaml      # Network traffic analysis tools
└── utilities.yaml             # General utilities
```

## YAML Schema

### Minimal Tool Definition

```yaml
- name: toolname
  source: github
  repo: owner/repository
  match: "pattern.*\\.zip$"
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/toolname"
  enabled: true
  priority: high
```

### Complete Tool Definition

```yaml
- name: toolname                      # Unique identifier (required)
  description: Tool description       # Human-readable description
  source: github                      # "github" or "http" (required)
  repo: owner/repository              # GitHub repo (required for github source)
  url: https://example.com/tool.zip   # Direct URL (required for http source)
  url_pattern: https://example.com/   # Base URL for scraping (alternative to url)
  match: "pattern.*\\.zip$"           # Regex pattern to match release (required)
  file_type: zip                      # zip, exe, msi, etc. (required)
  install_method: extract             # extract, copy, installer (required)
  extract_to: "${TOOLS}/toolname"     # Target directory (for extract)
  copy_to: "${TOOLS}/bin/tool.exe"    # Target path (for copy)
  installer_args: "/quiet /norestart" # Installer arguments (for installer)
  post_install:                       # Post-installation steps (optional)
    - type: rename
      pattern: "toolname-*"
      target: "toolname"
    - type: copy
      source: "${TOOLS}/src/file.exe"
      target: "${TOOLS}/bin/"
    - type: remove
      target: "${TOOLS}/temp"
    - type: add_to_path
      path: "${TOOLS}/toolname/bin"
  enabled: true                       # true or false (required)
  priority: high                      # critical, high, medium, low
  notes: "Additional information"     # Optional notes
```

## Field Reference

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Unique tool identifier (lowercase, no spaces) |
| `source` | string | Download source: `github` or `http` |
| `file_type` | string | File type: `zip`, `exe`, `msi`, etc. |
| `install_method` | string | Installation method: `extract`, `copy`, `installer` |
| `enabled` | boolean | Whether tool is enabled for installation |

### Source-Specific Fields

#### GitHub Source

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `repo` | string | Yes | Repository in format `owner/repository` |
| `match` | string | Yes | Regex pattern to match release asset name |

#### HTTP Source

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `url` | string | No* | Direct download URL |
| `url_pattern` | string | No* | Base URL to scrape for download link |
| `match` | string | Yes** | Regex pattern to find download link |

*Either `url` OR `url_pattern` required
**Required when using `url_pattern`

### Install Method Fields

#### Extract Method

```yaml
install_method: extract
extract_to: "${TOOLS}/targetdir"  # Required: Target directory
```

#### Copy Method

```yaml
install_method: copy
copy_to: "${TOOLS}/bin/tool.exe"  # Required: Full target path with filename
```

#### Installer Method

```yaml
install_method: installer
installer_args: "/quiet"          # Optional: Command-line arguments
```

### Post-Install Steps

Post-install steps are executed in order after installation:

#### Rename

```yaml
- type: rename
  pattern: "toolname-*"    # Glob pattern to match
  target: "toolname"       # New name
```

#### Copy

```yaml
- type: copy
  source: "${TOOLS}/src/file.exe"
  target: "${TOOLS}/bin/"
```

#### Remove

```yaml
- type: remove
  target: "${TOOLS}/temp"
```

#### Add to PATH

```yaml
- type: add_to_path
  path: "${TOOLS}/toolname/bin"
```

Note: `add_to_path` is noted but not automatically applied. It should be handled by sandbox startup scripts.

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | Human-readable tool description |
| `priority` | string | `critical`, `high`, `medium`, `low` |
| `notes` | string | Additional notes or warnings |

## Priority Levels

| Priority | Usage | Example Tools |
|----------|-------|---------------|
| `critical` | Essential dependencies | 7-Zip, Python, PowerShell |
| `high` | Commonly used tools | Volatility, Wireshark, IDA |
| `medium` | Useful but not critical | Additional parsers, utilities |
| `low` | Specialized or rarely used | Experimental tools |

## Environment Variables

Available variables in paths:

| Variable | Expands To | Usage |
|----------|------------|-------|
| `${TOOLS}` | `.\mount\Tools` | Tool installation directory |
| `${SETUP_PATH}` | `.\downloads` | Downloaded files directory |

## Examples

### Example 1: Simple GitHub Release (ZIP)

```yaml
- name: ripgrep
  description: Fast text search tool
  source: github
  repo: BurntSushi/ripgrep
  match: "x86_64-pc-windows-msvc\\.zip$"
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/ripgrep"
  post_install:
    - type: rename
      pattern: "ripgrep-*"
      target: "ripgrep"
  enabled: true
  priority: high
```

### Example 2: Single Executable

```yaml
- name: fx
  description: Command-line JSON viewer
  source: github
  repo: antonmedv/fx
  match: "fx_windows_amd64\\.exe"
  file_type: exe
  install_method: copy
  copy_to: "${TOOLS}/bin/fx.exe"
  enabled: true
  priority: medium
```

### Example 3: MSI Installer

```yaml
- name: autopsy
  description: Digital forensics platform
  source: github
  repo: sleuthkit/autopsy
  match: "autopsy-.*-64bit\\.msi"
  file_type: msi
  install_method: installer
  installer_args: "/qn /norestart"
  enabled: true
  priority: high
  notes: Requires Java Runtime Environment
```

### Example 4: HTTP Download with Scraping

```yaml
- name: exiftool
  description: Read and write file metadata
  source: http
  url_pattern: "https://exiftool.org/"
  match: "exiftool-[^zip]+_64\\.zip"
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/exiftool"
  post_install:
    - type: rename
      pattern: "exiftool-*"
      target: "exiftool"
    - type: copy
      source: "${TOOLS}/exiftool/exiftool(-k).exe"
      target: "${TOOLS}/exiftool/exiftool.exe"
    - type: remove
      target: "${TOOLS}/exiftool/exiftool(-k).exe"
  enabled: true
  priority: high
```

### Example 5: Complex Post-Install

```yaml
- name: aleapp
  description: Android Logs Events And Protobuf Parser
  source: github
  repo: abrignoni/aLEAPP
  match: "aleapp-.*Windows\\.zip"
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/aleapp"
  post_install:
    - type: copy
      source: "${TOOLS}/aleapp/aleapp.exe"
      target: "${TOOLS}/bin/"
    - type: remove
      target: "${TOOLS}/aleapp"
  enabled: true
  priority: high
```

## Testing Tools

### Dry Run

Test tool definition without downloading:

```powershell
.\resources\download\install-tools.ps1 -Category forensics -DryRun
```

### Install Single Category

Install all tools in a category:

```powershell
.\resources\download\install-tools.ps1 -Category utilities
```

### Install by Priority

Install only high-priority tools:

```powershell
.\resources\download\install-tools.ps1 -Priority high
```

## Common Patterns

### Pattern: GitHub Release with Version Directory

Many tools extract to a versioned directory:

```yaml
post_install:
  - type: rename
    pattern: "toolname-*"
    target: "toolname"
```

### Pattern: Extract and Copy Binary

Extract, then copy main binary to bin:

```yaml
install_method: extract
extract_to: "${TOOLS}/toolname"
post_install:
  - type: copy
    source: "${TOOLS}/toolname/tool.exe"
    target: "${TOOLS}/bin/"
```

### Pattern: Extract, Copy, Cleanup

Extract, copy what you need, remove temporary files:

```yaml
install_method: extract
extract_to: "${TOOLS}/temp"
post_install:
  - type: copy
    source: "${TOOLS}/temp/tool.exe"
    target: "${TOOLS}/bin/"
  - type: remove
    target: "${TOOLS}/temp"
```

## Regex Patterns

Common regex patterns for matching releases:

```yaml
# Match version number
match: "tool-v?\\d+\\.\\d+\\.\\d+.*\\.zip$"

# Match Windows 64-bit
match: "win.*64.*\\.zip$"
match: "windows.*x64.*\\.zip$"
match: "x86_64.*windows.*\\.zip$"

# Match specific file extension
match: "tool.*\\.exe$"
match: ".*\\.msi$"

# Exclude patterns
match: "tool.*\\.zip$"  # Then filter in code if needed
```

## Troubleshooting

### Tool Not Found

Check if regex pattern matches actual release names:

```powershell
# View actual release names
$releases = (curl.exe --silent -L "https://api.github.com/repos/owner/repo/releases/latest" | ConvertFrom-Json).assets.browser_download_url
$releases
```

### Tool Fails to Install

Check error log:

```powershell
Get-Content .\log\tool-errors.json | ConvertFrom-Json | Format-List
```

### YAML Syntax Error

Validate YAML:

```powershell
# PowerShell doesn't have built-in YAML validator
# Use online validator: https://www.yamllint.com/
# Or install: Install-Module -Name powershell-yaml
```

## Best Practices

1. **Use descriptive names**: Clear, unique identifiers
2. **Test before committing**: Always test with -DryRun first
3. **Add descriptions**: Help others understand the tool
4. **Set appropriate priority**: Helps with installation order
5. **Document special requirements**: Use `notes` field
6. **Keep it simple**: Avoid complex post-install if possible
7. **Follow existing patterns**: Check similar tools for examples

## Contributing

### Adding a New Tool

1. Choose the correct category file
2. Add tool definition following schema
3. Test with dry run
4. Test actual installation
5. Verify in sandbox
6. Submit pull request

### Creating a New Category

1. Create new YAML file: `resources/tools/category-name.yaml`
2. Add schema header:
```yaml
schema_version: "1.0"
category: category-name
description: Category description

tools:
  # Tool definitions here
```
3. Add tools
4. Update documentation

## Resources

- [MODULAR-ARCHITECTURE.md](../../docs/MODULAR-ARCHITECTURE.md) - Architecture overview
- [MIGRATION-GUIDE.md](../../docs/MIGRATION-GUIDE.md) - Migration from legacy system
- [REFACTORING-SUMMARY.md](../../docs/REFACTORING-SUMMARY.md) - Refactoring details

## Questions?

- Check existing tool definitions for examples
- Review the migration guide for complex cases
- Open a GitHub issue for help
