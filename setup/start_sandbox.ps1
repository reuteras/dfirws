# DFIRWS

# Import common functions
. $HOME\Documents\tools\wscommon.ps1

$WIN10=(Get-ComputerInfo | Select-Object -expand OsName) -match 10
#$WIN11=(Get-ComputerInfo | Select-Object -expand OsName) -match 11

# Start logging
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$TEMP = "C:\tmp"
mkdir "$TEMP"

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

# Always install java. Needed for wiki
Copy-Item "$SETUP_PATH\corretto.msi" "$TEMP\corretto.msi"
Start-Process -Wait msiexec -ArgumentList "/i $TEMP\corretto.msi /qn /norestart"

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

# Install .NET 6
Start-Process -Wait "$SETUP_PATH\dotnet6.exe" -ArgumentList "/install /quiet /norestart"

# Install HxD
Copy-Item "$TOOLS\hxd\HxDSetup.exe" "$TEMP\HxDSetup.exe"
& "$TEMP\HxDSetup.exe" /VERYSILENT /NORESTART

# Install Git if specified
if ($WSDFIR_GIT -eq "Yes") {
    Copy-Item "$SETUP_PATH\git.exe" "$TEMP\git.exe"
    Copy-Item "$HOME\Documents\tools\.bashrc" "$HOME\"
    & "$TEMP\git.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
}

# Install Notepad++ and ComparePlus plugin if specified
Copy-Item "$SETUP_PATH\notepad++.exe" "$TEMP\notepad++.exe"
& "$TEMP\notepad++.exe" /S
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\comparePlus.zip" -o"$env:ProgramFiles\Notepad++\Plugins\ComparePlus"

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
Add-ToUserPath "$env:ProgramFiles\4n4lDetector"
Add-ToUserPath "$env:ProgramFiles\7-Zip"
Add-ToUserPath "$env:ProgramFiles\bin"
Add-ToUserPath "$env:ProgramFiles\Git\bin"
Add-ToUserPath "$env:ProgramFiles\Git\usr\bin"
Add-ToUserPath "$env:ProgramFiles\hxd"
Add-ToUserPath "$env:ProgramFiles\idr\bin"
Add-ToUserPath "$env:ProgramFiles\Notepad++"
Add-ToUserPath "C:\git\ese-analyst"
Add-ToUserPath "C:\git\Events-Ripper"
Add-ToUserPath "C:\git\RegRipper3.0"
Add-ToUserPath "C:\git\Trawler"
Add-ToUserPath "C:\git\Zircolite\bin"
Add-ToUserPath "C:\Tools\bin"
Add-ToUserPath "C:\Tools\bulk_extractor\win64"
Add-ToUserPath "C:\Tools\capa"
Add-ToUserPath "C:\Tools\chainsaw"
Add-ToUserPath "C:\Tools\cutter"
Add-ToUserPath "C:\Tools\DB Browser for SQLite"
Add-ToUserPath "C:\Tools\DidierStevens"
Add-ToUserPath "C:\Tools\die"
Add-ToUserPath "C:\Tools\elfparser-ng\Release"
Add-ToUserPath "C:\Tools\exiftool"
Add-ToUserPath "C:\Tools\fakenet"
Add-ToUserPath "C:\Tools\fasm"
Add-ToUserPath "C:\Tools\floss"
Add-ToUserPath "C:\Tools\FullEventLogView"
Add-ToUserPath "C:\Tools\gftrace64"
Add-ToUserPath "C:\Tools\GoReSym"
Add-ToUserPath "C:\Tools\hayabusa"
Add-ToUserPath "C:\Tools\imhex"
Add-ToUserPath "C:\Tools\INDXRipper"
Add-ToUserPath "C:\Tools\jd-gui"
Add-ToUserPath "C:\Tools\malcat\bin"
Add-ToUserPath "C:\Tools\lessmsi"
Add-ToUserPath "C:\Tools\nmap"
Add-ToUserPath "C:\Tools\node"
Add-ToUserPath "C:\Tools\systeminformer\x64"
Add-ToUserPath "C:\Tools\systeminformer\x86"
Add-ToUserPath "C:\Tools\pev"
Add-ToUserPath "C:\Tools\procdot\win64"
Add-ToUserPath "C:\Tools\pstwalker"
Add-ToUserPath "C:\Tools\qpdf\bin"
Add-ToUserPath "C:\Tools\radare2\bin"
Add-ToUserPath "C:\Tools\redress"
#Add-ToUserPath "C:\Tools\resource_hacker"
Add-ToUserPath "C:\Tools\ripgrep"
Add-ToUserPath "C:\Tools\scdbg"
Add-ToUserPath "C:\Tools\sqlite"
Add-ToUserPath "C:\Tools\ssview"
Add-ToUserPath "C:\Tools\sysinternals"
Add-ToUserPath "C:\Tools\thumbcacheviewer"
Add-ToUserPath "C:\Tools\trid"
Add-ToUserPath "C:\Tools\upx"
Add-ToUserPath "C:\Tools\WinApiSearch"
Add-ToUserPath "C:\Tools\WinObjEx64"
Add-ToUserPath "C:\Tools\XELFViewer"
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

