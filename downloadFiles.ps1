# Download and update files for the sandbox

$TOOLS=".\mount\Tools"

Remove-Item -r $TOOLS > $null 2>$1
mkdir $TOOLS > $null 2>$1
mkdir $TOOLS\bin > $null 2>$1
mkdir $TOOLS\DidierStevens > $null 2>$1
mkdir $TOOLS\lib > $null 2>$1
mkdir $TOOLS\Zimmerman > $null 2>$1

if ( tasklist | findstr Sandbox ) {
    Write-Output "Sandbox can't be running during install or upgrade."
    Exit
}

if (!(Test-Path .\downloads)) {
    New-Item -ItemType Directory -Force -Path .\downloads > $null 2>&1
}

# Cleanup
if (Test-Path -Path .\log\log.txt) {
    Remove-Item .\log\log.txt
}
if (Test-Path -Path .\log\npm.txt) {
    Remove-Item .\log\npm.txt
    Write-Output "" > .\log\npm.txt
}
if (Test-Path -Path .\log\python.txt) {
    Remove-Item .\log\python.txt
    Write-Output "" > .\log\python.txt
}
Remove-Item -Recurse -Force .\tmp\downloads\ > $null 2>&1

# The scripts git, http and release are needed by the Python script.
.\resources\download\http.ps1
Write-Output "Setup node and install npm packages."
Start-Job -FilePath .\resources\download\node.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
.\resources\download\git.ps1
.\resources\download\release.ps1
Write-Output "Download Python pip packages."
Start-Job -FilePath .\resources\download\python.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
.\resources\download\didier.ps1
.\resources\download\zimmerman.ps1
Write-Output "Wait for build."
Get-Job | Wait-Job | Out-Null
Write-Output "Done waiting."
.\resources\download\unpack.ps1

Write-Output "Copy files."
Copy-Item README.md .\downloads\
Copy-Item .\resources\images\dfirws.jpg .\downloads\
# done.txt is used to check last update in sandbox
Write-Output "" > .\downloads\done.txt
Write-Output "Download and preparations done."
