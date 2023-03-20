# Set variables
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$SETUP_PATH="C:\downloads"
$TEMP="C:\tmp"

Write-Output "Creating Python venv in Sandbox." >> "C:\log\python.txt" 2>&1

Write-Output "Get-Content C:\log\python.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# This script runs in a Windows sandbox to prebuild the venv environment.
Remove-Item -r "C:\venv\done" > $null 2>&1
Remove-Item -r "C:\venv\data" > $null 2>&1
Remove-Item -r "C:\venv\Include" > $null 2>&1
Remove-Item -r "C:\venv\Lib" > $null 2>&1
Remove-Item -r "C:\venv\Scripts" > $null 2>&1
Remove-Item -r "C:\venv\share" > $null 2>&1
Remove-Item -r "C:\venv\pyvenv.cfg" > $null 2>&1
Get-ChildItem -Path $TEMP\pip\ -Include *.* -Recurse | ForEach-Object { $_.Delete()} > $null 2>&1

Write-Output "Install Python in Sandbox." >> "C:\log\python.txt" 2>&1
Start-Process "$SETUP_PATH\python3.exe" -Wait -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
Get-Job | Receive-Job >> "C:\log\python.txt" 2>&1

$PYTHON_BIN="$env:ProgramFiles\Python310\python.exe"

&"$PYTHON_BIN" -m venv C:\pip2pi

&"C:\pip2pi\Scripts\Activate.ps1"
Write-Output "Install pip2pi in Sandbox." >> "C:\log\python.txt" 2>&1
&python -m pip install -U pip >> "C:\log\python.txt" 2>&1
&python -m pip install pip2pi >> "C:\log\python.txt" 2>&1

Write-Output "Download packages with pip2pi in Sandbox." >> "C:\log\python.txt" 2>&1
Set-Location C:\
&pip2pi ./tmp/pip `
    aiohttp[speedups] `
    cabarchive `
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
    prettytable>=3.5 `
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
    wheel 2>&1 | findstr /V "ERROR linking" >> "C:\log\python.txt" 2>&1

deactivate

Copy-Item "$SETUP_PATH\dfir_ntfs.tar.gz" "$TEMP\pip"

Write-Output "Install packages in venv in sandbox." >> "C:\log\python.txt" 2>&1
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv"
C:\venv\Scripts\Activate.ps1
Set-Location $TEMP\pip
Get-ChildItem . -Filter wheel* | Foreach-Object { python -m pip install --disable-pip-version-check $_ >> "C:\log\python.txt" 2>&1 }
Get-ChildItem . -Filter *.gz | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ >> "C:\log\python.txt" 2>&1 }
Get-ChildItem . -Filter *.whl | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ >> "C:\log\python.txt" 2>&1 }
Get-ChildItem . -Filter *.zip | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ >> "C:\log\python.txt" 2>&1 }
Copy-Item -r C:\git\threat-intel $TEMP
Copy-Item -r C:\git\dotnetfile $TEMP
Set-Location $TEMP\threat-intel\tools\one-extract
python -m pip install --disable-pip-version-check . >> "C:\log\python.txt" 2>&1
Set-Location $TEMP\dotnetfile
python setup.py install >> "C:\log\python.txt" 2>&1
deactivate
Write-Output "Python venv done." >> "C:\log\python.txt" 2>&1

Write-Output "" > C:\venv\done

shutdown /s /t 1 /c "Done with installing Python pip packages." /f /d p:4:1
