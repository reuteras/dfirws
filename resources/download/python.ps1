Write-Output "Download Python pip packages."

. $PSScriptRoot\common.ps1

$VENV = "$env:HOMEDRIVE$env:HOMEPATH\.wsb"

if (Test-Path -Path $VENV) {
    "Path $VENV exists!"
    Exit
}

python3.10.exe -m venv "$VENV"
& "$VENV\Scripts\Activate.ps1"

python -m pip install -U pip >> .\log\log.txt
python -m pip install pip2pi >> .\log\log.txt

if (! (Test-Path -Path .\tmp )) {
    New-Item -ItemType Directory -Force -Path .\tmp > $null
}

if (! (Test-Path -Path .\mount )) {
    New-Item -ItemType Directory -Force -Path .\mount > $null
}

if (! (Test-Path -Path .\mount\venv )) {
    New-Item -ItemType Directory -Force -Path .\mount\venv > $null
}

if (Test-Path -Path .\tmp\pip ) {
    Remove-Item -r -Force .\tmp\pip
}

pip2pi ./tmp/pip `
    aiohttp[speedups] `
    chepy[extras] `
    colorama `
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
    wheel 2>&1 | findstr /V "ERROR linking" >> .\log\log.txt

deactivate
Remove-Item -r -Force "$VENV"

Copy-Item ./downloads/dfir_ntfs.tar.gz ./tmp/pip/

Robocopy.exe .\tmp\pip .\downloads\pip /COPY:D /E /PURGE /XN /XO >> .\log\log.txt

$ROOT_PATH=Resolve-Path "$PSScriptRoot\..\..\"

Remove-Item -r -Force .\tmp\venv > $null 2>&1
mkdir .\tmp\venv > $null 2>&1

(Get-Content generate_venv.wsb.template).replace('__SANDBOX__', $ROOT_PATH) | Set-Content .\generate_venv.wsb
.\generate_venv.wsb
Start-Sleep 10
Remove-Item .\generate_venv.wsb
