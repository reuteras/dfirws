# DFIRWS

# Import common functions
if (Test-Path "${HOME}\Documents\tools\wscommon.ps1") {
    . "${HOME}\Documents\tools\wscommon.ps1"
} else {
    . '\\vmware-host\Shared Folders\dfirws\setup\wscommon.ps1'
}

# Start logging
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Create required directories
foreach ($dir in @("${WSDFIR_TEMP}", "${DATA}", "${env:ProgramFiles}\bin", "${HOME}\Documents\WindowsPowerShell", "${HOME}\Documents\PowerShell", "${env:ProgramFiles}\PowerShell\Modules\PSDecode", "${env:ProgramFiles}\dfirws", "${HOME}\Documents\jupyter")) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

Write-DateLog "Start sandbox setup" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log"

# Bypass the execution policy for the current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Copy config files and import them
if (-not (Test-Path "${WSDFIR_TEMP}\default-config.ps1")) {
    Copy-Item "${HOME}\Documents\tools\default-config.txt" "${WSDFIR_TEMP}\default-config.ps1" -Force
}

if (-not (Test-Path "${WSDFIR_TEMP}\config.ps1")) {
    Copy-Item "${HOME}\Documents\tools\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force
}

. "${WSDFIR_TEMP}\default-config.ps1"
. "${WSDFIR_TEMP}\config.ps1"
Write-DateLog "Config files copied and imported" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# PowerShell
if (Test-Path "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1") {
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
} else {
    Copy-Item "${LOCAL_PATH}\default-Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force
    Copy-Item "${LOCAL_PATH}\default-Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
}

if ("${WSDFIR_OHMYPOSH}" -eq "Yes") {
    $consoleFontRegPath = "HKCU:\Console"
    Install-OhMyPosh
    Set-ItemProperty -Path "${consoleFontRegPath}" -Name "FaceName" -Value "${WSDFIR_fontName}"
    Set-ItemProperty -Path "${consoleFontRegPath}" -Name "FontSize" -Value "${WSDFIR_fontSize}"
}

Copy-Item "${HOME}\Documents\tools\utils\PSDecode.psm1" "${env:ProgramFiles}\PowerShell\Modules\PSDecode" -Force

# Jupyter
Copy-Item "${HOME}\Documents\tools\jupyter\.jupyter" "${HOME}\" -Recurse -Force
Copy-Item "${HOME}\Documents\tools\jupyter\common.py" "${HOME}\Documents\jupyter\" -Force
Copy-Item "${HOME}\Documents\tools\jupyter\*.ipynb" "${HOME}\Documents\jupyter\" -Force

