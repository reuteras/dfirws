# V2 Testing and Validation Plan

## Overview

This document provides a comprehensive plan for testing the DFIRWS v2 YAML-based architecture on Windows, including tool downloads, OSINT data acquisition, and validation procedures.

**Target Date**: Monday (when Windows computer is available)
**Current Status**: v2 architecture is 100% complete but needs end-to-end testing
**Total Tools**: 433 across 23 categories
**Current Branch**: v2

---

## Pre-Testing Checklist

### Before Starting on Windows

1. **Ensure Prerequisites Are Installed**:
   ```powershell
   # Check if required programs are installed
   winget list 7zip.7zip
   winget list Git.Git
   winget list Rclone.Rclone

   # Install if missing
   winget install 7zip.7zip
   winget install Git.Git
   winget install Rclone.Rclone
   ```

2. **Verify Windows Sandbox is Enabled**:
   ```powershell
   # Check if Windows Sandbox feature is enabled
   Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online

   # Enable if needed (requires restart)
   Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
   ```

3. **Configure PowerShell Execution Policy**:
   ```powershell
   # Must be done for BOTH PowerShell and pwsh
   # Run as Administrator
   Set-ExecutionPolicy -ExecutionPolicy Bypass
   ```

4. **Prepare Configuration File**:
   ```powershell
   cd dfirws

   # Copy template if config.ps1 doesn't exist
   if (-not (Test-Path config.ps1)) {
       Copy-Item config.ps1.template config.ps1
   }

   # Edit config.ps1 and add:
   # - GitHub token (required to avoid rate limiting)
   # - MaxMind license key (optional, for GeoIP data)
   # - IPinfo API key (optional, for IP geolocation)
   ```

5. **Ensure You Have Enough Disk Space**:
   - Tools: ~15-20 GB
   - Enrichment data: ~5-10 GB
   - VM (if creating): ~300 GB (sparse allocation)
   - Total recommended: **50+ GB free space**

---

## Testing Phases

### Phase 1: Basic Infrastructure Test (15-30 minutes)

Test that the v2 infrastructure works before attempting full downloads.

#### 1.1 Test YAML Validation

```powershell
# Ensure no YAML syntax errors
.\resources\download\install-all-tools-v2.ps1 -ShowCounts
```

**Expected Output**:
- Standard Tools: 193
- Python Tools: 72
- Git Repositories: 62
- Didier Stevens Tools: 102
- Node.js Tools: 4
- **Total: 433 tools**

**If this fails**: YAML files have syntax errors, need fixing before proceeding.

#### 1.2 Test Dry-Run Mode

```powershell
# Test all installers in dry-run mode (no actual downloads)
.\resources\download\install-all-tools-v2.ps1 -All -DryRun
```

**Expected Output**:
- Should display what would be installed for each category
- No actual downloads should occur
- No errors should be reported

**If this fails**: Installation logic has issues, need debugging.

---

### Phase 2: Incremental Tool Downloads (2-4 hours)

Download tools incrementally by category to identify issues early.

#### 2.1 Test Standard Tools (GitHub Releases)

**Estimated time**: 30-60 minutes

```powershell
# Download only GitHub release-based tools
.\downloadFiles.ps1 -Release

# Check log for errors
Get-Content .\log\install_all_v2.txt | Select-String -Pattern "error|failed" -Context 2
```

**What to verify**:
- Check `.\resources\tool-categories\` directories are populated
- Verify key tools are present (e.g., `.\resources\tool-categories\forensics\`)
- Review log file for download failures

**Common issues**:
- Rate limiting (if GitHub token not set)
- Network connectivity issues
- Antivirus blocking downloads

#### 2.2 Test Git Repositories

**Estimated time**: 20-40 minutes

```powershell
# Clone all Git repositories
.\downloadFiles.ps1 -Git

# Check log for errors
Get-Content .\log\install_all_v2.txt | Select-String -Pattern "error|failed" -Context 2
```

**What to verify**:
- Check `.\resources\git\` directory is populated
- Verify YARA rules are cloned
- Check Sigma rules are present

**Common issues**:
- Git not in PATH
- Firewall blocking git protocol
- Large repositories timing out

#### 2.3 Test Didier Stevens Tools

**Estimated time**: 10-20 minutes

```powershell
# Download Didier Stevens suite
.\downloadFiles.ps1 -Didier

# Verify installation
Get-ChildItem .\resources\git\didier-stevens\ -Recurse | Measure-Object | Select-Object Count
```

**Expected**: 102 Python scripts downloaded

#### 2.4 Test Python Tools

**Estimated time**: 30-60 minutes

```powershell
# Install Python tools (72 packages via uv)
.\downloadFiles.ps1 -Python

# Check installation log
Get-Content .\log\python.txt | Select-String -Pattern "error|failed" -Context 2

