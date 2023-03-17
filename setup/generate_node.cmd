rem Set variables
set SETUP_PATH=C:\downloads
set TEMP=C:\tmp
set TOOLS=C:\Tools

mkdir %TEMP%

copy "%SETUP_PATH%\7zip.msi" "%TEMP%\7zip.msi" > C:\log\npm.txt 2>&1
msiexec /i "%TEMP%\7zip.msi" /qn /norestart >> C:\log\npm.txt 2>&1

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
echo Get-Content C:\log\npm.txt -Wait > C:\Progress.ps1
echo PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1 > C:\Users\WDAGUtilityAccount\Desktop\Progress.cmd
PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\install_node.ps1 >> C:\log\npm.txt 2>&1
echo "" > %TOOLS%\node\done
shutdown /s /t 1 /c "Done with installing npm packages." /f /d p:4: