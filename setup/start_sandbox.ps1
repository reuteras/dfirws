# DFIRWS

# Ugly fix for Code Integrity blocking unsigned binaries and speeding up installation
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Policy" /v VerifiedAndReputablePolicyState /t REG_DWORD /d 0 /f
"`n" | CiTool.exe -r

# Disable firewall early to enable local web services during setup
netsh firewall set opmode DISABLE 2>&1 | Out-Null

# Cleanup - double Egde shortcut since sometime 2026
if (Test-Path 'C:\Users\Public\Desktop\Microsoft Edge.lnk') {
	Remove-Item 'C:\Users\Public\Desktop\Microsoft Edge.lnk' -Force
}

# Import common functions - first is for sandbox second is for VM
$TARGET_ENVIRONMENT = "Sandbox"
if (Test-Path "${HOME}\Documents\tools\wscommon.ps1") {
    . "${HOME}\Documents\tools\wscommon.ps1"
} else {
    . '\\vmware-host\Shared Folders\dfirws\setup\wscommon.ps1'
    $TARGET_ENVIRONMENT = "VM"
}

# Start logging
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-DateLog "Start $TARGET_ENVIRONMENT configuration" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log"
filter Write-SetupLog { $_ | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append }

$SANDBOX_PROGRESS_STEPS = (Select-String -Pattern 'Update-SandboxProgress' -Path $PSCommandPath).Count - 1
if ($TARGET_ENVIRONMENT -eq "VM") {
   Initialize-SandboxProgress -TotalSteps $SANDBOX_PROGRESS_STEPS
} else {
   Initialize-SandboxProgress -TotalSteps $SANDBOX_PROGRESS_STEPS -Title "DFIRWS VM Setup"
}

# Check if running in verify mode
if (Test-Path "C:\log\log.txt") {
	Add-Shortcut -SourceLnk "${HOME}\Desktop\progress.lnk" -DestinationPath "${POWERSHELL_EXE}" -WorkingDirectory "${HOME}\Desktop" -Arguments "-NoExit -command Get-Content C:\log\verify.txt -Wait"
	Write-DateLog "Sandbox started in verify mode." | Write-SetupLog
}

# Set the execution policy to Bypass for default PowerShell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force

# Install 7-Zip first - needed for other installations
Update-SandboxProgress "Installing 7-Zip..."
$proc7zip = Start-Process -Wait -PassThru msiexec -ArgumentList "/i ${SETUP_PATH}\7zip.msi /qn /norestart"
if ($proc7zip.ExitCode -ne 0) {
    Write-DateLog "WARNING: 7-Zip installer exited with code $($proc7zip.ExitCode)" | Write-SetupLog
}
Write-DateLog "7-Zip installed" | Write-SetupLog

# Install PSDecode module - https://github.com/R3MRUM/PSDecode
Copy-Item "${HOME}\Documents\tools\utils\PSDecode.psm1" "${env:ProgramFiles}\PowerShell\Modules\PSDecode" -Force | Out-Null

# Link latest PowerShell and set execution policy to Bypass
Update-SandboxProgress "Configuring PowerShell 7..."
New-Item -Path "${env:ProgramFiles}\PowerShell\7" -ItemType SymbolicLink -Value "${TOOLS}\pwsh" -Force | Out-Null
& "${POWERSHELL_EXE}" -Command "Set-ExecutionPolicy -Scope CurrentUser Unrestricted"
Write-DateLog "PowerShell installed and execution policy set to Unrestricted for pwsh done." | Write-SetupLog

#
# Install base tools
#

# Always install common Java.
Update-SandboxProgress "Installing Java..."
$procJava = Start-Process -Wait -PassThru msiexec -ArgumentList "/i ${SETUP_PATH}\corretto.msi /qn /norestart"
if ($procJava.ExitCode -ne 0) {
    Write-DateLog "WARNING: Java installer exited with code $($procJava.ExitCode)" | Write-SetupLog
}
Write-DateLog "Java installed" | Write-SetupLog

