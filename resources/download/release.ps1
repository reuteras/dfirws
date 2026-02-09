. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# artemis
$status = Get-GitHubRelease -repo "puffyCid/artemis" -path "${SETUP_PATH}\artemis.zip" -match "x86_64-pc-windows-msvc.zip$" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\artemis.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\artemis") {
        Remove-Item "${TOOLS}\artemis" -Recurse -Force
    }
    Move-Item ${TOOLS}\artemis-* "${TOOLS}\artemis"
}

# godap
$status = Get-GitHubRelease -repo "Macmod/godap" -path "${SETUP_PATH}\godap.zip" -match "windows-amd64.zip$" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\godap") {
        Remove-Item "${TOOLS}\godap" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\godap.zip" -o"${TOOLS}\godap" | Out-Null
    Move-Item ${TOOLS}\godap-* "${TOOLS}\godap"
}

# BeaconHunter - copied to program files during startup
$status = Get-GitHubRelease -repo "3lp4tr0n/BeaconHunter" -path "${SETUP_PATH}\beaconhunter.zip" -match "BeaconHunter.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\beaconhunter.zip" -o"${TOOLS}\BeaconHunter" | Out-Null
}

# 4n4lDetector - installed in sandbox during startup
$status =  Get-GitHubRelease -repo "4n0nym0us/4n4lDetector" -path "${SETUP_PATH}\4n4lDetector.zip" -match "4n4lDetector" -check "Zip archive data"

# aLEAPP
$status = Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "${SETUP_PATH}\aleapp.zip" -match "aleapp-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\aleapp") {
        Remove-Item "${TOOLS}\aleapp" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\aleapp.zip" -o"${TOOLS}\aleapp" | Out-Null
    Copy-Item ${TOOLS}\aleapp\aleapp.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\aleapp" -Recurse -Force
}
$status = Get-GitHubRelease -repo "abrignoni/aLEAPP" -path "${SETUP_PATH}\aleappGUI.zip" -match "aleappGUI-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\aleappGUI") {
        Remove-Item "${TOOLS}\aleappGUI" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\aleappGUI.zip" -o"${TOOLS}\aleappGUI" | Out-Null
    Copy-Item ${TOOLS}\aleappGUI\aleappGUI.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\aleappGUI" -Recurse -Force
}

# iLEAPP
$status = Get-GitHubRelease -repo "abrignoni/iLEAPP" -path "${SETUP_PATH}\ileapp.zip" -match "ileapp-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ileapp") {
        Remove-Item "${TOOLS}\ileapp" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ileapp.zip" -o"${TOOLS}\ileapp" | Out-Null
    Copy-Item ${TOOLS}\ileapp\ileapp.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\ileapp" -Recurse -Force
}
$status = Get-GitHubRelease -repo "abrignoni/iLEAPP" -path "${SETUP_PATH}\ileappGUI.zip" -match "ileappGUI-.*Windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ileappGUI") {
        Remove-Item "${TOOLS}\ileappGUI" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ileappGUI.zip" -o"${TOOLS}\ileappGUI" | Out-Null
    Copy-Item ${TOOLS}\ileappGUI\ileappGUI.exe ${TOOLS}\bin\
    Remove-Item "${TOOLS}\ileappGUI" -Recurse -Force
}

# lessmsi
$status = Get-GitHubRelease -repo "activescott/lessmsi" -path "${SETUP_PATH}\lessmsi.zip" -match "lessmsi-v" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\lessmsi") {
        Remove-Item "${TOOLS}\lessmsi" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\lessmsi.zip" -o"${TOOLS}\lessmsi" | Out-Null
}

# fx
$status = Get-GitHubRelease -repo "antonmedv/fx" -path "${SETUP_PATH}\fx.exe" -match "fx_windows_amd64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\fx.exe ${TOOLS}\bin\
}

# CobaltStrikeScan
$status = Get-GitHubRelease -repo "Apr4h/CobaltStrikeScan" -path "${SETUP_PATH}\CobaltStrikeScan.exe" -match "CobaltStrikeScan" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\CobaltStrikeScan.exe ${TOOLS}\bin\
}

# Audacity
$status = Get-GitHubRelease -repo "audacity/audacity" -path "${SETUP_PATH}\audacity.zip" -match "64bit.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\audacity") {
        Remove-Item "${TOOLS}\audacity" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\audacity.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\audacity-* "${TOOLS}\audacity"
}

# Ares
$status = Get-GitHubRelease -repo "bee-san/Ares" -path "${SETUP_PATH}\ares.zip" -match "windows" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ares") {
        Remove-Item "${TOOLS}\ares" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ares.zip" -o"${TOOLS}\ares" | Out-Null
    Copy-Item "${TOOLS}\ares\ares.exe" "${TOOLS}\bin\" -Force
    Remove-Item "${TOOLS}\ares" -Force -Recurse
}

# Brim/Zui (Zq) - installed during start
$status =  Get-GitHubRelease -repo "brimdata/zui" -path "${SETUP_PATH}\zui.exe" -match "exe$" -check "PE32"

# RDPCacheStitcher
$status = Get-GitHubRelease -repo "BSI-Bund/RdpCacheStitcher" -path "${SETUP_PATH}\RdpCacheStitcher.zip" -match "win64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\RdpCacheStitcher.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\RdpCacheStitcher") {
        Remove-Item "${TOOLS}\RdpCacheStitcher" -Recurse -Force
    }
    Move-Item ${TOOLS}\RdpCacheStitcher_* "${TOOLS}\RdpCacheStitcher"
}

# ffmpeg
$status = Get-GitHubRelease -repo "BtbN/FFmpeg-Builds" -path "${SETUP_PATH}\ffmpeg.zip" -match "win64-gpl-7" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ffmpeg") {
        Remove-Item "${TOOLS}\ffmpeg" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ffmpeg.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\ffmpeg-* "${TOOLS}\ffmpeg"
}

# ripgrep
$status = Get-GitHubRelease -repo "BurntSushi/ripgrep" -path "${SETUP_PATH}\ripgrep.zip" -match "x86_64-pc-windows-msvc.zip$" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\ripgrep") {
        Remove-Item "${TOOLS}\ripgrep" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ripgrep.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\ripgrep-* "${TOOLS}\ripgrep"
}

# binlex
$status = Get-GitHubRelease -repo "c3rb3ru5d3d53c/binlex" -path "${SETUP_PATH}\binlex.zip" -match "windows" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\binlex.zip" -o"${TOOLS}\bin" | Out-Null
}

# cmder - installed during start
$status =  Get-GitHubRelease -repo "cmderdev/cmder" -path "${SETUP_PATH}\cmder.7z" -match "cmder.7z" -check "7-zip archive data"

# Recaf
$status = Get-GitHubRelease -repo "Col-E/Recaf" -path "${SETUP_PATH}\recaf.jar" -match "jar-with-dependencies.jar" -check "Java archive data \(JAR\)"
if ($status) {
    Copy-Item ${SETUP_PATH}\recaf.jar ${TOOLS}\lib\recaf.jar
    Set-Content -Encoding Ascii -Path "${TOOLS}\bin\recaf.bat" "@echo off`njava --module-path ${SANDBOX_TOOLS}\javafx-sdk\lib --add-modules javafx.controls -jar C:\Tools\lib\recaf.jar"
}

