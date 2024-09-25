. "${PSScriptRoot}\common.ps1"

# BeaconHunter - copied to program files during startup
$status = Get-GitHubRelease -repo "3lp4tr0n/BeaconHunter" -path "${SETUP_PATH}\beaconhunter.zip" -match "BeaconHunter.zip"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\beaconhunter.zip" -o"${TOOLS}\BeaconHunter" | Out-Null
}

# 4n4lDetector - installed in sandbox during startup
$status =  Get-GitHubRelease -repo "4n0nym0us/4n4lDetector" -path "${SETUP_PATH}\4n4lDetector.zip" -match "4n4lDetector"

# aLEAPP
$status = Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "${SETUP_PATH}\aleapp.exe" -match "aleapp.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\aleapp.exe ${TOOLS}\bin\
}
$status = Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "${SETUP_PATH}\aleappGUI.exe" -match "aleappGUI.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\aleappGUI.exe ${TOOLS}\bin\
}

# iLEAPP
$status = Get-GitHubRelease -repo "abrignoni/iLEAPP" -path "${SETUP_PATH}\ileapp.exe" -match "ileapp.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\ileapp.exe ${TOOLS}\bin\
}
$status = Get-GitHubRelease -repo "abrignoni/iLEAPP" -path "${SETUP_PATH}\ileappGUI.exe" -match "ileappGUI.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\ileappGUI.exe ${TOOLS}\bin\
}

