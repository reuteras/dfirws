# Download and update files for the sandbox

$TOOLS=".\mount\Tools"

. .\resources\download\common.ps1

Remove-Item -r $TOOLS > $null 2>$1
mkdir $TOOLS > $null 2>$1
mkdir $TOOLS\bin > $null 2>$1
mkdir $TOOLS\lib > $null 2>$1
mkdir $TOOLS\Zimmerman > $null 2>$1

if ( tasklist | findstr WindowsSandbox ) {
    Write-DateLog "Sandbox can't be running during install or upgrade."
    Exit
}

# Ensure that we have a log directory and a clean log file
if (! (Test-Path -Path ".\log" )) {
    New-Item -ItemType Directory -Force -Path ".\log" > $null
}
if (! (Test-Path -Path ".\log\log.txt" )) {
    Get-Date > ".\log\log.txt"
}

if (!(Test-Path .\downloads)) {
    New-Item -ItemType Directory -Force -Path .\downloads > $null 2>&1
}

# Cleanup
if (Test-Path -Path .\log\log.txt) {
    Remove-Item .\log\*
    Write-Output "" > .\log\bash.txt
    Write-Output "" > .\log\jobs.txt
    Write-Output "" > .\log\npm.txt
}
Remove-Item -Recurse -Force .\tmp\downloads\ > $null 2>&1

# The scripts git and http are needed by the Python script.
# Most scripts need http.ps1.
# Get GitHub password from user input
$GH_USER = Read-Host "Enter GitHub user name"
$GH_PASS = Read-Host "Enter GitHub token" -AsSecureString
$null = $GH_PASS
$null = $GH_USER
.\resources\download\http.ps1
Write-DateLog "Download packages for Git for Windows (bash)."
Start-Job -FilePath .\resources\download\bash.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
Write-DateLog "Setup Node and install npm packages."
Start-Job -FilePath .\resources\download\node.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
.\resources\download\git.ps1
Write-DateLog "Download Python pip packages."
.\downloadPython.ps1
.\resources\download\release.ps1
.\resources\download\didier.ps1
.\resources\download\winget-download.ps1
.\resources\download\zimmerman.ps1
Write-DateLog "Wait for builds."
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job > .\log\jobs.txt 2>&1
Get-Job | Remove-Job | Out-Null
Write-DateLog "Done waiting."
Write-DateLog "Copy files."
Copy-Item README.md .\downloads\
Copy-Item .\resources\images\dfirws.jpg .\downloads\
Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\"
# done.txt is used to check last update in sandbox
Write-Output "" > .\downloads\done.txt
Write-DateLog "Download and preparations done."
