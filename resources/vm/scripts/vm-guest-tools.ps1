$7Z_MSI_NAME = "7z2301-x64.msi"
$7z_MSI_URL = "https://www.7-zip.org/a/${7Z_MSI_NAME}"

Write-Output "Install VMware Tools"

Write-Output "Download 7-Zip MSI Needed to unzip VMware tools."

while (!( Test-Path "C:\Windows\Temp\${7Z_MSI_NAME}")) {
    curl.exe -L -o "C:\Windows\Temp\${7Z_MSI_NAME}" -s --retry 10 --retry-all-errors "${7Z_MSI_URL}"
    Start-Sleep 5
}

Write-Output "Install 7-Zip MSI"
Start-Process -Wait msiexec -ArgumentList "/i C:\Windows\Temp\${7Z_MSI_NAME} /qn /norestart"

Write-Output "Download VMware Tools"
if (!(Test-Path "C:\Windows\Temp\windows.iso")) {
    Try {
        # Disabling the progress bar speeds up IWR https://github.com/PowerShell/PowerShell/issues/2138
        $ProgressPreference = 'SilentlyContinue'
        $pageContentLinks = (Invoke-WebRequest('https://softwareupdate.vmware.com/cds/vmw-desktop/ws') -UseBasicParsing).Links | where-object {$_.href -Match "[0-9]"} | Select-Object href | ForEach-Object { $_.href.Trim('/') }
        $versionObject = $pageContentLinks | ForEach-Object{ new-object System.Version ($_) } | sort-object -Descending | select-object -First 1 -Property:Major,Minor,Build
        $newestVersion = $versionObject.Major.ToString()+"."+$versionObject.Minor.ToString()+"."+$versionObject.Build.ToString() | out-string
        $newestVersion = $newestVersion.TrimEnd("`r?`n")

        $nextURISubdirectoryObject = (Invoke-WebRequest("https://softwareupdate.vmware.com/cds/vmw-desktop/ws/$newestVersion/") -UseBasicParsing).Links | where-object {$_.href -Match "[0-9]"} | Select-Object href | where-object {$_.href -Match "[0-9]"}
        $nextUriSubdirectory = $nextURISubdirectoryObject.href | Out-String
        $nextUriSubdirectory = $nextUriSubdirectory.TrimEnd("`r?`n")
        $newestVMwareToolsURL = "https://softwareupdate.vmware.com/cds/vmw-desktop/ws/$newestVersion/$nextURISubdirectory/windows/packages/tools-windows.tar"
        Write-Output "The latest version of VMware tools has been determined to be downloadable from $newestVMwareToolsURL"
        curl.exe -L -o "C:\Windows\Temp\vmware-tools.tar" -s --retry 10 --retry-all-errors "$newestVMwareToolsURL"
    } Catch {
        Write-Output "Unable to determine the latest version of VMware tools. Falling back to hardcoded URL."
        curl.exe -L -o "C:\Windows\Temp\vmware-tools.tar" -s --retry 10 --retry-all-errors "https://softwareupdate.vmware.com/cds/vmw-desktop/ws/17.5.0/22583795//windows/packages/tools-windows.tar"
}

Write-Output "Unzip VMware TAR"

& "C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\vmware-tools.tar -oC:\Windows\Temp | Out-Null

Move-Item c:\windows\temp\VMware-tools-windows-*.iso c:\windows\temp\windows.iso

if (Test-Path "C:\Program Files (x86)\VMWare") {
    Try {
        Remove-Item "C:\Program Files (x86)\VMWare" -Recurse -Force -ErrorAction Stop
    } Catch {
        Write-Output "Directory didn't exist to be removed." }
    }
}

Write-Output "Unzip VMware ISO"
& "C:\Program Files\7-Zip\7z.exe" x "C:\Windows\Temp\windows.iso" -o"C:\Windows\Temp\VMWare" | Out-Null

Write-Output "Install VMware Tools"
Start-Process -Wait "C:\Windows\Temp\VMWare\setup.exe" -ArgumentList '/S /v"/qn REBOOT=R\"'

Write-Output "Remove temp files"
Remove-Item -Force "C:\Windows\Temp\vmware-tools.tar"
Remove-Item -Force "C:\Windows\Temp\windows.iso"
Remove-Item -Force -Recurse "C:\Windows\Temp\VMware"

Exit 0
