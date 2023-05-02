# DFIRWS

$WIN10=(Get-ComputerInfo | Select-Object -expand OsName) -match 10
#$WIN11=(Get-ComputerInfo | Select-Object -expand OsName) -match 11

# Start logging
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$TEMP = "C:\tmp"
mkdir "$TEMP"
Start-Transcript -Append "$TEMP\dfirws_log.txt"

# Import common functions
. C:\Users\WDAGUtilityAccount\Documents\tools\common.ps1

Write-DateLog "start_sandbox.ps1"

# Bypass the execution policy for the current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Set variables
$SETUP_PATH = "C:\downloads"
$TOOLS = "C:\Tools"

# Create required directories
mkdir "C:\data"
mkdir "$env:ProgramFiles\bin"
mkdir "$HOME\Documents\WindowsPowerShell"

# Copy config files and import them
Copy-Item "$HOME\Documents\tools\config.txt" $TEMP\config.ps1
Copy-Item "$HOME\Documents\tools\default-config.txt" $TEMP\default-config.ps1
. $TEMP\default-config.ps1
. $TEMP\config.ps1

# Install msi packages and other tools
Copy-Item "$SETUP_PATH\7zip.msi" "$TEMP\7zip.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\7zip.msi /qn /norestart"

if ($WSDFIR_JAVA -eq "Yes") {
    Copy-Item "$SETUP_PATH\corretto.msi" "$TEMP\corretto.msi"
    Start-Process -Wait msiexec -ArgumentList "/i $TEMP\corretto.msi /qn /norestart"
}

if ($WSDFIR_JAVA_JDK11 -eq "Yes") {
    Copy-Item "$SETUP_PATH\microsoft-jdk-11.msi" "$TEMP\microsoft-jdk-11.msi"
    Start-Process -Wait msiexec -ArgumentList "/i $TEMP\microsoft-jdk-11.msi ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome INSTALLDIR=C:\java /qn /norestart"
}

if (($WSDFIR_JAVA_JDK11 -eq "Yes") -and ($WSDFIR_NEO4J -eq "Yes")) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\neo4j.zip" -o"$env:ProgramFiles"
    Move-Item $env:ProgramFiles\neo4j-community* $env:ProgramFiles\neo4j
    Add-ToUserPath "$env:ProgramFiles\neo4j\bin"
    & "$env:ProgramFiles\neo4j\bin\neo4j-admin" set-initial-password neo4j
    Copy-Item -Recurse "$TOOLS\neo4j" "$env:ProgramFiles"
}

if ($WSDFIR_LIBREOFFICE -eq "Yes") {
    # Install LibreOffice with custom arguments
    Copy-Item "$SETUP_PATH\LibreOffice.msi" "$TEMP\LibreOffice.msi"
    Start-Process -Wait msiexec -ArgumentList "/qb /i $TEMP\LibreOffice.msi /l* $TEMP\LibreOffice_install_log.txt REGISTER_ALL_MSO_TYPES=1 UI_LANGS=en_US ISCHECKFORPRODUCTUPDATES=0 REBOOTYESNO=No QUICKSTART=0 ADDLOCAL=ALL VC_REDIST=0 REMOVE=gm_o_Onlineupdate,gm_r_ex_Dictionary_Af,gm_r_ex_Dictionary_An,gm_r_ex_Dictionary_Ar,gm_r_ex_Dictionary_Be,gm_r_ex_Dictionary_Bg,gm_r_ex_Dictionary_Bn,gm_r_ex_Dictionary_Bo,gm_r_ex_Dictionary_Br,gm_r_ex_Dictionary_Pt_Br,gm_r_ex_Dictionary_Bs,gm_r_ex_Dictionary_Pt_Pt,gm_r_ex_Dictionary_Ca,gm_r_ex_Dictionary_Cs,gm_r_ex_Dictionary_Da,gm_r_ex_Dictionary_Nl,gm_r_ex_Dictionary_Et,gm_r_ex_Dictionary_Gd,gm_r_ex_Dictionary_Gl,gm_r_ex_Dictionary_Gu,gm_r_ex_Dictionary_He,gm_r_ex_Dictionary_Hi,gm_r_ex_Dictionary_Hu,gm_r_ex_Dictionary_Lt,gm_r_ex_Dictionary_Lv,gm_r_ex_Dictionary_Ne,gm_r_ex_Dictionary_No,gm_r_ex_Dictionary_Oc,gm_r_ex_Dictionary_Pl,gm_r_ex_Dictionary_Ro,gm_r_ex_Dictionary_Ru,gm_r_ex_Dictionary_Si,gm_r_ex_Dictionary_Sk,gm_r_ex_Dictionary_Sl,gm_r_ex_Dictionary_El,gm_r_ex_Dictionary_Es,gm_r_ex_Dictionary_Te,gm_r_ex_Dictionary_Th,gm_r_ex_Dictionary_Tr,gm_r_ex_Dictionary_Uk,gm_r_ex_Dictionary_Vi,gm_r_ex_Dictionary_Zu,gm_r_ex_Dictionary_Sq,gm_r_ex_Dictionary_Hr,gm_r_ex_Dictionary_De,gm_r_ex_Dictionary_Id,gm_r_ex_Dictionary_Is,gm_r_ex_Dictionary_Ko,gm_r_ex_Dictionary_Lo,gm_r_ex_Dictionary_Mn,gm_r_ex_Dictionary_Sr,gm_r_ex_Dictionary_Eo,gm_r_ex_Dictionary_It,gm_r_ex_Dictionary_Fr"
}

