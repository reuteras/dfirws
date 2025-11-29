# Monday Quick Start Guide - V2 Testing

## Quick Reference for Testing DFIRWS v2

**Goal**: Test all 433 tools download and OSINT data acquisition, then validate everything works.

---

## 1. Quick Setup (15 minutes)

```powershell
# Open PowerShell as Administrator and navigate to project
cd C:\path\to\dfirws

# Verify prerequisites
winget list 7zip.7zip
winget list Git.Git
winget list Rclone.Rclone

# Check Windows Sandbox is enabled
Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online

# Set execution policy (if needed)
Set-ExecutionPolicy -ExecutionPolicy Bypass

# Check config.ps1 has GitHub token
Get-Content config.ps1 | Select-String "GITHUB_TOKEN"
```

**⚠️ CRITICAL**: Must have GitHub token in config.ps1 or you'll hit rate limits!

---

## 2. Quick Test (5 minutes)

Verify v2 infrastructure works before full download:

```powershell
# Show tool counts (should show 433 total)
.\resources\download\install-all-tools-v2.ps1 -ShowCounts

# Dry run (no actual downloads, just testing)
.\resources\download\install-all-tools-v2.ps1 -All -DryRun
```

**Expected**: No errors, shows 433 tools across 5 categories.

---

## 3. Full Download & Validation (One Command)

```powershell
# Download everything and verify
.\downloadFiles.ps1 -AllTools -Enrichment -Freshclam -Verify
```

**Time**: 8-12 hours (can run overnight or during workday)

**What this does**:
- Downloads all 433 tools via v2 YAML architecture
- Downloads OSINT/enrichment data (TOR, MaxMind, YARA rules, etc.)
- Updates ClamAV signatures
- Runs verification in Windows Sandbox
- Creates complete DFIRWS environment

---

## 4. Monitor Progress

While it runs, monitor in another PowerShell window:

```powershell
# Watch main log
Get-Content .\log\dfirws.txt -Wait -Tail 20

# Check for errors across all logs
Get-ChildItem .\log\*.txt | ForEach-Object {
    Get-Content $_ | Select-String -Pattern "error|failed" -Context 1
}

# Check disk space
Get-PSDrive C | Select-Object Used,Free
```

---

## 5. Validation Checklist

After download completes, verify:

### Tools Installed (433 total)

```powershell
# Check standard tools (193 expected)
Get-ChildItem .\resources\tool-categories\ -Directory

# Check Python tools (72 expected)
uv tool list

# Check Git repos (62 expected)
Get-ChildItem .\resources\git\ -Directory | Measure-Object

# Check Didier Stevens (102 expected)
Get-ChildItem .\resources\git\didier-stevens\ -Filter "*.py" -Recurse | Measure-Object

# Check Node.js tools (4 expected)
npm list -g --depth=0
```

### OSINT/Enrichment Data

```powershell
# Check enrichment directory structure
Get-ChildItem .\enrichment\ -Directory

# Verify specific files
Test-Path .\enrichment\manuf\manuf.txt
Test-Path .\enrichment\maxmind\*.mmdb  # If MaxMind key configured
Get-ChildItem .\enrichment\tor\ | Measure-Object  # TOR exit nodes
```

### Sandbox Test

```powershell
# Create sandbox config files
.\createSandboxConfig.ps1

# Start sandbox (should launch in ~1-2 minutes)
.\dfirws.wsb
```

**In sandbox**: Try searching for tools, verify they're accessible.

### Verification Log

```powershell
# Check verification results
Get-Content .\log\verify.txt

# Look for verification success
Get-Content .\log\verify.txt | Select-String -Pattern "success|completed|done"
```

---

## 6. Quick Success Check

Run this to verify everything:

```powershell
# Check all key components
@{
    "Standard Tools" = (Get-ChildItem .\resources\tool-categories\ -Directory).Count
    "Python Tools" = (uv tool list 2>$null | Measure-Object -Line).Lines
    "Git Repos" = (Get-ChildItem .\resources\git\ -Directory -ErrorAction SilentlyContinue).Count
    "Didier Scripts" = (Get-ChildItem .\resources\git\didier-stevens\ -Filter "*.py" -Recurse -ErrorAction SilentlyContinue).Count
    "Enrichment Dirs" = (Get-ChildItem .\enrichment\ -Directory -ErrorAction SilentlyContinue).Count
} | Format-Table -AutoSize
```

**Expected output**:
- Standard Tools: ~19-23 categories
- Python Tools: 72
- Git Repos: 62
- Didier Scripts: 102
- Enrichment Dirs: 8-10

---

## 7. If Problems Occur

### Rate Limiting Error

```powershell
# Check GitHub API rate limit
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/rate_limit
```

