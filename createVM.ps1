param (
    [Parameter(HelpMessage = "Don't download the ISO file.")]
    [Switch]$NoDownload,
    [Parameter(HelpMessage = "Don't create the VM.")]
    [Switch]$NoCreateVM,
    [Parameter(HelpMessage = "Don't install dfirws the VM.")]
    [Switch]$NoInstall,
    [Parameter(HelpMessage = "Run Windows 11 debloat.")]
    [Switch]$Debloat
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
    $totalFound = foreach ($url in $urls) {

    Write-Output "Processing $url"
    try {
        $content = Invoke-WebRequest -Uri $url -ErrorAction Stop -ConnectionTimeoutSeconds 10
        $downloadLinks = $content.links | Where-Object { `
                $_.'aria-label' -match 'Download' `
                -and $_.outerHTML -match 'fwlink' `
                -and $_.outerHTML -match 'en-US' `
                -and $_.outerHTML -match 'ISO 64' `
                -or $_.'aria-label' -match '64-bit edition' }
        $count = $downloadLinks.href.Count
        $totalCount += $count
        Write-Output ("Processing {0}, Found {1} Download(s)..." -f $url, $count) -ForegroundColor Green
        foreach ($DownloadLink in $downloadLinks) {
            $org_link = $DownloadLink.href
            $real_link = $(curl "$org_link" -L -I -o NUL -w '%{url_effective}' -s)
            [PSCustomObject]@{
                Title  = $url.split('/')[5].replace('-', ' ').replace('download ', '')
                Name   = $DownloadLink.'aria-label'.Replace('Download ', '')
                Tag    = $DownloadLink.'data-bi-tags'.Split('&')[3].split(';')[1]
                Format = $DownloadLink.'data-bi-tags'.Split('-')[1].ToUpper()
                Link   = $real_link
            }

            # Get filename part from the link
            $filename = $real_link.Split("/")[-1]

            # Check if the iso file is already downloaded
            if (! (Test-Path -Path "iso\$filename")) {
                # Download the iso file
                Set-Location tmp
                Remove-Item -Force -ErrorAction SilentlyContinue *
                curl -O --retry 10 --retry-all-errors $real_link
                Set-Location ..
            }
        }

        #Output total downloads found and exports result to the $outputFile path specified
        Write-Output ("Found a total of {0} Downloads" -f $totalCount) -ForegroundColor Green
        $totalFound | Sort-Object Title, Name, Tag, Format | Export-Csv -NoTypeInformation -Encoding UTF8 -Delimiter ';' -Path $outputFile
    }
        catch {
            Write-Output ("ERROR: Url {0} is not accessible. Exiting" -f $url)
            Exit
        }
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
        Write-Output "ERROR: No previous ISO file found. Exiting"
        Exit
    } else {
        Write-Output "Using previous ISO file: $filename"
    }

    # Make sure the iso file is downloaded
    if (! (Test-Path -Path "iso\$filename")) {
        Write-Output "ERROR: ISO file not found. Exiting"
        Exit
    }

    # Get hash of the downloaded file from the iso directory
    $hash = (Get-FileHash -Path iso\$filename -Algorithm SHA256).Hash

    # Change the strings ISO_HASH, ISO_FILENAME and ISO_LINK in the file windows_11.pkr.hcl.default to the actual values and save in windows_11.pkr.hcl
    (Get-Content ".\resources\vm\windows_11.pkr.hcl.default") -replace 'ISO_HASH', $hash | Set-Content "windows_11.pkr.hcl"
    (Get-Content ".\windows_11.pkr.hcl") -replace 'ISO_FILENAME', $filename | Set-Content "windows_11.pkr.hcl"
    (Get-Content ".\windows_11.pkr.hcl") -replace 'ISO_LINK', $real_link | Set-Content "windows_11.pkr.hcl"

    if (Get-Command packer.exe -ErrorAction SilentlyContinue) {
        packer build windows_11.pkr.hcl
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

