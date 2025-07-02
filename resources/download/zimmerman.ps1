. ".\resources\download\common.ps1"

# Download and update Zimmerman tools.
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File .\resources\download\Get-ZimmermanTools.ps1 -Dest ".\mount\Tools\Zimmerman" 2>&1 >> ".\log\log.txt"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File .\resources\download\Sync-EZTools.ps1 ".\mount\Tools\Zimmerman" 2>&1 >> ".\log\log.txt"
