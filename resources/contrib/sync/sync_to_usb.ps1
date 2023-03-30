# Sync files to USB disc
$SOURCE_DIRECTORY="$HOME\Documents\workspace\dfirws"
$CURRENT="$PWD"

Set-Location "$SOURCE_DIRECTORY"

Start-Process -Wait 'C:\Program Files\7-Zip\7z.exe' -Argumentlist "a dfirws.zip .\downloads .\mount .\setup"
Get-Job | Receive-Job
Get-Job | Remove-Job
Copy-Item dfirws.zip $CURRENT
Remove-Item -Force dfirws.zip
Set-Location "$CURRENT"

Robocopy.exe $SOURCE_DIRECTORY\downloads .\dfirws\downloads /MIR /XF config.txt /MT:96
Robocopy.exe $SOURCE_DIRECTORY\mount .\dfirws\mount /MIR /MT:96
Robocopy.exe $SOURCE_DIRECTORY\setup .\dfirws\setup /MIR /MT:96

Copy-Item $SOURCE_DIRECTORY\createSandboxConfig.ps1 .\dfirws\
Copy-Item $SOURCE_DIRECTORY\README.md .\dfirws\
Copy-Item $SOURCE_DIRECTORY\dfirws.wsb.template .\dfirws\

if (! (Test-Path .\dfirws\local) ) {
    mkdir .\dfirws\local
}
Copy-Item $SOURCE_DIRECTORY\local\example-customize.ps1 .\dfirws\local