Write-DateLog "Add shortcuts (shorten link names first)"
#& reg add "HKU\%1\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d 00000000 /f

Copy-Item "$SETUP_PATH\BeaconHunter.exe" "$env:ProgramFiles\bin"

& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\jadx.zip" -o"$env:ProgramFiles\jadx"
Add-ToUserPath "$env:ProgramFiles\jadx\bin"

Copy-Item "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk" "$HOME\Desktop\PowerShell.lnk"
if ($WSDFIR_X64DBG -eq "Yes") {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\x64dbg.zip" -o"$env:ProgramFiles\x64dbg"
    Add-ToUserPath "$env:ProgramFiles\x64dbg\release\x32"
    Add-ToUserPath "$env:ProgramFiles\x64dbg\release\x64"
}

# PowerShell
Copy-Item "$HOME\Documents\tools\Microsoft.PowerShell_profile.ps1" "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType Directory $PSHome\Modules\PSDecode
Copy-Item "$HOME\Documents\tools\utils\PSDecode.psm1" "$PSHome\Modules\PSDecode"

# Jupyter
Copy-Item "$HOME\Documents\tools\jupyter\.jupyter" "$HOME\" -Recurse
mkdir "$HOME\Documents\jupyter"
Copy-Item $HOME\Documents\tools\jupyter\*.ipynb "$HOME\Documents\jupyter\"

New-Item -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Name EnableScriptBlockLogging -Value 1 -Force

Copy-Item -Recurse -Force C:\Tools\4n4lDetector "C:\Program Files"
Copy-Item -Recurse -Force C:\git\IDR "C:\Program Files"

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
# Use %VARIABLE% in cmd.exe
cmd /c Ftype xmlfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd
cmd /c Ftype chmfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype cmdfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype htafile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype jsefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype jsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype vbefile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"
cmd /c Ftype vbsfile="%ProgramFiles%\Notepad++\notepad++.exe" "%%*"

# Last commands
if (($WSDFIR_W10_LOOPBACK -eq "Yes") -and ($WIN10)) {
    & "$HOME\Documents\tools\utils\devcon.exe" install $env:windir\inf\netloop.inf *msloop
}

if ($WSDFIR_LOKI -eq "Yes") {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "C:\downloads\loki.zip" -o"$env:ProgramFiles\"
    Add-ToUserPath "$env:ProgramFiles\loki"
} else {
    mkdir "$env:ProgramFiles\loki"
}

# Clean up
Remove-Item $HOME\Desktop\PdfStreamDumper.exe.lnk