# Install latest PowerShell
Copy-Item   "${SETUP_PATH}\powershell.msi" "${WSDFIR_TEMP}\powershell.msi" -Force
Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\powershell.msi /qn /norestart"
Write-DateLog "PowerShell installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install 7-Zip
Copy-Item "${SETUP_PATH}\7zip.msi" "${WSDFIR_TEMP}\7zip.msi" -Force
Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\7zip.msi /qn /norestart"
Write-DateLog "7-Zip installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Always install common Java.
Copy-Item "${SETUP_PATH}\corretto.msi" "${WSDFIR_TEMP}\corretto.msi" -Force
Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\corretto.msi /qn /norestart"
Write-DateLog "Java installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install Python
& "${SETUP_PATH}\python3.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
Write-DateLog "Python installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install Visual C++ Redistributable 16 and 17
Start-Process -Wait "${SETUP_PATH}\vcredist_16_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -Wait "${SETUP_PATH}\vcredist_17_x64.exe" -ArgumentList "/passive /norestart"
Write-DateLog "Visual C++ Redistributable installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install .NET 6
Start-Process -Wait "${SETUP_PATH}\dotnet6.exe" -ArgumentList "/install /quiet /norestart"
Write-DateLog ".NET 6 installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install HxD
Copy-Item "${TOOLS}\hxd\HxDSetup.exe" "${WSDFIR_TEMP}\HxDSetup.exe" -Force
& "${WSDFIR_TEMP}\HxDSetup.exe" /VERYSILENT /NORESTART
Write-DateLog "HxD installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install Notepad++ and ComparePlus plugin
Copy-Item "${SETUP_PATH}\notepad++.exe" "${WSDFIR_TEMP}\notepad++.exe" -Force
& "${WSDFIR_TEMP}\notepad++.exe" /S  | Out-Null
& "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\comparePlus.zip" -o"${env:ProgramFiles}\Notepad++\Plugins\ComparePlus" | Out-Null
Write-DateLog "Notepad++ installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install NEO4J
if ("${WSDFIR_NEO4J}" -eq "Yes") {
    Install-Neo4j
    Write-DateLog "Neo4j installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install LibreOffice with custom arguments
if ("${WSDFIR_LIBREOFFICE}" -eq "Yes") {
    Install-LibreOffice
    Write-DateLog "LibreOffice installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Git if specified
if ("${WSDFIR_GIT}" -eq "Yes") {
    Install-GitBash
    Write-DateLog "Git installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install PDFStreamDumper if specified
if ("${WSDFIR_PDFSTREAM}" -eq "Yes") {
    Install-PDFStreamDumper
    Write-DateLog "PDFStreamDumper installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Visual Studio Code and PowerShell extension if specified
if ("${WSDFIR_VSCODE}" -eq "Yes") {
    Install-VSCode
    Write-DateLog "Visual Studio Code installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Zui if specified
if ("${WSDFIR_ZUI}" -eq "Yes") {
    Install-Zui
    Write-DateLog "Zui installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Set date and time format
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortDate -value "yyyy-MM-dd" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sLongDate -value "yyyy-MMMM-dddd" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss" | Out-Null
Write-DateLog "Date and time format set" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Dark mode
if ("${WSDFIR_DARK}" -eq "Yes") {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 | Out-Null
    New-Item -Path "${env:USERPROFILE}\AppData\Roaming\Notepad++" -ItemType Directory -Force | Out-Null
    Copy-Item "${env:USERPROFILE}\Documents\tools\configurations\notepad++_dark.xml" "${env:USERPROFILE}\AppData\Roaming\Notepad++\config.xml" -Force
    Write-DateLog "Dark mode set" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Show file extensions
Write-DateLog "Show file extensions" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
{
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt /v DefaultValue /t REG_DWORD /d 0 /f
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL /v DefaultValue /t REG_DWORD /d 1 /f
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0 /f
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
    reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 1 /f
} | Out-Null
Write-DateLog "File extensions shown" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Add right-click context menu if specified
if ("${WSDFIR_RIGHTCLICK}" -eq "Yes") {
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve | Out-Null
    Write-DateLog "Right-click context menu added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Import registry settings
reg import "${HOME}\Documents\tools\registry.reg" | Out-Null
Write-DateLog "Registry settings imported" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Restart Explorer process
Stop-Process -ProcessName "Explorer" -Force
Write-DateLog "Explorer restarted" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Add to PATH
Write-DateLog "Add to PATH" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

Add-ToUserPath "${env:ProgramFiles}\4n4lDetector"
Add-ToUserPath "${env:ProgramFiles}\7-Zip"
Add-ToUserPath "${env:ProgramFiles}\bin"
Add-ToUserPath "${env:ProgramFiles}\Git\bin"
Add-ToUserPath "${env:ProgramFiles}\Git\cmd"
Add-ToUserPath "${env:ProgramFiles}\Git\usr\bin"
Add-ToUserPath "${env:ProgramFiles}\graphviz\bin"
Add-ToUserPath "${env:ProgramFiles}\hashcat"
Add-ToUserPath "${env:ProgramFiles}\Hasher"
Add-ToUserPath "${env:ProgramFiles}\hxd"
Add-ToUserPath "${env:ProgramFiles}\IDR\bin"
Add-ToUserPath "${env:ProgramFiles}\iisGeolocate"
Add-ToUserPath "${env:ProgramFiles}\jadx\bin"
Add-ToUserPath "${env:ProgramFiles}\KAPE"
Add-ToUserPath "${env:ProgramFiles}\loki"
Add-ToUserPath "${env:ProgramFiles}\Notepad++"
Add-ToUserPath "${env:ProgramFiles}\RegistryExplorer"
Add-ToUserPath "${env:ProgramFiles}\ShellBagsExplorer"
Add-ToUserPath "${env:ProgramFiles}\TimelineExplorer"
Add-ToUserPath "${env:ProgramFiles}\qemu"
Add-ToUserPath "${RUST_DIR}\bin"
Add-ToUserPath "${GIT_PATH}\ese-analyst"
Add-ToUserPath "${GIT_PATH}\Events-Ripper"
Add-ToUserPath "${GIT_PATH}\iShutdown"
Add-ToUserPath "${GIT_PATH}\RegRipper3.0"
Add-ToUserPath "${GIT_PATH}\Regshot"
Add-ToUserPath "${GIT_PATH}\Trawler"
Add-ToUserPath "${TOOLS}\bin"
Add-ToUserPath "${TOOLS}\bulk_extractor\win64"
Add-ToUserPath "${TOOLS}\capa"
Add-ToUserPath "${TOOLS}\capa-ghidra"
Add-ToUserPath "${TOOLS}\cargo\bin"
Add-ToUserPath "${TOOLS}\chainsaw"
Add-ToUserPath "${TOOLS}\cutter"
Add-ToUserPath "${TOOLS}\DB Browser for SQLite"
Add-ToUserPath "${TOOLS}\DidierStevens"
Add-ToUserPath "${TOOLS}\die"
Add-ToUserPath "${TOOLS}\dumpbin\x64"
Add-ToUserPath "${TOOLS}\elfparser-ng\Release"
Add-ToUserPath "${TOOLS}\ExeinfoPE"
Add-ToUserPath "${TOOLS}\exiftool"
Add-ToUserPath "${TOOLS}\fakenet"
Add-ToUserPath "${TOOLS}\fasm"
Add-ToUserPath "${TOOLS}\floss"
Add-ToUserPath "${TOOLS}\FullEventLogView"
Add-ToUserPath "${TOOLS}\gftrace64"
Add-ToUserPath "${TOOLS}\GoReSym"
Add-ToUserPath "${TOOLS}\h2database"
Add-ToUserPath "${TOOLS}\hayabusa"
Add-ToUserPath "${TOOLS}\imhex"
Add-ToUserPath "${TOOLS}\INDXRipper"
Add-ToUserPath "${TOOLS}\jd-gui"
Add-ToUserPath "${TOOLS}\MailView"
Add-ToUserPath "${TOOLS}\MemProcFS"
Add-ToUserPath "${TOOLS}\lessmsi"
Add-ToUserPath "${TOOLS}\nmap"
Add-ToUserPath "${TOOLS}\node"
Add-ToUserPath "${TOOLS}\pebear"
Add-ToUserPath "${TOOLS}\perl\perl\bin"
Add-ToUserPath "${TOOLS}\pestudio"
Add-ToUserPath "${TOOLS}\pev"
Add-ToUserPath "${TOOLS}\php"
Add-ToUserPath "${TOOLS}\procdot\win64"
Add-ToUserPath "${TOOLS}\pstwalker"
Add-ToUserPath "${TOOLS}\qpdf\bin"
Add-ToUserPath "${TOOLS}\qrtool"
Add-ToUserPath "${TOOLS}\radare2\bin"
Add-ToUserPath "${TOOLS}\RdpCacheStitcher"
Add-ToUserPath "${TOOLS}\redress"
#Add-ToUserPath "${TOOLS}\resource_hacker"
Add-ToUserPath "${TOOLS}\ripgrep"
Add-ToUserPath "${TOOLS}\scdbg"
Add-ToUserPath "${TOOLS}\sleuthkit\bin"
Add-ToUserPath "${TOOLS}\sqlite"
Add-ToUserPath "${TOOLS}\ssview"
Add-ToUserPath "${TOOLS}\systeminformer\x64"
Add-ToUserPath "${TOOLS}\systeminformer\x86"
Add-ToUserPath "${TOOLS}\sysinternals"
Add-ToUserPath "${TOOLS}\thumbcacheviewer"
Add-ToUserPath "${TOOLS}\trid"
Add-ToUserPath "${TOOLS}\upx"
Add-ToUserPath "${TOOLS}\VolatilityWorkbench"
Add-ToUserPath "${TOOLS}\WinApiSearch"
Add-ToUserPath "${TOOLS}\WinObjEx64"
Add-ToUserPath "${TOOLS}\XELFViewer"
Add-ToUserPath "${TOOLS}\Zimmerman"
Add-ToUserPath "${TOOLS}\Zimmerman\EvtxECmd"
Add-ToUserPath "${TOOLS}\Zimmerman\EZViewer"
Add-ToUserPath "${TOOLS}\Zimmerman\JumpListExplorer"
Add-ToUserPath "${TOOLS}\Zimmerman\MFTExplorer"
Add-ToUserPath "${TOOLS}\Zimmerman\RECmd"
Add-ToUserPath "${TOOLS}\Zimmerman\SDBExplorer"
Add-ToUserPath "${TOOLS}\Zimmerman\SQLECmd"
Add-ToUserPath "${TOOLS}\Zimmerman\XWFIM"
Add-ToUserPath "${TOOLS}\zstd"
Add-ToUserPath "${VENV}\maldump\Scripts"
Add-ToUserPath "${VENV}\sigma-cli\Scripts"
Add-ToUserPath "${HOME}\AppData\Local\Programs\oh-my-posh\bin"
Add-ToUserPath "${HOME}\Documents\tools\utils"
$GHIDRA_INSTALL_DIR=((Get-ChildItem "${TOOLS}\ghidra\").Name | findstr "PUBLIC" | Select-Object -Last 1)
Add-ToUserPath "${TOOLS}\ghidra\${GHIDRA_INSTALL_DIR}"

Write-DateLog "Added to PATH" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Shortcut for PowerShell
Add-Shortcut -SourceLnk "${HOME}\Desktop\PowerShell.lnk" -DestinationPath "${env:ProgramFiles}\PowerShell\7\pwsh.exe" -WorkingDirectory "${HOME}\Desktop"

# Copy tools
Copy-Item -Force "${SETUP_PATH}\BeaconHunter.exe" "${env:ProgramFiles}\bin"
Copy-Item -Recurse -Force "${GIT_PATH}\IDR" "${env:ProgramFiles}"
Write-DateLog "Tools copied" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Add jadx
if ("${WSDFIR_JADX}" -eq "Yes") {
    Install-Jadx
    Write-DateLog "jadx added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Add x64dbg if specified
if ("${WSDFIR_X64DBG}" -eq "Yes") {
    Install-X64dbg
    Write-DateLog "x64dbg added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Configure PowerShell logging
New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -Force | Out-Null

# Add cmder
if ("${WSDFIR_CMDER}" -eq "Yes") {
    Install-CMDer
    Write-DateLog "cmder added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Add PersistenceSniper
Import-Module ${GIT_PATH}\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1

# Add apimonitor
if ("${WSDFIR_APIMONITOR}" -eq "Yes") {
    Install-Apimonitor
    Write-DateLog "apimonitor added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Configure usage of new venv for PowerShell
#(Get-ChildItem -File ${VENV}\default\Scripts\).Name | findstr /R /V "[\._]" | findstr /V activate | `
#    ForEach-Object {
#        Write-Output "function $_() { python ${VENV}\default\Scripts\$_ `$PsBoundParameters.Values + `$args }"
#    } | Out-File -Append -Encoding "ascii" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile_2.ps1"
#Write-DateLog "New venv configured for PowerShell" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Signal that everything is done to start using the tools (mostly).
Update-Wallpaper "${SETUP_PATH}\dfirws.jpg"
Write-DateLog "Wallpaper updated" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Run install script for choco packages
if ("${WSDFIR_CHOCO}" -eq "Yes") {
    Install-Choco
    # Add packages below
}

# Setup Node.js
if ("${WSDFIR_NODE}" -eq "Yes") {
    Install-Node
    Write-DateLog "Node.js installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Setup Obsidian
if ("${WSDFIR_OBSIDIAN}" -eq "Yes") {
    Install-Obsidian
    Write-DateLog "Obsidian installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Qemu
if ("${WSDFIR_QEMU}" -eq "Yes") {
    Install-Qemu
    Write-DateLog "Qemu installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install extra tools for Git-bash
if ("${WSDFIR_BASH_EXTRA}" -eq "Yes") {
    Install-BashExtra
    Write-DateLog "Extra tools for Git-bash installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Set Notepad++ as default for many file types
# Use %VARIABLE% in cmd.exe
Start-Process cmd -NoNewWindow -ArgumentList '/c Ftype xmlfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"'
Start-Process cmd -NoNewWindow -ArgumentList '/c Ftype chmfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"'
Start-Process cmd -NoNewWindow -ArgumentList '/c Ftype cmdfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"'
Start-Process cmd -NoNewWindow -ArgumentList '/c Ftype htafile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"'
Start-Process cmd -NoNewWindow -ArgumentList '/c Ftype jsefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"'
Start-Process cmd -NoNewWindow -ArgumentList '/c Ftype jsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"'
Start-Process cmd -NoNewWindow -ArgumentList '/c Ftype vbefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"'
Start-Process cmd -NoNewWindow -ArgumentList '/c Ftype vbsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"'
Write-DateLog "Notepad++ set as default for many file types" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Last commands
if ("${WSDFIR_W10_LOOPBACK}" -eq "Yes") {
    Install-W10Loopback
}

# Install Kape
if ("${WSDFIR_KAPE}" -eq "Yes") {
    Install-Kape
    Write-DateLog "Kape installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Loki
if ("${WSDFIR_LOKI}" -eq "Yes") {
    Install-Loki
    Write-DateLog "Loki installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install malcat
if ("${WSDFIR_MALCAT}" -eq "Yes") {
    Install-Malcat
    Write-DateLog "malcat installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Clean up
Remove-Item "${HOME}\Desktop\PdfStreamDumper.exe.lnk"

Write-DateLog "Start creation of Desktop/dfirws" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
# Create directory for shortcuts to installed tools
New-Item -ItemType Directory "${HOME}\Desktop\dfirws" | Out-Null

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\DidierStevens" | Out-Null
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\1768.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command 1768.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\amsiscan.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command amsiscan.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\base64dump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command base64dump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\byte-stats.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command byte-stats.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cipher-tool.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cipher-tool.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\count.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command count.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cs-analyze-processdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cs-analyze-processdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cs-decrypt-metadata.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cs-decrypt-metadata.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cs-extract-key.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cs-extract-key.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\cut-bytes.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cut-bytes.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decode-vbe.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decode-vbe.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decoder_add1.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decoder_add1.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decoder_ah.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decoder_ah.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decoder_chr.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decoder_chr.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decoder_rol1.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decoder_rol1.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decoder_xor1.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decoder_xor1.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\decompress_rtf.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command decompress_rtf.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\defuzzer.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command defuzzer.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\disitool.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command disitool.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\emldump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command emldump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\file-magic.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command file-magic.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\find-file-in-file.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command find-file-in-file.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\format-bytes.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command format-bytes.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\hash.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hash.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\headtail.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command headtail.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\hex-to-bin.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hex-to-bin.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\jpegdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jpegdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\js-ascii.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command js-ascii.exe -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\js-file.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command js-file.exe -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\metatool.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command metatool.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\msoffcrypto-crack.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command msoffcrypto-crack.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\myjson-filter.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command myjson-filter.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\myjson-transform.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command myjson-transform.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\nsrl.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command nsrl.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\numbers-to-hex.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command numbers-to-hex.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\numbers-to-string.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command numbers-to-string.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\oledump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command oledump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\onedump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command onedump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pdf-parser.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdf-parser.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pdfid.ini.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdfid.ini -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pdfid.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdfid.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pdftool.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pdftool.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pecheck.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pecheck.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\pngdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pngdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\process-binary-file.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command process-binary-file.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\process-text-file.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command process-text-file.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\python-per-line.library.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command python-per-line.library -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\python-per-line.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command python-per-line.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\re-search.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command re-search.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\reextra.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command reextra.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\rtfdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rtfdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\sets.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sets.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\sortcanon.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sortcanon.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\split-overlap.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command split-overlap.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\split.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command split.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\ssdeep.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ssdeep.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\strings.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command strings.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\teeplus.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command teeplus.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\translate.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command translate.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\what-is-new.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command what-is-new.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\xlsbdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xlsbdump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\xmldump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xmldump.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\xor-kpa.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xor-kpa.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\xorsearch.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command xorsearch.py -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\DidierStevens\zipdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command zipdump.py -h"

# Editors
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Editors" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Bytecode Viewer.lnk" -DestinationPath "${TOOLS}\bin\bcv.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\HxD.lnk" -DestinationPath "${env:ProgramFiles}\HxD\HxD.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\ImHex.lnk" -DestinationPath "${TOOLS}\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Malcat.lnk" -DestinationPath "${env:ProgramFiles}\malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Notepad++.lnk" -DestinationPath "${env:ProgramFiles}\Notepad++\notepad++.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Obsidian (runs dfirws-install -Obsidian).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Obsidian"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Editors\Visual Studio Code.lnk" -DestinationPath "${HOME}\AppData\Local\Programs\Microsoft VS Code\Code.exe"

# File and apps
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\autoit-ripper.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command autoit-ripper -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\binlex (A Binary Genetic Traits Lexer).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command binlex.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\bulk_extractor64.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command bulk_extractor64.exe -h"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\densityscout (calculates density (like entropy)).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command densityscout -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Detect It Easy (determining types of files).lnk" -DestinationPath "${TOOLS}\die\die.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\ezhexviewer (A simple hexadecimal viewer).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\dumpbin (Microsoft COFF Binary File Dumper).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dumpbin.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\fq (jq for binary formats).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\jq ( commandline JSON processor).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\lessmsi (A tool to view and extract the contents of a Windows Installer (.msi) file).lnk" -DestinationPath "${TOOLS}\lessmsi\lessmsi-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\msidump.py (a tool that analyzes malicious MSI installation packages, extracts files, streams, binary data and incorporates YARA scanner).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command msidump.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Qemu (runs dfirws-install -Qemu).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dfirws-install.ps1 -Qemu"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\qemu-img (QEMU disk image utility).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dfirws-install.ps1 -Qemu"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\qrtool.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command qrtool -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\ripgrep (rg).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rg -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\trid (File Identifier).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command trid.exe -?"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Browser" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\BrowsingHistoryView.lnk" -DestinationPath "${TOOLS}\nirsoft\BrowsingHistoryView.exe" -Iconlocation "${TOOLS}\nirsoft\BrowsingHistoryView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\ChromeCacheView.lnk" -DestinationPath "${TOOLS}\nirsoft\ChromeCacheView.exe" -Iconlocation "${TOOLS}\nirsoft\ChromeCacheView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight (Internet history forensics for Google Chrome and Chromium).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hindsight.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight_gui.lnk" -DestinationPath "${TOOLS}\bin\hindsight_gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl_app.py (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command unfurl-web.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl_cli.py - run via unfurl_cli.ps1 (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command unfurl_cli.ps1 -h"
# Microsoft Defender is flagging this as malware
#Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\ChromeCookiesView.lnk" -DestinationPath "${TOOLS}\nirsoft\ChromeCookiesView.exe" -Iconlocation "${TOOLS}\nirsoft\ChromeCookiesView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\IECacheView.lnk" -DestinationPath "${TOOLS}\nirsoft\IECacheView.exe" -Iconlocation "${TOOLS}\nirsoft\IECacheView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\LastActivityView.lnk" -DestinationPath "${TOOLS}\nirsoft\LastActivityView.exe" -Iconlocation "${TOOLS}\nirsoft\LastActivityView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\MZCacheView.lnk" -DestinationPath "${TOOLS}\nirsoft\MZCacheView.exe" -Iconlocation "${TOOLS}\nirsoft\MZCacheView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Browser\MZCookiesView.lnk" -DestinationPath "${TOOLS}\nirsoft\mzcv.exe" -Iconlocation "${TOOLS}\nirsoft\mzcv.exe"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Database" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\DB Browser for SQLite.lnk" -DestinationPath "${TOOLS}\DB Browser for SQLite\DB Browser for SQLite.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\dsq (commandline SQL engine for data files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dsq -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\h2 database.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\fqlite.lnk" -DestinationPath "${TOOLS}\fqlite\run.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\SQLECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\SQLECmd\SQLECmd.exe" -Arguments "-NoExit -command SQLECmd.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqldiff.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "-NoExit -command sqldiff.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqlite3.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "-NoExit -command sqlite3.exe -help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\sqlite3_analyzer (Analyze the SQLite3 database file and report detailing size and storage efficiency).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\sqlite\sqlite3.exe" -Arguments "-NoExit -command sqlite3_analyzer"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Database\SQLiteWalker.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command SQLiteWalker.py -h"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Disk" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\INDXRipper.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\INDXRipper\INDXRipper.exe" -Arguments "-NoExit -command INDXRipper.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mactime2 (replacement for mactime - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mactime2.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mft2bodyfile (parses an MFT file (and optionally the corresponding UsnJrnl) to bodyfile - dfir-toolkit - janstarke).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mft2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\MFTBrowser.lnk" -DestinationPath "${TOOLS}\bin\MFTBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ntfs_parser.py (Extract information from NTFS metadata files, volumes, and shadow copies).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ntfs_parser.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\parseUSBs.py (Registry parser, to extract USB connection artifacts from SYSTEM, SOFTWARE, and NTUSER.dat hives).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command parseUSBs.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkcalc (Calculates where data in the unallocated space image (from blkls) exists in the original image. This is used when evidence is found in unallocated space - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blkcalc.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkcat (Extracts the contents of a given data unit - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blkcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkls (Lists the details about data units and can extract the unallocated space of the file system - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blkls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\blkstat (Displays the statistics about a given data unit in an easy to read format - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command blkstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fcat - sleuthkit.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ffind (Finds allocated and unallocated file names that point to a given meta data structure  - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ffind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fls (Lists allocated and deleted file names in a directory - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\fsstat (Shows file system details and statistics including layout, sizes, and labels - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command fsstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\hfind (Uses a binary sort algorithm to lookup hashes in the NIST NSRL, Hashkeeper, and custom hash databases created by md5sum - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hfind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\icat (Extracts the data units of a file, which is specified by its meta data address (instead of the file name) - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command icat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ifind (Finds the meta data structure that has a given file name pointing to it or the meta data structure that points to a given data unit - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ifind.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\ils (Lists the meta data structures and their contents in a pipe delimited format - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ils.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\img_cat (This tool will show the raw contents of an image file - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command img_cat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\img_stat (tool will show the details of the image format - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command img_stat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\istat (Displays the statistics and details about a given meta data structure in an easy to read format - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command istat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\jcat (Display the contents of a specific journal block - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\jls (List the entries in the file system journal - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command jls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmcat (Extracts the contents of a specific volume to STDOUT - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mmcat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmls (Displays the layout of a disk, including the unallocated space - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mmls.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\mmstat (Display details about a volume system (typically only the type) - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command mmstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\pstat - sleuthkit.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pstat.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_comparedir (Compares a local directory hierarchy with the contents of raw device (or disk image) - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_comparedir.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_gettimes (Extracts all of the temporal data from the image to make a timeline - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_gettimes.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_imageinfo - sleuthkit.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_imageinfo.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_loaddb (Loads the metadata from an image into a SQLite database - sleuthkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_loaddb.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Disk\tsk_recover (Extracts the unallocated (or allocated) files from a disk image to a local directory) - sleuthkit.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tsk_recover.exe -h"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\JavaScript" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\box-js (is a utility to analyze malicious JavaScript files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command box-js --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\deobfuscator (synchrony).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command synchrony --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\js-beautify (Javascript beautifier).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command js-beautify --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\JavaScript\jsdom (opens README in Notepad++).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command notepad++.exe C:\Tools\node\node_modules\jsdom\README.md"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Log" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\chainsaw (Rapidly work with Forensic Artefacts).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command chainsaw.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\cleanhive (merges logfiles into a hive file - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command cleanhive.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\erip (Parse timeline-format events file - Events-Ripper).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command erip.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\es4forensics (This crates provides structs and functions to insert timeline data into an elasticsearch index - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command es4forensics.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtx_dump (Utility to parse EVTX files).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtx_dump.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtx2bodyfile (creates bodyfile from Windows evtx files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtx2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxanalyze (crate provide functions to analyze evtx files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtxanalyze.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxcat (Display one or more events from an evtx file - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtxcat.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxls (Display one or more events from an evtx file - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtxls.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\evtxscan (Find time skews in an evtx file - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evtxscan.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\FullEventLogView.lnk" -DestinationPath "${TOOLS}\FullEventLogView\FullEventLogView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\hayabusa (is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hayabusa.exe help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ipgrep (search for IP addresses in text files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ipgrep.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\MasterParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${env:ProgramFiles}\AuthLogParser" -Arguments "-NoExit -command .\MasterParser.ps1 -o Menu"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\Microsoft LogParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command LogParser.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\PowerSiem.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PowerSiem.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ToolAnalysisResultSheet (Summarizes the results of examining logs recorded in Windows upon execution of 49 tools which are likely used by a attacker that has infiltrated a network).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command ToolAnalysisResultSheet.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\ts2date (replaces UNIX timestamps in a stream by a formatted date - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ts2date.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Log\zircolite (Standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs - use zircolite.ps1).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command zircolite.ps1 -h"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Office and email" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\email-analyzer.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\EmailAnalyzer" -Arguments "-NoExit -command .\email-analyzer.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\extract_msg.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\LibreOffice (runs dfirws-install -LibreOffice).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -LibreOffice"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\Mail Viewer.lnk" -DestinationPath "${TOOLS}\MailView\MailView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\Mbox Viewer.lnk" -DestinationPath "${TOOLS}\mboxviewer\mboxview64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\MetadataPlus.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\MetadataPlus.exe" -Arguments "-NoExit -command MetadataPlus.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\mraptor.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\msgviewer.lnk" -DestinationPath "${TOOLS}\lib\msgviewer.jar"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\msodde.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\msoffcrypto-crack.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\msoffcrypto-tool.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\oledump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\oleid.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\olevba.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\pstwalker.lnk" -DestinationPath "${TOOLS}\pstwalker\pstwalker.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\pcode2code.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\pcodedmp.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\rtfdump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\rtfobj.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\Structured Storage Viewer (SSView).lnk" -DestinationPath "${TOOLS}\ssview\SSView.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\tree.com.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Office and email\zipdump.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\PDF" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdfstreamdumper.lnk" -DestinationPath "${PDFSTREAMDUMPER_PATH}\PDFStreamDumper.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdf-parser.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\pdfid.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PDF\qpdf.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\PE" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\4n4lDetector.lnk" -DestinationPath "${env:ProgramFiles}\4n4lDetector\4N4LDetector.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\capa.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\capa\capa.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\Debloat.lnk" -DestinationPath "${TOOLS}\bin\debloat.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\dll_to_exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\ExeinfoPE.lnk" -DestinationPath "${TOOLS}\ExeinfoPE\exeinfope.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\hachoir-tools.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\hollows_hunter (Scans running processes. Recognizes and dumps a variety of in-memory implants).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\hollows_hunter.exe" -Arguments "-NoExit -command hollows_hunter.exe /help"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pe2pic.ps1.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pe2pic.ps1 -h"
#Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pe2shc.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation ${TOOLS}\bin\pe2shc.exe
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\PE-bear.lnk" -DestinationPath "${TOOLS}\pebear\PE-bear.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\PE-sieve (Scans a given process, recognizes and dumps a variety of in-memory implants).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\bin\pe-sieve.exe" -Arguments "-NoExit -command pe-sieve.exe /help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pestudio.lnk" -DestinationPath "${TOOLS}\pestudio\pestudio.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\pescan.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${TOOLS}\pev"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\readpe - PE Utils.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
#Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\Resource Hacker.lnk" -DestinationPath "${TOOLS}\resource_hacker\ResourceHacker.exe"
Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\shellconv.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\PE\WinObjEx64.lnk" -DestinationPath "${TOOLS}\WinObjEx64\WinObjEx64.exe"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\Phone" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\aleapp (Android Logs, Events, and Protobuf Parser).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command aleapp.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\aleappGUI.lnk" -DestinationPath "${TOOLS}\bin\aleappGUI.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\ileapp (iOS Logs, Events, And Plists Parser).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ileapp.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_detect.py (sysdiagnose_file.tar.gz).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command iShutdown_detect.py"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_parse.py (A tool to extract and parse iOS shutdown logs from a .tar.gz archive).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command iShutdown_parse.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iShutdown_stats.py (Process an iOS shutdown.log file to create stats on reboots).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command iShutdown_stats.k -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\Phone\iLEAPPGUI.lnk" -DestinationPath "${TOOLS}\bin\iLEAPPGUI.exe"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Files and apps\RDP" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\RDP\bmc-tools.py (RDP Bitmap Cache parser).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command bmc-tools.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Files and apps\RDP\RdpCacheStitcher.lnk" -DestinationPath "${TOOLS}\RdpCacheStitcher\RdpCacheStitcher.exe"

# Forensics
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Forensics" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\Autopsy (runs dfirws-install -Autopsy).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Autopsy"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\venv-dissect.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ${HOME}\Documents\tools\utils\venv.ps1 -Dissect"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\acquire-decrypt.exe (dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command acquire-decrypt.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\acquire.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command acquire.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-dd.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command asdf-dd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-meta.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command asdf-meta.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-repair.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command asdf-repair.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\asdf-verify.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command asdf-verify.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\dump-nskeyedarchiver.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dump-nskeyedarchiver.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\envelope-decrypt.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command envelope-decrypt.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\keyring.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command keyring.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\normalizer.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command normalizer.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\parse-lnk.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command parse-lnk.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\rdump.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rdump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\rgeoip.exe (use rgeoip.ps1 if you have maxmind in enrichment- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rgeoip.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-build-pluginlist.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-build-pluginlist.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-dd.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-dd.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-dump.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-dump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-fs.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-fs.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-info.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-info.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-mount.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-mount.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-query.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-query.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-reg.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-reg.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\target-shell.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command target-shell.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\thumbcache-extract-indexed.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command thumbcache-extract-indexed.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\thumbcache-extract.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command thumbcache-extract.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Forensics\vma-extract.exe (- dissect).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command vma-extract.exe -h"

# Incident response
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\IR" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\gkape.lnk" -DestinationPath "${env:ProgramFiles}\KAPE\gkape.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Kape (runs dfirws-install -Kape).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Kape"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\kape (Krolls Artifact Parser and Extractor).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command kape --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Trawler.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Get-Help trawler"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\PersistenceSniper.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Get-Help -Name Find-AllPersistence"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\PowerSponse.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\PowerSponse"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\White-Phoenix.py (recovers content from files encrypted by Ransomware using intermittent encryption).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command White-Phoenix.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\velociraptor.exe (Velociraptor is an advanced digital forensic and incident response tool that enhances your visibility into your endpoints).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command velociraptor.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\IR\Shadow-pulse (csv with information about ransomware groups).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command EZViewer.exe ${GIT_PATH}\Shadow-pulse\Ransomlist.csv"

# Malware tools
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Malware tools" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\malconf (RATDecoders).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command malconf.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\maldump.exe (Multi-quarantine extractor).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command maldump.exe -h"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\1768.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\BeaconHunter.lnk" -DestinationPath "${env:ProgramFiles}\bin\BeaconHunter.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\CobaltStrikeScan.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

# Memory
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Memory" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\Dokany (runs dfirws-install -Dokany).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Dokany"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\MemProcFS.lnk"  -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command MemProcFS.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\Volatility Workbench 2.1.lnk" -DestinationPath "${TOOLS}\VolatilityWorkbench2\VolatilityWorkbench.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Memory\Volatility Workbench 3.lnk" -DestinationPath "${TOOLS}\VolatilityWorkbench\VolatilityWorkbench.exe"

# Network
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Network" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Fakenet.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\fakenet\fakenet.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\ipexpand.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\scapy.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Wireshark (runs dfirws-install -Wireshark).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Wireshark"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Network\Zui (runs dfirws-install -Zui).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Zui"

# OS
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS" | Out-Null

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Android" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Android\apktool.bat.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Linux" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Linux\elfparser-ng.lnk" -DestinationPath "${TOOLS}\elfparser-ng\Release\elfparser-ng.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Linux\xelfviewer.lnk" -DestinationPath "${TOOLS}\XELFViewer\xelfviewer.exe"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\macOS" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\macOS\dsstore.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\Python-dsstore"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\macOS\machofile-cli.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows" | Out-Null
if ("${WSDFIR_APIMONITOR}" -eq "Yes") {
    Add-shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\apimonitor-x86.lnk" -DestinationPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor\apimonitor-x86.exe"
    Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\apimonitor-x64.lnk" -DestinationPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor\apimonitor-x64.exe"
}
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\ese2csv.exe (Find and dump ESE databases).lnk" -DestinationPath "${POWERSHELL_EXE}" -Arguments "-NoExit -command ese2csv.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Jumplist-Browser.lnk" -DestinationPath "${TOOLS}\bin\JumplistBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\lnk2bodyfile (Parse Windows LNK files and create bodyfile output - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command lnk2bodyfile.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Prefetch-Browser.lnk" -DestinationPath "${TOOLS}\bin\PrefetchBrowser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\procdot.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\sidr (Search Index DB Reporter - handles both ESE (.edb) and SQLite).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sidr --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Thumbcache Viewer.lnk" -DestinationPath "${TOOLS}\thumbcacheviewer\thumbcache_viewer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\usnjrnl (Parses Windows UsnJrnl files - dfir-toolkit - janstarke).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command usnjrnl.exe --help"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\adalanche (Active Directory ACL Visualizer and Explorer).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command adalanche.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\CimSweep.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\CimSweep" -Arguments "-NoExit -command Import-Module .\CimSweep\CimSweep.psd1"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\OS\Windows\Registry" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\hivescan (scans a registry hive file for deleted entries - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hivescan.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\pol_export (Exporter for Windows Registry Policy Files - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pol_export.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\regdump (parses registry hive files and prints a bodyfile - dfir-toolkit).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regdump.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\Registry Explorer.lnk" -DestinationPath "${TOOLS}\Zimmerman\RegistryExplorer\RegistryExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\RegRipper (rip).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command rip.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\RegShot-x64-ANSI.lnk" -DestinationPath "${GIT_PATH}\Regshot\Regshot-x64-ANSI.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\OS\Windows\Registry\RegShot-x64-Unicode.lnk" -DestinationPath "${GIT_PATH}\Regshot\Regshot-x64-Unicode.exe"

# Programming
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\java.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\node.lnk" -DestinationPath "${TOOLS}\node\node.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\perl.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\php.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Python.lnk" -DestinationPath "${VENV}\default\Scripts\python.exe"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\dotNET" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\dotNET\dotnetfile_dump.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dotnetfile_dump.py -h"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Delphi" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Delphi\idr.lnk" -DestinationPath "${env:ProgramFiles}\idr\bin\Idr.exe"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Go" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\gftrace.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\GoReSym.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Go\Redress.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Install" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Install\GoLang (runs dfirws-install -GoLang).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -GoLang"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Install\Jadx (runs dfirws-install -Jadx).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Jadx"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Install\Node (runs dfirws-install -Node).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Node"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Install\Ruby (runs dfirws-install -Ruby).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Ruby"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Install\Rust (runs dfirws-install -Rust).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Rust"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Java" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\jadx-gui.lnk" -DestinationPath "${env:ProgramFiles}\jadx\bin\jadx-gui.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\jd-gui.lnk" -DestinationPath "${TOOLS}\jd-gui\jd-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Java\recaf (The modern Java bytecode editor).lnk" -DestinationPath "${TOOLS}\bin\recaf.bat" -Arguments "-NoExit -command recaf.bat"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\PowerShell" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\PowerShell\deobshell (main.py).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\deobshell" -Arguments "-NoExit -command .\main.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\PowerShell\PowerDecode.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\PowerDecode" -Arguments "-NoExit -command .\GUI.ps1"

New-item -ItemType Directory "${HOME}\Desktop\dfirws\Programming\Python" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Programming\Python\pydisasm.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

# Reverse Engineering
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Reverse Engineering" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Cutter.lnk" -DestinationPath "${TOOLS}\cutter\cutter.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy32.lnk" -DestinationPath "${TOOLS}\dnSpy32\dnSpy.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy64.lnk" -DestinationPath "${TOOLS}\dnSpy64\dnSpy.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\dragodis (Dragodis is a Python framework which allows for the creation of universal disassembler scripts).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dragodis.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\fasm.lnk" -DestinationPath "${TOOLS}\fasm\FASM.EXE"
(Get-ChildItem "${TOOLS}\ghidra").Name | ForEach-Object {
    $VERSION = "$_"
    Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\${VERSION}.lnk" -DestinationPath "${TOOLS}\ghidra\${VERSION}\ghidraRun.bat"
}
if (Test-Path "${VENV}\jep") {
    Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Ghidrathon.lnk" -DestinationPath "${HOME}\Documents\tools\utils\ghidrathon.bat"
}
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\iaito.lnk" -DestinationPath "${TOOLS}\iaito\iaito.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\ImHex.lnk" -DestinationPath "${TOOLS}\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\Malcat.lnk" -DestinationPath "${env:ProgramFiles}\malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\radare2.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command radare2 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\scare.ps1.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command scare.ps1 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\x32dbg.lnk" -DestinationPath "${env:ProgramFiles}\x64dbg\release\x32\x32dbg.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\x64dbg.lnk" -DestinationPath "${env:ProgramFiles}\x64dbg\release\x64\x64dbg.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Reverse Engineering\X64dbg (runs dfirws-install -X64dbg).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -X64dbg"

# Signatures and information
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Signatures and information" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\blyara.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\evt2sigma.ps1 (python package).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command evt2sigma.ps1 -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\mkyara.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\loki.lnk" -DestinationPath "${env:ProgramFiles}\loki\loki.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\PatchaPalooza.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${GIT_PATH}\PatchaPalooza" -Arguments "-NoExit -command .\PatchaPalooza.py -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\sigma-cli (This is the Sigma command line interface using the pySigma library to manage, list and convert Sigma rules into query languages).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sigma.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\WinApiSearch64.lnk" -DestinationPath "${TOOLS}\WinApiSearch\WinApiSearch64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yara.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command yara.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\yarac.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command yarac.exe -h"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Signatures and information\Online tools" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\shodan.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command shodan"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Signatures and information\Online tools\vt (A command-line tool for interacting with VirusTotal).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command vt help"

# "${HOME}\Desktop\dfirws\Sysinternals"
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Sysinternals" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\accesschk64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command accesschk64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\AccessEnum.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\AccessEnum.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ADExplorer64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\ADExplorer64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ADInsight64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\ADInsight64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\adrestore64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command adrestore64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Autologon64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Autologon64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Autoruns64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Autoruns64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\autorunsc64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command autorunsc64.exe --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Bginfo64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Bginfo64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Cacheset64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Cacheset64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Clockres64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Clockres64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Contig64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Contig64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Coreinfo64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Coreinfo64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\CPUSTRES64.EXE.lnk" -DestinationPath "${TOOLS}\sysinternals\CPUSTRES64.EXE"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ctrl2cap.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ctrl2cap.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\dbgview64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command dbgview64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Desktops64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Desktops64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\disk2vhd64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\disk2vhd64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\diskext64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command diskext64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Diskmon64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Diskmon64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\DiskView64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\DiskView64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\du64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command du64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\efsdump.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command efsdump.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\FindLinks64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command FindLinks64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\handle64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command handle64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\hex2dec64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command hex2dec64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\junction64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command junction64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ldmdump.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ldmdump.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Listdlls64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Listdlls64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\livekd64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command livekd64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\LoadOrd64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\LoadOrd64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\LoadOrdC64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\logonsessions64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command logonsessions64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\movefile64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command movefile64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\notmyfault64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command notmyfault64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\notmyfaultc64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command notmyfaultc64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ntfsinfo64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ntfsinfo64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pendmoves64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pendmoves64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pipelist64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pipelist64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\portmon.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command portmon.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\procdump64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command procdump64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\procexp64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\procexp64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Procmon64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Procmon64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsExec64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsExec64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\psfile64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command psfile64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsGetsid64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsGetsid64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsInfo64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsInfo64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pskill64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pskill64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pslist64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pslist64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsLoggedon64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsLoggedon64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\psloglist64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command psloglist64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pspasswd64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pspasswd64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\psping64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command psping64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\PsService64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command PsService64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\psshutdown64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command psshutdown64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\pssuspend64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pssuspend64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\RAMMap64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command RAMMap64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\RDCMan.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\RDCMan.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\RegDelNull64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command RegDelNull64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Reghide.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\regjump.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command regjump.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\RootkitRevealer.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ru64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ru64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\sdelete64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sdelete64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ShareEnum64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\ShareEnum64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ShellRunas.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command ShellRunas.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\sigcheck64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sigcheck64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\streams64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command streams64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\strings64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command strings64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\sync64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command sync64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Sysmon64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Sysmon64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\tcpvcon64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command tcpvcon64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\tcpview64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\tcpview64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Testlimit64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Testlimit64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\vmmap64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command vmmap64.exe /?"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Volumeid64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Volumeid64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\whois64.exe.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command whois64.exe -h"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\Winobj64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\Winobj64.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Sysinternals\ZoomIt64.exe.lnk" -DestinationPath "${TOOLS}\sysinternals\ZoomIt64.exe"

# Utilities
New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities" | Out-Null

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\_dfirws" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\_dfirws\dfirws-install.ps1.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Get-Help dfirws-install.ps1"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\7-Zip.lnk" -DestinationPath "${env:ProgramFiles}\7-Zip\7zFM.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\bash.lnk" -DestinationPath "${env:ProgramFiles}\Git\bin\bash.exe" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\cmder.lnk" -DestinationPath "${env:ProgramFiles}\cmder\cmder.exe" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\exiftool.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\exiftool\exiftool.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\floss.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\floss\floss.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\git.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\Git\cmd\git-gui.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Graphviz.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\pwncat.py (Fancy reverse and bind shell handler).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command pwncat.py --help"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\pygmentize.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\time-decode.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\upx.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\visidata.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\zstd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Utilities\Crypto" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\ares.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\chepy.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\CyberChef.lnk" -DestinationPath "${TOOLS}\CyberChef\CyberChef.html"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\hash-id.py.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\hashcat (runs dfirws-install -Hashcat).lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-command dfirws-install.ps1 -Hashcat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\hashcat.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${env:ProgramFiles}\hashcat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Utilities\Crypto\name-that-hash.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop"

New-Item -ItemType Directory "${HOME}\Desktop\dfirws\Zimmerman" | Out-Null
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\AmcacheParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\AmcacheParser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\AppCompatCacheParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\AppCompatCacheParser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\bstrings.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\bstrings.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\EvtxECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\EvtxECmd\EvtxECmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\EZViewer.lnk" -DestinationPath "${TOOLS}\Zimmerman\EZViewer\EZViewer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\Hasher.lnk" -DestinationPath "${env:ProgramFiles}\Hasher\Hasher.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\iisGeolocate.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${env:ProgramFiles}\iisGeolocate\iisGeolocate.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\JLECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\JLECmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\LECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\LECmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\MFTECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\MFTECmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\PECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\PECmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\RBCmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\RBCmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\RecentFileCacheParser.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\RecentFileCacheParser.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\RegistryExplorer.lnk" -DestinationPath "${env:ProgramFiles}\RegistryExplorer\RegistryExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\rla.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\rla.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\SBECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\SBECmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\ShellBagsExplorer.lnk" -DestinationPath "${env:ProgramFiles}\ShellBagsExplorer\ShellBagsExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\SrumECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\SrumECmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\SumECmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\SumECmd.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\TimeApp.lnk" -DestinationPath "${TOOLS}\Zimmerman\TimeApp.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\TimelineExplorer.lnk" -DestinationPath "${env:ProgramFiles}\TimelineExplorer\TimelineExplorer.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\VSCMount.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\VSCMount.exe"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Zimmerman\WxTCmd.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Iconlocation "${TOOLS}\Zimmerman\WxTCmd.exe"

Write-DateLog "Creating shortcuts in ${HOME}\Desktop\dfirws done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Pin to explorer
$shell = new-object -com "Shell.Application"
$folder = ${shell}.Namespace("${HOME}\Desktop")
$item = ${folder}.Parsename('dfirws')
$verb = ${item}.Verbs() | Where-Object { $_.Name -eq 'Pin to Quick access' }
if ("${verb}") {
    ${verb}.DoIt()
}
Write-DateLog "Pinning ${HOME}\Desktop\dfirws to explorer done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

& "${POWERSHELL_EXE}" -Command "Set-ExecutionPolicy Bypass"
Write-DateLog "Setting execution policy to Bypass done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

& "${SETUP_PATH}\graphviz.exe" /S /D="${env:ProgramFiles}\graphviz"
Write-DateLog "Installing Graphviz done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Add plugins to Cutter
New-Item -ItemType Directory -Force -Path "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" | Out-Null
Copy-Item "${GIT_PATH}\radare2-deep-graph\cutter\graphs_plugin_grid.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item "${SETUP_PATH}\x64dbgcutter.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item "${GIT_PATH}\cutterref\cutterref.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item -Recurse "${GIT_PATH}\cutterref\archs" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item -Recurse "${GIT_PATH}\cutter-jupyter\icons" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item -Recurse "${GIT_PATH}\capa-explorer\capa_explorer_plugin" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python"
Write-DateLog "Installing Cutter plugins done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Unzip yara signatures
& "${env:ProgramFiles}\7-Zip\7z.exe" x "${SETUP_PATH}\yara-forge-rules-core.zip" -o"${DATA}" | Out-Null
& "${env:ProgramFiles}\7-Zip\7z.exe" x "${SETUP_PATH}\yara-forge-rules-extended.zip" -o"${DATA}" | Out-Null
& "${env:ProgramFiles}\7-Zip\7z.exe" x "${SETUP_PATH}\yara-forge-rules-full.zip" -o"${DATA}" | Out-Null
Copy-Item "${DATA}\packages\full\yara-rules-full.yar" "${DATA}\total.yara" -Force
Write-DateLog "Unzipping signatures for yara done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Start sysmon when installation is done
if ("${WSDFIR_SYSMON}" -eq "Yes") {
    & "${TOOLS}\sysinternals\Sysmon64.exe" -accepteula -i "${WSDFIR_SYSMON_CONF}" | Out-Null
}
Write-DateLog "Starting sysmon done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Start Gollum for local wiki
netsh firewall set opmode DISABLE 2>&1 | Out-Null
Start-Process "${env:ProgramFiles}\Amazon Corretto\jdk*\bin\java.exe" -argumentlist "-jar ${TOOLS}\lib\gollum.war -S gollum --lenient-tag-lookup ${GIT_PATH}\dfirws.wiki" -WindowStyle Hidden
Write-DateLog "Starting Gollum for local wiki done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Don't ask about new apps
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t REG_DWORD /d 1 | Out-Null

# Install hashcat
if ("${WSDFIR_HASHCAT}" -eq "Yes") {
    Install-Hashcat
    Write-DateLog "Installing hashcat done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Add shortcuts to desktop for Jupyter and Gollum
Add-Shortcut -SourceLnk "${HOME}\Desktop\jupyter.lnk" -DestinationPath "${HOME}\Documents\tools\utils\jupyter.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws wiki.lnk" -DestinationPath "${HOME}\Documents\tools\utils\gollum.bat"

New-Item -Path "${HOME}/ghidra_scripts" -ItemType Directory -Force | Out-Null
if (Test-Path "${SETUP_PATH}\capa_ghidra.py") {
    Copy-Item "${SETUP_PATH}\capa_ghidra.py" "${HOME}/ghidra_scripts/capa_ghidra.py" -Force
}

# Run custom scripts
if (Test-Path "${LOCAL_PATH}\customize.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\customize.ps1"
    Write-DateLog "Running customize scripts done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
} else {
    Write-DateLog "No customize scripts found running example-customize.ps1." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\example-customize.ps1"
}

if (Test-Path "${LOCAL_PATH}\customise.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\customise.ps1"
    Write-DateLog "Running customise scripts done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Copy and extract files that need be in writeable locations
Copy-Item -Recurse "${TOOLS}\Zimmerman\Hasher" "${env:ProgramFiles}\" -Force
Copy-Item -Recurse "${HOME}\Documents\tools\configurations\Hasher.ini" "${env:ProgramFiles}\Hasher\Hasher.ini" -Force
Copy-Item -Recurse "${TOOLS}\Zimmerman\iisGeolocate" "${env:ProgramFiles}\" -Force
if (Test-Path "C:\enrichment\maxmind_current\GeoLite2-City.mmdb") {
    Copy-Item "C:\enrichment\maxmind_current\GeoLite2-City.mmdb" "${env:ProgramFiles}\iisGeolocate\" -Force
}
Copy-Item -Recurse "${TOOLS}\Zimmerman\RegistryExplorer" "${env:ProgramFiles}\" -Force
Copy-Item -Recurse "${TOOLS}\Zimmerman\ShellBagsExplorer" "${env:ProgramFiles}\" -Force
Copy-Item -Recurse "${TOOLS}\Zimmerman\TimelineExplorer" "${env:ProgramFiles}\" -Force
Copy-Item -Recurse "${GIT_PATH}\AuthLogParser" "${env:ProgramFiles}\" -Force
& "${env:ProgramFiles}\7-Zip\7z.exe" x "${SETUP_PATH}\4n4lDetector.zip" -o"${env:ProgramFiles}\4n4lDetector" | Out-Null

Write-DateLog "Installation done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

Exit 0