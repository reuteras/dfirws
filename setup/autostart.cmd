rem Set variables
set SETUP_PATH=C:\downloads
set TEMP=C:\tmp
set TOOLS=C:\Tools

rem Create directories
mkdir %TEMP%
mkdir %TEMP%\yararules
mkdir C:\Users\WDAGUtilityAccount\Documents\WindowsPowerShell

copy "C:\Users\WDAGUtilityAccount\Documents\tools\config.txt" %TEMP%\config.bat
copy "C:\Users\WDAGUtilityAccount\Documents\tools\default-config.txt" %TEMP%\default-config.bat
call %TEMP%\default-config.bat
call %TEMP%\config.bat

copy "C:\Users\WDAGUtilityAccount\Documents\tools\.bashrc" "C:\Users\WDAGUtilityAccount\"

rem Install msi packages
copy "%SETUP_PATH%\7zip.msi" "%TEMP%\7zip.msi"
msiexec /i "%TEMP%\7zip.msi" /qn /norestart
if %WSDFIR_JAVA%=="Yes" copy "%SETUP_PATH%\corretto.msi" "%TEMP%\corretto.msi"
if %WSDFIR_JAVA%=="Yes" msiexec /i "%TEMP%\corretto.msi" /qn /norestart
if %WSDFIR_LIBREOFFICE%=="Yes" copy "%SETUP_PATH%\LibreOffice.msi" "%TEMP%\LibreOffice.msi"
if %WSDFIR_LIBREOFFICE%=="Yes" msiexec /qb /i "%TEMP%\LibreOffice.msi" /l* %TEMP%\LibreOffice_install_log.txt REGISTER_ALL_MSO_TYPES=1 UI_LANGS=en_US ISCHECKFORPRODUCTUPDATES=0 ^
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

rem Set Notepad++ as default for many file types
if %WSDFIR_GIT%=="Yes" (
    Ftype xmlfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
    Ftype txtfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
    Ftype chmfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
    Ftype cmdfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
    Ftype htafile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
    Ftype jsefile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
    Ftype jsfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
    Ftype vbefile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
    Ftype vbsfile="C:\Program Files\Notepad++\notepad++.exe" "%%*"
) else (
    Ftype xmlfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    Ftype txtfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    Ftype chmfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    Ftype cmdfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    Ftype htafile="C:\WINDOWS\system32\notepad.exe" "%%*"
    Ftype jsefile="C:\WINDOWS\system32\notepad.exe" "%%*"
    Ftype jsfile="C:\WINDOWS\system32\notepad.exe" "%%*"
    Ftype vbefile="C:\WINDOWS\system32\notepad.exe" "%%*"
    Ftype vbsfile="C:\WINDOWS\system32\notepad.exe" "%%*"
)

rem Start Sysmon
"%TOOLS%\sysinternals\Sysmon64.exe" -accepteula -i "%SYSMON_CONF%"

rem Install packages
copy "%SETUP_PATH%\python3.exe" "%TEMP%\python3.exe"
copy "%SETUP_PATH%\vcredist_x64.exe" "%TEMP%\vcredist_x64.exe"
copy "%SETUP_PATH%\vcredist_16_x64.exe" "%TEMP%\vcredist_16_x64.exe"
"%SETUP_PATH%\python3.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
"%SETUP_PATH%\vcredist_x64.exe" /passive /norestart
"%SETUP_PATH%\vcredist_16_x64.exe" /passive /norestart

if %WSDFIR_HXD%=="Yes" copy "%SETUP_PATH%\hxd\HxDSetup.exe" "%TEMP%\HxDSetup.exe"
if %WSDFIR_HXD%=="Yes" "%TEMP%\HxDSetup.exe" /VERYSILENT /NORESTART
if %WSDFIR_GIT%=="Yes" copy "%SETUP_PATH%\git.exe" "%TEMP%\git.exe"
if %WSDFIR_GIT%=="Yes" "%TEMP%\git.exe" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
if %WSDFIR_NPP%=="Yes" copy "%SETUP_PATH%\notepad++.exe" "%TEMP%\notepad++.exe"
if %WSDFIR_NPP%=="Yes" "%TEMP%\notepad++.exe" /S
if %WSDFIR_NPP%=="Yes" "%PROGRAMFILES%\7-Zip\7z.exe" x -aoa "%SETUP_PATH%\comparePlus.zip" -o"C:\Program Files\Notepad++\Plugins\ComparePlus"
if %WSDFIR_PDFSTREAM%=="Yes" copy "%SETUP_PATH%\PDFStreamDumper.exe" "%TEMP%\PDFStreamDumper.exe"
if %WSDFIR_PDFSTREAM%=="Yes" "%TEMP%\PDFStreamDumper.exe" /verysilent
if %WSDFIR_VSCODE%=="Yes" copy "%SETUP_PATH%\vscode.exe" "%TEMP%\vscode.exe"
if %WSDFIR_VSCODE%=="Yes" "%TEMP%\vscode.exe" /verysilent /suppressmsgboxes /MERGETASKS="!runcode,desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,addtopath"

rem Run PowerShell install
PowerShell.exe -ExecutionPolicy Bypass -File "C:\Users\WDAGUtilityAccount\Documents\tools\helpers.ps1" 2>&1 >> %TEMP%\log.txt
