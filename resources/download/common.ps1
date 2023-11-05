# Set the default encoding for Out-File to UTF-8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Function to download a file from a given URI and save it to a specified file path
function Get-FileFromUri {
    Param (
        [Parameter(Mandatory=$True)] [string]$uri,
        [Parameter(Mandatory=$True)] [string]$FilePath
    )

    # Remove any leading '..' from the file path and set up temporary file path and final file path
    $CleanPath = $FilePath -replace "^..", ""
    $TmpFilePath= "$PSScriptRoot\..\..\tmp\$CleanPath"
    $FilePath = "$PSScriptRoot\..\..\$CleanPath"

    # Ensure the directory for the final file path exists
    If (! ( Test-Path ([System.IO.FileInfo]$FilePath).DirectoryName ) ) {
        New-Item ([System.IO.FileInfo]$FilePath).DirectoryName -force -type directory | Out-Null
    }

    # Ensure the directory for the temporary file path exists
    If (! ( Test-Path ([System.IO.FileInfo]$TmpFilePath).DirectoryName ) ) {
        New-Item ([System.IO.FileInfo]$TmpFilePath).DirectoryName -force -type directory | Out-Null
    }

    # Set the number of retries for the download
    $retries = 3
    $ProgressPreference = 'SilentlyContinue'
    while($true) {
        try {
            # Attempt to download the file from the specified URI
            Remove-Item -Force $TmpFilePath -ErrorAction SilentlyContinue
            if ($uri -contains "github.com") {
                curl.exe --silent -u "${GH_USER}:${GH_PASS}" -L --output $TmpFilePath $uri
            } else {
                curl.exe --silent -L --user-agent "Wget x64" --output $TmpFilePath $uri
            }        Write-SynchronizedLog "Downloaded $uri to $FilePath."
            break
        }
        catch {
            $exceptionMessage = $_.Exception.Message
            Write-SynchronizedLog "Failed to download '$uri': $exceptionMessage"
            if ($retries -gt 0) {
                $retries--
                Write-SynchronizedLog "Waiting 10 seconds before retrying. Retries left: $retries"
                Start-Sleep -Seconds 10
            } else {
                $exception = $_.Exception
                throw $exception
            }
        }
    }
    # Copy the temporary file to the final file path and remove the temporary file
    $result = rclone copyto --metadata --verbose --inplace --checksum $TmpFilePath $FilePath 2>&1 | Out-String
    Write-SynchronizedLog "$result"
    Remove-Item $TmpFilePath
    $ProgressPreference = 'Continue'
}

# Function to get the download URL for a GitHub release
function Get-DownloadUrl {
    Param (
        [Parameter(Mandatory=$True)] [string]$releases,
        [Parameter(Mandatory=$True)] [string]$match
    )
    try {
        # Retrieve the download URLs and filter them based on the provided regex match
        $downloads = (curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releases | ConvertFrom-Json)[0].assets.browser_download_url
        }
    catch {
        $downloads = ""
    }

    if (!$downloads) {
        try {
            $downloads = (curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releases | ConvertFrom-Json).assets[0].browser_download_url
        }
        catch {
            $downloads = ""
        }
    }

    if (!$downloads) {
        return ""
    }

    if ( ( Write-Output $downloads | Measure-Object -word ).Words -gt 1 ) {
        return $downloads -replace ' ', "`r`n" | findstr /R $match | findstr /R /V "darwin \.sig blockmap"
    } else {
        return $downloads
    }
}

# Function to download the specified GitHub release and save it to a specified file path
function Get-GitHubRelease {
    Param (
        [Parameter(Mandatory=$True)] [string]$repo,
        [Parameter(Mandatory=$True)] [string]$path,
        [Parameter(Mandatory=$True)] [string]$match
    )

    # Construct the URL to get the latest release information
    $releases = "https://api.github.com/repos/$repo/releases/latest"

    # Get the download URL by matching the specified regex pattern
    $url = Get-DownloadUrl -Releases $releases -Match $match

    # If no download URL is found, try without "latest"
    if ( !$url ) {
        $releases = "https://api.github.com/repos/$repo/releases"
        $url = Get-DownloadUrl -Releases $releases -Match $match
    }

    # If still no download URL is found, try getting the tarball URL
    if ( !$url ) {
        $url = curl --silent -L -u "${GH_USER}:${GH_PASS}" https://api.github.com/repos/$repo/releases | findstr tarball | Select-Object -First 1 | ForEach-Object { ($_ -split "\s+")[2] } | ForEach-Object { ($_ -replace '[",]','') }
        if ( !$url) {
            Write-Error "Can't find a file to download for repo $repo."
            Exit
        }
    }

    # Log the chosen URL and download the file
    Write-SynchronizedLog "Using $url for $repo."
    Get-FileFromUri -uri $url -FilePath $path
}

