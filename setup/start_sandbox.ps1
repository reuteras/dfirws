# DFIRWS

# Import common functions
if (Test-Path "${HOME}\Documents\tools\wscommon.ps1") {
    . "${HOME}\Documents\tools\wscommon.ps1"
} else {
    . '\\vmware-host\Shared Folders\dfirws\setup\wscommon.ps1'
}

# Ugly fix
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Policy" /v VerifiedAndReputablePolicyState /t REG_DWORD /d 0 /f
"`n" | CiTool.exe -r

# Start logging
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-DateLog "Start sandbox configuration" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log"

if (Test-Path "C:\log\log.txt") {
	Add-Shortcut -SourceLnk "${HOME}\Desktop\progress.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Get-Content C:\log\verify.txt -Wait"
}

# Set the execution policy to Bypass for default PowerShell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force

# Install 7-Zip first - needed for other installations
Start-Process -Wait msiexec -ArgumentList "/i ${SETUP_PATH}\7zip.msi /qn /norestart"
Write-DateLog "7-Zip installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Copy config files and import them
if (Test-Path "${LOCAL_PATH}\config.txt") {
    Copy-Item "${LOCAL_PATH}\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force | Out-Null
}
. "${WSDFIR_TEMP}\config.ps1"
Write-DateLog "Config files copied and imported" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# PowerShell
if (Test-Path "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1") {
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
    Copy-Item "${LOCAL_PATH}\defaults\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
}

Copy-Item "${HOME}\Documents\tools\utils\PSDecode.psm1" "${env:ProgramFiles}\PowerShell\Modules\PSDecode" -Force | Out-Null

# Link latest PowerShell and set execution policy to Bypass
New-Item -Path "${env:ProgramFiles}\PowerShell\7" -ItemType SymbolicLink -Value "${TOOLS}\pwsh" -Force | Out-Null
& "${POWERSHELL_EXE}" -Command "Set-ExecutionPolicy -Scope CurrentUser Unrestricted"
Write-DateLog "PowerShell installed and execution policy set to Unrestricted for pwsh done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Shortcut for PowerShell
Enable-ExperimentalFeature PSFeedbackProvider

# Install Terminal and link to it
Expand-Archive "${SETUP_PATH}\Terminal.zip" -DestinationPath "$env:ProgramFiles\Windows Terminal" -Force | Out-Null
$TERMINAL_INSTALL_DIR = ((Get-ChildItem "$env:ProgramFiles\Windows Terminal").Name | findstr "terminal" | Select-Object -Last 1)
if (! (Test-Path "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR\settings")) {
	New-Item -Path "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR\settings" -ItemType Directory -Force | Out-Null
}
Copy-Item "$LOCAL_PATH\defaults\Windows_Terminal.json" "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR\settings\settings.json" -Force | Out-Null
$TERMINAL_INSTALL_LOCATION = "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR"

# Add PersistenceSniper
Import-Module ${GIT_PATH}\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1

#
# Install base tools
#

