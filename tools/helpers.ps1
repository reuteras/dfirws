Write-Output "Start helpers.ps1"

Get-ChildItem env:* > C:\env.txt

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
        Write-Host "Added $dir to PATH"
        return
    }
    Write-Error "$dir is already in PATH"
}

function Set-Shortcut {
param ( [string]$SourceLnk, [string]$DestinationPath , [string]$WorkingDirectory)
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

# Rename folders and files
Move-Item C:\Temp\win64\densityscout.exe C:\Tools\bin\densityscout.exe
Move-Item C:\Temp\yara64.exe C:\Tools\bin\yara.exe
Move-Item C:\Temp\yarac64.exe C:\Tools\bin\yarac.exe
Move-Item "C:\Tools\exiftool\exiftool(-k).exe" C:\Tools\exiftool\exiftool.exe
Move-Item C:\Tools\cutter-* C:\Tools\cutter
Move-Item C:\Tools\CyberChef\CyberChef_* C:\Tools\CyberChef\CyberChef.html
Move-Item C:\Tools\fakenet* C:\Tools\fakenet
Move-Item C:\Tools\ghidra_* C:\Tools\ghidra
Move-Item C:\Tools\GoReSym\GoReSym_win.exe C:\Tools\GoReSym\GoReSym.exe
Move-Item C:\Tools\qpdf-* C:\Tools\qpdf
Move-Item C:\Tools\radare2-* C:\Tools\radare2
Move-Item C:\Tools\ripgrep-* C:\Tools\ripgrep
Move-Item C:\Tools\sqlite-* C:\Tools\sqlite
Move-Item C:\Tools\upx-* C:\Tools\upx
if ( $env:WSDFIR_JAVA -eq '"Yes"' ) {
    Move-Item C:\Temp\BCV.jar C:\Tools\lib
    Move-Item C:\Temp\msgviewer.jar C:\Tools\lib
    Write-Output "java -Xmx3G -jar C:\Tools\lib\BCV.jar" | Out-File -Encoding "ascii" C:\Tools\bin\bcv.bat
}

# Remove unused
Remove-Item C:\Tools\GoReSym\GoReSym_lin
Remove-Item C:\Tools\GoReSym\GoReSym_mac
Remove-Item -r C:\Temp\win32
Remove-Item -r C:\Temp\win64

# Remove rules specific to Loki and Thor
Remove-Item C:\temp\yararules\generic_anomalies.yar
Remove-Item C:\temp\yararules\general_cloaking.yar
Remove-Item C:\temp\yararules\gen_webshells_ext_vars.yar
Remove-Item C:\temp\yararules\thor_inverse_matches.yar
Remove-Item C:\temp\yararules\yara_mixed_ext_vars.yar
Remove-Item C:\temp\yararules\configured_vulns_ext_vars.yar

# Combine rules to one file
$content = Get-ChildItem C:\temp\yararules\ | Get-Content -raw
[IO.File]::WriteAllLines("C:\Tools\signature.yar", $content)

Write-Output "Add to PATH"
Add-ToUserPath "C:\Program Files\7-Zip"
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
Add-ToUserPath "C:\Tools\GoReSym"
Add-ToUserPath "C:\Tools\loki"
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

Write-Output "Add shortcuts (shorten link names first)"
REG ADD "HKU\%1\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "link" /t REG_BINARY /d 00000000 /f
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\bash.lnk" "C:\Program Files\Git\bin\bash.exe" "C:\Users\WDAGUtilityAccount\Desktop"
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\CyberChef.lnk" "C:\Tools\CyberChef\CyberChef.html"
if ( $env:WSDFIR_CMDER -eq '"Yes"' ) {
    Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\cmder.lnk" "C:\Tools\cmder\cmder.exe" "C:\Users\WDAGUtilityAccount\Desktop"
}
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\Cutter.lnk" "C:\Tools\cutter\cutter.exe"
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\dnSpy.lnk" "C:\Tools\dnSpy\dnSpy.exe"
if ( $env:WSDFIR_JAVA -eq '"Yes"' ) {
    Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\ghidraRun.lnk" "C:\Tools\ghidra\ghidraRun.bat"
}
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\HxD.lnk" "C:\Program Files\HxD\HxD.exe"
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\Malcat.lnk" "C:\Tools\Malcat\bin\malcat.exe"
if ( $env:WSDFIR_JAVA -eq '"Yes"' ) {
    Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\msgviewer.lnk" "C:\Tools\lib\msgviewer.jar"
}
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\Notepad++.lnk" "C:\Program Files\Notepad++\notepad++.exe"
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\PE-bear.lnk" "C:\Tools\pebear\PE-bear.exe"
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\pestudio.lnk" "C:\Tools\pestudio\pestudio\pestudio.exe"
Copy-Item "C:\Users\WDAGUtilityAccount\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Windows PowerShell\Windows PowerShell.lnk" "C:\Users\WDAGUtilityAccount\Desktop\PowerShell.lnk"
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\Tools.lnk" "C:\Tools"
Set-Shortcut "C:\Users\WDAGUtilityAccount\Desktop\x64dbg.lnk" "C:\Tools\x64dbg\release\x64\x64dbg.exe"

# PowerShell
Copy-Item "C:\Users\WDAGUtilityAccount\Documents\tools\Microsoft.PowerShell_profile.ps1" "C:\Users\WDAGUtilityAccount\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType Directory $PSHome\Modules\PSDecode
Copy-Item "C:\Users\WDAGUtilityAccount\Documents\tools\utils\PSDecode.psm1" "$PSHome\Modules\PSDecode"

Write-Output "Hide file extensions"
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt /v DefaultValue /t REG_DWORD /d 0 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL /v DefaultValue /t REG_DWORD /d 1 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 1 /f

REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt /v DefaultValue /t REG_DWORD /d 0 /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL /v DefaultValue /t REG_DWORD /d 1 /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 0 /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowSuperHidden /t REG_DWORD /d 1 /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 1 /f

# Copy signatures
Copy-Item -r "C:\Users\WDAGUtilityAccount\Documents\tools\downloads\git\signature-base" C:\Tools\loki\signature-base

New-Item -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force
Set-ItemProperty -Path HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Name EnableScriptBlockLogging -Value 1 -Force

# Add cmder integration
if ( $env:WSDFIR_CMDER -eq '"Yes"' ) {
    Add-ToUserPath "C:\Tools\cmder"
    Add-ToUserPath "C:\Tools\cmder\bin"
    Write-Output "C:\venv\scripts\activate.bat" | Out-File -Append -Encoding "ascii" C:\Tools\cmder\config\user_profile.cmd
    C:\Tools\cmder\cmder.exe /REGISTER ALL
}

# Install Python pip packages
if ( $env:WSDFIR_PYTHON_PIP -eq '"Yes"' ) {
    Write-Output "Change background to python"
    PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\Update-Wallpaper.ps1 C:\Users\WDAGUtilityAccount\Documents\tools\downloads\python.png
    $shell = New-Object -ComObject "Shell.Application"
    $shell.sendkeys('{F5}')
    PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\install_python_tools.ps1
    Copy-Item "C:\Users\WDAGUtilityAccount\Documents\tools\utils\powershell-cleanup.py" "C:\venv\Scripts\"
    # Configure usage of new venv for PowerShell
    (Get-ChildItem -File C:\venv\Scripts\).Name | findstr /R /V "[\._]" | findstr /V activate | `
        ForEach-Object {Write-Output "function $_() { python C:\venv\Scripts\$_ `$PsBoundParameters.Values + `$args }"} | Out-File -Append -Encoding "ascii" "C:\Users\WDAGUtilityAccount\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

Stop-Process -ProcessName Explorer -Force

# Signal that everything is done.
Copy-Item "C:\Users\WDAGUtilityAccount\Documents\tools\downloads\README.md" "C:\Users\WDAGUtilityAccount\Desktop\"
PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\WDAGUtilityAccount\Documents\tools\Update-Wallpaper.ps1 C:\temp\sans.jpg
C:\Tools\sysinternals\Bginfo64.exe /NOLICPROMPT /timer:0 C:\Users\WDAGUtilityAccount\Documents\tools\config.bgi
Write-Output "helpers.ps1 done."