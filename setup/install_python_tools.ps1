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

$PYTHON_BIN="$env:ProgramFiles\Python310\python.exe"

&"$PYTHON_BIN" -m venv C:\pip2pi

&"C:\pip2pi\Scripts\Activate.ps1"
Write-DateLog "Install pip2pi in Sandbox." >> "C:\log\python.txt" 2>&1
&python -m pip install -U pip >> "C:\log\python.txt" 2>&1
&python -m pip install pip2pi >> "C:\log\python.txt" 2>&1

Write-DateLog "Download packages with pip2pi in Sandbox." >> "C:\log\python.txt" 2>&1
Set-Location C:\
&pip2pi ./tmp/pip/default `
    aiohttp[speedups] `
    cabarchive `
    capstone `
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
    ijson `
    jinja2 `
    jsbeautifier `
    keystone-engine `
    LnkParse3 `
    lxml `
    maldump `
    minidump `
    mkyara `
    msgpack `
    msoffcrypto-tool `
    name-that-hash `
    neo4j `
    neo4j-driver `
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
    pyhindsight `
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
    tomlkit `
    tqdm `
    uncompyle6 `
    unicorn `
    unpy2exe `
    urllib3 `
    visidata `
    xlrd `
    XLMMacroDeobfuscator `
    xxhash `
    yara-python `
    wheel 2>&1 | findstr /V "ERROR linking" | findstr /V "Access is denied:" | findstr /V "skipping WinError" >> "C:\log\python.txt" 2>&1

Set-Location C:\
&pip2pi ./tmp/pip/dfir-unfurl `
    dfir-unfurl `
    hexdump `
    tomlkit `
    wheel 2>&1 | findstr /V "ERROR linking" | findstr /V "Access is denied:" | findstr /V "skipping WinError" >> "C:\log\python.txt" 2>&1

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

Copy-Item -r C:\git\threat-intel $TEMP
Set-Location $TEMP\threat-intel\tools\one-extract
python -m pip install --disable-pip-version-check . >> "C:\log\python.txt" 2>&1

deactivate
Write-DateLog "Python venv default done." >> "C:\log\python.txt" 2>&1

Write-DateLog "Install packages in venv dfir-unfurl in sandbox (needs older packages)." >> "C:\log\python.txt" 2>&1
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\dfir-unfurl"
C:\venv\dfir-unfurl\Scripts\Activate.ps1 >> "C:\log\python.txt" 2>&1
Set-Location $TEMP\pip\dfir-unfurl
Install-PythonPackage | Out-Null
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
    $baseHtmlContent = $baseHtmlContent.Replace($url.Value, "/static/$fileName")
}

Set-Content -Path $baseHtmlPath -Value $baseHtmlContent

deactivate
Write-DateLog "Python venv dfir-unfurl cache done." >> "C:\log\python.txt" 2>&1

Write-Output "" > C:\venv\done

shutdown /s /t 1 /c "Done with installing Python pip packages." /f /d p:4:1