# DBeaver
$status = Get-GitHubRelease -repo "dbeaver/dbeaver" -path "${SETUP_PATH}\dbeaver.zip" -match "win32.win32.x86_64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\dbeaver") {
        Remove-Item "${TOOLS}\dbeaver" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dbeaver.zip" -o"${TOOLS}" | Out-Null
}

# Dumpbin from Visual Studio
$status = Get-GitHubRelease -repo "Delphier/dumpbin" -path "${SETUP_PATH}\dumpbin.zip" -match "dumpbin" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\dumpbin") {
        Remove-Item "${TOOLS}\dumpbin" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dumpbin.zip" -o"${TOOLS}\dumpbin" | Out-Null
}

# dnSpy 32-bit
$status = Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "${SETUP_PATH}\dnSpy32.zip" -match "win32" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\dnSpy32") {
        Remove-Item "${TOOLS}\dnSpy32" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dnSpy32.zip" -o"${TOOLS}\dnSpy32" | Out-Null
}

# dnSpy 64-bit
$status = Get-GitHubRelease -repo "dnSpyEx/dnSpy" -path "${SETUP_PATH}\dnSpy64.zip" -match "win64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\dnSpy64") {
        Remove-Item "${TOOLS}\dnSpy64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dnSpy64.zip" -o"${TOOLS}\dnSpy64" | Out-Null
}

# Dokany - available for manual installation
$status =  Get-GitHubRelease -repo "dokan-dev/dokany" -path "${SETUP_PATH}\dokany.msi" -match "Dokan_x64.msi" -check "Composite Document File V2 Document"

# mboxviewer
$status = Get-GitHubRelease -repo "eneam/mboxviewer" -path "${SETUP_PATH}\mboxviewer.zip" -match "mbox-viewer.exe" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\mboxviewer") {
        Remove-Item "${TOOLS}\mboxviewer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mboxviewer.zip" -o"${TOOLS}\mboxviewer" | Out-Null
}

# zstd
$status = Get-GitHubRelease -repo "facebook/zstd" -path "${SETUP_PATH}\zstd.zip" -match "win64.zip$" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa ".\downloads\zstd.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\zstd") {
        Remove-Item "${TOOLS}\zstd" -Recurse -Force
    }
    Move-Item ${TOOLS}\zstd-* "${TOOLS}\zstd" | Out-Null
}

# CyberChef
$status = Get-GitHubRelease -repo "gchq/CyberChef" -path "${SETUP_PATH}\CyberChef.zip" -match "CyberChef" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\CyberChef") {
        Remove-Item "${TOOLS}\CyberChef" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\CyberChef.zip" -o"${TOOLS}\CyberChef" | Out-Null
    if (Test-Path "${TOOLS}\CyberChef\CyberChef.html") {
        Remove-Item "${TOOLS}\CyberChef\CyberChef.html" -Force
    }
    Move-Item "${TOOLS}\CyberChef\CyberChef_*" "${TOOLS}\CyberChef\CyberChef.html"

    Add-Type -AssemblyName System.Drawing
    ConvertTo-Icon -bitmapPath "${PWD}\${TOOLS}\CyberChef\images\cyberchef-128x128.png" -iconPath "${PWD}\${TOOLS}\CyberChef\CyberChef.ico"
}

# redress
$status = Get-GitHubRelease -repo "goretk/redress" -path "${SETUP_PATH}\redress.zip" -match "windows.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\redress.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\redress") {
        Remove-Item "${TOOLS}\redress" -Recurse -Force
    }
    Move-Item ${TOOLS}\redress-* ${TOOLS}\redress
}

# h2database - available for manual installation
$status = Get-GitHubRelease -repo "h2database/h2database" -path "${SETUP_PATH}\h2database.zip" -match "bundle.jar" -check "Java archive data"
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
$status = Get-GitHubRelease -repo "harelsegev/INDXRipper" -path "${SETUP_PATH}\indxripper.zip" -match "amd64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\INDXRipper") {
        Remove-Item "${TOOLS}\INDXRipper" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\indxripper.zip" -o"${TOOLS}\INDXRipper" | Out-Null
}

# dll_to_exe
$status = Get-GitHubRelease -repo "hasherezade/dll_to_exe" -path "${SETUP_PATH}\dll_to_exe.exe" -match "dll_to_exe.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_to_exe.exe ${TOOLS}\bin
}

# HollowsHunter
$status = Get-GitHubRelease -repo "hasherezade/hollows_hunter" -path "${SETUP_PATH}\hollows_hunter.exe" -match "hollows_hunter64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\hollows_hunter.exe ${TOOLS}\bin\
}

# PE-bear
$status = Get-GitHubRelease -repo "hasherezade/pe-bear" -path "${SETUP_PATH}\pebear.zip" -match "x64_win_vs19.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\pebear") {
        Remove-Item "${TOOLS}\pebear" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pebear.zip" -o"${TOOLS}\pebear" | Out-Null
}

# PE-sieve
$status = Get-GitHubRelease -repo "hasherezade/pe-sieve" -path "${SETUP_PATH}\pe-sieve.exe" -match "pe-sieve64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\pe-sieve.exe ${TOOLS}\bin\
}

# PE-utils
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\dll_load32.exe" -match "dll_load32.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_load32.exe ${TOOLS}\bin\
}
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\dll_load64.exe" -match "dll_load64.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\dll_load64.exe ${TOOLS}\bin\
}
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\kdb_check.exe" -match "kdb_check.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\kdb_check.exe ${TOOLS}\bin\
}
$status = Get-GitHubRelease -repo "hasherezade/pe_utils" -path "${SETUP_PATH}\pe_check.exe" -match "pe_check.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\pe_check.exe ${TOOLS}\bin\
}

# WinObjEx64
$status = Get-GitHubRelease -repo "hfiref0x/WinObjEx64" -path "${SETUP_PATH}\WinObjEx64.zip" -match "WinobjEx64.*[0-9].zip" -check "Zip archive data"
$plugin_status = Get-GitHubRelease -repo "hfiref0x/WinObjEx64" -path "${SETUP_PATH}\WinObjEx64_plugins.zip" -match "WinobjEx64.*plugins.zip" -check "Zip archive data"
if ($status -or $plugin_status) {
    if (Test-Path "${TOOLS}\WinObjEx64") {
        Remove-Item "${TOOLS}\WinObjEx64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\WinObjEx64.zip" -o"${TOOLS}\WinObjEx64" | Out-Null
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\WinObjEx64_plugins.zip" -o"${TOOLS}\WinObjEx64" | Out-Null
}

# Detect It Easy
$status = Get-GitHubRelease -repo "horsicq/DIE-engine" -path "${SETUP_PATH}\die.zip" -match "die_win64_portable" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\die") {
        Remove-Item "${TOOLS}\die" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\die.zip" -o"${TOOLS}\die" | Out-Null
}

