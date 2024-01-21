# DFIRWS

# Import common functions
. $HOME\Documents\tools\wscommon.ps1

# Start logging
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Create required directories
New-Item -ItemType Directory "$TEMP"
New-Item -ItemType Directory "$DATA"
New-Item -ItemType Directory "$env:ProgramFiles\bin"
New-Item -ItemType Directory "$HOME\Documents\WindowsPowerShell"
New-Item -ItemType Directory "$HOME\Documents\PowerShell"
New-Item -ItemType Directory "$env:ProgramFiles\PowerShell\Modules\PSDecode"
New-Item -ItemType Directory "$HOME\Documents\jupyter"

Write-DateLog "Start sandbox setup" > $TEMP\start_sandbox.log

# Bypass the execution policy for the current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Copy config files and import them
Copy-Item "$HOME\Documents\tools\default-config.txt" $TEMP\default-config.ps1
Copy-Item "$HOME\Documents\tools\config.txt" $TEMP\config.ps1
. $TEMP\default-config.ps1
. $TEMP\config.ps1
Write-DateLog "Config files copied and imported" >> $TEMP\start_sandbox.log

# PowerShell
Copy-Item "$HOME\Documents\tools\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Copy-Item "$HOME\Documents\tools\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Copy-Item "$HOME\Documents\tools\utils\PSDecode.psm1" "$env:ProgramFiles\PowerShell\Modules\PSDecode"

# Jupyter
Copy-Item "$HOME\Documents\tools\jupyter\.jupyter" "$HOME\" -Recurse
Copy-Item "$HOME\Documents\tools\jupyter\common.py" "$HOME\Documents\jupyter\"
Copy-Item $HOME\Documents\tools\jupyter\*.ipynb "$HOME\Documents\jupyter\"

# Install latest PowerShell
Copy-Item   "$SETUP_PATH\powershell.msi" "$TEMP\powershell.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\powershell.msi /qn /norestart"
Write-DateLog "PowerShell installed" >> $TEMP\start_sandbox.log

# Install 7-Zip
Copy-Item "$SETUP_PATH\7zip.msi" "$TEMP\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\7zip.msi /qn /norestart"
Write-DateLog "7-Zip installed" >> $TEMP\start_sandbox.log

# Always install common Java.
Copy-Item "$SETUP_PATH\corretto.msi" "$TEMP\corretto.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\corretto.msi /qn /norestart"
Write-DateLog "Java installed" >> $TEMP\start_sandbox.log

# Install Python
& "$SETUP_PATH\python3.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
Write-DateLog "Python installed" >> $TEMP\start_sandbox.log

# Install Visual C++ Redistributable 16 and 17
Start-Process -Wait "$SETUP_PATH\vcredist_16_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -Wait "$SETUP_PATH\vcredist_17_x64.exe" -ArgumentList "/passive /norestart"
Write-DateLog "Visual C++ Redistributable installed" >> $TEMP\start_sandbox.log

# Install .NET 6
Start-Process -Wait "$SETUP_PATH\dotnet6.exe" -ArgumentList "/install /quiet /norestart"
Write-DateLog ".NET 6 installed" >> $TEMP\start_sandbox.log

# Install HxD
Copy-Item "$TOOLS\hxd\HxDSetup.exe" "$TEMP\HxDSetup.exe"
& "$TEMP\HxDSetup.exe" /VERYSILENT /NORESTART
Write-DateLog "HxD installed" >> $TEMP\start_sandbox.log

# Install Notepad++ and ComparePlus plugin
Copy-Item "$SETUP_PATH\notepad++.exe" "$TEMP\notepad++.exe"
& "$TEMP\notepad++.exe" /S
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\comparePlus.zip" -o"$env:ProgramFiles\Notepad++\Plugins\ComparePlus"
Write-DateLog "Notepad++ installed" >> $TEMP\start_sandbox.log

# Install NEO4J
if ($WSDFIR_NEO4J -eq "Yes") {
    Install-Neo4j
    Write-DateLog "Neo4j installed" >> $TEMP\start_sandbox.log
}

# Install LibreOffice with custom arguments
if ($WSDFIR_LIBREOFFICE -eq "Yes") {
    Install-LibreOffice
    Write-DateLog "LibreOffice installed" >> $TEMP\start_sandbox.log
}