# Install Python - retry up to 3 times as installer can be unreliable
Update-SandboxProgress "Installing Python..."
$pythonInstalled = $false
for ($attempt = 1; $attempt -le 3; $attempt++) {
    $procPython = Start-Process -Wait -PassThru "${SETUP_PATH}\python3.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
    if ($procPython.ExitCode -eq 0) {
        $pythonInstalled = $true
        break
    }
    Write-DateLog "Python installation attempt $attempt failed (exit code: $($procPython.ExitCode)), retrying in 5 seconds..." | Write-SetupLog
    Start-Sleep -Seconds 5
}
if ($pythonInstalled) {
    Write-DateLog "Python installed" | Write-SetupLog
} else {
    Write-DateLog "WARNING: Python installation may have failed after 3 attempts" | Write-SetupLog
}

# Install Visual C++ Redistributable 17
Update-SandboxProgress "Installing Visual C++ Redistributable..."
$procVcredist = Start-Process -Wait -PassThru "${SETUP_PATH}\vcredist_17_x64.exe" -ArgumentList "/passive /norestart"
if ($procVcredist.ExitCode -ne 0) {
    Write-DateLog "WARNING: Visual C++ Redistributable installer exited with code $($procVcredist.ExitCode)" | Write-SetupLog
}
Write-DateLog "Visual C++ Redistributable installed" | Write-SetupLog

# Install .NET 6
Update-SandboxProgress "Installing .NET 6..."
$procDotnet6 = Start-Process -Wait -PassThru "${SETUP_PATH}\dotnet6desktop.exe" -ArgumentList "/install /quiet /norestart"
if ($procDotnet6.ExitCode -ne 0) {
    Write-DateLog "WARNING: .NET 6 installer exited with code $($procDotnet6.ExitCode)" | Write-SetupLog
}
Write-DateLog ".NET 6 Desktop runtime installed" | Write-SetupLog

# Install .NET 8
Update-SandboxProgress "Installing .NET 8..."
$procDotnet8 = Start-Process -Wait -PassThru "${SETUP_PATH}\dotnet8desktop.exe" -ArgumentList "/install /quiet /norestart"
if ($procDotnet8.ExitCode -ne 0) {
    Write-DateLog "WARNING: .NET 8 installer exited with code $($procDotnet8.ExitCode)" | Write-SetupLog
}
Write-DateLog ".NET 8 Desktop runtime installed" | Write-SetupLog

# Install .NET 9
Update-SandboxProgress "Installing .NET 9..."
$procDotnet9 = Start-Process -Wait -PassThru "${SETUP_PATH}\dotnet9desktop.exe" -ArgumentList "/install /quiet /norestart"
if ($procDotnet9.ExitCode -ne 0) {
    Write-DateLog "WARNING: .NET 9 installer exited with code $($procDotnet9.ExitCode)" | Write-SetupLog
}
Write-DateLog ".NET 9 Desktop runtime installed" | Write-SetupLog

# Copy config files and import them - needed for OhMyPosh installation
Update-SandboxProgress "Importing configuration..."
if (Test-Path "${LOCAL_PATH}\config.txt") {
    Copy-Item "${LOCAL_PATH}\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\config.txt" "${WSDFIR_TEMP}\config.ps1" -Force | Out-Null
}
. "${WSDFIR_TEMP}\config.ps1"
Write-DateLog "Config files copied and imported" | Write-SetupLog

# Install OhMyPosh
Update-SandboxProgress "Installing OhMyPosh..."
Install-OhMyPosh | Write-SetupLog

# Install HxD
Update-SandboxProgress "Installing HxD..."
& "${TOOLS}\hxd\HxDSetup.exe" /VERYSILENT /NORESTART
Write-DateLog "HxD installed" | Write-SetupLog

# Install IrfanView
Update-SandboxProgress "Installing IrfanView..."
& "${SETUP_PATH}\irfanview.exe" /silent /assoc=1 | Out-Null
Write-DateLog "IrfanView installed" | Write-SetupLog