# Verify uv installation directory
Get-ChildItem $env:LOCALAPPDATA\uv\tools -Directory | Measure-Object
```

**What to verify**:
- Check that `uv` is installed
- Verify Python packages are in uv tools directory
- Check for any installation failures

**Common issues**:
- Missing Python dependencies
- Network issues downloading packages
- Package conflicts

#### 2.5 Test Node.js Tools

**Estimated time**: 10-20 minutes

```powershell
# Install Node.js packages (4 packages)
.\downloadFiles.ps1 -Node

# Verify npm global packages
npm list -g --depth=0
```

**Expected**: 4 tools installed globally

#### 2.6 Test HTTP Downloads

**Estimated time**: 20-40 minutes

```powershell
# Download special HTTP-based tools
.\downloadFiles.ps1 -Http

# Check log
Get-Content .\log\http.txt | Select-String -Pattern "error|failed" -Context 2
```

**What to verify**:
- VSCode extensions downloaded
- Direct HTTP downloads completed
- Special installers fetched

---

### Phase 3: Enrichment Data Download (30-60 minutes)

Download OSINT and enrichment data for forensic analysis.

```powershell
# Download all enrichment data
.\downloadFiles.ps1 -Enrichment

# Verify enrichment directory structure
Get-ChildItem .\enrichment\ -Directory
```

**Expected directories**:
- `cve` - CVE data
- `geolocus` - Geolocation data
- `git` - Git-based threat intel
- `ipinfo` - IP information (if API key configured)
- `manuf` - MAC address manufacturer data
- `maxmind` - MaxMind GeoIP databases (if license key configured)
- `snort` - Snort rules
- `suricata` - Suricata rules
- `tor` - TOR exit node lists
- `yara` - YARA rules

**What to verify**:
```powershell
# Check TOR exit nodes
Get-ChildItem .\enrichment\tor\ | Measure-Object

# Check manuf file
Get-Item .\enrichment\manuf\manuf.txt

# Check MaxMind (if configured)
Get-ChildItem .\enrichment\maxmind\ -Filter "*.mmdb"

# Check YARA rules
Get-ChildItem .\enrichment\yara\ -Recurse -Filter "*.yar"
```

**Common issues**:
- Missing API keys (MaxMind, IPinfo)
- Network connectivity issues
- Download timeouts for large files

---

### Phase 4: ClamAV Signature Updates (10-20 minutes)

Update ClamAV antivirus signatures.

```powershell
# Update ClamAV databases
.\downloadFiles.ps1 -Freshclam

# Verify ClamAV databases
Get-ChildItem .\mount\venv\ -Filter "*.cvd"
```

**Note**: README mentions freshclam doesn't work currently - this may fail.

---

### Phase 5: Complete Download Test (3-5 hours total)

Run everything in one go to test the complete workflow.

```powershell
# Complete download: all tools + enrichment + freshclam
.\downloadFiles.ps1 -AllTools -Enrichment -Freshclam

# Monitor progress
Get-Content .\log\dfirws.txt -Wait -Tail 20
```

**What this does**:
- Downloads all 433 tools via v2 installers
- Downloads all enrichment data
- Updates ClamAV signatures
- Creates complete DFIRWS environment

---

### Phase 6: Validation (30-60 minutes)

Verify that all downloaded tools are working correctly.

#### 6.1 Run Built-in Verification

```powershell
# Run verification script
.\downloadFiles.ps1 -Verify

# Check verification results
Get-Content .\log\verify.txt
```

**What this does**:
- Starts a Windows Sandbox
- Runs verification tests inside the sandbox
- Creates a "verify_done" file when complete
- Logs results to `.\log\verify.txt`

**What to verify in the log**:
- Tool availability checks
- Version checks
- Basic functionality tests

#### 6.2 Manual Verification

**Check critical tool categories**:

```powershell
# Forensics tools
Get-ChildItem .\resources\tool-categories\forensics\ -Recurse -Filter "*.exe" | Select-Object -First 10

# Malware analysis tools
Get-ChildItem .\resources\tool-categories\malware-analysis\ -Recurse -Filter "*.exe" | Select-Object -First 10

# Python tools (via uv)
uv tool list

# Git repositories
Get-ChildItem .\resources\git\ -Directory | Measure-Object
```

**Test sandbox startup**:

```powershell
# Create sandbox configuration
.\createSandboxConfig.ps1