# Install Python
& "$SETUP_PATH\python3.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

# Install Visual C++ Redistributable 16 and 17
Start-Process -Wait "$SETUP_PATH\vcredist_16_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -Wait "$SETUP_PATH\vcredist_17_x64.exe" -ArgumentList "/passive /norestart"

# Install HxD if specified
if ($WSDFIR_HXD -eq "Yes") {
    Copy-Item "$TOOLS\hxd\HxDSetup.exe" "$TEMP\HxDSetup.exe"
    & "$TEMP\HxDSetup.exe" /VERYSILENT /NORESTART
}

# Install Git if specified
if ($WSDFIR_GIT -eq "Yes") {
    Copy-Item "$SETUP_PATH\git.exe" "$TEMP\git.exe"
    Copy-Item "$HOME\Documents\tools\.bashrc" "$HOME\"
    & "$TEMP\git.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
}

# Install Notepad++ and ComparePlus plugin if specified
if ($WSDFIR_NPP -eq "Yes") {
    Copy-Item "$SETUP_PATH\notepad++.exe" "$TEMP\notepad++.exe"
    & "$TEMP\notepad++.exe" /S
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\comparePlus.zip" -o"$env:ProgramFiles\Notepad++\Plugins\ComparePlus"
}

# Install PDFStreamDumper if specified
if ($WSDFIR_PDFSTREAM -eq "Yes") {
    Copy-Item "$SETUP_PATH\PDFStreamDumper.exe" "$TEMP\PDFStreamDumper.exe"
    & "$TEMP\PDFStreamDumper.exe" /verysilent
}

# Install Visual Studio Code and PowerShell extension if specified
if ($WSDFIR_VSCODE -eq "Yes") {
    Copy-Item "$SETUP_PATH\vscode.exe" "$TEMP\vscode.exe"
    Start-Process -Wait "$TEMP\vscode.exe" -ArgumentList '/verysilent /suppressmsgboxes /MERGETASKS="!runcode,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,addtopath"'
    if ($WSDFIR_VSCODE_POWERSHELL -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "C:\downloads\vscode\vscode-powershell.vsix"' -WindowStyle Hidden
    }
    if ($WSDFIR_VSCODE_PYTHON -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "C:\downloads\vscode\vscode-python.vsix"' -WindowStyle Hidden
    }
    if ($WSDFIR_VSCODE_SPELL -eq "Yes") {
        Start-Process "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code" -ArgumentList '--install-extension "C:\downloads\vscode\vscode-spell-checker.vsix"' -WindowStyle Hidden
    }
}

# Install Zui if specified
if ($WSDFIR_ZUI -eq "Yes") {
    Copy-Item "$SETUP_PATH\zui.exe" "$TEMP\zui.exe"
    & "$TEMP\zui.exe" /S /AllUsers
}

# Set date and time format
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortDate -value "yyyy-MM-dd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sLongDate -value "yyyy-MMMM-dddd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss"

