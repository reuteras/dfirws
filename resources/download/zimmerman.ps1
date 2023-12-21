. $PSScriptRoot\common.ps1

# Download and update Zimmerman tools. Copy to tools folder afterwards.
.\resources\download\Get-ZimmermanTools.ps1 -Dest .\downloads\Zimmerman >> .\log\log.txt 2>&1

xcopy /E $SETUP_PATH\Zimmerman $TOOLS\Zimmerman | Out-Null
