# Set the default encoding for Out-File to UTF-8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Variables used by the script - define in global scope for access from all functions
$global:CONFIGURATION_FILES = ".\local"
$global:SETUP_PATH = ".\downloads"
$global:WSDFIR_TEMP = "C:\tmp"
$global:TOOLS = ".\mount\Tools"
$global:SANDBOX_TOOLS = "C:\Tools"

$null=$global:CONFIGURATION_FILES
$null=$global:SANDBOX_TOOLS
$null=$global:SETUP_PATH
$null=$global:WSDFIR_TEMP
$null=$global:TOOLS

if (!(Test-Path variable:GIT_FILE)) {
    $GIT_FILE = "C:\Program Files\Git\usr\bin\file.exe"
}

# Function to download a file from a given URI and save it to a specified file path.
function Get-FileFromUri {
    Param (
        [Parameter(Mandatory=$True)] [string]$Uri,
        [Parameter(Mandatory=$True)] [string]$FilePath,
        [Parameter(Mandatory=$False)] [string]$CheckURL = "",
        [Parameter(Mandatory=$False)] [string]$check = "",
        [Parameter(Mandatory=$False)] [int]$RetryDepth = 0
    )

    Write-SynchronizedLog "Downloading $Uri to $FilePath. CheckURL: $CheckURL."

    $fileDownloadedOrChanged = $false

    # Check if the file has already been downloaded
    if ((Test-Path -Path "$FilePath") -and $CheckURL -eq "Yes") {
        if (Compare-ToolsDownloaded -URL $Uri -AppName ([System.IO.FileInfo]$FilePath).Name) {
            Write-SynchronizedLog "File $FilePath already downloaded according to tools_downloaded.csv."
            return $false
        }
    }

    if (Test-Path -Path "$FilePath") {
        $filePathHash = Get-FileHash -Path $FilePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    } else {
        $filePathHash = ""
    }

    # Save original FilePath before transformation for potential retry
    $OriginalFilePath = $FilePath

    # Remove any leading '..' from the file path and set up temporary file path and final file path
    $CleanPath = $FilePath -replace "^..", ""
    $TmpFilePath= "$PSScriptRoot\..\..\tmp\$CleanPath"
    $FilePath = "$PSScriptRoot\..\..\$CleanPath"
    $retries = 3
    $downloaded = $false
    $ProgressPreference = 'SilentlyContinue'

    # Ensure the directory for the final file path exists
    If (! ( Test-Path ([System.IO.FileInfo]$FilePath).DirectoryName )) {
        New-Item ([System.IO.FileInfo]$FilePath).DirectoryName -force -type directory | Out-Null
    }

    # Ensure the directory for the temporary file path exists
    If (! ( Test-Path ([System.IO.FileInfo]$TmpFilePath).DirectoryName )) {
        New-Item ([System.IO.FileInfo]$TmpFilePath).DirectoryName -force -type directory | Out-Null
    }

    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write("$Uri")
    $writer.Flush()
    $stringAsStream.Position = 0
    $UriHash = $(Get-FileHash -InputStream $stringAsStream -Algorithm SHA256 | Select-Object -ExpandProperty Hash)
    $ETAG_FILE = "$PSScriptRoot\..\..\downloads\.etag\${UriHash}"

    # Remove etag if file doesn't exist
    if (! (Test-Path "$FilePath")) {
        Remove-Item -Force "${ETAG_FILE}" -ErrorAction SilentlyContinue
    }

    if ("Yes" -eq "${CheckURL}") {
        $ETAG_FLAG = ""
        $Z_FLAG = ""
    } else {
        if (Test-Path "${ETAG_FILE}") {
            $ETAG_FLAG = "--etag-compare ${ETAG_FILE} --etag-save ${ETAG_FILE}"
        } else {
            $ETAG_FLAG = "--etag-save ${ETAG_FILE}"
        }
        if (Test-Path $FilePath) {
            $Z_FLAG = "-z $FilePath"
        } else {
            $Z_FLAG = ""
        }
    }

    # Attempt to download the file from the specified URI
    while($true) {
        try {
            Remove-Item -Force $TmpFilePath -ErrorAction SilentlyContinue

            if ($Uri -like "*github.com*" -and "" -ne $GH_USER -and "" -ne $GH_PASS) {
                $GH_FLAG = "-u ${GH_USER}:${GH_PASS}"
            } else {
                $GH_FLAG = ""
            }

            if ($Uri -like "*sourceforge.net*") {
                $UA_FLAG = '--user-agent "Wget x64"'
            } elseif ($Uri -like "*.amazonaws.com*") {
                $UA_FLAG = '--user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"'
            } else {
                $UA_FLAG = ""
            }

            if ($Uri -like "*marketplace.visualstudio.com*") {
                Invoke-WebRequest -uri "${Uri}" -outfile "${TmpFilePath}"
            } else {
                $CMD = "C:\Windows\system32\curl.exe"
                $FLAGS = @()
                (Write-Output "$ETAG_FLAG $Z_FLAG $GH_FLAG $UA_FLAG -L --silent --output $TmpFilePath $Uri").split(" ") | ForEach-Object {if ("" -ne $_ ) {$FLAGS += $_}}
                $COMMAND_LINE = $CMD + " " + $FLAGS -join " "
                Invoke-Expression $COMMAND_LINE
            }
            if (Test-Path $TmpFilePath) {
                Write-SynchronizedLog "Downloaded $Uri to $FilePath."
                $downloaded = $true
                # Check if size of ETAG file is less then 10 bytes and remove it if it is
                if (Test-Path $ETAG_FILE) {
                    if ((Get-Item $ETAG_FILE).length -lt 10) {
                        Remove-Item -Force $ETAG_FILE
                    }
                }
            }
            break
        }
        catch {
            if ($retries -gt 0) {
                $retries--
                Write-SynchronizedLog "Waiting 10 seconds before retrying. Retries left: $retries"
                Start-Sleep -Seconds 10
            } else {
                $exception = $_.Exception
                $exceptionMessage = $_.Exception.Message
                Write-SynchronizedLog "Failed to download '$Uri': $exceptionMessage"
                throw $exception
            }
        }
    }

    if (Test-Path $TmpFilePath) {
        $TmpFilePathHash = Get-FileHash -Path $TmpFilePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
    } else {
        $TmpFilePathHash = ""
    }

    if ($TmpFilePathHash -ne $filePathHash) {
        $fileDownloadedOrChanged = $true
    }

    if ($downloaded) {
        # Check if downloaded file is the correct type with help of $GIT_CHECK and the value of $check
        if ($check -ne "" ) {
            $FILE_TYPE = & "$GIT_FILE" -b "$TmpFilePath"
            # Check if the file type is correct - Git file returns "data" for some zip files
            if (!(($FILE_TYPE | Select-String -Pattern $check -Quiet) -or ($check -eq "Zip archive data" -and $FILE_TYPE -eq "data"))) {
                Write-SynchronizedLog "Error: Received file, ${FilePath}, is not the correct type. Type: $FILE_TYPE"
                Remove-Item $TmpFilePath -Force | Out-Null
                return $false
            }
        }
        # Copy the temporary file to the final file path and remove the temporary file
        try {
            $result = rclone --log-level ERROR copyto --metadata --inplace --checksum "${TmpFilePath}" "${FilePath}" | Out-String
            if ("" -eq $result) {
                $result = "OK status from rclone copyto '${TmpFilePath}' '${FilePath}'."
            }
        }
        catch {
            $exception = $_.Exception
            $exceptionMessage = $_.Exception.Message
            Write-SynchronizedLog "Failed to rclone copyto '${TmpFilePath}' '${FilePath}': $exceptionMessage"
        }
        Write-SynchronizedLog "$result"
        Remove-Item $TmpFilePath -Force | Out-Null
        Update-ToolsDownloaded -URL $Uri -Name ([System.IO.FileInfo]$FilePath).Name -Path $FilePath
    } else {
        # Etag matched - verify file actually exists
        if (Test-Path $FilePath) {
            Write-SynchronizedLog "Already downloaded $Uri according to etag (${ETAG_FILE})."
            return $false
        } else {
            # Prevent infinite recursion
            if ($RetryDepth -ge 1) {
                Write-Error "Download retry failed - file still missing after $RetryDepth attempts"
                return $false
            }

            Write-SynchronizedLog "Etag matched but file missing - removing etag and retrying download (attempt $($RetryDepth + 1))"
            Remove-Item -Force "${ETAG_FILE}" -ErrorAction SilentlyContinue
            # Retry the download without etag using original FilePath parameter
            return Get-FileFromUri -Uri $Uri -FilePath $OriginalFilePath -check $check -CheckURL "Yes" -RetryDepth ($RetryDepth + 1)
        }
    }
    $ProgressPreference = 'Continue'

    return $fileDownloadedOrChanged
}