# Install Notepad++ and plugins
Update-SandboxProgress "Configuring optional editors..."
if (("${WSDFIR_NOTEPAD}" -eq "Yes") -or (Test-Path "C:\log\log.txt")) {
	& "${SETUP_PATH}\notepad++.exe" /S  | Out-Null
	Add-ToUserPath "${env:ProgramFiles}\Notepad++"
	Add-Shortcut -SourceLnk "${HOME}\Desktop\Notepad++.lnk" -DestinationPath "${env:ProgramFiles}\Notepad++\notepad++.exe"
	Write-DateLog "Notepad++ installed" | Write-SetupLog
}

# Install Neovim
if (("${WSDFIR_NEOVIM}" -eq "Yes") -or (Test-Path "C:\log\log.txt")) {
	Install-Neovim
	Write-DateLog "Neovim installed" | Write-SetupLog
}

#
# Configure the sandbox
#

# Import registry settings
reg import "${HOME}\Documents\tools\reg\registry.reg" | Out-Null
Write-DateLog "Registry settings imported" | Write-SetupLog

# PowerShell
if (Test-Path "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1") {
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
    Copy-Item "${LOCAL_PATH}\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
    Copy-Item "${LOCAL_PATH}\defaults\Microsoft.PowerShell_profile.ps1" "${HOME}\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force | Out-Null
}

# Install Terminal and link to it
Update-SandboxProgress "Install Windows Terminal..."
Expand-Archive "${SETUP_PATH}\Terminal.zip" -DestinationPath "$env:ProgramFiles\Windows Terminal" -Force | Out-Null
$TERMINAL_INSTALL_DIR = ((Get-ChildItem "$env:ProgramFiles\Windows Terminal").Name | findstr "terminal" | Select-Object -Last 1)
if (! (Test-Path "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR\settings")) {
	New-Item -Path "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR\settings" -ItemType Directory -Force | Out-Null
}
Copy-Item "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR\wt.exe" "$env:ProgramFiles\Windows Terminal\"
& "${TOOLS}\sysinternals\junction.exe" "$env:ProgramFiles\Windows Terminal\bin" "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR" | Out-Null
Copy-Item "$LOCAL_PATH\defaults\Windows_Terminal.json" "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR\settings\settings.json" -Force | Out-Null
$TERMINAL_INSTALL_LOCATION = "$env:ProgramFiles\Windows Terminal\$TERMINAL_INSTALL_DIR"

# Set date and time format
Update-SandboxProgress "Configuring date and time format..."
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortDate -value "yyyy-MM-dd" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sLongDate -value "yyyy-MMMM-dddd" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm" | Out-Null
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss" | Out-Null
Write-DateLog "Date and time format set" | Write-SetupLog

# Add right-click context menu if specified
Update-SandboxProgress "Configuring context menu and registry..."
if ("${WSDFIR_RIGHTCLICK}" -eq "Yes") {
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve | Out-Null
    Write-DateLog "Right-click context menu added" | Write-SetupLog

	# Change TERMINAL_INSTALL_DIR to actual installed version
	Get-Content "${HOME}\Documents\tools\reg\right-click.reg" |
		ForEach-Object { $_ -replace "TERMINAL_INSTALL_DIR", "${TERMINAL_INSTALL_DIR}" } |
		Set-Content "${WSDFIR_TEMP}\right-click.reg"

	reg import "${WSDFIR_TEMP}\right-click.reg" | Out-Null
	Write-DateLog "Right-click context menu registry settings imported" | Write-SetupLog
}

# Uses SystemFileAssociations so the verbs apply reliably to file types
# Uses full path to pwsh.exe (PowerShell 7)
Update-SandboxProgress "Configuring Office file associations..."
$extensions = @(
    "doc","docm","docx","dot","dotm","dotx",
    "xls","xlsm","xlsx","xlt","xltm","xltx",
    "ppt","pptm","pptx","pot","potm","potx"
)

