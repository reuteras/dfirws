# DFIRWS v2 YAML Architecture Guide

## Overview

DFIRWS v2 introduces a modular YAML-based architecture for managing tool installations. This replaces the monolithic PowerShell setup script with a flexible, maintainable system that's easy to extend and customize.

## Architecture Benefits

### ✅ Modularity
- Tools organized by forensic category
- Easy to add, modify, or remove individual tools
- Clear separation of concerns

### ✅ Maintainability
- Human-readable YAML configuration
- Schema validation support
- Consistent structure across all categories

### ✅ Documentation
- Every tool includes description, priority, and notes
- Clear installation methods
- Source tracking (GitHub, pip, npm, Git)

### ✅ Flexibility
- Multiple installation methods supported
- Version pinning and SHA256 validation
- Post-install actions (rename, patch, copy)
- Priority-based installation

### ✅ Automation
- Programmatic access to tool definitions
- Parallel installation support
- Update management system
- State tracking and resume capability

## Directory Structure

```text
dfirws/
├── resources/
│   ├── tools/                          # YAML tool definitions
│   │   ├── forensics.yaml             # Standard GitHub releases
│   │   ├── malware-analysis.yaml
│   │   ├── windows-forensics.yaml
│   │   ├── ... (20 category files)
│   │   ├── python-tools.yaml          # Python packages (UV/pip)
│   │   ├── git-repositories.yaml      # Git repositories to clone
│   │   ├── nodejs-tools.yaml          # Node.js packages (npm)
│   │   └── didier-stevens-tools.yaml  # Didier Stevens Suite
│   │
│   └── download/                       # Installation scripts
│       ├── yaml-parser.ps1            # YAML parsing functions
│       ├── install-tools.ps1          # Standard tool installer
│       ├── install-python-tools-v2.ps1
│       ├── install-git-repos-v2.ps1
│       ├── install-nodejs-tools-v2.ps1
│       ├── install-didier-stevens-v2.ps1
│       └── install-all-tools-v2.ps1   # Master installer
│
└── docs/
    └── YAML_ARCHITECTURE.md           # This file
```

## YAML File Structure

### Standard Tool Definition (GitHub Releases)

```yaml
schema_version: "1.0"
category: malware-analysis
description: Malware analysis and reverse engineering tools

tools:
  - name: yara
    description: Pattern matching swiss army knife for malware researchers
    source: github
    repo: VirusTotal/yara
    match: "win64\\.zip$"
    file_type: zip
    install_method: extract
    extract_to: "${TOOLS}/yara"
    post_install:
      - type: add_to_path
        path: "${TOOLS}/yara"
    enabled: true
    priority: high
    # Optional: version pinning
    version: "4.3.2"
    sha256: "abc123..."
```

### Python Tools Definition

```yaml
schema_version: "1.0"
category: python-tools
description: Python-based analysis tools

special_installs:
  - name: binary-refinery
    package: "binary-refinery[extended]"
    description: Binary analysis toolkit
    priority: high
    with: "zipp>=3.20"  # Additional dependencies

tools:
  - name: autoit-ripper
    package: autoit-ripper
    description: AutoIt script extractor
    category_type: malware-analysis
    priority: medium
```

### Git Repositories Definition

```yaml
schema_version: "1.0"
category: git-repositories
description: Git repositories containing tools and resources

repositories:
  - name: signature-base
    url: "https://github.com/Neo23x0/signature-base.git"
    description: YARA signature database
    category_type: detection-rules
    priority: critical
    post_clone:
      - type: patch
        description: Apply custom patches
```

### Node.js Tools Definition

```yaml
schema_version: "1.0"
category: nodejs-tools
description: Node.js-based analysis tools

tools:
  - name: box-js
    package: box-js
    description: JavaScript malware analysis sandbox
    category_type: malware-analysis
    priority: high
```

### Didier Stevens Tools Definition

