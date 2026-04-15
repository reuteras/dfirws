# Install VMware Tools from attached CD-ROM (tools_mode = "attach" in Packer)
$ErrorActionPreference = 'SilentlyContinue'
$drives = @('D:', 'E:', 'F:', 'G:')
foreach ($drive in $drives) {
    $setup = Join-Path $drive 'setup64.exe'
    if (Test-Path $setup) {
        Write-Output "Installing VMware Tools from $drive"
        Start-Process -FilePath $setup -ArgumentList '/S /v "/qn REBOOT=R"' -Wait
        Write-Output "VMware Tools installation completed"
        break
    }
}
