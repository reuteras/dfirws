# Agents.md - DFIRWS Project Architecture

This document describes the architecture of the DFIRWS (DFIR in Windows Sandbox) project for AI agents working on the codebase.

## Overview

DFIRWS creates a comprehensive forensic investigation and incident response toolkit that runs in isolated Windows Sandbox environments. The project uses a multi-phase pipeline:

1. **Download phase** (host, online) - Downloads and organizes 400+ tools
2. **Build sandboxes** (temporary, online) - Compile/install tools needing build environments
3. **Final analysis sandbox** (offline) - Isolated DFIR workstation with all tools ready

**Critical constraint**: The final analysis sandbox runs **offline** (no network). All tools must be fully installed or have their files available before the sandbox starts.

## Directory Structure

```text
dfirws/
├── downloadFiles.ps1              # Main entry point - orchestrates all downloads
├── createSandboxConfig.ps1        # Creates .wsb files from templates
├── config.ps1.template            # Template for API keys (GitHub, MaxMind)
│
├── resources/
│   ├── download/                  # Download scripts (one per source category)
│   │   ├── common.ps1             # Shared download functions
│   │   ├── basic.ps1              # Core tools: 7-Zip, Java, Python, .NET
│   │   ├── http.ps1               # ~50 tools via direct HTTP download
│   │   ├── release.ps1            # ~120 tools from GitHub releases
│   │   ├── git.ps1                # ~60 git repository clones
│   │   ├── winget.ps1             # ~26 winget packages
│   │   ├── enrichment.ps1         # Threat intel data (MaxMind, YARA, etc.)
│   │   ├── python.ps1             # Launches Python build sandbox
│   │   ├── rust.ps1               # Launches Rust build sandbox
│   │   ├── go.ps1                 # Launches Go build sandbox
│   │   ├── node.ps1               # Launches Node build sandbox
│   │   ├── zimmerman.ps1          # Eric Zimmerman's .NET forensic tools
│   │   ├── didier.ps1             # Didier Stevens tools
│   │   ├── kape.ps1               # KAPE forensic framework
│   │   ├── msys2.ps1              # MSYS2 build environment
│   │   └── visualstudiobuildtools.ps1
│   │
│   └── templates/                 # Windows Sandbox XML templates
│       ├── dfirws.wsb.template              # Final analysis sandbox (offline)
│       ├── network_dfirws.wsb.template      # Analysis sandbox (online variant)
│       ├── generate_venv.wsb.template       # Python build sandbox
│       ├── generate_golang.wsb.template     # Go build sandbox
│       ├── generate_rust.wsb.template       # Rust build sandbox
│       ├── generate_node.wsb.template       # Node build sandbox
│       ├── generate_msys2.wsb.template      # MSYS2 setup sandbox
│       └── generate_freshclam.wsb.template  # ClamAV DB update sandbox
│
├── setup/
│   ├── shared.ps1                 # New-CreateToolFiles function
│   ├── start_sandbox.ps1          # Runs inside final sandbox at boot
│   ├── install/
│   │   ├── install_python_tools.ps1  # Runs inside Python build sandbox
│   │   ├── install_rust_tools.ps1    # Runs inside Rust build sandbox
│   │   ├── install_golang_tools.ps1  # Runs inside Go build sandbox
│   │   └── install_node.ps1          # Runs inside Node build sandbox
│   └── utils/
│       └── dfirws-install.ps1     # On-demand installer (40+ switches)
│
├── mount/                         # Mapped into sandbox as read-only
│   ├── Tools/                     # Extracted tool binaries
│   ├── git/                       # Cloned repositories
│   └── venv/                      # Python virtual environments
│
├── downloads/                     # Download cache
│   └── dfirws/                    # Generated metadata files
│       ├── tools_*.json           # Tool metadata per source
│       ├── verify_*.ps1           # Auto-generated verification scripts
│       ├── install_*.ps1          # Auto-generated install scripts
│       └── dfirws_folder_*.ps1    # Auto-generated shortcut scripts
│
├── enrichment/                    # Threat intel data (read-only in sandbox)
├── local/                         # User config (mapped into sandbox)
│   └── defaults/                  # Default configs shipped with project
├── scripts/
│   └── generate-tools-docs.py     # Generates wiki from tools_*.json
└── setup/mkdocs/                  # MkDocs site for tool documentation
```

## How Downloads Work

### Download Scripts (resources/download/*.ps1)

Each script follows the same pattern:

1. Source `common.ps1` for shared functions
2. Initialize `$TOOL_DEFINITIONS = @()`
3. Download tools using helper functions:
   - `Get-FileFromUri` - HTTP download with etag caching
   - `Get-GitHubRelease` - GitHub release asset download
   - `Get-DownloadUrlFromPage` - regular expression URL extraction from web pages