# Install Git if specified
if ($WSDFIR_GIT -eq "Yes") {
    Install-GitBash
    Write-DateLog "Git installed" >> $TEMP\start_sandbox.log
}

# Install PDFStreamDumper if specified
if ($WSDFIR_PDFSTREAM -eq "Yes") {
    Install-PDFStreamDumper
    Write-DateLog "PDFStreamDumper installed" >> $TEMP\start_sandbox.log
}

# Install Visual Studio Code and PowerShell extension if specified
if ($WSDFIR_VSCODE -eq "Yes") {
    Install-VSCode
    Write-DateLog "Visual Studio Code installed" >> $TEMP\start_sandbox.log
}

# Install Zui if specified
if ($WSDFIR_ZUI -eq "Yes") {
    Install-Zui
    Write-DateLog "Zui installed" >> $TEMP\start_sandbox.log
}

# Set date and time format
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortDate -value "yyyy-MM-dd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sLongDate -value "yyyy-MMMM-dddd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss"
Write-DateLog "Date and time format set" >> $TEMP\start_sandbox.log

# Dark mode
if ($WSDFIR_DARK -eq "Yes") {
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0
    New-Item -Path "$env:USERPROFILE\AppData\Roaming\Notepad++" -ItemType Directory -Force | Out-Null
    Copy-Item "$env:USERPROFILE\Documents\tools\configurations\notepad++_dark.xml" "$env:USERPROFILE\AppData\Roaming\Notepad++\config.xml" -Force
    Write-DateLog "Dark mode set" >> $TEMP\start_sandbox.log
}

# Show file extensions
Write-DateLog "Show file extensions" >> $TEMP\start_sandbox.log
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt /v DefaultValue /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL /v DefaultValue /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 1 /f
Write-DateLog "File extensions shown" >> $TEMP\start_sandbox.log

# Add right-click context menu if specified
if ($WSDFIR_RIGHTCLICK -eq "Yes") {
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    Write-DateLog "Right-click context menu added" >> $TEMP\start_sandbox.log
}

# Import registry settings
reg import $HOME\Documents\tools\registry.reg
Write-DateLog "Registry settings imported" >> $TEMP\start_sandbox.log

# Restart Explorer process
Stop-Process -ProcessName Explorer -Force
Write-DateLog "Explorer restarted" >> $TEMP\start_sandbox.log

