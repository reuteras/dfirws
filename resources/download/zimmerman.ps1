. "${PSScriptRoot}\common.ps1"

# Download and update Zimmerman tools. Copy to tools folder afterwards.
.\resources\download\Get-ZimmermanTools.ps1 -Dest ".\downloads\Zimmerman" 2>&1 >> ".\log\log.txt"
