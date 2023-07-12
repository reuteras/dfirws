. $PSScriptRoot\common.ps1

Write-DateLog "Download releases from GitHub."

Get-GitHubRelease -repo "3lp4tr0n/BeaconHunter" -path ".\downloads\beaconhunter.zip" -match BeaconHunter.zip
Get-GitHubRelease -repo "Bioruebe/UniExtract2" -path ".\downloads\uniextract2.zip" -match UniExtract
Get-GitHubRelease -repo "brimdata/zui" -path ".\downloads\zui.exe" -match Zui-Setup
Get-GitHubRelease -repo "BurntSushi/ripgrep" -path ".\downloads\ripgrep.zip" -match x86_64-pc-windows-msvc
Get-GitHubRelease -repo "c3rb3ru5d3d53c/binlex" -path ".\downloads\binlex.zip" -match windows
Get-GitHubRelease -repo "cmderdev/cmder" -path ".\downloads\cmder.7z" -match cmder.7z
Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path ".\downloads\dnSpy32.zip" -match win32
Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path ".\downloads\dnSpy64.zip" -match win64
Get-GitHubRelease -repo "dzzie/pdfstreamdumper" -path ".\downloads\PDFStreamDumper.exe" -match PDFStreamDumper
Get-GitHubRelease -repo "dzzie/VS_LIBEMU" -path ".\downloads\scdbg.zip" -match VS_LIBEMU
Get-GitHubRelease -repo "facebook/zstd" -path ".\downloads\zstd.zip" -match win64
Get-GitHubRelease -repo "harelsegev/INDXRipper" -path ".\downloads\indxripper.zip" -match amd64.zip
Get-GitHubRelease -repo "hasherezade/pe-bear" -path ".\downloads\pebear.zip" -match x64_win_vs17.zip
Get-GitHubRelease -repo "horsicq/DIE-engine" -path ".\downloads\die.zip" -match die_win64_portable
Get-GitHubRelease -repo "gchq/CyberChef" -path ".\downloads\CyberChef.zip" -match CyberChef
Get-GitHubRelease -repo "git-for-windows/git" -path ".\downloads\git.exe" -match 64-bit.exe
Get-GitHubRelease -repo "kacos2000/Jumplist-Browser" -path ".\downloads\JumplistBrowser.exe" -match JumplistBrowser.exe
Get-GitHubRelease -repo "kacos2000/Prefetch-Browser" -path ".\downloads\PrefetchBrowser.exe" -match PrefetchBrowser.exe
Get-GitHubRelease -repo "Konloch/bytecode-viewer" -path ".\downloads\BCV.jar" -match Bytecode
Get-GitHubRelease -repo "lolo101/MsgViewer" -path ".\downloads\msgviewer.jar" -match msgviewer.jar
Get-GitHubRelease -repo "mandiant/capa" -path ".\downloads\capa-windows.zip" -match windows
Get-GitHubRelease -repo "mandiant/flare-floss" -path ".\downloads\floss.zip" -match windows
Get-GitHubRelease -repo "mandiant/flare-fakenet-ng" -path ".\downloads\fakenet.zip" -match fakenet
Get-GitHubRelease -repo "mandiant/GoReSym" -path ".\downloads\GoReSym.zip" -match GoReSym-windows
Get-GitHubRelease -repo "multiprocessio/dsq" -path ".\downloads\dsq.zip" -match dsq-win
Get-GitHubRelease -repo "NationalSecurityAgency/ghidra" -path ".\downloads\ghidra.zip" -match ghidra
Get-GitHubRelease -repo "Neo23x0/Loki" -path ".\downloads\loki.zip" -match loki
Get-GitHubRelease -repo "notepad-plus-plus/notepad-plus-plus" -path ".\downloads\notepad++.exe" -match Installer.x64.exe
Get-GitHubRelease -repo "pnedev/comparePlus" -path ".\downloads\comparePlus.zip" -match x64.zip
Get-GitHubRelease -repo "PowerShell/vscode-powershell" -path ".\downloads\vscode\vscode-powershell.vsix" -match vsix
Get-GitHubRelease -repo "qpdf/qpdf" -path ".\downloads\qpdf.zip" -match msvc64.zip
Get-GitHubRelease -repo "radareorg/radare2" -path ".\downloads\radare2.zip" -match w64.zip
Get-GitHubRelease -repo "rizinorg/cutter" -path ".\downloads\cutter.zip" -match Windows-x86_64.zip
Get-GitHubRelease -repo "Squiblydoo/debloat" -path ".\downloads\debloat.zip" -match Win64
Get-GitHubRelease -repo "stedolan/jq" -path ".\downloads\jq.exe" -match win64
Get-GitHubRelease -repo "streetsidesoftware/vscode-spell-checker" -path ".\downloads\vscode\vscode-spell-checker.vsix" -match vsix
Get-GitHubRelease -repo "thumbcacheviewer/thumbcacheviewer" -path ".\downloads\thumbcacheviewer.zip" -match viewer_64
Get-GitHubRelease -repo "upx/upx" -path ".\downloads\upx.zip" -match win64
Get-GitHubRelease -repo "wader/fq" -path ".\downloads\fq.zip" -match windows_amd64.zip
Get-GitHubRelease -repo "WithSecureLabs/chainsaw" -path ".\downloads\chainsaw.zip" -match x86_64-pc-windows-msvc
Get-GitHubRelease -repo "VirusTotal/yara" -path ".\downloads\yara.zip" -match win64
Get-GitHubRelease -repo "Yamato-Security/hayabusa" -path ".\downloads\hayabusa.zip" -match win-64
