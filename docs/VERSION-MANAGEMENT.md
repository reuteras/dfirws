# DFIRWS Version Management and Security Validation

## Overview

This module provides version pinning, SHA256 validation, and update management for DFIRWS tools.

## Features

- **Version Pinning**: Pin tools to specific versions
- **SHA256 Validation**: Verify file integrity with checksums
- **Update Detection**: Check for newer versions
- **Version Lock File**: Track installed versions
- **Update Approval**: Review and approve updates
- **Automatic/Manual Modes**: Choose update strategy

## Architecture

### 1. Version Lock File

`downloads/tool-versions.lock.json` - Tracks installed versions:

```json
{
  "schema_version": "1.0",
  "last_updated": "2025-01-05T10:30:00Z",
  "tools": {
    "artemis": {
      "version": "1.2.3",
      "installed_date": "2025-01-05T10:00:00Z",
      "source": "github",
      "repo": "puffyCid/artemis",
      "sha256": "abc123...",
      "download_url": "https://github.com/.../artemis-1.2.3.zip",
      "file_path": "downloads/artemis.zip"
    }
  }
}
```

### 2. YAML Schema Extensions

Add optional version and validation fields:

```yaml
- name: artemis
  description: Fast forensic collection tool
  source: github
  repo: puffyCid/artemis
  match: "x86_64-pc-windows-msvc\\.zip$"

  # NEW: Version pinning (optional)
  version: "1.2.3"                    # Pin to specific version
  # OR
  version: "latest"                   # Always use latest (default)

  # NEW: SHA256 validation (optional but recommended)
  sha256: "abc123def456..."           # Expected checksum

  # NEW: Version policy
  update_policy: "manual"             # manual, auto, notify (default: notify)

  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/artemis"
  enabled: true
  priority: high
```

### 3. Update Workflow

```
1. Check for updates
   └─> Compare current version with latest available

2. List available updates
   └─> Show version changes, release notes

3. User approval (if manual)
   └─> Review and approve updates

4. Download and validate
   └─> Download file, verify SHA256

5. Install and update lock
   └─> Install tool, update version lock file
```

## Version Manager Module

### Key Functions

1. **Initialize-VersionLock**: Create/load version lock file
2. **Get-InstalledVersion**: Get currently installed version
3. **Get-LatestVersion**: Check for latest available version
4. **Check-Updates**: Find tools with updates available
5. **Approve-Update**: Mark update as approved
6. **Validate-Checksum**: Verify SHA256 checksum
7. **Update-VersionLock**: Record installation in lock file

## Usage Examples

### Check for Updates

```powershell
# Check all tools for updates
.\resources\download\install-tools.ps1 -CheckUpdates

# Output:
# Updates Available:
# - artemis: 1.2.3 -> 1.2.4
# - volatility3: 2.5.0 -> 2.5.2
# - yara: 4.3.0 -> 4.3.2
```

### List Available Updates

```powershell
# Show detailed update information
.\resources\download\install-tools.ps1 -ListUpdates

# Output:
# artemis (1.2.3 -> 1.2.4)
#   Released: 2025-01-01
#   Changes: Bug fixes, performance improvements
#   SHA256: def456...
#   Approve with: -ApproveUpdate artemis
```

### Approve and Install Updates

```powershell
# Approve specific updates
.\resources\download\install-tools.ps1 -ApproveUpdate artemis,volatility3

# Approve all updates
.\resources\download\install-tools.ps1 -ApproveAllUpdates

# Install approved updates
.\resources\download\install-tools.ps1 -InstallUpdates
```

### Force Update to Latest

```powershell
# Update specific tool ignoring version pin
.\resources\download\install-tools.ps1 -UpdateTool artemis -Force

# Update all tools to latest
.\resources\download\install-tools.ps1 -UpdateAll -Force
```

### Install with Version Pinning

```powershell
# Install tools respecting version pins
.\resources\download\install-tools.ps1 -All

# Install ignoring version pins (always latest)
.\resources\download\install-tools.ps1 -All -IgnoreVersions
```

### Validate Checksums

```powershell
# Validate all downloaded files
.\resources\download\install-tools.ps1 -ValidateChecksums

# Validate specific tool
.\resources\download\install-tools.ps1 -ValidateTool artemis
```

## Update Policies

### Manual (update_policy: manual)
- Never auto-update
- Requires explicit approval
- Best for production environments

### Auto (update_policy: auto)
- Automatically update to latest
- No approval needed
- Best for development environments