4. Extract/organize into `mount/Tools/` or `downloads/`
5. Add `$TOOL_DEFINITIONS += @{ ... }` entry for each tool
6. Call `New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "name"`

### TOOL_DEFINITIONS Entry Format

Every tool has a standardized metadata entry:

```powershell
$TOOL_DEFINITIONS += @{
    Name = "tool-name"
    Homepage = "https://..."
    Vendor = "author"
    License = "MIT License"
    LicenseUrl = "https://..."
    Category = "Category\Subcategory"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Category\tool.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command tool --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{ Type = "command"; Name = "tool.exe"; Expect = "PE32" }
    )
    FileExtensions = @(".ext1", ".ext2")
    Tags = @("tag1", "tag2")
    Notes = "Description of the tool."
    Tips = "Usage tips."
    Usage = "How to use."
    SampleCommands = @("tool --help")
    SampleFiles = @()
    Dependencies = @()          # High-level deps: "msys2", "dotnet6", "Ghidra", etc.
    PythonVersion = $PYTHON_DEFAULT  # Only for Python tools
}
```

### New-CreateToolFiles (setup/shared.ps1)

This function processes TOOL_DEFINITIONS and generates:

- `verify_<source>.ps1` - Verification commands for each tool
- `install_<source>.ps1` - Installation commands
- `dfirws_folder_<source>.ps1` - Desktop shortcut creation commands
- `tools_<source>.json` - Full metadata export (used for wiki generation)

The JSON export includes all fields plus `SourceType` (derived from the `-Source` parameter).

## Build Sandbox Architecture

Tools that need compilation or package installation use temporary build sandboxes.

### Pattern: Download Script + Build Sandbox

```text
resources/download/python.ps1   (host, online)
    │
    ├── Downloads Python installer, uv binary
    ├── Creates generate_venv.wsb from template
    ├── Launches sandbox → runs install_python_tools.ps1
    ├── Waits for mount/venv/default/done signal file
    ├── Copies back from log/dfirws/:
    │   ├── tools_python.json
    │   ├── verify_python.ps1
    │   ├── install_python.ps1
    │   └── dfirws_folder_python.ps1
    └── Cleans up log/dfirws/
```

### Sandbox Template Directory Mappings

Build sandboxes mount directories read-write so the sandbox can write output:

| Host Path | Sandbox Path | Access |
|-----------|-------------|--------|
| `setup/` | `C:\Users\WDAGUtilityAccount\Documents\tools` | Read-only |
| `downloads/` | `C:\downloads` | Read-only |
| `mount/Tools/` | `C:\Tools` | **Read-write** |
| `mount/venv/` | `C:\venv` | **Read-write** |
| `log/` | `C:\log` | **Read-write** |

The final analysis sandbox mounts everything **read-only** except `readwrite/`.

### Copy-Back Pattern

After a build sandbox finishes, the download script copies generated files back:

```powershell
if (Test-Path -Path "${ROOT_PATH}\log\dfirws") {
    Copy-Item "${ROOT_PATH}\log\dfirws\*_python.ps1" "${ROOT_PATH}\downloads\dfirws\" -Force
    Copy-Item "${ROOT_PATH}\log\dfirws\tools_python.json" "${ROOT_PATH}\downloads\dfirws\" -Force
    Remove-Item -Recurse -Force "${ROOT_PATH}\log\dfirws" 2>&1 | Out-Null
}
```

### Current Build Sandboxes

| Sandbox | Install Script | What It Builds | Build Tools |
|---------|---------------|----------------|-------------|
| generate_venv.wsb | install_python_tools.ps1 | 120+ Python packages via uv | Python, uv |
| generate_rust.wsb | install_rust_tools.ps1 | 5 Rust tools via cargo | Rust, msys2 gcc |
| generate_golang.wsb | install_golang_tools.ps1 | 1 Go tool | Go |
| generate_node.wsb | install_node.ps1 | 7 npm packages | Node.js, npm |
| generate_msys2.wsb | install_msys2.ps1 | MSYS2 environment + r2ai plugin | msys2 gcc, pkg-config |
| generate_freshclam.wsb | install_freshclam.ps1 | ClamAV signatures | ClamAV |

### r2ai Compilation in the MSYS2 Sandbox

The r2ai native plugin for radare2 is compiled inside the MSYS2 sandbox:

1. **Prerequisites**: Radare2 (from `release.ps1`) and r2ai source (from `git.ps1`) must be available
2. **Ordering**: `downloadFiles.ps1` runs MSYS2 after `release.ps1` and `git.ps1` so both are ready
3. **Build process** (`install_msys2.ps1`):
   - Copies r2ai source from read-only `C:\git\r2ai\src\` to writable `C:\tmp\r2ai_build\`
   - Sets `PKG_CONFIG_PATH` to point at radare2's pkgconfig files
   - Runs `make DOTEXE=.exe` with msys2's UCRT64 gcc toolchain
   - Saves `r2ai.dll` and `r2ai.exe` to `C:\Tools\msys64\r2ai_build\`
4. **Installation** (`start_sandbox.ps1`):
   - Copies `r2ai.dll` to `%HOME%\.local\share\radare2\plugins\`
   - Copies `r2ai.exe` to `C:\Tools\radare2\bin\`
5. **Conditional**: Build is skipped if radare2 or r2ai source are not available

### Adding a New Build Sandbox

To add a tool that needs compilation:

1. Create `resources/templates/generate_<name>.wsb.template` (copy from existing)
2. Create `setup/install/install_<name>.ps1` (runs inside sandbox)
3. Add launch logic to `resources/download/<name>.ps1` (or existing script)
4. Add copy-back code for generated metadata files
5. The install script should source `shared.ps1` and call `New-CreateToolFiles`

## Final Sandbox (start_sandbox.ps1)

The analysis sandbox runs **offline**. It:

1. Loads config from `C:\local\config.txt`
2. Installs base software from `C:\downloads\` (7-Zip, Java, .NET, etc.)
3. Configures PATH (max 2048 chars on Windows)
4. Copies plugins to user directories (Cutter plugins, decai for radare2, etc.)
5. Runs auto-generated install scripts from `downloads/dfirws/`
6. Creates desktop shortcuts via `dfirws_folder_*.ps1`
7. Runs user customization scripts from `local/`

### Key Sandbox Paths

| Path | Contents |
|------|----------|
| `C:\Tools\` | All extracted tool binaries (read-only) |
| `C:\git\` | Cloned Git repositories (read-only) |
| `C:\venv\` | Python virtual environments (read-only) |
| `C:\downloads\` | Installer cache (read-only) |
| `C:\enrichment\` | Threat intel data (read-only) |
| `C:\local\` | User configuration (read-only) |
| `Desktop\readwrite\` | User working directory (read-write) |

## Documentation Pipeline

```text
TOOL_DEFINITIONS (PowerShell)
    ↓ New-CreateToolFiles
tools_*.json (JSON metadata)
    ↓ scripts/generate-tools-docs.py
setup/mkdocs/docs/tools/*.md (Markdown)
    ↓ mkdocs build
https://reuteras.github.io/dfirws/tools/ (Published wiki)
```

The `generate-tools-docs.py` script:
- Reads all `tools_*.json` files from `downloads/dfirws/`
- Groups tools by category
- Generates per-category index tables (Tool, Source, Description, Tags, File Extensions)
- Generates individual tool detail pages
- Updates `mkdocs.yml` navigation

## Key Conventions

### Dependencies Field

The `Dependencies` field tracks high-level build/runtime dependencies between components:
- `"msys2"` - Needs gcc/g++ from MSYS2
- `"dotnet6"` / `"dotnet9"` - Needs .NET runtime
- `"Ghidra"` - Needs Ghidra installed
- `"openjdk11"` - Needs Java runtime
- `"nodejs"` - Needs Node.js runtime
- `"golang"` - Needs Go runtime
- `"enrichment"` - Needs enrichment databases
- `"Radare2"` - Needs radare2 installed

### PythonVersion Field

Python tools have `PythonVersion = $PYTHON_DEFAULT` (currently 3.11). This prepares for per-tool Python version specification during future upgrades.

### SourceType Field

Automatically set by `New-CreateToolFiles` from the `-Source` parameter. Maps to display labels in the wiki:

| Source | Wiki Label |
|--------|-----------|
| python | Python |
| node | npm |
| rust | Cargo |
| go | Go |
| release | GitHub Release |
| http | HTTP |
| Git | Git |
| winget | Winget |
| zimmerman | .NET |
| enrichment | Enrichment |

## MCP Server Integration

opencode-ai is configured with MCP servers for AI-assisted analysis. Config deployed to `~/.config/opencode/opencode.json` during sandbox startup.

| Server | Type | Status | Notes |
|--------|------|--------|-------|
| GhidrAssistMCP | Remote (SSE) | Extension downloaded | Requires Ghidra running with plugin enabled |
| radare2-mcp (r2mcp) | Local (stdio) | Binary downloaded | Known Windows crash issue (#24) |
| regipy MCP | Local (stdio) | Repository cloned + mcp pkg | Uses regipy venv Python |
| decai | radare2 plugin | JS file copied | Loaded by radare2 directly (not MCP) |
| r2ai | radare2 plugin | Compiled in MSYS2 sandbox | Native C plugin, r2ai.dll + r2ai.exe |

### MCP Configuration

Default config at `local/defaults/opencode.json` - all servers disabled by default.
Users override by placing `opencode.json` in `local/`.