# lessmsi
$status = Get-GitHubRelease -repo "activescott/lessmsi" -path "${SETUP_PATH}\lessmsi.zip" -match "lessmsi-v"
if ($status) {
    if (Test-Path "${TOOLS}\lessmsi") {
        Remove-Item "${TOOLS}\lessmsi" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\lessmsi.zip" -o"${TOOLS}\lessmsi" | Out-Null
}

# fx
$status = Get-GitHubRelease -repo "antonmedv/fx" -path "${SETUP_PATH}\fx.exe" -match "fx_windows_amd64.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\fx.exe ${TOOLS}\bin\
}

# CobaltStrikeScan
$status = Get-GitHubRelease -repo "Apr4h/CobaltStrikeScan" -path "${SETUP_PATH}\CobaltStrikeScan.exe" -match "CobaltStrikeScan"
if ($status) {
    Copy-Item ${SETUP_PATH}\CobaltStrikeScan.exe ${TOOLS}\bin\
}

# Audacity
$status = Get-GitHubRelease -repo "audacity/audacity" -path "${SETUP_PATH}\audacity.zip" -match "64bit.zip"
if ($status) {
    if (Test-Path "${TOOLS}\audacity") {
        Remove-Item "${TOOLS}\audacity" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\audacity.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\audacity-* "${TOOLS}\audacity"
}

# Ares
$status = Get-GitHubRelease -repo "bee-san/Ares" -path "${SETUP_PATH}\ares.zip" -match "windows"
if ($status) {
    if (Test-Path "${TOOLS}\ares") {
        Remove-Item "${TOOLS}\ares" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ares.zip" -o"${TOOLS}\ares" | Out-Null
    Copy-Item "${TOOLS}\ares\ares.exe" "${TOOLS}\bin\" -Force
    Remove-Item "${TOOLS}\ares" -Force -Recurse
}

# Brim/Zui (Zq) - installed during start
$status =  Get-GitHubRelease -repo "brimdata/zui" -path "${SETUP_PATH}\zui.exe" -match "exe$"

# RDPCacheStitcher
$status = Get-GitHubRelease -repo "BSI-Bund/RdpCacheStitcher" -path "${SETUP_PATH}\RdpCacheStitcher.zip" -match "win64"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\RdpCacheStitcher.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\RdpCacheStitcher") {
        Remove-Item "${TOOLS}\RdpCacheStitcher" -Recurse -Force
    }
    Move-Item ${TOOLS}\RdpCacheStitcher_* "${TOOLS}\RdpCacheStitcher"
}

# ffmpeg
$status = Get-GitHubRelease -repo "BtbN/FFmpeg-Builds" -path "${SETUP_PATH}\ffmpeg.zip" -match "win64-gpl-7"
if ($status) {
    if (Test-Path "${TOOLS}\ffmpeg") {
        Remove-Item "${TOOLS}\ffmpeg" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ffmpeg.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\ffmpeg-* "${TOOLS}\ffmpeg"
}

# ripgrep
$status = Get-GitHubRelease -repo "BurntSushi/ripgrep" -path "${SETUP_PATH}\ripgrep.zip" -match "x86_64-pc-windows-msvc.zip$"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ripgrep.zip" -o"${TOOLS}" | Out-Null
if ($status) {
    if (Test-Path "${TOOLS}\ripgrep") {
        Remove-Item "${TOOLS}\ripgrep" -Recurse -Force
    }
    Move-Item ${TOOLS}\ripgrep-* "${TOOLS}\ripgrep"
}

# binlex
$status = Get-GitHubRelease -repo "c3rb3ru5d3d53c/binlex" -path "${SETUP_PATH}\binlex.zip" -match "windows"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\binlex.zip" -o"${TOOLS}\bin" | Out-Null
}

# cmder - installed during start
$status =  Get-GitHubRelease -repo "cmderdev/cmder" -path "${SETUP_PATH}\cmder.7z" -match "cmder.7z"

# Recaf
$status = Get-GitHubRelease -repo "Col-E/Recaf" -path "${SETUP_PATH}\recaf.jar" -match "jar-with-dependencies.jar"
if ($status) {
    Copy-Item ${SETUP_PATH}\recaf.jar ${TOOLS}\lib\recaf.jar
    Set-Content -Encoding Ascii -Path "${TOOLS}\bin\recaf.bat" "@echo off`njava --module-path ${SANDBOX_TOOLS}\javafx-sdk\lib --add-modules javafx.controls -jar C:\Tools\lib\recaf.jar"
}

# DBeaver
$status = Get-GitHubRelease -repo "dbeaver/dbeaver" -path "${SETUP_PATH}\dbeaver.zip" -match "win32.win32.x86_64.zip"
if ($status) {
    if (Test-Path "${TOOLS}\dbeaver") {
        Remove-Item "${TOOLS}\dbeaver" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dbeaver.zip" -o"${TOOLS}" | Out-Null
}

# Dumpbin from Visual Studio
$status = Get-GitHubRelease -repo "Delphier/dumpbin" -path "${SETUP_PATH}\dumpbin.zip" -match "dumpbin"
if ($status) {
    if (Test-Path "${TOOLS}\dumpbin") {
        Remove-Item "${TOOLS}\dumpbin" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dumpbin.zip" -o"${TOOLS}\dumpbin" | Out-Null
}

# dnSpy 32-bit
$status = Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "${SETUP_PATH}\dnSpy32.zip" -match "win32"
if ($status) {
    if (Test-Path "${TOOLS}\dnSpy32") {
        Remove-Item "${TOOLS}\dnSpy32" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dnSpy32.zip" -o"${TOOLS}\dnSpy32" | Out-Null
}

# dnSpy 64-bit
$status = Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "${SETUP_PATH}\dnSpy64.zip" -match "win64"
if ($status) {
    if (Test-Path "${TOOLS}\dnSpy64") {
        Remove-Item "${TOOLS}\dnSpy64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dnSpy64.zip" -o"${TOOLS}\dnSpy64" | Out-Null
}

# Dokany - available for manual installation
$status =  Get-GitHubRelease -repo "dokan-dev/dokany" -path "${SETUP_PATH}\dokany.msi" -match "Dokan_x64.msi"

# mboxviewer
$status = Get-GitHubRelease -repo "eneam/mboxviewer" -path "${SETUP_PATH}\mboxviewer.zip" -match "mbox-viewer.exe"
if ($status) {
    if (Test-Path "${TOOLS}\mboxviewer") {
        Remove-Item "${TOOLS}\mboxviewer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mboxviewer.zip" -o"${TOOLS}\mboxviewer" | Out-Null
}

# Tabby
$status = Get-GitHubRelease -repo "eugeny/tabby" -path "${SETUP_PATH}\tabby.zip" -match "portable-x64"
if ($status) {
    if (Test-Path "${TOOLS}\tabby") {
        Remove-Item "${TOOLS}\tabby" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\tabby.zip" -o"${TOOLS}\tabby" | Out-Null
}

# zstd
$status = Get-GitHubRelease -repo "facebook/zstd" -path "${SETUP_PATH}\zstd.zip" -match "win64.zip$"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\downloads\zstd.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\zstd") {
        Remove-Item "${TOOLS}\zstd" -Recurse -Force
    }
    Move-Item ${TOOLS}\zstd-* "${TOOLS}\zstd" | Out-Null
}

# CyberChef
$status = Get-GitHubRelease -repo "gchq/CyberChef" -path "${SETUP_PATH}\CyberChef.zip" -match "CyberChef"
if ($status) {
    if (Test-Path "${TOOLS}\CyberChef") {
        Remove-Item "${TOOLS}\CyberChef" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\CyberChef.zip" -o"${TOOLS}\CyberChef" | Out-Null
    if (Test-Path "${TOOLS}\CyberChef\CyberChef.html") {
        Remove-Item "${TOOLS}\CyberChef\CyberChef.html" -Force
    }
    Move-Item "${TOOLS}\CyberChef\CyberChef_*" "${TOOLS}\CyberChef\CyberChef.html"
}

# Gollum
$status = Get-GitHubRelease -repo "gollum/gollum" -path "${SETUP_PATH}\gollum.war" -match "gollum.war"
if ($status) {
    Copy-Item ${SETUP_PATH}\gollum.war ${TOOLS}\lib
}

# redress
$status = Get-GitHubRelease -repo "goretk/redress" -path "${SETUP_PATH}\redress.zip" -match "windows.zip"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\redress.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\redress") {
        Remove-Item "${TOOLS}\redress" -Recurse -Force
    }
    Move-Item ${TOOLS}\redress-* ${TOOLS}\redress
}

# h2database - available for manual installation
$status = Get-GitHubRelease -repo "h2database/h2database" -path "${SETUP_PATH}\h2database.zip" -match "bundle.jar"
if ($status) {
    if (Test-Path "${TOOLS}\h2database") {
        Remove-Item "${TOOLS}\h2database" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\h2database.zip" -o"${TOOLS}\h2database" | Out-Null
}
$status = Get-GitHubRelease -repo "h2database/h2database" -path "${SETUP_PATH}\h2.pdf" -match "h2.pdf"
if ($status) {
    Copy-Item ${SETUP_PATH}\h2.pdf ${TOOLS}\h2database
}

# INDXRipper
$status = Get-GitHubRelease -repo "harelsegev/INDXRipper" -path "${SETUP_PATH}\indxripper.zip" -match "amd64.zip"
if ($status) {
    if (Test-Path "${TOOLS}\INDXRipper") {
        Remove-Item "${TOOLS}\INDXRipper" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\indxripper.zip" -o"${TOOLS}\INDXRipper" | Out-Null
}

# dll_to_exe
$status = Get-GitHubRelease -repo "hasherezade/dll_to_exe" -path "${SETUP_PATH}\dll_to_exe.exe" -match "dll_to_exe.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_to_exe.exe ${TOOLS}\bin
}

# HollowsHunter
$status = Get-GitHubRelease -repo "hasherezade/hollows_hunter" -path "${SETUP_PATH}\hollows_hunter.exe" -match "hollows_hunter64.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\hollows_hunter.exe ${TOOLS}\bin\
}

# PE-bear
$status = Get-GitHubRelease -repo "hasherezade/pe-bear" -path "${SETUP_PATH}\pebear.zip" -match "x64_win_vs19.zip"
if ($status) {
    if (Test-Path "${TOOLS}\pebear") {
        Remove-Item "${TOOLS}\pebear" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pebear.zip" -o"${TOOLS}\pebear" | Out-Null
}

# PE-sieve
$status = Get-GitHubRelease -repo "hasherezade/pe-sieve" -path "${SETUP_PATH}\pe-sieve.exe" -match "pe-sieve64.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\pe-sieve.exe ${TOOLS}\bin\
}

# PE-utils
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\dll_load32.exe" -match "dll_load32.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_load32.exe ${TOOLS}\bin\
}

$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\dll_load64.exe" -match "dll_load64.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_load64.exe ${TOOLS}\bin\
}

$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\kdb_check.exe" -match "kdb_check.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\kdb_check.exe ${TOOLS}\bin\
}

$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\pe_check.exe" -match "pe_check.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\pe_check.exe ${TOOLS}\bin\
}

# WinObjEx64
$status = Get-GitHubRelease -repo "hfiref0x/WinObjEx64" -path "${SETUP_PATH}\WinObjEx64.zip" -match "WinobjEx64"
if ($status) {
    if (Test-Path "${TOOLS}\WinObjEx64") {
        Remove-Item "${TOOLS}\WinObjEx64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\WinObjEx64.zip" -o"${TOOLS}\WinObjEx64" | Out-Null
}

# Detect It Easy
$status = Get-GitHubRelease -repo "horsicq/DIE-engine" -path "${SETUP_PATH}\die.zip" -match "die_win64_portable"
if ($status) {
    if (Test-Path "${TOOLS}\die") {
        Remove-Item "${TOOLS}\die" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\die.zip" -o"${TOOLS}\die" | Out-Null
}

# XELFViewer
$status = Get-GitHubRelease -repo "horsicq/XELFViewer" -path "${SETUP_PATH}\XELFViewer.zip" -match "win64_portable"
if ($status) {
    if (Test-Path "${TOOLS}\XELFViewer") {
        Remove-Item "${TOOLS}\XELFViewer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\XELFViewer.zip" -o"${TOOLS}\XELFViewer" | Out-Null
    if (Test-Path "${CONFIGURATION_FILES}\xelfviewer.ini") {
        Copy-Item "${CONFIGURATION_FILES}\xelfviewer.ini" "${TOOLS}\XELFViewer\xelfviewer.ini"
    } else {
        Copy-Item "${CONFIGURATION_FILES}\defaults\xelfviewer.ini" "${TOOLS}\XELFViewer\xelfviewer.ini"
    }
}

# jd-gui
$status = Get-GitHubRelease -repo "java-decompiler/jd-gui" -path "${SETUP_PATH}\jd-gui.zip" -match "jd-gui-windows"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\jd-gui.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\jd-gui") {
        Remove-Item "${TOOLS}\jd-gui" -Recurse -Force
    }
    Move-Item ${TOOLS}\jd-gui* "${TOOLS}\jd-gui"
}

# jq
$status = Get-GitHubRelease -repo "jqlang/jq" -path "${SETUP_PATH}\jq.exe" -match "win64"
if ($status) {
    Copy-Item ${SETUP_PATH}\jq.exe ${TOOLS}\bin\
}

# Jumplist Browser
$status = Get-GitHubRelease -repo "kacos2000/Jumplist-Browser" -path "${SETUP_PATH}\JumplistBrowser.exe" -match "JumplistBrowser.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\JumplistBrowser.exe ${TOOLS}\bin\
}

# MFTBrowser
$status = Get-GitHubRelease -repo "kacos2000/MFT_Browser" -path "${SETUP_PATH}\MFTBrowser.exe" -match "MFTBrowser.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\MFTBrowser.exe ${TOOLS}\bin\
}

# Prefetch Browser
$status = Get-GitHubRelease -repo "kacos2000/Prefetch-Browser" -path "${SETUP_PATH}\PrefetchBrowser.exe" -match "PrefetchBrowser.exe"
if ($status) {
    Copy-Item ${SETUP_PATH}\PrefetchBrowser.exe ${TOOLS}\bin\
}

# bytecode-viewer
$status = Get-GitHubRelease -repo "Konloch/bytecode-viewer" -path "${SETUP_PATH}\BCV.jar" -match "Bytecode"
if ($status) {
    Copy-Item ${SETUP_PATH}\BCV.jar ${TOOLS}\lib
    Write-Output "java -Xmx3G -jar C:\Tools\lib\BCV.jar" | Out-File -Encoding "ascii" ${TOOLS}\bin\bcv.bat
}

# gftrace
$status = Get-GitHubRelease -repo "leandrofroes/gftrace" -path "${SETUP_PATH}\gftrace.zip" -match "gftrace64"
if ($status) {
    if (Test-Path "${TOOLS}\gftrace64") {
        Remove-Item "${TOOLS}\gftrace64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\gftrace.zip" -o"${TOOLS}" | Out-Null
}

# adalanche
$status = Get-GitHubRelease -repo "lkarlslund/adalanche" -path "${SETUP_PATH}\adalanche.exe" -match "adalanche-windows-x64"
if ($status) {
    Copy-Item ${SETUP_PATH}\adalanche.exe ${TOOLS}\bin\
}

# MsgViewer
$status = Get-GitHubRelease -repo "lolo101/MsgViewer" -path "${SETUP_PATH}\msgviewer.jar" -match "msgviewer.jar"
if ($status) {
    Copy-Item ${SETUP_PATH}\msgviewer.jar ${TOOLS}\lib
}

# capa
$status = Get-GitHubRelease -repo "mandiant/capa" -path "${SETUP_PATH}\capa-windows.zip" -match "windows"
if ($status) {
    if (Test-Path "${TOOLS}\capa") {
        Remove-Item "${TOOLS}\capa" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-windows.zip" -o"${TOOLS}\capa" | Out-Null
}

# Temporary get Capa version 6.0.0 until the issue with the latest version not working with
# capaexplorer for Ghidra is fixed.
$status = Get-FileFromUri -uri "https://github.com/mandiant/capa/releases/download/v6.0.0/capa-v6.0.0-windows.zip" -FilePath "${SETUP_PATH}\capa-ghidra.zip"
if ($status) {
    if (Test-Path "${TOOLS}\capa-ghidra") {
        Remove-Item "${TOOLS}\capa-ghidra" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-ghidra.zip" -o"${TOOLS}\capa-ghidra" | Out-Null
    if (Test-Path "${TOOLS}\capa-ghidra\capa-ghidra.exe") {
        Remove-Item "${TOOLS}\capa-ghidra\capa-ghidra.exe" -Force
    }
    Move-Item ${TOOLS}\capa-ghidra\capa.exe ${TOOLS}\capa-ghidra\capa-ghidra.exe
}

# capa-rules
$status = Get-GitHubRelease -repo "mandiant/capa-rules" -path "${SETUP_PATH}\capa-rules.zip" -match "Source"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-rules.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\capa-rules") {
        Remove-Item "${TOOLS}\capa-rules" -Recurse -Force
    }
    Move-Item ${TOOLS}\mandiant-capa-rules-* "${TOOLS}\capa-rules"
}

# Folder for Ghidra extensions
if (! (Test-Path "${TOOLS}\ghidra_extensions")) {
    New-Item -Path "${TOOLS}\ghidra_extensions" -ItemType Directory | Out-Null
}

# Ghidra GolangAnalyzerExtension
$status = Get-GitHubRelease -repo "mooncat-greenpy/Ghidra_GolangAnalyzerExtension" -path "${SETUP_PATH}\GolangAnalyzerExtension_10.4.zip" -match "10.4_"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_10.4.zip")) {
    Copy-Item "${SETUP_PATH}\GolangAnalyzerExtension_10.4.zip" "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_10.4.zip"
}

$status = Get-GitHubRelease -repo "mooncat-greenpy/Ghidra_GolangAnalyzerExtension" -path "${SETUP_PATH}\GolangAnalyzerExtension_11.0.1.zip" -match "11.0.1_"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_11.0.1.zip")) {
    Copy-Item "${SETUP_PATH}\GolangAnalyzerExtension_11.0.1.zip" "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_11.0.1.zip"
}

# Microsoft PowerShell
$status = Get-GitHubRelease -repo "PowerShell/PowerShell" -path "${SETUP_PATH}\pwsh.zip" -match "win-x64.zip"
if ($status) {
    if (Test-Path "${TOOLS}\pwsh") {
        Remove-Item "${TOOLS}\pwsh" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pwsh.zip" -o"${TOOLS}\pwsh" | Out-Null
}

# Ghidra btighidra
$status = Get-GitHubRelease -repo "trailofbits/BTIGhidra" -path "${SETUP_PATH}\btighidra.zip" -match "ghidra"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\btighidra.zip")) {
    Copy-Item "${SETUP_PATH}\btighidra.zip" "${TOOLS}\ghidra_extensions\btighidra.zip"
}

# Ghidra Cartographer plugin
$status = Get-GitHubRelease -repo "nccgroup/Cartographer" -path "${SETUP_PATH}\Cartographer.zip" -match "Cartographer.zip"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\Cartographer.zip")) {
    Copy-Item "${SETUP_PATH}\Cartographer.zip" "${TOOLS}\ghidra_extensions\Cartographer.zip"
}

# Flare-Floss
$status = Get-GitHubRelease -repo "mandiant/flare-floss" -path "${SETUP_PATH}\floss.zip" -match "windows"
if ($status) {
    if (Test-Path "${TOOLS}\floss") {
        Remove-Item "${TOOLS}\floss" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\floss.zip" -o"${TOOLS}\floss" | Out-Null
}

# Flare-Fakenet-NG
$status = Get-GitHubRelease -repo "mandiant/flare-fakenet-ng" -path "${SETUP_PATH}\fakenet.zip" -match "fakenet"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fakenet.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\fakenet") {
        Remove-Item "${TOOLS}\fakenet" -Recurse -Force
    }
    Move-Item ${TOOLS}\fakenet* "${TOOLS}\fakenet"
}

