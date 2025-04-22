# Sync files to USB disc
$SOURCE_DIRECTORY="$HOME\Documents\workspace\dfirws"
$CURRENT="$PWD"

if ($args -contains "--zip") {
    Set-Location "$SOURCE_DIRECTORY"
    Start-Process -Wait 'C:\Program Files\7-Zip\7z.exe' -Argumentlist "a .\tmp\dfirws.zip .\downloads .\enrichment .\mount .\setup"
    Get-Job | Receive-Job
    Get-Job | Remove-Job
    Copy-Item ".\tmp\dfirws.zip" "$CURRENT"
    Remove-Item -Force ".\tmp\dfirws.zip"
    Set-Location "$CURRENT"
}

if (! (Test-Path .\dfirws\local) ) {
    New-Item -ItemType Directory .\dfirws\local
}

foreach ($folder in "vscode") {
    if (! (Test-Path .\dfirws\local\$folder) ) {
        New-Item -ItemType Directory .\dfirws\local\$folder -Force
    }
}

Robocopy.exe $SOURCE_DIRECTORY\downloads .\dfirws\downloads /MIR /MT:96
Robocopy.exe $SOURCE_DIRECTORY\enrichment .\dfirws\enrichment /MIR /MT:96
Robocopy.exe $SOURCE_DIRECTORY\local\defaults .\dfirws\local\defaults /MIR /MT:96
Robocopy.exe $SOURCE_DIRECTORY\mount .\dfirws\mount /MIR /MT:96
Robocopy.exe $SOURCE_DIRECTORY\resources .\dfirws\resources /MIR /MT:96
Robocopy.exe $SOURCE_DIRECTORY\setup .\dfirws\setup /MIR /MT:96

Copy-Item $SOURCE_DIRECTORY\createSandboxConfig.ps1 .\dfirws\
Copy-Item $SOURCE_DIRECTORY\README.md .\dfirws\