### Notify (update_policy: notify) - DEFAULT
- Check and notify about updates
- Requires approval to install
- Best for most users

## SHA256 Validation

### Automatic Validation

When SHA256 is specified in YAML:
1. Download file
2. Calculate actual SHA256
3. Compare with expected
4. Fail if mismatch
5. Log validation result

### Manual Checksum Addition

```powershell
# Calculate and add checksums to YAML
.\resources\download\calculate-checksums.ps1 -Category forensics

# This will:
# 1. Download all tools in category
# 2. Calculate SHA256 for each
# 3. Update YAML files with checksums
```

## Security Benefits

1. **Integrity Verification**: Detect tampering or corruption
2. **Version Control**: Know exactly what's installed
3. **Reproducibility**: Install same versions across environments
4. **Audit Trail**: Track when tools were installed/updated
5. **Rollback**: Easy to revert to previous versions
6. **Supply Chain Security**: Detect compromised downloads

## Best Practices

### For Tool Definitions

```yaml
# RECOMMENDED: Pin version with SHA256
- name: critical-tool
  version: "1.2.3"
  sha256: "abc123..."
  update_policy: manual

# ACCEPTABLE: Latest with SHA256 validation
- name: dev-tool
  version: "latest"
  sha256: "def456..."  # Updated automatically
  update_policy: auto

# MINIMUM: Latest without checksum (not recommended)
- name: test-tool
  version: "latest"
  update_policy: notify
```

### For Production

1. **Pin all critical tools**: Specify exact versions
2. **Use SHA256 validation**: Always validate checksums
3. **Manual update policy**: Review before updating
4. **Test before deploying**: Validate in test environment
5. **Maintain version lock**: Commit lock file to git

### For Development

1. **Use latest versions**: Stay current with tools
2. **Auto-update policy**: Keep tools up to date
3. **Validate checksums**: Still important
4. **Regular updates**: Check weekly
5. **Review changes**: Read release notes

## Version Lock File Management

### Commit to Git

```bash
# Commit version lock for reproducibility
git add downloads/tool-versions.lock.json
git commit -m "Update tool versions lock file"
```

### Share Across Team

```powershell
# Install exact versions from lock file
.\resources\download\install-tools.ps1 -FromLockFile

# This ensures everyone uses same versions
```

### Update Lock File

```powershell
# Update lock file without installing
.\resources\download\install-tools.ps1 -UpdateLockOnly

# Install and update lock
.\resources\download\install-tools.ps1 -All -UpdateLock
```

## Troubleshooting

### Checksum Mismatch

```
ERROR: SHA256 mismatch for artemis
Expected: abc123...
Actual:   def456...
```

**Solutions**:
1. Re-download file (may be corrupted)
2. Update checksum in YAML if tool was updated
3. Report if suspicious (possible compromise)

### Version Not Found

```
ERROR: Version 1.2.3 not found for artemis
Latest available: 1.2.4
```

**Solutions**:
1. Update version pin to available version
2. Use `version: "latest"`
3. Check if version was removed from repository

### Update Detection Fails

```
WARNING: Could not check for updates for artemis
API rate limit exceeded
```

**Solutions**:
1. Wait and retry later
2. Set GitHub token in config
3. Use `-IgnoreUpdateCheck` flag

## Implementation Notes

### GitHub API Considerations

- Rate limits: 60 requests/hour (unauthenticated), 5000 (authenticated)
- Cache update checks: Don't check every run
- Use ETag headers: Only download if changed

### HTTP Sources

- Some sources don't have version APIs
- Use ETag/Last-Modified for change detection
- Manual version specification may be required

### Version Comparison

- Semantic versioning (SemVer) support
- Handle different version formats (v1.2.3, 1.2.3, 1.2)
- Date-based versions for some tools

## Future Enhancements

1. **Automatic Checksum Updates**: When version changes, recalculate checksum
2. **Version History**: Track version history and changes
3. **Rollback Support**: Easy revert to previous version
4. **Security Advisories**: Check for vulnerabilities
5. **Dependency Tracking**: Handle tool dependencies
6. **Mirror Support**: Alternative download sources
7. **Offline Mode**: Work with cached versions

## See Also

- [MODULAR-ARCHITECTURE.md](MODULAR-ARCHITECTURE.md)
- [MIGRATION-GUIDE.md](MIGRATION-GUIDE.md)
- [Tool Definition Schema](../resources/tools/README.md)