# GoReSym
$status = Get-GitHubRelease -repo "mandiant/GoReSym" -path "${SETUP_PATH}\GoReSym.zip" -match "windows.zip"
if ($status) {
    if (Test-Path "${TOOLS}\GoReSym") {
        Remove-Item "${TOOLS}\GoReSym" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\GoReSym.zip" -o"${TOOLS}\GoReSym" | Out-Null
}

# mmdbinspect
$status = Get-GitHubRelease -repo "maxmind/mmdbinspect" -path "${SETUP_PATH}\mmdbinspect.zip" -match "windows_amd64.zip"
if ($status) {
    if (Test-Path "${TOOLS}\mmdbinspect") {
        Remove-Item "${TOOLS}\mmdbinspect" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mmdbinspect.zip" -o"${TOOLS}" | Out-Null
    Move-Item "${TOOLS}\mmdbinspect_*" "${TOOLS}\mmdbinspect"
}

# Elfparser-ng
$status = Get-GitHubRelease -repo "mentebinaria/elfparser-ng" -path "${SETUP_PATH}\elfparser-ng.zip" -match "win64"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\elfparser-ng.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\elfparser-ng") {
        Remove-Item "${TOOLS}\elfparser-ng" -Recurse -Force
    }
    Move-Item ${TOOLS}\elfparser-ng* "${TOOLS}\elfparser-ng"
}

