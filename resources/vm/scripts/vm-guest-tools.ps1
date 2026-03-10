$7Z_MSI_NAME = "7z2301-x64.msi"
$7z_MSI_URL = "https://www.7-zip.org/a/${7Z_MSI_NAME}"

Write-Output "Install VMware Tools"

Write-Output "Download 7-Zip MSI needed to extract VMware Tools ISO."
curl.exe -L -o "C:\Windows\Temp\${7Z_MSI_NAME}" -s --retry 10 --retry-all-errors "${7Z_MSI_URL}"

Write-Output "Install 7-Zip MSI"
Start-Process -Wait msiexec -ArgumentList "/i C:\Windows\Temp\${7Z_MSI_NAME} /qn /norestart"

# Packer uploads the VMware Tools ISO from the host via tools_upload_flavor = "windows"
$vmwareToolsIso = "C:\Windows\Temp\vmware-tools.iso"

if (!(Test-Path $vmwareToolsIso)) {
    Write-Output "ERROR: VMware Tools ISO not found at $vmwareToolsIso. Packer tools_upload_flavor may not be configured."
    Exit 1
}

Write-Output "Extract VMware Tools ISO"
& "C:\Program Files\7-Zip\7z.exe" x "$vmwareToolsIso" -o"C:\Windows\Temp\VMWare" | Out-Null

Write-Output "Install VMware Tools"
Start-Process -Wait "C:\Windows\Temp\VMWare\setup.exe" -ArgumentList '/S /v"/qn REBOOT=R\"'

Write-Output "Remove temp files"
Remove-Item -Force "C:\Windows\Temp\${7Z_MSI_NAME}"
Remove-Item -Force "$vmwareToolsIso"
Remove-Item -Force -Recurse "C:\Windows\Temp\VMware"

Exit 0
