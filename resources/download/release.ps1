. $PSScriptRoot\common.ps1

New-Item -ItemType Directory -Force -Path $TOOLS\bin > $null
New-Item -ItemType Directory -Force -Path $TOOLS\lib > $null

# BeaconHunter
Get-GitHubRelease -repo "3lp4tr0n/BeaconHunter" -path "$SETUP_PATH\beaconhunter.zip" -match BeaconHunter.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\beaconhunter.zip" -o"$SETUP_PATH\" | Out-Null

# 4n4lDetector
Get-GitHubRelease -repo "4n0nym0us/4n4lDetector" -path "$SETUP_PATH\4n4lDetector.zip" -match 4n4lDetector
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\4n4lDetector.zip" -o"$TOOLS\4n4lDetector" | Out-Null

# aLEAPP
Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "$SETUP_PATH\aleapp.exe" -match aleapp.exe
Copy-Item $SETUP_PATH\aleapp.exe $TOOLS\bin\
Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "$SETUP_PATH\aleappGUI.exe" -match aleappGUI.exe
Copy-Item $SETUP_PATH\aleappGUI.exe $TOOLS\bin\

# iLEAPP
Get-GitHubRelease -repo "abrignoni/iLEAPP" -path "$SETUP_PATH\ileapp.exe" -match ileapp.exe
Copy-Item $SETUP_PATH\ileapp.exe $TOOLS\bin\
Get-GitHubRelease -repo "abrignoni/iLEAPP" -path "$SETUP_PATH\ileappGUI.exe" -match ileappGUI.exe
Copy-Item $SETUP_PATH\ileappGUI.exe $TOOLS\bin\

# lessmsi
Get-GitHubRelease -repo "activescott/lessmsi" -path "$SETUP_PATH\lessmsi.zip" -match lessmsi-v
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\lessmsi.zip" -o"$TOOLS\lessmsi" | Out-Null

# CobaltStrikeScan
Get-GitHubRelease -repo "Apr4h/CobaltStrikeScan" -path "$SETUP_PATH\CobaltStrikeScan.exe" -match CobaltStrikeScan
Copy-Item $SETUP_PATH\CobaltStrikeScan.exe $TOOLS\bin\

# Ares
Get-GitHubRelease -repo "bee-san/Ares" -path "$SETUP_PATH\ares.zip" -match windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ares.zip" -o"$TOOLS\ares" | Out-Null
Copy-Item "$TOOLS\ares\ares.exe" "$TOOLS\bin\" -Force
Remove-Item "$TOOLS\ares" -Force -Recurse

# Brim/Zui (Zq) - installed during start
Get-GitHubRelease -repo "brimdata/zui" -path "$SETUP_PATH\zui.exe" -match Zui-Setup

# RDPCacheStitcher
Get-GitHubRelease -repo "BSI-Bund/RdpCacheStitcher" -path "$SETUP_PATH\RdpCacheStitcher.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\RdpCacheStitcher.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\RdpCacheStitcher") {
    Remove-Item "$TOOLS\RdpCacheStitcher" -Recurse -Force
}
move-item $TOOLS\RdpCacheStitcher_* $TOOLS\RdpCacheStitcher

# ripgrep
Get-GitHubRelease -repo "BurntSushi/ripgrep" -path "$SETUP_PATH\ripgrep.zip" -match x86_64-pc-windows-msvc
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ripgrep.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\ripgrep") {
    Remove-Item "$TOOLS\ripgrep" -Recurse -Force
}
Move-Item $TOOLS\ripgrep-* $TOOLS\ripgrep

# binlex
Get-GitHubRelease -repo "c3rb3ru5d3d53c/binlex" -path "$SETUP_PATH\binlex.zip" -match windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\binlex.zip" -o"$TOOLS\bin" | Out-Null

# cmder - installed during start
Get-GitHubRelease -repo "cmderdev/cmder" -path "$SETUP_PATH\cmder.7z" -match cmder.7z

