# DFIRWS Modular Architecture

## Overview

DFIRWS has been refactored to use a modular, data-driven architecture that makes it easier to maintain, extend, and customize. The new system separates tool definitions from code, enabling easier updates and better organization.

## Key Improvements

### 1. Data-Driven Tool Definitions

Tools are now defined in YAML files instead of hardcoded in PowerShell scripts:

**Before:**
```powershell
# In release.ps1 (repeated 148+ times)
$status = Get-GitHubRelease -repo "puffyCid/artemis" -path "${SETUP_PATH}\artemis.zip" -match "x86_64-pc-windows-msvc.zip$"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\artemis.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\artemis-* "${TOOLS}\artemis"
}
```

**After:**
```yaml
# In resources/tools/forensics.yaml
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

### 2. Category-Based Organization

Tools are organized by category in separate YAML files:

```text
resources/tools/
├── forensics.yaml          # Digital forensics tools
├── malware-analysis.yaml   # Malware analysis and RE tools
├── network-analysis.yaml   # Network traffic analysis
└── utilities.yaml          # General utilities
```

### 3. Generic Tool Handler

A single, generic tool handler processes all tool definitions:

```powershell
# Install all forensics tools
.\resources\download\install-tools.ps1 -Category forensics

# Install only high-priority tools
.\resources\download\install-tools.ps1 -Priority high

# Install with parallel downloads (5x-10x faster)
.\resources\download\install-tools.ps1 -All -Parallel -ThrottleLimit 10
```

### 4. State Management and Resume

The system tracks installation progress and can resume from failures:

```powershell
# Resume from previous installation
.\resources\download\install-tools.ps1 -Resume

# View statistics
.\resources\download\install-tools.ps1 -Statistics
```

### 5. Parallel Downloads

Downloads can run in parallel, significantly reducing total time:

```powershell
# Sequential (old way): ~30 minutes
.\resources\download\install-tools.ps1 -All

# Parallel (new way): ~5-10 minutes
.\resources\download\install-tools.ps1 -All -Parallel
```

## Architecture Components

### Tool Definition Schema

Each tool is defined with the following structure:

```yaml
- name: tool_name              # Unique identifier
  description: Tool description # Human-readable description
  source: github|http           # Download source
  repo: owner/repo              # For GitHub sources
  url: https://...              # For HTTP sources
  match: "regex pattern"        # Pattern to match release asset
  file_type: zip|exe|msi        # File type
  install_method: extract|copy|installer
  extract_to: "${TOOLS}/path"   # Extraction path
  copy_to: "${TOOLS}/path"      # Copy destination
  installer_args: "/quiet"      # Installer arguments
  post_install:                 # Post-installation steps
    - type: rename|copy|remove|add_to_path
      pattern: "pattern"
      target: "target"
  enabled: true|false           # Enable/disable tool
  priority: critical|high|medium|low
  notes: "Additional notes"
```

### Module Structure

```text
resources/
├── download/
│   ├── common.ps1            # Common functions (existing)
│   ├── tool-handler.ps1      # Generic tool processor
│   ├── state-manager.ps1     # State tracking and resume
│   └── install-tools.ps1     # Orchestrator script
└── tools/
    ├── forensics.yaml
    ├── malware-analysis.yaml
    ├── network-analysis.yaml
    └── utilities.yaml
```

## Usage Examples

### Install All Tools

```powershell
# Sequential
.\resources\download\install-tools.ps1 -All

# Parallel (recommended)
.\resources\download\install-tools.ps1 -All -Parallel
```

### Install by Category

```powershell
# Install all forensics tools
.\resources\download\install-tools.ps1 -Category forensics

# Install all malware analysis tools
.\resources\download\install-tools.ps1 -Category malware-analysis
```

### Install by Priority

```powershell
# Install only critical and high priority tools
.\resources\download\install-tools.ps1 -Priority high
```

### Resume Failed Installation

```powershell
# Resume from last interruption
.\resources\download\install-tools.ps1 -Resume

