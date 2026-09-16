# Set default encoding to UTF8
# GHIDRA_INSTALL_DIR is referenced in commented-out code below
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-Output "Start installation of Python in Sandbox."

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"
. "C:\Users\WDAGUtilityAccount\Documents\tools\shared.ps1"

$TOOL_DEFINITIONS = @()
$PYTHON_DEFAULT = "3.11"

# Python interpreters available for uv tool installs, keyed by version. uv tool
# venvs reference the interpreter by absolute path, so every version listed here
# must also be installed by start_sandbox.ps1 in the final (offline) sandbox.
# To move a tool to a newer Python: pass -PythonVersion to Install-UvTool and set
# PythonVersion in its TOOL_DEFINITIONS entry to the same value.
$PYTHON_INTERPRETERS = @{
    "3.11" = "C:\Program Files\Python311\python.exe"
    "3.13" = "C:\Program Files\Python313\python.exe"
}

# Installs a package with "uv tool install" on the requested Python version,
# logs the result and records changelog metadata.
#   -Package  requirement spec passed to uv (name, name[extra]@ver, git+https URL)
#   -Name     package name for metadata when -Package is not a plain name
#   -With     extra requirements (uv --with), comma separated
function Install-UvTool {
    param (
        [Parameter(Mandatory=$True)] [string]$Package,
        [Parameter(Mandatory=$False)] [string]$PythonVersion = $PYTHON_DEFAULT,
        [Parameter(Mandatory=$False)] [string]$With = "",
        [Parameter(Mandatory=$False)] [string]$Name = ""
    )

    $label = if ($Name) { $Name } else { $Package }
    $python = $PYTHON_INTERPRETERS[$PythonVersion]
    if (-not $python -or -not (Test-Path $python)) {
        Write-DateLog "ERROR: Python $PythonVersion is not installed, skipping $label." 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
        return
    }

    $uvArgs = @("tool", "install", "--python", $python)
    if ($With) {
        $uvArgs += @("--with", $With)
    }
    $uvArgs += $Package
    uv @uvArgs 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
    Write-DateLog "Installed $label via uv tool install (Python $PythonVersion)." 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
    Save-UvToolMetadata -Package $label 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
}

