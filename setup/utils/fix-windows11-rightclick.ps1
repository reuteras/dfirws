# DFIRWS Windows 11 Right-Click Context Menu Fix
# Related to GitHub Issue #97
# Version: 1.0
# Last Updated: 2025-11-05

param(
    [Parameter(HelpMessage = "Restore classic context menu")]
    [Switch]$Enable,

    [Parameter(HelpMessage = "Revert to Windows 11 default menu")]
    [Switch]$Disable,

    [Parameter(HelpMessage = "Check current status")]
    [Switch]$Status
)

$registryPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"

function Get-ContextMenuStatus {
    if (Test-Path $registryPath) {
        Write-Output "Status: Classic context menu is ENABLED"
        return $true
    } else {
        Write-Output "Status: Windows 11 default context menu is ACTIVE"
        return $false
    }
}

function Enable-ClassicContextMenu {
    Write-Output "Enabling classic context menu..."

    try {
        # Create the registry key structure
        $clsidPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"

        if (-not (Test-Path $clsidPath)) {
            New-Item -Path $clsidPath -Force | Out-Null
        }

        if (-not (Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
        }

        # Set empty default value
        Set-ItemProperty -Path $registryPath -Name "(Default)" -Value "" -Type String

        Write-Output "✓ Classic context menu enabled successfully!"
        Write-Output ""
        Write-Output "Please restart Windows Explorer or log off/on for changes to take effect."
        Write-Output ""
        Write-Output "To restart Explorer now, run:"
        Write-Output "  Stop-Process -Name explorer -Force"
        Write-Output ""

        return $true
    } catch {
        Write-Error "Failed to enable classic context menu: $_"
        return $false
    }
}

function Disable-ClassicContextMenu {
    Write-Output "Reverting to Windows 11 default context menu..."

    try {
        $clsidPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"

        if (Test-Path $clsidPath) {
            Remove-Item -Path $clsidPath -Recurse -Force
            Write-Output "✓ Windows 11 default context menu restored successfully!"
            Write-Output ""
            Write-Output "Please restart Windows Explorer or log off/on for changes to take effect."
            Write-Output ""
        } else {
            Write-Output "Classic context menu was not enabled. No changes made."
        }

        return $true
    } catch {
        Write-Error "Failed to restore default context menu: $_"
        return $false
    }
}

function Restart-Explorer {
    Write-Output "Restarting Windows Explorer..."
    try {
        Stop-Process -Name explorer -Force
        Write-Output "✓ Windows Explorer restarted successfully!"
        return $true
    } catch {
        Write-Error "Failed to restart Windows Explorer: $_"
        return $false
    }
}

# Main script logic
if ($Status) {
    Get-ContextMenuStatus
    exit 0
}

if ($Enable) {
    $result = Enable-ClassicContextMenu
    if ($result) {
        $response = Read-Host "Restart Windows Explorer now? (Y/N)"
        if ($response -eq 'Y' -or $response -eq 'y') {
            Restart-Explorer
        }
    }
    exit 0
}

if ($Disable) {
    $result = Disable-ClassicContextMenu
    if ($result) {
        $response = Read-Host "Restart Windows Explorer now? (Y/N)"
        if ($response -eq 'Y' -or $response -eq 'y') {
            Restart-Explorer
        }
    }
    exit 0
}

# If no parameters, show help
Write-Output "DFIRWS Windows 11 Right-Click Context Menu Fix"
Write-Output ""
Write-Output "Usage:"
Write-Output "  .\fix-windows11-rightclick.ps1 -Enable    # Enable classic context menu"
Write-Output "  .\fix-windows11-rightclick.ps1 -Disable   # Restore Windows 11 default"
Write-Output "  .\fix-windows11-rightclick.ps1 -Status    # Check current status"
Write-Output ""
Write-Output "Temporary alternative:"
Write-Output "  Hold Shift while right-clicking to access full menu without changes"
Write-Output ""
Write-Output "For more information, see: docs/WINDOWS11_RIGHT_CLICK_FIX.md"
Write-Output "Related to GitHub Issue #97"
Write-Output ""
