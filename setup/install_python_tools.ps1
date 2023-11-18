# Set variables
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1

Write-DateLog "Creating Python venv in Sandbox." >> "C:\log\python.txt"
Write-Output "Get-Content C:\log\python.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# This script runs in a Windows sandbox to prebuild the venv environment.
Remove-Item "C:\venv\done" > $null
Remove-Item -r C:\venv\default\* > $null
Remove-Item -r C:\venv\dfir-unfurl\* > $null

Write-DateLog "Install Python in Sandbox." >> "C:\log\python.txt"
Start-Process "$SETUP_PATH\python3.exe" -Wait -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
Get-Job | Receive-Job >> "C:\log\python.txt"

$PYTHON_BIN="$env:ProgramFiles\Python311\python.exe"

Write-DateLog "Install packages in venv default in sandbox." >> "C:\log\python.txt"
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\default"
C:\venv\default\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U setuptools wheel >> "C:\log\python.txt"
# TODO: Get latest version of package
python -m pip install https://github.com/msuhanov/dfir_ntfs/archive/1.1.18.tar.gz >> "C:\log\python.txt"

python -m pip install `
    aiohttp[speedups] `
    aiosignal>=1.2.0 `
    async_timeout>=4.0.1 `
    attrs>=22.2.0 `
    autoit-ripper `
    beautifulsoup4>=4.12.1 `
    cabarchive `
    capstone `
    certifi>=2023.5.7 `
    chardet>=5.0.0 `
    charset_normalizer>=3.1.0 `
    chepy[extras] `
    click>=8.1.5 `
    colorama `
    construct>=2.10.68 `
    cryptography>=41.0.1 `
    dnslib `
    docx2txt `
    dotnetfile `
    dpkt `
    elasticsearch[async] `
    elastic_transport>=8.1.2 `
    evtx `
    extract-msg `
    python-magic `
    python-magic-bin `
    fonttools `
    hachoir `
    idna>=3.2 `
    ijson `
    importlib-metadata>=6.5.0 `
    jedi>=0.19.0 `
    jinja2 `
    jsbeautifier `
    keyring>=23.13.1 `
    keystone-engine `
    LnkParse3 `
    lxml `
    MarkupSafe>=2.1.3 `
    minidump `
    mkyara `
    msgpack `
    msoffcrypto-tool `
    multidict>=6.0.0 `
    name-that-hash `
    neo4j `
    neo4j-driver `
    numpy `
    olefile `
    oletools[full]>=0.60.1 `
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
    prompt_toolkit>=3.0.35 `
    protobuf>=4.22.0 `
    protodeep `
    ptpython>=3.0.23 `
    pycryptodome `
    pycryptodomex>=3.17.0 `
    pyelftools `
    Pygments>=2.16.0 `
    pyOneNote `
    pyparsing>=2.4.6 `
    pypng `
    python-magic-bin `
    pywin32 `
    pyzipper `
    python-magic `
    regipy `
    requests `
    setuptools `
    soupsieve>=2.4.1 `
    time-decode `
    tomlkit `
    tqdm `
    tzdata>=2023.1 `
    uncompyle6 `
    unicorn `
    unpy2exe `
    urllib3>=2.0.7 `
    visidata>=2.11 `
    xlrd>=2.0.0 `
    XLMMacroDeobfuscator>=0.2.5 `
    xxhash>=3.3.0 `
    yara-python 2>&1 >> "C:\log\python.txt"

python -m pip install jupyterlab 2>&1 >> "C:\log\python.txt"

# Not compatible with Python 3.11:
#     regipy[full]>=3.1.6 - https://github.com/astanin/python-tabulate

python -m pip install -U https://github.com/DissectMalware/pyOneNote/archive/master.zip --force >> "C:\log\python.txt"
Set-Location "C:\venv\default\Scripts"
curl -o "shellconv.py" "https://raw.githubusercontent.com/hasherezade/shellconv/master/shellconv.py"
curl -o "SQLiteWalker.py" "https://raw.githubusercontent.com/stark4n6/SQLiteWalker/main/SQLiteWalker.py"
curl -o "parseUSBs.py" "https://raw.githubusercontent.com/khyrenz/parseusbs/main/parseUSBs.py"
curl -o "machofile-cli.py" "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile-cli.py"
curl -o "machofile.py" "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile.py"

