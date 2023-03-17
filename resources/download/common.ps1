# Ensure that we have a log directory and a clean log file
if (! (Test-Path -Path "$PSScriptRoot\..\..\log" )) {
    New-Item -ItemType Directory -Force -Path "$PSScriptRoot\..\..\log" > $null
}
if (! (Test-Path -Path "$PSScriptRoot\..\..\log\log.txt" )) {
    Get-Date > "$PSScriptRoot\..\..\log\log.txt"
}

function Get-FileFromUri {
    Param (
        [Parameter(Mandatory=$True)] [string]$uri,
        [Parameter(Mandatory=$True)] [string]$FilePath
    )

    $CleanPath = $FilePath -replace "^..", ""
    $TmpFilePath= "$PSScriptRoot\..\..\tmp\$CleanPath"
    $FilePath = "$PSScriptRoot\..\..\$CleanPath"

    # Make sure the destination directory exists
    # System.IO.FileInfo works even if the file/dir doesn't exist, which is better then get-item which requires the file to exist
    If (! ( Test-Path ([System.IO.FileInfo]$FilePath).DirectoryName ) ) {
        [void](New-Item ([System.IO.FileInfo]$FilePath).DirectoryName -force -type directory)
    }

    If (! ( Test-Path ([System.IO.FileInfo]$TmpFilePath).DirectoryName ) ) {
        [void](New-Item ([System.IO.FileInfo]$TmpFilePath).DirectoryName -force -type directory)
    }

    # See if this file exists
    $downloader = New-Object System.Net.WebClient
    $downloader.Headers.add("user-agent", "Wget x64")
    if ( -not (Test-Path $FilePath) ) {
        # Use simple download
        Write-Output "Downloading new file $FilePath." >> .\log\log.txt
        $downloader.DownloadFile($uri, $FilePath)
    } else {
        try {
            Write-Output "Downloading file $FilePath." >> .\log\log.txt
            $downloader.DownloadFile($uri, $TmpFilePath)
            rclone copyto --verbose --checksum $TmpFilePath $FilePath >> .\log\log.txt 2>&1
            Remove-Item $TmpFilePath
        } catch [System.Net.WebException] {
            # Check for a 304
            if ($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::NotModified) {
                Write-Output "$FilePath not modified, not downloading..." >> .\log\log.txt
            } else {
                # Unexpected error
                $Status = $_.Exception.Response.StatusCode
                $msg = $_.Exception
                Write-Output "Error dowloading $FilePath, Status code: $Status - $msg" >> .\log\log.txt
            }
        }
    }
}

function Get-DownloadUrl {
    Param (
        [string]$releases,
        [string]$match
    )
    try {
        $downloads = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].assets.browser_download_url
        if ( ( Write-Output $downloads | Measure-Object -word ).Words -gt 1 ) {
            return Write-Output $downloads | findstr /R $match | findstr /R /V "darwin sig blockmap"
        } else {
            return $downloads
        }
    }
    catch {
        return ""
    }
}

function Get-GitHubRelease {
    Param (
        [string]$repo,
        [string]$path,
        [string]$match
    )

    $releases = "https://api.github.com/repos/$repo/releases/latest"

    $url = Get-DownloadUrl -Releases $releases -Match $match


    if ( !$url ) {
        # Try without latest
        $releases = "https://api.github.com/repos/$repo/releases"
        $url = Get-DownloadUrl -Releases $releases -Match $match
    }

    if ( !$url ) {
        $url = curl --silent https://api.github.com/repos/$repo/releases | findstr tarball | Select-Object -First 1 | ForEach-Object { ($_ -split "\s+")[2] } | ForEach-Object { ($_ -replace '[",]','') }
        if ( !$url) {
            Write-Error "Can't find a file to download for repo $repo."
            Exit
        }
    }

    Write-Output "Using $url for $repo." >> .\log\log.txt
    Get-FileFromUri -uri $url -FilePath $path
}

function Get-ChocolateyUrl {
    Param (
        [string]$package
    )

    $url = curl --silent https://community.chocolatey.org/packages/$package | findstr /C:"Download the raw" | findstr ">Download<" | ForEach-Object { ($_ -split '"' )[1] }

    if (!$url) {
        Write-Error "Couldn't find download url for Chocolately package $package."
        Exit
    }

    return $url
}

function Get-DownloadUrlFromPage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $url,
        [Parameter()]
        [regex]
        $regex
    )

    return Invoke-WebRequest -Uri "$url" -UseBasicParsing | Select-String -Pattern "$regex" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
}

function Get-Sandbox {
    param ()

    Get-Process WindowsSandboxClient 2> $null
}

function Stop-SandboxWhenDone {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [string]
        $path
    )

    while ($true ) {
        $status = Get-Process WindowsSandboxClient 2> $null
        if ($status) {
            if ( Test-Path $path ) {
                if($PSCmdlet.ShouldProcess($file.Name)) {
                    (Get-Process WindowsSandboxClient).Kill()
                }
            }
            Start-Sleep 1
        } else {
            return
        }
    }

}