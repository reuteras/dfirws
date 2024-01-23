$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# This script runs in a Windows sandbox to uncompress zst files.
Write-DateLog "Uncompress zst files for Git for Windows (bash)" >> "C:\log\bash.txt"

New-Item -ItemType Directory "${TEMP}" 2>&1 | Out-Null
New-Item -ItemType Directory "${TOOLS}" 2>&1 | Out-Null

Copy-Item "$SETUP_PATH\7zip.msi" "${TEMP}\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i ${TEMP}\7zip.msi /qn /norestart"
Get-Job | Receive-Job | Out-Default >> "C:\log\bash.txt" 2>&1

Write-Output "Get-Content C:\log\bash.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "${HOME}\Desktop\Progress.cmd" -Encoding "ascii"

# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Start-Process -Wait "$env:ProgramFiles\7-Zip\7z.exe" -ArgumentList "x -aoa ${SETUP_PATH}\zstd.zip -o${TOOLS}"
Get-Job | Receive-Job | Out-Default >> "C:\log\bash.txt" 2>&1
Move-Item ${TOOLS}\zstd-* "${TOOLS}\zstd" | Out-Null

Set-Location "C:\bash"
Get-ChildItem | Where-Object Extension -Like '*.zst' |
    ForEach-Object {
        Write-DateLog "Uncompressing $($_.Name)" >> "C:\log\bash.txt"
        & "${TOOLS}\zstd\zstd.exe" --force --rm --decompress "$_" >> "C:\log\bash.txt"
    }

# Some files are compressed with xz even if they have zst extension
Get-ChildItem | Where-Object Extension -Like '*.zst' |
    ForEach-Object {
        Write-DateLog "Uncompressing $($_.Name)" >> "C:\log\bash.txt"
        & "${env:ProgramFiles}\7-Zip\7z.exe" x "$_" -o"." >> "C:\log\bash.txt"
        Remove-Item "$_" -Force >> "C:\log\bash.txt"
    }

Write-DateLog "Uncompress of zst files done." >> "C:\log\bash.txt"
Write-Output "" > "C:\bash\done"