# Recaf
Get-GitHubRelease -repo "Col-E/Recaf" -path "$SETUP_PATH\recaf.jar" -match jar-with-dependencies.jar
Copy-Item $SETUP_PATH\recaf.jar $TOOLS\lib\recaf.jar
Set-Content -Encoding Ascii -Path "$TOOLS\bin\recaf.bat" "@echo off`njava --module-path $env:PATH_TO_FX --add-modules javafx.controls -jar C:\Tools\bin\recaf.jar"

# dnSpy 32-bit
Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "$SETUP_PATH\dnSpy32.zip" -match win32
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dnSpy32.zip" -o"$TOOLS\dnSpy32" | Out-Null

# dnSpy 64-bit
Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "$SETUP_PATH\dnSpy64.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dnSpy64.zip" -o"$TOOLS\dnSpy64" | Out-Null

# mboxviewer
Get-GitHubRelease -repo "eneam/mboxviewer" -path "$SETUP_PATH\mboxviewer.zip" -match mbox-viewer.exe
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\mboxviewer.zip" -o"$TOOLS\mboxviewer" | Out-Null

# CyberChef
Get-GitHubRelease -repo "gchq/CyberChef" -path "$SETUP_PATH\CyberChef.zip" -match CyberChef
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\CyberChef.zip" -o"$TOOLS\CyberChef" | Out-Null
if (Test-Path "$TOOLS\CyberChef\CyberChef.html") {
    Remove-Item "$TOOLS\CyberChef\CyberChef.html" -Force
}
Move-Item $TOOLS\CyberChef\CyberChef_* $TOOLS\CyberChef\CyberChef.html

# Gollum
Get-GitHubRelease -repo "gollum/gollum" -path "$SETUP_PATH\gollum.war" -match gollum.war
Copy-Item $SETUP_PATH\gollum.war $TOOLS\lib

# redress
Get-GitHubRelease -repo "goretk/redress" -path "$SETUP_PATH\redress.zip" -match windows.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\redress.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\redress") {
    Remove-Item "$TOOLS\redress" -Recurse -Force
}
Move-Item $TOOLS\redress-* $TOOLS\redress

# h2database - available for manual installation
Get-GitHubRelease -repo "h2database/h2database" -path "$SETUP_PATH\h2database.zip" -match bundle.jar
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\h2database.zip" -o"$TOOLS\h2database" | Out-Null
Get-GitHubRelease -repo "h2database/h2database" -path "$SETUP_PATH\h2.pdf" -match h2.pdf
Copy-Item $SETUP_PATH\h2.pdf $TOOLS\h2database

# INDXRipper
Get-GitHubRelease -repo "harelsegev/INDXRipper" -path "$SETUP_PATH\indxripper.zip" -match amd64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\indxripper.zip" -o"$TOOLS\INDXRipper" | Out-Null

# dll_to_exe
Get-GitHubRelease -repo "hasherezade/dll_to_exe" -path "$SETUP_PATH\dll_to_exe.exe" -match dll_to_exe.exe
Copy-Item $SETUP_PATH\dll_to_exe.exe $TOOLS\bin

# HollowsHunter
Get-GitHubRelease -repo "hasherezade/hollows_hunter" -path "$SETUP_PATH\hollows_hunter.exe" -match hollows_hunter64.exe
Copy-Item $SETUP_PATH\hollows_hunter.exe $TOOLS\bin\

# PE-bear
Get-GitHubRelease -repo "hasherezade/pe-bear" -path "$SETUP_PATH\pebear.zip" -match x64_win_vs19.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pebear.zip" -o"$TOOLS\pebear" | Out-Null

# PE-sieve
Get-GitHubRelease -repo "hasherezade/pe-sieve" -path "$SETUP_PATH\pe-sieve.exe" -match pe-sieve64.exe
Copy-Item $SETUP_PATH\pe-sieve.exe $TOOLS\bin\

# Flaged by MS AV - don't download at the moment since I don't want to force user to exclude files
# at the moment.
#Get-GitHubRelease -repo "hasherezade/pe_to_shellcode" -path "$SETUP_PATH\pe2shc.exe" -match pe2shc.exe
#Copy-Item $SETUP_PATH\pe2shc.exe $TOOLS\bin\