(Get-Content .\parseUSBs.py -raw) -replace "#!/bin/python","#!/usr/bin/env python" | Set-Content -Path ".\parseUSBs2.py"
Copy-Item parseUSBs2.py parseUSBs.py
Remove-Item parseUSBs2.py
Copy-Item $SETUP_PATH\msidump.py .\msidump.py

New-Item -ItemType Directory C:\tmp\rename > $null 2>&1
Get-ChildItem C:\venv\default\Scripts\ -Exclude *.exe,*.py,*.ps1,activate,__pycache__,*.bat | ForEach-Object { Move-Item $_ C:\tmp\rename }
Set-Location C:\tmp\rename
Get-ChildItem | Rename-Item -newname  { $_.Name +".py" }
Copy-Item * C:\venv\default\Scripts
deactivate
Write-DateLog "Python venv default done." >> "C:\log\python.txt"

# dfir-unfurl
Write-DateLog "Install packages in venv dfir-unfurl in sandbox (needs older packages)." >> "C:\log\python.txt"
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\dfir-unfurl"
C:\venv\dfir-unfurl\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U setuptools wheel >> "C:\log\python.txt"

python -m pip install `
    dfir-unfurl `
    hexdump `
    tomlkit 2>&1 >> "C:\log\python.txt"

Write-DateLog "Python venv dfir-unfurl done. Will update path and cache Cloudflare." >> "C:\log\python.txt"

$baseHtmlPath = "C:\venv\dfir-unfurl\Lib\site-packages\unfurl\templates\base.html"
$baseHtmlContent = Get-Content $baseHtmlPath -Raw
$urls = [regex]::Matches($baseHtmlContent, 'https://cdnjs.cloudflare.com[^"]+')

# Download each file and update the base.html content with the local path
foreach ($url in $urls) {
    $fileName = $url.Value.Split("/")[-1]
    $staticPath = "C:\venv\dfir-unfurl\Lib\site-packages\unfurl\static\$fileName"
    Write-DateLog "Downloading $url.Value to $staticPath." >> "C:\log\python.txt"
    Invoke-WebRequest -Uri $url.Value -OutFile $staticPath
    $baseHtmlContent = $baseHtmlContent.slace($url.Value, "/static/$fileName")
}
Set-Content -Path $baseHtmlPath -Value $baseHtmlContent
deactivate
Write-DateLog "Python venv dfir-unfurl cache done." >> "C:\log\python.txt"

# pySigma
Write-DateLog "Install packages in venv pySigma in sandbox (needs older packages that conflicts with oletools)." >> "C:\log\python.txt"
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\pySigma"
C:\venv\pySigma\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U setuptools wheel >> "C:\log\python.txt"

python -m pip install `
    pySigma>=0.9.6 `
    wheel>=0.41.3 2>&1 >> "C:\log\python.txt"
deactivate
Write-DateLog "Python venv pySigma done." >> "C:\log\python.txt"

# pe2pic
Write-DateLog "Install packages in venv pe2pic in sandbox (needs older packages)." >> "C:\log\python.txt"
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\pe2pic"
C:\venv\pe2pic\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U setuptools wheel >> "C:\log\python.txt"

python -m pip install -r https://raw.githubusercontent.com/hasherezade/pe2pic/master/requirements.txt 2>&1 >> "C:\log\python.txt"
Set-Location "C:\venv\pe2pic\Scripts"
curl -o "pe2pic.py" "https://raw.githubusercontent.com/hasherezade/pe2pic/master/pe2pic.py"
deactivate
Write-DateLog "Python venv pe2pic done." >> "C:\log\python.txt"

# evt2sigma
Write-DateLog "Install packages in venv evt2sigma in sandbox (needs older packages)." >> "C:\log\python.txt"
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\evt2sigma"
C:\venv\evt2sigma\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U setuptools wheel >> "C:\log\python.txt"
python -m pip install -r https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/requirements.txt 2>&1 >> "C:\log\python.txt"
Set-Location "C:\venv\evt2sigma\Scripts"
curl -o "evt2sigma.py" "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/evt2sigma.py"

# maldump
Write-DateLog "Install packages in venv maldump in sandbox (needs older packages)." >> "C:\log\python.txt"
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\maldump"
C:\venv\maldump\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U setuptools wheel >> "C:\log\python.txt"
python -m pip install -r https://raw.githubusercontent.com/NUKIB/maldump/v0.2.0/requirements.txt 2>&1 >> "C:\log\python.txt"
python -m pip install maldump==0.2.0 2>&1 >> "C:\log\python.txt"
deactivate

# scare
Write-DateLog "Install packages in venv scare in sandbox (needs older packages)." >> "C:\log\python.txt"
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\scare"
C:\venv\scare\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U ptpython setuptools wheel >> "C:\log\python.txt"

Copy-Item -Recurse "C:\git\scare" "C:\venv\scare"
Set-Location "C:\venv\scare\scare"
(Get-Content .\requirements.txt -raw) -replace "capstone","capstone`npyreadline3" | Set-Content -Path ".\requirements2.txt" -Encoding ascii
python -m pip install -r ./requirements2.txt 2>&1 >> "C:\log\python.txt"
(Get-Content .\scarelib.py -raw) -replace "print(splash)","splash = 'Simple Configurable Asm REPL && Emulator'`nprint(splash)" | Set-Content -Path ".\scarelib2.py" -Encoding ascii
Copy-Item scarelib2.py scarelib.py
Remove-Item scarelib2.py
Copy-Item C:\venv\scare\scare\*.py "C:\venv\scare\Scripts"
deactivate

