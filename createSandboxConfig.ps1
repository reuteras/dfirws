# Create default files and configuration

if (! (Test-Path -Path ".\dfirws.wsb")) {
    (Get-Content dfirws.wsb.template).replace('__SANDBOX__', $PSScriptRoot) | Set-Content .\dfirws.wsb
}

if (! (Test-Path -Path ".\network_dfirws.wsb")) {
    (Get-Content network_dfirws.wsb.template).replace('__SANDBOX__', $PSScriptRoot) | Set-Content .\network_dfirws.wsb
}