# PE-utils
Get-GitHubRelease -repo "hasherezade/pe_utils" -path "$SETUP_PATH\dll_load32.exe" -match dll_load32.exe
Copy-Item $SETUP_PATH\dll_load32.exe $TOOLS\bin\
Get-GitHubRelease -repo "hasherezade/pe_utils" -path "$SETUP_PATH\dll_load64.exe" -match dll_load64.exe
Copy-Item $SETUP_PATH\dll_load64.exe $TOOLS\bin\
Get-GitHubRelease -repo "hasherezade/pe_utils" -path "$SETUP_PATH\kdb_check.exe" -match kdb_check.exe
Copy-Item $SETUP_PATH\kdb_check.exe $TOOLS\bin\
Get-GitHubRelease -repo "hasherezade/pe_utils" -path "$SETUP_PATH\pe_check.exe" -match pe_check.exe
Copy-Item $SETUP_PATH\pe_check.exe $TOOLS\bin\

# WinObjEx64
Get-GitHubRelease -repo "hfiref0x/WinObjEx64" -path "$SETUP_PATH\WinObjEx64.zip" -match 2
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\WinObjEx64.zip" -o"$TOOLS\WinObjEx64" | Out-Null

# Detect It Easy
Get-GitHubRelease -repo "horsicq/DIE-engine" -path "$SETUP_PATH\die.zip" -match die_win64_portable
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\die.zip" -o"$TOOLS\die" | Out-Null

# XELFViewer
Get-GitHubRelease -repo "horsicq/XELFViewer" -path "$SETUP_PATH\XELFViewer.zip" -match win64_portable
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\XELFViewer.zip" -o"$TOOLS\XELFViewer" | Out-Null

# jd-gui
Get-GitHubRelease -repo "java-decompiler/jd-gui" -path "$SETUP_PATH\jd-gui.zip" -match jd-gui-windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\jd-gui.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\jd-gui") {
    Remove-Item "$TOOLS\jd-gui" -Recurse -Force
}
Move-Item $TOOLS\jd-gui* $TOOLS\jd-gui

# jq
Get-GitHubRelease -repo "jqlang/jq" -path "$SETUP_PATH\jq.exe" -match win64
Copy-Item $SETUP_PATH\jq.exe $TOOLS\bin\

# Jumplist Browser
Get-GitHubRelease -repo "kacos2000/Jumplist-Browser" -path "$SETUP_PATH\JumplistBrowser.exe" -match JumplistBrowser.exe
Copy-Item $SETUP_PATH\JumplistBrowser.exe $TOOLS\bin\

# MFTBrowser
Get-GitHubRelease -repo "kacos2000/MFT_Browser" -path "$SETUP_PATH\MFTBrowser.exe" -match MFTBrowser.exe
Copy-Item $SETUP_PATH\MFTBrowser.exe $TOOLS\bin\

# Prefetch Browser
Get-GitHubRelease -repo "kacos2000/Prefetch-Browser" -path "$SETUP_PATH\PrefetchBrowser.exe" -match PrefetchBrowser.exe
Copy-Item $SETUP_PATH\PrefetchBrowser.exe $TOOLS\bin\

# bytecode-viewer
Get-GitHubRelease -repo "Konloch/bytecode-viewer" -path "$SETUP_PATH\BCV.jar" -match Bytecode
Copy-Item $SETUP_PATH\BCV.jar $TOOLS\lib
Write-Output "java -Xmx3G -jar C:\Tools\lib\BCV.jar" | Out-File -Encoding "ascii" $TOOLS\bin\bcv.bat

# gftrace
Get-GitHubRelease -repo "leandrofroes/gftrace" -path "$SETUP_PATH\gftrace.zip" -match gftrace64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\gftrace.zip" -o"$TOOLS" | Out-Null

