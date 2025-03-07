# Install and update kape if kape.zip is present

. ".\resources\download\common.ps1"

if (test-path .\local\kape.zip) {
    Write-DateLog "kape.zip found. Will add and update Kape for dfirws."
} else {
    Write-DateLog "kape.zip not found. Will not add or update Kape for dfirws."
    Write-dateLog "If you want to add Kape place your copy of kape.zip in the local directory."
    Exit
}

if (! (Test-Path -Path "$SETUP_PATH\KAPE" )) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\local\kape.zip" -o"$SETUP_PATH" | Out-Null
    if (Test-Path "$SETUP_PATH\Get-KAPEUpdate.ps1") {
        Remove-Item "$SETUP_PATH\Get-KAPEUpdate.ps1"  -Force
    }
}

$CURRENT_DIR = $PWD

Copy-Item ".\resources\external\KAPE-EZToolsAncillaryUpdater.ps1" "$SETUP_PATH\KAPE\KAPE-EZToolsAncillaryUpdater.ps1" -Force
Set-Location "$SETUP_PATH\KAPE"
& .\KAPE-EZToolsAncillaryUpdater.ps1 -silent *> $CURRENT_DIR\log\kape.txt
Set-Location $CURRENT_DIR
