# Set the default encoding for Out-File to UTF-8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Variables used by the script
$CONFIGURATION_FILES = ".\local"
$SETUP_PATH = ".\downloads"
$WSDFIR_TEMP = "C:\tmp"
$TOOLS = ".\mount\Tools"
$SANDBOX_TOOLS = "C:\Tools"
$mutexName = "Global\dfirwsMutex"

$null=$CONFIGURATION_FILES
$null=$SANDBOX_TOOLS
$null=$SETUP_PATH
$null=$WSDFIR_TEMP
$null=$TOOLS
$null=$mutexName

if (!(Test-Path variable:GIT_FILE)) {
    $GIT_FILE = "C:\Program Files\Git\usr\bin\file.exe"
}

<#
.SYNOPSIS
Function to download a file from a given URI and save it to a specified file path.

.DESCRIPTION
This function allows you to download a file from a specified URI and save it to a specified file path on your local machine.

.PARAMETER Uri
The URI of the file to be downloaded.

.PARAMETER FilePath
The file path where the downloaded file will be saved.

.PARAMETER CheckURL
Specifies whether to check the URL for the file in the tools_downloaded.csv file.

.OUTPUTS
System.Boolean - Returns $true if the file was successfully downloaded and saved, $false otherwise.

.EXAMPLE
Get-FileFromUri -Uri "https://example.com/file.txt" -FilePath "C:\Downloads\file.txt"
Downloads the file from the specified URI and saves it to the specified file path.

