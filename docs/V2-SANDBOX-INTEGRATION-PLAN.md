# V2 Sandbox Integration Plan

## Overview

This document outlines the plan to integrate Windows Sandbox execution into the v2 YAML-based architecture, ensuring parity with the legacy implementation's security model.

## Current State

### Legacy Approach (Sandbox-Based)

The legacy scripts run installations in Windows Sandbox for isolation:

| Tool Type | Host Script | Sandbox Template | Sandbox Runner |
|-----------|-------------|------------------|----------------|
| **Python** | `python.ps1` | `generate_venv.wsb.template` | `setup/install/install_python_tools.ps1` |
| **Node.js** | `node.ps1` | `generate_node.wsb.template` | `setup/install/install_node.ps1` |
| **Rust** | `rust.ps1` | `generate_rust.wsb.template` | `setup/install/install_rust_tools.ps1` |
| **Go** | `go.ps1` | `generate_golang.wsb.template` | `setup/install/install_golang_tools.ps1` |
| **MSYS2** | `msys2.ps1` | `generate_msys2.wsb.template` | `setup/install/install_msys2.ps1` |

**How Legacy Works:**
1. Host script reads templates and creates `.wsb` configuration
2. Windows Sandbox starts with mapped folders
3. Sandbox runner script executes inside sandbox
4. Creates a "done" file when finished
5. Host script waits for "done" file via `Wait-Sandbox`
6. Results synced back using `rclone`

### V2 Approach (Currently Direct Host)

The v2 scripts currently run installations directly on the host:

| Tool Type | Orchestrator | Installer | Execution |
|-----------|-------------|-----------|-----------|
| **Python** | `install-all-tools-v2.ps1` | `install-python-tools-v2.ps1` | Direct `uv tool install` |
| **Node.js** | `install-all-tools-v2.ps1` | `install-nodejs-tools-v2.ps1` | Direct `npm install -g` |
| **Rust** | Not migrated yet | - | - |
| **Go** | Not migrated yet | - | - |

**Issue #132 Problem:**
- V2 runs installations directly on host (no sandbox isolation)
- Legacy runs installations in Windows Sandbox (secure isolation)
- User requests v2 to use sandbox like legacy

## Languages/Tools Requiring Sandbox

Based on legacy implementation:

1. ✅ **Python** - Uses `uv tool install` (72 packages)
2. ✅ **Node.js** - Uses `npm install -g` (4 packages)
3. ⏳ **Rust** - Uses `cargo install` (4 tools: dfir-toolkit, usnjrnl, CuTE-tui, SSHniff)
4. ⏳ **Go** - Uses `go install` (1 tool: protodump)
5. ⏳ **MSYS2** - Uses `pacman -S` (various Unix tools)

## Implementation Plan

### Design Decision: Sandbox is Mandatory

**Security-first approach:** All Python, Node.js, Rust, Go, and MSYS2 installations **MUST** run in Windows Sandbox. No optional parameters, no bypass flags.

**Rationale:**
- DFIR tools analyze malware - extra isolation is non-negotiable
- Supply chain attacks are real threats
- Consistent security model across all tool types
- Matches legacy architecture security design

### Phase 1: Replace Direct Installation with Sandbox

#### 1.1 Refactor V2 Installers to Use Sandbox

**Files to modify:**
- `resources/download/install-python-tools-v2.ps1`
- `resources/download/install-nodejs-tools-v2.ps1`

**Changes:**
```powershell
# Remove all direct installation logic
# Replace with sandbox orchestrator call

param(
    [Parameter(HelpMessage = "Install all Python tools")]
    [Switch]$All,

    [Parameter(HelpMessage = "Install specific tool by name")]
    [string]$ToolName,

    [Parameter(HelpMessage = "Dry run - show what would be done")]
    [Switch]$DryRun
)

# All installations go through sandbox
& ".\resources\download\sandbox\run-python-sandbox-v2.ps1" @PSBoundParameters
```

#### 1.2 Create V2 Sandbox Orchestrators

Create new sandbox orchestrator scripts:

**New files:**
- `resources/download/sandbox/run-python-sandbox-v2.ps1`
- `resources/download/sandbox/run-nodejs-sandbox-v2.ps1`

**Responsibilities:**
- Create `.wsb` configuration from template
- Start Windows Sandbox
- Wait for completion (monitor "done" file)
- Sync results back to host

#### 1.3 Create V2 Sandbox Runner Scripts

Create scripts that run **inside** the sandbox:

**New files:**
- `setup/install/install_python_tools_v2.ps1`
- `setup/install/install_node_tools_v2.ps1`

**Responsibilities:**
- Import YAML parser and common functions
- Read YAML tool definitions from mapped folder
- Install tools using same logic as v2 installers
- Create "done" file when finished

#### 1.4 Create V2 Sandbox Templates

Create Windows Sandbox configuration templates:

**New files:**
- `resources/templates/generate_venv_v2.wsb.template`
- `resources/templates/generate_node_v2.wsb.template`

