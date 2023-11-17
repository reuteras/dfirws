. $PSScriptRoot\common.ps1

.\resources\download\Get-ZimmermanTools.ps1 -Dest .\downloads\Zimmerman >> .\log\log.txt 2>&1

xcopy /E $SETUP_PATH\Zimmerman $TOOLS\Zimmerman | Out-Null
