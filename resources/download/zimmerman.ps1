Write-Output "Download Zimmerman tools."

. $PSScriptRoot\common.ps1

.\resources\download\Get-ZimmermanTools.ps1 -Dest .\downloads\Zimmerman >> .\log\log.txt 2>&1