```yaml
schema_version: "1.0"
category: didier-stevens-tools
description: Didier Stevens' comprehensive Python toolkit

main_suite:
  source: "https://raw.githubusercontent.com/DidierStevens/DidierStevensSuite/master/"
  destination: "${TOOLS}/DidierStevens/"
  tools:
    - name: pdf-parser.py
      description: Parse and analyze PDF files
      category_type: document-analysis
      priority: critical

beta_tools:
  source: "https://raw.githubusercontent.com/DidierStevens/Beta/master/"
  destination: "${TOOLS}/DidierStevens/"
  tools:
    - name: metatool.py
      description: Metadata analysis tool (beta)
      category_type: document-analysis
      priority: medium
```

## YAML Schema Fields

### Common Fields (All Tool Types)

| Field | Required | Description |
|-------|----------|-------------|
| `name` | ✅ | Tool name (unique identifier) |
| `description` | ✅ | Brief description of tool purpose |
| `priority` | ✅ | Installation priority: `critical`, `high`, `medium`, `low` |
| `enabled` | ✅ | Whether tool should be installed: `true`/`false` |
| `notes` | ❌ | Additional notes, warnings, or requirements |
| `version` | ❌ | Pin to specific version (default: `latest`) |
| `sha256` | ❌ | Expected SHA256 hash for validation |

### GitHub Release Tools

| Field | Required | Description |
|-------|----------|-------------|
| `source` | ✅ | Source type: `github` or `http` |
| `repo` | ✅ | GitHub repository (owner/repository) |
| `match` | ✅ | Regular expression pattern to match release asset |
| `file_type` | ✅ | File type: `zip`, `exe`, `msi`, `jar` |
| `install_method` | ✅ | Installation method: `extract`, `copy`, `installer` |
| `extract_to` | ⚠️ | Extraction path (required if `install_method: extract`) |
| `copy_to` | ⚠️ | Copy destination (required if `install_method: copy`) |
| `installer_args` | ❌ | Arguments for installer (default: `/quiet /norestart`) |
| `post_install` | ❌ | Post-installation steps (see below) |

### Python Tools

| Field | Required | Description |
|-------|----------|-------------|
| `package` | ✅ | Package name or URL for UV/pip |
| `with` | ❌ | Additional dependencies for UV `--with` flag |
| `category_type` | ✅ | Tool category: `malware-analysis`, `forensics`, etc. |

### Git Repositories

| Field | Required | Description |
|-------|----------|-------------|
| `url` | ✅ | Git repository URL |
| `category_type` | ✅ | Repository category |
| `post_clone` | ❌ | Post-clone operations |

### Node.js Tools

| Field | Required | Description |
|-------|----------|-------------|
| `package` | ✅ | NPM package name |
| `category_type` | ✅ | Tool category |

### Didier Stevens Tools

| Field | Required | Description |
|-------|----------|-------------|
| `name` | ✅ | Script filename |
| `category_type` | ✅ | Tool category |

## Post-Install Actions

The `post_install` field supports various actions:

### Rename Files/Directories

```yaml
post_install:
  - type: rename
    pattern: "${TOOLS}/yara/yara-*"
    target: "yara"
```

### Copy Files

```yaml
post_install:
  - type: copy
    source: "${TOOLS}/tool/bin/tool.exe"
    target: "${TOOLS}/bin/tool.exe"
```

### Remove Files

```yaml
post_install:
  - type: remove
    target: "${TOOLS}/tool/unnecessary.dll"
```

### Add to PATH

```yaml
post_install:
  - type: add_to_path
    path: "${TOOLS}/tool/bin"
```

## Installation Scripts

### Master Installer

Install all tools across all categories:

```powershell
.\resources\download\install-all-tools-v2.ps1 -All
```

Show tool counts:

```powershell
.\resources\download\install-all-tools-v2.ps1 -ShowCounts
```

Dry run to see what would be installed:

```powershell
.\resources\download\install-all-tools-v2.ps1 -All -DryRun
```

### Category-Specific Installation

Install only standard GitHub release tools:

```powershell
.\resources\download\install-all-tools-v2.ps1 -StandardTools
```

Install only Python tools:

```powershell
.\resources\download\install-all-tools-v2.ps1 -PythonTools
```

Install only Git repositories:

```powershell
.\resources\download\install-all-tools-v2.ps1 -GitRepos
```

