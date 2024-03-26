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
foreach ($dir in @("${WSDFIR_TEMP}", "${env:ProgramFiles}\bin", "${HOME}\Documents\WindowsPowerShell", "${HOME}\Documents\PowerShell", "${env:ProgramFiles}\PowerShell\Modules\PSDecode", "${env:ProgramFiles}\dfirws", "${HOME}\Documents\jupyter")) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

Write-DateLog "Start sandbox setup" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log"

# Set the execution policy to Bypass for default PowerShell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Copy config files and import them
if (-not (Test-Path "${WSDFIR_TEMP}\config.ps1")) {
    if (Test-Path "${LOCAL_PATH}\config.txt") {
        Copy-Item "${LOCAL_PATH}\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force
    } else {
        Copy-Item "${LOCAL_PATH}\defaults\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force
    }
}

. "${WSDFIR_TEMP}\config.ps1"
Write-DateLog "Config files copied and imported" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# PowerShell
if (Test-Path "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1") {
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
} else {
    Copy-Item "${LOCAL_PATH}\defaults\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force
    Copy-Item "${LOCAL_PATH}\defaults\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
}

Copy-Item "${HOME}\Documents\tools\utils\PSDecode.psm1" "${env:ProgramFiles}\PowerShell\Modules\PSDecode" -Force

# Install latest PowerShell and set execution policy to Bypass
Copy-Item   "${SETUP_PATH}\powershell.msi" "${WSDFIR_TEMP}\powershell.msi" -Force
Start-Process -Wait msiexec -ArgumentList "/i ${WSDFIR_TEMP}\powershell.msi /qn /norestart"
Write-DateLog "PowerShell installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
& "${POWERSHELL_EXE}" -Command "Set-ExecutionPolicy Bypass"
Write-DateLog "Setting execution policy to Bypass for pwsh done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Shortcut for PowerShell or Tabby
if ("$WSDFIR_TABBY" -eq "Yes") {
    Add-Shortcut -SourceLnk "${HOME}\Desktop\Tabby.lnk" -DestinationPath "${TOOLS}\tabby\Tabby.exe" -WorkingDirectory "${HOME}\Desktop" -IconPath "${TOOLS}\tabby\Tabby.exe"
} else {
    Add-Shortcut -SourceLnk "${HOME}\Desktop\PowerShell.lnk" -DestinationPath "${env:ProgramFiles}\PowerShell\7\pwsh.exe" -WorkingDirectory "${HOME}\Desktop"
}

# Copy config for Tabby
if (!(Test-Path "${HOME}\AppData\Roaming\tabby")) {
    New-Item -Path "${HOME}\AppData\Roaming\tabby" -ItemType Directory -Force | Out-Null
    if (Test-Path "${LOCAL_PATH}\tabby\config.yaml") {
        Copy-Item "${LOCAL_PATH}\tabby\config.yaml" "${HOME}\AppData\Roaming\tabby\config.yaml" -Force
    } else {
        Copy-Item "${LOCAL_PATH}\defaults\tabby\config.yaml" "${HOME}\AppData\Roaming\tabby\config.yaml" -Force
    }
}

# Configure PowerShell logging
New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -Force | Out-Null

