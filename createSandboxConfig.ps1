(Get-Content sandbox_clean_no_network.wsb.template).replace('__SANDBOX__', $PSScriptRoot) | Set-Content .\sandbox_clean_no_network.wsb
(Get-Content sandbox_tools_no_network.wsb.template).replace('__SANDBOX__', $PSScriptRoot) | Set-Content .\sandbox_tools_no_network.wsb

if (! (Test-Path -Path .\setup\config.txt)) {
    Copy-Item .\setup\default-config.txt .\setup\config.txt
    Write-Output "Created .\tools\config.txt. Select tools to install based on your needs."
}