# XELFViewer
$status = Get-GitHubRelease -repo "horsicq/XELFViewer" -path "${SETUP_PATH}\XELFViewer.zip" -match "win64_portable" -check "Zip archive data"
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
$status = Get-GitHubRelease -repo "java-decompiler/jd-gui" -path "${SETUP_PATH}\jd-gui.zip" -match "jd-gui-windows" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\jd-gui.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\jd-gui") {
        Remove-Item "${TOOLS}\jd-gui" -Recurse -Force
    }
    Move-Item ${TOOLS}\jd-gui* "${TOOLS}\jd-gui"
}

# LogBoost
$status = Get-GitHubRelease -repo "joeavanzato/logboost" -path "${SETUP_PATH}\logboost.rar" -match "logboost_release" -check "RAR archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\logboost.rar" -o"${TOOLS}\logboost" | Out-Null
}

# jq
$status = Get-GitHubRelease -repo "jqlang/jq" -path "${SETUP_PATH}\jq.exe" -match "win64" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\jq.exe ${TOOLS}\bin\
}

# Jumplist Browser
$status = Get-GitHubRelease -repo "kacos2000/Jumplist-Browser" -path "${SETUP_PATH}\JumplistBrowser.exe" -match "JumplistBrowser.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\JumplistBrowser.exe ${TOOLS}\bin\
}

# MFTBrowser
$status = Get-GitHubRelease -repo "kacos2000/MFT_Browser" -path "${SETUP_PATH}\MFTBrowser.exe" -match "MFTBrowser.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\MFTBrowser.exe ${TOOLS}\bin\
}

# Prefetch Browser
$status = Get-GitHubRelease -repo "kacos2000/Prefetch-Browser" -path "${SETUP_PATH}\PrefetchBrowser.exe" -match "PrefetchBrowser.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\PrefetchBrowser.exe ${TOOLS}\bin\
}

# bytecode-viewer
$status = Get-GitHubRelease -repo "Konloch/bytecode-viewer" -path "${SETUP_PATH}\BCV.jar" -match "Bytecode" -check "Java archive data"
if ($status) {
    Copy-Item ${SETUP_PATH}\BCV.jar ${TOOLS}\lib
    Write-Output "java -Xmx3G -jar C:\Tools\lib\BCV.jar" | Out-File -Encoding "ascii" ${TOOLS}\bin\bcv.bat
}

# gftrace
$status = Get-GitHubRelease -repo "leandrofroes/gftrace" -path "${SETUP_PATH}\gftrace.zip" -match "gftrace64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\gftrace64") {
        Remove-Item "${TOOLS}\gftrace64" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\gftrace.zip" -o"${TOOLS}" | Out-Null
}

# adalanche
$status = Get-GitHubRelease -repo "lkarlslund/adalanche" -path "${SETUP_PATH}\adalanche.exe" -match "adalanche-windows-x64" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\adalanche.exe ${TOOLS}\bin\
}

# MsgViewer
$status = Get-GitHubRelease -repo "lolo101/MsgViewer" -path "${SETUP_PATH}\msgviewer.jar" -match "msgviewer.jar" -check "Java archive data"
if ($status) {
    Copy-Item ${SETUP_PATH}\msgviewer.jar ${TOOLS}\lib
}

# capa
$status = Get-GitHubRelease -repo "mandiant/capa" -path "${SETUP_PATH}\capa-windows.zip" -match "windows" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\capa") {
        Remove-Item "${TOOLS}\capa" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\capa-windows.zip" -o"${TOOLS}\capa" | Out-Null
}

# Temporary get Capa version 6.0.0 until the issue with the latest version not working with
# capaexplorer for Ghidra is fixed.
$status = Get-FileFromUri -uri "https://github.com/mandiant/capa/releases/download/v6.0.0/capa-v6.0.0-windows.zip" -FilePath "${SETUP_PATH}\capa-ghidra.zip" -check "Zip archive data"
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
$status = Get-GitHubRelease -repo "mandiant/capa-rules" -path "${SETUP_PATH}\capa-rules.zip" -match "Source" -check "Zip archive data"
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
$status = Get-GitHubRelease -repo "mooncat-greenpy/Ghidra_GolangAnalyzerExtension" -path "${SETUP_PATH}\GolangAnalyzerExtension_10.4.zip" -match "10.4_" -check "Zip archive data"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_10.4.zip")) {
    Copy-Item "${SETUP_PATH}\GolangAnalyzerExtension_10.4.zip" "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_10.4.zip"
}

# TODO: Get latest version of GolangAnalyzerExtension
$status = Get-GitHubRelease -repo "mooncat-greenpy/Ghidra_GolangAnalyzerExtension" -path "${SETUP_PATH}\GolangAnalyzerExtension_11.0.1.zip" -match "11.0.1_" -check "Zip archive data"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_11.0.1.zip")) {
    Copy-Item "${SETUP_PATH}\GolangAnalyzerExtension_11.0.1.zip" "${TOOLS}\ghidra_extensions\GolangAnalyzerExtension_11.0.1.zip"
}

# Microsoft PowerShell
$status = Get-GitHubRelease -repo "PowerShell/PowerShell" -path "${SETUP_PATH}\pwsh.zip" -match "win-x64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\pwsh") {
        Remove-Item "${TOOLS}\pwsh" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\pwsh.zip" -o"${TOOLS}\pwsh" | Out-Null
}

# Ghidra btighidra
$status = Get-GitHubRelease -repo "trailofbits/BTIGhidra" -path "${SETUP_PATH}\btighidra.zip" -match "ghidra" -check "Zip archive data"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\btighidra.zip")) {
    Copy-Item "${SETUP_PATH}\btighidra.zip" "${TOOLS}\ghidra_extensions\btighidra.zip"
}

# Ghidra Cartographer plugin
$status = Get-GitHubRelease -repo "nccgroup/Cartographer" -path "${SETUP_PATH}\Cartographer.zip" -match "Cartographer.zip" -check "Zip archive data"
if ($status -or !(Test-Path "${TOOLS}\ghidra_extensions\Cartographer.zip")) {
    Copy-Item "${SETUP_PATH}\Cartographer.zip" "${TOOLS}\ghidra_extensions\Cartographer.zip"
}

# Flare-Floss
$status = Get-GitHubRelease -repo "mandiant/flare-floss" -path "${SETUP_PATH}\floss.zip" -match "windows" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\floss") {
        Remove-Item "${TOOLS}\floss" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\floss.zip" -o"${TOOLS}\floss" | Out-Null
}

# Flare-Fakenet-NG
$status = Get-GitHubRelease -repo "mandiant/flare-fakenet-ng" -path "${SETUP_PATH}\fakenet.zip" -match "fakenet" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fakenet.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\fakenet") {
        Remove-Item "${TOOLS}\fakenet" -Recurse -Force
    }
    Move-Item ${TOOLS}\fakenet* "${TOOLS}\fakenet"
}