# Dark mode

if ($WSDFIR_DARK -eq "Yes") {
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0
}

# Show file extensions
Write-DateLog "Show file extensions"
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt /v DefaultValue /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL /v DefaultValue /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 1 /f

# Add right-click context menu if specified
if ($WSDFIR_RIGHTCLICK -eq "Yes") {
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
}

# Import registry settings
reg import $HOME\Documents\tools\registry.reg

# Restart Explorer process
Stop-Process -ProcessName Explorer -Force

# Add to PATH
Write-DateLog "Add to PATH"
Add-ToUserPath "$env:ProgramFiles\7-Zip"
Add-ToUserPath "$env:ProgramFiles\bin"
Add-ToUserPath "$env:ProgramFiles\Git\bin"
Add-ToUserPath "$env:ProgramFiles\Git\usr\bin\"
Add-ToUserPath "$env:ProgramFiles\hxd"
Add-ToUserPath "$env:ProgramFiles\Notepad++\"
Add-ToUserPath "C:\git\Events-Ripper\"
Add-ToUserPath "C:\git\RegRipper3.0"
Add-ToUserPath "C:\Tools\bin"
Add-ToUserPath "C:\Tools\bulk_extractor\win64"
Add-ToUserPath "C:\Tools\capa"
Add-ToUserPath "C:\Tools\chainsaw"
Add-ToUserPath "C:\Tools\DidierStevens"
Add-ToUserPath "C:\Tools\die"
Add-ToUserPath "C:\Tools\exiftool"
Add-ToUserPath "C:\Tools\fakenet"
Add-ToUserPath "C:\Tools\floss"
Add-ToUserPath "C:\Tools\FullEventLogView"
Add-ToUserPath "C:\Tools\GoReSym"
Add-ToUserPath "C:\Tools\hayabusa"
Add-ToUserPath "C:\Tools\malcat\bin"
Add-ToUserPath "C:\Tools\nmap"
Add-ToUserPath "C:\Tools\node"
Add-ToUserPath "C:\Tools\systeminformer\x64"
Add-ToUserPath "C:\Tools\systeminformer\x86"
Add-ToUserPath "C:\Tools\pstwalker"
Add-ToUserPath "C:\Tools\qpdf\bin"
Add-ToUserPath "C:\Tools\radare2"
Add-ToUserPath "C:\Tools\ripgrep"
Add-ToUserPath "C:\Tools\scdbg"
Add-ToUserPath "C:\Tools\sqlite"
Add-ToUserPath "C:\Tools\sysinternals"
Add-ToUserPath "C:\Tools\thumbcacheviewer"
Add-ToUserPath "C:\Tools\trid"
Add-ToUserPath "C:\Tools\upx"
Add-ToUserPath "C:\Tools\Zimmerman"
Add-ToUserPath "C:\Tools\Zimmerman\EvtxECmd"
Add-ToUserPath "C:\Tools\Zimmerman\EZViewer"
Add-ToUserPath "C:\Tools\Zimmerman\Hasher"
Add-ToUserPath "C:\Tools\Zimmerman\iisGeolocate"
Add-ToUserPath "C:\Tools\Zimmerman\JumpListExplorer"
Add-ToUserPath "C:\Tools\Zimmerman\MFTExplorer"
Add-ToUserPath "C:\Tools\Zimmerman\RECmd"
Add-ToUserPath "C:\Tools\Zimmerman\RegistryExplorer"
Add-ToUserPath "C:\Tools\Zimmerman\SDBExplorer"
Add-ToUserPath "C:\Tools\Zimmerman\ShellBagsExplorer"
Add-ToUserPath "C:\Tools\Zimmerman\SQLECmd"
Add-ToUserPath "C:\Tools\Zimmerman\TimelineExplorer"
Add-ToUserPath "C:\Tools\Zimmerman\XWFIM"
Add-ToUserPath "C:\Tools\zstd"
if ($WSDFIR_UNIEXTRACT -eq "Yes") {
    Add-ToUserPath "C:\Tools\UniExtract"
}