# MsgViewer
Get-GitHubRelease -repo "lolo101/MsgViewer" -path "$SETUP_PATH\msgviewer.jar" -match msgviewer.jar
Copy-Item $SETUP_PATH\msgviewer.jar $TOOLS\lib

# capa
Get-GitHubRelease -repo "mandiant/capa" -path "$SETUP_PATH\capa-windows.zip" -match windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\capa-windows.zip" -o"$TOOLS\capa" | Out-Null
# Temporary get Capa version 6.0.0 until the issue with the latest version not working with
# capaexplorer for Ghidra is fixed.
Get-FileFromUri -uri "https://github.com/mandiant/capa/releases/download/v6.0.0/capa-v6.0.0-windows.zip" -FilePath "$SETUP_PATH\capa-ghidra.zip"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\capa-ghidra.zip" -o"$TOOLS\capa-ghidra" | Out-Null
if (Test-Path "$TOOLS\capa-ghidra\capa-ghidra.exe") {
    Remove-Item "$TOOLS\capa-ghidra\capa-ghidra.exe" -Force
}
Move-Item $TOOLS\capa-ghidra\capa.exe $TOOLS\capa-ghidra\capa-ghidra.exe

# capa-rules
Get-GitHubRelease -repo "mandiant/capa-rules" -path "$SETUP_PATH\capa-rules.zip" -match Source
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\capa-rules.zip" -o"$TOOLS" | Out-Null
if (Test-Path $TOOLS\capa-rules) {
    Remove-Item $TOOLS\capa-rules -Recurse -Force
}
Move-Item $TOOLS\mandiant-capa-rules-* $TOOLS\capa-rules

# Flare-Floss
Get-GitHubRelease -repo "mandiant/flare-floss" -path "$SETUP_PATH\floss.zip" -match windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\floss.zip" -o"$TOOLS\floss" | Out-Null

# Flare-Fakenet-NG
Get-GitHubRelease -repo "mandiant/flare-fakenet-ng" -path "$SETUP_PATH\fakenet.zip" -match fakenet
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fakenet.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\fakenet") {
    Remove-Item "$TOOLS\fakenet" -Recurse -Force
}
Move-Item $TOOLS\fakenet* $TOOLS\fakenet

# GoReSym
Get-GitHubRelease -repo "mandiant/GoReSym" -path "$SETUP_PATH\GoReSym.zip" -match GoReSym-windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\GoReSym.zip" -o"$TOOLS\GoReSym" | Out-Null
if (Test-Path "$TOOLS\GoReSym\GoReSym.exe") {
    Remove-Item "$TOOLS\GoReSym\GoReSym.exe" -Force
}
Move-Item $TOOLS\GoReSym\GoReSym_win.exe $TOOLS\GoReSym\GoReSym.exe
Remove-Item $TOOLS\GoReSym\GoReSym_lin
Remove-Item $TOOLS\GoReSym\GoReSym_mac

# Elfparser-ng
Get-GitHubRelease -repo "mentebinaria/elfparser-ng" -path "$SETUP_PATH\elfparser-ng.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\elfparser-ng.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\elfparser-ng") {
    Remove-Item "$TOOLS\elfparser-ng" -Recurse -Force
}
Move-Item $TOOLS\elfparser-ng* $TOOLS\elfparser-ng

# readpe
Get-GitHubRelease -repo "mentebinaria/readpe" -path "$SETUP_PATH\readpe.zip" -match win.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\readpe.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\pev") {
    Remove-Item "$TOOLS\pev" -Recurse -Force
}
Move-Item $TOOLS\pev* $TOOLS\pev

# dsq
Get-GitHubRelease -repo "multiprocessio/dsq" -path "$SETUP_PATH\dsq.zip" -match dsq-win
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dsq.zip" -o"$TOOLS\bin" | Out-Null