# Create directory for shortcuts to installed tools
mkdir "$HOME\Desktop\dfirws"
mkdir "$HOME\Desktop\dfirws\Browser"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Browser\hindsight.lnk" -DestinationPath "C:\Tools\bin\hindsight_gui.exe"
mkdir "$HOME\Desktop\dfirws\Database"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Database\DB Browser for SQLite.lnk" -DestinationPath "C:\Tools\DB Browser for SQLite\DB Browser for SQLite.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Database\ese2csv.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Database\fqlite.lnk" -DestinationPath "C:\Tools\fqlite\run.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Database\SQLECmd.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation "C:\Tools\Zimmerman\SQLECmd\SQLECmd.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Database\sqlite3.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation "C:\Tools\sqlite\sqlite3.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Database\SQLiteWalker.py.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
# C:\Tools\DidierStevens
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\DidierStevens.lnk" -DestinationPath "C:\Tools\DidierStevens"
mkdir "$HOME\Desktop\dfirws\Disk"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Disk\INDXRipper.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation "C:\Tools\INDXRipper\INDXRipper.exe"
mkdir "$HOME\Desktop\dfirws\Editors"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Bytecode Viewer.lnk" -DestinationPath "C:\Tools\bin\bcv.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\HxD.lnk" -DestinationPath "$env:ProgramFiles\HxD\HxD.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\ImHex.lnk" -DestinationPath "C:Tools\imhex\imhex-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Malcat.lnk" -DestinationPath "C:\Tools\Malcat\bin\malcat.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Notepad++.lnk" -DestinationPath "$env:ProgramFiles\Notepad++\notepad++.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Editors\Visual Studio Code.lnk" -DestinationPath "$HOME\AppData\Local\Programs\Microsoft VS Code\Code.exe"
mkdir "$HOME\Desktop\dfirws\File"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\binlex.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\bulk_extractor64.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\densityscout.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Detect It Easy.lnk" -DestinationPath "C:\Tools\die\die.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\fq.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\lessmsi-gui.lnk" -DestinationPath "C:\Tools\lessmsi\lessmsi-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\ripgrep (rg).lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\trid.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\File\Office and email"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\Mbox Viewer.lnk" -DestinationPath "C:\Tools\mboxviewer\mboxview64.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\MetadataPlus.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation "C:\Tools\bin\MetadataPlus.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\mraptor.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\msgviewer.lnk" -DestinationPath "C:\Tools\lib\msgviewer.jar"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\msodde.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\oledump.py.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\oleid.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\olevba.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\msgviewer.lnk" -DestinationPath "C:\Tools\pstwalker\pstwalker.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\rtfdump.py.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\rtfobj.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\Structured Storage Viewer (SSView).lnk" -DestinationPath "C:\Tools\ssview\SSView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\tree.com.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\Office and email\zipdump.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\File\PDF"
if ($WSDFIR_PDFSTREAM -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PDF\pdfstreamdumper.lnk" -DestinationPath "C:\Sandsprite\PDFStreamDumper\PDFStreamDumper.exe"
}
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PDF\pdf-parser.py.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PDF\pdfid.py.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PDF\peepdf.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PDF\qpdf.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\File\PE"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\4n4lDetector.lnk" -DestinationPath "C:\Program Files\4n4lDetector\4N4LDetector.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\capa.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation C:\Tools\capa\capa.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\Debloat.lnk" -DestinationPath "C:\Tools\bin\debloat.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\dll_to_exe.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\hollows_hunter.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation C:\Tools\bin\hollows_hunter.exe
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\pe2pic.bat.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
#Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\pe2shc.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation C:\Tools\bin\pe2shc.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\PE-bear.lnk" -DestinationPath "C:\Tools\pebear\PE-bear.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\PE-sieve.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation C:\Tools\bin\pe-sieve.exe
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\pestudio.lnk" -DestinationPath "C:\Tools\pestudio\pestudio\pestudio.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\pescan.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "C:\Tools\pev"
#Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\Resource Hacker.lnk" -DestinationPath "C:\Tools\resource_hacker\ResourceHacker.exe"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\shellconv.py.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\File\PE\WinObjEx64.lnk" -DestinationPath "C:\Tools\WinObjEx64\WinObjEx64.exe"
mkdir "$HOME\Desktop\dfirws\IR"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\IR\Trawler.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\Log"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Log\chainsaw.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Log\Events-Ripper.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Log\FullEventLogView.lnk" -DestinationPath "C:\Tools\FullEventLogView\FullEventLogView.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Log\hayabusa.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Log\Microsoft LogParser (LogParser).lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Log\PowerSiem.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\Malware tools"
mkdir "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\1768.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\BeaconHunter.lnk" -DestinationPath "C:\Program Files\bin\BeaconHunter.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Malware tools\Cobalt Strike\CobaltStrikeScan.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\Network"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Network\Fakenet.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation "C:\Tools\fakenet\fakenet.exe"
mkdir "$HOME\Desktop\dfirws\Online tools"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Online tools\vt.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\OS"
mkdir "$HOME\Desktop\dfirws\OS\Linux"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Linux\elfparser-ng.lnk" -DestinationPath "C:\Tools\elfparser-ng\Release\elfparser-ng.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Linux\xelfviewer.lnk" -DestinationPath "C:\Tools\XELFViewer\xelfviewer.exe"
mkdir "$HOME\Desktop\dfirws\OS\macOS"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\macOS\dsstore.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "C:\git\Python-dsstore"
mkdir "$HOME\Desktop\dfirws\OS\Windows"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Jumplist-Browser.lnk" -DestinationPath "C:\Tools\bin\JumplistBrowser.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Prefetch-Browser.lnk" -DestinationPath "C:\Tools\bin\PrefetchBrowser.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\procdot.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\sidr.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Thumbcache Viewer.lnk" -DestinationPath "C:\Tools\thumbcacheviewer\thumbcache_viewer.exe"
mkdir "$HOME\Desktop\dfirws\OS\Windows\Registry"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Registry\Registry Explorer.lnk" -DestinationPath "C:\Tools\Zimmerman\RegistryExplorer\RegistryExplorer.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\OS\Windows\Registry\RegRipper (rip).lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\Programming"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\java.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\node.lnk" -DestinationPath "C:\Tools\node\node.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Python.lnk" -DestinationPath "C:\venv\default\Scripts\python.exe"
mkdir "$HOME\Desktop\dfirws\Programming\Delphi"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Delphi\idr.lnk" -DestinationPath "C:\Program Files\idr\bin\Idr.exe"
mkdir "$HOME\Desktop\dfirws\Programming\Go"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Go\gftrace.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Go\GoReSym.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
mkdir "$HOME\Desktop\dfirws\Programming\Java"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\jadx-gui.lnk" -DestinationPath "$env:ProgramFiles\jadx\bin\jadx-gui.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\jd-gui.lnk" -DestinationPath "C:\Tools\jd-gui\jd-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\Java\recaf.lnk" -DestinationPath "C:\Tools\bin\recaf.bat"
mkdir "$HOME\Desktop\dfirws\Programming\PowerShell"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Programming\PowerShell\PowerDecode.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "C:\git\PowerDecode"
mkdir "$HOME\Desktop\dfirws\Reverse Engineering"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\Cutter.lnk" -DestinationPath "C:\Tools\cutter\cutter.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\dnSpy32.lnk" -DestinationPath "C:\Tools\dnSpy32\dnSpy.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\dnSpy64.lnk" -DestinationPath "C:\Tools\dnSpy64\dnSpy.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\fasm.lnk" -DestinationPath "C:\Tools\fasm\FASM.EXE"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\Ghidra.lnk" -DestinationPath "C:\Tools\ghidra\ghidraRun.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\radare2.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\scare.bat.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
if ($WSDFIR_X64DBG -eq "Yes") {
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\x32dbg.lnk" -DestinationPath "$env:ProgramFiles\x64dbg\release\x32\x32dbg.exe"
    Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Reverse Engineering\x64dbg.lnk" -DestinationPath "$env:ProgramFiles\x64dbg\release\x64\x64dbg.exe"
}
mkdir "$HOME\Desktop\dfirws\Signatures and information"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\evt2sigma.bat.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\loki.lnk" -DestinationPath "C:\Program Files\loki\loki.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\PatchaPalooza.py.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "C:\git\PatchaPalooza"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\WinApiSearch64.lnk" -DestinationPath "C:\Tools\WinApiSearch\WinApiSearch64.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Signatures and information\yara.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
# "$HOME\Desktop\dfirws\Sysinternals"
Add-shortcut -SourceLnk "$HOME\Desktop\dfirws\Sysinternals.lnk" -DestinationPath "C:\Tools\sysinternals"
mkdir "$HOME\Desktop\dfirws\Utilities"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\7-Zip.lnk" -DestinationPath "C:\Program Files\7-Zip\7zFM.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\bash.lnk" -DestinationPath "$env:ProgramFiles\Git\bin\bash.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\cmder.lnk" -DestinationPath "$env:ProgramFiles\cmder\cmder.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\CyberChef.lnk" -DestinationPath "C:\Tools\CyberChef\CyberChef.html"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\exiftool.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation "C:\Tools\exiftool\exiftool.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\floss.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation "C:\Tools\floss\floss.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\git.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop" -Iconlocation "C:\Program Files\Git\cmd\git-gui.exe"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\upx.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Utilities\zstd.lnk" -DestinationPath "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory "$HOME\Desktop"
# "$HOME\Desktop\dfirws\Zimmerman"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws\Zimmerman.lnk" -DestinationPath "C:\Tools\Zimmerman"

