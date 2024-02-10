param (
    [Parameter(HelpMessage = "Don't download the ISO file.")]
    [Switch]$NoDownload,
    [Parameter(HelpMessage = "Don't create the VM.")]
    [Switch]$NoCreateVM,
    [Parameter(HelpMessage = "Don't install dfirws the VM.")]
    [Switch]$NoInstall,
    [Parameter(HelpMessage = "Dont' run Windows 11 customization.")]
    [Switch]$NoCustomize
)

if (-not (Test-Path -Path "tmp")) {
    New-Item -ItemType Directory -Path "tmp" | Out-Null
}

$filename = ""

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
            $real_link = $(curl "$org_link" -L -I -o NUL -w '%{url_effective}' -s)
        }

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

    # Copy iso file to iso directory
    if (-not (Test-Path -Path "iso")) {
        New-Item -ItemType Directory -Path "iso"
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

    # Make sure the iso file is downloaded
    if (! (Test-Path -Path "iso\$filename")) {
        Write-Output "ERROR: ISO file not found. Exiting"
        Exit
    }

    # Get hash of the downloaded file from the iso directory
    $hash = (Get-FileHash -Path iso\$filename -Algorithm SHA256).Hash

    # Change the strings ISO_HASH, ISO_FILENAME and ISO_LINK in the file windows_11.pkr.hcl.default to the actual values and save in windows_11.pkr.hcl
    (Get-Content ".\resources\vm\windows_11.pkr.hcl.default") -replace 'ISO_HASH', $hash | Set-Content ".\tmp\windows_11.pkr.hcl"
    (Get-Content ".\tmp\windows_11.pkr.hcl") -replace 'ISO_FILENAME', $filename | Set-Content ".\tmp\windows_11.pkr.hcl"
    (Get-Content ".\tmp\windows_11.pkr.hcl") -replace 'ISO_LINK', $real_link | Set-Content ".\tmp\windows_11.pkr.hcl"

    if (Get-Command packer.exe -ErrorAction SilentlyContinue) {
        if (Test-Path ".\local\variables.pkr.hcl") {
            Write-Output "Running packer build windows_11.pkr.hcl with local/variables.pkr.hcl"
            packer build -var-file=".\local/variables.pkr.hcl" ".\tmp\windows_11.pkr.hcl"
        } else {
            Write-Output "Running packer build windows_11.pkr.hcl"
            packer build -var-file=".\local/default-variables.pkr.hcl" ".\tmp\windows_11.pkr.hcl"
        }
    } else {
        Write-Output "Packer is not installed. Please install packer and then rerun the command."
        Write-Output "Download packer from https://developer.hashicorp.com/packer/install"
        Exit 1
    }
}

if (! ($NoInstall.IsPresent)) {
    Write-Output "Create zip files for the VM to speed up the installation"
    & ".\resources\vm\prepare_zip_files.ps1"
    Write-Output "Running the install_dfirws_in_vm.ps1 script for the VM"
    & ".\resources\vm\install_dfirws_in_vm.ps1"
}

if ($Debloat.IsPresent) {
    Write-Output "Running the debloat.ps1 script"
    & ".\resources\vm\debloat.ps1"
}

if (! ($NoCustomize.IsPresent)) {
    if (Test-Path -Path ".\local\customize-vm.ps1") {
        Write-Output "Running the local/customize-vm.ps1 script"
        & ".\resources\vm\customize-vm.ps1" -CustomizeFile "customize-vm.ps1"
    } else {
        Write-Output "Running the local/example-customize-vm.ps1 script"
        & ".\resources\vm\customize-vm.ps1" -CustomizeFile "example-customize-vm.ps1"
    }
}

Write-Output "Done"
