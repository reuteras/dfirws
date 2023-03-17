# First start logging
Start-Transcript -Append "C:\log\python.txt"

# Set variables
$SETUP_PATH="C:\downloads"
$TEMP="C:\tmp"

Write-Output "Get-Content C:\log\python.txt -Wait" | Out-File -FilePath "C:\Progress.ps1"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd"

# This script runs in a Windows sandbox to prebuild the venv environment.
Write-Output "Install Python based tools"
Remove-Item -r "C:\venv\data" > $null 2>&1
Remove-Item -r "C:\venv\Include" > $null 2>&1
Remove-Item -r "C:\venv\Lib" > $null 2>&1
Remove-Item -r "C:\venv\Scripts" > $null 2>&1
Remove-Item -r "C:\venv\share" > $null 2>&1
Remove-Item -r "C:\venv\pyvenv.cfg" > $null 2>&1
Get-ChildItem -Path $TEMP\pip\ -Include *.* -Recurse | ForEach-Object { $_.Delete()} > $null 2>&1

& "$SETUP_PATH\python3.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

$PYTHON_BIN="$env:ProgramFiles\Python310\python.exe"

while (Get-Process python3 2> $null) {
    Start-Sleep 1
}

& $PYTHON_BIN -m venv "C:\pip2pi"
& "C:\pip2pi\Scripts\Activate.ps1"

python -m pip install -U pip
python -m pip install pip2pi

Set-Location C:\
pip2pi ./tmp/pip `
    aiohttp[speedups] `
    chepy[extras] `
    colorama `
    dfir-unfurl `
    dnslib `
    docx2txt `
    dpkt `
    elasticsearch[async] `
    evtx `
    extract-msg `
    fonttools `
    hachoir `
    jinja2 `
    jsbeautifier `
    LnkParse3 `
    lxml `
    maldump `
    minidump `
    mkyara `
    msgpack `
    msoffcrypto-tool `
    name-that-hash `
    numpy `
    olefile `
    oletools[full] `
    openpyxl `
    orjson `
    pandas `
    pcode2code `
    pcodedmp `
    pefile `
    peutils `
    pillow `
    ppdeep `
    protobuf>=4.22.0 `
    protodeep `
    pycryptodome `
    pyelftools `
    pyOneNote `
    pypng `
    python-magic-bin `
    pywin32 `
    pyzipper `
    python-magic `
    regipy[full] `
    requests `
    setuptools `
    time-decode `
    tqdm `
    uncompyle6 `
    unpy2exe `
    urllib3 `
    visidata `
    xlrd `
    XLMMacroDeobfuscator `
    xxhash `
    yara-python `
    wheel 2>&1 | findstr /V "ERROR linking"

deactivate

Copy-Item $SETUP_PATH\dfir_ntfs.tar.gz $TEMP\pip

& $PYTHON_BIN -m venv C:\venv
C:\venv\Scripts\Activate.ps1
Set-Location $TEMP\pip
Get-ChildItem . -Filter wheel* | Foreach-Object { python -m pip install --disable-pip-version-check $_ }
Get-ChildItem . -Filter *.gz | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ }
Get-ChildItem . -Filter *.whl | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ }
Get-ChildItem . -Filter *.zip | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ }
Copy-Item -r C:\git\threat-intel $TEMP
Copy-Item -r C:\git\dotnetfile $TEMP
Set-Location $TEMP\threat-intel\tools\one-extract
python -m pip install --disable-pip-version-check .
Set-Location $TEMP\dotnetfile
python setup.py install
deactivate
Write-Output "Installed Python based tools done"

Write-Output "" > C:\venv\done
Stop-Transcript

shutdown /s /t 1 /c "Done with installing Python pip packages." /f /d p:4:1
