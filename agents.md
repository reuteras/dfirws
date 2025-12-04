# DFIRWS Architecture Documentation

## Download vs Installation Architecture

### Overview

DFIRWS uses a two-phase approach to tool deployment:
1. **Download/Preparation Phase** (runs on HOST)
2. **Installation Phase** (runs in SANDBOX)

This separation ensures that the host system remains clean while preparing all tools for fast sandbox deployment.

### Phase 1: Download/Preparation (HOST)

**Script**: `downloadFiles.ps1`

**Location**: Runs on the host Windows system

**What it does**:
- Downloads tool binaries to `downloads/` directory
- Extracts archives to `mount/Tools/` directory
- Copies executables to appropriate locations in `mount/Tools/`
- Renames/moves files within `mount/Tools/` as needed
- **Does NOT run installers** (MSI/EXE files)

**Why `mount/Tools/`**:
- This directory is mapped to `C:\Tools` inside the Windows Sandbox
- Pre-extracting here means tools are immediately available when sandbox starts
- Significantly speeds up sandbox initialization

**Key Scripts**:
- `resources/download/http.ps1` - Legacy download script with extraction logic
- `resources/download/release.ps1` - GitHub releases download (deprecated on v2)
- `resources/download/winget.ps1` - Winget-based downloads
- `resources/download/install-all-tools-v2.ps1 -DownloadOnly` - V2 YAML system in download mode

### Phase 2: Installation (SANDBOX)

**Script**: `dfirws-install.ps1`

**Location**: Runs inside Windows Sandbox

**What it does**:
- Runs installer files (MSI/EXE) that require actual installation
- Configures Windows-level settings
- Installs system-wide tools (Visual Studio Code, Java, etc.)

**Why separate**:
- Installers modify registry, system directories, and require admin privileges
- These operations should only happen inside the disposable sandbox
- Keeps the host system clean

### V2 YAML System Architecture

#### Download Mode (`-DownloadOnly`)

When `downloadFiles.ps1` calls the v2 system with `-DownloadOnly` flag:

```powershell
.\resources\download\install-all-tools-v2.ps1 -StandardTools -DownloadOnly
```

**Behavior**:
- ✅ Downloads binaries to `downloads/`
- ✅ **Extracts** archives to `mount/Tools/` (install_method: extract)
- ✅ **Copies** executables to `mount/Tools/bin/` (install_method: copy)
- ✅ **Runs post-install steps** (rename, move, etc.)
- ❌ **Skips installers** (install_method: installer)

**Example YAML**:
```yaml
# This WILL run in DownloadOnly mode (extraction to mount/Tools)
- name: ripgrep
  install_method: extract
  extract_to: "${TOOLS}/ripgrep"
  post_install:
    - type: rename
      pattern: "ripgrep-*"
      target: "ripgrep"

# This will be SKIPPED in DownloadOnly mode (installer)
- name: 7zip
  install_method: installer
  installer_args: "/qn /norestart"
```

#### Normal Mode (in Sandbox)

When `dfirws-install.ps1` calls the v2 system WITHOUT `-DownloadOnly`:

```powershell
.\resources\download\install-all-tools-v2.ps1 -StandardTools
```

**Behavior**:
- ✅ Downloads binaries (if not already downloaded)
- ✅ Extracts archives
- ✅ Copies files
- ✅ **Runs installers** (MSI/EXE)
- ✅ Runs all post-install steps

### Install Methods in V2 YAML

#### `install_method: extract`
Extracts archives to a directory in `mount/Tools`.

**Runs in**: DownloadOnly ✅ | Normal ✅

**Example**:
```yaml
- name: sysinternals
  file_type: zip
  install_method: extract
  extract_to: "${TOOLS}/sysinternals"
```

**What happens**:
```powershell
# Runs on HOST during download phase
& "7z.exe" x -aoa downloads/sysinternals.zip -o"mount/Tools/sysinternals"
```

#### `install_method: copy`
Copies a single file to a location in `mount/Tools`.

**Runs in**: DownloadOnly ✅ | Normal ✅

**Example**:
```yaml
- name: fx
  file_type: exe
  install_method: copy
  copy_to: "${TOOLS}/bin/fx.exe"
```