# Retrieves the download URL for a GitHub release based on a provided regex match.
function Get-DownloadUrl {
    Param (
        [Parameter(Mandatory=$True)] [string]$releases,
        [Parameter(Mandatory=$True)] [string]$match
    )
    try {
        # Retrieve the download URLs and filter them based on the provided regex match
        if ($GH_USER -eq "" -or $GH_PASS -eq "") {
            $downloads = (curl.exe --silent -L $releases | ConvertFrom-Json)[0].assets.browser_download_url
        } else {
            $downloads = (curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releases | ConvertFrom-Json)[0].assets.browser_download_url
        }
    }
    catch {
        $downloads = ""
    }

    if (!$downloads) {
        try {
            if ($GH_USER -eq "" -or $GH_PASS -eq "") {
                $downloads = (curl.exe --silent -L $releases | ConvertFrom-Json).assets[0].browser_download_url
            } else {
                $downloads = (curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releases | ConvertFrom-Json).assets[0].browser_download_url
            }
        }
        catch {
            $downloads = ""
        }
    }

    if (!$downloads) {
        return ""
    }

    if ( ( Write-Output $downloads | Measure-Object -word ).Words -gt 1 ) {
        return $downloads -replace ' ', "`r`n" | findstr /R $match | findstr /R /V "darwin \.sig blockmap \.sha256 \.asc" | Select-Object -First 1
    } else {
        return $downloads
    }
}