# readpe
$status = Get-GitHubRelease -repo "mentebinaria/readpe" -path "${SETUP_PATH}\readpe.zip" -match "win.zip"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\readpe.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\pev") {
        Remove-Item "${TOOLS}\pev" -Recurse -Force
    }
    Move-Item ${TOOLS}\pev* ${TOOLS}\pev
}

# dsq
$status = Get-GitHubRelease -repo "multiprocessio/dsq" -path "${SETUP_PATH}\dsq.zip" -match "dsq-win"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dsq.zip" -o"${TOOLS}\bin" | Out-Null
}

# MetadataPlus
$status = Get-GitHubRelease -repo "nccgroup/MetadataPlus" -path "${SETUP_PATH}\MetadataPlus.exe" -match "MetadataPlus"
if ($status) {
    Copy-Item ${SETUP_PATH}\MetadataPlus.exe ${TOOLS}\bin\
}

# Loki - installed during start
$status =  Get-GitHubRelease -repo "Neo23x0/Loki" -path "${SETUP_PATH}\loki.zip" -match "loki"

# Notepad++ - installed during start
$status =  Get-GitHubRelease -repo "notepad-plus-plus/notepad-plus-plus" -path "${SETUP_PATH}\notepad++.exe" -match "Installer.x64.exe$"