$wtpath = "C:\\Program Files\\Windows Terminal\\${TERMINAL_INSTALL_DIR}\\wt.exe"
$cmd_mraptor = "`\`"$wtpath`\`" -w 0 C:\\Program Files\\PowerShell\\7\\pwsh.exe -NoExit -Command `\`"mraptor '%1'`\`""
$cmd_oleid   = "`\`"$wtpath`\`" -w 0 C:\\Program Files\\PowerShell\\7\\pwsh.exe -NoExit -Command `\`"oleid '%1'`\`""
$cmd_olevba  = "`\`"$wtpath`\`" -w 0 C:\\Program Files\\PowerShell\\7\\pwsh.exe -NoExit -Command `\`"olevba '%1'`\`""

$allRegistryContent = "Windows Registry Editor Version 5.00`r`n"
foreach ($extension in $extensions) {
    $baseKey = "HKEY_LOCAL_MACHINE\Software\Classes\SystemFileAssociations\.${extension}\shell\dfirws_office"
    $allRegistryContent += @"

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
}

$combinedRegPath = Join-Path $WSDFIR_TEMP "office_all.reg"
$allRegistryContent | Out-File -FilePath $combinedRegPath -Encoding ascii
reg import $combinedRegPath | Out-Null
Remove-Item -LiteralPath $combinedRegPath -Force

Write-DateLog "Office extensions added" | Write-SetupLog

# Set default editor associations for text files
Update-SandboxProgress "Configuring text editor associations..."
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
    if ($exe) {
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
    Write-DateLog "WARNING: WSDFIR_TEXT_EDITOR='$sel' but nvim.exe not found; trying Notepad++." | Write-SetupLog
    # fall through to Notepad++ below
  }

  # Notepad++ (requested or fallback from Neovim)
  $exe = Resolve-ExePath `
    -names @("notepad++.exe") `
    -fallbackPaths @(
      "$env:ProgramFiles\Notepad++\notepad++.exe",
      "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe",
      "$env:ChocolateyInstall\bin\notepad++.exe",
      "$env:LOCALAPPDATA\Programs\Notepad++\notepad++.exe"
    )
  if ($exe) {
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

  # Neither Neovim nor Notepad++ found - return $null so the caller skips associations.
  Write-DateLog "WARNING: No text editor (Neovim or Notepad++) found; skipping file associations." | Write-SetupLog
  return $null
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

if ($ed) {
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

    # Register application (helps "Choose an app" scenarios)
    New-Item -Path "HKCU:\Software\Classes\Applications\$($ed.AppExe)\shell\open\command" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\Applications\$($ed.AppExe)\shell\open\command" -Name "(default)" -Value $ed.Cmd

    # Always-available context menu entry for all files (*)
    New-Item -Path "HKCU:\Software\Classes\*\shell\$($ed.ShellKey)\command" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\*\shell\$($ed.ShellKey)\command" -Name "(default)" -Value $ed.Cmd

    # --- Apply associations (explicitly avoid .lnk) ---
    foreach ($ext in $exts) {
        Set-DefaultForExt -ext $ext -progId $ed.ProgId
    }

    Write-DateLog "Editor associations set" | Write-SetupLog
}

# Set dark theme if selected
Update-SandboxProgress "Applying theme and wallpaper..."
if ("${WSDFIR_DARK}" -eq "Yes") {
    Start-Process -Wait "c:\Windows\Resources\Themes\themeB.theme"
	Stop-Process -Name SystemSettings
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 | Out-Null
}

Update-Wallpaper "${SETUP_PATH}\dfirws.jpg"
Write-DateLog "Wallpaper updated" | Write-SetupLog

# Hide the taskbar
if ("${WSDFIR_HIDE_TASKBAR}" -eq "Yes") {
    # From https://www.itechtics.com/hide-show-taskbar/#from-windows-powershell
    &{$p='HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3';$v=(Get-ItemProperty -Path $p).Settings;$v[8]=3;&Set-ItemProperty -Path $p -Name Settings -Value $v;&Stop-Process -f -ProcessName explorer}
}

# Restart Explorer process
Update-SandboxProgress "Restarting Explorer..."
Stop-Process -ProcessName "Explorer" -Force
Write-DateLog "Explorer restarted" | Write-SetupLog

#
# Configure PATH
#
# PATH - Windows have a limit of <2048 characters for user PATH

Update-SandboxProgress "Configuring PATH environment variable..."
Write-DateLog "Add to PATH" | Write-SetupLog
$GHIDRA_INSTALL_DIR=""
if (Test-Path "${TOOLS}\ghidra\") {
    $GHIDRA_INSTALL_DIR=((Get-ChildItem "${TOOLS}\ghidra\").Name | findstr "PUBLIC" | Select-Object -Last 1)
}

$ADD_TO_PATH = @("${HOME}\Go\bin"
    "${MSYS2_DIR}"
    "${MSYS2_DIR}\ucrt64\bin"
    "${MSYS2_DIR}\usr\bin"
	"${TOOLS}\perl\perl\bin"
	"${env:ProgramFiles}\7-Zip"
	"${env:ProgramFiles}\Git\bin"
	"${env:ProgramFiles}\Git\cmd"
	"${env:ProgramFiles}\Git\usr\bin"
	"${env:ProgramFiles}\graphviz\bin"
	"${env:ProgramFiles}\hxd"
    "${env:ProgramFiles}\IDR\bin"
    "${env:ProgramFiles}\jadx\bin"
	"${env:ProgramFiles}\iisGeolocate"
	"${env:ProgramFiles}\KAPE"
	"${env:ProgramFiles}\loki"
	"${env:ProgramFiles}\RegistryExplorer"
	"${env:ProgramFiles}\ShellBagsExplorer"
	"${env:ProgramFiles}\TimelineExplorer"
	"${env:ProgramFiles}\qemu"
    "${GIT_PATH}\defender-detectionhistory-parser"
    "${GIT_PATH}\ese-analyst"
    "${GIT_PATH}\iShutdown"
    "${GIT_PATH}\libimobiledevice-windows"
    "${GIT_PATH}\Regshot"
    "${GIT_PATH}\Trawler"
    "${GIT_PATH}\White-Phoenix"
	"${RUST_DIR}\bin"
	"${TERMINAL_INSTALL_LOCATION}"
    "${TOOLS}\h2database"
    "${TOOLS}\nmap"
    "${TOOLS}\hfs"
    "${TOOLS}\VolatilityWorkbench"
    "${TOOLS}\WinApiSearch"
    "${TOOLS}\gftrace64"
    "${TOOLS}\procdot\win64"
    "${TOOLS}\systeminformer\x64"
    "${TOOLS}\systeminformer\x86"
    "${TOOLS}\XELFViewer"
    "${TOOLS}\audacity"
    "${TOOLS}\capa-ghidra"
    "${TOOLS}\elfparser-ng\Release"
    "${TOOLS}\RdpCacheStitcher"
    "${TOOLS}\AndroidSDK\platform-tools"
	"${TOOLS}\artemis"
    "${TOOLS}\AzureCLI\bin"
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
	"${TOOLS}\Zimmerman"
    "${TOOLS}\Zimmerman\EvtxECmd"
    "${TOOLS}\Zimmerman\EZViewer"
    "${TOOLS}\Zimmerman\JumpListExplorer"
    "${TOOLS}\Zimmerman\MFTExplorer"
    "${TOOLS}\Zimmerman\RECmd"
    "${TOOLS}\Zimmerman\SDBExplorer"
    "${TOOLS}\Zimmerman\SQLECmd"
    "${TOOLS}\Zimmerman\XWFIM"
	"${TOOLS}\zircolite"
	"${TOOLS}\zircolite\bin"
	"${TOOLS}\zstd"
	"${TOOLS}\YAMAGoya"
	"${VENV}\bin"
	"${HOME}\Documents\tools\utils")

$ADD_TO_PATH_STRING = $ADD_TO_PATH -join ";"

Add-MultipleToUserPath $ADD_TO_PATH_STRING

Update-SandboxProgress "Creating Desktop shortcuts..."
Write-DateLog "Start creation of Desktop/dfirws" | Write-SetupLog
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
Update-SandboxProgress "Installing Graphviz..."
& "${SETUP_PATH}\graphviz.exe" /S /D="${env:ProgramFiles}\graphviz"
Write-DateLog "Installing Graphviz done." | Write-SetupLog

# Copy files to user profile
New-Item -Path "${HOME}/ghidra_scripts" -ItemType Directory -Force | Out-Null
if (Test-Path "${SETUP_PATH}\capa_explorer.py") {
    Copy-Item "${SETUP_PATH}\capa_explorer.py" "${HOME}/ghidra_scripts/capa_explorer.py" -Force | Out-Null
}
if (Test-Path "${SETUP_PATH}\capa_ghidra.py") {
    Copy-Item "${SETUP_PATH}\capa_ghidra.py" "${HOME}/ghidra_scripts/capa_ghidra.py" -Force | Out-Null
}

# Add plugins to Cutter
Update-SandboxProgress "Installing Cutter plugins..."
New-Item -ItemType Directory -Force -Path "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" | Out-Null
Copy-Item "${GIT_PATH}\radare2-deep-graph\cutter\graphs_plugin_grid.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
Copy-Item "${SETUP_PATH}\x64dbgcutter.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
if (Test-Path "${GIT_PATH}\cutterref"){
    Copy-Item "${GIT_PATH}\cutterref\cutterref.py" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python" -Force | Out-Null
    Robocopy.exe /MT:96 /MIR "${GIT_PATH}\cutterref\archs" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\archs" | Out-Null
}
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\cutter-jupyter\icons" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\icons" | Out-Null
Robocopy.exe /MT:96 /MIR "${GIT_PATH}\capa-explorer\capa_explorer_plugin" "${HOME}\AppData\Roaming\rizin\cutter\plugins\python\capa_explorer_plugin" | Out-Null
Write-DateLog "Installed Cutter plugins." | Write-SetupLog

# BeaconHunter, IDR, and Zimmerman tools - run Robocopy copies in parallel
Update-SandboxProgress "Configuring forensic tools..."
$programFiles = $env:ProgramFiles
$robocopyJobs = @(
    Start-Job { Robocopy.exe /MT:96 /MIR "$using:TOOLS\BeaconHunter" "$using:programFiles\BeaconHunter" }
    Start-Job { Robocopy.exe /MT:96 /MIR "$using:GIT_PATH\IDR" "$using:programFiles\IDR" }
    Start-Job { Robocopy.exe /MT:96 /MIR "$using:TOOLS\Zimmerman\iisGeolocate" "$using:programFiles\iisGeolocate" }
    Start-Job { Robocopy.exe /MT:96 /MIR "$using:TOOLS\Zimmerman\RegistryExplorer" "$using:programFiles\RegistryExplorer" }
    Start-Job { Robocopy.exe /MT:96 /MIR "$using:TOOLS\Zimmerman\ShellBagsExplorer" "$using:programFiles\ShellBagsExplorer" }
    Start-Job { Robocopy.exe /MT:96 /MIR "$using:TOOLS\Zimmerman\TimelineExplorer" "$using:programFiles\TimelineExplorer" }
)
$robocopyJobs | Wait-Job | Out-Null
$robocopyJobs | Remove-Job
if (Test-Path "C:\enrichment\maxmind_current\GeoLite2-City.mmdb") {
    Copy-Item "C:\enrichment\maxmind_current\GeoLite2-City.mmdb" "${env:ProgramFiles}\iisGeolocate\" -Force | Out-Null
}

# Jupyter
Update-SandboxProgress "Configuring Jupyter..."
Robocopy.exe /MT:96 /MIR "${HOME}\Documents\tools\jupyter\.jupyter" "${HOME}\.jupyter" | Out-Null
Copy-Item "${HOME}\Documents\tools\jupyter\common.py" "${HOME}\Documents\jupyter\" -Force | Out-Null
Copy-Item "${HOME}\Documents\tools\jupyter\*.ipynb" "${HOME}\Documents\jupyter\" -Force | Out-Null

# geolocus
if (Test-Path "C:\enrichment\geolocus\.cache\geolocus-cli\geolocus.mmdb") {
    New-Item -Path "${HOME}\.cache\geolocus-cli" -ItemType Directory -Force | Out-Null
    Copy-Item "C:\enrichment\geolocus\.cache\geolocus-cli\geolocus.mmdb" "${HOME}\.cache\geolocus-cli\geolocus.mmdb" -Force | Out-Null
}

# mvt IOCs
if (Test-Path "C:\venv\iocs\mvt") {
    Robocopy.exe /MT:96 /MIR "C:\venv\iocs\mvt" "${HOME}\AppData\Local\mvt" | Out-Null
}

# 4n4lDetector
if (Test-Path "${SETUP_PATH}\4n4lDetector.zip") {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x "${SETUP_PATH}\4n4lDetector.zip" -o"${env:ProgramFiles}\4n4lDetector" | Out-Null
}

# Config for opencode-ai MCP servers
Update-SandboxProgress "Configuring opencode-ai..."
$opencode_config_dir = "${HOME}\.config\opencode"
New-Item -ItemType Directory -Force -Path "${opencode_config_dir}" | Out-Null
if (Test-Path "${LOCAL_PATH}\opencode.json") {
    Copy-Item "${LOCAL_PATH}\opencode.json" "${opencode_config_dir}\opencode.json" -Force | Out-Null
} else {
    Copy-Item "${LOCAL_PATH}\defaults\opencode.json" "${opencode_config_dir}\opencode.json" -Force | Out-Null
}

$opencode_skills_src = ""
if (Test-Path "${LOCAL_PATH}\opencode-skills") {
    $opencode_skills_src = "${LOCAL_PATH}\opencode-skills"
} elseif (Test-Path "${LOCAL_PATH}\defaults\opencode-skills") {
    $opencode_skills_src = "${LOCAL_PATH}\defaults\opencode-skills"
}

if ($opencode_skills_src -ne "") {
    $opencode_skills_dest = "${opencode_config_dir}\skills"
    New-Item -ItemType Directory -Force -Path "${opencode_skills_dest}" | Out-Null
    Robocopy.exe /MT:96 /MIR "${opencode_skills_src}" "${opencode_skills_dest}" | Out-Null
    Write-DateLog "Installed opencode-ai skills." | Write-SetupLog
} else {
    Write-DateLog "No opencode-ai skills found in local or defaults." | Write-SetupLog
}

Write-DateLog "Installed opencode-ai config." | Write-SetupLog

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

Update-SandboxProgress "Running customization script..."
if ($TARGET_ENVIRONMENT -ne "Sandbox") {
    Write-DateLog "Not running customize script since TARGET_ENVIRONMENT='$TARGET_ENVIRONMENT'." | Write-SetupLog
} elseif (Test-Path "${LOCAL_PATH}\customize.ps1") {
    Write-DateLog "Running customize script." | Write-SetupLog
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\customize.ps1" @args | Write-SetupLog
} elseif (Test-Path "${LOCAL_PATH}\customise.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\customise.ps1" @args | Write-SetupLog
    Write-DateLog "Running customise scripts done." | Write-SetupLog
} else {
    Write-DateLog "No customize scripts found, running defaults\customize-sandbox.ps1." | Write-SetupLog
    PowerShell.exe -ExecutionPolicy Bypass -File "${LOCAL_PATH}\defaults\customize-sandbox.ps1" @args | Write-SetupLog
}

#
# Start sysmon when installation is done
#

Update-SandboxProgress "Starting Sysmon..."
if ("${WSDFIR_SYSMON}" -eq "Yes") {
    & "${TOOLS}\sysinternals\Sysmon64.exe" -accepteula -i "${WSDFIR_SYSMON_CONF}" | Out-Null
}
Write-DateLog "Starting sysmon done." | Write-SetupLog

# Main setup is complete - sandbox is now usable even while background tasks finish.
Set-SandboxProgressReady

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
Update-SandboxProgress "Finalizing setup..."
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job 2>&1 | Write-SetupLog
Get-Job | Remove-Job | Out-Null

Write-DateLog "Setup done." | Write-SetupLog

While (! (Test-Path "${WSDFIR_TEMP}\dfirws_folder_done.txt")) {
    Start-Sleep -Seconds 1
}

Close-SandboxProgress

Exit 0
