# Create default files and configuration

if (! (Test-Path -Path ".\dfirws.wsb")) {
    (Get-Content dfirws.wsb.template).replace('__SANDBOX__', $PSScriptRoot) | Set-Content .\dfirws.wsb
}

if (! (Test-Path -Path ".\network_dfirws.wsb")) {
    (Get-Content network_dfirws.wsb.template).replace('__SANDBOX__', $PSScriptRoot) | Set-Content .\network_dfirws.wsb
}

if (! (Test-Path -Path ".\setup\config.txt")) {
    Copy-Item ".\setup\default-config.txt" ".\setup\config.txt"
    Write-Output "Created .\tools\config.txt. Select tools to install based on your needs."
}

if (! (Test-Path -Path ".\local\customize.ps1")) {
    Copy-Item ".\local\example-customize.txt" ".\local\customize.ps1"
    Write-Output "Created .\local\customize.ps1. Customize shortcuts on desktop, wallpaper and more."
}
