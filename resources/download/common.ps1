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
        Write-Output "Downloading file $FilePath." >> .\log\log.txt
        [void] (New-Object System.Net.WebClient).DownloadFile($uri, $FilePath)
    } else {
        try {
            # Use HttpWebRequest to download file
            $webRequest = [System.Net.HttpWebRequest]::Create($uri);
            $webRequest.IfModifiedSince = ([System.IO.FileInfo]$FilePath).LastWriteTime
            $webRequest.Method = "GET";
            $webRequest.Headers["User-Agent"] = "Wget x64";
            [System.Net.HttpWebResponse]$webResponse = $webRequest.GetResponse()

            # Read HTTP result from the $webResponse
            $stream = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
            # Save to file
            $stream.ReadToEnd() | Set-Content -Path $TmpFilePath -Force
            $hashsourcefile = Get-FileHash $TmpFilePath -Algorithm "SHA256"
            $hashdestfile = Get-FileHash $FilePath -Algorithm "SHA256"
            if (Compare-Object -Referenceobject $hashsourcefile -Differenceobject $hashdestfile) {
                Write-Output "Downloaded new $FilePath" >> .\log\log.txt
                Copy-Item $TmpFilePath $FilePath
            } else {
                Write-Output "$FilePath not modified, not using downloaded file..." >> .\log\log.txt
            }
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