# Retrieves the download URL for the latest release of a GitHub repository.
function Get-GitHubRelease {
    Param (
        [Parameter(Mandatory=$True)] [string]$repo,
        [Parameter(Mandatory=$True)] [string]$path,
        [Parameter(Mandatory=$True)] [string]$match,
        [Parameter(Mandatory=$False)] [string]$version = "latest",
        [Parameter(Mandatory=$False)] [string]$check = ""
    )

    $Url = ""

    if ($version -eq "latest") {
        Write-SynchronizedLog "Getting the latest release for $repo."

        # Construct the URL to get the latest release information
        $releasesURL = "https://api.github.com/repos/$repo/releases/latest"

        # Get the download URL by matching the specified regex pattern
        $latest_release = curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releasesURL | ConvertFrom-Json

        foreach ($asset in $latest_release.assets) {
            if ($asset.browser_download_url -match $match) {
                $Url = $asset.browser_download_url
                Write-Output "Found download URL: $Url"
            }
        }
    }

    if (!$Url) {
        if ($version -eq "latest") {
            Write-SynchronizedLog "No download URL found for $repo. Trying without 'latest'."
            }
        $releasesURL = "https://api.github.com/repos/$repo/releases"
        $releases = curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" "$releasesURL" | ConvertFrom-Json

        :releaseLoop foreach ($release in $releases) {
            foreach ($asset in $release.assets) {
                if ($asset.browser_download_url -match $match) {
                    if ($release.tag_name -eq $version) {
                        $Url = $asset.browser_download_url
                        Write-Output "Found download URL: $Url"
                        break releaseLoop
                    } elseif ($version -eq "latest") {
                        $Url = $asset.browser_download_url
                        Write-Output "Found download URL: $Url"
                        break releaseLoop
                    }
                }
            }
        }
    }

    # If still no download URL is found, fail gracefully
    if ( !$Url ) {
        Write-SynchronizedLog "Error: No matching release asset found for repo $repo with pattern '$match'."
        return $false
    }

    # Log the chosen URL and download the file
    Write-SynchronizedLog "Using $Url for $repo."
    return Get-FileFromUri -uri $Url -FilePath $path -CheckURL "Yes" -check $check
}

# Retrieves the download URL from a web page based on a specified regular expression pattern.
function Get-DownloadUrlFromPage {
    param (
        [Parameter(Mandatory=$True)] [string]$Url,
        [Parameter(Mandatory=$True)] [regex]$RegEx,
        [Parameter(Mandatory=$False)] [switch]$last
    )

    $downloadUrl = ""
    $retries = 3

    while ("$downloadUrl" -eq "") {
        try {
            if ($Url -contains "github.com") {
                if ($last) {
                    if ($GH_USER -eq "" -or $GH_PASS -eq "") {
                        $downloadUrl = curl.exe --silent -L "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -Last 1
                    } else {
                        $downloadUrl = curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -Last 1
                    }
                } else {
                    if ($GH_USER -eq "" -or $GH_PASS -eq "") {
                        $downloadUrl = curl.exe --silent -L "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -First 1
                    } else {
                        $downloadUrl = curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -First 1
                    }
                }
            } else {
                if ($last) {
                    $downloadUrl = curl.exe --silent -L "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -Last 1
                } else {
                    $downloadUrl = curl.exe --silent -L "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -First 1
                }
            }
        }
        catch {
            $downloadUrl = ""
        }
        if ("$downloadUrl" -eq "") {
            Start-Sleep 60
        }
        $retries--
        if ($retries -eq 0) {
            Write-DateLog "Failed to get download URL from $Url."
            return ""
        }
    }

    # Trim any whitespace
    $downloadUrl = $downloadUrl.Trim()

    Write-SynchronizedLog "DEBUG: Extracted URL from page: '$downloadUrl'"

    # If the URL is relative (doesn't start with http:// or https://), make it absolute
    if (-not ($downloadUrl -match "^https?://")) {
        Write-SynchronizedLog "DEBUG: URL is relative, constructing absolute URL"
        # Extract base URL (protocol + domain)
        if ($Url -match "^(https?://[^/]+)") {
            $baseUrl = $matches[1]
            # Handle leading slash in relative URL
            if ($downloadUrl -match "^/") {
                # Absolute path on same domain
                $downloadUrl = "$baseUrl$downloadUrl"
            } else {
                # Relative path
                $downloadUrl = "$baseUrl/$downloadUrl"
            }
            Write-SynchronizedLog "DEBUG: Constructed absolute URL: '$downloadUrl'"
        }
    } else {
        Write-SynchronizedLog "DEBUG: URL is already absolute"
    }

    return $downloadUrl
}