# GoReSym
$status = Get-GitHubRelease -repo "mandiant/GoReSym" -path "${SETUP_PATH}\GoReSym.zip" -match "windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\GoReSym") {
        Remove-Item "${TOOLS}\GoReSym" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\GoReSym.zip" -o"${TOOLS}\GoReSym" | Out-Null
}

# mmdbinspect
$status = Get-GitHubRelease -repo "maxmind/mmdbinspect" -path "${SETUP_PATH}\mmdbinspect.zip" -match "windows_amd64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\mmdbinspect") {
        Remove-Item "${TOOLS}\mmdbinspect" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\mmdbinspect.zip" -o"${TOOLS}" | Out-Null
    Move-Item "${TOOLS}\mmdbinspect_*" "${TOOLS}\mmdbinspect"
}

# Elfparser-ng
$status = Get-GitHubRelease -repo "mentebinaria/elfparser-ng" -path "${SETUP_PATH}\elfparser-ng.zip" -match "win64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\elfparser-ng.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\elfparser-ng") {
        Remove-Item "${TOOLS}\elfparser-ng" -Recurse -Force
    }
    Move-Item ${TOOLS}\elfparser-ng* "${TOOLS}\elfparser-ng"
}

# readpe
$status = Get-GitHubRelease -repo "mentebinaria/readpe" -path "${SETUP_PATH}\readpe.zip" -match "win.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\readpe.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\pev") {
        Remove-Item "${TOOLS}\pev" -Recurse -Force
    }
    Move-Item ${TOOLS}\pev* ${TOOLS}\pev
}

# Dit explorer
$status = Get-GitHubRelease -repo "trustedsec/DitExplorer" -path "${SETUP_PATH}\DitExplorer.zip" -match "win64-release.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\DitExplorer") {
        Remove-Item "${TOOLS}\DitExplorer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\DitExplorer.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\DitExplorer-* "${TOOLS}\DitExplorer"
}

# srum_dump binary
$status = Get-GitHubRelease -repo "MarkBaggett/srum-dump" -path "${SETUP_PATH}\srum_dump.exe" -match "srum_dump.exe" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\srum_dump.exe ${TOOLS}\bin\
}

# forensic-timeliner
$status = Get-GitHubRelease -repo "acquiredsecurity/forensic-timeliner" -path "${SETUP_PATH}\ForensicTimeliner.zip" -match "ForensicTimeliner" -check "Zip archive data"

# jwt-cli
$status = Get-GitHubRelease -repo "mike-engel/jwt-cli" -path "${SETUP_PATH}\jwt-cli.tar.gz" -match "jwt-windows.tar.gz"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\jwt-cli.tar.gz" -o"${TOOLS}\bin" | Out-Null
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${TOOLS}\bin\jwt-cli.tar" -o"${TOOLS}\bin" | Out-Null
    if (Test-Path "${TOOLS}\bin\jwt-cli.tar") {
        Remove-Item "${TOOLS}\bin\jwt-cli.tar" -Force
    }
}

# dsq
$status = Get-GitHubRelease -repo "multiprocessio/dsq" -path "${SETUP_PATH}\dsq.zip" -match "dsq-win" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\dsq.zip" -o"${TOOLS}\bin" | Out-Null
}

# MetadataPlus
$status = Get-GitHubRelease -repo "nccgroup/MetadataPlus" -path "${SETUP_PATH}\MetadataPlus.exe" -match "MetadataPlus" -check "PE32"
if ($status) {
    Copy-Item ${SETUP_PATH}\MetadataPlus.exe ${TOOLS}\bin\
}

# Loki - installed during start
$status =  Get-GitHubRelease -repo "Neo23x0/Loki" -path "${SETUP_PATH}\loki.zip" -match "loki" -check "Zip archive data"

# Notepad++ - installed during start
$status =  Get-GitHubRelease -repo "notepad-plus-plus/notepad-plus-plus" -path "${SETUP_PATH}\notepad++.exe" -match "Installer.x64.exe$" -check "PE32"

# HindSight
$status = Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "${SETUP_PATH}\hindsight.exe" -match "hindsight.exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\hindsight.exe" "${TOOLS}\bin"
}

# Hindsight GUI
$status = Get-GitHubRelease -repo "obsidianforensics/hindsight" -path "${SETUP_PATH}\hindsight_gui.exe" -match "hindsight_gui.exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\hindsight_gui.exe" "${TOOLS}\bin"
}

# evtx_dump
$status = Get-GitHubRelease -repo "omerbenamram/evtx" -path "${SETUP_PATH}\evtx_dump.exe" -match "exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\evtx_dump.exe" "${TOOLS}\bin"
}

#Plugins for Notepad++ - installed during start
# ComparePlus plugin for Notepad++ - installed during start
$status =  Get-GitHubRelease -repo "pnedev/comparePlus" -path "${SETUP_PATH}\comparePlus.zip" -match "x64.zip" -check "Zip archive data"
# DSpellCheck plugin for Notepad++ - installed during start
$status =  Get-GitHubRelease -repo "Predelnik/DSpellCheck" -path "${SETUP_PATH}\DSpellCheck.zip" -match "x64.zip" -check "Zip archive data"

# Visual Studio Code powershell extension - installed during start
$status =  Get-GitHubRelease -repo "PowerShell/vscode-powershell" -path "${SETUP_PATH}\vscode\vscode-powershell.vsix" -match "vsix" -check "Zip archive data"
# vscode-shellcheck
$status =  Get-GitHubRelease -repo "vscode-shellcheck/vscode-shellcheck" -path "${SETUP_PATH}\vscode\vscode-shellcheck.vsix" -match "vsix" -check "Zip archive data"

# qpdf
$status = Get-GitHubRelease -repo "qpdf/qpdf" -path "${SETUP_PATH}\qpdf.zip" -match "msvc64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\qpdf.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\qpdf") {
        Remove-Item "${TOOLS}\qpdf" -Recurse -Force
    }
    Move-Item ${TOOLS}\qpdf-* "${TOOLS}\qpdf"
}

# Fibratus
$status = Get-GitHubRelease -repo "rabbitstack/fibratus" -path "${SETUP_PATH}\fibratus.msi" -match "fibratus-[.0-9]+-amd64.msi$" -check "Composite Document File V2 Document"

# Radare2
$status = Get-GitHubRelease -repo "radareorg/radare2" -path "${SETUP_PATH}\radare2.zip" -match "w64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\radare2.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\radare2") {
        Remove-Item "${TOOLS}\radare2" -Recurse -Force
    }
    Move-Item ${TOOLS}\radare2-* ${TOOLS}\radare2
}

# Iaito by Radareorg
$status = Get-GitHubRelease -repo "radareorg/iaito" -path "${SETUP_PATH}\iaito.zip" -match "iaito.zip" -check "Zip archive data"
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
$status = Get-GitHubRelease -repo "rejetto/hfs" -path "${SETUP_PATH}\hfs.zip" -match "hfs-windows-x64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\hfs") {
        Remove-Item "${TOOLS}\hfs" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hfs.zip" -o"${TOOLS}\hfs" | Out-Null
}

