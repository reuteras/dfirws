# Set variables
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$SETUP_PATH="C:\downloads"
$TEMP="C:\tmp"

. C:\Users\WDAGUtilityAccount\Documents\tools\common.ps1

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
    dpkt `
    elasticsearch[async] `
    elastic_transport>=8.1.2 `
    evtx `
    extract-msg `
    fonttools `
    hachoir `
    idna>=3.2 `
    ijson `
    importlib-metadata>=6.5.0 `
    jinja2 `
    jsbeautifier `
    keyring>=23.13.1 `
    keystone-engine `
    LnkParse3 `
    lxml `
    maldump `
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
    pycryptodome `
    pycryptodomex>=3.17.0 `
    pyelftools `
    pyOneNote `
    pyparsing>=2.4.6 `
    pypng `
    pyreadline `
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
    urllib3>=2.0.6 `
    visidata>=2.11 `
    xlrd>=2.0.0 `
    XLMMacroDeobfuscator>=0.2.5 `
    xxhash>=3.3.0 `
    yara-python 2>&1 >> "C:\log\python.txt"

python -m pip install `
    jupyterlab 2>&1 >> "C:\log\python.txt"

# Not compatible with Python 3.11:
#     regipy[full]>=3.1.6 - https://github.com/astanin/python-tabulate

Copy-Item -r C:\git\dotnetfile $TEMP
Set-Location $TEMP\dotnetfile
python -m pip install . >> "C:\log\python.txt" 2>&1

python -m pip install -U https://github.com/DissectMalware/pyOneNote/archive/master.zip --force >> "C:\log\python.txt"

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
    tomlkit `
    wheel>=0.40.0 2>&1 >> "C:\log\python.txt" 

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

Write-Output "" > C:\venv\done