# Add to PATH
Write-DateLog "Add to PATH" >> $TEMP\start_sandbox.log
Add-ToUserPath "$env:ProgramFiles\4n4lDetector"
Add-ToUserPath "$env:ProgramFiles\7-Zip"
Add-ToUserPath "$env:ProgramFiles\bin"
Add-ToUserPath "$env:ProgramFiles\Git\bin"
Add-ToUserPath "$env:ProgramFiles\Git\usr\bin"
Add-ToUserPath "$env:ProgramFiles\graphviz\bin"
Add-ToUserPath "$env:ProgramFiles\hashcat"
Add-ToUserPath "$env:ProgramFiles\hxd"
Add-ToUserPath "$env:ProgramFiles\IDR\bin"
Add-ToUserPath "$env:ProgramFiles\jadx\bin"
Add-ToUserPath "$env:ProgramFiles\KAPE"
Add-ToUserPath "$env:ProgramFiles\loki"
Add-ToUserPath "$env:ProgramFiles\Notepad++"
Add-ToUserPath "$env:ProgramFiles\qemu"
Add-ToUserPath "C:\Rust\bin"
Add-ToUserPath "$GIT\ese-analyst"
Add-ToUserPath "$GIT\Events-Ripper"
Add-ToUserPath "$GIT\RegRipper3.0"
Add-ToUserPath "$GIT\Regshot"
Add-ToUserPath "$GIT\Trawler"
Add-ToUserPath "$GIT\Zircolite\bin"
Add-ToUserPath "$TOOLS\bin"
Add-ToUserPath "$TOOLS\bulk_extractor\win64"
Add-ToUserPath "$TOOLS\capa"
Add-ToUserPath "$TOOLS\capa-ghidra"
Add-ToUserPath "$TOOLS\cargo\bin"
Add-ToUserPath "$TOOLS\chainsaw"
Add-ToUserPath "$TOOLS\cutter"
Add-ToUserPath "$TOOLS\DB Browser for SQLite"
Add-ToUserPath "$TOOLS\DidierStevens"
Add-ToUserPath "$TOOLS\die"
Add-ToUserPath "$TOOLS\elfparser-ng\Release"
Add-ToUserPath "$TOOLS\ExeinfoPE"
Add-ToUserPath "$TOOLS\exiftool"
Add-ToUserPath "$TOOLS\fakenet"
Add-ToUserPath "$TOOLS\fasm"
Add-ToUserPath "$TOOLS\floss"
Add-ToUserPath "$TOOLS\FullEventLogView"
Add-ToUserPath "$TOOLS\gftrace64"
Add-ToUserPath "$TOOLS\GoReSym"
Add-ToUserPath "$TOOLS\hayabusa"
Add-ToUserPath "$TOOLS\imhex"
Add-ToUserPath "$TOOLS\INDXRipper"
Add-ToUserPath "$TOOLS\jd-gui"
Add-ToUserPath "$TOOLS\MailView"
Add-ToUserPath "$TOOLS\malcat\bin"
Add-ToUserPath "$TOOLS\lessmsi"
Add-ToUserPath "$TOOLS\nmap"
Add-ToUserPath "$TOOLS\node"
Add-ToUserPath "$TOOLS\perl\perl\bin"
Add-ToUserPath "$TOOLS\pestudio"
Add-ToUserPath "$TOOLS\pev"
Add-ToUserPath "$TOOLS\php"
Add-ToUserPath "$TOOLS\procdot\win64"
Add-ToUserPath "$TOOLS\pstwalker"
Add-ToUserPath "$TOOLS\qpdf\bin"
Add-ToUserPath "$TOOLS\qrtool"
Add-ToUserPath "$TOOLS\radare2\bin"
Add-ToUserPath "$TOOLS\RdpCacheStitcher"
Add-ToUserPath "$TOOLS\redress"
#Add-ToUserPath "$TOOLS\resource_hacker"
Add-ToUserPath "$TOOLS\ripgrep"
Add-ToUserPath "$TOOLS\scdbg"
Add-ToUserPath "$TOOLS\sleuthkit\bin"
Add-ToUserPath "$TOOLS\sqlite"
Add-ToUserPath "$TOOLS\ssview"
Add-ToUserPath "$TOOLS\systeminformer\x64"
Add-ToUserPath "$TOOLS\systeminformer\x86"
Add-ToUserPath "$TOOLS\sysinternals"
Add-ToUserPath "$TOOLS\thumbcacheviewer"
Add-ToUserPath "$TOOLS\trid"
Add-ToUserPath "$TOOLS\upx"
Add-ToUserPath "$TOOLS\VolatilityWorkbench"
Add-ToUserPath "$TOOLS\WinApiSearch"
Add-ToUserPath "$TOOLS\WinObjEx64"
Add-ToUserPath "$TOOLS\XELFViewer"
Add-ToUserPath "$TOOLS\Zimmerman"
Add-ToUserPath "$TOOLS\Zimmerman\EvtxECmd"
Add-ToUserPath "$TOOLS\Zimmerman\EZViewer"
Add-ToUserPath "$TOOLS\Zimmerman\Hasher"
Add-ToUserPath "$TOOLS\Zimmerman\iisGeolocate"
Add-ToUserPath "$TOOLS\Zimmerman\JumpListExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\MFTExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\RECmd"
Add-ToUserPath "$TOOLS\Zimmerman\RegistryExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\SDBExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\ShellBagsExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\SQLECmd"
Add-ToUserPath "$TOOLS\Zimmerman\TimelineExplorer"
Add-ToUserPath "$TOOLS\Zimmerman\XWFIM"
Add-ToUserPath "$TOOLS\zstd"
Add-ToUserPath "$VENV\maldump\Scripts"
Add-ToUserPath "$HOME\Documents\tools\utils"
Write-DateLog "Added to PATH" >> $TEMP\start_sandbox.log

# Shortcut for PowerShell
Add-Shortcut -SourceLnk "$HOME\Desktop\PowerShell.lnk" -DestinationPath "$env:ProgramFiles\PowerShell\7\pwsh.exe" -WorkingDirectory "$HOME\Desktop"

