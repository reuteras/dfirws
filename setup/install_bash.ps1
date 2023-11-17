$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1

# This script runs in a Windows sandbox to uncompress zst files.
Write-DateLog "Uncompress zst files for Git for Windows (bash)" > "C:\log\bash.txt" 2>&1

New-Item -ItemType Directory "$TEMP" > $null 2>&1
New-Item -ItemType Directory "$TOOLS" > $null 2>&1

Copy-Item "$SETUP_PATH\7zip.msi" "$TEMP\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\7zip.msi /qn /norestart"
Get-Job | Receive-Job | Out-Default >> "C:\log\bash.txt" 2>&1

Write-Output "Get-Content C:\log\bash.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Start-Process -Wait "$env:ProgramFiles\7-Zip\7z.exe" -ArgumentList "x -aoa $SETUP_PATH\zstd.zip -o$TOOLS\zstd"
Get-Job | Receive-Job | Out-Default >> "C:\log\bash.txt" 2>&1

Set-Location C:\bash
Remove-Item -Force *.tar
Get-ChildItem -Include * |
    ForEach-Object {
        Start-Process -Wait "$TOOLS\zstd\zstd.exe" -ArgumentList "-d $_"
    }

Get-Job | Receive-Job | Out-Default >> "C:\log\bash.txt" 2>&1
Write-DateLog "Uncompress of zst files done." >> "C:\log\bash.txt" 2>&1
Write-Output "" > C:\bash\done
