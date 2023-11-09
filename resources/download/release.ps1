. $PSScriptRoot\common.ps1

$TOOLS=".\mount\Tools"
$SETUP_PATH=".\downloads"

Write-DateLog "Download releases from GitHub."

New-Item -ItemType Directory -Force -Path $TOOLS\bin > $null
New-Item -ItemType Directory -Force -Path $TOOLS\lib > $null

Get-GitHubRelease -repo "3lp4tr0n/BeaconHunter" -path "$SETUP_PATH\beaconhunter.zip" -match BeaconHunter.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\beaconhunter.zip" -o"$SETUP_PATH\" | Out-Null

Get-GitHubRelease -repo "activescott/lessmsi" -path "$SETUP_PATH\lessmsi.zip" -match lessmsi-v
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\lessmsi.zip" -o"$TOOLS\lessmsi" | Out-Null

Get-GitHubRelease -repo "brimdata/zui" -path "$SETUP_PATH\zui.exe" -match Zui-Setup

Get-GitHubRelease -repo "BurntSushi/ripgrep" -path "$SETUP_PATH\ripgrep.zip" -match x86_64-pc-windows-msvc
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ripgrep.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\ripgrep-* $TOOLS\ripgrep

Get-GitHubRelease -repo "c3rb3ru5d3d53c/binlex" -path "$SETUP_PATH\binlex.zip" -match windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\binlex.zip" -o"$TOOLS\bin" | Out-Null

Get-GitHubRelease -repo "cmderdev/cmder" -path "$SETUP_PATH\cmder.7z" -match cmder.7z

Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "$SETUP_PATH\dnSpy32.zip" -match win32
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dnSpy32.zip" -o"$TOOLS\dnSpy32" | Out-Null

Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "$SETUP_PATH\dnSpy64.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dnSpy64.zip" -o"$TOOLS\dnSpy64" | Out-Null

Get-GitHubRelease -repo "facebook/zstd" -path "$SETUP_PATH\zstd.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\downloads\zstd.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\zstd-* $TOOLS\zstd | Out-Null

Get-GitHubRelease -repo "gchq/CyberChef" -path "$SETUP_PATH\CyberChef.zip" -match CyberChef
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\CyberChef.zip" -o"$TOOLS\CyberChef" | Out-Null
Move-Item $TOOLS\CyberChef\CyberChef_* $TOOLS\CyberChef\CyberChef.html

Get-GitHubRelease -repo "git-for-windows/git" -path "$SETUP_PATH\git.exe" -match 64-bit.exe

Get-GitHubRelease -repo "gollum/gollum" -path "$SETUP_PATH\gollum.war" -match gollum.war
Copy-Item $SETUP_PATH\gollum.war $TOOLS\lib

Get-GitHubRelease -repo "harelsegev/INDXRipper" -path "$SETUP_PATH\indxripper.zip" -match amd64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\indxripper.zip" -o"$TOOLS\INDXRipper" | Out-Null

Get-GitHubRelease -repo "hasherezade/pe-bear" -path "$SETUP_PATH\pebear.zip" -match x64_win_vs17.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pebear.zip" -o"$TOOLS\pebear" | Out-Null

Get-GitHubRelease -repo "horsicq/DIE-engine" -path "$SETUP_PATH\die.zip" -match die_win64_portable
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\die.zip" -o"$TOOLS\die" | Out-Null

Get-GitHubRelease -repo "horsicq/XELFViewer" -path "$SETUP_PATH\XELFViewer.zip" -match win64_portable
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\XELFViewer.zip" -o"$TOOLS\XELFViewer" | Out-Null

Get-GitHubRelease -repo "java-decompiler/jd-gui" -path "$SETUP_PATH\jd-gui.zip" -match jd-gui-windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\jd-gui.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\jd-gui* $TOOLS\jd-gui

Get-GitHubRelease -repo "jqlang/jq" -path "$SETUP_PATH\jq.exe" -match win64
Copy-Item $SETUP_PATH\jq.exe $TOOLS\bin\

Get-GitHubRelease -repo "kacos2000/Jumplist-Browser" -path "$SETUP_PATH\JumplistBrowser.exe" -match JumplistBrowser.exe
Copy-Item $SETUP_PATH\JumplistBrowser.exe $TOOLS\bin\

Get-GitHubRelease -repo "kacos2000/Prefetch-Browser" -path "$SETUP_PATH\PrefetchBrowser.exe" -match PrefetchBrowser.exe
Copy-Item $SETUP_PATH\PrefetchBrowser.exe $TOOLS\bin\

Get-GitHubRelease -repo "Konloch/bytecode-viewer" -path "$SETUP_PATH\BCV.jar" -match Bytecode
Copy-Item $SETUP_PATH\BCV.jar $TOOLS\lib
Write-Output "java -Xmx3G -jar C:\Tools\lib\BCV.jar" | Out-File -Encoding "ascii" $TOOLS\bin\bcv.bat

Get-GitHubRelease -repo "lolo101/MsgViewer" -path "$SETUP_PATH\msgviewer.jar" -match msgviewer.jar
Copy-Item $SETUP_PATH\msgviewer.jar $TOOLS\lib

Get-GitHubRelease -repo "mandiant/capa" -path "$SETUP_PATH\capa-windows.zip" -match windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\capa-windows.zip" -o"$TOOLS\capa" | Out-Null

