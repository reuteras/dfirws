# Installing tools
PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\Update-Wallpaper.ps1 C:\Users\WDAGUtilityAccount\Documents\tools\downloads\copying.png
$shell = New-Object -ComObject "Shell.Application"
$shell.sendkeys('{F5}')
