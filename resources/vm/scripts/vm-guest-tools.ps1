$7Z_MSI_NAME = "7z2301-x64.msi"
$7z_MSI_URL = "https://www.7-zip.org/a/${7Z_MSI_NAME}"

Write-Output "Install VMware Tools"

Write-Output "Download 7-Zip MSI needed to extract VMware Tools ISO."
curl.exe -L -o "C:\Windows\Temp\${7Z_MSI_NAME}" -s --retry 10 --retry-all-errors "${7Z_MSI_URL}"

Write-Output "Install 7-Zip MSI"
Start-Process -Wait msiexec -ArgumentList "/i C:\Windows\Temp\${7Z_MSI_NAME} /qn /norestart"

Write-Output "Download VMware Tools ISO"
$vmwareToolsBaseUrl = "https://packages.vmware.com/tools/releases/latest/windows/"
$listPage = (Invoke-WebRequest -Uri $vmwareToolsBaseUrl -UseBasicParsing).Content
$isoName = [regex]::Match($listPage, 'href="(VMware-tools-windows[^"]+\.iso)"').Groups[1].Value
if (-not $isoName) {
    Write-Output "ERROR: Could not determine VMware Tools ISO filename from $vmwareToolsBaseUrl"
    Exit 1
}
$vmwareToolsIso = "C:\Windows\Temp\vmware-tools.iso"
curl.exe -L -o "$vmwareToolsIso" -s --retry 10 --retry-all-errors "${vmwareToolsBaseUrl}${isoName}"

Write-Output "Extract VMware Tools ISO"
& "C:\Program Files\7-Zip\7z.exe" x "$vmwareToolsIso" -o"C:\Windows\Temp\VMWare" | Out-Null

Write-Output "Install VMware Tools"
Start-Process -Wait "C:\Windows\Temp\VMWare\setup64.exe" -ArgumentList '/S /v "/qn REBOOT=R"'

Write-Output "Remove temp files"
Remove-Item -Force "C:\Windows\Temp\${7Z_MSI_NAME}"
Remove-Item -Force "$vmwareToolsIso"
Remove-Item -Force -Recurse "C:\Windows\Temp\VMware"

Exit 0