# Function to write a synchronized log to a specified file.
function Write-SynchronizedLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message,
        [Parameter(Mandatory=$false)] [string]$LogFile = "$PSScriptRoot\..\..\log\log.txt"
    )

    $logMutex = New-Object -TypeName 'System.Threading.Mutex' -ArgumentList $false, 'Global\dfirwsLogMutex'

    try {
        $result = $logMutex.WaitOne()
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $fullMessage = "$timestamp - $Message"
        Add-Content -Path $LogFile -Value $fullMessage 2>&1 | Out-Null
    }
    finally {
        $result = $logMutex.ReleaseMutex()
    }

    if (!$result) {
        Write-Debug "Error"
    }
}

# Write a log entry with a timestamp.
function Write-DateLog {
    param (
        [Parameter(Mandatory=$True)] [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullMessage = "$timestamp - $Message"
    Write-Output $fullMessage
}

# Comparison can only be done for the URL field since we don't have a hash for remote files
function Compare-ToolsDownloaded {
    param (
        [Parameter(Mandatory=$True)] [string]$URL,
        [Parameter(Mandatory=$True)] [string]$AppName
    )
    # Bad linter...
    $null=$AppName

    if (Test-Path "$PSScriptRoot\..\..\downloads\tools_downloaded.csv") {
        $toolsDownloaded = Import-Csv "$PSScriptRoot\..\..\downloads\tools_downloaded.csv"
    } else {
        $toolsDownloaded = [System.Collections.Generic.List[PSCustomObject]] @()
    }

    $localFile = $toolsDownloaded | Where-Object { $_.Name -eq $AppName }

    # No local file found
    if (!$localFile) {
        return $false
    }

    # Is it the same URL?
    if ($localFile.URL -eq $URL) {
        return $true
    } else {
        return $false
    }
}

# Update the tools_downloaded.csv file
function Update-ToolsDownloaded {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True)] [string]$URL,
        [Parameter(Mandatory=$True)] [string]$Name,
        [Parameter(Mandatory=$True)] [string]$Path
    )
    if (Test-Path "$PSScriptRoot\..\..\downloads\tools_downloaded.csv") {
        $toolsDownloaded = [System.Collections.Generic.List[PSCustomObject]] (Import-Csv "$PSScriptRoot\..\..\downloads\tools_downloaded.csv")
    } else {
        $toolsDownloaded = [System.Collections.Generic.List[PSCustomObject]] @()
    }

    $localFile = $toolsDownloaded | Where-Object { $_.Name -eq $Name }

    # No local file found
    if (!$localFile) {
        $addNewTool = [PSCustomObject]@{
            URL = $URL
            Name = $Name
            SHA256 = Get-FileHash -Path $Path -Algorithm SHA256 | Select-Object -ExpandProperty Hash
            Size = Get-Item $Path | Select-Object -ExpandProperty Length
            Path = Resolve-Path -Path $Path
        }

        $toolsDownloaded.Add($addNewTool)
    } else {
        $localFile.URL = $URL
    }

    if($PSCmdlet.ShouldProcess($file.Name)) {
        $toolsDownloaded.ToArray() | Export-Csv "$PSScriptRoot\..\..\downloads\tools_downloaded.csv" -NoTypeInformation
    }
}

