. $PSScriptRoot\common.ps1

# Local function
function Clear-Tmp {
    if (Test-Path -Path .\tmp\winget) {
        Remove-Item -Recurse -Force .\tmp\winget > $null 2>&1
    }
}

# Autopsy
Clear-Tmp
winget download SleuthKit.Autopsy -d .\tmp\winget > $null 2>&1
copy-item .\tmp\winget\Autopsy*.msi .\downloads\autopsy.msi
Clear-Tmp

# DotNet 6 runtime
Clear-Tmp
winget download Microsoft.DotNet.Runtime.6 -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\Microsoft*.exe .\downloads\dotnet6.exe
Clear-Tmp

# GoLang
Clear-Tmp
winget download Golang.Go -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\Go*.msi .\downloads\golang.msi
Clear-Tmp

# Microsoft LogParser
Clear-Tmp
winget download Microsoft.LogParser -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\Log*.msi .\downloads\logparser.msi
Clear-Tmp

# Obsidian
Clear-Tmp
winget download Obsidian.Obsidian -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\Obsidian*.exe .\downloads\obsidian.exe
Clear-Tmp

# PowerShell 7
Clear-Tmp
winget download Microsoft.PowerShell -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\PowerShell*.msi .\downloads\powershell.msi
Clear-Tmp

# Qemu
Clear-Tmp
winget download SoftwareFreedomConservancy.QEMU -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\QEMU*.exe .\downloads\qemu.exe
Clear-Tmp

# Ruby
Clear-Tmp
winget download RubyInstallerTeam.Ruby.3.2 -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\Ruby*.exe .\downloads\ruby.exe
Clear-Tmp

# VirusTotal CLI
Clear-Tmp
winget download VirusTotal.vt-cli -d .\tmp\winget > $null 2>&1
Copy-Item .\tmp\winget\vt-cli*.zip .\downloads\vt.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\vt.zip" -o"$TOOLS\bin" | Out-Null
Clear-Tmp