# HindSight
$status = Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "${SETUP_PATH}\hindsight.exe" -match "hindsight.exe"
if ($status) {
    Copy-Item "${SETUP_PATH}\hindsight.exe" "${TOOLS}\bin"
}

# Hindsight GUI
$status = Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "${SETUP_PATH}\hindsight_gui.exe" -match "hindsight_gui.exe"
if ($status) {
    Copy-Item "${SETUP_PATH}\hindsight_gui.exe" "${TOOLS}\bin"
}

# evtx_dump
$status = Get-GitHubRelease -repo "omerbenamram/evtx" -path "${SETUP_PATH}\evtx_dump.exe" -match "exe"
if ($status) {
    Copy-Item "${SETUP_PATH}\evtx_dump.exe" "${TOOLS}\bin"
}

# ComparePlus plugin for Notepad++ - installed during start
$status =  Get-GitHubRelease -repo "pnedev/comparePlus" -path "${SETUP_PATH}\comparePlus.zip" -match "x64.zip"

# Visual Studio Code powershell extension - installed during start
$status =  Get-GitHubRelease -repo "PowerShell/vscode-powershell" -path "${SETUP_PATH}\vscode\vscode-powershell.vsix" -match "vsix"

# vscode-shellcheck
$status =  Get-GitHubRelease -repo "vscode-shellcheck/vscode-shellcheck" -path "${SETUP_PATH}\vscode\vscode-shellcheck.vsix" -match "vsix"