# obsidian-mitre-attack
$status = Get-GitHubRelease -repo "reuteras/obsidian-mitre-attack" -path "${SETUP_PATH}\obsidian-mitre-attack.zip" -match "release.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\obsidian-mitre-attack") {
        Remove-Item "${TOOLS}\obsidian-mitre-attack" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\obsidian-mitre-attack.zip" -o"${TOOLS}" | Out-Null
    Move-Item "${TOOLS}\MITRE" "${TOOLS}\obsidian-mitre-attack"
    Remove-Item "${TOOLS}\README.md" -Force
}

# Cutter
$status = Get-GitHubRelease -repo "rizinorg/cutter" -path "${SETUP_PATH}\cutter.zip" -match "Windows-x86_64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\cutter.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\cutter") {
        Remove-Item "${TOOLS}\cutter" -Recurse -Force
    }
    Move-Item ${TOOLS}\Cutter-* ${TOOLS}\cutter
}

# Nerd fonts - installed during start
# Add some example fonts
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\JetBrainsMono.zip" -match "JetBrainsMono.zip" -check "Zip archive data"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\LiberationMono.zip" -match "LiberationMono.zip" -check "Zip archive data"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\Meslo.zip" -match "Meslo.zip" -check "Zip archive data"
$status =  Get-GitHubRelease -repo "ryanoasis/nerd-fonts" -path "${SETUP_PATH}\Terminus.zip" -match "Terminus.zip" -check "Zip archive data"

# Perl by Strawberry
$status = Get-GitHubRelease -repo "StrawberryPerl/Perl-Dist-Strawberry" -path "${SETUP_PATH}\perl.zip" -match "portable.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\perl") {
        Remove-Item "${TOOLS}\perl" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\perl.zip" -o"${TOOLS}\perl" | Out-Null
}

# sidr
$status = Get-GitHubRelease -repo "strozfriedberg/sidr" -path "${SETUP_PATH}\sidr.exe" -match "sidr.exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\sidr.exe" "${TOOLS}\bin"
}

# jadx - installed during start
$status =  Get-GitHubRelease -repo "skylot/jadx" -path "${SETUP_PATH}\jadx.zip" -match "jadx-1" -check "Zip archive data"

# Sleuthkit
$status = Get-GitHubRelease -repo "sleuthkit/sleuthkit" -path "${SETUP_PATH}\sleuthkit.zip" -match "win32.zip$" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sleuthkit.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\sleuthkit") {
        Remove-Item "${TOOLS}\sleuthkit" -Recurse -Force
    }
    Move-Item ${TOOLS}\sleuthkit-* "${TOOLS}\sleuthkit"
}

# qrtool
$status = Get-GitHubRelease -repo "sorairolake/qrtool" -path "${SETUP_PATH}\qrtool.zip" -match "x86_64-pc-windows-msvc" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\qrtool.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\qrtool") {
        Remove-Item "${TOOLS}\qrtool" -Recurse -Force
    }
    Move-Item ${TOOLS}\qrtool-* "${TOOLS}\qrtool"
}

# debloat
$status = Get-GitHubRelease -repo "Squiblydoo/debloat" -path "${SETUP_PATH}\debloat.zip" -match "Windows" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\debloat.zip" -o"${TOOLS}\bin" | Out-Null
}

# Visual Studio Code spell checker extension - installed during start
$status =  Get-GitHubRelease -repo "streetsidesoftware/vscode-spell-checker" -path "${SETUP_PATH}\vscode\vscode-spell-checker.vsix" -match "vsix" -check "Zip archive data"

# Thumbcacheviewer
$status = Get-GitHubRelease -repo "thumbcacheviewer/thumbcacheviewer" -path "${SETUP_PATH}\thumbcacheviewer.zip" -match "viewer_64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\thumbcacheviewer") {
        Remove-Item "${TOOLS}\thumbcacheviewer" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\thumbcacheviewer.zip" -o"${TOOLS}\thumbcacheviewer" | Out-Null
}

# gron
$status = Get-GitHubRelease -repo "tomnomnom/gron" -path "${SETUP_PATH}\gron.zip" -match "gron-windows-amd64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\gron.zip" -o"${TOOLS}\bin" | Out-Null
}

# MemProcFS
$status = Get-GitHubRelease -repo "ufrisk/MemProcFS" -path "${SETUP_PATH}\memprocfs.zip" -match "win_x64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\MemProcFS") {
        Remove-Item "${TOOLS}\MemProcFS" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\memprocfs.zip" -o"${TOOLS}\MemProcFS" | Out-Null
}

# upx
$status = Get-GitHubRelease -repo "upx/upx" -path "${SETUP_PATH}\upx.zip" -match "win64" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\upx.zip" -o"${TOOLS}" | Out-Null
    if (Test-Path "${TOOLS}\upx") {
        Remove-Item "${TOOLS}\upx" -Recurse -Force
    }
    Move-Item ${TOOLS}\upx-* "${TOOLS}\upx"
}

# Velociraptor
$status = Get-GitHubRelease -repo "velocidex/velociraptor" -path "${SETUP_PATH}\velociraptor.exe" -match "windows-amd64.exe$" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\velociraptor.exe" "${TOOLS}\bin\" -Force
}

# Witr
$status = Get-GitHubRelease -repo "pranshuparmar/witr" -path "${SETUP_PATH}\witr.zip" -match "witr-windows-amd64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\witr.zip" "witr.exe" -o"${TOOLS}\bin" | Out-Null
}

# fq
$status = Get-GitHubRelease -repo "wader/fq" -path "${SETUP_PATH}\fq.zip" -match "windows_amd64.zip" -check "Zip archive data"
if ($status) {
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\fq.zip" -o"${TOOLS}\bin" | Out-Null
}

# fqlite
$status = Get-GitHubRelease -repo "pawlaszczyk/fqlite" -path "${SETUP_PATH}\fqlite.exe" -match "windows.exe" -check "PE32"

# Zircolite
$status = Get-GitHubRelease -repo "wagga40/zircolite" -path "${SETUP_PATH}\zircolite.7z" -match "zircolite" -check "7-zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\zircolite") {
        Remove-Item "${TOOLS}\zircolite" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\zircolite.7z" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\zircolite_* ${TOOLS}\zircolite
    Move-Item ${TOOLS}\zircolite\zircolite_*.exe ${TOOLS}\zircolite\zircolite.exe
}

# imhex
$status = Get-GitHubRelease -repo "WerWolv/ImHex" -path "${SETUP_PATH}\imhex.zip" -match "Portable-NoGPU-x86_64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\imhex") {
        Remove-Item "${TOOLS}\imhex" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\imhex.zip" -o"${TOOLS}\imhex" | Out-Null
}

# chainsaw
$status = Get-GitHubRelease -repo "WithSecureLabs/chainsaw" -path "${SETUP_PATH}\chainsaw.zip" -match "x86_64-pc-windows-msvc" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\chainsaw") {
        Remove-Item "${TOOLS}\chainsaw" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\chainsaw.zip" -o"${TOOLS}" | Out-Null
}

