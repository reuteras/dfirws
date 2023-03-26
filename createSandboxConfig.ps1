# Create default files and configuration
(Get-Content dfirws.wsb.template).replace('__SANDBOX__', $PSScriptRoot) | Set-Content .\dfirws.wsb
(Get-Content network_dfirws.wsb.template).replace('__SANDBOX__', $PSScriptRoot) | Set-Content .\network_dfirws.wsb

if (! (Test-Path -Path .\setup\config.txt)) {
    Copy-Item .\setup\default-config.txt .\setup\config.txt
    Write-Output "Created .\tools\config.txt. Select tools to install based on your needs."
}
