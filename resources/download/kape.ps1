# Install and update kape if kape.zip is present

. $PSScriptRoot\common.ps1

if (test-path .\local\kape.zip) {
    Write-DateLog "kape.zip found. Will add and update Kape for dfirws."
} else {
    Write-DateLog "kape.zip not found. Will not add or update Kape for dfirws."
    Write-dateLog "If you want to add Kape place your copy of kape.zip in the local directory."
    Exit
}

& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\local\kape.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\Get-KAPEUpdate.ps1") {
    Remove-Item "$TOOLS\Get-KAPEUpdate.ps1"  -Force
}

$CURRENT_DIR = $PWD

# Download KAPE-EZToolsAncillaryUpdater
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AndrewRathbun/KAPE-EZToolsAncillaryUpdater/main/KAPE-EZToolsAncillaryUpdater.ps1" -OutFile "$TOOLS\KAPE\KAPE-EZToolsAncillaryUpdater.ps1" -UseBasicParsing
Set-Location "$TOOLS\KAPE"
& .\KAPE-EZToolsAncillaryUpdater.ps1 -silent *> $CURRENT_DIR\log\kape.txt
Set-Location $CURRENT_DIR
