$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# This script runs in a Windows sandbox to uncompress zst files.
Write-Output "Uncompress zst files for Git for Windows (bash)" > "C:\log\bash.txt" 2>&1

# Set variables
$SETUP_PATH="C:\downloads"
$TOOLS="C:\Tools"
$TEMP="C:\tmp"

mkdir "$TEMP" > $null 2>&1
mkdir "$TOOLS" > $null 2>&1

Copy-Item "$SETUP_PATH\7zip.msi" "$TEMP\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\7zip.msi /qn /norestart"
Get-Job | Receive-Job >> "C:\log\bash.txt" 2>&1

Write-Output "Get-Content C:\log\bash.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Update path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\zstd.zip" -o"$TOOLS\zstd" >> "C:\log\bash.txt" 2>&1

Set-Location C:\bash >> "C:\log\bash.txt" 2>&1
Remove-Item -Force *.tar >> "C:\log\bash.txt" 2>&1
Get-ChildItem -Include * |
    ForEach-Object {
        Start-Process -Wait "$TOOLS\zstd\zstd.exe" -ArgumentList "-d $_"
    }

Get-Job | Receive-Job >> "C:\log\bash.txt" 2>&1
Write-Output "Uncompress of zst files done." >> "C:\log\bash.txt" 2>&1
Write-Output "" > C:\bash\done

shutdown /s /t 1 /c "Done with uncompressing zst files." /f /d p:4:1