# yara
$status = Get-GitHubRelease -repo "VirusTotal/yara" -path "${SETUP_PATH}\yara.zip" -match "win64" -check "Zip archive data"
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
$status = Get-GitHubRelease -repo "VirusTotal/yara-x" -path "${SETUP_PATH}\yara-x.zip" -match "x86_64-pc-windows-msvc" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\bin\yr.exe") {
        Remove-Item "${TOOLS}\bin\yr.exe" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\yara-x.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\yr.exe ${TOOLS}\bin\yr.exe
}

# yq
$status = Get-GitHubRelease -repo "mikefarah/yq" -path "${SETUP_PATH}\yq.exe" -match "yq_windows_amd64.exe" -check "PE32"
if ($status) {
    Copy-Item "${SETUP_PATH}\yq.exe" "${TOOLS}\bin"
}

# Get x64dbg - installed during start
$status =  Get-GitHubRelease -repo "x64dbg/x64dbg" -path "${SETUP_PATH}\x64dbg.zip" -match "snapshot/snapshot" -check "Zip archive data"

# hayabusa
$status = Get-GitHubRelease -repo "Yamato-Security/hayabusa" -path "${SETUP_PATH}\hayabusa.zip" -match "win-x64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\hayabusa") {
        Remove-Item "${TOOLS}\hayabusa" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\hayabusa.zip" -o"${TOOLS}\hayabusa" | Out-Null
    Move-Item ${TOOLS}\hayabusa\hayabusa-* ${TOOLS}\hayabusa\hayabusa.exe
}

# takajo
$status = Get-GitHubRelease -repo "Yamato-Security/takajo" -path "${SETUP_PATH}\takajo.zip" -match "win-x64" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\takajo") {
        Remove-Item "${TOOLS}\takajo" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\takajo.zip" -o"${TOOLS}\takajo" | Out-Null
    Move-Item ${TOOLS}\takajo\takajo-* "${TOOLS}\takajo\takajo.exe"
}

# zaproxy - available for installation with dfirws-install.ps1
$status = Get-GitHubRelease -repo "zaproxy/zaproxy" -path "${SETUP_PATH}\zaproxy.exe" -match "windows.exe" -check "PE32"

# edit
$status = Get-GitHubRelease -repo "microsoft/edit" -path "${SETUP_PATH}\edit.zip" -match "windows.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\edit") {
        Remove-Item "${TOOLS}\edit" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\edit.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\edit-* ${TOOLS}\edit
    Copy-Item "${TOOLS}\edit\edit.exe" "${TOOLS}\bin\edit.exe"
}

# https://download.sqlitebrowser.org/ - DB Browser for SQLite
$status = Get-GitHubRelease -repo "sqlitebrowser/sqlitebrowser" -path "${SETUP_PATH}\sqlitebrowser.zip" -match "win64.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path -Path "${TOOLS}\DB Browser for SQLite") {
        Remove-Item -Recurse -Force "${TOOLS}\DB Browser for SQLite" | Out-Null 2>&1
    }
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\sqlitebrowser.zip" -o"${TOOLS}\sqlitebrowser" | Out-Null
}

# NetExt
$status = Get-GitHubRelease -repo "rodneyviana/netext" -path "${SETUP_PATH}\netext.zip" -match "NetExt-.*.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\NetExt") {
        Remove-Item "${TOOLS}\NetExt" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\netext.zip" -o"${TOOLS}" | Out-Null
    Move-Item ${TOOLS}\NetExt-* "${TOOLS}\NetExt"
}

# YAMAGoya
$status = Get-GitHubRelease -repo "JPCERTCC/YAMAGoya" -path "${SETUP_PATH}\YAMAGoya.zip" -match "YAMAGoya.*.zip" -check "Zip archive data"
if ($status) {
    if (Test-Path "${TOOLS}\YAMAGoya") {
        Remove-Item "${TOOLS}\YAMAGoya" -Recurse -Force
    }
    & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\YAMAGoya.zip" -o"${TOOLS}\YAMAGoya" | Out-Null
}

#
# Obsidian plugins
#

# obsidian-dataview
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "blacksmithgu/obsidian-dataview" -path "${SETUP_PATH}\obsidian-plugins\obsidian-dataview\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-kanban
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "mgmeyers/obsidian-kanban" -path "${SETUP_PATH}\obsidian-plugins\obsidian-kanban\styles.css" -match "styles.css" -check "ASCII text"

# quickadd
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "chhoumann/quickadd" -path "${SETUP_PATH}\obsidian-plugins\quickadd\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-calendar-plugin
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "liamcain/obsidian-calendar-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-calendar-plugin\styles.css" -match "styles.css" -check "ASCII text"

# Templater
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "SilentVoid13/Templater" -path "${SETUP_PATH}\obsidian-plugins\Templater\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-tasks
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "obsidian-tasks-group/obsidian-tasks" -path "${SETUP_PATH}\obsidian-plugins\obsidian-tasks\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-excalidraw-plugin
$status = Get-GitHubRelease -repo "zsviczian/obsidian-excalidraw-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-excalidraw-plugin\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "zsviczian/obsidian-excalidraw-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-excalidraw-plugin\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "zsviczian/obsidian-excalidraw-plugin" -path "${SETUP_PATH}\obsidian-plugins\obsidian-excalidraw-plugin\styles.css" -match "styles.css" -check "text"

# admonitions
$status = Get-GitHubRelease -repo "javalent/admonitions" -path "${SETUP_PATH}\obsidian-plugins\admonitions\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "javalent/admonitions" -path "${SETUP_PATH}\obsidian-plugins\admonitions\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "javalent/admonitions" -path "${SETUP_PATH}\obsidian-plugins\admonitions\styles.css" -match "styles.css" -check "ASCII text"

# obsidian-timeline
$status = Get-GitHubRelease -repo "George-debug/obsidian-timeline" -path "${SETUP_PATH}\obsidian-plugins\obsidian-timeline\main.js" -match "main.js" -check "JavaScript source"
$status = Get-GitHubRelease -repo "George-debug/obsidian-timeline" -path "${SETUP_PATH}\obsidian-plugins\obsidian-timeline\manifest.json" -match "manifest.json" -check "JSON text data"
$status = Get-GitHubRelease -repo "George-debug/obsidian-timeline" -path "${SETUP_PATH}\obsidian-plugins\obsidian-timeline\styles.css" -match "styles.css" -check "ASCII text"

#
# Tool definitions for documentation generation.
# Fill in the dfirws-specific fields below. Auto-extracted metadata (Homepage,
# Vendor, License) comes from the GitHub API cache via extract-tool-metadata.py.
#

