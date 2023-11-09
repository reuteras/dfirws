. .\resources\download\common.ps1

# Ensure that we have a log directory and a clean log file
if (! (Test-Path -Path ".\log" )) {
    New-Item -ItemType Directory -Force -Path ".\log" > $null
}

Write-Output "" > .\log\python.txt

Start-Job -FilePath .\resources\download\python.ps1 -WorkingDirectory $PWD\resources\download -ArgumentList $PSScriptRoot | Out-Null
