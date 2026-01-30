# Tool Registry (Option B)

This document describes a minimal-change approach for centralizing tool definitions in one place while keeping existing scripts. The goal is to define each tool once and have downloads, installs, shortcuts, verification, startup items, and notes driven from that definition.

## Goals

- One source of truth for each tool.
- Minimal disruption to existing scripts and flows.
- Incremental rollout (migrate tools gradually).

## Location

Create a registry file (single PowerShell file) and keep all tool definitions there.

Suggested path:

- `setup/tools.ps1`

## Registry shape

Use a hashtable keyed by tool name. Each tool is a hashtable with common fields.

Example:

```powershell
$TOOLS_REGISTRY = @{
  "Kape" = @{
    Name     = "Kape"
    Category = "windows-forensics"
    Download = @{
      Type        = "github-release"
      Repo        = "EricZimmerman/KapeFiles"
      Asset       = "Kape.zip"
      Destination = "$TOOLS\Kape"
      Sha256      = $null
    }
    Install = @{
      Type        = "unzip"
      Source      = "$SETUP_PATH\kape.zip"
      Destination = "$TOOLS\Kape"
    }
    Shortcuts = @(
      @{
        Lnk      = "$HOME\Desktop\dfirws\Zimmerman\Kape.lnk"
        Target   = "$CLI_TOOL"
        Args     = "$CLI_TOOL_ARGS -command Kape.exe"
        Icon     = "$TOOLS\Zimmerman\Kape.exe"
        WorkDir  = "$HOME\Desktop"
      }
    )
    Verify = @(
      @{ Type = "command"; Name = "Kape.exe"; Expect = "PE32" }
    )
    Notes = @(
      "Installed Kape into $TOOLS\\Kape"
    )
  }
}
```

## Multiple shortcuts per tool

Use the `Shortcuts` field as an array to define more than one link for the same tool.

```powershell
"Sysinternals" = @{
  Name = "Sysinternals"
  Shortcuts = @(
    @{
      Lnk = "$HOME\\Desktop\\dfirws\\Sysinternals\\Process Explorer.lnk"
      Target = "$TOOLS\\sysinternals\\procexp64.exe"
    },
    @{
      Lnk = "$HOME\\Desktop\\dfirws\\Sysinternals\\Autoruns.lnk"
      Target = "$TOOLS\\sysinternals\\autoruns64.exe"
    }
  )
}
```

## Helper functions

Add lightweight helper functions in `setup/tools.ps1` to query the registry:

```powershell
function Get-ToolRegistry {
  return $TOOLS_REGISTRY
}

function Get-ToolDefinition {
  param([string]$Name)
  return $TOOLS_REGISTRY[$Name]
}

function Get-ToolsByCategory {
  param([string]$Category)
  return $TOOLS_REGISTRY.Values | Where-Object { $_.Category -eq $Category }
}

function Get-GitHubReleaseTools {
  return $TOOLS_REGISTRY.Values | Where-Object {
      $_.Download -and $_.Download.Type -eq "github-release"
  }
}
```

## Execution helpers

Add small executor functions that read the registry and do the work. These should be generic and contain no tool-specific logic.

Suggested function names:

- `Invoke-ToolDownload`
- `Invoke-ToolInstall`
- `Invoke-ToolShortcuts`
- `Invoke-ToolVerify`
- `Invoke-ToolStartup`
- `Write-ToolNotes`

Each executor should handle missing blocks safely (skip if not defined).

## Integrating into existing scripts

Keep current script locations, but replace tool-specific details with registry calls.

### Downloads

In scripts like `resources/download/http.ps1`:

```powershell
. .\setup\tools.ps1
$tool = Get-ToolDefinition "Kape"
Invoke-ToolDownload $tool
```

### Shortcuts

In `setup/utils/dfirws_folder.ps1`:

```powershell
. $HOME\Documents\tools\tools.ps1

foreach ($tool in (Get-ToolRegistry).Values) {
    Invoke-ToolShortcuts $tool
}
```

### Verify

In `setup/install/install_verify.ps1`:

```powershell
. $HOME\Documents\tools\tools.ps1

foreach ($tool in (Get-ToolRegistry).Values) {
    Invoke-ToolVerify $tool
}
```

### Startup items

Add a `Startup` block per tool, then call `Invoke-ToolStartup` from a single place.

### Notes

Add a `Notes` block per tool and call `Write-ToolNotes` as part of install/verify.

## Notes in the running sandbox

Example note writer:

```powershell
function Write-ToolNotes {
  param([hashtable]$Tool)
  $notesPath = "C:\dfirws\notes\tools.txt"
  foreach ($note in $Tool.Notes) {
    Add-Content -Path $notesPath -Value "$(Get-Date -f s) $($Tool.Name): $note"
  }
}
```

## Incremental rollout

1. Add `setup/tools.ps1` with a few tools.
2. Update one script (e.g., `dfirws_folder.ps1`) to use the registry for those tools.
3. Expand registry coverage over time.

This avoids a high-risk refactor and lets you validate the pattern early.