# Pin to explorer
$shell = new-object -com "Shell.Application"
$folder = $shell.Namespace("$HOME\Desktop")
$item = $folder.Parsename('dfirws')
$verb = $item.Verbs() | Where-Object { $_.Name -eq 'Pin to Quick access' }
if ($verb) {
    $verb.DoIt()
}

# TODO
# Links to
# - C:\git tools
# - pip tools
# - node tools

New-Item -ItemType Directory -Force -Path "$HOME\AppData\Roaming\rizin\cutter\plugins\python" | Out-Null
Copy-Item C:\git\radare2-deep-graph\cutter\graphs_plugin_grid.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
#Copy-Item C:\downloads\cutter_stackstrings.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item C:\downloads\x64dbgcutter.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item C:\git\cutterref\cutterref.py "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse C:\git\cutterref\archs "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
#Copy-Item -Recurse C:\git\cutter-jupyter\cutter_jupyter "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse C:\git\cutter-jupyter\icons "$HOME\AppData\Roaming\rizin\cutter\plugins\python"
Copy-Item -Recurse C:\git\capa-explorer\capa_explorer_plugin "$HOME\AppData\Roaming\rizin\cutter\plugins\python"

Start-Transcript -Append "$TEMP\dfirws_log.txt"

& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "C:\downloads\signature.7z" -o"$env:ProgramFiles\loki"
Remove-Item "$env:ProgramFiles\loki\signature.yara"
& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "C:\downloads\signature.7z" -o"C:\data"
& "$env:ProgramFiles\7-Zip\7z.exe" x -pinfected "C:\downloads\total.7z" -o"C:\data"

# Start sysmon when installation is done
if ($WSDFIR_SYSMON -eq "Yes") {
    & "$TOOLS\sysinternals\Sysmon64.exe" -accepteula -i "$WSDFIR_SYSMON_CONF"
}

# Start Gollum for local wiki
netsh firewall set opmode DISABLE 2>&1 | Out-Null
Start-Process "C:\Program Files\Amazon Corretto\jdk*\bin\java.exe" -argumentlist "-jar C:\Tools\lib\gollum.war -S gollum C:\git\dfirws.wiki" -WindowStyle Hidden

REG ADD "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t REG_DWORD /d 1
Add-Shortcut -SourceLnk "$HOME\Desktop\jupyter.lnk" -DestinationPath "$HOME\Documents\tools\jupyter.bat"
Add-Shortcut -SourceLnk "$HOME\Desktop\dfirws wiki.lnk" -DestinationPath "$HOME\Documents\tools\utils\gollum.bat"

Write-DateLog "helpers.ps1 done"
Stop-Transcript
