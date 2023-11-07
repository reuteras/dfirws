. $PSScriptRoot\common.ps1

$TOOLS=".\mount\Tools"
$SETUP_PATH=".\downloads"

Copy-Item $SETUP_PATH\jq.exe $TOOLS\bin\
Copy-Item $SETUP_PATH\JumplistBrowser.exe $TOOLS\bin\
Copy-Item $SETUP_PATH\hindsight.exe $TOOLS\bin\
Copy-Item $SETUP_PATH\hindsight_gui.exe $TOOLS\bin\
Copy-Item $SETUP_PATH\PrefetchBrowser.exe $TOOLS\bin\
Copy-Item $SETUP_PATH\MetadataPlus.exe $TOOLS\bin\
xcopy /E $SETUP_PATH\DidierStevens $TOOLS\DidierStevens
xcopy /E $SETUP_PATH\Zimmerman $TOOLS\Zimmerman

# Unzip programs
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\beaconhunter.zip" -o"$SETUP_PATH\"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\binlex.zip" -o"$TOOLS\bin"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\bulk_extractor.zip" -o"$TOOLS\bulk_extractor"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\capa-windows.zip" -o"$TOOLS\capa"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\chainsaw.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\choco.zip" -o"$SETUP_PATH\choco"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\cutter.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\CyberChef.zip" -o"$TOOLS\CyberChef"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\debloat.zip" -o"$TOOLS\bin"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\DensityScout.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\die.zip" -o"$TOOLS\die"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dsq.zip" -o"$TOOLS\bin"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dnSpy32.zip" -o"$TOOLS\dnSpy32"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dnSpy64.zip" -o"$TOOLS\dnSpy64"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\elfparser-ng.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\exiftool.zip" -o"$TOOLS\exiftool"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fakenet.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\floss.zip" -o"$TOOLS\floss"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fq.zip" -o"$TOOLS\bin"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ghidra.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\GoReSym.zip" -o"$TOOLS\GoReSym"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\hayabusa.zip" -o"$TOOLS\hayabusa"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\hxd.zip" -o"$TOOLS\hxd"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\imhex.zip" -o"$TOOLS\imhex"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\indxripper.zip" -o"$TOOLS\INDXRipper"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\jd-gui.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\lessmsi.zip" -o"$TOOLS\lessmsi"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\logview.zip" -o"$TOOLS\FullEventLogView"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\malcat.zip" -o"$TOOLS\malcat"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\nmap.exe" -o"$TOOLS\nmap"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pebear.zip" -o"$TOOLS\pebear"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pestudio.zip" -o"$TOOLS\pestudio"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pstwalker.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\qpdf.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\radare2.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ripgrep.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sqlite.zip" -o"$TOOLS\sqlite"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ssview.zip" -o"$TOOLS\ssview"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sysinternals.zip" -o"$TOOLS\sysinternals"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\thumbcacheviewer.zip" -o"$TOOLS\thumbcacheviewer"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\trid.zip" -o"$TOOLS\trid"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\triddefs.zip" -o"$TOOLS\trid"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\upx.zip" -o"$TOOLS"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\XELFViewer.zip" -o"$TOOLS\XELFViewer"
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\yara.zip" -o"$TOOLS"

Move-Item "$TOOLS\exiftool\exiftool(-k).exe" $TOOLS\exiftool\exiftool.exe
Move-Item $TOOLS\cutter-* $TOOLS\cutter
Move-Item $TOOLS\CyberChef\CyberChef_* $TOOLS\CyberChef\CyberChef.html
Move-Item $TOOLS\elfparser-ng* $TOOLS\elfparser-ng
Move-Item $TOOLS\fakenet* $TOOLS\fakenet
Move-Item $TOOLS\ghidra_* $TOOLS\ghidra
Move-Item $TOOLS\GoReSym\GoReSym_win.exe $TOOLS\GoReSym\GoReSym.exe
Move-Item $TOOLS\hayabusa\hayabusa-* $TOOLS\hayabusa\hayabusa.exe
Move-Item $TOOLS\jd-gui* $TOOLS\jd-gui
Remove-Item -Recurse -Force $TOOLS\pstwalker
Move-Item $TOOLS\pstwalker* $TOOLS\pstwalker
Move-Item $TOOLS\qpdf-* $TOOLS\qpdf
Move-Item $TOOLS\radare2-* $TOOLS\radare2
Move-Item $TOOLS\ripgrep-* $TOOLS\ripgrep
Move-Item $TOOLS\sqlite-* $TOOLS\sqlite
Move-Item $TOOLS\upx-* $TOOLS\upx
Move-Item $TOOLS\win64\densityscout.exe $TOOLS\bin\densityscout.exe
Move-Item $TOOLS\yara64.exe $TOOLS\bin\yara.exe
Move-Item $TOOLS\yarac64.exe $TOOLS\bin\yarac.exe

Copy-Item $SETUP_PATH\BCV.jar $TOOLS\lib
Copy-Item $SETUP_PATH\gollum.war $TOOLS\lib
Copy-Item $SETUP_PATH\msgviewer.jar $TOOLS\lib
Write-Output "java -Xmx3G -jar C:\Tools\lib\BCV.jar" | Out-File -Encoding "ascii" $TOOLS\bin\bcv.bat

# Remove unused
Remove-Item $TOOLS\GoReSym\GoReSym_lin
Remove-Item $TOOLS\GoReSym\GoReSym_mac
Remove-Item -r $TOOLS\win32
Remove-Item -r $TOOLS\win64
Remove-Item $TOOLS\license.txt

Copy-Item ".\resources\images\dfirws.jpg" ".\downloads\"
Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\"
