. $PSScriptRoot\common.ps1

# Download and update Zimmerman tools. Copy to tools folder afterwards.
.\resources\download\Get-ZimmermanTools.ps1 -Dest .\downloads\Zimmerman >> .\log\log.txt 2>&1

rclone.exe sync --verbose --checksum $SETUP_PATH\Zimmerman $TOOLS\Zimmerman 2>&1 | Out-Null