# Copy tools
Copy-Item "$SETUP_PATH\BeaconHunter.exe" "$env:ProgramFiles\bin"
Copy-Item -Recurse -Force $TOOLS\4n4lDetector "$env:ProgramFiles"
Copy-Item -Recurse -Force $GIT\IDR "$env:ProgramFiles"
Write-DateLog "Tools copied" >> $TEMP\start_sandbox.log

# Add jadx
if ($WSDFIR_JADX -eq "Yes") {
    Install-Jadx
    Write-DateLog "jadx added" >> $TEMP\start_sandbox.log
}

# Add x64dbg if specified
if ($WSDFIR_X64DBG -eq "Yes") {
    Install-X64dbg
    Write-DateLog "x64dbg added" >> $TEMP\start_sandbox.log
}

# Configure PowerShell logging
New-Item -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Name EnableScriptBlockLogging -Value 1 -Force

# Add cmder
if ($WSDFIR_CMDER -eq "Yes") {
    Install-CMDer
    Write-DateLog "cmder added" >> $TEMP\start_sandbox.log
}

# Add PersistenceSniper
if ($WSDFIR_PERSISTENCESNIPER -eq "Yes") {
    Import-Module $GIT\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1
    Write-DateLog "PersistenceSniper added" >> $TEMP\start_sandbox.log
}

# Add apimonitor
if ($WSDFIR_APIMONITOR -eq "Yes") {
    Install-Apimonitor
    Write-DateLog "apimonitor added" >> $TEMP\start_sandbox.log
}