# qpdf
$status = Get-GitHubRelease -repo "qpdf/qpdf" -path "${SETUP_PATH}\qpdf.zip" -match "msvc64.zip"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\qpdf.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\qpdf") {
        Remove-Item "${TOOLS}\qpdf" -Recurse -Force
    }
    Move-Item ${TOOLS}\qpdf-* "${TOOLS}\qpdf"
}

# Fibratus
$status = Get-GitHubRelease -repo "rabbitstack/fibratus" -path "${SETUP_PATH}\fibratus.msi" -match "fibratus-[.0-9]+-amd64.msi"

# Radare2
$status = Get-GitHubRelease -repo "radareorg/radare2" -path "${SETUP_PATH}\radare2.zip" -match "w64.zip"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\radare2.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\radare2") {
        Remove-Item "${TOOLS}\radare2" -Recurse -Force
    }
    Move-Item ${TOOLS}\radare2-* ${TOOLS}\radare2
}

# Iaito by Radareorg
$status = Get-GitHubRelease -repo "radareorg/iaito" -path "${SETUP_PATH}\iaito.zip" -match "iaito.zip"
if ($status) {
    if (Test-Path "${TOOLS}\iaito") {
        Remove-Item "${TOOLS}\iaito" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\iaito.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\__MACOSX") {
        Remove-Item "${TOOLS}\__MACOSX" -Recurse -Force
    }
}

# hfs
$status = Get-GitHubRelease -repo "rejetto/hfs" -path "${SETUP_PATH}\hfs.zip" -match "hfs-windows-x64"
if ($status) {
    if (Test-Path "${TOOLS}\hfs") {
        Remove-Item "${TOOLS}\hfs" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hfs.zip" -o"${TOOLS}\hfs" | Out-Null
}

# obsidian-mitre-attack
$status = Get-GitHubRelease -repo "reuteras/obsidian-mitre-attack" -path "${SETUP_PATH}\obsidian-mitre-attack.zip" -match "release.zip"
if ($status) {
    if (Test-Path "${TOOLS}\obsidian-mitre-attack") {
        Remove-Item "${TOOLS}\obsidian-mitre-attack" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\obsidian-mitre-attack.zip" -o"${TOOLS}" | Out-Null
    move-item "${TOOLS}\MITRE" "${TOOLS}\obsidian-mitre-attack"
}

# Cutter
$status = Get-GitHubRelease -repo "rizinorg/cutter" -path "${SETUP_PATH}\cutter.zip" -match "Windows-x86_64.zip"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\cutter.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\cutter") {
        Remove-Item "${TOOLS}\cutter" -Recurse -Force
    }
    Move-Item ${TOOLS}\Cutter-* ${TOOLS}\cutter
}

