# Download and update files for the sandbox

if ( tasklist | findstr Sandbox ) {
    Write-Host "Sandbox can't be running during upgrade."
    Exit
}

New-Item -ItemType Directory -Force -Path .\downloads > $null 2>&1

# Cleanup
if (Test-Path -Path .\log\log.txt) {
    Remove-Item .\log\log.txt
}
Remove-Item -Recurse -Force .\tmp\downloads\ > $null 2>&1

# The scripts git, http and release are needed by the Python script.
.\resources\download\git.ps1
.\resources\download\http.ps1
.\resources\download\release.ps1
.\resources\download\python.ps1
.\resources\download\didier.ps1
.\resources\download\zimmerman.ps1
.\resources\download\unpack.ps1

Write-Output "Copy files."
Copy-Item README.md .\downloads\
Copy-Item .\resources\images\dfirws.jpg .\downloads\
# done.txt is used to check last update in sandbox
Write-Output "" > .\downloads\done.txt
Write-Output "Download and preparations done."