Install by forensic category:

```powershell
.\resources\download\install-tools.ps1 -Category malware-analysis
```

Install by priority:

```powershell
.\resources\download\install-tools.ps1 -Priority critical
```

### Specialized Installers

Python tools:

```powershell
# Install all Python tools
.\resources\download\install-python-tools-v2.ps1 -All

# Install specific tool
.\resources\download\install-python-tools-v2.ps1 -ToolName binary-refinery

# Install only special install tools
.\resources\download\install-python-tools-v2.ps1 -SpecialOnly
```

Git repositories:

```powershell
# Clone all repositories
.\resources\download\install-git-repos-v2.ps1 -All

# Update existing repositories
.\resources\download\install-git-repos-v2.ps1 -All -Update

# Clone specific repository
.\resources\download\install-git-repos-v2.ps1 -RepoName signature-base

# Filter by category type
.\resources\download\install-git-repos-v2.ps1 -CategoryType detection-rules
```

Node.js tools:

```powershell
# Install all Node.js tools
.\resources\download\install-nodejs-tools-v2.ps1 -All

# Install specific tool
.\resources\download\install-nodejs-tools-v2.ps1 -ToolName box-js
```

Didier Stevens tools:

```powershell
# Install all Didier Stevens tools
.\resources\download\install-didier-stevens-v2.ps1 -All

# Install only main suite
.\resources\download\install-didier-stevens-v2.ps1 -MainOnly

# Install only beta tools
.\resources\download\install-didier-stevens-v2.ps1 -BetaOnly
```

## Advanced Features

### Parallel Installation

Standard tools support parallel downloads:

```powershell
.\resources\download\install-all-tools-v2.ps1 -StandardTools -Parallel -ThrottleLimit 10
```

### Version Management

Check for updates:

```powershell
.\resources\download\install-tools.ps1 -CheckUpdates
```

Approve and install updates:

```powershell
.\resources\download\install-tools.ps1 -ApproveUpdate yara,capa
.\resources\download\install-tools.ps1 -InstallUpdates
```

Show installed versions:

```powershell
.\resources\download\install-tools.ps1 -ShowVersions
```

### Resume Installation

Resume from where a previous installation stopped:

```powershell
.\resources\download\install-tools.ps1 -All -Resume
```

### SHA256 Validation

Validate checksums during installation:

```powershell
.\resources\download\install-tools.ps1 -All -ValidateChecksums
```

## Adding New Tools

### Option 1: Interactive Tool Addition

Use the interactive script:

```powershell
.\resources\download\add-tool.ps1
```

This will guide you through adding a new tool with validation.

### Option 2: Manual YAML Editing

1. Choose the appropriate YAML file based on tool type
2. Add tool definition following the schema
3. Validate YAML syntax
4. Test installation

Example:

```yaml
tools:
  - name: my-new-tool
    description: Description of my tool
    source: github
    repo: owner/my-new-tool
    match: "win64\\.zip$"
    file_type: zip
    install_method: extract
    extract_to: "${TOOLS}/my-new-tool"
    enabled: true
    priority: medium
```

## YAML Parsing

The system supports two parsing modes:

1. **PowerShell-YAML Module** (Preferred):
   ```powershell
   Install-Module -Name powershell-yaml -Force
   ```

2. **Fallback Parser**: Built-in parser for basic YAML structures

## Tool Categories