**Fix**: Add/update GitHub token in config.ps1

### Download Failures

```powershell
# Search logs for failed downloads
Get-ChildItem .\log\*.txt | ForEach-Object {
    Write-Host "`n=== $($_.Name) ===" -ForegroundColor Cyan
    Get-Content $_ | Select-String -Pattern "failed|error" -Context 2
}
```

**Fix**: Re-run specific component:
```powershell
.\downloadFiles.ps1 -Release   # Retry GitHub releases
.\downloadFiles.ps1 -Git       # Retry Git repos
.\downloadFiles.ps1 -Python    # Retry Python tools
```

### Disk Space Issues

```powershell
# Check available space
Get-PSDrive C

# Clean temporary files
Remove-Item .\tmp\* -Recurse -Force
```

**Required space**: ~50 GB minimum

### Sandbox Won't Start

```powershell
# Verify Windows Sandbox feature
Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online

# Enable if needed (requires restart)
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
```

---

## 8. Alternative: Incremental Testing

If full download is too risky, test incrementally:

```powershell
# Step 1: Test GitHub releases (30-60 min)
.\downloadFiles.ps1 -Release

# Step 2: Test Git repos (20-40 min)
.\downloadFiles.ps1 -Git

# Step 3: Test Python tools (30-60 min)
.\downloadFiles.ps1 -Python

# Step 4: Test enrichment (30-60 min)
.\downloadFiles.ps1 -Enrichment

# Step 5: Verify everything
.\downloadFiles.ps1 -Verify
```

---

## 9. Documentation After Testing

Create a quick report:

```powershell
# Save results to file
@"
DFIRWS V2 Testing Results - $(Get-Date -Format 'yyyy-MM-dd')

## Tool Counts
- Standard Tools: $($(Get-ChildItem .\resources\tool-categories\ -Directory -ErrorAction SilentlyContinue).Count) categories
- Python Tools: $($(uv tool list 2>$null | Measure-Object -Line).Lines) packages
- Git Repos: $($(Get-ChildItem .\resources\git\ -Directory -ErrorAction SilentlyContinue).Count) repositories
- Didier Scripts: $($(Get-ChildItem .\resources\git\didier-stevens\ -Filter "*.py" -Recurse -ErrorAction SilentlyContinue).Count) scripts

## Enrichment Data
- Directories: $($(Get-ChildItem .\enrichment\ -Directory -ErrorAction SilentlyContinue).Count)

## Errors Found
$(Get-ChildItem .\log\*.txt -ErrorAction SilentlyContinue | ForEach-Object {
    $errors = Get-Content $_ | Select-String -Pattern "error|failed" -Context 0
    if ($errors) { "File: $($_.Name)`n$errors`n" }
})

## Sandbox Test
- Sandbox created: $(Test-Path .\dfirws.wsb)
- Sandbox started: [PASS/FAIL - manual check]

## Overall Status
- [SUCCESS/FAILURE]
- Notes: [Add any issues or observations]
"@ | Out-File ".\V2_TEST_RESULTS_$(Get-Date -Format 'yyyy-MM-dd').txt"
```

---

## 10. Expected Timeline

| Time | Task | Duration |
|------|------|----------|
| 08:00 | Setup & verification | 30 min |
| 08:30 | Start full download | 15 min |
| 08:45 | ☕ Let it run... | 8-10 hours |
| 18:00 | Check results | 30 min |
| 18:30 | Run validation | 30 min |
| 19:00 | Test sandbox | 30 min |
| 19:30 | Document results | 30 min |
| 20:00 | ✅ Done! | - |

**Total active time**: ~2.5 hours
**Total wait time**: ~8-10 hours

---

## Key Files to Review After Testing

1. `.\log\dfirws.txt` - Main log
2. `.\log\verify.txt` - Verification results
3. `.\log\install_all_v2.txt` - V2 installation log
4. `.\log\python.txt` - Python tools log
5. `.\log\http.txt` - HTTP downloads log

---

## Success Criteria Summary

✅ **PASS** if:
- All 433 tools counted (use -ShowCounts)
- No critical errors in logs
- Enrichment directories populated
- Sandbox starts and runs
- Verification script completes

❌ **FAIL** if:
- Missing large numbers of tools (>10%)
- Sandbox won't start
- Critical tools missing
- Verification script fails

---

## Emergency Contact

If major issues occur, document:
1. Error messages from logs
2. PowerShell version (`$PSVersionTable`)
3. Windows version (`winver`)
4. Disk space available
5. Which step failed

Then create GitHub issue with details.

---

**Remember**: This is the first complete end-to-end test of v2 architecture!

**Good luck on Monday!** 🚀