**What happens**:
```powershell
# Runs on HOST during download phase
Copy-Item downloads/fx.exe mount/Tools/bin/fx.exe
```

#### `install_method: installer`
Runs an MSI or EXE installer.

**Runs in**: DownloadOnly ❌ | Normal ✅

**Example**:
```yaml
- name: 7zip
  file_type: msi
  install_method: installer
  installer_args: "/qn /norestart"
```

**What happens**:
```powershell
# Runs ONLY in SANDBOX during installation phase
msiexec /i downloads/7zip.msi /qn /norestart
```

### Post-Install Steps

Post-install steps (rename, copy, move, remove) run for ALL methods including in `-DownloadOnly` mode when the install_method is `extract` or `copy`.

**Common operations**:
```yaml
post_install:
  # Rename version-specific folders to consistent names
  - type: rename
    pattern: "tool-v1.2.3-*"
    target: "tool"

  # Copy executables to bin directory
  - type: copy
    source: "${TOOLS}/tool/tool.exe"
    target: "${TOOLS}/bin/tool.exe"

  # Remove unnecessary files
  - type: remove
    target: "${TOOLS}/tool/readme.txt"
```

### Directory Structure

```
dfirws/
├── downloads/              # Downloaded binaries (not committed)
│   ├── sysinternals.zip
│   ├── vscode.exe
│   └── ...
│
├── mount/                  # Mounted into sandbox as C:\
│   └── Tools/              # Becomes C:\Tools in sandbox
│       ├── bin/            # Executables
│       ├── sysinternals/   # Extracted tools
│       ├── pestudio/
│       └── ...
│
└── resources/
    ├── download/           # Download scripts
    │   ├── http.ps1        # Legacy: Download + extract to mount/Tools
    │   ├── common.ps1      # Shared download functions
    │   ├── tool-handler.ps1    # V2 YAML processor
    │   └── install-all-tools-v2.ps1
    │
    └── tools/              # V2 YAML definitions
        ├── utilities.yaml
        ├── forensics.yaml
        └── ...
```

### Workflow Summary

**On the HOST** (before starting sandbox):
```
downloadFiles.ps1
  └─> http.ps1: Download + extract to mount/Tools
  └─> V2 system with -DownloadOnly:
       └─> Download binaries
       └─> Extract to mount/Tools
       └─> Copy files to mount/Tools
       └─> Skip installers
```

**Result**: `mount/Tools/` contains all pre-extracted tools

**In the SANDBOX** (after sandbox starts):
```
dfirws-install.ps1
  └─> V2 system without -DownloadOnly:
       └─> Run installers (MSI/EXE)
       └─> Configure system settings
```

**Result**: System-wide tools installed (Visual Studio Code, Java, etc.)

### Key Principles

1. **Host stays clean**: No installers run on host, only downloads and extractions
2. **Fast sandbox startup**: Pre-extracted tools in mount/Tools are immediately available
3. **Installers only in sandbox**: MSI/EXE installers run only in disposable sandbox environment
4. **Separation of concerns**: Download logic separate from installation logic

### Migration from Legacy to V2

**Legacy system** (http.ps1, release.ps1):
- Mixed download and extraction in PowerShell scripts
- Special cases hardcoded for each tool
- Difficult to maintain

**V2 YAML system**:
- Declarative tool definitions
- Generic installation logic
- Easy to add new tools
- Clear separation via `-DownloadOnly` flag

**Both systems currently coexist**:
- Legacy scripts handle tools not yet migrated to YAML
- V2 YAML system handles newer tools
- Comments in http.ps1 indicate which tools moved to V2 (e.g., "NOW HANDLED BY V2 YAML")

### Common Gotchas

1. **Don't run installers in download scripts**: Use `-DownloadOnly` mode
2. **Don't skip extraction in DownloadOnly mode**: Tools need to be in mount/Tools
3. **Variables**:
   - `${TOOLS}` = `.\mount\Tools` (on host) or `C:\Tools` (in sandbox)
   - `${SETUP_PATH}` = `.\downloads`
   - `${SANDBOX_TOOLS}` = `C:\Tools` (sandbox only)

4. **File type validation**: The `-check` parameter expects file command output:
   - `"Zip archive data"` (not "zip")
   - `"PE32"` (not "exe")
   - `"Composite Document File V2 Document"` (not "msi")