# Nerd fonts - installed during start
# Add some example fonts
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\JetBrainsMono.zip" -match "JetBrainsMono.zip"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\LiberationMono.zip" -match "LiberationMono.zip"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\Meslo.zip" -match "Meslo.zip"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\Terminus.zip" -match "Terminus.zip"

# Perl by Strawberry
$status = Get-GitHubRelease -repo "StrawberryPerl/Perl-Dist-Strawberry" -path "${SETUP_PATH}\perl.zip" -match "portable.zip"
if ($status) {
    if (Test-Path "${TOOLS}\perl") {
        Remove-Item "${TOOLS}\perl" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\perl.zip" -o"${TOOLS}\perl" | Out-Null
}

# sidr
$status = Get-GitHubRelease -repo "strozfriedberg/sidr" -path "${SETUP_PATH}\sidr.exe" -match "sidr.exe"
if ($status) {
    Copy-Item "${SETUP_PATH}\sidr.exe" "${TOOLS}\bin"
}

# jadx - installed during start
$status =  Get-GitHubRelease -repo "skylot/jadx" -path "${SETUP_PATH}\jadx.zip" -match "jadx-1"

# Sleuthkit
$status = Get-GitHubRelease -repo "sleuthkit/sleuthkit" -path "${SETUP_PATH}\sleuthkit.zip" -match "win32.zip$"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sleuthkit.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\sleuthkit") {
        Remove-Item "${TOOLS}\sleuthkit" -Recurse -Force
    }
    Move-Item ${TOOLS}\sleuthkit-* "${TOOLS}\sleuthkit"
}

# qrtool
$status = Get-GitHubRelease -repo "sorairolake/qrtool" -path "${SETUP_PATH}\qrtool.zip" -match "x86_64-pc-windows-msvc"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\qrtool.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\qrtool") {
        Remove-Item "${TOOLS}\qrtool" -Recurse -Force
    }
    Move-Item ${TOOLS}\qrtool-* "${TOOLS}\qrtool"
}

# debloat
$status = Get-GitHubRelease -repo "Squiblydoo/debloat" -path "${SETUP_PATH}\debloat.zip" -match "Windows"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\debloat.zip" -o"${TOOLS}\bin" | Out-Null
}

# Visual Studio Code spell checker extension - installed during start
$status =  Get-GitHubRelease -repo "streetsidesoftware/vscode-spell-checker" -path "${SETUP_PATH}\vscode\vscode-spell-checker.vsix" -match "vsix"

# Thumbcacheviewer
$status = Get-GitHubRelease -repo "thumbcacheviewer/thumbcacheviewer" -path "${SETUP_PATH}\thumbcacheviewer.zip" -match "viewer_64"
if ($status) {
    if (Test-Path "${TOOLS}\thumbcacheviewer") {
        Remove-Item "${TOOLS}\thumbcacheviewer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\thumbcacheviewer.zip" -o"${TOOLS}\thumbcacheviewer" | Out-Null
}

# gron
$status = Get-GitHubRelease -repo "tomnomnom/gron" -path "${SETUP_PATH}\gron.zip" -match "gron-windows-amd64"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\gron.zip" -o"${TOOLS}\bin" | Out-Null
}

# MemProcFS
$status = Get-GitHubRelease -repo "ufrisk/MemProcFS" -path "${SETUP_PATH}\memprocfs.zip" -match "win_x64"
if ($status) {
    if (Test-Path "${TOOLS}\MemProcFS") {
        Remove-Item "${TOOLS}\MemProcFS" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\memprocfs.zip" -o"${TOOLS}\MemProcFS" | Out-Null
}

# upx
$status = Get-GitHubRelease -repo "upx/upx" -path "${SETUP_PATH}\upx.zip" -match "win64"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\upx.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\upx") {
        Remove-Item "${TOOLS}\upx" -Recurse -Force
    }
    Move-Item ${TOOLS}\upx-* "${TOOLS}\upx"
}

# Velociraptor
$status = Get-GitHubRelease -repo "velocidex/velociraptor" -path "${SETUP_PATH}\velociraptor.exe" -match "windows-amd64.exe$"
if ($status) {
    Copy-Item "${SETUP_PATH}\velociraptor.exe" "${TOOLS}\bin\" -Force
}

