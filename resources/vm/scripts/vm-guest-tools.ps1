if (!( Test-Path "C:\Windows\Temp\7z2301-x64.msi")) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z2301-x64.msi', 'C:\Windows\Temp\7z2301-x64.msi')
 }

if (!(Test-Path "C:\Windows\Temp\7z2301-x64.msi")) {
    Start-Sleep 5; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z2301-x64.msi', 'C:\Windows\Temp\7z2301-x64.msi')
}

cmd /c msiexec /qb /i C:\Windows\Temp\7z2301-x64.msi
  
Write-Output "Using VMware"

if (Test-Path "C:\Users\dfirws\windows.iso") {
    Move-Item -force C:\Users\dfirws\windows.iso C:\Windows\Temp
}
  
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
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile("$newestVMwareToolsURL", 'C:\Windows\Temp\vmware-tools.tar')
    } Catch {
        Write-Output "Unable to determine the latest version of VMware tools. Falling back to hardcoded URL."
        (New-Object System.Net.WebClient).DownloadFile('https://softwareupdate.vmware.com/cds/vmw-desktop/ws/15.5.5/16285975/windows/packages/tools-windows.tar', 'C:\Windows\Temp\vmware-tools.tar')
}

cmd /c "C:\PROGRA~1\7-Zip\7z.exe" x C:\Windows\Temp\vmware-tools.tar -oC:\Windows\Temp 

Move-Item c:\windows\temp\VMware-tools-windows-*.iso c:\windows\temp\windows.iso

if (Test-Path "C:\Program Files (x86)\VMWare") {
    Try {
        Remove-Item "C:\Program Files (x86)\VMWare" -Recurse -Force -ErrorAction Stop
    } Catch { 
        Write-Output "Directory didn't exist to be removed." }
    }
}

Write-Output "Unzip VMware ISO"
cmd /c "C:\PROGRA~1\7-Zip\7z.exe" x "C:\Windows\Temp\windows.iso" -o"C:\Windows\Temp\VMWare"

Write-Output "Install VMware Tools"
cmd /c C:\Windows\Temp\VMWare\setup.exe /S /v"/qn REBOOT=R\"

Write-Output "Remove temp files"
#Remove-Item -Force "C:\Windows\Temp\vmware-tools.tar"
#Remove-Item -Force "C:\Windows\Temp\windows.iso"
#Remove-Item -Force -Recurse "C:\Windows\Temp\VMware"

Exit 0
