Write-Output "Customizing the VM"

. "${HOME}\Documents\tools\wscommon.ps1"

$OriginalPref = $ProgressPreference # Default is 'Continue'
$ProgressPreference = "SilentlyContinue"

Write-Output "Fix sticky keys"
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f

Write-Output "Enlarge Windows Event Security Log Size"
wevtutil sl Security /ms:1024000
wevtutil sl Application /ms:1024000
wevtutil sl System /ms:1024000
wevtutil sl "Windows Powershell" /ms:1024000
wevtutil sl "Microsoft-Windows-PowerShell/Operational" /ms:1024000

Write-Output "Enable Windows Event Detailed Logging"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f | Out-Null

Auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable | Out-Null
Auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable | Out-Null
Auditpol /set /subcategory:"Logoff" /success:enable /failure:disable | Out-Null
Auditpol /set /subcategory:"Logon" /success:enable /failure:enable | Out-Null
Auditpol /set /subcategory:"Filtering Platform Connection" /success:enable /failure:disable | Out-Null
Auditpol /set /subcategory:"Removable Storage" /success:enable /failure:enable | Out-Null
Auditpol /set /subcategory:"SAM" /success:disable /failure:disable | Out-Null
Auditpol /set /subcategory:"Filtering Platform Policy Change" /success:disable /failure:disable | Out-Null
Auditpol /set /subcategory:"IPsec Driver" /success:enable /failure:enable | Out-Null
Auditpol /set /subcategory:"Security State Change" /success:enable /failure:enable | Out-Null
Auditpol /set /subcategory:"Security System Extension" /success:enable /failure:enable | Out-Null
Auditpol /set /subcategory:"System Integrity" /success:enable /failure:enable | Out-Null

Write-Output "Uninstall common extra apps found on a lot of Win11 installs"
Get-AppxPackage *Microsoft.BingNews* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.BingWeather* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.GetHelp* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.Getstarted* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.Microsoft3DViewer* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.MicrosoftOfficeHub* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.MicrosoftSolitaireCollection* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.Xbox.TCUI* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxApp* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxGameOverlay* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxGamingOverlay* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxIdentityProvider* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxSpeechToTextOverlay* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.XboxTCUI* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.YourPhone* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.WindowsFeedback* -AllUsers | Remove-AppxPackage
Get-AppxPackage *Microsoft.WindowsFeedbackHub* -AllUsers | Remove-AppxPackage

Write-Output "Uninstall OneDrive"
taskkill /f /im OneDrive.exe | Out-Null
& "$env:SystemRoot\System32\OneDriveSetup.exe" /uninstall

Write-Output "Install extra apps"
dfirws-install.ps1 -Autopsy
dfirws-install.ps1 -Dokany
dfirws-install.ps1 -Kape
dfirws-install.ps1 -LibreOffice
dfirws-install.ps1 -Loki
dfirws-install.ps1 -Obsidian
dfirws-install.ps1 -OhMyPosh
dfirws-install.ps1 -Qemu
dfirws-install.ps1 -Wireshark
dfirws-install.ps1 -X64dbg
dfirws-install.ps1 -Zui

# Problems with virtualization in Workstation
#wsl.exe --install -d Kali-Linux --no-launch
#wsl.exe --set-version Kali-Linux 2
#dfirws-install.ps1 -Docker

Write-Output "Install Meslo font for Oh-My-Posh"
oh-my-posh.exe font install Meslo

Write-Output "Add auto start shortcut to open dfirws folder"
Add-Shortcut "${HOME}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\dfirws.lnk" -DestinationPath "${HOME}\Desktop\dfirws"

Write-Output "Set Windows Theme to Dark"
& "c:\Windows\Resources\Themes\themeB.theme" || Write-Output "ERROR: Failed to set theme to dark"
Update-Wallpaper "${SETUP_PATH}\dfirws.jpg"

$ProgressPreference = $OriginalPref