.NOTES
Author: peter@reuteras.net
Date:   2023-12-21
#>
function Get-FileFromUri {
    Param (
        [Parameter(Mandatory=$True)] [string]$Uri,
        [Parameter(Mandatory=$True)] [string]$FilePath,
        [Parameter(Mandatory=$False)] [string]$CheckURL = "",
        [Parameter(Mandatory=$False)] [string]$check = ""
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
                $UA_FLAG = '--user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"'
            } else {
                $UA_FLAG = ""
            }

            if ($Uri -like "*marketplace.visualstudio.com*") {
                Invoke-WebRequest -uri "${Uri}" -outfile "${TmpFilePath}"
            } else {
                $CMD = "curl.exe"
                $FLAGS = @()
                (Write-Output "$ETAG_FLAG $Z_FLAG $GH_FLAG $UA_FLAG --silent -L --output $TmpFilePath $Uri").split(" ") | ForEach-Object {if ("" -ne $_ ) {$FLAGS += $_}}
                & $CMD $FLAGS
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
            if (!($FILE_TYPE | Select-String -Pattern $check -Quiet)) {
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
        Write-SynchronizedLog "Already downloaded $Uri according to etag (${ETAG_FILE})."
        return $false
    }
    $ProgressPreference = 'Continue'

    return $fileDownloadedOrChanged
}

<#
.SYNOPSIS
Retrieves the download URL for a GitHub release based on a provided regex match.

.DESCRIPTION
The Get-DownloadUrl function retrieves the download URL for a GitHub release by querying the GitHub API and filtering the results based on a provided regex match. It supports authentication using GitHub credentials.

.PARAMETER releases
The URL of the GitHub API endpoint that provides information about the releases.

.PARAMETER match
A regex pattern used to filter the download URLs. Only URLs that match the pattern will be returned.

.EXAMPLE
$releases = "https://api.github.com/repos/username/repo/releases/latest"
$match = ".*\.zip$"
$downloadUrl = Get-DownloadUrl -Releases $releases -Match $match
Retrieves the download URL for the latest release of the specified GitHub repository that ends with ".zip".

.NOTES
Author: peter@reuteras.net
Date:   2023-12-21
#>
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

<#
.SYNOPSIS
    Retrieves the download URL for the latest release of a GitHub repository.

.DESCRIPTION
    The Get-GitHubRelease function retrieves the download URL for the latest release of a GitHub repository. It uses the GitHub API to fetch the release information and matches the specified regex pattern to find the download URL.

.PARAMETER repo
    Specifies the GitHub repository in the format "owner/repo".

.PARAMETER path
    Specifies the local file path where the downloaded file will be saved.

.PARAMETER match
    Specifies the regex pattern used to match the desired download URL.

.EXAMPLE
    Get-GitHubRelease -repo "Microsoft/PowerShell" -path "C:\Downloads" -match ".*\.zip"

    This example retrieves the download URL for the latest release of the "Microsoft/PowerShell" repository and saves the downloaded file to the "C:\Downloads" directory. It matches the download URL that ends with ".zip".

.NOTES
    - This function requires an internet connection to access the GitHub API.
    - If the specified regex pattern does not match any download URL in the release information, the function will try to find the download URL without using the "latest" release.
    - If no download URL is found, the function will try to get the tarball URL.
    - If the tarball URL is also not found, an error will be displayed and the function will exit.
#>
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

    # If still no download URL is found, try getting the tarball URL
    if ( !$Url ) {
        $releases = "https://api.github.com/repos/$repo/releases/latest"
        $Url = (curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" $releases | ConvertFrom-Json).zipball_url.ToString()

        if ( !$Url) {
            Write-Error "Can't find a file to download for repo $repo."
            Exit
        } else {
            Write-SynchronizedLog "Using tarball URL for $repo."
        }
    }

    # Log the chosen URL and download the file
    Write-SynchronizedLog "Using $Url for $repo."
    return Get-FileFromUri -uri $Url -FilePath $path -CheckURL "Yes" -check $check
}

<#
.SYNOPSIS
Retrieves the download URL from a web page based on a specified regular expression pattern.

.DESCRIPTION
The Get-DownloadUrlFromPage function retrieves the download URL from a web page by sending an HTTP request and parsing the response using a regular expression pattern. It supports authentication for GitHub URLs if the GH_USER and GH_PASS environment variables are set.

.PARAMETER Url
The URL of the web page from which to retrieve the download URL.

.PARAMETER RegEx
The regular expression pattern used to extract the download URL from the web page.

.EXAMPLE
Get-DownloadUrlFromPage -Url "https://example.com" -RegEx "href=\"(.*?)\""

This example retrieves the download URL from the web page "https://example.com" using the regular expression pattern "href=\"(.*?)\"".

.NOTES
Author: Your Name
Date:   Current Date
#>
function Get-DownloadUrlFromPage {
    param (
        [Parameter(Mandatory=$True)] [string]$Url,
        [Parameter(Mandatory=$True)] [regex]$RegEx
    )

    $downloadUrl = ""
    $retries = 3

    while ("$downloadUrl" -eq "") {
        try {
            if ($Url -contains "github.com") {
                if ($GH_USER -eq "" -or $GH_PASS -eq "") {
                    $downloadUrl = curl.exe --silent -L "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -First 1
                } else {
                    $downloadUrl = curl.exe --silent -L -u "${GH_USER}:${GH_PASS}" "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -First 1
                }
            } else {
                $downloadUrl = curl.exe --silent -L "$Url" | Select-String -Pattern "$RegEx" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value | Select-Object -First 1
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

    return $downloadUrl
}

<#
.SYNOPSIS
Stops the Windows Sandbox when a specific condition is met.

.DESCRIPTION
The Stop-SandboxWhenDone function is used to stop the Windows Sandbox when a specific condition is met. It continuously checks for the presence of the Windows Sandbox process and a specified file path. If both conditions are met, it terminates the Windows Sandbox process, removes the specified file, releases the mutex, and exits the function.

.PARAMETER path
Specifies the path of the file that needs to exist in order to stop the Windows Sandbox.

.PARAMETER Mutex
Specifies the mutex object that is used to synchronize access to shared resources.

.EXAMPLE
Stop-SandboxWhenDone -path "C:\Temp\sample.txt" -Mutex $mutex
This example stops the Windows Sandbox when the file "C:\Temp\sample.txt" exists and the mutex object $mutex is released.

.NOTES
Author: peter@reuteras.net
Date:   2023-12-21
#>
function Stop-SandboxWhenDone {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True)] [string]$path,
        [Parameter(Mandatory=$True)] [System.Threading.Mutex] $Mutex
    )

    while ($true) {
        $status = Get-Process WindowsSandboxClient 2> $null
        $status_new = Get-Process WindowsSandboxRemoteSession 2> $null
        if ($status -or $status_new) {
            if ( Test-Path $path ) {
                if($PSCmdlet.ShouldProcess($file.Name)) {
                    (Get-Process WindowsSandboxClient).Kill() 2> $null
                    (Get-Process WindowsSandboxRemoteSession).Kill() 2> $null
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

<#
.SYNOPSIS
Function to write a synchronized log to a specified file.

.DESCRIPTION
This function writes a synchronized log to a specified file. It ensures that multiple threads or processes can write to the log file without conflicts.

.PARAMETER LogFile
The path to the log file where the log will be written.

.PARAMETER Message
The message to be written to the log file.

.EXAMPLE
Write-SynchronizedLog -LogFile "C:\Logs\log.txt" -Message "This is a log message"

This example demonstrates how to use the Write-SynchronizedLog function to write a log message to the specified log file.

.NOTES
Author: peter@reuteras.net
Date:   2023-12-21
#>
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

<#
.SYNOPSIS
Write a log entry with a timestamp.

.DESCRIPTION
This function is used to write a log entry with a timestamp. It can be used to track the execution of a script or record important events.

.PARAMETER Message
The message to be logged.

.EXAMPLE
Write-LogEntry -Message "Script execution started."

This example demonstrates how to use the Write-LogEntry function to write a log entry with a custom message.

#>
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
