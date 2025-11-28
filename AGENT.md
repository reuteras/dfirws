# DFIRWS Agent Instructions

This document provides guidance for AI assistants (like Claude) working on the DFIRWS project. It contains context about the project architecture, completed work, and best practices for making changes.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture Summary](#architecture-summary)
- [What Has Been Done](#what-has-been-done)
- [Directory Structure](#directory-structure)
- [Key Files and Their Purposes](#key-files-and-their-purposes)
- [Common Tasks](#common-tasks)
- [YAML Tool Definition Standards](#yaml-tool-definition-standards)
- [Installation Script Conventions](#installation-script-conventions)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Git Workflow](#git-workflow)
- [Troubleshooting](#troubleshooting)

---

## Project Overview

**DFIRWS (Digital Forensics and Incident Response in Windows Sandbox)** is a comprehensive toolkit for DFIR work that runs in Windows Sandbox or VMs. The project provides automated installation and management of 433+ forensics, malware analysis, and security tools.

### Key Goals
1. **Ease of Use**: One-command installation of all tools
2. **Reproducibility**: Sandbox-based, isolated environment
3. **Maintainability**: Modular YAML-based architecture
4. **Completeness**: Comprehensive tool coverage across all DFIR domains

### Current Version
- **v2 Architecture**: YAML-based, modular tool management
- **v1 Architecture**: Legacy monolithic PowerShell scripts (still functional)

---

## Architecture Summary

### v2 Architecture (Current - Recommended)

```text
YAML Tool Definitions (resources/tools/*.yaml)
    ↓
YAML Parser (resources/download/yaml-parser.ps1)
    ↓
Specialized Installers (install-*-v2.ps1)
    ↓
Master Orchestrator (install-all-tools-v2.ps1)
    ↓
Tools Installed in Windows Sandbox
```

### Tool Categories

| Category | File | Tools | Type |
|----------|------|-------|------|
| Standard Tools | 19 YAML files | 193 | GitHub releases |
| Python Tools | python-tools.yaml | 72 | UV/pip packages |
| Git Repositories | git-repositories.yaml | 62 | Git clones |
| Didier Stevens | didier-stevens-tools.yaml | 102 | Direct downloads |
| Node.js Tools | nodejs-tools.yaml | 4 | npm packages |
| **TOTAL** | **23 files** | **433** | **5 methods** |

---

## What Has Been Done

### ✅ Phase 1: Foundation (Completed)
- Created modular YAML schema for tool definitions
- Implemented validation framework
- Built interactive tool addition script (`add-tool.ps1`)
- Added version pinning and SHA256 validation support

### ✅ Phase 2: Batch Migrations (Completed)
- **Batch 1**: Core forensics tools (30 tools)
- **Batch 2**: Windows forensics & utilities (46 tools)
- **Batch 3**: Binary analysis & reverse engineering (45 tools)
- **Batch 4**: Specialized categories (70 tools)

### ✅ Phase 3: Final Migration (Completed)
- Created `python-tools.yaml` (72 Python packages)
- Created `git-repositories.yaml` (62 Git repos)
- Created `nodejs-tools.yaml` (4 Node.js packages)
- Created `didier-stevens-tools.yaml` (102 scripts)
- Added final 3 tools (yara-x, DIE-engine, capa-rules)
- **100% migration complete - All 433 tools**

### ✅ Phase 4: Installation Infrastructure (Completed)
- Created `yaml-parser.ps1` for YAML parsing
- Created `install-python-tools-v2.ps1`
- Created `install-git-repos-v2.ps1`
- Created `install-nodejs-tools-v2.ps1`
- Created `install-didier-stevens-v2.ps1`
- Created `install-all-tools-v2.ps1` (master orchestrator)

### ✅ Phase 5: Documentation (Completed)
- Created `MIGRATION_COMPLETE.md` (migration summary)
- Created `docs/YAML_ARCHITECTURE.md` (500+ line guide)
- Updated `README.md` with v2 section
- Created this `AGENT.md` file

---

## Directory Structure

```text
dfirws/
├── README.md                           # Main project documentation
├── AGENT.md                            # This file - AI assistant guide
├── MIGRATION_COMPLETE.md               # v2 migration summary
├── ROADMAP.md                          # Project roadmap and future plans
│
├── docs/
│   └── YAML_ARCHITECTURE.md           # Complete v2 architecture guide
│
├── resources/
│   ├── tools/                          # YAML tool definitions (v2)
│   │   ├── active-directory.yaml      # 5 AD tools
│   │   ├── binary-utilities.yaml      # 15 binary tools
│   │   ├── code-editors.yaml          # 8 editors/IDEs
│   │   ├── data-analysis.yaml         # 14 analysis tools
│   │   ├── database-tools.yaml        # 3 database tools
│   │   ├── didier-stevens-tools.yaml  # 102 Didier Stevens scripts
│   │   ├── disk-forensics.yaml        # 9 disk analysis tools
│   │   ├── document-analysis.yaml     # 14 document tools
│   │   ├── email-forensics.yaml       # 5 email tools
│   │   ├── forensics.yaml             # 7 general forensics
│   │   ├── ghidra-plugins.yaml        # 5 Ghidra plugins
│   │   ├── git-repositories.yaml      # 62 Git repos
│   │   ├── malware-analysis.yaml      # 11 malware tools
│   │   ├── memory-forensics.yaml      # 9 memory tools
│   │   ├── network-analysis.yaml      # 5 network tools
│   │   ├── nodejs-tools.yaml          # 4 Node.js packages
│   │   ├── obsidian-plugins.yaml      # 9 Obsidian plugins
│   │   ├── python-tools.yaml          # 72 Python packages
│   │   ├── reverse-engineering.yaml   # 16 RE tools
│   │   ├── system-utilities.yaml      # 14 utilities
│   │   ├── threat-intelligence.yaml   # 6 threat intel tools
│   │   ├── utilities.yaml             # 16 misc utilities
│   │   └── windows-forensics.yaml     # 22 Windows tools
│   │
│   └── download/                       # Installation scripts
│       ├── common.ps1                  # Common PowerShell functions
│       ├── yaml-parser.ps1             # YAML parsing module (v2)
│       ├── tool-handler.ps1            # Tool installation handler (v2)
│       ├── state-manager.ps1           # Installation state tracking
│       ├── version-manager.ps1         # Version management
│       │
│       ├── install-tools.ps1           # Standard tool installer (v2)
│       ├── install-python-tools-v2.ps1 # Python tools installer
│       ├── install-git-repos-v2.ps1    # Git repos installer
│       ├── install-nodejs-tools-v2.ps1 # Node.js tools installer
│       ├── install-didier-stevens-v2.ps1 # Didier Stevens installer
│       ├── install-all-tools-v2.ps1    # Master orchestrator
│       │
│       ├── add-tool.ps1                # Interactive tool addition
│       └── [legacy v1 scripts]         # Original monolithic scripts
│
├── setup/                              # Sandbox setup scripts
│   ├── install/                        # Installation scripts for sandbox
│   └── utils/                          # Utility scripts
│
├── local/                              # Local configuration (gitignored)
│   └── defaults/                       # Default configurations
│
└── mount/                              # Mount point for tools (gitignored)
    ├── Tools/                          # Installed tools
    └── git/                            # Cloned Git repositories
```

---

## Key Files and Their Purposes

### YAML Tool Definitions (`resources/tools/*.yaml`)

These files define all tools in a structured format. Each YAML file represents a category.

**Standard Tool Format:**
```yaml
tools:
  - name: tool-name
    description: Tool description
    source: github
    repo: owner/repo
    match: "pattern\\.zip$"
    file_type: zip
    install_method: extract
    extract_to: "${TOOLS}/tool-name"
    enabled: true
    priority: high
```

### Installation Scripts (`resources/download/*.ps1`)

**v2 Scripts (Current):**
- `yaml-parser.ps1` - Parses YAML files, supports multiple formats
- `install-tools.ps1` - Standard GitHub release tools
- `install-python-tools-v2.ps1` - Python packages via UV
- `install-git-repos-v2.ps1` - Git repository cloning
- `install-nodejs-tools-v2.ps1` - Node.js packages via npm
- `install-didier-stevens-v2.ps1` - Didier Stevens scripts
- `install-all-tools-v2.ps1` - Master installer (orchestrates all)

**Supporting Modules:**
- `common.ps1` - Shared functions (Get-GitHubRelease, Get-FileFromUri, etc.)
- `tool-handler.ps1` - Tool installation logic
- `state-manager.ps1` - Installation state tracking
- `version-manager.ps1` - Version pinning and updates

### Documentation

- `README.md` - Main project documentation
- `MIGRATION_COMPLETE.md` - Migration summary and statistics
- `docs/YAML_ARCHITECTURE.md` - Complete architecture guide
- `AGENT.md` - This file
- `ROADMAP.md` - Project roadmap

---

## Common Tasks

### Task 1: Add a New Tool to an Existing Category

**Option A: Interactive (Recommended)**
```powershell
.\resources\download\add-tool.ps1
```

**Option B: Manual**

1. Identify the correct YAML file in `resources/tools/`
2. Add tool definition following the schema
3. Validate YAML syntax
4. Test installation:
   ```powershell
   .\resources\download\install-tools.ps1 -ToolName new-tool -DryRun
   ```

**Example Addition to `malware-analysis.yaml`:**
```yaml
tools:
  # ... existing tools ...

  # New Tool - Add at appropriate alphabetical position
  - name: new-analysis-tool
    description: Brief description of what it does
    source: github
    repo: owner/new-analysis-tool
    match: "win64\\.zip$"
    file_type: zip
    install_method: extract
    extract_to: "${TOOLS}/new-analysis-tool"
    enabled: true
    priority: medium
    notes: Any special requirements or notes
```

### Task 2: Update a Tool's GitHub Repository Reference

1. Locate the tool in the appropriate YAML file
2. Update the `repo` field
3. Verify the `match` pattern still works with new repo's release assets
4. Test:
   ```powershell
   .\resources\download\install-tools.ps1 -ToolName tool-name -DryRun
   ```

**Example:**
```yaml
# Before
repo: oldowner/tool

# After
repo: newowner/tool
```

### Task 3: Add Version Pinning to a Tool

Add `version` and optionally `sha256` fields:

```yaml
tools:
  - name: yara
    # ... other fields ...
    version: "4.3.2"
    sha256: "abc123def456..."
```

### Task 4: Add a Python Package

Add to `resources/tools/python-tools.yaml`:

**Standard package:**
```yaml
tools:
  - name: new-python-tool
    package: new-python-tool
    description: Tool description
    category_type: malware-analysis
    priority: medium
```

**Package with dependencies:**
```yaml
special_installs:
  - name: complex-tool
    package: "complex-tool[extra]"
    description: Tool with special dependencies
    priority: high
    with: "dependency1>=1.0, dependency2"
```

### Task 5: Add a Git Repository

Add to `resources/tools/git-repositories.yaml`:

```yaml
repositories:
  - name: new-repo
    url: "https://github.com/owner/new-repo.git"
    description: Repository description
    category_type: detection-rules
    priority: high
    notes: Any special notes
```

### Task 6: Disable a Tool

Set `enabled: false` in the YAML file:

```yaml
tools:
  - name: problematic-tool
    # ... other fields ...
    enabled: false
    notes: Disabled due to compatibility issues
```

### Task 7: Create a New Tool Category

1. Create new YAML file: `resources/tools/new-category.yaml`
2. Follow the standard schema:

```yaml
schema_version: "1.0"
category: new-category
description: Description of this category

tools:
  - name: first-tool
    description: Tool description
    source: github
    repo: owner/first-tool
    match: "win64\\.zip$"
    file_type: zip
    install_method: extract
    extract_to: "${TOOLS}/first-tool"
    enabled: true
    priority: high
```

3. Tools will automatically be picked up by `install-tools.ps1`

### Task 8: Update Documentation

When making significant changes:

1. Update `docs/YAML_ARCHITECTURE.md` if schema changes
2. Update `README.md` if user-facing functionality changes
3. Update `ROADMAP.md` if completing roadmap items
4. Update tool counts in documentation:
   ```powershell
   .\resources\download\install-all-tools-v2.ps1 -ShowCounts
   ```

---

## YAML Tool Definition Standards

### Required Fields (All Tools)

```yaml
- name: tool-name           # Unique identifier, lowercase, hyphens
  description: "..."        # Clear, concise description
  priority: high            # critical, high, medium, low
  enabled: true             # true or false
```

### GitHub Release Tools

```yaml
- name: tool-name
  description: "Tool description"
  source: github
  repo: owner/repo
  match: "pattern.*\\.zip$"     # Regex for release asset
  file_type: zip                # zip, exe, msi, jar, war
  install_method: extract       # extract, copy, installer
  extract_to: "${TOOLS}/tool"   # Use ${TOOLS} variable
  enabled: true
  priority: high
```

### Installation Methods

**Extract (most common):**
```yaml
install_method: extract
extract_to: "${TOOLS}/tool-name"
```

**Copy (single file):**
```yaml
install_method: copy
copy_to: "${TOOLS}/bin/tool.exe"
```

**Installer (MSI/EXE):**
```yaml
install_method: installer
installer_args: "/quiet /norestart"
```

### Post-Install Actions

```yaml
post_install:
  - type: rename
    pattern: "${TOOLS}/tool/tool-*"
    target: "tool"

  - type: copy
    source: "${TOOLS}/tool/bin/tool.exe"
    target: "${TOOLS}/bin/tool.exe"

  - type: remove
    target: "${TOOLS}/tool/unnecessary.dll"

  - type: add_to_path
    path: "${TOOLS}/tool/bin"
```

### Priority Guidelines

- **critical**: Essential tools needed for basic functionality (YARA, volatility)
- **high**: Commonly used tools, core capabilities (sleuthkit, autopsy)
- **medium**: Specialized tools, nice-to-have (specific parsers)
- **low**: Rarely used, experimental, or redundant tools

### Category Types

Standard categories:
- `forensics`, `malware-analysis`, `reverse-engineering`
- `memory-forensics`, `disk-forensics`, `windows-forensics`
- `document-analysis`, `email-forensics`, `network-analysis`
- `threat-intelligence`, `active-directory`, `data-analysis`
- `utilities`, `binary-analysis`, `detection-rules`

---

## Installation Script Conventions

### Naming Convention

- **v2 scripts**: Use `-v2` suffix (e.g., `install-python-tools-v2.ps1`)
- **Legacy scripts**: No suffix (maintained for compatibility)

### Parameter Standards

All installer scripts should support:

```powershell
-All           # Install all tools in category
-DryRun        # Show what would be done without doing it
-ToolName      # Install specific tool by name
```

Category-specific parameters:
```powershell
-Category      # Filter by category
-Priority      # Filter by priority
-Parallel      # Enable parallel downloads (where supported)
```

### Logging Standards

All installers should:
1. Create log file in `.\log\` directory
2. Use `Write-DateLog` function from `common.ps1`
3. Log start, progress, and completion
4. Include statistics summary

**Example:**
```powershell
Write-DateLog "Starting installation" > ${ROOT_PATH}\log\script.txt
# ... installation logic ...
Write-DateLog "Successfully installed: $toolName" >> ${ROOT_PATH}\log\script.txt
```

### Error Handling

```powershell
try {
    # Installation logic
    if ($result) {
        Write-DateLog "Success: $toolName"
        return $true
    } else {
        Write-DateLog "Failed: $toolName"
        return $false
    }
} catch {
    Write-DateLog "Error: $toolName - $_"
    return $false
}
```

---

## Testing Guidelines

### Before Committing Changes

1. **Syntax Validation**
   ```powershell
   # Check YAML syntax
   Get-Content resources/tools/category.yaml | ConvertFrom-Yaml

   # Check PowerShell syntax
   Get-Command .\resources\download\script.ps1 -Syntax
   ```

2. **Dry Run Test**
   ```powershell
   .\resources\download\install-tools.ps1 -ToolName new-tool -DryRun
   ```

3. **Actual Installation Test**
   ```powershell
   # Test in Windows Sandbox or VM
   .\resources\download\install-tools.ps1 -ToolName new-tool
   ```

4. **Verify Tool Counts**
   ```powershell
   .\resources\download\install-all-tools-v2.ps1 -ShowCounts
   ```

### Test Categories

- **Unit Tests**: Individual tool installation
- **Integration Tests**: Category installation
- **End-to-End Tests**: Full installation via `install-all-tools-v2.ps1`

### Common Test Scenarios

1. Fresh installation
2. Update existing installation
3. Resume interrupted installation
4. Version pinning
5. SHA256 validation
6. Parallel downloads
7. Error recovery

---

## Documentation Standards

### When to Update Documentation

Update documentation when:
- Adding new features
- Changing existing functionality
- Adding/removing tool categories
- Modifying YAML schema
- Changing installation procedures

### Documentation Checklist

- [ ] Update `docs/YAML_ARCHITECTURE.md` for schema changes
- [ ] Update `README.md` for user-facing changes
- [ ] Update `ROADMAP.md` for completed features
- [ ] Update tool counts in all documentation
- [ ] Add examples for new features
- [ ] Update this `AGENT.md` for architectural changes

### Writing Style

- Use clear, concise language
- Provide code examples for all procedures
- Include both success and failure examples
- Use tables for comparisons
- Add notes/warnings where appropriate
- Keep line length reasonable for readability

---

## Git Workflow

### Branch Naming

- Feature branches: `feature/description`
- Bug fixes: `fix/issue-description`
- Claude sessions: `claude/task-description-sessionid`

### Commit Message Format

```text
Brief summary (50 chars or less)

Detailed explanation of changes:
- What was changed
- Why it was changed
- How it was tested

Relevant issue numbers: #123
```

**Example:**

```text
Add support for container-based tools

This commit adds new YAML fields for Docker/Podman container tools:
- container_image: Image name and tag
- container_cmd: Command to run in container
- container_volumes: Volume mounts

Tested with sample container tools in malware-analysis.yaml

Related to #456 - Container support feature request
```

### Before Pushing

1. Verify all changes are intentional
2. Check for sensitive data (tokens, passwords)
3. Run syntax validation
4. Update relevant documentation
5. Test in Windows Sandbox if possible

### Pushing to Remote

```powershell
git add <files>
git commit -m "Descriptive message"
git push -u origin <branch-name>
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: YAML Parsing Errors

**Symptom**: Script fails with YAML parse errors

**Solution:**
1. Check YAML syntax (indentation, quotes, special characters)
2. Install powershell-yaml module:
   ```powershell
   Install-Module -Name powershell-yaml -Force
   ```
3. Test parsing:
   ```powershell
   Get-Content resources/tools/file.yaml | ConvertFrom-Yaml
   ```

#### Issue: Tool Installation Fails

**Symptom**: Tool fails to download or install

**Solution:**
1. Check log file in `.\log\` directory
2. Verify GitHub repo and release pattern:
   ```powershell
   # Check releases manually
   gh release list --repo owner/repo
   ```
3. Test with dry run:
   ```powershell
   .\resources\download\install-tools.ps1 -ToolName tool -DryRun
   ```
4. Verify network connectivity
5. Check GitHub rate limits

#### Issue: GitHub Rate Limit

**Symptom**: "API rate limit exceeded" errors

**Solution:**
1. Ensure GitHub token is configured in `config.ps1`
2. Check token validity
3. Wait for rate limit reset
4. Use authenticated requests

#### Issue: Version Lock Conflicts

**Symptom**: Tools won't update despite new version available

**Solution:**
```powershell
# Clear version cache
.\resources\download\install-tools.ps1 -ClearCache

# Force reinstallation
.\resources\download\install-tools.ps1 -ToolName tool -Force
```

#### Issue: Tool Count Mismatch

**Symptom**: Documented tool count doesn't match actual

**Solution:**
```powershell
# Regenerate counts
.\resources\download\install-all-tools-v2.ps1 -ShowCounts

# Update documentation with correct counts
```

---

## Best Practices for AI Agents

### DO ✅

1. **Read existing code** before making changes
2. **Follow established patterns** in the codebase
3. **Test changes** with dry run mode
4. **Update documentation** when making changes
5. **Use descriptive commit messages** with details
6. **Ask clarifying questions** if requirements are unclear
7. **Provide examples** when suggesting changes
8. **Check for existing functionality** before adding new features
9. **Keep YAML files organized** alphabetically within categories
10. **Update tool counts** in documentation after changes

### DON'T ❌

1. **Don't break existing functionality** without discussion
2. **Don't commit untested changes**
3. **Don't ignore error handling**
4. **Don't use hardcoded paths** (use ${TOOLS}, ${SETUP_PATH} variables)
5. **Don't duplicate functionality** that exists elsewhere
6. **Don't skip documentation updates**
7. **Don't make assumptions** about user environment
8. **Don't commit sensitive data** (tokens, passwords)
9. **Don't change v1 scripts** without understanding impact
10. **Don't modify multiple unrelated things** in single commit

### When in Doubt

1. Refer to existing examples in the codebase
2. Check `docs/YAML_ARCHITECTURE.md` for schema reference
3. Review `MIGRATION_COMPLETE.md` for context
4. Test in Windows Sandbox before committing
5. Ask the user for clarification

---

## Quick Reference

### File Locations

| Item | Path |
|------|------|
| Tool definitions | `resources/tools/*.yaml` |
| Installation scripts | `resources/download/*.ps1` |
| Documentation | `docs/`, `*.md` files |
| Logs | `.\log\*.txt` |

### Common Commands

```powershell
# Show all tools
.\resources\download\install-all-tools-v2.ps1 -ShowCounts

# Install all tools
.\resources\download\install-all-tools-v2.ps1 -All

# Dry run
.\resources\download\install-all-tools-v2.ps1 -All -DryRun

# Install category
.\resources\download\install-tools.ps1 -Category malware-analysis

# Add new tool (interactive)
.\resources\download\add-tool.ps1

# Check for updates
.\resources\download\install-tools.ps1 -CheckUpdates

# Show installed versions
.\resources\download\install-tools.ps1 -ShowVersions
```

### YAML Field Quick Reference

```yaml
# Minimal GitHub release tool
- name: tool-name
  description: "Description"
  source: github
  repo: owner/repo
  match: "pattern\\.zip$"
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/tool"
  enabled: true
  priority: high

# With version pinning
  version: "1.2.3"
  sha256: "abc123..."

# With post-install
  post_install:
    - type: rename
      pattern: "pattern"
      target: "target"
```

---

## Additional Resources

- **Main Documentation**: `README.md`
- **Architecture Guide**: `docs/YAML_ARCHITECTURE.md`
- **Migration Details**: `MIGRATION_COMPLETE.md`
- **Future Plans**: `ROADMAP.md`
- **GitHub Wiki**: <https://github.com/reuteras/dfirws/wiki>
- **Issues**: <https://github.com/reuteras/dfirws/issues>

---

## Version History

- **v1.0** (2025-11-05): Initial creation
  - Documented v2 architecture
  - Added common tasks
  - Provided troubleshooting guide
  - Established best practices

---

**Remember**: The goal is to make DFIR tool management simple, maintainable, and reliable. Always prioritize user experience and system stability when making changes.

For questions or clarifications, consult existing documentation or ask the user directly.
