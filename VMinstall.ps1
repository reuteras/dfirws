<#
.SYNOPSIS
    Create a dfirws installation package for VMs, or install from one.

.DESCRIPTION
    Host mode (-CreatePackage): from a populated dfirws checkout (after
    downloadFiles.ps1), produces a single .7z archive containing everything
    needed to install dfirws inside a Windows 11 VM. Hypervisor-agnostic;
    works with VMware Workstation, Hyper-V, VirtualBox, or a physical host.

    Guest mode (-Install): run from the extracted bundle inside the VM.
    Copies the bundle payload to the same destination paths that the
    Windows Sandbox mapped folders use, then runs start_sandbox.ps1 and
    the customize-vm script to finish configuration.

.PARAMETER CreatePackage
    Host-side. Create dfirws-vm.7z from the current directory.

.PARAMETER Install
    Guest-side. Install dfirws from the extracted bundle.

.PARAMETER PackageFile
    Output path for -CreatePackage. Default: .\dfirws-vm.7z

.EXAMPLE
    .\VMinstall.ps1 -CreatePackage

.EXAMPLE
    .\VMinstall.ps1 -Install

.NOTES
    Replaces the previous createVM.ps1 + resources\vm\* flow, which was
    tied to VMware Workstation and broke with VMware Tools 13.0+ TPM
    requirement.
#>

param (
    [Switch]$CreatePackage,
    [Switch]$Install,
    [string]$PackageFile = ".\dfirws-vm.7z"
)

function Find-SevenZip {
    if (Get-Command "7z.exe" -ErrorAction SilentlyContinue) { return "7z.exe" }
    foreach ($c in @("${env:ProgramFiles}\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe")) {
        if (Test-Path $c) { return $c }
    }
    return $null
}

if (-not ($CreatePackage -or $Install)) {
    Write-Output "Specify either -CreatePackage (on host) or -Install (in guest)."
    Exit 1
}
if ($CreatePackage -and $Install) {
    Write-Output "Specify only one of -CreatePackage or -Install."
    Exit 1
}

# -------- Host mode: build the package --------
if ($CreatePackage) {
    $sevenZip = Find-SevenZip
    if (-not $sevenZip) {
        Write-Output "ERROR: 7-Zip is required on the host. Install it and retry."
        Exit 1
    }

    $required = @(
        "setup",
        "mount\git",
        "mount\Tools",
        "mount\venv",
        "mount\golang",
        "downloads",
        "enrichment",
        "local"
    )
    foreach ($d in $required) {
        if (-not (Test-Path $d)) {
            Write-Output "ERROR: required directory '$d' is missing. Run downloadFiles.ps1 first."
            Exit 1
        }
    }
    if (-not (Test-Path ".\VMinstall.ps1")) {
        Write-Output "ERROR: run this from the dfirws repository root."
        Exit 1
    }

    if (Test-Path $PackageFile) {
        Write-Output "Removing existing package: $PackageFile"
        Remove-Item $PackageFile -Force
    }

    $items = $required + @("VMinstall.ps1")
    Write-Output "Creating $PackageFile. This will take a while."
    & $sevenZip a -mx=5 $PackageFile @items | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "ERROR: 7-Zip failed with exit code $LASTEXITCODE."
        Exit $LASTEXITCODE
    }
    Write-Output ("Package created: {0}" -f (Resolve-Path $PackageFile))
    Exit 0
}

# -------- Guest mode: install from extracted bundle --------
if ($Install) {
    $currentId = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentId)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Output "VMinstall.ps1 -Install must be run from an elevated PowerShell."
        Exit 1
    }

    $bundleRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

    # Sanity check: the bundle must be extracted.
    foreach ($d in @("setup", "mount", "downloads", "local")) {
        if (-not (Test-Path (Join-Path $bundleRoot $d))) {
            Write-Output "ERROR: bundle directory '$d' not found under $bundleRoot. Extract dfirws-vm.7z first."
            Exit 1
        }
    }

    # Ensure 7-Zip on the guest (needed by start_sandbox.ps1 and friends).
    if (-not (Find-SevenZip)) {
        $msi = Join-Path $bundleRoot "downloads\7zip.msi"
        if (-not (Test-Path $msi)) {
            Write-Output "ERROR: 7-Zip not installed and downloads\7zip.msi missing from bundle."
            Exit 1
        }
        Write-Output "Installing 7-Zip..."
        Start-Process -Wait msiexec -ArgumentList "/i `"$msi`" /qn /norestart"
    }

    # Mirror the Windows Sandbox mapped-folder layout.
    $map = @(
        @{ src = "setup";        dst = "$env:USERPROFILE\Documents\tools" },
        @{ src = "mount\git";    dst = "C:\git" },
        @{ src = "mount\Tools";  dst = "C:\Tools" },
        @{ src = "mount\venv";   dst = "C:\venv" },
        @{ src = "mount\golang"; dst = "$env:USERPROFILE\go" },
        @{ src = "downloads";    dst = "C:\downloads" },
        @{ src = "enrichment";   dst = "C:\enrichment" },
        @{ src = "local";        dst = "C:\local" }
    )
    foreach ($m in $map) {
        $s = Join-Path $bundleRoot $m.src
        $d = $m.dst
        if (-not (Test-Path $s)) {
            Write-Output "WARNING: $s missing in bundle, skipping."
            continue
        }
        if (-not (Test-Path $d)) {
            New-Item -ItemType Directory -Path $d -Force | Out-Null
        }
        Write-Output "Copying $s -> $d"
        Copy-Item -Recurse -Force -Path (Join-Path $s '*') -Destination $d
    }

    Write-Output "Running start_sandbox.ps1"
    & "$env:USERPROFILE\Documents\tools\start_sandbox.ps1"

    # Customize step (start_sandbox.ps1 skips this when TARGET_ENVIRONMENT != Sandbox).
    $custom = "C:\local\customize-vm.ps1"
    $defaultCustom = "C:\local\defaults\customize-vm.ps1"
    if (Test-Path $custom) {
        Write-Output "Running $custom"
        & $custom
    } elseif (Test-Path $defaultCustom) {
        Write-Output "Running $defaultCustom"
        & $defaultCustom
    } else {
        Write-Output "No customize-vm.ps1 found; skipping customization."
    }

    Write-Output "Done. Reboot recommended."
    Exit 0
}