$TOOL_DEFINITIONS += @{
    Name = "artemis"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\artemis.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command artemis.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "artemis"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "godap"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\godap (LDAP tool).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command godap --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "godap"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "BeaconHunter"
    Category = "Malware tools\Cobalt Strike"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\BeaconHunter.lnk"
            Target   = "`${env:ProgramFiles}\BeaconHunter\BeaconHunter.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "${env:ProgramFiles}\BeaconHunter\BeaconHunter.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "4n4lDetector"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\4n4lDetector.lnk"
            Target   = "`${env:ProgramFiles}\4n4lDetector\4N4LDetector.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "${env:ProgramFiles}\4N4LDetector\4N4LDetector.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "aLEAPP"
    Category = "Files and apps\Phone"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Phone\aleapp (Android Logs, Events, and Protobuf Parser).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command aleapp.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Phone\aleappGUI.lnk"
            Target   = "`${TOOLS}\bin\aleappGUI.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "aleapp"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "aleappGUI"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "iLEAPP"
    Category = "Files and apps\Phone"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Phone\ileapp (iOS Logs, Events, And Plists Parser).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ileapp.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Phone\iLEAPPGUI.lnk"
            Target   = "`${TOOLS}\bin\iLEAPPGUI.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "ileapp"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "ileappGUI"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "lessmsi"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\lessmsi (A tool to view and extract the contents of a Windows Installer (.msi) file).lnk"
            Target   = "`${TOOLS}\lessmsi\lessmsi-gui.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "lessmsi"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "fx"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\fx (Terminal JSON viewer and processor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fx -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "fx"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "CobaltStrikeScan"
    Category = "Malware tools\Cobalt Strike"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\Cobalt Strike\CobaltStrikeScan.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command CobaltStrikeScan.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "CobaltStrikeScan"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Audacity"
    Category = "Utilities\Media"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Media\Audacity.lnk"
            Target   = "`${TOOLS}\Audacity\audacity.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\Audacity\audacity.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Ares"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\ares.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "ares"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Zui"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Zui (runs dfirws-install -Zui).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Zui"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Zui"
    Verify = @(
        @{
            Type = "command"
            Name = "zui"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "RDPCacheStitcher"
    Category = "Files and apps\RDP"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\RDP\RdpCacheStitcher.lnk"
            Target   = "`${TOOLS}\RdpCacheStitcher\RdpCacheStitcher.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\RdpCacheStitcher\RdpCacheStitcher.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ffmpeg"
    Category = "Utilities\Media"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Media\ffmpeg.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ffmpeg --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "ffmpeg"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ripgrep"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\ripgrep (rg).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rg -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "rg"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "binlex"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\binlex (A Binary Genetic Traits Lexer).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command binlex.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "binlex"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "cmder"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -CMDer"
    Verify = @(
        @{
            Type = "command"
            Name = "Cmder"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Recaf"
    Category = "Programming\Java"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Java\recaf (The modern Java bytecode editor).lnk"
            Target   = "`${TOOLS}\bin\recaf.bat"
            Args     = "`${CLI_TOOL_ARGS} -command recaf.bat"
            Icon     = "`${TOOLS}\lib\recaf.jar"
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "DBeaver"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\dbeaver (runs dfirws-install -DBeaver).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -DBeaver"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Dbeaver"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\dbeaver\dbeaver.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Dumpbin"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\dumpbin (Microsoft COFF Binary File Dumper).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dumpbin.exe"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "dumpbin"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dnSpy"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy32.lnk"
            Target   = "`${TOOLS}\dnSpy32\dnSpy.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\dnSpy64.lnk"
            Target   = "`${TOOLS}\dnSpy64\dnSpy.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\dnSpy64\bin\dnSpy.dll"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Dokany"
    Category = "Memory"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Memory\Dokany (runs dfirws-install -Dokany).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Dokany"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Dokany"
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "mboxviewer"
    Category = "Files and apps\Email"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\Mbox Viewer.lnk"
            Target   = "`${TOOLS}\mboxviewer\mboxview64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\mboxviewer\mboxview64.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "zstd"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\zstd.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command zstd -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "zstd"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "CyberChef"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\CyberChef.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "redress"
    Category = "Programming\Go"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Go\Redress.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command Redress.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "redress"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "h2database"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\h2 database.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${TOOLS}\h2database"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "INDXRipper"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\INDXRipper.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command INDXRipper.exe -h"
            Icon     = "`${TOOLS}\INDXRipper\INDXRipper.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "INDXRipper"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dll_to_exe"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "dll_to_exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "HollowsHunter"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\hollows_hunter (Scans running processes. Recognizes and dumps a variety of in-memory implants).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command hollows_hunter.exe /help"
            Icon     = "`${TOOLS}\bin\hollows_hunter.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "hollows_hunter"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PE-bear"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\PE-bear.lnk"
            Target   = "`${TOOLS}\pebear\PE-bear.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "PE-bear"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PE-sieve"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\PE-sieve (Scans a given process, recognizes and dumps a variety of in-memory implants).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pe-sieve.exe /help"
            Icon     = "`${TOOLS}\bin\pe-sieve.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "pe-sieve"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PE-utils"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "pescan"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "WinObjEx64"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\WinObjEx64.lnk"
            Target   = "`${TOOLS}\WinObjEx64\WinObjEx64.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "WinObjEx64"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Detect It Easy"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Detect It Easy (determining types of files).lnk"
            Target   = "`${TOOLS}\die\die.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "die"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "diec"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "XELFViewer"
    Category = "OS\Linux"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Linux\xelfviewer.lnk"
            Target   = "`${TOOLS}\XELFViewer\xelfviewer.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\XELFViewer\xelfviewer.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jd-gui"
    Category = "Programming\Java"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Java\jd-gui.lnk"
            Target   = "`${TOOLS}\jd-gui\jd-gui.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "jd-gui"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "LogBoost"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\logboost (runs dfirws-install -LogBoost).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -LogBoost"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -LogBoost"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\LogBoost\LogBoost.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jq"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\jq ( commandline JSON processor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command jq -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "jq"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Jumplist Browser"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Jumplist-Browser.lnk"
            Target   = "`${TOOLS}\bin\JumplistBrowser.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "JumplistBrowser"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "MFTBrowser"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\MFTBrowser.lnk"
            Target   = "`${TOOLS}\bin\MFTBrowser.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "MFTBrowser"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Prefetch Browser"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Prefetch-Browser.lnk"
            Target   = "`${TOOLS}\bin\PrefetchBrowser.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "PrefetchBrowser"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "bytecode-viewer"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Bytecode Viewer.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${POWERSHELL_EXE} -w hidden -command `${TOOLS}\bin\bcv.bat"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "gftrace"
    Category = "Programming\Go"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Go\gftrace.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command gftrace"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\gftrace64\gftrace.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "adalanche"
    Category = "OS\Windows\Active Directory (AD)"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\adalanche (Active Directory ACL Visualizer and Explorer).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command adalanche.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "adalanche"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "MsgViewer"
    Category = "Files and apps\Email"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\msgviewer.lnk"
            Target   = "`${TOOLS}\lib\msgviewer.jar"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "capa"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\capa.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command capa.exe -h"
            Icon     = "`${TOOLS}\capa\capa.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "capa"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\jep\Scripts\capa.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "capa-rules"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Ghidra GolangAnalyzerExtension"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "PowerShell"
    Category = "Programming\PowerShell"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Ghidra BTIGhidra"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Ghidra Cartographer"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Flare-Floss"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\floss.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command venv.ps1 -floss ; floss --help"
            Icon     = "`${TOOLS}\floss\floss.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "floss"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Flare-Fakenet-NG"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Fakenet.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fakenet.exe -h"
            Icon     = "`${TOOLS}\fakenet\fakenet.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "fakenet"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "GoReSym"
    Category = "Programming\Go"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Go\GoReSym.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command GoReSym.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "GoReSym"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "mmdbinspect"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\mmdbinspect (Tool for GeoIP lookup).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mmdbinspect --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "mmdbinspect"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Elfparser-ng"
    Category = "OS\Linux"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Linux\elfparser-ng.lnk"
            Target   = "`${TOOLS}\elfparser-ng\Release\elfparser-ng.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\elfparser-ng\Release\elfparser-ng.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "readpe"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "pescan"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "DitExplorer"
    Category = "OS\Windows\Active Directory (AD)"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Active Directory (AD)\DitExplorer (Active Directory Database Explorer).lnk"
            Target   = "`${TOOLS}\DitExplorer\DitExplorer.UI.WpfApp.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "srum_dump"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\srum-dump (Parses Windows System Resource Usage Monitor (SRUM) database).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command srum_dump.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "srum_dump"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "forensic-timeliner"
    Category = "IR"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -ForensicTimeliner"
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jwt-cli"
    Category = "Programming\Java"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "dsq"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\dsq (commandline SQL engine for data files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dsq -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "dsq"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "MetadataPlus"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\MetadataPlus.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command MetadataPlus.exe -h"
            Icon     = "`${TOOLS}\bin\MetadataPlus.exe"
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "MetadataPlus"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Loki"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\loki (runs dfirws-install -Loki).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Loki"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Loki"
    Verify = @(
        @{
            Type = "command"
            Name = "loki"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Notepad++"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Notepad++.lnk"
            Target   = "`${env:ProgramFiles}\Notepad++\notepad++.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "notepad++"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "HindSight"
    Category = "Files and apps\Browser"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight (Internet history forensics for Google Chrome and Chromium).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command hindsight.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\hindsight_gui.lnk"
            Target   = "`${TOOLS}\bin\hindsight_gui.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "hindsight"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "evtx_dump"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\evtx_dump (Utility to parse EVTX files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command evtx_dump.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "evtx_dump"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\uv\regipy\Scripts\evtx_dump.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ComparePlus"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\comparePlus.zip"
            Expect = "Zip archive data"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "DSpellCheck"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\DSpellCheck.zip"
            Expect = "Zip archive data"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "VS Code PowerShell Extension"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "vscode-shellcheck"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "qpdf"
    Category = "Files and apps\PDF"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PDF\qpdf.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command qpdf.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "qpdf"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Fibratus"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\fibratus (runs dfirws-install -Fibratus).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Fibratus"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Fibratus"
    Verify = @(
        @{
            Type = "command"
            Name = "fibratus"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Radare2"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\radare2.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command radare2 -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "radare2"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Iaito"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\iaito.lnk"
            Target   = "`${TOOLS}\iaito\iaito.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\iaito\iaito.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "hfs"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\hfs.exe.lnk"
            Target   = "`${TOOLS}\hfs\hfs.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\hfs\hfs.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-mitre-attack"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Cutter"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\Cutter.lnk"
            Target   = "`${TOOLS}\cutter\cutter.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "cutter"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "rizin"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Nerd Fonts"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Strawberry Perl"
    Category = "Programming"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "sidr"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\sidr (Search Index DB Reporter - handles both ESE (.edb) and SQLite).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sidr --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "sidr"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "jadx"
    Category = "Programming\Java"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Programming\Java\Jadx (runs dfirws-install -Jadx).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Jadx"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Jadx"
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Sleuthkit"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\blkcalc (Calculates where data in the unallocated space image).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "blkcalc"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "qrtool"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "qrtool"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "debloat"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\Debloat.lnk"
            Target   = "`${TOOLS}\bin\debloat.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "debloat"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "VS Code Spell Checker"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Thumbcacheviewer"
    Category = "OS\Windows"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Thumbcache Viewer.lnk"
            Target   = "`${TOOLS}\thumbcacheviewer\thumbcache_viewer.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "thumbcache_viewer"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "gron"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\gron (Make JSON greppable).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command gron -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "gron"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "MemProcFS"
    Category = "Memory"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Memory\MemProcFS.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command MemProcFS.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "MemProcFS"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "upx"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\upx.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command upx"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "upx"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Velociraptor"
    Category = "IR"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\IR\velociraptor.exe (Velociraptor is an advanced digital forensic and incident response tool that enhances your visibility into your endpoints).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command velociraptor.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "velociraptor"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Witr"
    Category = "IR"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "fq"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\fq (jq for binary formats).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fq -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "fq"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "fqlite"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\fqlite (runs dfirws-install -FQLite).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -FQLite"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -FQLite"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Users\WDAGUtilityAccount\AppData\Local\fqlite\fqlite.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Zircolite"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\zircolite (Standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command zircolite.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "zircolite"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "ImHex"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\ImHex.lnk"
            Target   = "`${TOOLS}\imhex\imhex-gui.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "imhex-gui"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "imhex"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "chainsaw"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\chainsaw (Rapidly work with Forensic Artefacts).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command chainsaw.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "chainsaw"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "YARA"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\yara.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command yara.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\yarac.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command yarac.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "yara"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "yarac"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "yara-x"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\yr (yara-x).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command yr.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "yr"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "yq"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\yq (is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command yq.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "yq"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "x64dbg"
    Category = "Reverse Engineering"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Reverse Engineering\X64dbg (runs dfirws-install -X64dbg).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -X64dbg"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -X64Dbg"
    Verify = @(
        @{
            Type = "command"
            Name = "x64dbg"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "hayabusa"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\hayabusa (is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command hayabusa.exe help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "hayabusa"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "takajo"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\takajo (is a tool to analyze Windows event logs - hayabusa).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command takajo.exe -h"
            Icon     = ""
            WorkDir  = "`${TOOLS}\takajo"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\takajo\takajo.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "zaproxy"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Zaproxy (runs dfirws-install -Zaproxy).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Zaproxy"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -ZAProxy"
    Verify = @(
        @{
            Type = "command"
            Name = "zap"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "edit"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "DB Browser for SQLite"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\DB Browser for SQLite.lnk"
            Target   = "`${TOOLS}\sqlitebrowser\DB Browser for SQLite.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = ""
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Tools\sqlitebrowser\DB Browser for SQLite.exe"
            Expect = "PE32"
        }
    )
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "NetExt"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "YAMAGoya"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\YAMAGoya (Yet Another Memory Analyzer for malware detection and Guarding Operations with YARA and SIGMA).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command YAMAGoya.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-dataview"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-kanban"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "quickadd"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-calendar-plugin"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "Templater"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-tasks"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-excalidraw-plugin"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "admonitions"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

$TOOL_DEFINITIONS += @{
    Name = "obsidian-timeline"
    Category = "Editors"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "release"
