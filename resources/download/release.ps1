Write-Host "Download releases from GitHub."

. $PSScriptRoot\common.ps1

Function Get-GitHubRelease {
    Param (
        [string]$repo,
        [string]$path,
        [string]$match
    )

    $releases = "https://api.github.com/repos/$repo/releases/latest"

    $downloads = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].assets.browser_download_url
    if ( ( Write-Output $downloads | Measure-Object -word ).Words -gt 1 ) {
        $url = Write-Output $downloads | findstr /R $match | findstr /R /V "darwin sig"
    } else {
        $url = $downloads
    }

    Write-Output "Using $url for $repo." >> .\log\log.txt
    Get-FileFromUri -uri $url -FilePath $path
}

Try {
    Get-GitHubRelease -repo "BurntSushi/ripgrep" -path ".\tools\downloads\ripgrep.zip" -match x86_64-pc-windows-msvc
    Get-GitHubRelease -repo "cmderdev/cmder" -path ".\tools\downloads\cmder.7z" -match cmder.7z
    Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path ".\tools\downloads\dnSpy.zip" -match win64
    Get-GitHubRelease -repo "dzzie/pdfstreamdumper" -path ".\tools\downloads\PDFStreamDumper.exe" -match PDFStreamDumper
    Get-GitHubRelease -repo "dzzie/VS_LIBEMU" -path ".\tools\downloads\scdbg.zip" -match VS_LIBEMU
    Get-GitHubRelease -repo "hasherezade/pe-bear" -path ".\tools\downloads\pebear.zip" -match x64_win_vs17.zip
    Get-GitHubRelease -repo "gchq/CyberChef" -path ".\tools\downloads\CyberChef.zip" -match CyberChef
    Get-GitHubRelease -repo "git-for-windows/git" -path ".\tools\downloads\git.exe" -match 64-bit.exe
    Get-GitHubRelease -repo "Konloch/bytecode-viewer" -path ".\tools\downloads\BCV.jar" -match Bytecode
    Get-GitHubRelease -repo "lolo101/MsgViewer" -path ".\tools\downloads\msgviewer.jar" -match msgviewer.jar
    Get-GitHubRelease -repo "mandiant/capa" -path ".\tools\downloads\capa-windows.zip" -match windows
    Get-GitHubRelease -repo "mandiant/flare-floss" -path ".\tools\downloads\floss.zip" -match windows
    Get-GitHubRelease -repo "mandiant/flare-fakenet-ng" -path ".\tools\downloads\fakenet.zip" -match fakenet
    Get-GitHubRelease -repo "mandiant/GoReSym" -path ".\tools\downloads\GoReSym.zip" -match GoReSym
    Get-GitHubRelease -repo "NationalSecurityAgency/ghidra" -path ".\tools\downloads\ghidra.zip" -match ghidra
    Get-GitHubRelease -repo "Neo23x0/Loki" -path ".\tools\downloads\loki.zip" -match loki
    Get-GitHubRelease -repo "notepad-plus-plus/notepad-plus-plus" -path ".\tools\downloads\notepad++.exe" -match Installer.x64.exe
    Get-GitHubRelease -repo "pnedev/comparePlus" -path ".\tools\downloads\comparePlus.zip" -match x64.zip
    Get-GitHubRelease -repo "qpdf/qpdf" -path ".\tools\downloads\qpdf.zip" -match msvc64.zip
    Get-GitHubRelease -repo "radareorg/radare2" -path ".\tools\downloads\radare2.zip" -match w64.zip
    Get-GitHubRelease -repo "rizinorg/cutter" -path ".\tools\downloads\cutter.zip" -match Windows-x86_64.zip
    Get-GitHubRelease -repo "stedolan/jq" -path ".\tools\downloads\jq.exe" -match win64
    Get-GitHubRelease -repo "thumbcacheviewer/thumbcacheviewer" -path ".\tools\downloads\thumbcacheviewer.zip" -match viewer_64
    Get-GitHubRelease -repo "upx/upx" -path ".\tools\downloads\upx.zip" -match win64
    Get-GitHubRelease -repo "WithSecureLabs/chainsaw" -path ".\tools\downloads\chainsaw.zip" -match x86_64-pc-windows-msvc
    Get-GitHubRelease -repo "VirusTotal/yara" -path ".\tools\downloads\yara.zip" -match win64
}
Catch {
    $error[0] | Format-List * -force
}