# Ghidra GolangAnalyzerExtension
Get-GitHubRelease -repo "mooncat-greenpy/Ghidra_GolangAnalyzerExtension" -path "$SETUP_PATH\GolangAnalyzerExtension.zip" -match 10.4
if (! (Test-Path "$TOOLS\ghidra_extensions")) {
    New-Item -Path "$TOOLS\ghidra_extensions" -ItemType directory | Out-Null
}
Copy-Item "$SETUP_PATH\GolangAnalyzerExtension.zip" "$TOOLS\ghidra_extensions\GolangAnalyzerExtension.zip"


# Ghidra Cartographer plugin
Get-GitHubRelease -repo "nccgroup/Cartographer" -path "$SETUP_PATH\Cartographer.zip" -match Cartographer.zip
Copy-Item "$SETUP_PATH\Cartographer.zip" "$TOOLS\ghidra_extensions\Cartographer.zip"

# MetadataPlus
Get-GitHubRelease -repo "nccgroup/MetadataPlus" -path "$SETUP_PATH\MetadataPlus.exe" -match MetadataPlus
Copy-Item $SETUP_PATH\MetadataPlus.exe $TOOLS\bin\

# Loki - installed during start
Get-GitHubRelease -repo "Neo23x0/Loki" -path "$SETUP_PATH\loki.zip" -match loki

# Notepad++ - installed during start
Get-GitHubRelease -repo "notepad-plus-plus/notepad-plus-plus" -path "$SETUP_PATH\notepad++.exe" -match Installer.x64.exe

# HindSight
Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "$SETUP_PATH\hindsight.exe" -match hindsight.exe
Copy-Item $SETUP_PATH\hindsight.exe $TOOLS\bin\

# Hindsight GUI
Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "$SETUP_PATH\hindsight_gui.exe" -match hindsight_gui.exe
Copy-Item $SETUP_PATH\hindsight_gui.exe $TOOLS\bin\

# evtx_dump
Get-GitHubRelease -repo "omerbenamram/evtx" -path "$SETUP_PATH\evtx_dump.exe" -match exe
Copy-Item $SETUP_PATH\evtx_dump.exe $TOOLS\bin\

# ComparePlus plugin for Notepad++ - installed during start
Get-GitHubRelease -repo "pnedev/comparePlus" -path "$SETUP_PATH\comparePlus.zip" -match x64.zip

# Visual Studio Code powershell extension - installed during start
Get-GitHubRelease -repo "PowerShell/vscode-powershell" -path "$SETUP_PATH\vscode\vscode-powershell.vsix" -match vsix

# qpdf
Get-GitHubRelease -repo "qpdf/qpdf" -path "$SETUP_PATH\qpdf.zip" -match msvc64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\qpdf.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\qpdf") {
    Remove-Item "$TOOLS\qpdf" -Recurse -Force
}
Move-Item $TOOLS\qpdf-* $TOOLS\qpdf

# Radare2
Get-GitHubRelease -repo "radareorg/radare2" -path "$SETUP_PATH\radare2.zip" -match w64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\radare2.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\radare2") {
    Remove-Item "$TOOLS\radare2" -Recurse -Force
}
Move-Item $TOOLS\radare2-* $TOOLS\radare2

# Iaito by Radareorg
Get-GitHubRelease -repo "radareorg/iaito" -path "$SETUP_PATH\iaito.zip" -match iaito.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\iaito.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\__MACOSX") {
    Remove-Item "$TOOLS\__MACOSX" -Recurse -Force
}

# Cutter
Get-GitHubRelease -repo "rizinorg/cutter" -path "$SETUP_PATH\cutter.zip" -match Windows-x86_64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\cutter.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\cutter") {
    Remove-Item "$TOOLS\cutter" -Recurse -Force
}
Move-Item $TOOLS\cutter-* $TOOLS\cutter

# Perl by Strawberry
Get-GitHubRelease -repo "StrawberryPerl/Perl-Dist-Strawberry" -path "$SETUP_PATH\perl.zip" -match portable.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\perl.zip" -o"$TOOLS\perl" | Out-Null

# sidr
Get-GitHubRelease -repo "strozfriedberg/sidr" -path "$SETUP_PATH\sidr.exe" -match sidr.exe
Copy-Item $SETUP_PATH\sidr.exe $TOOLS\bin\

