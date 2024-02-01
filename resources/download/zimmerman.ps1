. "${PSScriptRoot}\common.ps1"

# Download and update Zimmerman tools.
.\resources\download\Get-ZimmermanTools.ps1 -Dest ".\mount\Tools\Zimmerman" 2>&1 >> ".\log\log.txt"