# Configure usage of new venv for PowerShell
(Get-ChildItem -File $VENV\default\Scripts\).Name | findstr /R /V "[\._]" | findstr /V activate | `
    ForEach-Object {Write-Output "function $_() { python $VENV\default\Scripts\$_ `$PsBoundParameters.Values + `$args }"} | Out-File -Append -Encoding "ascii" "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Write-DateLog "New venv configured for PowerShell" >> $TEMP\start_sandbox.log

# Signal that everything is done to start using the tools (mostly).
Update-Wallpaper "$SETUP_PATH\dfirws.jpg"
Write-DateLog "Wallpaper updated" >> $TEMP\start_sandbox.log

# Run install script for choco packages
if ($WSDFIR_CHOCO -eq "Yes") {
    Install-Choco
    # Add packages below
}

# Setup Node.js
if ($WSDFIR_NODE -eq "Yes") {
    Install-Node
    Write-DateLog "Node.js installed" >> $TEMP\start_sandbox.log
}

# Setup Obsidian
if ($WSDFIR_OBSIDIAN -eq "Yes") {
    Install-Obsidian
    Write-DateLog "Obsidian installed" >> $TEMP\start_sandbox.log
}

# Install Qemu
if ($WSDFIR_QEMU -eq "Yes") {
    Install-Qemu
    Write-DateLog "Qemu installed" >> $TEMP\start_sandbox.log
}

# Install extra tools for Git-bash
if ($WSDFIR_BASH_EXTRA -eq "Yes") {
    Install-BashExtra
    Write-DateLog "Extra tools for Git-bash installed" >> $TEMP\start_sandbox.log
}

# Set Notepad++ as default for many file types
# Use %VARIABLE% in cmd.exe
cmd /c Ftype xmlfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype chmfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype cmdfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype htafile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype jsefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype jsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype vbefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype vbsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
Write-DateLog "Notepad++ set as default for many file types" >> $TEMP\start_sandbox.log

# Last commands
if ($WSDFIR_W10_LOOPBACK -eq "Yes") {
    Install-W10Loopback
}

# Install Kape
if ($WSDFIR_KAPE -eq "Yes") {
    Install-Kape
    Write-DateLog "Kape installed" >> $TEMP\start_sandbox.log
}

# Install Loki
if ($WSDFIR_LOKI -eq "Yes") {
    Install-Loki
    Write-DateLog "Loki installed" >> $TEMP\start_sandbox.log
}

# Clean up
Remove-Item $HOME\Desktop\PdfStreamDumper.exe.lnk

Write-DateLog "Start creation of Desktop/dfirws" >> $TEMP\start_sandbox.log
# Create directory for shortcuts to installed tools
New-Item -ItemType Directory "$HOME\Desktop\dfirws"
# $TOOLS\DidierStevens
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\DidierStevens.lnk" -DestinationPath "$TOOLS\DidierStevens"

# Editors
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Editors"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Bytecode Viewer.lnk" -DestinationPath "$TOOLS\bin\bcv.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\HxD.lnk" -DestinationPath "$env:ProgramFiles\HxD\HxD.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\ImHex.lnk" -DestinationPath "C:Tools\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Malcat.lnk" -DestinationPath "$TOOLS\Malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Notepad++.lnk" -DestinationPath "$env:ProgramFiles\Notepad++\notepad++.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Visual Studio Code.lnk" -DestinationPath "$HOME\AppData\Local\Programs\Microsoft VS Code\Code.exe"

# File and apps
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\autoit-ripper.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\binlex.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\bulk_extractor64.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\densityscout.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Detect It Easy.lnk" -DestinationPath "$TOOLS\die\die.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\ezhexviewer.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\fq.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\lessmsi-gui.lnk" -DestinationPath "$TOOLS\lessmsi\lessmsi-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\msidump.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\qrtool.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\ripgrep (rg).lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\trid.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Browser"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\hindsight.lnk" -DestinationPath "$TOOLS\bin\hindsight_gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\BrowsingHistoryView.lnk" -DestinationPath "$TOOLS\nirsoft\BrowsingHistoryView.exe" -Iconlocation "$TOOLS\nirsoft\BrowsingHistoryView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\ChromeCacheView.lnk" -DestinationPath "$TOOLS\nirsoft\ChromeCacheView.exe" -Iconlocation "$TOOLS\nirsoft\ChromeCacheView.exe"
# Microsoft Defender is flagging this as malware
#Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\ChromeCookiesView.lnk" -DestinationPath "$TOOLS\nirsoft\ChromeCookiesView.exe" -Iconlocation "$TOOLS\nirsoft\ChromeCookiesView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\IECacheView.lnk" -DestinationPath "$TOOLS\nirsoft\IECacheView.exe" -Iconlocation "$TOOLS\nirsoft\IECacheView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\LastActivityView.lnk" -DestinationPath "$TOOLS\nirsoft\LastActivityView.exe" -Iconlocation "$TOOLS\nirsoft\LastActivityView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\MZCacheView.lnk" -DestinationPath "$TOOLS\nirsoft\MZCacheView.exe" -Iconlocation "$TOOLS\nirsoft\MZCacheView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Browser\mzcv.lnk" -DestinationPath "$TOOLS\nirsoft\mzcv.exe" -Iconlocation "$TOOLS\nirsoft\mzcv.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Database"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\DB Browser for SQLite.lnk" -DestinationPath "$TOOLS\DB Browser for SQLite\DB Browser for SQLite.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\ese2csv.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\fqlite.lnk" -DestinationPath "$TOOLS\fqlite\run.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\SQLECmd.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\Zimmerman\SQLECmd\SQLECmd.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\sqlite3.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\sqlite\sqlite3.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Database\SQLiteWalker.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Disk"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Disk\INDXRipper.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\INDXRipper\INDXRipper.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Disk\MFTBrowser.lnk" -DestinationPath "$TOOLS\bin\MFTBrowser.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Disk\ntfs_parser.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Disk\parseUSBs.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Disk\sleuthkit.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\JavaScript"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\JavaScript\deobfuscator.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\JavaScript\js-beautify.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\JavaScript\jsdom.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Log"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\chainsaw.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\Events-Ripper.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\evtx_dump.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\FullEventLogView.lnk" -DestinationPath "$TOOLS\FullEventLogView\FullEventLogView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\hayabusa.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\Microsoft LogParser (LogParser).lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Log\PowerSiem.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Office and email"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\email-analyzer.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$GIT\EmailAnalyzer"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\extract_msg.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\Mail Viewer.lnk" -DestinationPath "$TOOLS\MailView\MailView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\Mbox Viewer.lnk" -DestinationPath "$TOOLS\mboxviewer\mboxview64.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\MetadataPlus.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\bin\MetadataPlus.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\mraptor.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\msgviewer.lnk" -DestinationPath "$TOOLS\lib\msgviewer.jar"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\msodde.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\msoffcrypto-crack.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\msoffcrypto-tool.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\oledump.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\oleid.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\olevba.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\pstwalker.lnk" -DestinationPath "$TOOLS\pstwalker\pstwalker.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\pcode2code.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\pcodedmp.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\rtfdump.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\rtfobj.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\Structured Storage Viewer (SSView).lnk" -DestinationPath "$TOOLS\ssview\SSView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\tree.com.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Office and email\zipdump.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\PDF"
if ($WSDFIR_PDFSTREAM -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\pdfstreamdumper.lnk" -DestinationPath "$PDFSTREAMDUMPER\PDFStreamDumper.exe"
}
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\pdf-parser.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\pdfid.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PDF\qpdf.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\PE"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\4n4lDetector.lnk" -DestinationPath "$env:ProgramFiles\4n4lDetector\4N4LDetector.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\capa.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation $TOOLS\capa\capa.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\Debloat.lnk" -DestinationPath "$TOOLS\bin\debloat.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\dll_to_exe.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\ExeinfoPE.lnk" -DestinationPath "$TOOLS\ExeinfoPE\exeinfope.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\hachoir-tools.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\hollows_hunter.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation $TOOLS\bin\hollows_hunter.exe
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\pe2pic.bat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
#Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\pe2shc.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation $TOOLS\bin\pe2shc.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\PE-bear.lnk" -DestinationPath "$TOOLS\pebear\PE-bear.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\PE-sieve.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation $TOOLS\bin\pe-sieve.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\pestudio.lnk" -DestinationPath "$TOOLS\pestudio\pestudio.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\pescan.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$TOOLS\pev"
#Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\Resource Hacker.lnk" -DestinationPath "$TOOLS\resource_hacker\ResourceHacker.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\shellconv.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\PE\WinObjEx64.lnk" -DestinationPath "$TOOLS\WinObjEx64\WinObjEx64.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\Phone"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Phone\aleapp.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Phone\aleappGUI.lnk" -DestinationPath "$TOOLS\bin\aleappGUI.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Phone\ileapp.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\Phone\iLEAPPGUI.lnk" -DestinationPath "$TOOLS\bin\iLEAPPGUI.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Files and apps\RDP"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\RDP\bmc-tools.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Files and apps\RDP\RdpCacheStitcher.lnk" -DestinationPath "$TOOLS\RdpCacheStitcher\RdpCacheStitcher.exe"

# Incident response
New-Item -ItemType Directory "$HOME\Desktop\dfirws\IR"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\IR\Trawler.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# Malware tools
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Malware tools"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\maldump.exe (run maldump.ps1 first).lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\1768.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\BeaconHunter.lnk" -DestinationPath "$env:ProgramFiles\bin\BeaconHunter.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\CobaltStrikeScan.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# Memory
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Memory"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Memory\Volatility Workbench 2.1.lnk" -DestinationPath "$TOOLS\VolatilityWorkbench2\VolatilityWorkbench.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Memory\Volatility Workbench 3.lnk" -DestinationPath "$TOOLS\VolatilityWorkbench\VolatilityWorkbench.exe"

# Network
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Network"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Network\Fakenet.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\fakenet\fakenet.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Network\ipexpand.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Network\scapy.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# OS
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\Android"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Android\apktool.bat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\Linux"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Linux\elfparser-ng.lnk" -DestinationPath "$TOOLS\elfparser-ng\Release\elfparser-ng.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Linux\xelfviewer.lnk" -DestinationPath "$TOOLS\XELFViewer\xelfviewer.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\macOS"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\macOS\dsstore.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$GIT\Python-dsstore"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\macOS\machofile-cli.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\Windows"
if ($WSDFIR_APIMONITOR -eq "Yes") {
    Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\apimonitor-x86.lnk" -DestinationPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor\apimonitor-x86.exe"
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\apimonitor-x64.lnk" -DestinationPath "${env:ProgramFiles(x86)}\rohitab.com\API Monitor\apimonitor-x64.exe"
}
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Jumplist-Browser.lnk" -DestinationPath "$TOOLS\bin\JumplistBrowser.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Prefetch-Browser.lnk" -DestinationPath "$TOOLS\bin\PrefetchBrowser.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\procdot.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\sidr.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Thumbcache Viewer.lnk" -DestinationPath "$TOOLS\thumbcacheviewer\thumbcache_viewer.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\OS\Windows\Registry"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Registry\Registry Explorer.lnk" -DestinationPath "$TOOLS\Zimmerman\RegistryExplorer\RegistryExplorer.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Registry\RegRipper (rip).lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Registry\RegShot.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# Programming
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\java.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\node.lnk" -DestinationPath "$TOOLS\node\node.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\perl.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\php.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Python.lnk" -DestinationPath "$VENV\default\Scripts\python.exe"
new-item -ItemType Directory "$HOME\Desktop\dfirws\Programming\dotNET"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\dotNET\dotnetfile_dump.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming\Delphi"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Delphi\idr.lnk" -DestinationPath "$env:ProgramFiles\idr\bin\Idr.exe"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming\Go"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Go\gftrace.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Go\GoReSym.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming\Java"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\jadx-gui.lnk" -DestinationPath "$env:ProgramFiles\jadx\bin\jadx-gui.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\jd-gui.lnk" -DestinationPath "$TOOLS\jd-gui\jd-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\recaf.lnk" -DestinationPath "$TOOLS\bin\recaf.bat"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Programming\PowerShell"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\PowerShell\PowerDecode.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$GIT\PowerDecode"
New-item -ItemType Directory "$HOME\Desktop\dfirws\Programming\Python"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Python\pydisasm.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# Reverse Engineering
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Reverse Engineering"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\Cutter.lnk" -DestinationPath "$TOOLS\cutter\cutter.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\dnSpy32.lnk" -DestinationPath "$TOOLS\dnSpy32\dnSpy.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\dnSpy64.lnk" -DestinationPath "$TOOLS\dnSpy64\dnSpy.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\fasm.lnk" -DestinationPath "$TOOLS\fasm\FASM.EXE"
(Get-ChildItem C:\Tools\Ghidra\).Name | ForEach-Object {
    $VERSION = $_
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\${VERSION}.lnk" -DestinationPath "$TOOLS\ghidra\${VERSION}\ghidraRun.bat"
}
if (Test-Path "$VENV\jep") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\Ghidrathon.lnk" -DestinationPath "$HOME\Documents\tools\utils\ghidrathon.bat"
}
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\iaito.lnk" -DestinationPath "$TOOLS\iaito\iaito.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\radare2.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\scare.bat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
if ($WSDFIR_X64DBG -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\x32dbg.lnk" -DestinationPath "$env:ProgramFiles\x64dbg\release\x32\x32dbg.exe"
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\x64dbg.lnk" -DestinationPath "$env:ProgramFiles\x64dbg\release\x64\x64dbg.exe"
}

# Signatures and information
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Signatures and information"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Signatures and information\Online tools"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\Online tools\vt.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\evt2sigma.bat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\mkyara.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\loki.lnk" -DestinationPath "$env:ProgramFiles\loki\loki.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\PatchaPalooza.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$GIT\PatchaPalooza"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\WinApiSearch64.lnk" -DestinationPath "$TOOLS\WinApiSearch\WinApiSearch64.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\yara.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# "$HOME\Desktop\dfirws\Sysinternals"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Sysinternals.lnk" -DestinationPath "$TOOLS\sysinternals"

# Utilities
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Utilities"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Utilities\_dfirws"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\_dfirws\dfirws-install.ps1.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\7-Zip.lnk" -DestinationPath "$env:ProgramFiles\7-Zip\7zFM.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\bash.lnk" -DestinationPath "$env:ProgramFiles\Git\bin\bash.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\cmder.lnk" -DestinationPath "$env:ProgramFiles\cmder\cmder.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\exiftool.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\exiftool\exiftool.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\floss.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$TOOLS\floss\floss.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\git.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop" -Iconlocation "$env:ProgramFiles\Git\cmd\git-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\Graphviz.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\pygmentize.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\time-decode.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\upx.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\visidata.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\zstd.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
New-Item -ItemType Directory "$HOME\Desktop\dfirws\Utilities\Crypto"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\Crypto\ares.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\Crypto\chepy.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\Crypto\CyberChef.lnk" -DestinationPath "$TOOLS\CyberChef\CyberChef.html"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\Crypto\hash-id.py.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\Crypto\hashcat.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$env:ProgramFiles\hashcat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\Crypto\name-that-hash.lnk" -DestinationPath "$POWERSHELL_EXE" -WorkingDirectory "$HOME\Desktop"

# "$HOME\Desktop\dfirws\Zimmerman"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Zimmerman.lnk" -DestinationPath "$TOOLS\Zimmerman"
Write-DateLog "Creating shortcuts in $HOME\Desktop\dfirws done." >> $TEMP\start_sandbox.log

# Pin to explorer
$shell = new-object -com "Shell.Application"
$folder = $shell.Namespace("$HOME\Desktop")
$item = $folder.Parsename('dfirws')
$verb = $item.Verbs() | Where-Object { $_.Name -eq 'Pin to Quick access' }
if ($verb) {
    $verb.DoIt()
}
Write-DateLog "Pinning $HOME\Desktop\dfirws to explorer done." >> $TEMP\start_sandbox.log

& "$POWERSHELL_EXE" -Command "Set-ExecutionPolicy Bypass"
Write-DateLog "Setting execution policy to Bypass done." >> $TEMP\start_sandbox.log

& "$SETUP_PATH\graphviz.exe" /S /D='$env:ProgramFiles\graphviz'
Write-DateLog "Installing Graphviz done." >> $TEMP\start_sandbox.log

# Add plugins to Cutter
New-Item -ItemType Directory -Force -Path "$HOME\AppData\Roaming\rizin\cutter\plugins\python" | Out-Null
Copy-Item $GIT\radare2-deep-graph\cutter\graphs_plugin_grid.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item $SETUP_PATH\x64dbgcutter.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item $GIT\cutterref\cutterref.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse $GIT\cutterref\archs "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse $GIT\cutter-jupyter\icons "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse $GIT\capa-explorer\capa_explorer_plugin "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Write-DateLog "Installing Cutter plugins done." >> $TEMP\start_sandbox.log

# Unzip yara signatures
& "$env:ProgramFiles\7-Zip\7z.exe" x "$SETUP_PATH\yara-forge-rules-core.zip" -o"$DATA"
& "$env:ProgramFiles\7-Zip\7z.exe" x "$SETUP_PATH\yara-forge-rules-extended.zip" -o"$DATA"
& "$env:ProgramFiles\7-Zip\7z.exe" x "$SETUP_PATH\yara-forge-rules-full.zip" -o"$DATA"
Copy-Item "$DATA\packages\full\yara-rules-full.yar" "$DATA\total.yara"
Write-DateLog "Unzipping signatures for yara done." >> $TEMP\start_sandbox.log

# Start sysmon when installation is done
if ($WSDFIR_SYSMON -eq "Yes") {
    & "$TOOLS\sysinternals\Sysmon64.exe" -accepteula -i "$WSDFIR_SYSMON_CONF"
}
Write-DateLog "Starting sysmon done." >> $TEMP\start_sandbox.log

# Start Gollum for local wiki
netsh firewall set opmode DISABLE 2>&1 | Out-Null
Start-Process "$env:ProgramFiles\Amazon Corretto\jdk*\bin\java.exe" -argumentlist "-jar $TOOLS\lib\gollum.war -S gollum --lenient-tag-lookup $GIT\dfirws.wiki" -WindowStyle Hidden
Write-DateLog "Starting Gollum for local wiki done." >> $TEMP\start_sandbox.log

# Don't ask about new apps
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t REG_DWORD /d 1

# Install hashcat
if ($WSDFIR_HASHCAT -eq "Yes") {
    Install-Hashcat
    Write-DateLog "Installing hashcat done." >> $TEMP\start_sandbox.log
}

# Add shortcuts to desktop for Jupyter and Gollum
Add-Shortcut -SourceLnk "$HOME\Desktop\jupyter.lnk" -DestinationPath "$HOME\Documents\tools\utils\jupyter.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws wiki.lnk" -DestinationPath "$HOME\Documents\tools\utils\gollum.bat"

New-Item -Path "$HOME/ghidra_scripts" -ItemType Directory -Force | Out-Null
if (Test-Path "$SETUP_PATH\capa_ghidra.py") {
    Copy-Item "$SETUP_PATH\capa_ghidra.py" "$HOME/ghidra_scripts/capa_ghidra.py"
}

# Run custom scripts
if (Test-Path "$LOCAL_PATH\customize.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "$LOCAL_PATH\customize.ps1"
    Write-DateLog "Running customize scripts done." >> $TEMP\start_sandbox.log
}

if (Test-Path "$LOCAL_PATH\customise.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "$LOCAL_PATH\customise.ps1"
    Write-DateLog "Running customise scripts done." >> $TEMP\start_sandbox.log
}
Write-DateLog "Installation done." >> $TEMP\start_sandbox.log
