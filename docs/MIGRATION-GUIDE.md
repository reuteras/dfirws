# Migration Guide: Legacy to Modular Architecture

## Overview

This guide explains how to migrate from the legacy tool installation system to the new modular architecture.

## Key Differences

### Legacy System (release.ps1, http.ps1)

- 945 lines in release.ps1 handling 148 tools
- 515 lines in http.ps1 handling 75 tools
- Hardcoded download/install logic
- Sequential processing only
- Limited error recovery
- Difficult to add new tools

### New System (tool-handler.ps1, YAML definitions)

- ~100 lines of orchestration code
- Tool definitions in YAML files
- Generic, reusable handlers
- Parallel processing support
- State management and resume
- Add tools by editing YAML

## Migration Steps

### For End Users

**No changes required!** The legacy system continues to work. To use the new system:

```powershell
# Instead of:
.\downloadFiles.ps1 -Release

# Use:
.\resources\download\install-tools.ps1 -All -Parallel
```

### For Contributors/Maintainers

#### Step 1: Identify Tools to Migrate

Check which tools are in legacy scripts:

```bash
# Count GitHub releases
grep -c "Get-GitHubRelease" resources/download/release.ps1

# Count HTTP downloads
grep -c "Get-FileFromUri" resources/download/http.ps1
```

#### Step 2: Convert to YAML

**Legacy format (in release.ps1):**

```powershell
# artemis
$status = Get-GitHubRelease -repo "puffyCid/artemis" -path "${SETUP_PATH}\artemis.zip" -match "x86_64-pc-windows-msvc.zip$" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\artemis.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\artemis") {
        Remove-Item "${TOOLS}\artemis" -Recurse -Force
    }
    Move-Item ${TOOLS}\artemis-* "${TOOLS}\artemis"
}
```

**New format (in forensics.yaml):**

```yaml
- name: artemis
  description: Fast forensic collection tool written in Rust
  source: github
  repo: puffyCid/artemis
  match: "x86_64-pc-windows-msvc\\.zip$"
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/artemis"
  post_install:
    - type: rename
      pattern: "artemis-*"
      target: "artemis"
  enabled: true
  priority: high
```

#### Step 3: Choose Appropriate Category

Place tool definition in the correct file:

- `forensics.yaml` - Digital forensics tools (Autopsy, KAPE, etc.)
- `malware-analysis.yaml` - Malware analysis (IDA, Ghidra, YARA, etc.)
- `network-analysis.yaml` - Network tools (Wireshark, Zeek, etc.)
- `utilities.yaml` - General utilities (7-Zip, ripgrep, etc.)

Create new category files if needed:

```yaml
# resources/tools/memory-forensics.yaml
schema_version: "1.0"
category: memory-forensics
description: Memory forensics and analysis tools

tools:
  - name: volatility3
    # ... tool definition
```

#### Step 4: Test the Tool

```powershell
# Dry run to verify
.\resources\download\install-tools.ps1 -Category forensics -DryRun

# Test installation
.\resources\download\install-tools.ps1 -Category forensics
```

#### Step 5: Remove from Legacy Script

Once verified, comment out or remove from legacy script:

```powershell
# In release.ps1
# MIGRATED TO YAML: artemis
# $status = Get-GitHubRelease -repo "puffyCid/artemis" ...
```

## Conversion Examples

### Example 1: Simple GitHub Release

**Legacy:**
```powershell
$status = Get-GitHubRelease -repo "BurntSushi/ripgrep" -path "${SETUP_PATH}\ripgrep.zip" -match "x86_64-pc-windows-msvc.zip$" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ripgrep.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\ripgrep-* "${TOOLS}\ripgrep"
}
```

**New:**
```yaml
- name: ripgrep
  description: Fast line-oriented search tool
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

### Example 2: Simple Executable

**Legacy:**
```powershell
$status = Get-GitHubRelease -repo "antonmedv/fx" -path "${SETUP_PATH}\fx.exe" -match "fx_windows_amd64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\fx.exe ${TOOLS}\bin\
}
```

**New:**
```yaml
- name: fx
  description: Command-line JSON processing tool
  source: github
  repo: antonmedv/fx
  match: "fx_windows_amd64\\.exe"
  file_type: exe
  install_method: copy
  copy_to: "${TOOLS}/bin/fx.exe"
  enabled: true
  priority: medium
```

### Example 3: HTTP Download with Dynamic URL

**Legacy:**
```powershell
$EXIFTOOL_VERSION = Get-DownloadUrlFromPage -url https://exiftool.org/index.html -RegEx 'exiftool-[^zip]+_64.zip'
$status = Get-FileFromUri -uri "https://exiftool.org/$EXIFTOOL_VERSION" -FilePath ".\downloads\exiftool.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\exiftool.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\exiftool-* "${TOOLS}\exiftool" -Force
    Copy-Item "${TOOLS}\exiftool\exiftool(-k).exe" ${TOOLS}\exiftool\exiftool.exe
    Remove-Item "${TOOLS}\exiftool\exiftool(-k).exe" -Force
}
```

**New:**
```yaml
- name: exiftool
  description: Read and write meta information in files
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

### Example 4: Installer (MSI/EXE)

**Legacy:**
```powershell
$status = Get-GitHubRelease -repo "sleuthkit/autopsy" -path "${SETUP_PATH}\autopsy.msi" -match "autopsy-.*-64bit\\.msi" -check "Composite Document"
if ($status) {
    # Installed during sandbox startup
}
```

**New:**
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

### Example 5: Multiple Post-Install Steps

