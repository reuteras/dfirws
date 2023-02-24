rem Set variables
set SETUP_PATH=C:\users\WDAGUtilityAccount\Documents\tools\downloads
set TEMP=C:\temp
set TOOLS=C:\Tools

rem Create directories
mkdir C:\git
mkdir C:\temp
mkdir C:\temp\yararules
mkdir C:\Tools
mkdir C:\Tools\bin
mkdir C:\Tools\DidierStevens
mkdir C:\Tools\lib
mkdir C:\Tools\Zimmerman
mkdir C:\Users\WDAGUtilityAccount\Documents\WindowsPowerShell

rem Set temporary background
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Users\WDAGUtilityAccount\Documents\tools\copying.ps1" 2>&1 >> C:\temp\log.txt

rem Copy files
copy /B /Y /V %SETUP_PATH%\* %TEMP%\

copy "C:\Users\WDAGUtilityAccount\Documents\tools\config.txt" C:\temp\config.bat
call C:\temp\config.bat

copy /B %SETUP_PATH%\jq.exe C:\Tools\bin\
copy "C:\Users\WDAGUtilityAccount\Documents\tools\.bashrc" "C:\Users\WDAGUtilityAccount\"
xcopy /E %SETUP_PATH%\DidierStevens C:\Tools\DidierStevens
xcopy /E %SETUP_PATH%\git C:\git 
xcopy /E "%SETUP_PATH%\git\signature-base\yara" C:\temp\yararules
xcopy /E %SETUP_PATH%\Zimmerman C:\Tools\Zimmerman

rem Set temporary background
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Users\WDAGUtilityAccount\Documents\tools\installing.ps1" 2>&1 >> C:\temp\log.txt

rem Install msi packages
msiexec /i "%TEMP%\7zip.msi" /qn /norestart
if %WSDFIR_JAVA%=="Yes" msiexec /i "%TEMP%\corretto.msi" /qn /norestart
if %WSDFIR_LIBREOFFICE%=="Yes" msiexec /qb /i "%TEMP%\LibreOffice.msi" /l* C:\temp\LibreOffice_install_log.txt REGISTER_ALL_MSO_TYPES=1 UI_LANGS=en_US ISCHECKFORPRODUCTUPDATES=0 ^
REBOOTYESNO=No QUICKSTART=0 ADDLOCAL=ALL VC_REDIST=0 ^
REMOVE=gm_o_Onlineupdate,gm_r_ex_Dictionary_Af,gm_r_ex_Dictionary_An,gm_r_ex_Dictionary_Ar,gm_r_ex_Dictionary_Be,gm_r_ex_Dictionary_Bg,^
gm_r_ex_Dictionary_Bn,gm_r_ex_Dictionary_Bo,gm_r_ex_Dictionary_Br,gm_r_ex_Dictionary_Pt_Br,gm_r_ex_Dictionary_Bs,^
gm_r_ex_Dictionary_Pt_Pt,gm_r_ex_Dictionary_Ca,gm_r_ex_Dictionary_Cs,gm_r_ex_Dictionary_Da,gm_r_ex_Dictionary_Nl,^
gm_r_ex_Dictionary_Et,gm_r_ex_Dictionary_Gd,gm_r_ex_Dictionary_Gl,gm_r_ex_Dictionary_Gu,gm_r_ex_Dictionary_He,^
gm_r_ex_Dictionary_Hi,gm_r_ex_Dictionary_Hu,gm_r_ex_Dictionary_Lt,gm_r_ex_Dictionary_Lv,gm_r_ex_Dictionary_Ne,^
gm_r_ex_Dictionary_No,gm_r_ex_Dictionary_Oc,gm_r_ex_Dictionary_Pl,gm_r_ex_Dictionary_Ro,gm_r_ex_Dictionary_Ru,^
gm_r_ex_Dictionary_Si,gm_r_ex_Dictionary_Sk,gm_r_ex_Dictionary_Sl,gm_r_ex_Dictionary_El,gm_r_ex_Dictionary_Es,^
gm_r_ex_Dictionary_Te,gm_r_ex_Dictionary_Th,gm_r_ex_Dictionary_Tr,gm_r_ex_Dictionary_Uk,^
gm_r_ex_Dictionary_Vi,gm_r_ex_Dictionary_Zu,gm_r_ex_Dictionary_Sq,gm_r_ex_Dictionary_Hr,gm_r_ex_Dictionary_De,^
gm_r_ex_Dictionary_Id,gm_r_ex_Dictionary_Is,gm_r_ex_Dictionary_Ko,gm_r_ex_Dictionary_Lo,gm_r_ex_Dictionary_Mn,^
gm_r_ex_Dictionary_Sr,gm_r_ex_Dictionary_Eo,gm_r_ex_Dictionary_It,gm_r_ex_Dictionary_Fr