# Test sandbox startup (network disabled)
.\dfirws.wsb
```

**What to verify**:
- Sandbox starts successfully
- Tools are accessible in sandbox
- Desktop shortcuts are created
- Search functionality works

---

## Validation Checklist

After completing all phases, verify the following:

### Tools Verification

- [ ] **Standard Tools**: 193 GitHub release-based tools installed
- [ ] **Python Tools**: 72 packages installed via `uv tool list`
- [ ] **Git Repositories**: 62 repos cloned in `.\resources\git\`
- [ ] **Didier Stevens**: 102 scripts in `.\resources\git\didier-stevens\`
- [ ] **Node.js Tools**: 4 packages installed via `npm list -g`
- [ ] **Total**: 433 tools accounted for

### Enrichment Data Verification

- [ ] **TOR Exit Nodes**: Downloaded to `.\enrichment\tor\`
- [ ] **MAC Manufacturer Data**: `.\enrichment\manuf\manuf.txt` exists
- [ ] **MaxMind GeoIP**: Databases in `.\enrichment\maxmind\` (if configured)
- [ ] **IPinfo Data**: Databases in `.\enrichment\ipinfo\` (if configured)
- [ ] **YARA Rules**: Rules in `.\enrichment\yara\`
- [ ] **Snort/Suricata Rules**: Rules in respective directories

### Sandbox Verification

- [ ] **Sandbox Config**: `dfirws.wsb` and `network_dfirws.wsb` created
- [ ] **Sandbox Starts**: Sandbox launches without errors
- [ ] **Tools Accessible**: Can find and run tools in sandbox
- [ ] **Performance**: Sandbox startup time ~1-2 minutes

### Log File Review

- [ ] **No Critical Errors**: Review `.\log\dfirws.txt` for errors
- [ ] **No Download Failures**: Check individual log files
- [ ] **Verification Passed**: `.\log\verify.txt` shows success

---

## Quick Reference Commands

### One-Line Complete Setup

```powershell
# Download everything and verify
.\downloadFiles.ps1 -AllTools -Enrichment -Freshclam -Verify
```

### Selective Downloads

```powershell
# Only tools (no enrichment)
.\downloadFiles.ps1 -AllTools

# Only enrichment (no tools)
.\downloadFiles.ps1 -Enrichment

# Only specific tool types
.\downloadFiles.ps1 -Release -Git -Python

# Tools + verification
.\downloadFiles.ps1 -AllTools -Verify
```

### Troubleshooting Commands

```powershell
# View recent log entries
Get-Content .\log\dfirws.txt -Tail 50

# Search for errors across all logs
Get-ChildItem .\log\*.txt | ForEach-Object {
    Get-Content $_ | Select-String -Pattern "error|failed|exception"
}

# Check disk space
Get-PSDrive C | Select-Object Used,Free

# Test GitHub API rate limit (if using token)
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/rate_limit

# Verify Windows Sandbox is enabled
Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online
```

---

## Known Issues to Watch For

Based on README.md, these tools have known issues:

1. **aleapp**: `ModuleNotFoundError: No module named 'xmltodict'`
2. **bazaar**: `ModuleNotFoundError: No module named 'typer'`
3. **shodan**: `ModuleNotFoundError: No module named 'pkg_resources'`
4. **freshclam**: Doesn't work currently

**Action**: Document any new issues you encounter during testing.

---

## Estimated Total Time

| Phase | Duration | Cumulative |
|-------|----------|------------|
| Pre-testing checklist | 15-30 min | 0:30 |
| Phase 1: Infrastructure test | 15-30 min | 1:00 |
| Phase 2: Incremental downloads | 2-4 hours | 5:00 |
| Phase 3: Enrichment data | 30-60 min | 6:00 |
| Phase 4: ClamAV updates | 10-20 min | 6:20 |
| Phase 5: Complete test | 3-5 hours | 11:20 |
| Phase 6: Validation | 30-60 min | 12:20 |
| **Total** | **~8-12 hours** | **12:20** |

**Recommendation**: Plan for a full day of testing on Monday.

---

## Success Criteria

The v2 architecture is considered fully validated when:

1. ✅ All 433 tools downloaded successfully
2. ✅ Enrichment data acquired completely
3. ✅ Verification script passes all checks
4. ✅ Windows Sandbox starts and runs tools correctly
5. ✅ No critical errors in log files
6. ✅ Performance is acceptable (sandbox startup ~1-2 min)

---

## Next Steps After Successful Testing

Once testing is complete and successful:

1. **Document Results**: Create a test report with findings
2. **Report Issues**: File GitHub issues for any problems found
3. **Merge to Main**: Prepare v2 branch for merge to main
4. **Tag Release**: Tag as v2.0.0 release
5. **Update Documentation**: Update README with v2 testing results

---

## Emergency Rollback Plan

If v2 testing fails catastrophically:

```powershell
# Switch back to legacy scripts temporarily
git checkout main

# Use v1 legacy scripts
.\downloadFiles.ps1 -AllTools
```

**Note**: Legacy scripts are still present and functional as backup.

---

**Last Updated**: 2025-11-29
**Status**: Ready for Testing
**Next Action**: Execute testing plan on Windows computer
