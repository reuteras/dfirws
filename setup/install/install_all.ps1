$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

Write-SynchronizedLog "Install all tools in the sandbox."
Write-OutPut "Install all tools in the sandbox."
Write-SynchronizedLog ([string](dfirws-install.ps1 -Obsidian))
Write-SynchronizedLog ([string](dfirws-install.ps1 -ApiMonitor))
Write-SynchronizedLog ([string](dfirws-install.ps1 -BinaryNinja))
Write-SynchronizedLog ([string](dfirws-install.ps1 -BurpSuite))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Chrome))
Write-SynchronizedLog ([string](dfirws-install.ps1 -ClamAV))
Write-SynchronizedLog ([string](dfirws-install.ps1 -CMDer))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Dbeaver))
Write-SynchronizedLog ([string](dfirws-install.ps1 -DCode))
#dfirws-install.ps1 -Docker
Write-SynchronizedLog ([string](dfirws-install.ps1 -Dokany))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Fibratus))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Firefox))
Write-SynchronizedLog ([string](dfirws-install.ps1 -FoxitReader))
Write-SynchronizedLog ([string](dfirws-install.ps1 -FQLite))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Git))
Write-SynchronizedLog ([string](dfirws-install.ps1 -GoogleEarth))
Write-SynchronizedLog ([string](dfirws-install.ps1 -GoLang))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Gpg4win))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Hashcat))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Jadx))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Kape))
Write-SynchronizedLog ([string](dfirws-install.ps1 -LibreOffice))
Write-SynchronizedLog ([string](dfirws-install.ps1 -LogBoost))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Loki))
#Write-SynchronizedLog ([string](dfirws-install.ps1 -Maltego))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Neo4j))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Node))
#Write-SynchronizedLog ([string](dfirws-install.ps1 -OhMyPosh))
Write-SynchronizedLog ([string](dfirws-install.ps1 -PDFStreamDumper))
Write-SynchronizedLog ([string](dfirws-install.ps1 -PuTTY))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Qemu))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Ruby))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Rust))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Tor))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Veracrypt))
if (Test-Path -Path C:\venv\visualstudio.txt) {
    Write-SynchronizedLog ([string](dfirws-install.ps1 -VisualStudioBuildTools))
}
Write-SynchronizedLog ([string](dfirws-install.ps1 -VLC))
Write-SynchronizedLog ([string](dfirws-install.ps1 -VSCode))
Write-SynchronizedLog ([string](dfirws-install.ps1 -WinMerge))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Wireshark))
Write-SynchronizedLog ([string](dfirws-install.ps1 -X64Dbg))
Write-SynchronizedLog ([string](dfirws-install.ps1 -ZAProxy))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Zui))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Autopsy))

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

exit 0