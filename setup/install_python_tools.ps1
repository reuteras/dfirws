# Set variables
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$SETUP_PATH="C:\downloads"
$TEMP="C:\tmp"

. C:\Users\WDAGUtilityAccount\Documents\tools\common.ps1

# Local function
function Install-PythonPackage {
    Get-ChildItem . -Filter wheel* | Foreach-Object { python -m pip install --disable-pip-version-check $_ >> "C:\log\python.txt" 2>&1 }
    Get-ChildItem . -Filter tomlkit* | Foreach-Object { python -m pip install --disable-pip-version-check $_ >> "C:\log\python.txt" 2>&1 }
    Get-ChildItem . -Filter *.gz | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ >> "C:\log\python.txt" 2>&1 }
    Get-ChildItem . -Filter *.whl | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ >> "C:\log\python.txt" 2>&1 }
    Get-ChildItem . -Filter *.zip | Foreach-Object { python -m pip install --disable-pip-version-check --no-deps --no-build-isolation $_ >> "C:\log\python.txt" 2>&1 }
    return
}

Write-DateLog "Creating Python venv in Sandbox." >> "C:\log\python.txt" 2>&1

Write-Output "Get-Content C:\log\python.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# This script runs in a Windows sandbox to prebuild the venv environment.
Remove-Item "C:\venv\done" > $null 2>&1
Remove-Item -r C:\venv\default\* > $null 2>&1
Remove-Item -r C:\venv\dfir-unfurl\* > $null 2>&1
Get-ChildItem -Path $TEMP\pip\default -Include *.* -Recurse | ForEach-Object { $_.Delete()} > $null 2>&1
Get-ChildItem -Path $TEMP\pip\dfir-unfurl -Include *.* -Recurse | ForEach-Object { $_.Delete()} > $null 2>&1

Write-DateLog "Install Python in Sandbox." >> "C:\log\python.txt" 2>&1
Start-Process "$SETUP_PATH\python3.exe" -Wait -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
Get-Job | Receive-Job >> "C:\log\python.txt" 2>&1

$PYTHON_BIN="$env:ProgramFiles\Python311\python.exe"

&"$PYTHON_BIN" -m venv C:\pip2pi

&"C:\pip2pi\Scripts\Activate.ps1"
Write-DateLog "Install pip2pi in Sandbox." >> "C:\log\python.txt" 2>&1
&python -m pip install -U pip >> "C:\log\python.txt" 2>&1
&python -m pip install pip2pi >> "C:\log\python.txt" 2>&1

Write-DateLog "Download packages with pip2pi in Sandbox." >> "C:\log\python.txt" 2>&1
Set-Location C:\
&pip2pi ./tmp/pip/default `
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
    pyhindsight `
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
    time-decode `
    tomlkit `
    tqdm `
    tzdata>=2023.1 `
    uncompyle6 `
    unicorn `
    unpy2exe `
    urllib3>=1.26.15 `
    visidata>=2.11 `
    xlrd>=2.0.0 `
    XLMMacroDeobfuscator>=0.2.5 `
    xxhash `
    yara-python `
    wheel>=0.40.0 2>&1 | findstr /V "ERROR linking" | findstr /V "Access is denied:" | findstr /V "skipping WinError" >> "C:\log\python.txt" 2>&1

# Not compatible with Python 3.11:
#     regipy[full]>=3.1.6 - https://github.com/astanin/python-tabulate

Set-Location C:\
&pip2pi ./tmp/pip/dfir-unfurl `
    dfir-unfurl `
    hexdump `
    tomlkit `
    wheel>=0.40.0 2>&1 | findstr /V "ERROR linking" | findstr /V "Access is denied:" | findstr /V "skipping WinError" >> "C:\log\python.txt" 2>&1

Set-Location C:\
&pip2pi ./tmp/pip/pySigma `
    pySigma>=0.9.6 `
    wheel>=0.40.0 2>&1 | findstr /V "ERROR linking" | findstr /V "Access is denied:" | findstr /V "skipping WinError" >> "C:\log\python.txt" 2>&1

deactivate

Write-DateLog "Install packages in venv default in sandbox." >> "C:\log\python.txt" 2>&1
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\default"
C:\venv\default\Scripts\Activate.ps1 >> "C:\log\python.txt" 2>&1

Copy-Item "$SETUP_PATH\dfir_ntfs.tar.gz" "$TEMP\pip\default"

Set-Location $TEMP\pip\default
Install-PythonPackage

Copy-Item -r C:\git\dotnetfile $TEMP
Set-Location $TEMP\dotnetfile
python -m pip install --disable-pip-version-check . >> "C:\log\python.txt" 2>&1

Copy-Item -r C:\git\one-extract $TEMP
Set-Location $TEMP\one-extract
python -m pip install --disable-pip-version-check . >> "C:\log\python.txt" 2>&1

deactivate
Write-DateLog "Python venv default done." >> "C:\log\python.txt" 2>&1

Write-DateLog "Install packages in venv dfir-unfurl in sandbox (needs older packages)." >> "C:\log\python.txt" 2>&1
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\dfir-unfurl"
C:\venv\dfir-unfurl\Scripts\Activate.ps1 >> "C:\log\python.txt" 2>&1
Set-Location $TEMP\pip\dfir-unfurl
Install-PythonPackage
Write-DateLog "Python venv dfir-unfurl done. Will update path and cache Cloudflare." >> "C:\log\python.txt" 2>&1

$baseHtmlPath = "C:\venv\dfir-unfurl\Lib\site-packages\unfurl\templates\base.html"
$baseHtmlContent = Get-Content $baseHtmlPath -Raw
$urls = [regex]::Matches($baseHtmlContent, 'https://cdnjs.cloudflare.com[^"]+')

# Download each file and update the base.html content with the local path
foreach ($url in $urls) {
    $fileName = $url.Value.Split("/")[-1]
    $staticPath = "C:\venv\dfir-unfurl\Lib\site-packages\unfurl\static\$fileName"
    Write-DateLog "Downloading $url.Value to $staticPath." >> "C:\log\python.txt" 2>&1
    Invoke-WebRequest -Uri $url.Value -OutFile $staticPath
    $baseHtmlContent = $baseHtmlContent.slace($url.Value, "/static/$fileName")
}

Set-Content -Path $baseHtmlPath -Value $baseHtmlContent

deactivate
Write-DateLog "Python venv dfir-unfurl cache done." >> "C:\log\python.txt" 2>&1

Write-DateLog "Install packages in venv pySigma in sandbox (needs older packages that conflicts with oletools)." >> "C:\log\python.txt" 2>&1
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\pySigma"
C:\venv\pySigma\Scripts\Activate.ps1 >> "C:\log\python.txt" 2>&1
Set-Location $TEMP\pip\pySigma
Install-PythonPackage | Out-Null
deactivate
Write-DateLog "Python venv pySigma done." >> "C:\log\python.txt" 2>&1

Write-Output "" > C:\venv\done
