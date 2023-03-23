$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

function Get-FileFromUri {
    Param (
        [Parameter(Mandatory=$True)] [string]$uri,
        [Parameter(Mandatory=$True)] [string]$FilePath
    )

    $CleanPath = $FilePath -replace "^..", ""
    $TmpFilePath= "$PSScriptRoot\..\..\tmp\$CleanPath"
    $FilePath = "$PSScriptRoot\..\..\$CleanPath"

    If (! ( Test-Path ([System.IO.FileInfo]$FilePath).DirectoryName ) ) {
        New-Item ([System.IO.FileInfo]$FilePath).DirectoryName -force -type directory | Out-Null
    }

    If (! ( Test-Path ([System.IO.FileInfo]$TmpFilePath).DirectoryName ) ) {
        New-Item ([System.IO.FileInfo]$TmpFilePath).DirectoryName -force -type directory | Out-Null
    }

    $retries = 3
    $ProgressPreference = 'SilentlyContinue'
    while($true) {
        try {
            Invoke-WebRequest $uri -UserAgent "Wget x64" -OutFile $TmpFilePath
            Write-SynchronizedLog "Downloaded $uri to $FilePath."
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
    $result = rclone copyto --verbose --checksum $TmpFilePath $FilePath 2>&1 | Out-String
    Write-SynchronizedLog "$result"
    Remove-Item $TmpFilePath
    $ProgressPreference = 'Continue'
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

    Write-SynchronizedLog "Using $url for $repo."
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

function Get-DownloadUrlMSYS {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $package
    )

    $base = "https://repo.msys2.org/msys/x86_64/"
    $package = '"' + $package + "-[0-9]"
    $url = curl --silent $base |
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

function Stop-SandboxWhenDone {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [string]$path,
        [System.Threading.Mutex] $Mutex
    )

    while ($true ) {
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

function Write-SynchronizedLog {
    param (
        [string]$Message,
        [string]$Path = "$PSScriptRoot\..\..\log\log.txt"
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