Get-GitHubRelease -repo "mandiant/flare-floss" -path "$SETUP_PATH\floss.zip" -match windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\floss.zip" -o"$TOOLS\floss" | Out-Null

Get-GitHubRelease -repo "mandiant/flare-fakenet-ng" -path "$SETUP_PATH\fakenet.zip" -match fakenet
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fakenet.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\fakenet* $TOOLS\fakenet

Get-GitHubRelease -repo "mandiant/GoReSym" -path "$SETUP_PATH\GoReSym.zip" -match GoReSym-windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\GoReSym.zip" -o"$TOOLS\GoReSym" | Out-Null
Move-Item $TOOLS\GoReSym\GoReSym_win.exe $TOOLS\GoReSym\GoReSym.exe
Remove-Item $TOOLS\GoReSym\GoReSym_lin
Remove-Item $TOOLS\GoReSym\GoReSym_mac

Get-GitHubRelease -repo "mentebinaria/elfparser-ng" -path "$SETUP_PATH\elfparser-ng.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\elfparser-ng.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\elfparser-ng* $TOOLS\elfparser-ng

Get-GitHubRelease -repo "multiprocessio/dsq" -path "$SETUP_PATH\dsq.zip" -match dsq-win
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dsq.zip" -o"$TOOLS\bin" | Out-Null

Get-GitHubRelease -repo "NationalSecurityAgency/ghidra" -path "$SETUP_PATH\ghidra.zip" -match ghidra
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ghidra.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\ghidra_* $TOOLS\ghidra

Get-GitHubRelease -repo "nccgroup/MetadataPlus" -path "$SETUP_PATH\MetadataPlus.exe" -match MetadataPlus
Copy-Item $SETUP_PATH\MetadataPlus.exe $TOOLS\bin\

Get-GitHubRelease -repo "Neo23x0/Loki" -path "$SETUP_PATH\loki.zip" -match loki

Get-GitHubRelease -repo "notepad-plus-plus/notepad-plus-plus" -path "$SETUP_PATH\notepad++.exe" -match Installer.x64.exe

Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "$SETUP_PATH\hindsight.exe" -match hindsight.exe
Copy-Item $SETUP_PATH\hindsight.exe $TOOLS\bin\

Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "$SETUP_PATH\hindsight_gui.exe" -match hindsight_gui.exe
Copy-Item $SETUP_PATH\hindsight_gui.exe $TOOLS\bin\

Get-GitHubRelease -repo "pnedev/comparePlus" -path "$SETUP_PATH\comparePlus.zip" -match x64.zip

Get-GitHubRelease -repo "PowerShell/vscode-powershell" -path "$SETUP_PATH\vscode\vscode-powershell.vsix" -match vsix

Get-GitHubRelease -repo "qpdf/qpdf" -path "$SETUP_PATH\qpdf.zip" -match msvc64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\qpdf.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\qpdf-* $TOOLS\qpdf

Get-GitHubRelease -repo "radareorg/radare2" -path "$SETUP_PATH\radare2.zip" -match w64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\radare2.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\radare2-* $TOOLS\radare2

Get-GitHubRelease -repo "rizinorg/cutter" -path "$SETUP_PATH\cutter.zip" -match Windows-x86_64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\cutter.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\cutter-* $TOOLS\cutter

Get-GitHubRelease -repo "skylot/jadx" -path "$SETUP_PATH\jadx.zip" -match jadx-1

Get-GitHubRelease -repo "Squiblydoo/debloat" -path "$SETUP_PATH\debloat.zip" -match Windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\debloat.zip" -o"$TOOLS\bin" | Out-Null

Get-GitHubRelease -repo "streetsidesoftware/vscode-spell-checker" -path "$SETUP_PATH\vscode\vscode-spell-checker.vsix" -match vsix

Get-GitHubRelease -repo "thumbcacheviewer/thumbcacheviewer" -path "$SETUP_PATH\thumbcacheviewer.zip" -match viewer_64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\thumbcacheviewer.zip" -o"$TOOLS\thumbcacheviewer" | Out-Null

Get-GitHubRelease -repo "upx/upx" -path "$SETUP_PATH\upx.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\upx.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\upx-* $TOOLS\upx

Get-GitHubRelease -repo "wader/fq" -path "$SETUP_PATH\fq.zip" -match windows_amd64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fq.zip" -o"$TOOLS\bin" | Out-Null

Get-GitHubRelease -repo "WerWolv/ImHex" -path "$SETUP_PATH\imhex.zip" -match Portable-NoGPU-x86_64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\imhex.zip" -o"$TOOLS\imhex" | Out-Null

Get-GitHubRelease -repo "WithSecureLabs/chainsaw" -path "$SETUP_PATH\chainsaw.zip" -match x86_64-pc-windows-msvc
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\chainsaw.zip" -o"$TOOLS" | Out-Null

Get-GitHubRelease -repo "VirusTotal/yara" -path "$SETUP_PATH\yara.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\yara.zip" -o"$TOOLS" | Out-Null
Move-Item $TOOLS\yara64.exe $TOOLS\bin\yara.exe
Move-Item $TOOLS\yarac64.exe $TOOLS\bin\yarac.exe

Get-GitHubRelease -repo "Yamato-Security/hayabusa" -path "$SETUP_PATH\hayabusa.zip" -match win-64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\hayabusa.zip" -o"$TOOLS\hayabusa" | Out-Null
