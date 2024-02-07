
Write-Output "Disabling Windows Defender..."
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIntrusionPreventionSystem $true
Set-MpPreference -DisableIOAVProtection $true 
Set-MpPreference -DisableScriptScanning $true 
Set-MpPreference -SubmitSamplesConsent NeverSend
Get-Service WinDefend | Stop-Service -PassThru | Set-Service -StartupType Disabled
sc config WinDefend start= disabled
sc stop WinDefend
Remove-WindowsFeature Windows-Defender, Windows-Defender-GUI