| Category | File | Tools | Description |
|----------|------|-------|-------------|
| **Active Directory** | active-directory.yaml | 5 | AD analysis and security tools |
| **Binary Utilities** | binary-utilities.yaml | 15 | Binary manipulation tools |
| **Code Editors** | code-editors.yaml | 8 | IDEs and text editors |
| **Data Analysis** | data-analysis.yaml | 14 | Log and data analysis tools |
| **Database Tools** | database-tools.yaml | 3 | Database viewers and tools |
| **Didier Stevens** | didier-stevens-tools.yaml | 102 | Comprehensive analysis suite |
| **Disk Forensics** | disk-forensics.yaml | 9 | Disk and filesystem analysis |
| **Document Analysis** | document-analysis.yaml | 14 | PDF, Office, email analysis |
| **Email Forensics** | email-forensics.yaml | 5 | Email analysis tools |
| **Forensics** | forensics.yaml | 7 | General forensics tools |
| **Ghidra Plugins** | ghidra-plugins.yaml | 5 | Ghidra extensions |
| **Git Repositories** | git-repositories.yaml | 62 | Detection rules, threat intel |
| **Malware Analysis** | malware-analysis.yaml | 11 | Malware analysis tools |
| **Memory Forensics** | memory-forensics.yaml | 9 | Memory dump analysis |
| **Network Analysis** | network-analysis.yaml | 5 | Network traffic analysis |
| **Node.js Tools** | nodejs-tools.yaml | 4 | JavaScript analysis tools |
| **Obsidian Plugins** | obsidian-plugins.yaml | 9 | Obsidian extensions |
| **Python Tools** | python-tools.yaml | 72 | Python-based tools |
| **Reverse Engineering** | reverse-engineering.yaml | 16 | Disassemblers, debuggers |
| **System Utilities** | system-utilities.yaml | 14 | General utilities |
| **Threat Intelligence** | threat-intelligence.yaml | 6 | Threat intel tools |
| **Utilities** | utilities.yaml | 16 | Miscellaneous utilities |
| **Windows Forensics** | windows-forensics.yaml | 22 | Windows-specific forensics |

**Total: 433 tools across 23 categories**

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `${TOOLS}` | Main tools directory | `C:\Users\...\mount\Tools` |
| `${SETUP_PATH}` | Setup/download directory | `C:\Users\...\dfirws\setup` |

## Best Practices

### Tool Definitions

1. **Use descriptive names**: Tool names should be clear and unique
2. **Add comprehensive notes**: Document requirements, dependencies, known issues
3. **Set appropriate priorities**: Use `critical` sparingly, most tools are `high` or `medium`
4. **Test before committing**: Always test new tool definitions
5. **Version pin critical tools**: Pin versions for tools where compatibility matters

### Installation

1. **Start with dry runs**: Use `-DryRun` to verify what will be installed
2. **Use categories**: Install by category for focused setups
3. **Enable parallel downloads**: Use `-Parallel` for faster installation
4. **Check logs**: Review log files in `.\log\` for errors
5. **Validate checksums**: Use `-ValidateChecksums` for security

### Maintenance

1. **Regular updates**: Check for tool updates periodically
2. **Review approvals**: Review and approve updates before installing
3. **Test in sandbox**: Test updates in Windows Sandbox first
4. **Keep YAML clean**: Remove disabled tools, update descriptions
5. **Document changes**: Add notes when modifying tool definitions

## Troubleshooting

### YAML Parsing Errors

```powershell
# Install powershell-yaml module
Install-Module -Name powershell-yaml -Force

# Or rely on fallback parser (limited functionality)
```

### Tool Installation Fails

1. Check log file for specific error
2. Verify GitHub repository and match pattern
3. Check network connectivity
4. Manually download to verify URL
5. Validate YAML syntax

### Version Lock Issues

```powershell
# Clear version cache
.\resources\download\install-tools.ps1 -ClearCache

# Force reinstallation
.\resources\download\install-tools.ps1 -ToolName yara -Force
```

## Migration from v1

The v2 architecture is designed to coexist with v1:

1. **v1 scripts**: Legacy monolithic scripts (still functional)
2. **v2 scripts**: New YAML-based scripts (v2 suffix)

Both can be used, but v2 is recommended for new installations.

## Future Enhancements

- [ ] YAML schema validation with JSON Schema
- [ ] Web UI for tool management
- [ ] Automatic tool discovery
- [ ] Container-based installation option
- [ ] Tool dependency resolution
- [ ] Installation profiles (minimal, standard, full)

## Support

For issues or questions:

- GitHub Issues: <https://github.com/reuteras/dfirws/issues>
- Documentation: <https://github.com/reuteras/dfirws/wiki>
- Migration Guide: MIGRATION_COMPLETE.md

---

**DFIRWS v2** - Making digital forensics tool management simple and maintainable.