rem Unzip
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\capa-windows.zip" -o"%TOOLS%\capa"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\chainsaw.zip" -o"%TOOLS%"
if %WSDFIR_CMDER%=="Yes" "%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\cmder.7z" -o"%TOOLS%\cmder"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\cutter.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\CyberChef.zip" -o"%TOOLS%\CyberChef"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\DensityScout.zip" -o"%TEMP%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\dnSpy.zip" -o"%TOOLS%\dnSpy"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\exiftool.zip" -o"%TOOLS%\exiftool"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\fakenet.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\floss.zip" -o"%TOOLS%\floss"
if %WSDFIR_JAVA%=="Yes" "%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\ghidra.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\GoReSym.zip" -o"%TOOLS%\GoReSym"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\hxd.zip" -o"%TOOLS%\hxd"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\loki.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\malcat.zip" -o"%TOOLS%\malcat"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\nmap.exe" -o"%TOOLS%\nmap"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\pebear.zip" -o"%TOOLS%\pebear"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\pestudio.zip" -o"%TOOLS%\pestudio"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\qpdf.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\radare2.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\ripgrep.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\scdbg.zip" -o"%TOOLS%\scdbg"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\sqlite.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\sysinternals.zip" -o"%TOOLS%\sysinternals"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\thumbcacheviewer.zip" -o"%TOOLS%\thumbcacheviewer"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\trid.zip" -o"%TOOLS%\trid"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\triddefs.zip" -o"%TOOLS%\trid"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\upx.zip" -o"%TOOLS%"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\x64dbg.zip" -o"%TOOLS%\x64dbg"
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\yara.zip" -o"%TEMP%"

rem Set Notepad++ as default for many file types
Ftype xmlfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
Ftype txtfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
Ftype chmfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
Ftype cmdfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
Ftype htafile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
Ftype jsefile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
Ftype jsfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
Ftype vbefile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
Ftype vbsfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"

rem Start Sysmon
"%TOOLS%\sysinternals\Sysmon64.exe" -accepteula -i "%TEMP%\sysmonconfig-export.xml"

rem Install packages
"%TOOLS%\hxd\HxDSetup.exe" /VERYSILENT /NORESTART
"%TEMP%\git.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
"%TEMP%\notepad++.exe" /S
"%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%TEMP%\comparePlus.zip" -o"C:\Program Files\Notepad++\Plugins\ComparePlus"
if %WSDFIR_PDFSTREAM%=="Yes" "%TEMP%\PDFStreamDumper.exe" /verysilent
"%TEMP%\python3.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
"%TEMP%\vcredist_x64.exe" /passive /norestart
"%TEMP%\vcredist_16_x64.exe" /passive /norestart
if %WSDFIR_VSCODE%=="Yes" "%TEMP%\vscode.exe" /verysilent /suppressmsgboxes /MERGETASKS="!runcode,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,addtopath"

rem https://www.wireshark.org/docs/wsug_html_chunked/ChBuildInstallWinInstall.html
rem silent install will not install npcap
rem "%TEMP%\wireshark.exe" /S /desktopicon=yes
rem npcap does not support silent install ....
rem "%TEMP%\npcap.exe" /loopback_support=yes

rem Run PowerShell install
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Users\WDAGUtilityAccount\Documents\tools\helpers.ps1" 2>&1 >> C:\temp\log.txt
