C:\downloads\python3.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
echo Get-Content C:\python.log -Wait > C:\Progress.ps1
echo PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1 > C:\Users\WDAGUtilityAccount\Desktop\Progress.cmd
PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\install_python_tools.ps1 > C:\python.log 2>&1
echo "" > C:\venv\done
shutdown /s /t 1 /c "Done with installing Python pip packages." /f /d p:4:1