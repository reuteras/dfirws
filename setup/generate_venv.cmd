rem Set variables
set SETUP_PATH=C:\downloads
set TEMP=C:\tmp
set TOOLS=C:\Tools

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
echo Get-Content C:\log\python.txt -Wait > C:\Progress.ps1
echo PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1 > C:\Users\WDAGUtilityAccount\Desktop\Progress.cmd
PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\install_python_tools.ps1 -Force > C:\log\python.txt 2>&1
echo "" > C:\venv\done
shutdown /s /t 1 /c "Done with installing Python pip packages." /f /d p:4:1