Write-DateLog "Add shortcuts (shorten link names first)"
#& reg add "HKU\%1\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d 00000000 /f
if ($WSDFIR_BEACONHUNTER -eq "Yes") {
    Copy-Item "$SETUP_PATH\BeaconHunter.exe" "$env:ProgramFiles\bin"
}
if ($WSDFIR_GIT -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\bash.lnk" -DestinationPath "$env:ProgramFiles\Git\bin\bash.exe" -WorkingDirectory "$HOME\Desktop"
}
if ($WSDFIR_CYBERCHEF -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\CyberChef.lnk" -DestinationPath "C:\Tools\CyberChef\CyberChef.html"
}
if ($WSDFIR_CMDER -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\cmder.lnk" -DestinationPath "$env:ProgramFiles\cmder\cmder.exe" -WorkingDirectory "$HOME\Desktop"
}
if ($WSDFIR_CUTTER -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\Cutter.lnk" -DestinationPath "C:\Tools\cutter\cutter.exe"
}
if ($WSDFIR_DNSPY32 -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dnSpy32.lnk" -DestinationPath "C:\Tools\dnSpy32\dnSpy.exe"
}
if ($WSDFIR_DNSPY64 -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dnSpy64.lnk" -DestinationPath "C:\Tools\dnSpy64\dnSpy.exe"
}
if ($WSDFIR_FLV -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\FullEventLogView.lnk" -DestinationPath "C:\Tools\FullEventLogView\FullEventLogView.exe"
}
if (($WSDFIR_JAVA -eq "Yes") -and ($WSDFIR_GHIDRA -eq "Yes")) {
    Add-Shortcut -SourceLnk "$HOME\Desktop\ghidraRun.lnk" -DestinationPath "C:\Tools\ghidra\ghidraRun.bat"
}
if ($WSDFIR_HXD -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\HxD.lnk" -DestinationPath "$env:ProgramFiles\HxD\HxD.exe"
}
if (($WSDFIR_JAVA -eq "Yes") -and ($WSDFIR_MSGVIEWER)) {
    Add-Shortcut -SourceLnk "$HOME\Desktop\msgviewer.lnk" -DestinationPath "C:\Tools\lib\msgviewer.jar"
}
if ($WSDFIR_MALCAT -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\Malcat.lnk" -DestinationPath "C:\Tools\Malcat\bin\malcat.exe"
}
if ($WSDFIR_SYSTEMINFORMER64 -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\System_Informer_x64.lnk" -DestinationPath "C:\Tools\systeminformer\x64\ProcessHacker.exe"
}
if ($WSDFIR_SYSTEMINFORMER86 -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\System_Informer_x86.lnk" -DestinationPath "C:\Tools\systeminformer\x86\ProcessHacker.exe"
}
if ($WSDFIR_NPP -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\Notepad++.lnk" -DestinationPath "$env:ProgramFiles\Notepad++\notepad++.exe"
}
if ($WSDFIR_PEBEAR -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\PE-bear.lnk" -DestinationPath "C:\Tools\pebear\PE-bear.exe"
}
if ($WSDFIR_PESTUDIO -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\pestudio.lnk" -DestinationPath "C:\Tools\pestudio\pestudio\pestudio.exe"
}
Copy-Item "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk" "$HOME\Desktop\PowerShell.lnk"
if ($WSDFIR_TOOLS -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\Tools.lnk" -DestinationPath "C:\Tools"
}
if ($WSDFIR_X64DBG -eq "Yes") {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\x64dbg.zip" -o"$env:ProgramFiles\x64dbg"
    Add-ToUserPath "$env:ProgramFiles\x64dbg\release\x32"
    Add-ToUserPath "$env:ProgramFiles\x64dbg\release\x64"
    Add-Shortcut -SourceLnk "$HOME\Desktop\x64dbg.lnk" -DestinationPath "$env:ProgramFiles\x64dbg\release\x64\x64dbg.exe"
}

# PowerShell
Copy-Item "$HOME\Documents\tools\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType Directory $PSHome\Modules\PSDecode
Copy-Item "$HOME\Documents\tools\utils\PSDecode.psm1" "$PSHome\Modules\PSDecode"

New-Item -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Name EnableScriptBlockLogging -Value 1 -Force