$GHIDRA_INSTALL_DIR = ""
if (Test-Path "${TOOLS}\ghidra\") {
    $GHIDRA_INSTALL_DIR = (Get-ChildItem "${TOOLS}\ghidra\").FullName | findstr.exe PUBLIC | Select-Object -Last 1
}

$env:UV_TOOL_BIN_DIR = "C:\venv\bin"
$env:UV_TOOL_DIR = "C:\venv\uv"
$env:UV_INSTALL_DIR = "C:\venv\pkg"
$env:UV_PYTHON_INSTALL_DIR = "C:\venv\python"
$env:UV_CACHE_DIR = "C:\venv\cache"
$env:UV_LINK_MODE = "copy"
$env:UV_CONCURRENT_INSTALLS = "1"

foreach ($dir in @($env:UV_TOOL_BIN_DIR, $env:UV_TOOL_DIR, $env:UV_INSTALL_DIR, $env:UV_CACHE_DIR)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")+ ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

Add-ToUserPath "${env:ProgramFiles}\Git\bin" | Out-Null
Add-ToUserPath "${env:ProgramFiles}\Git\cmd" | Out-Null
Add-ToUserPath "${TOOLS}\bin" | Out-Null
Add-ToUserPath "C:\venv\bin" | Out-Null

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}

Write-Output "Get-Content C:\log\python.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

# Ugly fix
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CI\Policy" /v VerifiedAndReputablePolicyState /t REG_DWORD /d 0 /f
"`n" | CiTool.exe -r

# Install Visual C++ Redistributable 16 and 17
Start-Process -Wait "${SETUP_PATH}\vcredist_17_x64.exe" -ArgumentList "/passive /norestart"
Write-DateLog "Visual C++ Redistributable installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append

# Install .NET 6
if (Test-Path "${SETUP_PATH}\dotnet6desktop.exe") {
    Start-Process -Wait "${SETUP_PATH}\dotnet6desktop.exe" -ArgumentList "/install /quiet /norestart"
    Write-DateLog ".NET 6 Desktop runtime installed" | Tee-Object -FilePath "${WSDFIR_TEMP}\start_sandbox.log" -Append
}

Write-DateLog "Install Git." >> "C:\log\python.txt"
Install-Git | Out-Null
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
git config --global --add safe.directory '*' 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

Write-DateLog "Install Python in Sandbox." >> "C:\log\python.txt"
if (Test-ToolIncludedSandbox -ToolName "python3.13") {
    Start-Process "${SETUP_PATH}\python3.13.exe" -Wait -ArgumentList "/quiet InstallAllUsers=1 PrependPath=0 Include_test=0"
}
Start-Process "${SETUP_PATH}\python3.exe" -Wait -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
$iniPath = "$env:LOCALAPPDATA\py.ini"
Write-Output "[defaults]" > $iniPath
Write-Output "python=3.11" >> $iniPath
cp $iniPath "C:\Windows\py.ini" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
py -0 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Get-Job | Receive-Job 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

#
# Install Python packages
#
Write-DateLog "Install Python packages in sandbox." >> "C:\log\python.txt"
Install-UvTool -Package "git+https://github.com/msuhanov/dfir_ntfs.git" -Name "dfir_ntfs"
Install-UvTool -Package "regipy[rust]>=4.0.0" -With "click, libfwsi-python, mcp, python-evtx, tabulate, zipp" -Name "regipy"
Install-UvTool -Package "peepdf-3" -With "pyreadline3, stpyv8"
Install-UvTool -Package "zensical"
Install-UvTool -Package "git+https://github.com/Hexastrike/PyrsistenceSniper.git" -Name "PyrsistenceSniper"

if (Test-ToolIncludedSandbox -ToolName "binary-refinery") {
    Install-UvTool -Package "binary-refinery[extended]@0.9.26" -Name "binary-refinery"
}

foreach ($package in `
    "apkid", `
    "autoit-ripper", `
    "cart", `
    "chepy", `
    "csvkit", `
    "deep_translator", `
    "docx2txt", `
    "extract-msg>=0.48.4", `
    "flatten_json", `
    "frida-tools", `
    "ghidrecomp", `
    "ghidriff", `
    "grip", `
    "hachoir", `
    "jsbeautifier", `
    "jupyterlab", `
    "litecli", `
    "LnkParse3", `
    "magika", `
    "maldump", `
    "malwarebazaar", `
    "markitdown[all]", `
    "minidump", `
    "mkyara", `
    "msoffcrypto-tool", `
    "mvt", `
    "mwcp", `
    "name-that-hash", `
    "netaddr", `
    "numpy", `
    "oletools[full]", `
    "pcode2code", `
    "pdfalyzer", `
    "pip", `
    "protodeep", `
    "ptpython", `
    "pwncat", `
    "pyinstxtractor-ng", `
    "pynvim", `
    "pyOneNote", `
    "pypng", `
    "rexi", `
    "scapy", `
    "shodan", `
    "stego-lsb", `
    "sqlit-tui[all]", `
    "time-decode", `
    "toolong", `
    "unpy2exe", `
    "visidata", `
    "xlrd", `
    "XLMMacroDeobfuscator", `
    "XlsxWriter" ) {
        Install-UvTool -Package $package
}

# speakeasy-emulator requires setuptools (pkg_resources); use python -m venv + pip to ensure it is available
# uv pip install does not reliably expose pkg_resources even when setuptools is installed
& "C:\Program Files\Python311\python.exe" -m venv "C:\venv\speakeasy" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
& "C:\venv\speakeasy\Scripts\pip.exe" install setuptools speakeasy-emulator 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\speakeasy\Scripts\speakeasy.exe" "C:\venv\bin\speakeasy.exe" -Force 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
Save-VenvPackageMetadata -Venv "speakeasy" -Python "C:\venv\speakeasy\Scripts\python.exe" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
Write-DateLog "Installed speakeasy-emulator in dedicated venv." 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"

# Download IOCs for mvt
 mvt-ios download-iocs 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
 New-Item -ItemType Directory -Force -Path "C:\venv\iocs" | Out-Null
 Copy-Item "C:\Users\WDAGUtilityAccount\AppData\Local\mvt" "C:\venv\iocs" -Recurse -Force 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"

# Profile-conditional Python packages
if (Test-ToolIncludedSandbox -ToolName "jpterm") {
    Install-UvTool -Package "jpterm"
}

# Tools that need a newer Python than $PYTHON_DEFAULT. filterforge requires >= 3.12.
if ((Test-ToolIncludedSandbox -ToolName "python3.13") -and (Test-ToolIncludedSandbox -ToolName "filterforge")) {
    Install-UvTool -Package "git+https://github.com/cloudflare/filterforge.git" -Name "filterforge" -PythonVersion "3.13"
}

Write-DateLog "Install extra scripts in Tools\bin." >> "C:\log\python.txt"
Set-Location "C:\Tools\bin"
Get-RawGitHubFile -OutFile "machofile-cli.py" -Url "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile-cli.py"
Get-RawGitHubFile -OutFile "machofile.py" -Url "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile.py"
Get-RawGitHubFile -OutFile "msidump.py" -Url "https://raw.githubusercontent.com/mgeeky/msidump/main/msidump.py"
Get-RawGitHubFile -OutFile "shellconv.py" -Url "https://raw.githubusercontent.com/hasherezade/shellconv/master/shellconv.py"
Get-RawGitHubFile -OutFile "smtpsmug.py" -Url "https://raw.githubusercontent.com/hannob/smtpsmug/main/smtpsmug"
Get-RawGitHubFile -OutFile "SQLiteWalker.py" -Url "https://raw.githubusercontent.com/stark4n6/SQLiteWalker/main/SQLiteWalker.py"
Get-RawGitHubFile -OutFile "CanaryTokenScanner.py" -Url "https://raw.githubusercontent.com/0xNslabs/CanaryTokenScanner/main/CanaryTokenScanner.py"
Get-RawGitHubFile -OutFile "sigs.py" -Url "https://raw.githubusercontent.com/clausing/scripts/master/sigs.py"
Get-RawGitHubFile -OutFile "defender-dump.py" -Url "https://raw.githubusercontent.com/AlexJ4n6/Defender-Quarantine-Dump/refs/heads/main/defender-dump.py"

# Copy executables to bin folder
Copy-Item "C:\venv\uv\chepy\Scripts\pyjwt.exe" "C:\venv\bin\pyjwt.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

# Copy scripts to bin folder
if (Test-Path "C:\git\bmc-tools\bmc-tools.py") {
    Copy-Item "C:\git\bmc-tools\bmc-tools.py" "C:\Tools\bin\bmc-tools.py"
}

if (Test-Path "C:\git\dotnetfile\examples\dotnetfile_dump.py") {
    Copy-Item "C:\git\dotnetfile\examples\dotnetfile_dump.py" "C:\Tools\bin\dotnetfile_dump.py"
}

foreach ($iShutdown in @("iShutdown_detect.py", "iShutdown_parse.py", "iShutdown_stats.py")) {
    if (Test-Path "C:\git\iShutdown\$iShutdown") {
        Copy-Item "C:\git\iShutdown\$iShutdown" "C:\Tools\bin\$iShutdown"
    }
}

#
# venv default
#
# Include all needed by Didier's tools, https://github.com/DidierStevens/DidierStevensSuite/blob/master/requirements.txt
Write-DateLog "Install packages in venv default in sandbox." >> "C:\log\python.txt"
uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\default" >> "C:\log\python.txt"
C:\venv\default\Scripts\Activate.ps1 >> "C:\log\python.txt"
Set-Location "C:\venv\default"
uv pip install -U `
    "acquire", `
    "aiodns", `
    "aiohttp[speedups]", `
    "Aspose.Email-for-Python-via-Net", `
    "BeautifulSoup4", `
    "bitstruct", `
    "cabarchive", `
    "capstone", `
    "colorama", `
    "compressed_rtf", `
    "dissect", `
    "dissect.target[yara]", `
    "dnslib", `
    "dotnetfile", `
    "dpkt", `
    "elasticsearch", `
    "evtx", `
    "flatten_json", `
    "flow.record", `
    "graphviz", `
    "geoip2", `
    "flare-capa[ghidra]", `
    "javaobj-py3", `
    "keystone-engine", `
    "lief", `
    "matplotlib", `
    "memprocfs", `
    "minidump", `
    "msoffcrypto-tool", `
    "msticpy", `
    "neo4j", `
    "neo4j-driver", `
    "netaddr", `
    "networkx", `
    "numpy", `
    "olefile", `
    "oletools", `
    "openpyxl", `
    "orjson", `
    "pandas", `
    "paramiko", `
    "pathlab", `
    "pefile", `
    "peutils", `
    "pfp", `
    "ppdeep", `
    "prettytable", `
    "pyasn1", `
    "pycares", `
    "pycryptodome", `
    "pydivert", `
    "pyghidra", `
    "pypdf", `
    "pypdf2", `
    "pyshark", `
    "PySocks", `
    "python-dateutil", `
    "python-docx", `
    "python-dotenv", `
    "python-magic", `
    "python-magic-bin", `
    "python-registry", `
    "pytz", `
    "pyvis", `
    "pywin32", `
    "pyzipper", `
    "requests", `
    "rzpipe", `
    "setuptools", `
    "sigma-cli", `
        "pysigma-backend-elasticsearch", `
        "pySigma-backend-loki", `
        "pysigma-backend-splunk", `
        "pysigma-backend-sqlite", `
        "pysigma-pipeline-sysmon", `
        "pysigma-pipeline-windows", `
    "simplejson", `
    "six", `
    "termcolor", `
    "textsearch", `
    "tomlkit", `
    "tqdm", `
    "treelib", `
    "unicorn", `
    "XlsxWriter", `
    "xxhash", `
    "yara-python", `
    "win_inet_pton" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

Save-VenvPackageMetadata -Venv "default" -Python "C:\venv\default\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

#
# venv white-phoenix
#
if (Test-ToolIncludedSandbox -ToolName "White-Phoenix") {
    Write-DateLog "Install packages in venv white-phoenix in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    C:\Windows\System32\curl.exe -L --silent -o "${WSDFIR_TEMP}\white-phoenix.txt" "https://raw.githubusercontent.com/cyberark/White-Phoenix/main/requirements.txt" 2>&1 >> "C:\log\python.txt"
    uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\white-phoenix" >> "C:\log\python.txt"
    C:\venv\white-phoenix\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Set-Location "C:\venv\white-phoenix"
    uv pip install -r "${WSDFIR_TEMP}\white-phoenix.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Save-VenvPackageMetadata -Venv "white-phoenix" -Python "C:\venv\white-phoenix\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv white-phoenix done." >> "C:\log\python.txt"
}

### venv for Kanvas
if (Test-ToolIncludedSandbox -ToolName "Kanvas") {
    Write-DateLog "Install packages in venv kanvas in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    git clone https://github.com/WithSecureLabs/Kanvas.git C:\venv\Kanvas 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Set-Location "C:\venv\Kanvas"
    uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\Kanvas\.venv" >> "C:\log\python.txt"
    C:\venv\Kanvas\.venv\Scripts\Activate.ps1 >> "C:\log\python.txt"
    uv pip install -r ".\requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    C:\Users\WDAGUtilityAccount\Documents\tools\utils\kanvas_update.ps1 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Save-VenvPackageMetadata -Venv "Kanvas" -Python "C:\venv\Kanvas\.venv\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv kanvas done." >> "C:\log\python.txt"
}

### venv for gostringungarbler
Write-DateLog "Install packages in venv gostringungarbler in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
git clone https://github.com/mandiant/gostringungarbler.git C:\venv\gostringungarbler 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Set-Location "C:\venv\gostringungarbler"
uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\gostringungarbler\.venv" >> "C:\log\python.txt"
C:\venv\gostringungarbler\.venv\Scripts\Activate.ps1 >> "C:\log\python.txt"
uv pip install -r ".\requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Save-VenvPackageMetadata -Venv "gostringungarbler" -Python "C:\venv\gostringungarbler\.venv\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
deactivate
Write-DateLog "Python venv gostringungarbler done." >> "C:\log\python.txt"

#
# venv dfir-unfurl
#
Write-DateLog "Install packages in venv dfir-unfurl in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\dfir-unfurl" >> "C:\log\python.txt"
C:\venv\dfir-unfurl\Scripts\Activate.ps1 >> "C:\log\python.txt"
Set-Location "C:\venv\dfir-unfurl"
uv pip install -U `
        dfir-unfurl[ui] `
        hexdump `
        maclookup `
        tomlkit 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Save-VenvPackageMetadata -Venv "dfir-unfurl" -Python "C:\venv\dfir-unfurl\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

# Download each file and update the base.html content with the local path
$baseHtmlPath = "C:\venv\dfir-unfurl\Lib\site-packages\unfurl\templates\base.html"
$baseHtmlContent = Get-Content $baseHtmlPath -Raw
$urls = [regex]::Matches($baseHtmlContent, 'https://cdnjs.cloudflare.com[^"]+')
foreach ($url in $urls) {
    $fileName = $url.Value.Split("/")[-1]
    $staticPath = "C:\venv\dfir-unfurl\Lib\site-packages\unfurl\static\$fileName"
    Write-DateLog "Downloading $url.Value to $staticPath." >> "C:\log\python.txt"
    Invoke-WebRequest -Uri $url.Value -OutFile $staticPath
    $baseHtmlContent = $baseHtmlContent.Replace($url.Value, "/static/$fileName")
}
Set-Content -Path $baseHtmlPath -Value $baseHtmlContent
deactivate
Set-Content "C:\venv\dfir-unfurl\Scripts\python.exe C:\venv\dfir-unfurl\Scripts\unfurl_app.py" -Encoding Ascii -Path "C:\venv\default\Scripts\unfurl_app.ps1"
Set-Content "C:\venv\dfir-unfurl\Scripts\python.exe C:\venv\dfir-unfurl\Scripts\unfurl_cli.py `$args" -Encoding Ascii -Path "C:\venv\default\Scripts\unfurl_cli.ps1"
Write-DateLog "Python venv dfir-unfurl done." >> "C:\log\python.txt"

#
# venv pe2pic
#
Write-DateLog "Install packages in venv pe2pic in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
Set-Location "C:\tmp"
Get-RawGitHubFile -OutFile "pe2pic.py" -Url "https://raw.githubusercontent.com/hasherezade/pe2pic/master/pe2pic.py" 2>&1 >> "C:\log\python.txt"
C:\Windows\System32\curl.exe -L --silent -o "pe2pic_requirements.txt" "https://raw.githubusercontent.com/hasherezade/pe2pic/master/requirements.txt" 2>&1 >> "C:\log\python.txt"
uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\pe2pic"
C:\venv\pe2pic\Scripts\Activate.ps1 >> "C:\log\python.txt"
uv pip install -r "C:\tmp\pe2pic_requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Save-VenvPackageMetadata -Venv "pe2pic" -Python "C:\venv\pe2pic\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\tmp\pe2pic.py" "C:\venv\pe2pic\Scripts\pe2pic.py" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
deactivate
Set-Content "C:\venv\pe2pic\Scripts\python.exe C:\venv\pe2pic\Scripts\pe2pic.py `$args" -Encoding Ascii -Path C:\venv\default\Scripts\pe2pic.ps1
Write-DateLog "Python venv pe2pic done." >> "C:\log\python.txt"

#
# venv evt2sigma
#
if (Test-ToolIncludedSandbox -ToolName "evt2sigma") {
    Write-DateLog "Install packages in venv evt2sigma in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    Set-Location "C:\tmp"
    Get-RawGitHubFile -OutFile "evt2sigma.py" -Url "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/evt2sigma.py" 2>&1 >> "C:\log\python.txt"
    C:\Windows\System32\curl.exe -L --silent -o "evt2sigma_requirements.txt" "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/requirements.txt" 2>&1 >> "C:\log\python.txt"
    uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\evt2sigma"
    C:\venv\evt2sigma\Scripts\Activate.ps1 >> "C:\log\python.txt"
    uv pip install -r "C:\tmp\evt2sigma_requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Save-VenvPackageMetadata -Venv "evt2sigma" -Python "C:\venv\evt2sigma\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Copy-Item "C:\tmp\evt2sigma.py" "C:\venv\evt2sigma\Scripts\evt2sigma.py"
    Set-Content "C:\venv\evt2sigma\Scripts\python.exe C:\venv\evt2sigma\Scripts\evt2sigma.py `$args" -Encoding Ascii -Path "C:\venv\default\Scripts\evt2sigma.ps1"
    deactivate
    Write-DateLog "Python venv evt2sigma done." >> "C:\log\python.txt"
}


#
# venv scare
#
Write-DateLog "Install packages in venv scare in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\scare"
Copy-Item -Recurse "C:\git\scare" "C:\venv\scare"
Set-Location "C:\venv\scare\scare"
C:\venv\scare\Scripts\Activate.ps1 >> "C:\log\python.txt"
uv pip install ptpython pyreadline3 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
uv pip install -r .\requirements.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Save-VenvPackageMetadata -Venv "scare" -Python "C:\venv\scare\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
(Get-Content .\scarelib.py -raw) -replace "print\(splash\)","splash = 'Simple Configurable Asm REPL && Emulator'`n    print(splash)" | Set-Content -Path ".\scarelib2.py" -Encoding ascii
Copy-Item scarelib2.py scarelib.py
Remove-Item scarelib2.py
Copy-Item C:\venv\scare\scare\*.py "C:\venv\scare\Scripts"
deactivate
Set-Content "cd C:\venv\scare\scare && C:\venv\scare\Scripts\ptpython.exe -- C:\venv\scare\scare\scare.py `$args" -Encoding Ascii -Path "C:\venv\default\Scripts\scare.ps1"
Write-DateLog "Python venv scare done." >> "C:\log\python.txt"


#
# venv zircolite
#
Write-DateLog "Install packages in venv zircolite in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\zircolite"
C:\venv\zircolite\Scripts\Activate.ps1 >> "C:\log\python.txt"
Copy-Item -Recurse "C:\git\zircolite" "C:\venv\zircolite"
Set-Location "C:\venv\zircolite\zircolite"
uv pip install -r .\requirements.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Save-VenvPackageMetadata -Venv "zircolite" -Python "C:\venv\zircolite\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
$env:PYTHONWARNINGS = "ignore"
python zircolite.py -U 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
$lines = Get-Content "zircolite.py"
$lines[0] = "#!C:\venv\zircolite\Scripts\python.exe"
$lines | Set-Content "zircolite.py"
deactivate
Set-Content "C:\venv\zircolite\Scripts\python.exe C:\venv\zircolite\zircolite\zircolite.py `$args" -Encoding Ascii -Path "C:\venv\bin\zircolite.ps1"
Write-DateLog "Python venv zircolite done." >> "C:\log\python.txt"

$TOOL_DEFINITIONS += @{
    Name = "Zircolite"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\zircolite (Standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command zircolite.ps1 -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx", ".json")
    Tags = @("log-analysis", "sigma", "detection", "incident-response")
    Notes = "Zircolite is a standalone SIGMA-based detection tool for EVTX, Auditd, Sysmon for linux, XML or JSONL,NDJSON Logs"
    Tips = "Use zircolite.ps1 to run the tool, as it ensures the correct Python environment is used."
    Usage = "zircolite.ps1 --evtx <evtx folder> --ruleset <rules.json>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}

#
# venv eventhawk - EVTX analysis with ATT&CK mapping, IOC extraction and a Qt GUI.
# Cloned by git.ps1; the repository has no package, so it runs from the checkout.
#
if ((Test-ToolIncludedSandbox -ToolName "EventHawk") -and (Test-Path "C:\git\EventHawk\requirements.txt")) {
    Write-DateLog "Install packages in venv eventhawk in sandbox." >> "C:\log\python.txt"
    uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\eventhawk" >> "C:\log\python.txt"
    C:\venv\eventhawk\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Copy-Item -Recurse "C:\git\EventHawk" "C:\venv\eventhawk" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Set-Location "C:\venv\eventhawk\EventHawk"
    uv pip install -r .\requirements.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Save-VenvPackageMetadata -Venv "eventhawk" -Python "C:\venv\eventhawk\Scripts\python.exe" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    deactivate
    Set-Content "C:\venv\eventhawk\Scripts\python.exe C:\venv\eventhawk\EventHawk\evtx_tool.py `$args" -Encoding Ascii -Path "C:\venv\bin\eventhawk.ps1"
    Write-DateLog "Python venv eventhawk done." >> "C:\log\python.txt"
}

$TOOL_DEFINITIONS += @{
    Name = "EventHawk"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\EventHawk (Windows EVTX analysis - ATT&CK mapping, IOC extraction, profiles, diff and Qt GUI).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command eventhawk.ps1 --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\eventhawk\Scripts\python.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".evtx")
    Tags = @("event-log", "log-analysis", "threat-hunting", "mitre-attack", "ioc")
    Notes = "EventHawk parses Windows EVTX logs at speed, maps events to MITRE ATT&CK techniques, extracts IOCs and exports to JSON, CSV, XML, HTML, PDF, STIX 2.1, OpenIOC and YARA. Analysis profiles focus on themes such as logon activity, and the Sentinel module builds a baseline from known-good logs and flags anomalies with Sigma rules. Includes a Qt GUI."
    Tips = "Run it through eventhawk.ps1 so the dedicated virtual environment is used. Start with 'eventhawk.ps1 profiles' to list the built-in analysis profiles, then 'parse' a folder of EVTX files with --profile and --output. Use --juggernaut for very large collections (DuckDB backed). Hayabusa integration is optional and picks up the hayabusa binary already in dfirws."
    Usage = "eventhawk.ps1 parse <evtx folder> --profile <profile> --output results.json"
    SampleCommands = @(
        "eventhawk.ps1 profiles",
        "eventhawk.ps1 parse C:\Users\WDAGUtilityAccount\Desktop\readwrite\evtx --profile `"Logon/Logoff Activity`" --output results.json",
        "eventhawk.ps1 gui"
    )
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = "https://github.com/Mihir-Choudhary/EventHawk"
    Vendor = "Mihir-Choudhary"
    License = "Apache License 2.0"
    LicenseUrl = "https://github.com/Mihir-Choudhary/EventHawk/blob/main/LICENSE"
}

#
# Venvs that needs Visual Studio Build Tools
#

$NeedVSBuildTools = $false

if (((Test-Path "${TOOLS}\VSLayout\vs_BuildTools.exe") -and ($NeedVSBuildTools -eq $true)))  {
    Write-Output "" >> "${WSDFIR_TEMP}\visualstudio.txt"

    # Install Visual Studio Build Tools
    Write-DateLog "Start installation of Visual Studio Build Tools." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    # https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019
    # https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2019
    # https://wiki.python.org/moin/WindowsCompilers
    if (Test-Path "${TOOLS}\VSLayout\vs_BuildTools.exe") {
        Start-Process -Wait "C:\Tools\VSLayout\vs_BuildTools.exe" -ArgumentList "--passive --norestart --force --installWhileDownloading --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.TestTools.BuildTools --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.CLI.Support --installPath C:\BuildTools"
    } else {
        Start-Process -Wait "${SETUP_PATH}\vs_BuildTools.exe" -ArgumentList "--passive --norestart --force --installWhileDownloading --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.TestTools.BuildTools --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.CLI.Support --installPath C:\BuildTools"
    }

    ## Set environment variables for Visual Studio Build Tools
    $env:DISTUTILS_USE_SDK=1
    $env:MSSdk=1
    $env:LIB = "C:\BuildTools\VC\Tools\MSVC\14.29.30133\lib\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\shared\x64;" + $env:LIB
    $env:INCLUDE = "C:\BuildTools\VC\Tools\MSVC\14.29.30133\include" + ";C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0" + $env:INCLUDE
    C:\BuildTools\VC\Auxiliary\Build\vcvarsall.bat amd64 >> "C:\log\python.txt"
    $env:Path = "C:\Users\WDAGUtilityAccount\.local\bin" + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64;C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64"

    # Install Java for jep
    #Write-DateLog "Start installation of Corretto Java." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    #Start-Process -Wait msiexec -ArgumentList "/i ${SETUP_PATH}\corretto.msi /qn /norestart"
    #Get-Job | Receive-Job 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    #$env:JAVA_HOME="C:\Program Files\Amazon Corretto\"+(Get-ChildItem 'C:\Program Files\Amazon Corretto\').Name

    #Write-DateLog "Install Python packages in sandbox needing Visual Studio Build Tools." >> "C:\log\python.txt"
    #uv venv --python "C:\Program Files\Python311\python.exe" "C:\venv\jep" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    #C:\venv\jep\Scripts\Activate.ps1 >> "C:\log\python.txt"

    # Build Ghidrathon for Gidhra
    #Write-DateLog "Build Ghidrathon for Ghidra." >> "C:\log\python.txt"
    #Copy-Item -Force -Recurse "${TOOLS}\ghidrathon" "${WSDFIR_TEMP}"
    #Set-Location "${WSDFIR_TEMP}\ghidrathon"
    #Get-Content requirements.txt >> "C:\log\python.txt"
    #uv pip install "jep==4.2.0" NumPy flare-capa 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    #uv pip install -r requirements.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    #python "ghidrathon_configure.py" "${GHIDRA_INSTALL_DIR}" --debug 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    #if (! (Test-Path "${TOOLS}\ghidra_extensions")) {
    #    New-Item -ItemType Directory -Force -Path "${TOOLS}\ghidra_extensions" | Out-Null
    #}
    #Copy-Item ${WSDFIR_TEMP}\ghidrathon\*.zip "${TOOLS}\ghidra_extensions\" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    #deactivate
    #Write-DateLog "Python venv jep done." >> "C:\log\python.txt"
}
# End venvs needing Visual Studio Build Tools

$TOOL_DEFINITIONS += @{
    Name = "speakeasy"
    Category = "Malware Analysis"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware Analysis\speakeasy (Windows malware emulation framework).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command speakeasy -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".sys", ".bin")
    Tags = @("malware-analysis", "emulation", "shellcode", "reverse-engineering", "windows")
    Notes = "Windows malware emulation framework that executes binaries, drivers, and shellcode in a modeled Windows runtime without a full VM. Produces structured JSON reports."
    Tips = "Docs are available in C:\git\speakeasy\docs, and the source code is in C:\git\speakeasy."
    Usage = "speakeasy -t sample.exe -o report.json"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    Homepage = "https://github.com/mandiant/speakeasy"
    Vendor = "Mandiant"
    License = "MIT License"
    LicenseUrl = ""
    PythonVersion = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PyrsistenceSniper"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\PyrsistenceSniper.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pyrsistencesniper -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\pyrsistencesniper.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("malware-analysis", "forensics", "ioc", "data-extraction", "enrichment")
    Notes = "Point it at a KAPE dump, a Velociraptor collection, or a mounted disk image and get offline Windows persistence detection in seconds. No live system access, no admin privileges, no PowerShell. Runs on Windows, Linux, and macOS because investigators don't always get to pick their workstation."
    Tips = "Point it at a KAPE or Velociraptor collection or a mounted image and review the persistence techniques it reports (run keys, services, scheduled tasks, WMI subscriptions and more). Output can be written as CSV or JSON for the timeline."
    Usage = "pyrsistencesniper -h"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = "https://github.com/Hexastrike/PyrsistenceSniper"
    Vendor = ""
    License = "MIT License"
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "white-phoenix"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\IR\White-Phoenix.py (recovers content from files encrypted by Ransomware using intermittent encryption).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command venv.ps1 -whitephoenix ; White-Phoenix.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".encrypted", ".locked", ".enc")
    Tags = @("ransomware", "encryption", "decryption", "forensics", "data-recovery")
    Notes = "White-Phoenix is a tool that recovers content from files encrypted by Ransomware using intermittent encryption. It is designed to help incident responders and forensic analysts to retrieve data from encrypted files when the decryption key is not available."
    Tips = "Works on files hit by intermittent encryption (BlackCat, Play, Qilin and similar). Supports PDF, Office and zip based formats; recovery is partial so triage the most valuable files first. Excluded from the Basic profile."
    Usage = "venv.ps1 -whitephoenix ; White-Phoenix.py -f <encrypted file> -o <output dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = "https://github.com/cyberark/White-Phoenix"
    Vendor = "CyberArk"
    License = "Apache License 2.0"
    LicenseUrl = "https://github.com/cyberark/White-Phoenix/blob/main/LICENSE"
}

$TOOL_DEFINITIONS += @{
    Name = "msidump"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\msidump.py (a tool that analyzes malicious MSI installation packages, extracts files, streams, binary data and incorporates YARA scanner).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command msidump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\bin\msidump.py"
            Expect = "Python"
        }
    )
    FileExtensions = @(".msi")
    Tags = @("ioc", "data-extraction", "enrichment", "parsing", "forensics")
    Notes = "MSI Dump - a tool that analyzes malicious MSI installation packages, extracts files, streams, binary data and incorporates YARA scanner."
    Tips = "Lists tables, custom actions and embedded binaries of an MSI and flags suspicious ones; -y runs YARA on the extracted streams. lessmsi is the GUI alternative for benign packages."
    Usage = "msidump.py <file.msi> -e <extract dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = "https://github.com/mgeeky/msidump"
    Vendor = "mgeeky"
    License = ""
    LicenseUrl = ""
}


$TOOL_DEFINITIONS += @{
    Name = "dfir_ntfs"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\ntfs_parser.py (Extract information from NTFS metadata files, volumes, and shadow copies).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ntfs_parser.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\fat_parser.py (Extract information from FAT files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command fat_parser.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ntfs_parser.py"
            Expect = "Python"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\fat_parser.py"
            Expect = "Python"
        }
    )
    FileExtensions = @(".mft", ".dd", ".raw", ".img")
    Tags = @("ntfs", "filesystem", "forensics", "disk-forensics")
    Notes = "An NTFS/FAT parser for digital forensics & incident response."
    Tips = "Parses NTFS (MFT, USN journal, LogFile) and FAT structures including deleted entries and can decrypt BitLocker volumes with a key. fat_parser.py handles FAT12/16/32 images."
    Usage = "ntfs_parser.py <image or MFT file> --mft-csv out.csv"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "binary-refinery"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\binary-refinery.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command binref -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\binref.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".bin")
    Tags = @("malware-analysis", "deobfuscation", "data-extraction", "scripting")
    Notes = "The Binary Refinery is a collection of Python scripts that implement transformations of binary data such as compression and encryption. We will often refer to it simply by refinery, which is also the name of the corresponding package."
    Tips = "A pipeline of small units (binref -h lists them): carve, xor, aes, zl, pemeta, vstack, xtzip and hundreds more. Every unit has --help; chain them with pipes like CyberChef on the command line. Excluded from the Basic profile."
    Usage = "emit sample.bin | xor 0x41 | dump out.bin"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "regipy"
    Category = "OS\Windows\Registry"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-diff.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command regipy-diff.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Windows\Registry\regipy-dump.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command regipy-dump.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\uv\regipy\Scripts\evtx_dump.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".reg", ".dat")
    Tags = @("registry", "windows", "forensics")
    Notes = "Regipy is a python library for parsing offline registry hives."
    Tips = "Parses offline registry hives. regipy-plugins-run executes all plugins (run keys, services, user assist, shellbags and more), regipy-dump exports a hive, regipy-diff compares two hives, and --transaction-logs applies dirty LOG files first."
    Usage = "regipy-plugins-run <hive> -o out.json"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "peepdf-3"
    Category = "Files and apps\PDF"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PDF\peepdf-3 (peepdf - peepdf-3 is a Python 3 tool to explore PDF files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command peepdf -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\peepdf.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pdf")
    Tags = @("pdf", "malware-analysis", "javascript")
    Notes = "A Python 3 tool to explore, analyse, and disassemble PDF files"
    Tips = "Interactive PDF analysis of objects, streams, JavaScript and suspicious elements. Use -f to force parsing of broken files and -x for XML output; pdfalyzer and pdf-parser.py are the alternatives."
    Usage = "peepdf -i <file.pdf>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "zensical"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".md", ".toml")
    Tags = @("documentation", "markdown")
    Notes = "Project documentation with Markdown."
    Tips = "Static site generator used for the dfirws documentation. Run it in a project folder containing zensical.toml."
    Usage = "zensical build"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "apkid"
    Category = "OS\Android"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\OS\Android\apkid (Android Application Identifier for packers, protectors, obfuscators and oddities).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command apkid -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\apkid.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".apk", ".dex")
    Tags = @("android", "packer-detection", "malware-analysis")
    Notes = "APKiD identifies the compiler, packer, protector and obfuscator used to build an Android APK or DEX file - PEiD for Android."
    Tips = "Run apkid before decompiling with jadx or apktool to know which packer or obfuscator you are dealing with. Use -r to scan recursively and -j for JSON output."
    Usage = "apkid sample.apk"
    SampleCommands = @(
        "apkid sample.apk",
        "apkid -j sample.apk",
        "apkid -r C:\Users\WDAGUtilityAccount\Desktop\readwrite\apks"
    )
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = "https://github.com/rednaga/APKiD"
    Vendor = "RedNaga"
    License = "GNU General Public License v3.0"
    LicenseUrl = "https://github.com/rednaga/APKiD/blob/master/LICENSE.COMMERCIAL"
}

$TOOL_DEFINITIONS += @{
    Name = "autoit-ripper"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\autoit-ripper.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command autoit-ripper -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\autoit-ripper.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe")
    Tags = @("malware-analysis", "scripting", "deobfuscation")
    Notes = "Extract AutoIt scripts embedded in PE binaries."
    Tips = "Extracts the AutoIt script and bundled resources from compiled AutoIt executables. The script is written as a .au3 text file which can then be read or deobfuscated."
    Usage = "autoit-ripper <compiled.exe> <output dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "cart"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\cart.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".cart")
    Tags = @("malware-analysis")
    Notes = "Compressed and RC4 Transport (CaRT) Neutering format. This is a file format that is used to neuter malware files for distribution in the malware analyst community."
    Tips = "Neuters malware for safe transport by RC4 encrypting and compressing it with metadata. Decode with -d before analysis; -s shows the metadata header."
    Usage = "cart <file> (creates file.cart) or cart -d file.cart"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "chepy"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\chepy.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\chepy.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".bin", ".txt", ".hex")
    Tags = @("data-processing", "encoding", "decoding", "deobfuscation", "hashing")
    Notes = "Chepy is a python library with a handy cli that is aimed to mirror some of the capabilities of CyberChef. A reasonable amount of effort was put behind Chepy to make it compatible to the various functionalities that CyberChef offers, all in a pure Pythonic manner."
    Tips = "CyberChef operations from the command line and Python. Start 'chepy' without arguments for the interactive shell with tab completion; useful for scripting decode chains on many files."
    Usage = "chepy 'aGVsbG8=' base64_decode o"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "csvkit"
    Category = "Malware Analysis"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\csvkit (tools for working with csv files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command csv --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\csvclean.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\csvcut.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".csv")
    Tags = @("csv", "data-processing", "cli")
    Notes = "A suite of command-line tools for working with CSV, the king of tabular file formats."
    Tips = "csvcut, csvgrep, csvsort, csvstat, csvsql (SQL on CSV), in2csv (Excel and JSON to CSV) and csvjson. Use -e for encoding problems and -t for tab separated input."
    Usage = "csvcut -c 1,3 file.csv | csvlook"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "deep_translator"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\deep-translator.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("data-processing")
    Notes = "A flexible free and unlimited python tool to translate between different languages in a simple way using multiple translators"
    Tips = "Translates text via online services, so it needs the network sandbox. Useful for ransom notes and foreign language artifacts."
    Usage = "deep-translator -trans google -src auto -tgt en -txt '<text>'"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "docx2txt"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\docx2txt.py"
            Expect = "Python"
        }
    )
    FileExtensions = @(".docx")
    Tags = @("office", "data-extraction")
    Notes = "A pure python-based utility to extract text and images from docx files."
    Tips = "Dumps the text of a DOCX without opening it in Word. Extract embedded images with -i <dir>."
    Usage = "docx2txt.py <file.docx> [output.txt]"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "extract-msg"
    Category = "Files and apps\Email"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Email\extract_msg.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command extract_msg -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\extract_msg.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".msg")
    Tags = @("email", "data-extraction")
    Notes = "Extracts emails and attachments saved in Microsoft Outlook's .msg files"
    Tips = "Extracts body, headers and attachments from Outlook MSG files into a folder. Use --json for machine readable output, --raw to keep original encodings and --out-name to set the folder."
    Usage = "extract_msg <file.msg>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "filterforge"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\filterforge (ff - solve BPF filters and craft matching packets).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ff --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ff.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pcap", ".pcapng")
    Tags = @("network-analysis", "network", "pcap")
    Notes = "filterforge from Cloudflare solves BPF filters with the z3 SMT solver and crafts packets that match (or do not match) a given filter expression."
    Tips = "The command is ff. Useful for validating capture and firewall filters and generating test packets for them. Requires Python 3.13 and is skipped when python3.13 is excluded by the profile."
    Usage = "ff --help"
    SampleCommands = @(
        "ff --help"
    )
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = "3.13"
    Homepage = "https://github.com/cloudflare/filterforge"
    Vendor = "Cloudflare"
    License = "Apache License 2.0"
    LicenseUrl = "https://github.com/cloudflare/filterforge/blob/main/LICENSE"
}

$TOOL_DEFINITIONS += @{
    Name = "flatten_json"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\flatten_json.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json")
    Tags = @("python", "json")
    Notes = "Flatten JSON objects"
    Tips = "Flattens nested JSON to a single level so it can be loaded into CSV tools or spreadsheets; also usable as a Python library."
    Usage = "flatten_json <file.json>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "frida-tools"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\frida.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\frida-apk.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".apk", ".ipa")
    Tags = @("reverse-engineering", "dynamic-analysis")
    Notes = "Frida CLI tools."
    Tips = "Dynamic instrumentation: frida-trace traces API calls, frida -p <pid> -l script.js injects a script and frida-ps lists processes. Only instrument samples inside the sandbox."
    Usage = "frida-trace -i 'CreateFile*' <exe>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ghidrecomp"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ghidrecomp.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf")
    Tags = @("reverse-engineering", "decompiler")
    Notes = "Python Command-Line Ghidra Decomplier."
    Tips = "Headless decompilation of every function with Ghidra into text files; requires Ghidra and Java. Use --filter to limit functions and -o for the output directory."
    Usage = "ghidrecomp <binary>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ghidriff"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ghidriff.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".elf")
    Tags = @("reverse-engineering", "binary-diffing")
    Notes = "Ghidra Binary Diffing Engine."
    Tips = "Binary diffing with Ghidra headless. Produces Markdown and JSON diffs of changed, added and removed functions; useful for patch analysis and variant comparison."
    Usage = "ghidriff old.exe new.exe"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "grip"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\grip.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".md")
    Tags = @("markdown", "viewer")
    Notes = "Render local readme files before sending off to GitHub."
    Tips = "Renders Markdown as GitHub would in a local browser. It uses the GitHub API, so run it in the network sandbox; for offline preview use Obsidian or VS Code."
    Usage = "grip README.md"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "hachoir"
    Category = "Files and apps\PE"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PE\hachoir-tools.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dir C:\venv\bin\hachoir-*"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\hachoir-wx.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".png", ".jpg", ".zip", ".tar", ".gz")
    Tags = @("binary-analysis", "metadata", "file-analysis")
    Notes = "Hachoir is a Python library to view and edit a binary stream field by field. In other words, Hachoir allows you to `"browse`" any binary stream just like you browse directories and files."
    Tips = "hachoir-metadata extracts metadata from many formats, hachoir-urwid browses a file field by field, hachoir-subfile carves embedded files and hachoir-strip removes metadata."
    Usage = "hachoir-metadata <file>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "jpterm"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\jpterm (Jupyter in the terminal).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command jpterm --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\jpterm.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".json")
    Tags = @("python", "data-processing", "tui")
    Notes = "Jupyter in the terminal."
    Tips = "Jupyter notebooks in the terminal. Open or create .ipynb files and run cells without a browser. Excluded from the Basic profile."
    Usage = "jpterm"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "jsbeautifier"
    Category = "Files and apps\JavaScript"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\JavaScript\js-beautify (Javascript beautifier).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command js-beautify --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\js-beautify.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".js")
    Tags = @("javascript", "deobfuscation")
    Notes = "JavaScript unobfuscator and beautifier."
    Tips = "Formats minified or obfuscated JavaScript for reading. Combine with synchrony (deobfuscator) and box-js for behaviour analysis."
    Usage = "js-beautify obfuscated.js > pretty.js"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "jupyterlab"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\uv\jupyterlab\Scripts\jupyter.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".ipynb")
    Tags = @("python", "data-processing")
    Notes = "JupyterLab computational environment"
    Tips = "Start from the desktop shortcut. Notebooks from jupyter-collection and the dfirws setup are available, and the default venv kernel has the installed DFIR libraries (dissect, pefile, yara, msticpy)."
    Usage = "jupyter lab --notebook-dir <folder>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "litecli"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\litecli (SQLite CLI with autocompletion and syntax highlighting).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command litecli --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\litecli.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".db", ".sqlite")
    Tags = @("database", "sqlite", "cli")
    Notes = "CLI for SQLite Databases with auto-completion and syntax highlighting."
    Tips = "SQLite shell with auto completion and syntax highlighting. Use .tables to list tables and .schema <table> to describe one."
    Usage = "litecli <database.sqlite>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "LnkParse3"
    Category = "OS\Windows"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\lnkparse.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".lnk")
    Tags = @("windows", "forensics", "file-analysis")
    Notes = "Windows Shortcut file (LNK) parser"
    Tips = "Prints target path, arguments, timestamps, machine ID and MAC address from LNK files; --json for structured output. Jumplist Browser covers Jump Lists."
    Usage = "lnkparse <file.lnk>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "magika"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\magika (A tool like file and file-magic based on AI).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command magika -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\magika.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("file-analysis", "ai")
    Notes = "A tool to determine the content type of a file with deep learning."
    Tips = "Deep learning file type identification that works on renamed or partial files. Use -r for recursive scanning and --json for output; compare with file-magic.py for edge cases."
    Usage = "magika <file or dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "maldump"
    Category = "Malware Analysis"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\maldump.exe (Multi-quarantine extractor).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command maldump.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\maldump.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("malware-analysis", "malware-detection")
    Notes = "Maldump makes it easy to extract quarantined files of multiple AVs from a live system or a mounted disk image."
    Tips = "Extracts quarantined files from Windows Defender, Avast, AVG, Kaspersky, ESET, Malwarebytes and more. Use -l to list entries and -q to extract them to a folder."
    Usage = "maldump.exe <root of mounted image or drive>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "malwarebazaar"
    Category = "Signatures and information\Online tools"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\Online tools\bazaar.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command bazaar --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\bazaar.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\yaraify.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("malware-analysis", "threat-intelligence", "ioc-scanner")
    Notes = "CLI wrapper for malware bazaar API (bazaar.abuse.ch) and YARAify API (yaraify.abuse.ch)"
    Tips = "Query and download samples from MalwareBazaar and scan with YARAify. Needs an abuse.ch auth key and the network sandbox; downloads are password protected zips (infected)."
    Usage = "bazaar -h ; yaraify -h"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "markitdown"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\markitdown (Python tool for converting files and office documents to Markdown).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command markitdown --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".docx", ".xlsx", ".pptx", ".pdf", ".html")
    Tags = @("conversion", "markdown", "data-extraction", "office")
    Notes = "Utility tool for converting various files to Markdown."
    Tips = "Converts PDF, Office, HTML, images and audio to Markdown for reading and for feeding LLMs. Use it to turn documents into notes for Obsidian."
    Usage = "markitdown <file> -o out.md"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "minidump"
    Category = "Memory"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\minidump.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dmp")
    Tags = @("memory-forensics", "windows")
    Notes = "Python library to parse Windows minidump file format."
    Tips = "Parses Windows minidump files and lists modules, threads and memory regions. Used by pypykatz for LSASS dumps."
    Usage = "minidump <file.dmp>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "mkyara"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\mkyara.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mkyara -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\mkyara.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".bin")
    Tags = @("yara", "detection-rules", "malware-analysis")
    Notes = ""
    Tips = "Generates YARA rules from a code region by masking operands. Use it to write a signature for a unique function in a sample."
    Usage = "mkyara -i <file> -s <start offset> -e <end offset>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "msoffcrypto-tool"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\msoffcrypto-tool.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command msoffcrypto-tool -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\msoffcrypto-tool.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx")
    Tags = @("office", "encryption", "decryption")
    Notes = "Python tool and library for decrypting and encrypting MS Office files using a password or other keys"
    Tips = "Decrypts password protected Office files (including the default VelvetSweatshop password) so olevba and oledump can analyse them. Use -t to test whether a file is encrypted."
    Usage = "msoffcrypto-tool -p <password> encrypted.docx decrypted.docx"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "mwcp"
    Category = "Malware Analysis"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\mwcp.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe", ".dll", ".bin")
    Tags = @("malware-analysis", "data-extraction")
    Notes = "A framework for malware configuration parsers."
    Tips = "Framework for malware configuration parsers; 'mwcp list' shows the available parsers. Write your own parser for a family and run it on samples to extract C2 addresses and keys."
    Usage = "mwcp parse <parser> <file>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "name-that-hash"
    Category = "Utilities\Cryptography"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Cryptography\name-that-hash (also available as nth).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\name-that-hash.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("hashing", "file-analysis")
    Notes = "The Modern Hash Identification System."
    Tips = "Identifies hash types and suggests hashcat and John modes. Use -f for a file of hashes."
    Usage = "nth -t '<hash>'"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "netaddr"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\netaddr.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("network")
    Notes = "A network address manipulation library for Python."
    Tips = "Python library for IP and MAC address maths. The netaddr command opens an interactive shell for subnet calculations and OUI lookups."
    Usage = "netaddr"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "numpy"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("data-processing")
    Notes = "Fundamental package for array computing in Python."
    Tips = "Numerical library used by other tools and notebooks; nothing to run directly."
    Usage = "import numpy as np"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "oletools"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\ezhexviewer (A simple hexadecimal viewer).lnk"
            Target   = "C:\venv\bin\ezhexviewer.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\oleid.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command oleid -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\olevba.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command olevba -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\mraptor.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command mraptor -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\msodde.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command msodde -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\oleid.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\olevba.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\bin\mraptor.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".rtf")
    Tags = @("office", "malware-analysis", "vba")
    Notes = "Python tools to analyze security characteristics of MS Office and OLE files (also called Structured Storage, Compound File Binary Format or Compound Document File Format), for Malware Analysis and Incident Response #DFIR."
    Tips = "oleid triages, olevba extracts and deobfuscates VBA (--deobf for obfuscated macros), mraptor flags auto exec macros, msodde finds DDE links, rtfobj extracts objects from RTF and oleobj extracts embedded objects."
    Usage = "olevba <file> ; oleid <file> ; mraptor <file>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pcode2code"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\pcode2code.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pcode2code -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\pcode2code.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".doc", ".xls", ".ppt")
    Tags = @("office", "vba", "decompiler")
    Notes = "A vba p-code decompiler based on pcodedmp"
    Tips = "Decompiles VBA p-code, recovering macros whose source was stomped (VBA stomping). Compare with olevba output to detect stomping."
    Usage = "pcode2code <file.doc>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pdfalyzer"
    Category = "Files and apps\PDF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pdf")
    Tags = @("pdf", "malware-analysis", "visualization")
    Notes = "Analyze PDFs with colors (and YARA). Visualize a PDF's inner tree-like data structure, check it against a library of YARA rules, force decodes of suspicious font binaries, and more."
    Tips = "Visualises the PDF object tree, runs YARA rules and decodes suspicious streams and fonts. Use --streams to dump stream contents and --extract-binary for embedded data."
    Usage = "pdfalyze <file.pdf>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "protodeep"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\protodeep.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".bin")
    Tags = @("parsing", "reverse-engineering")
    Notes = "A tool to help reversing protobuf."
    Tips = "Decodes protobuf data without the schema, guessing field types. Useful for app databases and C2 traffic that use protobuf."
    Usage = "protodeep <file or hex string>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ptpython"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\ptpython.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".py")
    Tags = @("python", "scripting")
    Notes = "Python REPL build on top of prompt_toolkit."
    Tips = "Better Python REPL with completion and history. Use it for quick experiments with the installed libraries such as pefile, lief and dissect."
    Usage = "ptpython"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pwncat"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\pwncat.py (Fancy reverse and bind shell handler).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pwncat.py --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\pwncat.py"
            Expect = "Python"
        }
    )
    FileExtensions = @()
    Tags = @("exploitation", "security-testing")
    Notes = "Netcat on steroids with Firewall, IDS/IPS evasion, bind and reverse shell and port forwarding magic - and its fully scriptable with Python (PSE)."
    Tips = "Netcat replacement with port forwarding, bind and reverse shells and Python scripting. Use it in the network sandbox to catch callbacks from a detonated sample."
    Usage = "pwncat.py -l 4444"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pyghidra"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf")
    Tags = @("reverse-engineering", "decompiler", "scripting")
    Notes = "The PyGhidra Python library, originally developed by the Department of Defense Cyber Crime Center (DC3) under the name `"Pyhidra`", is a Python library that provides direct access to the Ghidra API within a native CPython 3 interpreter using JPype. PyGhidra contains some conveniences for setting up analysis on a given sample and running a Ghidra script locally. It also contains a Ghidra plugin to allow the use of CPython 3 from the Ghidra GUI."
    Tips = "Runs Ghidra headless from CPython. Set GHIDRA_INSTALL_DIR to the Ghidra folder first. Used by ghidrecomp and ghidriff. Excluded from the Basic profile."
    Usage = "python -c 'import pyghidra; pyghidra.start()'"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Ghidra")
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pyinstxtractor-ng"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\pyinstxtractor-ng (extract the contents of PyInstaller generated executables).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pyinstxtractor-ng -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\pyinstxtractor-ng.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".exe")
    Tags = @("reverse-engineering", "python", "data-extraction")
    Notes = "PyInstaller Extractor Next Generation extracts the Python scripts, modules and PYZ archives from PyInstaller generated Windows and Linux executables, including encrypted ones."
    Tips = "The extracted .pyc files are written to <file>_extracted. Decompile or disassemble them with pycdc / pycdas (built in the MSYS2 sandbox) - the entry point script is usually named after the original executable."
    Usage = "pyinstxtractor-ng sample.exe"
    SampleCommands = @(
        "pyinstxtractor-ng sample.exe",
        "pycdc sample.exe_extracted\sample.pyc"
    )
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = "https://github.com/pyinstxtractor/pyinstxtractor-ng"
    Vendor = "pyinstxtractor"
    License = "GNU General Public License v3.0"
    LicenseUrl = "https://github.com/pyinstxtractor/pyinstxtractor-ng/blob/master/LICENSE"
}

$TOOL_DEFINITIONS += @{
    Name = "pyOneNote"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\pyonenote.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".one")
    Tags = @("office", "data-extraction")
    Notes = ""
    Tips = "Parses OneNote files and extracts embedded files and images. Compare with onedump.py and one-extract when a file is malformed."
    Usage = "pyonenote -f <file.one>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pypng"
    Category = "Utilities\CTF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\priweavepng.py"
            Expect = "Python"
        }
    )
    FileExtensions = @(".png")
    Tags = @("steganography")
    Notes = ""
    Tips = "Pure Python PNG library. The bundled scripts inspect and rewrite chunks, which helps with steganography and corrupt PNG files."
    Usage = "priweavepng.py <image.png>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "rexi"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\rexi.exe (Terminal UI for Regex Testing).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rexi.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\rexi.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("search", "data-processing", "tui")
    Notes = ""
    Tips = "Interactive regular expression tester in the terminal. Paste sample text and edit the pattern live before using it in rg or a script."
    Usage = "rexi"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "scapy"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\scapy.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command scapy -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\scapy.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pcap", ".pcapng")
    Tags = @("network-analysis", "pcap", "security-testing")
    Notes = ""
    Tips = "Craft, send and dissect packets in Python. rdpcap('file.pcap') loads a capture for analysis; sniffing and sending need the network sandbox and administrator rights."
    Usage = "scapy"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "shodan"
    Category = "Signatures and information\Online tools"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\Online tools\shodan.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command shodan"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\shodan.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("osint", "network")
    Notes = ""
    Tips = "Needs an API key and the network sandbox. shodan host, search and download for IP and service lookups."
    Usage = "shodan init <api key> ; shodan host 8.8.8.8"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "stego-lsb"
    Category = "Utilities\CTF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".png", ".bmp", ".wav")
    Tags = @("steganography", "audio")
    Notes = ""
    Tips = "Hides and recovers data in the least significant bits of PNG and WAV files. Try -n 1 to 4 bits when recovering unknown payloads."
    Usage = "stegolsb steglsb -r -i stego.png -o out.bin -n 1"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "sqlit-tui"
    Category = "Files and apps\Database"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Database\sqlit (TUI for SQL databases).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sqlit.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".db", ".sqlite", ".sqlite3")
    Tags = @("database", "sqlite", "tui")
    Notes = ""
    Tips = "Terminal UI for browsing SQLite tables and running queries. A lightweight alternative to DB Browser for SQLite."
    Usage = "sqlit <database.sqlite>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "time-decode"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\time-decode.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command time-decode --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\time-decode.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("metadata", "forensics", "decoding")
    Notes = ""
    Tips = "Converts timestamps between formats (Unix, Windows FILETIME, WebKit, Cocoa, OLE, GPS and dozens more). --guess tries every format on a raw value."
    Usage = "time-decode --guess <value>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "toolong"
    Category = "Files and apps\Log"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Log\toolong (tl - A terminal application to view, tail, merge, and search log files (plus JSONL)).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command tl.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\tl.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".log", ".txt")
    Tags = @("log-analysis", "tui")
    Notes = ""
    Tips = "Terminal log viewer with tailing, merging of multiple files and JSON pretty printing. Opens large logs that editors choke on."
    Usage = "tl <logfile>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "unpy2exe"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\unpy2exe.py"
            Expect = "Python"
        }
    )
    FileExtensions = @(".exe")
    Tags = @("reverse-engineering", "python", "decompiler")
    Notes = ""
    Tips = "Extracts the compiled Python code from py2exe executables. For PyInstaller use pyinstxtractor-ng, then decompile the .pyc files with pycdc."
    Usage = "unpy2exe.py <py2exe executable>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "visidata"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\visidata (VisiData or vd is an interactive multitool for tabular data).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command visidata --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\visidata.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".csv", ".tsv", ".json", ".sqlite", ".xlsx")
    Tags = @("data-processing", "tui", "csv")
    Notes = ""
    Tips = "Terminal spreadsheet for CSV, JSON, SQLite, Excel and more. Press F for frequency tables, Shift+F to plot and Ctrl+S to save; excellent for large timelines."
    Usage = "vd file.csv"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "xlrd"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\runxlrd.py"
            Expect = "Python"
        }
    )
    FileExtensions = @(".xls")
    Tags = @("office", "data-extraction")
    Notes = ""
    Tips = "Reads legacy .xls files. runxlrd.py dumps sheets and cells from the command line without Excel."
    Usage = "runxlrd.py show <file.xls>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "XLMMacroDeobfuscator"
    Category = "Files and apps\Office"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Office\xlmdeobfuscator (XLMMacroDeobfuscator can be used to decode obfuscated XLM macros).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command xlmdeobfuscator -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\xlmdeobfuscator.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".xls", ".xlsm", ".xlsb")
    Tags = @("office", "vba", "deobfuscation", "malware-analysis")
    Notes = ""
    Tips = "Emulates Excel 4.0 (XLM) macros to reveal the hidden commands. --no-ms-excel forces the internal emulator and -x extracts the macros only."
    Usage = "xlmdeobfuscator -f <file.xls>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "XlsxWriter"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".xlsx")
    Tags = @("office")
    Notes = ""
    Tips = "Python library for writing Excel files. Used by other tools such as srum_dump; nothing to run directly."
    Usage = "import xlsxwriter"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "acquire"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\acquire.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command acquire.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\acquire-decrypt.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command acquire-decrypt.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\acquire.exe"
            Expect = "PE32"
        }
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\acquire-decrypt.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".tar")
    Tags = @("forensics", "incident-response", "acquisition", "disk-forensics")
    Notes = ""
    Tips = "Dissect's collector: 'acquire -p full' collects artifacts from a live host or 'acquire <image>' from an image into a tar file. acquire-decrypt opens encrypted collections."
    Usage = "acquire --help"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "aiodns"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "dns")
    Notes = ""
    Tips = "Async DNS resolver library used by other tools; nothing to run directly."
    Usage = "import aiodns"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "aiohttp"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "http")
    Notes = ""
    Tips = "Async HTTP client and server library used by other tools; nothing to run directly."
    Usage = "import aiohttp"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "Aspose.Email-for-Python-via-Net"
    Category = "Files and apps\Email"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".msg", ".eml", ".pst", ".ost", ".mbox")
    Tags = @("email", "forensics", "data-extraction")
    Notes = ""
    Tips = "Library for reading and converting PST, OST, MSG and EML mail files from Python. The free mode has limits; extract-msg and pst tools cover most cases."
    Usage = "import aspose.email"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "BeautifulSoup4"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".html", ".htm", ".xml")
    Tags = @("web", "parsing", "data-extraction")
    Notes = ""
    Tips = "HTML and XML parsing library for scripts, for example to pull links from phishing pages; nothing to run directly."
    Usage = "from bs4 import BeautifulSoup"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "bitstruct"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("binary-analysis", "data-processing")
    Notes = ""
    Tips = "Packs and unpacks bit level structures in Python; useful for custom binary formats."
    Usage = "import bitstruct"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "compressed_rtf"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".rtf")
    Tags = @("office", "rtf", "data-extraction")
    Notes = ""
    Tips = "Decompresses RTF stored in Outlook MSG files. Used by extract-msg; nothing to run directly."
    Usage = "import compressed_rtf"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dissect"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\rdump.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rdump.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\rdump.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dd", ".raw", ".tar")
    Tags = @("forensics", "incident-response", "data-extraction")
    Notes = ""
    Tips = "The Dissect framework: target-query runs plugins against images (E01, VMDK, VHDX, tar, acquire collections) without mounting, target-shell browses the file system and target-dump exports records. Pipe records into rdump for CSV or JSON."
    Usage = "target-query -f users <image>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dissect.target"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\target-query.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command target-query.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\target-shell.exe (dissect).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command target-shell.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\target-shell.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dd", ".raw", ".tar", ".vmdk", ".E01")
    Tags = @("forensics", "incident-response", "artifact-extraction")
    Notes = ""
    Tips = "Interactive shell over a disk image or collection, and target-query -l lists the plugins (evtx, registry, prefetch, mft, browser history and more). Records pipe into rdump."
    Usage = "target-shell <image>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dnslib"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "dns")
    Notes = ""
    Tips = "DNS packet parsing and building library for scripts; nothing to run directly."
    Usage = "import dnslib"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "flow.record"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".rec")
    Tags = @("forensics", "data-processing")
    Notes = ""
    Tips = "Reads and writes dissect record streams. Use rdump with -F to select fields, -s for filter expressions and -w to write CSV, JSON or JSONL."
    Usage = "rdump records.rec -w out.csv"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "geoip2"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".mmdb")
    Tags = @("geolocation", "network", "maxmind")
    Notes = ""
    Tips = "Reader for the MaxMind databases in the enrichment folder. Use mmdbinspect for command line lookups."
    Usage = "import geoip2.database"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("enrichment")
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "cabarchive"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".cab")
    Tags = @("compression", "data-extraction")
    Notes = ""
    Tips = "Reads and extracts Microsoft cabinet files from Python. 7-Zip handles the same from the shell."
    Usage = "import cabarchive"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dotnetfile"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll")
    Tags = @("pe-analysis", "dotnet")
    Notes = ""
    Tips = "Library for CLR header parsing of .NET assemblies. The git checkout under C:\git\dotnetfile has dotnetfile_dump.py for command line use."
    Usage = "import dotnetfile"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dpkt"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pcap", ".pcapng")
    Tags = @("network-analysis", "pcap", "protocol-analysis")
    Notes = ""
    Tips = "Fast PCAP parsing library for scripts. pyshark and scapy are easier for interactive work."
    Usage = "import dpkt"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "elasticsearch"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("database", "log-analysis", "search", "siem")
    Notes = ""
    Tips = "Python client for the Elastic Stack installed on demand; needs the cluster running."
    Usage = "from elasticsearch import Elasticsearch"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "evtx"
    Category = "Files and apps\Log"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".evtx")
    Tags = @("log-analysis", "event-log", "windows")
    Notes = ""
    Tips = "python-evtx scripts: evtx_dump.py, evtx_info.py, evtx_templates.py and evtx_dump_json.py. The Rust evtx_dump tool is much faster for bulk work."
    Usage = "evtx_dump.py <file.evtx>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "graphviz"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".dot", ".gv")
    Tags = @("visualization", "graph")
    Notes = ""
    Tips = "Python bindings plus the dot layout engine used for rendering call graphs, process trees and attack paths."
    Usage = "dot -Tpng graph.dot -o graph.png"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "javaobj-py3"
    Category = "Programming\Java"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @()
    Notes = ""
    Tips = "Deserialises Java serialized objects from Python for inspecting Java application data."
    Usage = "import javaobj"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "keystone-engine"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering")
    Notes = ""
    Tips = "Assembler library for x86, ARM, MIPS and more. Use it with unicorn and capstone in notebooks; scare wraps them in a REPL."
    Usage = "import keystone"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "lief"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".mach-o")
    Tags = @("pe-analysis", "elf-analysis", "binary-analysis")
    Notes = ""
    Tips = "Parse and modify PE, ELF, Mach-O and DEX files. Good for scripted extraction of imports, resources, signatures and for patching headers."
    Usage = "import lief; b = lief.parse('file.exe')"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "matplotlib"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("visualization")
    Notes = ""
    Tips = "Plotting library for notebooks and scripts; nothing to run directly."
    Usage = "import matplotlib.pyplot as plt"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "msticpy"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".json", ".csv")
    Tags = @("threat-intelligence", "incident-response", "python")
    Notes = ""
    Tips = "Microsoft's security notebooks toolkit for enrichment, visualisation and querying (Sentinel, Splunk, Elastic). Threat intel providers need API keys and the network sandbox."
    Usage = "import msticpy"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "neo4j"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("database", "graph")
    Notes = ""
    Tips = "Python driver for the Neo4j database installed on demand. Used for graph analysis such as BloodHound style data."
    Usage = "from neo4j import GraphDatabase"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "networkx"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("visualization", "graph")
    Notes = ""
    Tips = "Graph analysis in Python. Build process trees or infrastructure graphs and export them to pyvis for interactive visualisation."
    Usage = "import networkx as nx"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "olefile"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\bin\olefile.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".doc", ".xls", ".ppt", ".msg")
    Tags = @("office", "ole", "data-extraction")
    Notes = ""
    Tips = "Lists OLE streams and storages and is the underlying library for oletools. oledump.py gives more detail and can dump streams."
    Usage = "olefile <file>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "openpyxl"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".xlsx")
    Tags = @("office", "data-extraction")
    Notes = ""
    Tips = "Read and write xlsx files from Python; nothing to run directly."
    Usage = "import openpyxl"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "orjson"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".json")
    Tags = @("json", "data-processing")
    Notes = ""
    Tips = "Fast JSON library used by other tools; nothing to run directly."
    Usage = "import orjson"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "paramiko"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "scripting")
    Notes = ""
    Tips = "SSH client library for scripts; needs the network sandbox to reach hosts."
    Usage = "import paramiko"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pathlab"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("forensics", "filesystem")
    Notes = ""
    Tips = "Path abstraction library used by dissect; nothing to run directly."
    Usage = "import pathlab"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pefile"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".sys")
    Tags = @("pe-analysis", "reverse-engineering")
    Notes = ""
    Tips = "Parse PE headers, imports, exports and resources in Python. pe.dump_info() prints everything; pe.get_imphash() gives the import hash."
    Usage = "import pefile; pe = pefile.PE('file.exe')"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "peutils"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll")
    Tags = @("pe-analysis", "packer-detection")
    Notes = ""
    Tips = "Signature matching helper for pefile using PEiD style userdb signatures."
    Usage = "import peutils"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pfp"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".bin")
    Tags = @("binary-analysis", "file-analysis")
    Notes = ""
    Tips = "Python interpreter for 010 Editor templates. Parse binary formats with existing .bt templates from scripts."
    Usage = "import pfp"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "ppdeep"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("hashing", "fuzzy-hashing", "binary-diffing")
    Notes = ""
    Tips = "Pure Python ssdeep fuzzy hashing. ssdeep.py from the Didier Stevens suite wraps it for the command line."
    Usage = "import ppdeep"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "prettytable"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("data-processing")
    Notes = ""
    Tips = "ASCII table output for scripts; nothing to run directly."
    Usage = "import prettytable"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pyasn1"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @()
    Notes = ""
    Tips = "Decode ASN.1 structures such as certificates and Kerberos tickets in scripts."
    Usage = "import pyasn1"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pycares"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "dns")
    Notes = ""
    Tips = "c-ares DNS bindings used by aiodns; nothing to run directly."
    Usage = "import pycares"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pycryptodome"
    Category = "Utilities\Cryptography"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("encryption", "cryptography")
    Notes = ""
    Tips = "Crypto primitives (AES, RC4, RSA, ChaCha20, hashes) for decrypting configs and payloads in scripts."
    Usage = "from Crypto.Cipher import AES"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pydivert"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pcap")
    Tags = @("network", "pcap")
    Notes = ""
    Tips = "WinDivert bindings for capturing and modifying packets on the sandbox. Needs the driver and administrator rights."
    Usage = "import pydivert"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pypdf"
    Category = "Files and apps\PDF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pdf")
    Tags = @("pdf", "data-extraction")
    Notes = ""
    Tips = "Read, split and extract text from PDFs in scripts. Use pdf-parser, peepdf or pdfalyzer for malicious PDFs."
    Usage = "import pypdf"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pyshark"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pcap", ".pcapng")
    Tags = @("network-analysis", "pcap", "protocol-analysis")
    Notes = ""
    Tips = "Wireshark dissectors from Python. Requires tshark, so install Wireshark on demand first."
    Usage = "import pyshark; cap = pyshark.FileCapture('file.pcap')"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "PySocks"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network")
    Notes = ""
    Tips = "SOCKS proxy support for Python sockets and requests; nothing to run directly."
    Usage = "import socks"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "python-docx"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".docx")
    Tags = @("office", "data-extraction")
    Notes = ""
    Tips = "Read and write DOCX files from Python; docx2txt is the quick text dumper."
    Usage = "import docx"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "python-dotenv"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @()
    Notes = ""
    Tips = "Loads .env files into the environment for scripts; nothing to run directly."
    Usage = "from dotenv import load_dotenv"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "python-magic"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @()
    Notes = ""
    Tips = "libmagic bindings giving the same identification as the file command. magika is the machine learning alternative."
    Usage = "import magic; magic.from_file('file')"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "python-registry"
    Category = "OS\Windows\Registry"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".reg", ".dat")
    Tags = @("registry", "windows", "forensics")
    Notes = ""
    Tips = "Library for offline registry hives. regipy is more actively maintained, but python-registry is still used by several older scripts."
    Usage = "import Registry"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pyvis"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("visualization", "graph")
    Notes = ""
    Tips = "Interactive network graphs in HTML from networkx graphs; open the result in a browser."
    Usage = "from pyvis.network import Network"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pyzipper"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".zip")
    Tags = @("compression", "encryption")
    Notes = ""
    Tips = "AES encrypted zip support (read and write) in Python, for example for password protected malware archives."
    Usage = "import pyzipper"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "requests"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "http")
    Notes = ""
    Tips = "HTTP client library for scripts; needs the network sandbox to reach the internet."
    Usage = "import requests"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "rzpipe"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin")
    Tags = @("reverse-engineering", "scripting")
    Notes = ""
    Tips = "Script Rizin (the engine behind Cutter) from Python with r.cmd('aaa'). r2pipe works the same for radare2."
    Usage = "import rzpipe; r = rzpipe.open('file.exe')"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "sigma-cli"
    Category = "Signatures and information"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\sigma-cli (This is the Sigma command line interface using the pySigma library to manage, list and convert Sigma rules into query languages).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sigma.exe --help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\default\Scripts\sigma.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "log-analysis")
    Notes = ""
    Tips = "Converts Sigma rules using the installed backends (elasticsearch, loki, splunk, sqlite) and pipelines (sysmon, windows). 'sigma list targets' shows what is available and 'sigma check' validates rules."
    Usage = "sigma convert -t <target> -p <pipeline> <rules dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-backend-elasticsearch"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "log-analysis", "search")
    Notes = ""
    Tips = "Elasticsearch backend for sigma-cli producing Lucene, EQL or ES|QL queries."
    Usage = "sigma convert -t lucene <rules dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pySigma-backend-loki"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection")
    Notes = ""
    Tips = "Loki backend for sigma-cli producing LogQL queries for Grafana Loki."
    Usage = "sigma convert -t loki <rules dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-backend-splunk"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "siem")
    Notes = ""
    Tips = "Splunk backend for sigma-cli producing SPL searches and saved search configuration."
    Usage = "sigma convert -t splunk <rules dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-backend-sqlite"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "sqlite")
    Notes = ""
    Tips = "SQLite backend for sigma-cli, useful for running Sigma rules against log data loaded into an SQLite database."
    Usage = "sigma convert -t sqlite <rules dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-pipeline-sysmon"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "event-log", "windows")
    Notes = ""
    Tips = "Pipeline that maps generic Sigma log sources to Sysmon event IDs; use it together with the windows pipeline."
    Usage = "sigma convert -t <target> -p sysmon <rules dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-pipeline-windows"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "windows")
    Notes = ""
    Tips = "Pipelines that map generic Sigma log sources to Windows event log channels and audit event IDs."
    Usage = "sigma convert -t <target> -p windows-logsources <rules dir>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "simplejson"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".json")
    Tags = @("json", "data-processing")
    Notes = ""
    Tips = "JSON library used by other tools; nothing to run directly."
    Usage = "import simplejson"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "termcolor"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("terminal")
    Notes = ""
    Tips = "Coloured terminal output for scripts; nothing to run directly."
    Usage = "import termcolor"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "textsearch"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("data-processing", "search")
    Notes = ""
    Tips = "Fast multi keyword search library used by other tools; nothing to run directly."
    Usage = "import textsearch"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "tomlkit"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".toml")
    Tags = @("parsing", "data-processing")
    Notes = ""
    Tips = "TOML parsing library used by other tools; nothing to run directly."
    Usage = "import tomlkit"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "treelib"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("data-processing", "filesystem")
    Notes = ""
    Tips = "Tree data structure library, handy for printing process or directory trees in scripts."
    Usage = "import treelib"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "unicorn"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "emulation")
    Notes = ""
    Tips = "CPU emulator library. Emulate shellcode or decryption routines in scripts; speakeasy and scare are the higher level tools built on it."
    Usage = "import unicorn"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "xxhash"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("hashing")
    Notes = ""
    Tips = "Fast non cryptographic hashing used by other tools; nothing to run directly."
    Usage = "import xxhash"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "yara-python"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yar", ".yara")
    Tags = @("yara", "malware-analysis", "detection")
    Notes = ""
    Tips = "YARA from Python for scripted scanning. The yara and yr command line tools are usually more convenient for one off scans."
    Usage = "import yara; rules = yara.compile('rules.yar')"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "dfir-unfurl"
    Category = "Files and apps\Browser"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl_app.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command C:\venv\dfir-unfurl\Scripts\unfurl_app.exe"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Browser\unfurl.exe (unfurl takes a URL and expands it into a directed graph - dfir-unfurl).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command C:\venv\dfir-unfurl\Scripts\unfurl.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\venv\dfir-unfurl\Scripts\unfurl.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("osint", "network", "forensics", "visualization")
    Notes = ""
    Tips = "Breaks URLs into their parts and decodes embedded timestamps, IDs and tracking data (Google, Twitter, Discord, Snowflake IDs). Start the web UI with unfurl_app for a graph view. Runs in its own venv (venv.ps1 -unfurl)."
    Usage = "unfurl '<url>'"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "hexdump"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".bin")
    Tags = @("hex-editor", "binary-analysis")
    Notes = ""
    Tips = "Simple hex dump from Python. ImHex or xxd from MSYS2 give more options."
    Usage = "hexdump <file>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

$TOOL_DEFINITIONS += @{
    Name = "maclookup"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network")
    Notes = ""
    Tips = "Looks up the vendor for a MAC address from the OUI database; updating the database needs the network sandbox."
    Usage = "maclookup <mac address>"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
    Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "python"

if ($SUPPLY_CHAIN_SECURITY_AUDIT) {
    # Audit Python packages installed via uv tool (each tool has an isolated venv under UV_TOOL_DIR)
    Write-DateLog "pip-audit: auditing uv tool environments." >> "C:\log\python.txt"
    Get-ChildItem "${env:UV_TOOL_DIR}" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Write-DateLog "pip-audit: $($_.Name)" >> "C:\log\python.txt"
        uvx pip-audit --path $_.FullName 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
    }
    # Also audit the shared default venv
    Write-DateLog "pip-audit: auditing venv default." >> "C:\log\python.txt"
    uvx pip-audit --path "C:\venv\default" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
} else {
    Write-DateLog "pip-audit: Supply chain security audit disabled - skipping pip-audit." >> "C:\log\python.txt"
}

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > C:\venv\default\done