# Function to clear tmp directory
function Clear-Tmp {
    param (
        [Parameter(Mandatory=$True)] [string]$Folder
    )

    if (Test-Path -Path ".\tmp\${Folder}") {
        Remove-Item -Recurse -Force ".\tmp\${Folder}" > $null 2>&1
    }
}

# Function to download via winget
function Get-Winget {
    param (
        [Parameter(Mandatory=$true)] [string]$AppName,
        [Parameter(Mandatory=$true)] [string]$TmpFileName,
        [Parameter(Mandatory=$true)] [string]$DownloadName,
        [Parameter(Mandatory=$false)] [string]$check = ""
    )

    $VERSION = (winget search --exact --id "$AppName") -match '^([A-Z0-9]+|-)' | Select-Object -Last 1 | ForEach-Object { ($_ -split("\s+"))[-2] }

    Clear-Tmp winget
    if (Test-Path ".\downloads\$DownloadName") {
        if (Compare-ToolsDownloaded -URL $VERSION -AppName $AppName) {
            Write-SynchronizedLog "File $AppName version $VERSION already downloaded."
            return
        }
    }

    Write-SynchronizedLog "Downloading $AppName version $VERSION."

    winget download --disable-interactivity	--exact --id "$AppName" -d .\tmp\winget 2>&1 | Out-Null
    Remove-Item .\tmp\winget\*.yaml -Force 2>&1 | Out-Null

    $FileName = Get-ChildItem .\tmp\winget\ | Select-Object -Last 1 -ExpandProperty FullName

    if ($check -ne "" ) {
        $FILE_TYPE = & "$GIT_FILE" -b "$FileName"
        if (!($FILE_TYPE | Select-String -Pattern $check -Quiet)) {
            Write-SynchronizedLog "Error: Downloaded file, ${FileName}, is not the correct type. Type: $FILE_TYPE"
            Remove-Item $FileName -Force | Out-Null
            return $false
        }
        if ($FILE_TYPE.Contains("Zip archive data")) {
            $7Z_TEST = 7z t -pprocdot -bb0 -bd $FileName
            if (! ($7Z_TEST.Contains("Everything is Ok"))) {
                Write-SynchronizedLog "Error: Downloaded file, ${FileName}, did not pass 7z test. Result: $7Z_TEST"
                Remove-Item $FileName -Force | Out-Null
                return $false
            }
        } elseif ($FILE_TYPE.Contains("RAR archive data")) {
            $RAR_TEST = 7z t -bb0 -bd $FileName
            if (! ($RAR_TEST.Contains("All OK"))) {
                Write-SynchronizedLog "Error: Downloaded file, ${FileName}, did not pass 7z test. Result: $RAR_TEST"
                Remove-Item $FileName -Force | Out-Null
                return $false
            }
        } elseif ($FILE_TYPE.Contains("Composite Document File V2 Document")) {
            $MSI_TEST = 7z t -bb0 -bd $FileName
            if (! ($MSI_TEST.Contains("Everything is Ok"))) {
                Write-SynchronizedLog "Error: Downloaded file, ${FileName}, did not pass 7z test. Result: $MSI_TEST"
                Remove-Item $FileName -Force | Out-Null
                return $false
            }
        }
    }

    Update-ToolsDownloaded -URL $VERSION -Name $AppName -Path $FileName

    Get-ChildItem .\tmp\winget\ | ForEach-Object {
        if ($_.Name -ne ".\tmp\winget\$TmpFileName") {
            Copy-Item $_.FullName ".\downloads\$DownloadName" -Force
        }
    }

    Clear-Tmp winget

    return $true
}

# Function to wait for the sandbox to finish
function Wait-Sandbox {
    param (
        [Parameter(Mandatory=$True)] [string]$WSBPath,
        [Parameter(Mandatory=$True)] [string]$WaitForPath
    )

    $sandboxRunning = $true

    while ($sandboxRunning) {
        if (Test-Path -Path $WaitForPath) {
            Write-SynchronizedLog "Sandbox finished."
            $sandboxRunning = $false
        } else {
            Start-Sleep -Seconds 5
        }
    }

    Stop-Sandbox

    if (Test-Path -Path $WSBPath) {
        Remove-Item -Force $WSBPath | Out-Null
    }

    if (Test-Path -Path $WaitForPath) {
        Remove-Item -Force $WaitForPath | Out-Null
    }
}

# Function to stop the sandbox
function Stop-Sandbox {
    [CmdletBinding(SupportsShouldProcess)]
    param (
    )
    Stop-Process -Name WindowsSandboxClient -Force -ErrorAction SilentlyContinue
    Stop-Process -Name WindowsSandboxRemoteSession -Force -ErrorAction SilentlyContinue
    Start-Sleep 5
}