# Add cmder
if ($WSDFIR_CMDER -eq "Yes") {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\cmder.7z" -o"$env:ProgramFiles\cmder"
    Add-ToUserPath "$env:ProgramFiles\cmder"
    Add-ToUserPath "$env:ProgramFiles\cmder\bin"
    Write-Output "C:\venv\default\scripts\activate.bat" | Out-File -Append -Encoding "ascii" $env:ProgramFiles\cmder\config\user_profile.cmd
    & "$env:ProgramFiles\cmder\cmder.exe" /REGISTER ALL
}

# Add PersistenceSniper
if ($WSDFIR_PERSISTENCESNIPER -eq "Yes") {
    Import-Module C:\git\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1
}

# Configure usage of new venv for PowerShell
(Get-ChildItem -File C:\venv\default\Scripts\).Name | findstr /R /V "[\._]" | findstr /V activate | `
    ForEach-Object {Write-Output "function $_() { python C:\venv\default\Scripts\$_ `$PsBoundParameters.Values + `$args }"} | Out-File -Append -Encoding "ascii" "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Signal that everything is done to start using the tools (mostly).
Copy-Item "C:\downloads\README.md" "$HOME\Desktop\"
Update-Wallpaper "C:\downloads\dfirws.jpg"

if ($WSDFIR_CHOCO -eq "Yes") {
    & "C:\downloads\choco\tools\chocolateyInstall.ps1"
    # Add packages below
}

if ($WSDFIR_NODE -eq "Yes") {
    Copy-Item -r "$TOOLS\node" $HOME\Desktop
}

# Run any custom scripts
if (Test-Path "C:\local\customize.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "C:\local\customize.ps1"
}

# Install extra tools for Git-bash
if ($WSDFIR_BASH_EXTRA -eq "Yes") {
    Set-Location "$env:ProgramFiles\Git"
    Get-ChildItem -Path C:\downloads\bash -Include "*.tar" -Recurse |
        ForEach-Object {
            $command = "tar.exe -x -vf /C/downloads/bash/" + $_.Name
            &"C:\Program Files\Git\bin\bash.exe" -c "$command"
        }
}

# Set Notepad++ as default for many file types
if ($WSDFIR_NPP -eq "Yes") {
    # Use %VARIABLE% in cmd.exe
    cmd /c Ftype xmlfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
    cmd /c Ftype txtfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
    cmd /c Ftype chmfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
    cmd /c Ftype cmdfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
    cmd /c Ftype htafile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
    cmd /c Ftype jsefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
    cmd /c Ftype jsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
    cmd /c Ftype vbefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
    cmd /c Ftype vbsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
 } else {
    cmd /c Ftype xmlfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    cmd /c Ftype txtfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    cmd /c Ftype chmfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    cmd /c Ftype cmdfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    cmd /c Ftype htafile="C:\WINDOWS\system32\notepad.exe" "%%*"
    cmd /c Ftype jsefile="C:\WINDOWS\system32\notepad.exe" "%%*"
    cmd /c Ftype jsfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    cmd /c Ftype vbefile="C:\WINDOWS\system32\notepad.exe" "%%*"
    cmd /c Ftype vbsfile="C:\WINDOWS\system32\notepad.exe" "%%*"
 }

# Last commands

if (($WSDFIR_W10_LOOPBACK -eq "Yes") -and ($WIN10)) {
    & "C:\Users\WDAGUtilityAccount\Documents\tools\utils\devcon.exe" install $env:windir\inf\netloop.inf *msloop
}

if ($WSDFIR_LOKI -eq "Yes") {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "C:\downloads\loki.zip" -o"$env:ProgramFiles\"
    Add-ToUserPath "$env:ProgramFiles\loki"
} else {
    mkdir "$env:ProgramFiles\loki"
}
& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "C:\downloads\signature.7z" -o"$env:ProgramFiles\loki"
Remove-Item "$env:ProgramFiles\loki\signature.yara"
& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "C:\downloads\signature.7z" -o"C:\data"
& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "C:\downloads\total.7z" -o"C:\data"

# Start sysmon when installation is done
if ($WSDFIR_SYSMON -eq "Yes") {
    & "$TOOLS\sysinternals\Sysmon64.exe" -accepteula -i "$WSDFIR_SYSMON_CONF"
}

Write-DateLog "helpers.ps1 done"
Stop-Transcript
