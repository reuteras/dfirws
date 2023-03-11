Write-Output "Start helpers.ps1"

# Declare helper functions
function Add-ToUserPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $dir
    )

    $dir = (Resolve-Path $dir)

    $path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    if (!($path.Contains($dir))) {
        # append dir to path
        [Environment]::SetEnvironmentVariable("PATH", $path + ";$dir", [EnvironmentVariableTarget]::User)
        Write-Output "Added $dir to PATH"
        return
    }
    Write-Error "$dir is already in PATH"
}

function Add-Shortcut {
    param (
        [string]$SourceLnk,
        [string]$DestinationPath,
        [string]$WorkingDirectory
    )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($SourceLnk)
    if ($WorkingDirectory -ne $Null) {
        $Shortcut.WorkingDirectory = $WorkingDirectory
    }
    $Shortcut.TargetPath = $DestinationPath
    $Shortcut.Save()
}

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortDate -value "yyyy-MM-dd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sLongDate -value "yyyy-MMMM-dddd"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sShortTime -value "HH:mm"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -name sTimeFormat -value "HH:mm:ss"

Write-Output "Show file extensions"
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt /v DefaultValue /t REG_DWORD /d 0 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL /v DefaultValue /t REG_DWORD /d 1 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 1 /f

if ( $env:WSDFIR_RIGHTCLICK -eq '"Yes"' ) {
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
}

reg import C:\Users\WDAGUtilityAccount\Documents\tools\registry.reg

Stop-Process -ProcessName Explorer -Force

Write-Output "Add to PATH"
Add-ToUserPath "C:\Program Files\7-Zip"
Add-ToUserPath "C:\Program Files\bin"
Add-ToUserPath "C:\Program Files\Git\bin"
Add-ToUserPath "C:\Program Files\hxd"
Add-ToUserPath "C:\Program Files\Notepad++\"
Add-ToUserPath "C:\Tools\bin"
Add-ToUserPath "C:\Tools\capa"
Add-ToUserPath "C:\Tools\chainsaw"
Add-ToUserPath "C:\Tools\DidierStevens"
Add-ToUserPath "C:\Tools\exiftool"
Add-ToUserPath "C:\Tools\fakenet"
Add-ToUserPath "C:\Tools\floss"
Add-ToUserPath "C:\Tools\FullEventLogView"
Add-ToUserPath "C:\Tools\GoReSym"
Add-ToUserPath "C:\Tools\hayabusa"
Add-ToUserPath "C:\Tools\malcat\bin"
Add-ToUserPath "C:\Tools\nmap"
Add-ToUserPath "C:\Tools\qpdf\bin"
Add-ToUserPath "C:\Tools\radare2"
Add-ToUserPath "C:\Tools\ripgrep"
Add-ToUserPath "C:\Tools\scdbg"
Add-ToUserPath "C:\Tools\sqlite"
Add-ToUserPath "C:\Tools\sysinternals"
Add-ToUserPath "C:\Tools\thumbcacheviewer"
Add-ToUserPath "C:\Tools\trid"
Add-ToUserPath "C:\Tools\upx"
Add-ToUserPath "C:\Tools\x64dbg\release\x64"
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
if ( $env:WSDFIR_UNIEXTRACT -eq '"Yes"' ) {
    Add-ToUserPath "C:\Tools\UniExtract"
}

Write-Output "Add shortcuts (shorten link names first)"
REG ADD "HKU\%1\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d 00000000 /f
if ( $env:WSDFIR_BEACONHUNTER -eq '"Yes"' ) {
    Copy-Item $env:SETUP_PATH\BeaconHunter.exe "C:\Program Files\bin"
}
if ( $env:WSDFIR_GIT -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\bash.lnk" -DestinationPath "C:\Program Files\Git\bin\bash.exe" -WorkingDirectory "C:\Users\WDAGUtilityAccount\Desktop"
}
if ( $env:WSDFIR_CYBERCHEF -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\CyberChef.lnk" -DestinationPath "C:\Tools\CyberChef\CyberChef.html"
}
if ( $env:WSDFIR_CMDER -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\cmder.lnk" -DestinationPath "C:\Tools\cmder\cmder.exe" -WorkingDirectory "C:\Users\WDAGUtilityAccount\Desktop"
}
if ( $env:WSDFIR_CUTTER -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\Cutter.lnk" -DestinationPath "C:\Tools\cutter\cutter.exe"
}
if ( $env:WSDFIR_DNSPY32 -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\dnSpy32.lnk" -DestinationPath "C:\Tools\dnSpy32\dnSpy.exe"
}
if ( $env:WSDFIR_DNSPY64 -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\dnSpy64.lnk" -DestinationPath "C:\Tools\dnSpy64\dnSpy.exe"
}
if ( $env:WSDFIR_FLV -eq '"Yes"') {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\FullEventLogView.lnk" -DestinationPath "C:\Tools\FullEventLogView\FullEventLogView.exe"
}
if ( $env:WSDFIR_JAVA -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\ghidraRun.lnk" -DestinationPath "C:\Tools\ghidra\ghidraRun.bat"
}
if ( $env:WSDFIR_HXD -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\HxD.lnk" -DestinationPath "C:\Program Files\HxD\HxD.exe"
}
if ( $env:WSDFIR_MALCAT -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\Malcat.lnk" -DestinationPath "C:\Tools\Malcat\bin\malcat.exe"
}
if ( $env:WSDFIR_JAVA -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\msgviewer.lnk" -DestinationPath "C:\Tools\lib\msgviewer.jar"
}
if ( $env:WSDFIR_NPP -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\Notepad++.lnk" -DestinationPath "C:\Program Files\Notepad++\notepad++.exe"
}
if ( $env:WSDFIR_PEBEAR -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\PE-bear.lnk" -DestinationPath "C:\Tools\pebear\PE-bear.exe"
}
if ( $env:WSDFIR_PESTUDIO -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\pestudio.lnk" -DestinationPath "C:\Tools\pestudio\pestudio\pestudio.exe"
}
Copy-Item "C:\Users\WDAGUtilityAccount\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk" "C:\Users\WDAGUtilityAccount\Desktop\PowerShell.lnk"
if ( $env:WSDFIR_TOOLS -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\Tools.lnk" -DestinationPath "C:\Tools"
}
if ( $env:WSDFIR_X64DBG -eq '"Yes"' ) {
    Add-Shortcut -SourceLnk "C:\Users\WDAGUtilityAccount\Desktop\x64dbg.lnk" -DestinationPath "C:\Tools\x64dbg\release\x64\x64dbg.exe"
}