# Resume with parallel downloads
.\resources\download\install-tools.ps1 -Resume -Parallel
```

### Dry Run

```powershell
# Preview what would be installed
.\resources\download\install-tools.ps1 -All -DryRun
```

### View Statistics

```powershell
# Show installation statistics
.\resources\download\install-tools.ps1 -Statistics
```

## Adding New Tools

### 1. Add to Appropriate YAML File

Edit the appropriate category file (e.g., `resources/tools/forensics.yaml`):

```yaml
- name: newtool
  description: Description of the new tool
  source: github
  repo: author/newtool
  match: "windows.*\\.zip$"
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/newtool"
  enabled: true
  priority: medium
```

### 2. Test the Tool

```powershell
# Dry run to verify definition
.\resources\download\install-tools.ps1 -Category forensics -DryRun

# Install the new tool
.\resources\download\install-tools.ps1 -Category forensics
```

### 3. No Code Changes Required

The tool will be automatically processed by the generic handler.

## Migration from Legacy System

The legacy system (release.ps1, http.ps1) continues to work. The new system can be used in parallel:

```powershell
# Legacy way (still works)
.\downloadFiles.ps1 -Release

# New way (recommended)
.\resources\download\install-tools.ps1 -All -Parallel
```

Over time, tools can be migrated from legacy scripts to YAML definitions.

## Performance Comparison

| Method | Time | Tools |
|--------|------|-------|
| Legacy Sequential | ~30 min | All |
| New Sequential | ~25 min | All |
| New Parallel (5 jobs) | ~8 min | All |
| New Parallel (10 jobs) | ~5 min | All |

*Times are approximate and depend on network speed and system resources.*

## State Management

Installation state is tracked in `downloads/installation-state.json`:

```json
{
  "session_id": "20250105-143022",
  "start_time": "2025-01-05 14:30:22",
  "end_time": "2025-01-05 14:45:10",
  "status": "completed",
  "total_tools": 50,
  "completed_tools": [
    {"name": "artemis", "version": "unknown", "completed_at": "2025-01-05 14:31:15"},
    {"name": "aleapp", "version": "unknown", "completed_at": "2025-01-05 14:32:30"}
  ],
  "failed_tools": [
    {"name": "sometool", "error": "Connection timeout", "failed_at": "2025-01-05 14:40:00"}
  ]
}
```

## Error Handling

Errors are logged in `log/tool-errors.json`:

```json
[
  {
    "tool": "sometool",
    "error": "Failed to download: Connection timeout",
    "timestamp": "2025-01-05 14:40:00",
    "context": {
      "source": "github",
      "repo": "owner/sometool"
    }
  }
]
```

## Best Practices

1. **Use Parallel Downloads**: Much faster, especially for many tools
2. **Start with High Priority**: Install critical tools first
3. **Use Resume**: If interrupted, resume instead of restarting
4. **Test with Dry Run**: Verify definitions before installing
5. **Check Statistics**: Review success rates and failed tools
6. **Enable Only What You Need**: Disable unused tools in YAML

## Troubleshooting

### Tool Won't Download

1. Check the YAML definition for typos
2. Verify the GitHub repository exists
3. Check the regular expression pattern matches actual release names
4. Test with `-DryRun` flag

### Installation Fails

1. Check `log/tool-errors.json` for details
2. Verify required dependencies are installed
3. Ensure sufficient disk space
4. Check antivirus isn't blocking files

### Parallel Downloads Hang

1. Reduce throttle limit: `-ThrottleLimit 3`
2. Use sequential mode instead
3. Check for rate limiting on GitHub
4. Verify GitHub token is set correctly

## Future Enhancements

- Dependency management
- Version pinning
- Automatic updates
- Tool verification/checksums
- Category tags/filters
- Export tool catalog to HTML
- Integration with package managers

## Contributing

To add tools to the new system:

1. Add tool definition to appropriate YAML file
2. Test with dry run
3. Document any special requirements
4. Submit pull request

For questions or issues, see the main [Readme](../README.md) or open an issue on GitHub.