# Zircolite
Write-DateLog "Install packages in venv Zircolite in sandbox (needs older packages)." >> "C:\log\python.txt"
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\Zircolite"
C:\venv\Zircolite\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip >> "C:\log\python.txt"
python -m pip install -U ptpython setuptools wheel 2>&1 >> "C:\log\python.txt"

Copy-Item -Recurse "C:\git\Zircolite" "C:\venv\Zircolite"
Set-Location "C:\venv\Zircolite\Zircolite"
python -m pip install -r requirements.txt 2>&1 >> "C:\log\python.txt"
deactivate

Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\Zircolite\Scripts\Activate.ps1`nC:\venv\Zircolite\Scripts\ptpython.exe C:\venv\Zircolite\Zircolite\zircolite.py" -Encoding Ascii -Path C:\venv\default\Scripts\zircolite.ps1
Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\dfir-unfurl\Scripts\Activate.ps1`nC:\venv\dfir-unfurl\Scripts\python.exe C:\venv\dfir-unfurl\Scripts\unfurl_app.py" -Encoding Ascii -Path C:\venv\default\Scripts\unfurl_app.ps1
Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\dfir-unfurl\Scripts\Activate.ps1`nC:\venv\dfir-unfurl\Scripts\python.exe C:\venv\dfir-unfurl\Scripts\unfurl_cli.py" -Encoding Ascii -Path C:\venv\default\Scripts\unfurl_cli.ps1
Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\evt2sigma\Scripts\Activate.ps1`nC:\venv\evt2sigma\Scripts\python.exe C:\venv\evt2sigma\Scripts\evt2sigma.py" -Encoding Ascii -Path C:\venv\default\Scripts\evt2sigma.ps1
Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\pe2pic\Scripts\Activate.ps1`nC:\venv\pe2pic\Scripts\python.exe C:\venv\pe2pic\Scripts\pe2pic.py" -Encoding Ascii -Path C:\venv\default\Scripts\pe2pic.ps1
Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\scare\Scripts\Activate.ps1`ncd C:\venv\scare\scare`nC:\venv\scare\Scripts\ptpython.exe C:\venv\scare\scare\scare.py" -Encoding Ascii -Path C:\venv\default\Scripts\scare.ps1
Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\maldump\Scripts\Activate.ps1" -Encoding Ascii -Path C:\venv\default\Scripts\maldump.ps1

Write-Output "" > C:\venv\done