# fq
$status = Get-GitHubRelease -repo "wader/fq" -path "${SETUP_PATH}\fq.zip" -match "windows_amd64.zip"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fq.zip" -o"${TOOLS}\bin" | Out-Null
}

# Zircolite
$status = Get-GitHubRelease -repo "wagga40/zircolite" -path "${SETUP_PATH}\zircolite.7z" -match "zircolite"
if ($status) {
    if (Test-Path "${TOOLS}\zircolite") {
        Remove-Item "${TOOLS}\zircolite" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\zircolite.7z" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\zircolite_* ${TOOLS}\zircolite
    Move-Item ${TOOLS}\zircolite\zircolite_*.exe ${TOOLS}\zircolite\zircolite.exe
}

# imhex
$status = Get-GitHubRelease -repo "WerWolv/ImHex" -path "${SETUP_PATH}\imhex.zip" -match "Portable-NoGPU-x86_64.zip"
if ($status) {
    if (Test-Path "${TOOLS}\imhex") {
        Remove-Item "${TOOLS}\imhex" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\imhex.zip" -o"${TOOLS}\imhex" | Out-Null
}

# chainsaw
$status = Get-GitHubRelease -repo "WithSecureLabs/chainsaw" -path "${SETUP_PATH}\chainsaw.zip" -match "x86_64-pc-windows-msvc"
if ($status) {
    if (Test-Path "${TOOLS}\chainsaw") {
        Remove-Item "${TOOLS}\chainsaw" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\chainsaw.zip" -o"${TOOLS}" | Out-Null
}

# yara
$status = Get-GitHubRelease -repo "VirusTotal/yara" -path "${SETUP_PATH}\yara.zip" -match "win64"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\yara.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\bin\yara.exe") {
        Remove-Item "${TOOLS}\bin\yara.exe" -Force
    }
    if (Test-Path "${TOOLS}\bin\yarac.exe") {
        Remove-Item "${TOOLS}\bin\yarac.exe" -Force
    }
    Move-Item ${TOOLS}\yara64.exe ${TOOLS}\bin\yara.exe
    Move-Item ${TOOLS}\yarac64.exe ${TOOLS}\bin\yarac.exe
}

# yara-x
$status = Get-GitHubRelease -repo "VirusTotal/yara-x" -path "${SETUP_PATH}\yara-x.zip" -match "x86_64-pc-windows-msvc"
if ($status) {
    if (Test-Path "${TOOLS}\bin\yr.exe") {
        Remove-Item "${TOOLS}\bin\yr.exe" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\yara-x.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\yr.exe ${TOOLS}\bin\yr.exe
}

# yq
$status = Get-GitHubRelease -repo "mikefarah/yq" -path "${SETUP_PATH}\yq.exe" -match "yq_windows_amd64.exe"
if ($status) {
    Copy-Item "${SETUP_PATH}\yq.exe" "${TOOLS}\bin"
}

# Get x64dbg - installed during start
$status =  Get-GitHubRelease -repo "x64dbg/x64dbg" -path "${SETUP_PATH}\x64dbg.zip" -match "snapshot/snapshot"

# hayabusa
$status = Get-GitHubRelease -repo "Yamato-Security/hayabusa" -path "${SETUP_PATH}\hayabusa.zip" -match "win-x64"
if ($status) {
    if (Test-Path "${TOOLS}\hayabusa") {
        Remove-Item "${TOOLS}\hayabusa" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hayabusa.zip" -o"${TOOLS}\hayabusa" | Out-Null
    Move-Item ${TOOLS}\hayabusa\hayabusa-* ${TOOLS}\hayabusa\hayabusa.exe
}

# zaproxy - available for installation with dfirws-install.ps1
$status = Get-GitHubRelease -repo "zaproxy/zaproxy" -path "${SETUP_PATH}\zaproxy.exe" -match "windows.exe"

#
# Obsidian plugins
#

# obsidian-dataview
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\main.js" -match "main.js"
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\manifest.json" -match "manifest.json"
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\styles.css" -match "styles.css"

# obsidian-kanban
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\main.js" -match "main.js"
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\manifest.json" -match "manifest.json"
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\styles.css" -match "styles.css"

# quickadd
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\main.js" -match "main.js"
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\manifest.json" -match "manifest.json"
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\styles.css" -match "styles.css"

# obsidian-calendar-plugin
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\main.js" -match "main.js"
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\manifest.json" -match "manifest.json"
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\styles.css" -match "styles.css"

# Templater
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\main.js" -match "main.js"
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\manifest.json" -match "manifest.json"
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\styles.css" -match "styles.css"

# obsidian-tasks
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\main.js" -match "main.js"
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\manifest.json" -match "manifest.json"
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\styles.css" -match "styles.css"
