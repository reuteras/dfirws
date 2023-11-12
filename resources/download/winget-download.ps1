. $PSScriptRoot\common.ps1

$TOOLS=".\mount\Tools"
$SETUP_PATH=".\downloads"

Write-DateLog "Download tools via winget."

# Local function
function Clear-Tmp {
    if (Test-Path -Path .\tmp\winget) {
        Remove-Item -Recurse -Force .\tmp\winget > $null 2>&1
    }
}

# DotNet 6 runtime

Clear-Tmp
winget download Microsoft.DotNet.Runtime.6 -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\Microsoft*.exe .\downloads\dotnet6.exe
Clear-Tmp

# VirusTotal CLI
Clear-Tmp
winget download VirusTotal.vt-cli -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\vt-cli*.zip .\downloads\vt.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\vt.zip" -o"$TOOLS\bin" | Out-Null
Clear-Tmp