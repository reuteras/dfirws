param (
    [Parameter(HelpMessage = "Remove all downloaded and created files.")]
    [Switch]$All
)

# Script to clean up directories created by this tool.
Remove-Item -Recurse -Force "downloads" 2>&1 | Out-Null
Remove-Item -Recurse -Force "log" 2>&1 | Out-Null
Remove-Item -Recurse -Force "mount" 2>&1 | Out-Null
Remove-Item -Recurse -Force "packer_cache" 2>&1 | Out-Null
Remove-Item -Recurse -Force "tmp" 2>&1 | Out-Null
Remove-Item -Force ".\tools_downloaded.csv" 2>&1 | Out-Null
Remove-Item -Force ".\windows_11.pkr.hcl" 2>&1 | Out-Null

if ($All.IsPresent) {
    Remove-Item -Recurse -Force "iso" 2>&1 | Out-Null
    Remove-Item -Recurse -Force ".\Windows_11_dfirws_64-bit.vmwarevm" 2>&1 | Out-Null
    Remove-Item -Force ".\dfirws.wsb" 2>&1 | Out-Null
    Remove-Item -Force ".\network_dfirws.wsb" 2>&1 | Out-Null
}
