Write-Host "Download Python pip packages."

$VENV = "$env:HOMEDRIVE$env:HOMEPATH\.wsb"

if (Test-Path -Path $VENV) {
    "Path $VENV exists!"
    Exit
}

python3 -m venv "$VENV"
& "$VENV\Scripts\Activate.ps1"

python -m pip install -U pip >> .\log\log.txt
python -m pip install pip2pi >> .\log\log.txt

if (! (Test-Path -Path .\tmp )) {
    New-Item -ItemType Directory -Force -Path .\tmp > $null
}

if (Test-Path -Path .\tmp\pip ) {
    Remove-Item -r .\tmp\pip
}

pip2pi ./tmp/pip `
    chepy[extras] `
    colorama `
    dnslib `
    docx2txt `
    dpkt `
    extract-msg `
    fonttools `
    hachoir `
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
    pandas `
    pcode2code `
    pcodedmp `
    pefile `
    peutils `
    ppdeep `
    pycryptodome `
    pyelftools `
    pyOneNote `
    pypng `
    python-magic-bin `
    pyzipper `
    python-magic `
    setuptools `
    time-decode `
    uncompyle6 `
    unpy2exe `
    visidata `
    xlrd `
    XLMMacroDeobfuscator `
    yara-python `
    wheel 2>&1 | findstr /V "ERROR linking" >> .\log\log.txt

deactivate
Remove-Item -r "$VENV"

Robocopy.exe .\tmp\pip .\tools\downloads\pip /COPY:D /E /PURGE /XN /XO >> .\log\log.txt