# Always install common Java.
Start-Process msiexec -ArgumentList "/i ${SETUP_PATH}\corretto.msi /qn /norestart"
Write-DateLog "Java installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install Python
& "${SETUP_PATH}\python3.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
Write-DateLog "Python installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install Visual C++ Redistributable 16 and 17
Start-Process -Wait "${SETUP_PATH}\vcredist_17_x64.exe" -ArgumentList "/passive /norestart"
Write-DateLog "Visual C++ Redistributable installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install .NET 6
Start-Process -Wait "${SETUP_PATH}\dotnet6desktop.exe" -ArgumentList "/install /quiet /norestart"
Write-DateLog ".NET 6 Desktop runtime installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install .NET 8
Start-Process -Wait "${SETUP_PATH}\dotnet8desktop.exe" -ArgumentList "/install /quiet /norestart"
Write-DateLog ".NET 8 Desktop runtime installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install OhMyPosh
if ("${WSDFIR_OHMYPOSH}" -eq "Yes") {
    Install-OhMyPosh | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install HxD
Copy-Item "${TOOLS}\hxd\HxDSetup.exe" "${WSDFIR_TEMP}\HxDSetup.exe" -Force
& "${WSDFIR_TEMP}\HxDSetup.exe" /VERYSILENT /NORESTART
Write-DateLog "HxD installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install IrfanView
& "${SETUP_PATH}\irfanview.exe" /silent /assoc=2 | Out-Null
Write-DateLog "IrfanView installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install Notepad++ and plugins
& "${SETUP_PATH}\notepad++.exe" /S  | Out-Null
Write-DateLog "Notepad++ installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

#
# Configure the sandbox
#

# Set date and time format
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortDate -value "yyyy-MM-dd" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sLongDate -value "yyyy-MMMM-dddd" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss" | Out-Null
Write-DateLog "Date and time format set" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Add right-click context menu if specified
if ("${WSDFIR_RIGHTCLICK}" -eq "Yes") {
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve | Out-Null
    Write-DateLog "Right-click context menu added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Import registry settings
reg import "${HOME}\Documents\tools\reg\registry.reg" | Out-Null
if ($WINDOWS_VERSION -eq "10") {
	reg import "${HOME}\Documents\tools\reg\right-click-win10.reg" | Out-Null
}
Write-DateLog "Registry settings imported" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

foreach ($extension in "doc", "docm", "docx", "dot", "dotm", "dotx", "xls", "xlsm", "xlsx", "xlt", "xltm", "xltx", "ppt", "pptm", "pptx", "pot", "potm", "potx") {
    $registry_file = @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\Software\Classes\.${extension}\shell\${extension}]
"MUIVerb"="dfirws office"
"SubCommands"=""

[HKEY_LOCAL_MACHINE\Software\Classes\.${extension}\shell\${extension}\shell\mraptor]
"MUIVerb"="mraptor"

[HKEY_LOCAL_MACHINE\Software\Classes\.${extension}\shell\${extension}\shell\mraptor\command]
@="pwsh -NoExit -Command mraptor '%1'"

[HKEY_LOCAL_MACHINE\Software\Classes\.${extension}\shell\${extension}\shell\oleid]
"MUIVerb"="oleid"

[HKEY_LOCAL_MACHINE\Software\Classes\.${extension}\shell\${extension}\shell\oleid\command]
@="pwsh -NoExit -Command oleid '%1'"

[HKEY_LOCAL_MACHINE\Software\Classes\.${extension}\shell\${extension}\shell\olevba]
"MUIVerb"="olevba"

[HKEY_LOCAL_MACHINE\Software\Classes\.${extension}\shell\${extension}\shell\olevba\command]
@="pwsh -NoExit -Command olevba '%1'"

"@

    $registry_file | Out-File -FilePath "${WSDFIR_TEMP}\${extension}.reg" -Encoding ascii
    reg import "${WSDFIR_TEMP}\${extension}.reg" | Out-Null
    remove-item "${WSDFIR_TEMP}\${extension}.reg"
}
Write-DateLog "Office extensions added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Set dark theme if selected
if ("${WSDFIR_DARK}" -eq "Yes") {
    Start-Process -Wait "c:\Windows\Resources\Themes\themeB.theme"
	Stop-Process -Name SystemSettings
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 | Out-Null
}

Update-Wallpaper "${SETUP_PATH}\dfirws.jpg"
Write-DateLog "Wallpaper updated" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Disable firewall to enable local web services
netsh firewall set opmode DISABLE 2>&1 | Out-Null

# Hide the taskbar
if ("${WSDFIR_HIDE_TASKBAR}" -eq "Yes") {
    # From https://www.itechtics.com/hide-show-taskbar/#from-windows-powershell
    &{$p='HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3';$v=(Get-ItemProperty -Path $p).Settings;$v[8]=3;&Set-ItemProperty -Path $p -Name Settings -Value $v;&Stop-Process -f -ProcessName explorer}
}

# Restart Explorer process
Stop-Process -ProcessName "Explorer" -Force
Write-DateLog "Explorer restarted" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

#
# Configure PATH
#

Write-DateLog "Add to PATH" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
$GHIDRA_INSTALL_DIR=((Get-ChildItem "${TOOLS}\ghidra\").Name | findstr "PUBLIC" | Select-Object -Last 1)

$ADD_TO_PATH = @("${MSYS2_DIR}"
    "${MSYS2_DIR}\ucrt64\bin"
    "${MSYS2_DIR}\usr\bin"
	"${TOOLS}\perl\perl\bin"
	"${env:ProgramFiles}\4n4lDetector"
	"${env:ProgramFiles}\7-Zip"
	"${env:ProgramFiles}\BeaconHunter"
	"${env:ProgramFiles}\bin"
	"${env:ProgramFiles}\ForensicTimeliner"
	"${env:ProgramFiles}\Git\bin"
	"${env:ProgramFiles}\Git\cmd"
	"${env:ProgramFiles}\Git\usr\bin"
	"${env:ProgramFiles}\graphviz\bin"
	"${env:ProgramFiles}\hxd"
	"${env:ProgramFiles}\IDR\bin"
	"${env:ProgramFiles}\iisGeolocate"
	"${env:ProgramFiles}\jadx\bin"
	"${env:ProgramFiles}\KAPE"
	"${env:ProgramFiles}\loki"
	"${env:ProgramFiles}\Notepad++"
	"${env:ProgramFiles}\RegistryExplorer"
	"${env:ProgramFiles}\ShellBagsExplorer"
	"${env:ProgramFiles}\TimelineExplorer"
	"${env:ProgramFiles}\qemu"
	"${RUST_DIR}\bin"
	"${GIT_PATH}\defender-detectionhistory-parser"
	"${GIT_PATH}\ese-analyst"
	"${GIT_PATH}\Events-Ripper"
	"${GIT_PATH}\iShutdown"
	"${GIT_PATH}\RegRipper4.0"
	"${GIT_PATH}\Regshot"
	"${GIT_PATH}\Trawler"
	"${GIT_PATH}\White-Phoenix"
	"${HOME}\Go\bin"
	"${TERMINAL_INSTALL_LOCATION}"
	"${TOOLS}\artemis"
	"${TOOLS}\audacity"
	"${TOOLS}\bin"
	"${TOOLS}\bulk_extractor\win64"
	"${TOOLS}\capa"
	"${TOOLS}\capa-ghidra"
	"${TOOLS}\cargo\bin"
	"${TOOLS}\chainsaw"
	"${TOOLS}\cutter"
	"${TOOLS}\sqlitebrowser"
	"${TOOLS}\DidierStevens"
	"${TOOLS}\die"
	"${TOOLS}\dumpbin"
	"${TOOLS}\edit"
	"${TOOLS}\elfparser-ng\Release"
	"${TOOLS}\ExeinfoPE"
	"${TOOLS}\exiftool"
	"${TOOLS}\fakenet"
	"${TOOLS}\fasm"
	"${TOOLS}\ffmpeg\bin"
	"${TOOLS}\floss"
	"${TOOLS}\FullEventLogView"
	"${TOOLS}\gftrace64"
    "${TOOLS}\ghidra\${GHIDRA_INSTALL_DIR}"
	"${TOOLS}\godap"
	"${TOOLS}\GoReSym"
	"${TOOLS}\h2database"
	"${TOOLS}\hayabusa"
	"${TOOLS}\hfs"
	"${TOOLS}\imhex"
	"${TOOLS}\INDXRipper"
	"${TOOLS}\jd-gui"
	"${TOOLS}\MailView"
	"${TOOLS}\MemProcFS"
	"${TOOLS}\mmdbinspect"
	"${TOOLS}\lessmsi"
	"${TOOLS}\nmap"
	"${TOOLS}\node"
	"${TOOLS}\pebear"
	"${TOOLS}\pestudio"
	"${TOOLS}\pev"
	"${TOOLS}\php"
	"${TOOLS}\procdot\win64"
	"${TOOLS}\pstwalker"
	"${TOOLS}\qpdf\bin"
	"${TOOLS}\qrtool"
	"${TOOLS}\radare2\bin"
	"${TOOLS}\RdpCacheStitcher"
	"${TOOLS}\redress"
	"${TOOLS}\ripgrep"
	"${TOOLS}\scdbg"
	"${TOOLS}\sleuthkit\bin"
	"${TOOLS}\sqlite"
	"${TOOLS}\ssview"
	"${TOOLS}\systeminformer\x64"
	"${TOOLS}\systeminformer\x86"
	"${TOOLS}\sysinternals"
	"${TOOLS}\takajo"
	"${TOOLS}\thumbcacheviewer"
	"${TOOLS}\trid"
	"${TOOLS}\upx"
	"${TOOLS}\VolatilityWorkbench"
	"${TOOLS}\WinApiSearch"
	"${TOOLS}\WinObjEx64"
	"${TOOLS}\XELFViewer"
	"${TOOLS}\Zimmerman\net6"
	"${TOOLS}\Zimmerman\net6\EvtxECmd"
	"${TOOLS}\Zimmerman\net6\EZViewer"
	"${TOOLS}\Zimmerman\net6\JumpListExplorer"
	"${TOOLS}\Zimmerman\net6\MFTExplorer"
	"${TOOLS}\Zimmerman\net6\RECmd"
	"${TOOLS}\Zimmerman\net6\SDBExplorer"
	"${TOOLS}\Zimmerman\net6\SQLECmd"
	"${TOOLS}\Zimmerman\net6\XWFIM"
	"${TOOLS}\zircolite"
	"${TOOLS}\zircolite\bin"
	"${TOOLS}\zstd"
	"${VENV}\bin"
	"${VENV}\jpterm\Scripts"
	"${VENV}\magika\Scripts"
	"${VENV}\maldump\Scripts"
	"${VENV}\peepdf3\Scripts"
	"${VENV}\regipy\Scripts"
	"${VENV}\sigma-cli\Scripts"
	"${VENV}\toolong\Scripts"
	"${HOME}\Documents\tools\utils")

$ADD_TO_PATH_STRING = $ADD_TO_PATH -join ";"
Add-MultipleToUserPath $ADD_TO_PATH_STRING

Write-DateLog "Start creation of Desktop/dfirws" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
Start-Process ${POWERSHELL_EXE} -ArgumentList "${HOME}\Documents\tools\utils\dfirws_folder.ps1" -NoNewWindow

#
# Install tools
#

# Add jadx
if ("${WSDFIR_JADX}" -eq "Yes") {
    Install-Jadx | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "jadx added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Add x64dbg if specified
if ("${WSDFIR_X64DBG}" -eq "Yes") {
    Install-X64dbg | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "x64dbg added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Add cmder
if ("${WSDFIR_CMDER}" -eq "Yes") {
    Install-CMDer | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "cmder added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Add apimonitor
if ("${WSDFIR_APIMONITOR}" -eq "Yes") {
    Install-Apimonitor | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "apimonitor added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Setup Node.js
if ("${WSDFIR_NODE}" -eq "Yes") {
    Install-Node | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Node.js installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Setup Obsidian
if ("${WSDFIR_OBSIDIAN}" -eq "Yes") {
    Install-Obsidian | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Obsidian installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Qemu
if ("${WSDFIR_QEMU}" -eq "Yes") {
    Install-Qemu | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Qemu installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Kape
if ("${WSDFIR_KAPE}" -eq "Yes") {
    Install-Kape | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Kape installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Loki
if ("${WSDFIR_LOKI}" -eq "Yes") {
    Install-Loki | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Loki installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install malcat
if ("${WSDFIR_MALCAT}" -eq "Yes") {
    Install-Malcat | Out-Null
    Write-DateLog "malcat installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install NEO4J if specified
if ("${WSDFIR_NEO4J}" -eq "Yes") {
    Install-Neo4j | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Neo4j installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install LibreOffice with custom arguments if specified
if ("${WSDFIR_LIBREOFFICE}" -eq "Yes") {
    Install-LibreOffice | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "LibreOffice installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Git if specified
if ("${WSDFIR_GIT}" -eq "Yes") {
    Start-Process "${POWERSHELL_EXE}" -ArgumentList "-Command Install-Git" -NoNewWindow
    Write-DateLog "Git installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install PDFStreamDumper if specified
if ("${WSDFIR_PDFSTREAM}" -eq "Yes") {
    Install-PDFStreamDumper | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "PDFStreamDumper installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Visual Studio Code and extensions if specified
if ("${WSDFIR_VSCODE}" -eq "Yes") {
    Install-VSCode | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Visual Studio Code installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Zui if specified
if ("${WSDFIR_ZUI}" -eq "Yes") {
    Install-Zui | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Zui installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install hashcat
if ("${WSDFIR_HASHCAT}" -eq "Yes") {
    Install-Hashcat | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Installing hashcat done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

& "${SETUP_PATH}\graphviz.exe" /S /D="${env:ProgramFiles}\graphviz"
Write-DateLog "Installing Graphviz done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

#
# Copy files to user profile
#

New-Item -Path "${HOME}/ghidra_scripts" -ItemType Directory -Force | Out-Null
if (Test-Path "${SETUP_PATH}\capa_explorer.py") {
    Copy-Item "${SETUP_PATH}\capa_explorer.py" "${HOME}/ghidra_scripts/capa_explorer.py" -Force | Out-Null
}if (Test-Path "${SETUP_PATH}\capa_ghidra.py") {
    Copy-Item "${SETUP_PATH}\capa_ghidra.py" "${HOME}/ghidra_scripts/capa_ghidra.py" -Force | Out-Null
}

# TODO Verify Robocopy destinations

# Add plugins to Cutter
New-Item -ItemType Directory -Force -Path "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" | Out-Null
Copy-Item "${GIT_PATH}\radare2-deep-graph\cutter\graphs_plugin_grid.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
Copy-Item "${SETUP_PATH}\x64dbgcutter.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
Copy-Item "${GIT_PATH}\cutterref\cutterref.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\cutterref\archs" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\archs" | Out-Null
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\cutter-jupyter\icons" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\icons" | Out-Null
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\capa-explorer\capa_explorer_plugin" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\capa_explorer_plugin" | Out-Null
Write-DateLog "Installed Cutter plugins." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append


#
# Copy and extract files that need be in writeable locations
#

# BeaconHunter
Robocopy.exe /MT:96 /MIR "${TOOLS}\BeaconHunter" "${env:ProgramFiles}\BeaconHunter" | Out-Null

# IDR
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\IDR" "${env:ProgramFiles}\IDR" | Out-Null

# Jupyter
Robocopy.exe /MT:96 /MIR "${HOME}\Documents\tools\jupyter\.jupyter" "${HOME}\.jupyter" | Out-Null
Copy-Item "${HOME}\Documents\tools\jupyter\common.py" "${HOME}\Documents\jupyter\" -Force | Out-Null
Copy-Item "${HOME}\Documents\tools\jupyter\*.ipynb" "${HOME}\Documents\jupyter\" -Force | Out-Null

Robocopy.exe /MT:96 /MIR "${TOOLS}\Zimmerman\net6\iisGeolocate" "${env:ProgramFiles}\iisGeolocate" | Out-Null
if (Test-Path "C:\enrichment\maxmind_current\GeoLite2-City.mmdb") {
    Copy-Item "C:\enrichment\maxmind_current\GeoLite2-City.mmdb" "${env:ProgramFiles}\iisGeolocate\" -Force | Out-Null
}
Robocopy.exe /MT:96 /MIR "${TOOLS}\Zimmerman\net6\RegistryExplorer" "${env:ProgramFiles}\RegistryExplorer" | Out-Null
Robocopy.exe /MT:96 /MIR "${TOOLS}\Zimmerman\net6\ShellBagsExplorer" "${env:ProgramFiles}\ShellBagsExplorer" | Out-Null
Robocopy.exe /MT:96 /MIR "${TOOLS}\Zimmerman\net6\TimelineExplorer" "${env:ProgramFiles}\TimelineExplorer" | Out-Null

# AuthLogParser
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\AuthLogParser" "${env:ProgramFiles}\AuthLogParser" | Out-Null

# 4n4lDetector
& "${env:ProgramFiles}\7-Zip\7z.exe" x "${SETUP_PATH}\4n4lDetector.zip" -o"${env:ProgramFiles}\4n4lDetector" | Out-Null

#
# Add shortcuts to desktop
#

Add-Shortcut -SourceLnk "${HOME}\Desktop\jupyter.lnk" -DestinationPath "${HOME}\Documents\tools\utils\jupyter.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws wiki.lnk" -DestinationPath "${HOME}\Documents\tools\utils\gollum.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\Windows Terminal.lnk" -DestinationPath "${TERMINAL_INSTALL_LOCATION}\wt.exe" -WorkingDirectory "${HOME}\Desktop"

#
# Config for bash and zsh
#
if (Test-Path "${LOCAL_PATH}\.zshrc") {
    Copy-Item "${LOCAL_PATH}\.zshrc" "${HOME}\.zshrc" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\.zshrc" "${HOME}\.zshrc" -Force | Out-Null
}
if (Test-Path "${LOCAL_PATH}\.zcompdump") {
    Copy-Item "${LOCAL_PATH}\.zcompdump" "${HOME}\.zcompdump" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\.zcompdump" "${HOME}\.zcompdump" -Force | Out-Null
}

#
# Run custom scripts
#

if (Test-Path "${LOCAL_PATH}\customize.ps1") {
    Write-DateLog "Running customize script." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\customize.ps1" @args | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
} elseif (Test-Path "${LOCAL_PATH}\customise.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\customise.ps1" @args | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Running customise scripts done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
} else {
    Write-DateLog "No customize scripts found, running defaults\customize-sandbox.ps1." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\defaults\customize-sandbox.ps1" @args | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}


#
# Start sysmon when installation is done
#

if ("${WSDFIR_SYSMON}" -eq "Yes") {
    & "${TOOLS}\sysinternals\Sysmon64.exe" -accepteula -i "${WSDFIR_SYSMON_CONF}" | Out-Null
}
Write-DateLog "Starting sysmon done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

if (Test-Path "C:\log\log.txt") {
    Write-SynchronizedLog "Running install_all.ps1 script."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")
    & "${HOME}\Documents\tools\install\install_all.ps1" | Out-Null
    Write-SynchronizedLog "Running install_verify.ps1 script."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")
    & "${HOME}\Documents\tools\install\install_verify.ps1" | Out-Null
    Get-Job | Wait-Job | Out-Null
    Get-Job | Receive-Job 2>&1 >> ".\log\jobs.txt"
    Get-Job | Remove-Job | Out-Null
    Write-Output "" > "C:\log\verify_done"
}

# Wait for all jobs to finish and clean up
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job 2>&1 | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
Get-Job | Remove-Job | Out-Null
Remove-Item "${WSDFIR_TEMP}\HxDSetup.exe" -Force

Write-DateLog "Setup done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

Exit 0