# Install OhMyPosh
if ("${WSDFIR_OHMYPOSH}" -eq "Yes") {
    Install-OhMyPosh | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Add PersistenceSniper
Import-Module ${GIT_PATH}\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1

#
# Install base tools
#

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

#
# Configure the sandbox
#

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
    if (Test-Path "${LOCAL_PATH}\notepad++_dark.xml") {
        Copy-Item "${LOCAL_PATH}\notepad++_dark.xml" "${env:USERPROFILE}\AppData\Roaming\Notepad++\config.xml" -Force
    } else {
        Copy-Item "${LOCAL_PATH}\defaults\notepad++_dark.xml" "${env:USERPROFILE}\AppData\Roaming\Notepad++\config.xml" -Force
    }
    Write-DateLog "Dark mode set" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Show file extensions
Write-DateLog "Show file extensions" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f | Out-Null
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt /v DefaultValue /t REG_DWORD /d 0 /f | Out-Null
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL /v DefaultValue /t REG_DWORD /d 1 /f | Out-Null
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f | Out-Null
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0 /f | Out-Null
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f | Out-Null
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 1 /f | Out-Null
Write-DateLog "File extensions shown" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Add right-click context menu if specified
if ("${WSDFIR_RIGHTCLICK}" -eq "Yes") {
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve | Out-Null
    Write-DateLog "Right-click context menu added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Import registry settings
reg import "${HOME}\Documents\tools\registry.reg" | Out-Null
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

# Set dark theme if selected
if ("${WSDFIR_DARK}" -eq "Yes") {
    Start-Process -Wait "c:\Windows\Resources\Themes\themeB.theme"
    taskkill /f /im systemsettings.exe
}

Update-Wallpaper "${SETUP_PATH}\dfirws.jpg"
Write-DateLog "Wallpaper updated" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Set Notepad++ as default for many file types
# Use %VARIABLE% in cmd.exe
cmd /c "Ftype xmlfile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
cmd /c "Ftype chmfile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
cmd /c "Ftype cmdfile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
cmd /c "Ftype htafile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
cmd /c "Ftype jsefile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
cmd /c "Ftype jsfile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
cmd /c "Ftype txtfile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
cmd /c "Ftype vbefile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
cmd /c "Ftype vbsfile=""${env:ProgramFiles}\Notepad++\notepad++.exe"" ""%1"""
Write-DateLog "Notepad++ set as default for many file types" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Disable firewall to enable local web services
netsh firewall set opmode DISABLE 2>&1 | Out-Null

# Don't ask about new apps
REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t REG_DWORD /d 1 | Out-Null

# Hide the taskbar
if ("${WSDFIR_HIDE_TASKBAR}" -eq "Yes") {
    # From https://www.itechtics.com/hide-show-taskbar/#from-windows-powershell
    &{$p='HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3';$v=(Get-ItemProperty -Path $p).Settings;$v[8]=3;&Set-ItemProperty -Path $p -Name Settings -Value $v;&Stop-Process -f -ProcessName explorer}
}

# Windows 10 Loopback
if ("${WSDFIR_W10_LOOPBACK}" -eq "Yes") {
    Install-W10Loopback | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Restart Explorer process
Stop-Process -ProcessName "Explorer" -Force
Write-DateLog "Explorer restarted" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

#
# Configure PATH
#

Write-DateLog "Add to PATH" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

Add-ToUserPath "${TOOLS}\perl\perl\bin"
Add-ToUserPath "${env:ProgramFiles}\4n4lDetector"
Add-ToUserPath "${env:ProgramFiles}\7-Zip"
Add-ToUserPath "${env:ProgramFiles}\bin"
Add-ToUserPath "${env:ProgramFiles}\ClamAV"
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
Add-ToUserPath "${TOOLS}\ripgrep"
Add-ToUserPath "${TOOLS}\scdbg"
Add-ToUserPath "${TOOLS}\sleuthkit\bin"
Add-ToUserPath "${TOOLS}\sqlite"
Add-ToUserPath "${TOOLS}\ssview"
Add-ToUserPath "${TOOLS}\systeminformer\x64"
Add-ToUserPath "${TOOLS}\systeminformer\x86"
Add-ToUserPath "${TOOLS}\sysinternals"
Add-ToUserPath "${TOOLS}\tabby"
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
Add-ToUserPath "${VENV}\ingestr\Scripts"
Add-ToUserPath "${VENV}\jpterm\Scripts"
Add-ToUserPath "${VENV}\magika\Scripts"
Add-ToUserPath "${VENV}\maldump\Scripts"
Add-ToUserPath "${VENV}\peepdf3\Scripts"
Add-ToUserPath "${VENV}\regipy\Scripts"
Add-ToUserPath "${VENV}\sigma-cli\Scripts"
Add-ToUserPath "${VENV}\toolong\Scripts"
Add-ToUserPath "${HOME}\AppData\Local\Programs\oh-my-posh\bin"
Add-ToUserPath "${HOME}\Documents\tools\utils"

$GHIDRA_INSTALL_DIR=((Get-ChildItem "${TOOLS}\ghidra\").Name | findstr "PUBLIC" | Select-Object -Last 1)
Add-ToUserPath "${TOOLS}\ghidra\${GHIDRA_INSTALL_DIR}"
Write-DateLog "Added to PATH" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

& "${HOME}\Documents\tools\dfirws_folder.ps1"

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

# Install extra tools for Git-bash
if ("${WSDFIR_BASH_EXTRA}" -eq "Yes") {
    Install-BashExtra | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Extra tools for Git-bash installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
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
    Install-Malcat | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
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
    Install-GitBash | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
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
    Copy-Item "${SETUP_PATH}\capa_explorer.py" "${HOME}/ghidra_scripts/capa_explorer.py" -Force
}if (Test-Path "${SETUP_PATH}\capa_ghidra.py") {
    Copy-Item "${SETUP_PATH}\capa_ghidra.py" "${HOME}/ghidra_scripts/capa_ghidra.py" -Force
}

# Add plugins to Cutter
New-Item -ItemType Directory -Force -Path "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" | Out-Null
Copy-Item "${GIT_PATH}\radare2-deep-graph\cutter\graphs_plugin_grid.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item "${SETUP_PATH}\x64dbgcutter.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item "${GIT_PATH}\cutterref\cutterref.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item -Recurse "${GIT_PATH}\cutterref\archs" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item -Recurse "${GIT_PATH}\cutter-jupyter\icons" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force
Copy-Item -Recurse "${GIT_PATH}\capa-explorer\capa_explorer_plugin" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python"
Write-DateLog "Installed Cutter plugins." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append


#
# Copy and extract files that need be in writeable locations
#

# BeaconHunter
Copy-Item -Force "${SETUP_PATH}\BeaconHunter.exe" "${env:ProgramFiles}\bin"

# IDR
Copy-Item -Recurse -Force "${GIT_PATH}\IDR" "${env:ProgramFiles}"

# Jupyter
Copy-Item "${HOME}\Documents\tools\jupyter\.jupyter" "${HOME}\" -Recurse -Force
Copy-Item "${HOME}\Documents\tools\jupyter\common.py" "${HOME}\Documents\jupyter\" -Force
Copy-Item "${HOME}\Documents\tools\jupyter\*.ipynb" "${HOME}\Documents\jupyter\" -Force

# Zimmerman tools
Copy-Item -Recurse "${TOOLS}\Zimmerman\Hasher" "${env:ProgramFiles}\" -Force
if (Test-Path "${LOCAL_PATH}\Hasher.ini") {
    Copy-Item "${LOCAL_PATH}\Hasher.ini" "${env:ProgramFiles}\Hasher\Hasher.ini" -Force
} else {
    Copy-Item "${LOCAL_PATH}\defaults\Hasher.ini" "${env:ProgramFiles}\Hasher\Hasher.ini" -Force
}

Copy-Item -Recurse "${TOOLS}\Zimmerman\iisGeolocate" "${env:ProgramFiles}\" -Force
if (Test-Path "C:\enrichment\maxmind_current\GeoLite2-City.mmdb") {
    Copy-Item "C:\enrichment\maxmind_current\GeoLite2-City.mmdb" "${env:ProgramFiles}\iisGeolocate\" -Force
}
Copy-Item -Recurse "${TOOLS}\Zimmerman\RegistryExplorer" "${env:ProgramFiles}\" -Force
Copy-Item -Recurse "${TOOLS}\Zimmerman\ShellBagsExplorer" "${env:ProgramFiles}\" -Force
Copy-Item -Recurse "${TOOLS}\Zimmerman\TimelineExplorer" "${env:ProgramFiles}\" -Force

# AuthLogParser
Copy-Item -Recurse "${GIT_PATH}\AuthLogParser" "${env:ProgramFiles}\" -Force

# 4n4lDetector
& "${env:ProgramFiles}\7-Zip\7z.exe" x "${SETUP_PATH}\4n4lDetector.zip" -o"${env:ProgramFiles}\4n4lDetector" | Out-Null


#
# Add shortcuts to desktop for Jupyter and Gollum
#

Add-Shortcut -SourceLnk "${HOME}\Desktop\jupyter.lnk" -DestinationPath "${HOME}\Documents\tools\utils\jupyter.bat"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws wiki.lnk" -DestinationPath "${HOME}\Documents\tools\utils\gollum.bat"

# Copy shortcuts to Start menu
if ("${WSDFIR_START_MENU}" -eq "Yes") {
    ${sourceDir} = "${HOME}\Desktop\dfirws"
    ${DestinationDir} = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"

    if (-not (Test-Path -Path ${DestinationDir})) {
        New-Item -ItemType Directory -Path ${DestinationDir}
    }

    # Find all files in the source directory, including subdirectories
    $files = Get-ChildItem -Path ${sourceDir} -Recurse -File

    foreach ($file in $files) {
        $newFolderName = "dfirws - " + $file.DirectoryName.Replace($sourceDir, '').TrimStart('\').Replace('\', ' - ').Replace('\', ' - ').Replace('\', ' - ')
        $newFolderPath = Join-Path -Path $DestinationDir -ChildPath $newFolderName

        # Ensure the new folder exists
        if (-not (Test-Path -Path $newFolderPath)) {
            New-Item -ItemType Directory -Path $newFolderPath
        }

        # Define the new file path within the new folder structure
        $newFilePath = Join-Path -Path $newFolderPath -ChildPath $file.Name

        # Copy the file to the new location
        Copy-Item -Path $file.FullName -Destination $newFilePath
    }

    Write-DateLog "Files have been copied to the destination directory: ${DestinationDir}"
}


#
# Run custom scripts
#

if (Test-Path "${LOCAL_PATH}\customize.ps1") {
    Write-DateLog "Running customize script." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\customize.ps1" @args | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
} else {
    Write-DateLog "No customize scripts found, running defaults\customize-sandbox.ps1." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\defaults\customize-sandbox.ps1" @args | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

if (Test-Path "${LOCAL_PATH}\customise.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\customise.ps1" @args | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
    Write-DateLog "Running customise scripts done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}


#
# Start sysmon when installation is done
#

if ("${WSDFIR_SYSMON}" -eq "Yes") {
    & "${TOOLS}\sysinternals\Sysmon64.exe" -accepteula -i "${WSDFIR_SYSMON_CONF}" | Out-Null
}
Write-DateLog "Starting sysmon done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

Write-DateLog "Installation done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

Exit 0