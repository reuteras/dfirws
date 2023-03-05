# From https://stackoverflow.com/questions/26533819/how-can-i-download-a-file-only-if-it-has-changed-using-powershell#30129694

if (! (Test-Path -Path .\log )) {
    New-Item -ItemType Directory -Force -Path .\log > $null
}

if (! (Test-Path -Path .\log\log.txt )) {
    Get-Date > .\log\log.txt
}

Function Get-FileFromUri {
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
    if ( -not (Test-Path $FilePath) ) {
        # Use simple download
        Write-Output "Downloading new file $FilePath." >> .\log\log.txt
        $downloader = New-Object System.Net.WebClient
        $downloader.Headers.add("user-agent", "Wget x64")
        $downloader.DownloadFile($uri, $FilePath)
    } else {
        try {
            Write-Output "Downloading file $FilePath." >> .\log\log.txt
            $downloader = New-Object System.Net.WebClient
            $downloader.Headers.add("user-agent", "Wget x64")
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
