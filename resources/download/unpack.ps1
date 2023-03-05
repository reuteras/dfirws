Write-Host "Prepare downloaded files"

. $PSScriptRoot\common.ps1

$TOOLS=".\mount\Tools"
$SETUP_PATH=".\downloads"

Remove-Item -r $TOOLS > $null 2>$1
mkdir $TOOLS > $null 2>$1
mkdir $TOOLS\bin > $null 2>$1
mkdir $TOOLS\DidierStevens > $null 2>$1
mkdir $TOOLS\lib > $null 2>$1
mkdir $TOOLS\Zimmerman > $null 2>$1

Copy-Item $SETUP_PATH\jq.exe $TOOLS\bin\ >> .\log\log.txt 2>&1
Copy-Item $SETUP_PATH\JumplistBrowser.exe $TOOLS\bin\ >> .\log\log.txt 2>&1
xcopy /E $SETUP_PATH\DidierStevens $TOOLS\DidierStevens >> .\log\log.txt 2>&1
xcopy /E $SETUP_PATH\Zimmerman $TOOLS\Zimmerman >> .\log\log.txt 2>&1

# Unzip programs
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\beaconhunter.zip" -o"$TOOLS\beaconhunter" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\capa-windows.zip" -o"$TOOLS\capa" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\chainsaw.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\cmder.7z" -o"$TOOLS\cmder" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\cutter.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\CyberChef.zip" -o"$TOOLS\CyberChef" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\DensityScout.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\dnSpy.zip" -o"$TOOLS\dnSpy" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\exiftool.zip" -o"$TOOLS\exiftool" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fakenet.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\floss.zip" -o"$TOOLS\floss" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\fq.zip" -o"$TOOLS\bin" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ghidra.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\GoReSym.zip" -o"$TOOLS\GoReSym" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\hxd.zip" -o"$TOOLS\hxd" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\logview.zip" -o"$TOOLS\FullEventLogView" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\malcat.zip" -o"$TOOLS\malcat" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\nmap.exe" -o"$TOOLS\nmap" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pebear.zip" -o"$TOOLS\pebear" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\pestudio.zip" -o"$TOOLS\pestudio" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\qpdf.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\radare2.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\ripgrep.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\scdbg.zip" -o"$TOOLS\scdbg" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sqlite.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\sysinternals.zip" -o"$TOOLS\sysinternals" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\thumbcacheviewer.zip" -o"$TOOLS\thumbcacheviewer" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\trid.zip" -o"$TOOLS\trid" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\triddefs.zip" -o"$TOOLS\trid" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\upx.zip" -o"$TOOLS" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\x64dbg.zip" -o"$TOOLS\x64dbg" >> .\log\log.txt 2>&1
& "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "$SETUP_PATH\yara.zip" -o"$TOOLS" >> .\log\log.txt 2>&1

Move-Item $TOOLS\win64\densityscout.exe $TOOLS\bin\densityscout.exe
Move-Item $TOOLS\yara64.exe $TOOLS\bin\yara.exe
Move-Item $TOOLS\yarac64.exe $TOOLS\bin\yarac.exe
Move-Item "$TOOLS\exiftool\exiftool(-k).exe" $TOOLS\exiftool\exiftool.exe
Move-Item $TOOLS\cutter-* $TOOLS\cutter
Move-Item $TOOLS\CyberChef\CyberChef_* $TOOLS\CyberChef\CyberChef.html
Move-Item $TOOLS\fakenet* $TOOLS\fakenet
Move-Item $TOOLS\ghidra_* $TOOLS\ghidra
Move-Item $TOOLS\GoReSym\GoReSym_win.exe $TOOLS\GoReSym\GoReSym.exe
Move-Item $TOOLS\qpdf-* $TOOLS\qpdf
Move-Item $TOOLS\radare2-* $TOOLS\radare2
Move-Item $TOOLS\ripgrep-* $TOOLS\ripgrep
Move-Item $TOOLS\sqlite-* $TOOLS\sqlite
Move-Item $TOOLS\upx-* $TOOLS\upx

Copy-Item $SETUP_PATH\BCV.jar $TOOLS\lib
Copy-Item $SETUP_PATH\msgviewer.jar $TOOLS\lib
Write-Output "java -Xmx3G -jar C:\Tools\lib\BCV.jar" | Out-File -Encoding "ascii" $TOOLS\bin\bcv.bat

# Remove unused
Remove-Item $TOOLS\GoReSym\GoReSym_lin
Remove-Item $TOOLS\GoReSym\GoReSym_mac
Remove-Item -r $TOOLS\win32
Remove-Item -r $TOOLS\win64
Remove-Item -Recurse -Force $TOOLS\loki\signature-base

Copy-Item ".\setup\utils\PowerSiem.ps1" ".\mount\Tools\bin\"

if (! (Test-Path .\tmp\venv\done)) {
    Write-Output "Wait for Python pip building."
    While (! (Test-Path .\tmp\venv\done)){
        Start-Sleep 1
    }
    Remove-Item .\tmp\venv\done
    Write-Output "Python done. Continuing."
}

Copy-Item ".\setup\utils\hash-id.py" ".\tmp\venv\Scripts\"
Copy-Item ".\setup\utils\powershell-cleanup.py" ".\tmp\venv\Scripts\"
Copy-Item ".\mount\git\dotnetfile\examples\dotnetfile_dump.py" ".\mount\venv\Scripts\"  

rclone.exe sync --verbose --checksum .\tmp\venv .\mount\venv >> .\log\log.txt 2>&1
Remove-Item -Recurse -Force .\tmp\venv > $null 2>&1
