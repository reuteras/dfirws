<#
.SYNOPSIS
    Create a Windows 11 VM with dfirws installed.

.DESCRIPTION
    This script will download the Windows 11 ISO file, create a VM with Windows 11 installed, install dfirws in the VM and run Windows 11 customization.

.PARAMETER NoDownload
    Don't download the ISO file (when already downloaded).

.PARAMETER NoCreateVM
    Don't create the VM (VM already created and Windows is installed).

.PARAMETER NoInstall
    Don't install dfirws in the VM (install script already finished).

.PARAMETER NoCustomize
    Dont' run Windows 11 customization.

.NOTES
    File Name      : createVM.ps1
    Author         : Peter R

.LINK
    https://github.com/reuteras/dfirws
#>

param (
    [Parameter(HelpMessage = "Don't download the ISO file (when already downloaded).")]
    [Switch]$NoDownload,
    [Parameter(HelpMessage = "Don't create the VM (VM already created and Windows is installed).")]
    [Switch]$NoCreateVM,
    [Parameter(HelpMessage = "Don't install dfirws in the VM (install script already finished).")]
    [Switch]$NoInstall,
    [Parameter(HelpMessage = "Dont' run Windows 11 customization.")]
    [Switch]$NoCustomize,
    [Parameter(HelpMessage = "VMX file for the VM.")]
    [string]$VM_VMX = ".\Windows_11_dfirws_64-bit.vmwarevm\Windows_11_dfirws_64-bit.vmx"
)

if (-not (Test-Path -Path "tmp")) {
    New-Item -ItemType Directory -Path "tmp" | Out-Null
}

$filename = ""
$real_link = ""

if ($NoDownload.IsPresent) {
    Get-ChildItem -Path "iso" -Filter "*.iso" | ForEach-Object {
        $script:filename = $_.Name
    }
} else {
    # Code to get download url is from
    # https://powershellisfun.com/2022/05/25/get-all-download-links-from-microsoft-evaluation-center/

    # Evaluation Center link with downloadable content fir Windows 11
    $url= "https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise"

    # Search for download links
    $ProgressPreference = "SilentlyContinue"

    Write-Output "Processing $url"
    try {
        $content = Invoke-WebRequest -Uri $url -ErrorAction Stop -ConnectionTimeoutSeconds 10 -UserAgent "curl"
        $downloadLinks = $content.links | Where-Object { `
            $_.'aria-label' -match 'Download' `
                -and $_.outerHTML -match 'fwlink' `
                -and $_.outerHTML -match 'en-US' `
                -and $_.outerHTML -match 'ISO 64' `
                -or $_.'aria-label' -match '64-bit edition' }
        foreach ($DownloadLink in $downloadLinks) {
            $org_link = $DownloadLink.href
            $real_link = $(curl "$org_link" -L -I -o NUL -w '%{url_effective}' -s) -replace "es-es", "en-us"
        }
        Write-Output "Will use link $real_link."

        # Get filename part from the link
        $filename = $real_link.Split("/")[-1]

        # Check if the iso file is already downloaded
        if (! (Test-Path -Path "iso\$filename")) {
            # Download the iso file
            Set-Location tmp
            curl -O --retry 10 --retry-all-errors $real_link
            Set-Location ..
        }
    } catch {
        Write-Output ("ERROR: Url {0} is not accessible. Exiting" -f $url)
        Exit
    }

    if (-not (Test-Path -Path "iso")) {
        New-Item -ItemType Directory -Path "iso" | Out-Null
    }

    if (! (Test-Path -Path "iso\$filename")) {
        Copy-Item -Path "tmp\$filename" -Destination "iso\$filename" -Force
    }
}

if (! ($NoCreateVM.IsPresent)) {
    if ($filename -eq "") {
        Write-Output "ERROR: No ISO file found. Exiting"
        Exit
    } else {
        Write-Output "Using ISO file: $filename"
    }

    if (! (Test-Path -Path "iso\$filename")) {
        Write-Output "ERROR: ISO file not found. Exiting"
        Exit
    }

    $hash = (Get-FileHash -Path iso\$filename -Algorithm SHA256).Hash

    if ( "" -eq $real_link ) {
        # Bogus URL
        $real_link = "${url}/${filename}"
    }

    # Change the strings ISO_HASH, ISO_FILENAME and ISO_LINK in the file windows_11.pkr.hcl.default to the actual values and save in windows_11.pkr.hcl
    (Get-Content ".\resources\vm\windows_11.pkr.hcl.default") -replace 'ISO_HASH', $hash | Set-Content ".\tmp\windows_11.pkr.hcl"
    (Get-Content ".\tmp\windows_11.pkr.hcl") -replace 'ISO_FILENAME', $filename | Set-Content ".\tmp\windows_11.pkr.hcl"
    (Get-Content ".\tmp\windows_11.pkr.hcl") -replace 'ISO_LINK', $real_link | Set-Content ".\tmp\windows_11.pkr.hcl"

    if (Get-Command packer.exe -ErrorAction SilentlyContinue) {
        if (Test-Path ".\local\variables.pkr.hcl") {
            Write-Output "Running packer build windows_11.pkr.hcl with local/variables.pkr.hcl"
            packer build -var-file=".\local\variables.pkr.hcl" ".\tmp\windows_11.pkr.hcl"
        } else {
            Write-Output "Running packer build windows_11.pkr.hcl"
            packer build -var-file=".\local\defaults\variables.pkr.hcl" ".\tmp\windows_11.pkr.hcl"
        }
    } else {
        Write-Output "Packer is not installed. Please install packer and then rerun the command."
        Write-Output "Download packer from https://developer.hashicorp.com/packer/install"
        Exit 1
    }
}

if (! ($NoInstall.IsPresent)) {
    Write-Output "Create zip files for the VM to speed up installation"
    & ".\resources\vm\prepare_zip_files.ps1"
    Write-Output "Running install_dfirws_in_vm.ps1 script"
    & ".\resources\vm\install_dfirws_in_vm.ps1"
}

if ($Debloat.IsPresent) {
    Write-Output "Running debloat.ps1 script"
    & ".\resources\vm\debloat.ps1"
}

if (! ($NoCustomize.IsPresent)) {
    if (Test-Path -Path ".\local\customize-vm.ps1") {
        Write-Output "Running local/customize-vm.ps1 script"
        & ".\resources\vm\customize-vm.ps1" -CustomizeFile "customize-vm.ps1"
    } else {
        Write-Output "Running local/defaults/customize-vm.ps1 script"
        & ".\resources\vm\customize-vm.ps1" -CustomizeFile "defaults\customize-vm.ps1"
    }
}

Write-Output "Starting the VM to remove shared folder dfirws"
vmrun.exe -T ws start "${VM_VMX}" gui

vmrun.exe -T ws -gu dfirws -gp password  getGuestIPAddress "${VM_VMX}" -wait | Out-Null

Write-Output "Remove shared folder dfirws"
vmrun.exe -T ws removeSharedFolder "${VM_VMX}" "dfirws"

Write-Output "Shutting down the VM"
vmrun.exe -T ws stop "${VM_VMX}" soft

Write-Output "Removing temporary files"
foreach ($file in "tmp\windows_11.pkr.hcl", ".\tmp\git.zip", ".\tmp\tools.zip", ".\tmp\venv.zip", ".\tmp\${filename}") {
    if (Test-Path -Path $file) {
        Remove-Item -Path $file -Force
    }
}

Write-Output "Done"