# Function to get the download URL for a Chocolatey package
function Get-ChocolateyUrl {
    Param (
        [Parameter(Mandatory=$True)] [string]$package
    )

    # Scrape the download URL from the Chocolatey package page
    $url = curl --silent https://community.chocolatey.org/packages/$package | findstr /C:"Download the raw" | findstr ">Download<" | ForEach-Object { ($_ -split '"' )[1] }

    if (!$url) {
        Write-Error "Couldn't find download url for Chocolately package $package."
        Exit
    }

    return $url
}

# Function to get the download URL from a specified web page, based on a regex pattern
function Get-DownloadUrlFromPage {
    param (
        [Parameter(Mandatory=$True)] [string]$url,
        [Parameter(Mandatory=$True)] [regex]$regex
    )

    if ($url -contains "github.com") {
        return curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" "$url" | Select-String -Pattern "$regex" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
    } else {
        return curl.exe --silent -L "$url" | Select-String -Pattern "$regex" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
    }
}

# Function to get the download URL for an MSYS package
function Get-DownloadUrlMSYS {
    param (
        [Parameter(Mandatory=$True)] [string]$package
    )

    $base = "https://repo.msys2.org/msys/x86_64/"
    $package = '"' + $package + "-[0-9]"
    $url = curl --silent -L $base |
        findstr "$package" |
        findstr /v ".sig" |
        ForEach-Object { ($_ -split '"')[1]} |
        ForEach-Object {
            if ($_ -match '(.+)-([0-9.]+)-([0-9]+)-(.+)\.pkg\.tar\.zst') {
                [PSCustomObject]@{
                    FileName    = $_
                    Name        = $matches[1]
                    Version     = [System.Version]::Parse($matches[2])
                    Release     = [int]::Parse($matches[3])
                    Architecture = $matches[4]
                }
            } else {
                [PSCustomObject]@{
                    FileName    = $_
                }
            }
        } |
        Sort-Object -Property Version, Release -Descending |
        Select-Object -First 1
    return $base + $url.FileName
}

# Function to stop the Windows Sandbox when the specified file is deleted
function Stop-SandboxWhenDone {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True)] [string]$path,
        [Parameter(Mandatory=$True)] [System.Threading.Mutex] $Mutex
    )

    while ($true) {
        $status = Get-Process WindowsSandboxClient 2> $null
        if ($status) {
            if ( Test-Path $path ) {
                if($PSCmdlet.ShouldProcess($file.Name)) {
                    (Get-Process WindowsSandboxClient).Kill()
                    Remove-Item -Force "$path"
                    Start-Sleep 1
                    $mutex.ReleaseMutex()
                    $mutex.Dispose()
                    return
                }
            }
            Start-Sleep 1
        } else {
            $mutex.ReleaseMutex()
            $mutex.Dispose()
            return
        }
    }
}

# Function to write a synchronized log to a specified file
function Write-SynchronizedLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message,
        [Parameter(Mandatory=$false)] [string]$Path = "$PSScriptRoot\..\..\log\log.txt"
    )

    $logMutex = New-Object -TypeName 'System.Threading.Mutex' -ArgumentList $false, 'Global\dfirwsLogMutex'

    try {
        $result = $logMutex.WaitOne()
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $fullMessage = "$timestamp - $Message"
        Add-Content -Path $Path -Value $fullMessage
    }
    finally {
        $result = $logMutex.ReleaseMutex()
    }

    if (!$result) {
        Write-Debug "Error"
    }
}

# Write a log with a timestamp
function Write-DateLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullMessage = "$timestamp - $Message"
    Write-Output $fullMessage
}