# jadx - installed during start
Get-GitHubRelease -repo "skylot/jadx" -path "$SETUP_PATH\jadx.zip" -match jadx-1

# Sleuthkit
Get-GitHubRelease -repo "sleuthkit/sleuthkit" -path "$SETUP_PATH\sleuthkit.zip" -match win32.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sleuthkit.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\sleuthkit") {
    Remove-Item "$TOOLS\sleuthkit" -Recurse -Force
}
Move-Item $TOOLS\sleuthkit-* $TOOLS\sleuthkit

# qrtool
Get-GitHubRelease -repo "sorairolake/qrtool" -path "$SETUP_PATH\qrtool.zip" -match x86_64-pc-windows-msvc
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\qrtool.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\qrtool") {
    Remove-Item "$TOOLS\qrtool" -Recurse -Force
}
Move-Item $TOOLS\qrtool-* $TOOLS\qrtool

# debloat
Get-GitHubRelease -repo "Squiblydoo/debloat" -path "$SETUP_PATH\debloat.zip" -match Windows
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\debloat.zip" -o"$TOOLS\bin" | Out-Null

# Visual Studio Code spell checker extension - installed during start
Get-GitHubRelease -repo "streetsidesoftware/vscode-spell-checker" -path "$SETUP_PATH\vscode\vscode-spell-checker.vsix" -match vsix

# Thumbcacheviewer
Get-GitHubRelease -repo "thumbcacheviewer/thumbcacheviewer" -path "$SETUP_PATH\thumbcacheviewer.zip" -match viewer_64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\thumbcacheviewer.zip" -o"$TOOLS\thumbcacheviewer" | Out-Null

# upx
Get-GitHubRelease -repo "upx/upx" -path "$SETUP_PATH\upx.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\upx.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\upx") {
    Remove-Item "$TOOLS\upx" -Recurse -Force
}
Move-Item $TOOLS\upx-* $TOOLS\upx

# Velociraptor - available for manual installation
Get-GitHubRelease -repo "velocidex/velociraptor" -path "$SETUP_PATH\velociraptor.exe" -match windows-amd64.exe

# fq
Get-GitHubRelease -repo "wader/fq" -path "$SETUP_PATH\fq.zip" -match windows_amd64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fq.zip" -o"$TOOLS\bin" | Out-Null

# imhex
Get-GitHubRelease -repo "WerWolv/ImHex" -path "$SETUP_PATH\imhex.zip" -match Portable-NoGPU-x86_64.zip
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\imhex.zip" -o"$TOOLS\imhex" | Out-Null

# chainsaw
Get-GitHubRelease -repo "WithSecureLabs/chainsaw" -path "$SETUP_PATH\chainsaw.zip" -match x86_64-pc-windows-msvc
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\chainsaw.zip" -o"$TOOLS" | Out-Null

# yara
Get-GitHubRelease -repo "VirusTotal/yara" -path "$SETUP_PATH\yara.zip" -match win64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\yara.zip" -o"$TOOLS" | Out-Null
if (Test-Path "$TOOLS\bin\yara.exe") {
    Remove-Item "$TOOLS\bin\yara.exe" -Force
}
if (Test-Path "$TOOLS\bin\yarac.exe") {
    Remove-Item "$TOOLS\bin\yarac.exe" -Force
}
Move-Item $TOOLS\yara64.exe $TOOLS\bin\yara.exe
Move-Item $TOOLS\yarac64.exe $TOOLS\bin\yarac.exe

# hayabusa
Get-GitHubRelease -repo "Yamato-Security/hayabusa" -path "$SETUP_PATH\hayabusa.zip" -match win-64
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\hayabusa.zip" -o"$TOOLS\hayabusa" | Out-Null
if (Test-Path "$TOOLS\hayabusa\hayabusa.exe") {
    Remove-Item "$TOOLS\hayabusa\hayabusa.exe" -Force
}
Move-Item $TOOLS\hayabusa\hayabusa-* $TOOLS\hayabusa\hayabusa.exe