# PowerShell
Copy-Item "C:\Users\WDAGUtilityAccount\Documents\tools\Microsoft.PowerShell_profile.ps1" "C:\Users\WDAGUtilityAccount\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType Directory $PSHome\Modules\PSDecode
Copy-Item "C:\Users\WDAGUtilityAccount\Documents\tools\utils\PSDecode.psm1" "$PSHome\Modules\PSDecode"

New-Item -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Name EnableScriptBlockLogging -Value 1 -Force

# Add cmder
if ( $env:WSDFIR_CMDER -eq '"Yes"' ) {
    Add-ToUserPath "C:\Tools\cmder"
    Add-ToUserPath "C:\Tools\cmder\bin"
    Write-Output "C:\venv\scripts\activate.bat" | Out-File -Append -Encoding "ascii" C:\Tools\cmder\config\user_profile.cmd
    C:\Tools\cmder\cmder.exe /REGISTER ALL
}

# Add PersistenceSniper

if ( $env:WSDFIR_PERSISTENCESNIPER -eq '"Yes"' ) {
    Import-Module C:\git\PersistenceSniper\PersistenceSniper\PersistenceSniper.psd1
}

# Configure usage of new venv for PowerShell
(Get-ChildItem -File C:\venv\Scripts\).Name | findstr /R /V "[\._]" | findstr /V activate | `
    ForEach-Object {Write-Output "function $_() { python C:\venv\Scripts\$_ `$PsBoundParameters.Values + `$args }"} | Out-File -Append -Encoding "ascii" "C:\Users\WDAGUtilityAccount\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Signal that everything is done to start using the tools (mostly).
Copy-Item "C:\downloads\README.md" "C:\Users\WDAGUtilityAccount\Desktop\"
PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\Update-Wallpaper.ps1 C:\downloads\dfirws.jpg
C:\Tools\sysinternals\Bginfo64.exe /NOLICPROMPT /timer:0 C:\Users\WDAGUtilityAccount\Documents\tools\config.bgi

if ( $env:WSDFIR_CHOCO -eq '"Yes"' ) {
    & "C:\downloads\choco\tools\chocolateyInstall.ps1"
    # Add packages below
}

# Run any custom scripts
if (Test-Path "C:\local\customize.ps1") {
    PowerShell.exe -ExecutionPolicy Bypass -File "C:\local\customize.ps1"
}

# Last commands
if ( $env:WSDFIR_X64DBG -eq '"Yes"' ) {
    & "C:\Program Files\7-Zip\7z.exe" x -aoa "C:\downloads\loki.zip" -o"C:\Program Files\"
    Remove-Item -Recurse -Force "$env:TOOLS\loki\signature-base"
    Add-ToUserPath "C:\Program Files\loki"
    Copy-Item -r ".\mount\git\signature-base" $TOOLS\loki\signature-base
} else {
    mkdir "C:\Program Files\loki"
}
& "C:\Program Files\7-Zip\7z.exe" x -pinfected "C:\downloads\signature.7z" -o"C:\Program Files\loki"
Move-Item "C:\Program Files\loki\signature.yara" "C:\data"
& "C:\Program Files\7-Zip\7z.exe" x -pinfected "C:\downloads\total.7z" -o"C:\data"

# Start sysmon when installation is done
if ( $env:WSDFIR_SYSMON -eq '"Yes"' ) {
    & "$env:TOOLS\sysinternals\Sysmon64.exe" -accepteula -i "$env:WSDFIR_SYSMON_CONF"
}

Write-Output "helpers.ps1 done"
