# Download and update files for the sandbox

$TOOLS=".\mount\Tools"

. .\resources\download\common.ps1

Remove-Item -r $TOOLS > $null 2>$1
mkdir $TOOLS > $null 2>$1
mkdir $TOOLS\bin > $null 2>$1
mkdir $TOOLS\DidierStevens > $null 2>$1
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
    Write-Output "" > .\log\npm.txt
    Write-Output "" > .\log\python.txt
}
Remove-Item -Recurse -Force .\tmp\downloads\ > $null 2>&1

# The scripts git and http are needed by the Python script.
# Most scripts need http.ps1.
.\resources\download\http.ps1
Write-DateLog "Download packages for Git for Windows (bash)."
Start-Job -FilePath .\resources\download\bash.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
Write-DateLog "Setup node and install npm packages."
Start-Job -FilePath .\resources\download\node.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
.\resources\download\git.ps1
Write-DateLog "Download Python pip packages."
Start-Job -FilePath .\resources\download\python.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
.\resources\download\release.ps1
.\resources\download\didier.ps1
.\resources\download\zimmerman.ps1
Write-DateLog "Wait for build."
Get-Job | Wait-Job | Out-Null
Write-DateLog "Done waiting."
Write-DateLog "Prepare downloaded files."
$result = .\resources\download\unpack.ps1 2>&1
Write-SynchronizedLog "$result"
Write-DateLog "Copy files."
Copy-Item README.md .\downloads\
Copy-Item .\resources\images\dfirws.jpg .\downloads\
# done.txt is used to check last update in sandbox
Write-Output "" > .\downloads\done.txt
Write-DateLog "Download and preparations done."