**Template structure:**
```xml
<Configuration>
  <VGpu>Disable</VGpu>
  <Networking>Default</Networking>
  <ProtectedClient>Enable</ProtectedClient>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>__SANDBOX__resources</HostFolder>
      <SandboxFolder>C:\resources</SandboxFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
    <MappedFolder>
      <HostFolder>__SANDBOX__mount\venv</HostFolder>
      <SandboxFolder>C:\venv</SandboxFolder>
      <ReadOnly>false</ReadOnly>
    </MappedFolder>
    <!-- ... other mapped folders ... -->
  </MappedFolders>
  <LogonCommand>
    <Command>powershell -executionpolicy unrestricted -File C:\setup\install_python_tools_v2.ps1</Command>
  </LogonCommand>
</Configuration>
```

### Phase 2: Integrate with Main Entry Point

#### 2.1 Update downloadFiles.ps1

No changes needed - sandbox is transparent to callers:

```powershell
# Existing code works as-is
if ($all -or $Python.IsPresent) {
    Write-Output "" > .\log\python.txt
    Write-DateLog "Setup Python and install packages (v2 YAML-based with Sandbox)."
    .\resources\download\install-all-tools-v2.ps1 -PythonTools
}
```

#### 2.2 Update install-all-tools-v2.ps1

No changes needed - installers handle sandbox internally:

```powershell
# Existing code works as-is
if ($installPython) {
    Write-DateLog "Starting Python Tools installation (in Sandbox)" >> ${ROOT_PATH}\log\install_all_v2.txt
    $params = @{ All = $true }
    if ($DryRun) { $params.DryRun = $true }
    & ".\resources\download\install-python-tools-v2.ps1" @params
}
```

### Phase 3: Extend to Other Tools (Optional)

Create v2 YAML-based installers for:

1. **Rust tools** (rust-tools.yaml + install-rust-tools-v2.ps1)
2. **Go tools** (go-tools.yaml + install-go-tools-v2.ps1)
3. **MSYS2 packages** (msys2-packages.yaml + install-msys2-v2.ps1)

## Directory Structure

```
dfirws/
├── resources/
│   ├── download/
│   │   ├── install-python-tools-v2.ps1        # Modified: add -UseSandbox
│   │   ├── install-nodejs-tools-v2.ps1        # Modified: add -UseSandbox
│   │   ├── install-all-tools-v2.ps1           # Modified: pass -UseSandbox
│   │   └── sandbox/                           # NEW DIRECTORY
│   │       ├── run-python-sandbox-v2.ps1      # NEW: Python sandbox orchestrator
│   │       └── run-nodejs-sandbox-v2.ps1      # NEW: Node.js sandbox orchestrator
│   ├── templates/
│   │   ├── generate_venv_v2.wsb.template      # NEW: Python v2 template
│   │   └── generate_node_v2.wsb.template      # NEW: Node.js v2 template
│   └── tools/
│       ├── python-tools.yaml                  # Existing YAML definitions
│       └── nodejs-tools.yaml                  # Existing YAML definitions
├── setup/
│   └── install/
│       ├── install_python_tools_v2.ps1        # NEW: Runs inside sandbox
│       └── install_node_tools_v2.ps1          # NEW: Runs inside sandbox
└── downloadFiles.ps1                          # Modified: add -UseSandbox
```

## Benefits

1. ✅ **Security**: Sandbox isolation prevents malicious packages from compromising host
2. ✅ **Consistency**: V2 matches legacy security model perfectly
3. ✅ **YAML-based**: Maintains v2 architecture advantages
4. ✅ **Simplicity**: No confusing parameters - sandbox always on
5. ✅ **Testability**: Dry-run works in sandbox mode

## Considerations

### Performance
- **Sandbox startup**: ~10-30 seconds overhead per tool type
- **Tradeoff**: Security vs speed
- **Decision**: Security wins - this is a DFIR toolkit

### Compatibility
- **Requires**: Windows 11 Pro/Enterprise or later (Sandbox feature)
- **Home editions**: Not supported (same as legacy)
- **Note**: DFIRWS is primarily for professional DFIR work

### No Backwards Compatibility Needed
- Direct installation was a mistake in v2
- V2 should have used sandbox from day one
- Remove direct installation code entirely

## Testing Plan

1. **Unit Tests**: Test YAML parsing in sandbox environment
2. **Integration Tests**: Full installation in sandbox for Python/Node.js
3. **Comparison Tests**: Verify sandbox results match direct installation
4. **Performance Tests**: Measure sandbox overhead

## Migration Path

1. ✅ Phase 1.1-1.4: Implement sandbox support (Python + Node.js)
2. ✅ Phase 2.1-2.2: Integrate with main entry point
3. ⏳ Phase 3: Extend to Rust, Go, MSYS2 (optional)
4. ⏳ Testing and validation
5. ⏳ Documentation updates
6. ⏳ Deprecate legacy scripts

## Timeline Estimate

- **Phase 1**: 2-3 days (sandbox infrastructure)
- **Phase 2**: 1 day (integration)
- **Phase 3**: 2-3 days (optional extension)
- **Testing**: 1-2 days
- **Total**: ~6-10 days for full implementation

## Success Criteria

- ✅ Python tools install successfully in sandbox using YAML
- ✅ Node.js tools install successfully in sandbox using YAML
- ✅ Results match legacy sandbox behavior
- ✅ Dry-run mode works in sandbox
- ✅ Performance acceptable (<2 min overhead per tool type)
- ✅ Documentation complete and clear

## Related Issues

- **Issue #132**: Complete v2 integration: Add Python and Node.js tools
- **Issue #130**: V2 integration main tracking issue
