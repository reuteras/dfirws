# DFIRWS

# Ugly fix for Code Integrity blocking unsigned binaries and speeding up installation
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Policy" /v VerifiedAndReputablePolicyState /t REG_DWORD /d 0 /f
"`n" | CiTool.exe -r

# Cleanup - double Egde shortcut since sometime 2026
if (Test-Path 'C:\Users\Public\Desktop\Microsoft Edge.lnk') {
	Remove-Item 'C:\Users\Public\Desktop\Microsoft Edge.lnk' -Force
}

# Import common functions
if (Test-Path "${HOME}\Documents\tools\wscommon.ps1") {
    . "${HOME}\Documents\tools\wscommon.ps1"
} else {
    . '\\vmware-host\Shared Folders\dfirws\setup\wscommon.ps1'
}

# Start logging
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-DateLog "Start sandbox configuration" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log"

# Check if running in verify mode
if (Test-Path "C:\log\log.txt") {
	Add-Shortcut -SourceLnk "${HOME}\Desktop\progress.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Get-Content C:\log\verify.txt -Wait"
	Write-DateLog "Sandbox started in verify mode." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Set the execution policy to Bypass for default PowerShell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force

# Install 7-Zip first - needed for other installations
Start-Process -Wait msiexec -ArgumentList "/i ${SETUP_PATH}\7zip.msi /qn /norestart"
Write-DateLog "7-Zip installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install PSDecode module - https://github.com/R3MRUM/PSDecode
Copy-Item "${HOME}\Documents\tools\utils\PSDecode.psm1" "${env:ProgramFiles}\PowerShell\Modules\PSDecode" -Force | Out-Null

# Link latest PowerShell and set execution policy to Bypass
New-Item -Path "${env:ProgramFiles}\PowerShell\7" -ItemType SymbolicLink -Value "${TOOLS}\pwsh" -Force | Out-Null
& "${POWERSHELL_EXE}" -Command "Set-ExecutionPolicy -Scope CurrentUser Unrestricted"
Write-DateLog "PowerShell installed and execution policy set to Unrestricted for pwsh done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

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

# Copy config files and import them - needed for OhMyPosh installation
if (Test-Path "${LOCAL_PATH}\config.txt") {
    Copy-Item "${LOCAL_PATH}\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force | Out-Null
}
. "${WSDFIR_TEMP}\config.ps1"
Write-DateLog "Config files copied and imported" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install OhMyPosh
Install-OhMyPosh | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install HxD
Copy-Item "${TOOLS}\hxd\HxDSetup.exe" "${WSDFIR_TEMP}\HxDSetup.exe" -Force
& "${WSDFIR_TEMP}\HxDSetup.exe" /VERYSILENT /NORESTART
Write-DateLog "HxD installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install IrfanView
& "${SETUP_PATH}\irfanview.exe" /silent /assoc=1 | Out-Null
Write-DateLog "IrfanView installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install Notepad++ and plugins
if (("${WSDFIR_NOTEPAD}" -eq "Yes") -or (Test-Path "C:\log\log.txt")) {
	& "${SETUP_PATH}\notepad++.exe" /S  | Out-Null
	Add-ToUserPath "${env:ProgramFiles}\Notepad++"
	Add-Shortcut -SourceLnk "${HOME}\Desktop\Notepad++.lnk" -DestinationPath "${env:ProgramFiles}\Notepad++\notepad++.exe"
	Write-DateLog "Notepad++ installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Install Neovim
if (("${WSDFIR_NEOVIM}" -eq "Yes") -or (Test-Path "C:\log\log.txt")) {
	Install-Neovim
	Write-DateLog "Neovim installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

#
# Configure the sandbox
#

# PowerShell
if (Test-Path "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1") {
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
    Copy-Item "${LOCAL_PATH}\defaults\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
}

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

	# Change TERMINAL_INSTALL_DIR to actual installed version
	Get-Content "${HOME}\Documents\tools\reg\right-click.reg" | 
		ForEach-Object { $_ -replace "TERMINAL_INSTALL_DIR", "${TERMINAL_INSTALL_DIR}" } | 
		Set-Content "${WSDFIR_TEMP}\right-click.reg"

	reg import "${WSDFIR_TEMP}\right-click.reg" | Out-Null
	Write-DateLog "Right-click context menu registry settings imported" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

# Import registry settings
reg import "${HOME}\Documents\tools\reg\registry.reg" | Out-Null
Write-DateLog "Registry settings imported" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Uses SystemFileAssociations so the verbs apply reliably to file types
# Uses full path to pwsh.exe (PowerShell 7)

$extensions = @(
    "doc","docm","docx","dot","dotm","dotx",
    "xls","xlsm","xlsx","xlt","xltm","xltx",
    "ppt","pptm","pptx","pot","potm","potx"
)

$wtpath = "C:\\Program Files\\Windows Terminal\\${TERMINAL_INSTALL_DIR}\\wt.exe"

foreach ($extension in $extensions) {
    $baseKey = "HKEY_LOCAL_MACHINE\Software\Classes\SystemFileAssociations\.${extension}\shell\dfirws_office"

    $cmd_mraptor = "`\`"$wtpath`\`" -w 0 C:\\Program Files\\PowerShell\\7\\pwsh.exe -NoExit -Command `\`"mraptor '%1'`\`""
    $cmd_oleid   = "`\`"$wtpath`\`" -w 0 C:\\Program Files\\PowerShell\\7\\pwsh.exe -NoExit -Command `\`"oleid '%1'`\`""
    $cmd_olevba  = "`\`"$wtpath`\`" -w 0 C:\\Program Files\\PowerShell\\7\\pwsh.exe -NoExit -Command `\`"olevba '%1'`\`""

    $registry_file = @"
Windows Registry Editor Version 5.00

[$baseKey]
"MUIVerb"="dfirws office"
"SubCommands"=""

[$baseKey\shell\mraptor]
"MUIVerb"="mraptor"

[$baseKey\shell\mraptor\command]
@="$cmd_mraptor"

[$baseKey\shell\oleid]
"MUIVerb"="oleid"

[$baseKey\shell\oleid\command]
@="$cmd_oleid"

[$baseKey\shell\olevba]
"MUIVerb"="olevba"

[$baseKey\shell\olevba\command]
@="$cmd_olevba"
"@

    $regPath = Join-Path $WSDFIR_TEMP "${extension}.reg"
    $registry_file | Out-File -FilePath $regPath -Encoding ascii

    reg import $regPath | Out-Null
    Remove-Item -LiteralPath $regPath -Force
}

Write-DateLog "Office extensions added" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Set default editor associations for text files

# Extensions you want
$exts = @(
  ".txt",".log",".md",".json",".yaml",".yml",".toml",".ini",".cfg",
  ".xml",".html",".css",".ts",".tsx",".lua",".c",".cpp",".h",".cs",".go",".rs",".sh"
)

# Select editor
$editorSel = $WSDFIR_TEXT_EDITOR
if ([string]::IsNullOrWhiteSpace($editorSel)) { $editorSel = "notepad_plus_plus" }
$editorSel = $editorSel.ToLowerInvariant()

function Resolve-ExePath {
  param(
    [string[]]$names,
    [string[]]$fallbackPaths
  )
  foreach ($n in $names) {
    $cmd = Get-Command $n -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { return $cmd.Source }
  }
  foreach ($p in $fallbackPaths) {
    if ($p -and (Test-Path $p)) { return $p }
  }
  return $null
}

function Resolve-Editor {
  param([string]$sel)

  if ($sel -eq "neovim" -or $sel -eq "nvim") {
    $exe = Resolve-ExePath `
      -names @("nvim.exe") `
      -fallbackPaths @(
        "$env:ProgramFiles\Neovim\bin\nvim.exe",
        "$env:LOCALAPPDATA\Programs\Neovim\bin\nvim.exe",
        "$env:ChocolateyInstall\bin\nvim.exe"
      )
    if (-not $exe) { throw "WSDFIR_TEXT_EDITOR='$sel' but nvim.exe not found." }

    return [pscustomobject]@{
      Name     = "Neovim"
      ProgId   = "WSDFIR.Neovim.File"
      AppExe   = "nvim.exe"
      Exe      = $exe
      Cmd      = "`"$exe`" `"%1`""
      Icon     = "`"$exe`",0"
      ShellKey = "EditWithNeovim"
    }
  }

  # default: Notepad++
  $exe = Resolve-ExePath `
    -names @("notepad++.exe") `
    -fallbackPaths @(
      "$env:ProgramFiles\Notepad++\notepad++.exe",
      "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe",
      "$env:ChocolateyInstall\bin\notepad++.exe",
      "$env:LOCALAPPDATA\Programs\Notepad++\notepad++.exe"
    )
  if (-not $exe) { throw "Notepad++ selected (default/fallback) but notepad++.exe not found." }

  return [pscustomobject]@{
    Name     = "Notepad++"
    ProgId   = "WSDFIR.NotepadPP.File"
    AppExe   = "notepad++.exe"
    Exe      = $exe
    Cmd      = "`"$exe`" `"%1`""
    Icon     = "`"$exe`",0"
    ShellKey = "EditWithNotepadPP"
  }
}

function Set-DefaultForExt {
  param(
    [string]$ext,
    [string]$progId
  )

  # 1) The actual association
  $extKey = "HKCU:\Software\Classes\$ext"
  New-Item -Path $extKey -Force | Out-Null
  Set-ItemProperty -Path $extKey -Name "(default)" -Value $progId

  # 2) Make Windows treat it as a text file (helps Explorer “open” behavior)
  New-ItemProperty -Path $extKey -Name "PerceivedType" -Value "text" -PropertyType String -Force | Out-Null

  # Special case for .md to be treated as markdown (enables preview pane and other features in Explorer)
  if ($ext -eq ".md") {
    New-ItemProperty -Path $extKey -Name "Content Type" -Value "text/markdown" -PropertyType String -Force | Out-Null
  }

  # 3) Clear Explorer overrides for THIS extension only
  $fe = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$ext"
  Remove-Item -Path "$fe\UserChoice" -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -Path "$fe\OpenWithList" -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -Path "$fe\OpenWithProgids" -Recurse -Force -ErrorAction SilentlyContinue
}

# --- Pick editor + define ProgID ---
$ed = Resolve-Editor -sel $editorSel

$progRoot = "HKCU:\Software\Classes\$($ed.ProgId)"

# ProgID open + edit (maximum feel)
New-Item -Path "$progRoot\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "$progRoot\shell\open\command" -Name "(default)" -Value $ed.Cmd

New-Item -Path "$progRoot\shell\edit\command" -Force | Out-Null
Set-ItemProperty -Path "$progRoot\shell\edit\command" -Name "(default)" -Value $ed.Cmd

New-Item -Path $progRoot -Force | Out-Null
Set-ItemProperty -Path $progRoot -Name "FriendlyTypeName" -Value ("WSDFIR " + $ed.Name)
New-Item -Path "$progRoot\DefaultIcon" -Force | Out-Null
Set-ItemProperty -Path "$progRoot\DefaultIcon" -Name "(default)" -Value $ed.Icon

# Register application (helps “Choose an app” scenarios)
New-Item -Path "HKCU:\Software\Classes\Applications\$($ed.AppExe)\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\Applications\$($ed.AppExe)\shell\open\command" -Name "(default)" -Value $ed.Cmd

# Always-available context menu entry for all files (*)
New-Item -Path "HKCU:\Software\Classes\*\shell\$($ed.ShellKey)\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\*\shell\$($ed.ShellKey)\command" -Name "(default)" -Value $ed.Cmd

# --- Apply associations (explicitly avoid .lnk) ---
foreach ($ext in $exts) {
  Set-DefaultForExt -ext $ext -progId $ed.ProgId
}

Write-DateLog "Editor associations set" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

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
# PATH - Windows have a limit of <2048 characters for user PATH

Write-DateLog "Add to PATH" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
$GHIDRA_INSTALL_DIR=((Get-ChildItem "${TOOLS}\ghidra\").Name | findstr "PUBLIC" | Select-Object -Last 1)

# TODO: Handle these later
# "${env:ProgramFiles}\IDR\bin"
# "${env:ProgramFiles}\jadx\bin"
# "${GIT_PATH}\defender-detectionhistory-parser"
# "${GIT_PATH}\ese-analyst"
# "${GIT_PATH}\Events-Ripper"
# "${GIT_PATH}\iShutdown"
# "${GIT_PATH}\RegRipper4.0"
# "${GIT_PATH}\Regshot"
# "${GIT_PATH}\Trawler"
# "${GIT_PATH}\White-Phoenix"
# "${TOOLS}\h2database"
# "${TOOLS}\Zimmerman\net6\EvtxECmd"
# "${TOOLS}\Zimmerman\net6\EZViewer"
# "${TOOLS}\Zimmerman\net6\JumpListExplorer"
# "${TOOLS}\Zimmerman\net6\MFTExplorer"
# "${TOOLS}\Zimmerman\net6\RECmd"
# "${TOOLS}\Zimmerman\net6\SDBExplorer"
# "${TOOLS}\Zimmerman\net6\SQLECmd"
# "${TOOLS}\Zimmerman\net6\XWFIM"
# "${TOOLS}\nmap"
# "${TOOLS}\hfs"
# "${TOOLS}\VolatilityWorkbench"
# "${TOOLS}\WinApiSearch"
# "${TOOLS}\gftrace64"
# "${TOOLS}\procdot\win64"
# "${TOOLS}\systeminformer\x64"
# "${TOOLS}\systeminformer\x86"
# "${TOOLS}\XELFViewer"
# "${TOOLS}\audacity"
# "${TOOLS}\capa-ghidra"
# "${TOOLS}\elfparser-ng\Release"
# "${TOOLS}\RdpCacheStitcher"

$ADD_TO_PATH = @("${MSYS2_DIR}"
    "${MSYS2_DIR}\ucrt64\bin"
    "${MSYS2_DIR}\usr\bin"
	"${TOOLS}\perl\perl\bin"
	"${env:ProgramFiles}\7-Zip"
	"${env:ProgramFiles}\Git\bin"
	"${env:ProgramFiles}\Git\cmd"
	"${env:ProgramFiles}\Git\usr\bin"
	"${env:ProgramFiles}\graphviz\bin"
	"${env:ProgramFiles}\hxd"
	"${env:ProgramFiles}\iisGeolocate"
	"${env:ProgramFiles}\KAPE"
	"${env:ProgramFiles}\loki"
	"${env:ProgramFiles}\RegistryExplorer"
	"${env:ProgramFiles}\ShellBagsExplorer"
	"${env:ProgramFiles}\TimelineExplorer"
	"${env:ProgramFiles}\qemu"
	"${RUST_DIR}\bin"
	"${HOME}\Go\bin"
	"${TERMINAL_INSTALL_LOCATION}"
	"${TOOLS}\artemis"
	"${TOOLS}\bin"
	"${TOOLS}\bulk_extractor\win64"
	"${TOOLS}\capa"
	"${TOOLS}\cargo\bin"
	"${TOOLS}\chainsaw"
	"${TOOLS}\cutter"
	"${TOOLS}\sqlitebrowser"
	"${TOOLS}\die"
	"${TOOLS}\dumpbin"
	"${TOOLS}\ExeinfoPE"
	"${TOOLS}\exiftool"
	"${TOOLS}\fakenet"
	"${TOOLS}\fasm"
	"${TOOLS}\ffmpeg\bin"
	"${TOOLS}\floss"
	"${TOOLS}\FullEventLogView"
    "${TOOLS}\ghidra\${GHIDRA_INSTALL_DIR}"
	"${TOOLS}\godap"
	"${TOOLS}\GoReSym"
	"${TOOLS}\hayabusa"
	"${TOOLS}\imhex"
	"${TOOLS}\INDXRipper"
	"${TOOLS}\jd-gui"
	"${TOOLS}\MailView"
	"${TOOLS}\MemProcFS"
	"${TOOLS}\mmdbinspect"
	"${TOOLS}\lessmsi"
	"${TOOLS}\node"
	"${TOOLS}\pebear"
	"${TOOLS}\pestudio"
	"${TOOLS}\pev"
	"${TOOLS}\php"
	"${TOOLS}\pstwalker"
	"${TOOLS}\qpdf\bin"
	"${TOOLS}\qrtool"
	"${TOOLS}\radare2\bin"
	"${TOOLS}\redress"
	"${TOOLS}\ripgrep"
	"${TOOLS}\scdbg"
	"${TOOLS}\sleuthkit\bin"
	"${TOOLS}\sqlite"
	"${TOOLS}\ssview"
	"${TOOLS}\sysinternals"
	"${TOOLS}\takajo"
	"${TOOLS}\thumbcacheviewer"
	"${TOOLS}\trid"
	"${TOOLS}\upx"
	"${TOOLS}\WinObjEx64"
	"${TOOLS}\Zimmerman\net6"
	"${TOOLS}\zircolite"
	"${TOOLS}\zircolite\bin"
	"${TOOLS}\zstd"
	"${TOOLS}\YAMAGoya"
	"${VENV}\bin"
	"${HOME}\Documents\tools\utils")

$ADD_TO_PATH_STRING = $ADD_TO_PATH -join ";"
echo "Adding to PATH: $ADD_TO_PATH_STRING" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
# Save length of ADD_TO_PATH_STRING to log
$length = $ADD_TO_PATH_STRING.Length
echo "Length of PATH addition string: $length" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
# Total user PATH length
$existingUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$totalPathLength = $existingUserPath.Length + $length + 1
echo "Total user PATH length after addition: $totalPathLength" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
# Warn if total length exceeds 2048 characters
if ($totalPathLength -gt 2048) {
	echo "WARNING: Total user PATH length exceeds 2048 characters. Some entries may be truncated." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

Add-MultipleToUserPath $ADD_TO_PATH_STRING

Write-DateLog "Start creation of Desktop/dfirws" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
Start-Process ${POWERSHELL_EXE} -ArgumentList "${HOME}\Documents\tools\utils\dfirws_folder.ps1" -NoNewWindow

# Add shortcuts to desktop
Add-Shortcut -SourceLnk "${HOME}\Desktop\jupyter.lnk" -DestinationPath "${HOME}\Documents\tools\utils\jupyter.bat" -IconLocation "C:\venv\uv\jupyterlab\Lib\site-packages\jupyter_server\static\favicons\favicon.ico"
Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws docs.lnk" -DestinationPath "${HOME}\Documents\tools\utils\mkdocs.bat" -IconLocation "$env:windir\System32\shell32.dll" -IconIndex 23
Add-Shortcut -SourceLnk "${HOME}\Desktop\Windows Terminal.lnk" -DestinationPath "${TERMINAL_INSTALL_LOCATION}\wt.exe" -WorkingDirectory "${HOME}\Desktop"

# Enable clipboard history
New-Item -Path "HKCU:\Software\Microsoft\Clipboard" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name EnableClipboardHistory -Type DWord -Value 1

#
# Main installation done, now copy files to user profile and other locations
#

# Install Graphviz
& "${SETUP_PATH}\graphviz.exe" /S /D="${env:ProgramFiles}\graphviz"
Write-DateLog "Installing Graphviz done." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Copy files to user profile
New-Item -Path "${HOME}/ghidra_scripts" -ItemType Directory -Force | Out-Null
if (Test-Path "${SETUP_PATH}\capa_explorer.py") {
    Copy-Item "${SETUP_PATH}\capa_explorer.py" "${HOME}/ghidra_scripts/capa_explorer.py" -Force | Out-Null
}if (Test-Path "${SETUP_PATH}\capa_ghidra.py") {
    Copy-Item "${SETUP_PATH}\capa_ghidra.py" "${HOME}/ghidra_scripts/capa_ghidra.py" -Force | Out-Null
}

# Add plugins to Cutter
New-Item -ItemType Directory -Force -Path "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" | Out-Null
Copy-Item "${GIT_PATH}\radare2-deep-graph\cutter\graphs_plugin_grid.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
Copy-Item "${SETUP_PATH}\x64dbgcutter.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
Copy-Item "${GIT_PATH}\cutterref\cutterref.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\cutterref\archs" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\archs" | Out-Null
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\cutter-jupyter\icons" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\icons" | Out-Null
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\capa-explorer\capa_explorer_plugin" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\capa_explorer_plugin" | Out-Null
Write-DateLog "Installed Cutter plugins." | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# BeaconHunter
Robocopy.exe /MT:96 /MIR "${TOOLS}\BeaconHunter" "${env:ProgramFiles}\BeaconHunter" | Out-Null

# IDR
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\IDR" "${env:ProgramFiles}\IDR" | Out-Null

# Jupyter
Robocopy.exe /MT:96 /MIR "${HOME}\Documents\tools\jupyter\.jupyter" "${HOME}\.jupyter" | Out-Null
Copy-Item "${HOME}\Documents\tools\jupyter\common.py" "${HOME}\Documents\jupyter\" -Force | Out-Null
Copy-Item "${HOME}\Documents\tools\jupyter\*.ipynb" "${HOME}\Documents\jupyter\" -Force | Out-Null

# IIS Geolocate and other Zimmerman tools that needs readwrite access
Robocopy.exe /MT:96 /MIR "${TOOLS}\Zimmerman\net6\iisGeolocate" "${env:ProgramFiles}\iisGeolocate" | Out-Null
if (Test-Path "C:\enrichment\maxmind_current\GeoLite2-City.mmdb") {
    Copy-Item "C:\enrichment\maxmind_current\GeoLite2-City.mmdb" "${env:ProgramFiles}\iisGeolocate\" -Force | Out-Null
}
Robocopy.exe /MT:96 /MIR "${TOOLS}\Zimmerman\net6\RegistryExplorer" "${env:ProgramFiles}\RegistryExplorer" | Out-Null
Robocopy.exe /MT:96 /MIR "${TOOLS}\Zimmerman\net6\ShellBagsExplorer" "${env:ProgramFiles}\ShellBagsExplorer" | Out-Null
Robocopy.exe /MT:96 /MIR "${TOOLS}\Zimmerman\net6\TimelineExplorer" "${env:ProgramFiles}\TimelineExplorer" | Out-Null

# geolocus
if (Test-Path "C:\enrichment\geolocus\.cache\geolocus-cli\geolocus.mmdb") {
    New-Item -Path "${HOME}\.cache\geolocus-cli" -ItemType Directory -Force | Out-Null
    Copy-Item "C:\enrichment\geolocus\.cache\geolocus-cli\geolocus.mmdb" "${HOME}\.cache\geolocus-cli\geolocus.mmdb" -Force | Out-Null
}

# AuthLogParser
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\AuthLogParser" "${env:ProgramFiles}\AuthLogParser" | Out-Null

# 4n4lDetector
& "${env:ProgramFiles}\7-Zip\7z.exe" x "${SETUP_PATH}\4n4lDetector.zip" -o"${env:ProgramFiles}\4n4lDetector" | Out-Null

# Config for bash and zsh
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

# If in verify mode, run install_all and install_verify scripts
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