**Legacy:**
```powershell
$status = Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "${SETUP_PATH}\aleapp.zip" -match "aleapp-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\aleapp") {
        Remove-Item "${TOOLS}\aleapp" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\aleapp.zip" -o"${TOOLS}\aleapp" | Out-Null
    Copy-Item ${TOOLS}\aleapp\aleapp.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\aleapp" -Recurse -Force
}
```

**New:**
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

## YAML Schema Reference

### Required Fields

```yaml
- name: string          # Unique tool identifier
  source: string        # "github" or "http"
  file_type: string     # "zip", "exe", "msi", etc.
  install_method: string # "extract", "copy", "installer"
  enabled: boolean      # true or false
```

### GitHub Source Fields

```yaml
source: github
repo: string           # "owner/repository"
match: string          # Regex pattern for release asset
```

### HTTP Source Fields

```yaml
source: http
url: string            # Direct URL
# OR
url_pattern: string    # Base URL for scraping
match: string          # Regex pattern to find download link
```

### Install Methods

#### Extract (for ZIP files)

```yaml
install_method: extract
extract_to: string     # Target directory
```

#### Copy (for single files)

```yaml
install_method: copy
copy_to: string        # Full target path with filename
```

#### Installer (for MSI/EXE installers)

```yaml
install_method: installer
installer_args: string # Command-line arguments (optional)
```

### Post-Install Steps

```yaml
post_install:
  - type: rename        # Rename files/directories
    pattern: string     # Glob pattern to match
    target: string      # New name

  - type: copy          # Copy files
    source: string      # Source path
    target: string      # Target path

  - type: remove        # Remove files/directories
    target: string      # Path to remove

  - type: add_to_path   # Add to PATH (noted for startup script)
    path: string        # Path to add
```

### Optional Fields

```yaml
description: string    # Human-readable description
priority: string       # "critical", "high", "medium", "low"
notes: string          # Additional notes
category: string       # Auto-added from file name
```

## Testing Strategy

### 1. Test Individual Tool

```powershell
# Dry run
.\resources\download\install-tools.ps1 -Category forensics -DryRun

# Actual installation
.\resources\download\install-tools.ps1 -Category forensics
```

### 2. Test Category

After migrating several tools in a category:

```powershell
# Install entire category
.\resources\download\install-tools.ps1 -Category malware-analysis -Parallel
```

### 3. Verify in Sandbox

Start a sandbox and verify:

1. Tool is present in expected location
2. Tool runs without errors
3. PATH additions work correctly
4. Dependencies are satisfied

### 4. Compare with Legacy

Run both systems and compare results:

```powershell
# Legacy
.\downloadFiles.ps1 -Release

# New
.\resources\download\install-tools.ps1 -All -Parallel

# Compare contents
Compare-Object (Get-ChildItem .\mount\Tools -Recurse).Name (Get-ChildItem .\mount\Tools -Recurse).Name
```

## Migration Checklist

- [ ] Identify tool in legacy script
- [ ] Create YAML definition
- [ ] Choose appropriate category file
- [ ] Test with dry run
- [ ] Test actual installation
- [ ] Verify in sandbox
- [ ] Update documentation if needed
- [ ] Comment out/remove from legacy script
- [ ] Submit pull request

## Common Issues

### Issue: Tool Won't Download

**Cause:** Regex pattern doesn't match release assets

**Solution:** Check GitHub releases page and adjust regex:

```powershell
# Test pattern
$releases = (curl.exe --silent -L "https://api.github.com/repos/owner/repo/releases/latest" | ConvertFrom-Json).assets.browser_download_url
$releases -match "your-pattern"
```

### Issue: Extraction Fails

**Cause:** Path doesn't exist or permissions issue

**Solution:** Verify paths use correct variables:

```yaml
extract_to: "${TOOLS}/toolname"  # Correct
extract_to: "C:\Tools\toolname"  # Avoid hardcoding
```

### Issue: Post-Install Steps Don't Run

**Cause:** Syntax error in YAML

**Solution:** Validate YAML syntax:

```powershell
# Test YAML parsing
.\resources\download\tool-handler.ps1
Import-ToolDefinitions -Category your-category
```

### Issue: Tool Marked as Failed

**Cause:** Various, check error log

**Solution:**

```powershell
# View errors
Get-Content .\log\tool-errors.json | ConvertFrom-Json

# View detailed state
Get-Content .\downloads\installation-state.json | ConvertFrom-Json
```

## Gradual Migration Path

Don't migrate everything at once. Suggested order:

### Phase 1: High-Value Tools (Week 1)
- Utilities (ripgrep, fx, etc.)
- Common forensics tools
- Most-used malware analysis tools

### Phase 2: Bulk GitHub Releases (Week 2-3)
- Migrate tools with simple download/extract patterns
- Tools without complex post-install steps

### Phase 3: Complex Tools (Week 4)
- Tools with dynamic URLs
- Tools with multiple post-install steps
- Tools with dependencies

### Phase 4: Legacy Cleanup (Week 5)
- Remove commented code from legacy scripts
- Archive old scripts
- Update all documentation

## Benefits After Migration

1. **Maintainability**: Update tool URLs/patterns without touching code
2. **Extensibility**: Add new tools in minutes
3. **Performance**: Parallel downloads significantly faster
4. **Reliability**: State management and resume capability
5. **Clarity**: Tool definitions are self-documenting
6. **Collaboration**: Less merge conflicts, easier reviews

## Getting Help

- Check [MODULAR-ARCHITECTURE.md](MODULAR-ARCHITECTURE.md) for detailed architecture
- Review existing YAML files for examples
- Open GitHub issue for complex migration cases
- Ask in discussions for migration advice

## Contributing Back

After successful migration:

1. Update this guide with lessons learned
2. Add examples for edge cases
3. Document any new post-install step types
4. Share migration scripts/tools you created
