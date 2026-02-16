# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-Output "Start installation of Python in Sandbox."

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"
. "C:\Users\WDAGUtilityAccount\Documents\tools\shared.ps1"

$TOOL_DEFINITIONS = @()
$PYTHON_DEFAULT = "3.11"

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
Start-Process "${SETUP_PATH}\python3.exe" -Wait -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
Get-Job | Receive-Job 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

#
# Install Python packages
#
Write-DateLog "Install Python packages in sandbox." >> "C:\log\python.txt"

uv tool install "git+https://github.com/msuhanov/dfir_ntfs.git" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
if (Test-ToolIncludedSandbox -ToolName "binary-refinery") {
    uv tool install --with "zipp>=3.20" "binary-refinery[extended]" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
}
uv tool install --with "click, libfwsi-python, mcp, python-evtx, tabulate, zipp" "regipy>=4.0.0" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
uv tool install --with "pyreadline3, stpyv8" "peepdf-3" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
uv tool install --with "mkdocs-material" "mkdocs" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"

foreach ($package in `
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
    "litecli",  `
    "LnkParse3", `
    "magika", `
    "maldump", `
    "malwarebazaar", `
    "markitdown[all]", `
    "minidump", `
    "mkyara", `
    "msoffcrypto-tool", `
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
    "XlsxWriter") {
        uv tool install $package 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
}

# Profile-conditional Python packages
if (Test-ToolIncludedSandbox -ToolName "jpterm") {
    uv tool install jpterm 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
}
if (Test-ToolIncludedSandbox -ToolName "pyghidra") {
    uv tool install pyghidra 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
}

Write-DateLog "Install extra scripts in Tools\bin." >> "C:\log\python.txt"
Set-Location "C:\Tools\bin"
C:\Windows\System32\curl.exe -L --silent -o "machofile-cli.py" "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile-cli.py"
C:\Windows\System32\curl.exe -L --silent -o "machofile.py" "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile.py"
C:\Windows\System32\curl.exe -L --silent -o "msidump.py" "https://raw.githubusercontent.com/mgeeky/msidump/main/msidump.py"
C:\Windows\System32\curl.exe -L --silent -o "shellconv.py" "https://raw.githubusercontent.com/hasherezade/shellconv/master/shellconv.py"
C:\Windows\System32\curl.exe -L --silent -o "smtpsmug.py" "https://raw.githubusercontent.com/hannob/smtpsmug/main/smtpsmug"
C:\Windows\System32\curl.exe -L --silent -o "SQLiteWalker.py" "https://raw.githubusercontent.com/stark4n6/SQLiteWalker/main/SQLiteWalker.py"
C:\Windows\System32\curl.exe -L --silent -o "CanaryTokenScanner.py" "https://raw.githubusercontent.com/0xNslabs/CanaryTokenScanner/main/CanaryTokenScanner.py"
C:\Windows\System32\curl.exe -L --silent -o "sigs.py" "https://raw.githubusercontent.com/clausing/scripts/master/sigs.py"
C:\Windows\System32\curl.exe -L --silent -o "defender-dump.py" "https://raw.githubusercontent.com/AlexJ4n6/Defender-Quarantine-Dump/refs/heads/main/defender-dump.py"

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
uv venv "C:\venv\default" >> "C:\log\python.txt"
C:\venv\default\Scripts\Activate.ps1 >> "C:\log\python.txt"
Set-Location "C:\venv\default"
uv pip install -U `
    "acquire", `
    "aiodns", `
    "aiohttp[speedups]", `
    "Aspose.Email-for-Python-via-Net", `
    "BeautifulSoup4", `
    "bitstruct", `
    "compressed_rtf", `
    "dissect", `
    "dissect.target[yara]", `
    "dnslib", `
    "flow.record", `
    "geoip2", `
    "cabarchive", `
    "dnslib", `
    "dotnetfile", `
    "dpkt", `
    "elasticsearch", `
    "evtx", `
    "graphviz", `
    "javaobj-py3", `
    "keystone-engine", `
    "lief", `
    "matplotlib", `
    "minidump", `
    "msoffcrypto-tool", `
    "msticpy", `
    "neo4j", `
    "neo4j-driver", `
    "networkx", `
    "olefile", `
    "oletools", `
    "openpyxl", `
    "orjson", `
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
    "pypdf", `
    "pypdf2", `
    "pyshark", `
    "PySocks", `
    "python-docx", `
    "python-dotenv", `
    "python-magic", `
    "python-magic-bin", `
    "python-registry", `
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
    "termcolor", `
    "textsearch", `
    "tomlkit", `
    "treelib", `
    "unicorn", `
    "xxhash", `
    "yara-python", `
    "win_inet_pton" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

#
# venv white-phoenix
#
if (Test-ToolIncludedSandbox -ToolName "White-Phoenix") {
    Write-DateLog "Install packages in venv white-phoenix in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    C:\Windows\System32\curl.exe -L --silent -o "${WSDFIR_TEMP}\white-phoenix.txt" "https://raw.githubusercontent.com/cyberark/White-Phoenix/main/requirements.txt" 2>&1 >> "C:\log\python.txt"
    uv venv "C:\venv\white-phoenix" >> "C:\log\python.txt"
    C:\venv\white-phoenix\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Set-Location "C:\venv\white-phoenix"
    uv pip install -r "${WSDFIR_TEMP}\white-phoenix.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv white-phoenix done." >> "C:\log\python.txt"
}

### venv for Kanvas
if (Test-ToolIncludedSandbox -ToolName "Kanvas") {
    Write-DateLog "Install packages in venv kanvas in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    git clone https://github.com/WithSecureLabs/Kanvas.git C:\venv\Kanvas 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Set-Location "C:\venv\Kanvas"
    uv venv "C:\venv\Kanvas\.venv" >> "C:\log\python.txt"
    C:\venv\Kanvas\.venv\Scripts\Activate.ps1 >> "C:\log\python.txt"
    uv pip install -r ".\requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    C:\Users\WDAGUtilityAccount\Documents\tools\utils\kanvas_update.ps1 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv kanvas done." >> "C:\log\python.txt"
}

### venv for gostringungarbler
Write-DateLog "Install packages in venv gostringungarbler in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
git clone https://github.com/mandiant/gostringungarbler.git C:\venv\gostringungarbler 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Set-Location "C:\venv\gostringungarbler"
uv venv "C:\venv\gostringungarbler\.venv" >> "C:\log\python.txt"
C:\venv\gostringungarbler\.venv\Scripts\Activate.ps1 >> "C:\log\python.txt"
uv pip install -r ".\requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
deactivate
Write-DateLog "Python venv gostringungarbler done." >> "C:\log\python.txt"

#
# venv dfir-unfurl
#
Write-DateLog "Install packages in venv dfir-unfurl in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
uv venv "C:\venv\dfir-unfurl" >> "C:\log\python.txt"
C:\venv\dfir-unfurl\Scripts\Activate.ps1 >> "C:\log\python.txt"
Set-Location "C:\venv\dfir-unfurl"
uv pip install -U `
        dfir-unfurl[ui] `
        hexdump `
        maclookup `
        tomlkit 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

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
C:\Windows\System32\curl.exe -L --silent -o "pe2pic.py" "https://raw.githubusercontent.com/hasherezade/pe2pic/master/pe2pic.py" 2>&1 >> "C:\log\python.txt"
C:\Windows\System32\curl.exe -L --silent -o "pe2pic_requirements.txt" "https://raw.githubusercontent.com/hasherezade/pe2pic/master/requirements.txt" 2>&1 >> "C:\log\python.txt"
uv venv "C:\venv\pe2pic"
C:\venv\pe2pic\Scripts\Activate.ps1 >> "C:\log\python.txt"
uv pip install -r "C:\tmp\pe2pic_requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
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
    C:\Windows\System32\curl.exe -L --silent -o "evt2sigma.py" "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/evt2sigma.py" 2>&1 >> "C:\log\python.txt"
    C:\Windows\System32\curl.exe -L --silent -o "evt2sigma_requirements.txt" "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/requirements.txt" 2>&1 >> "C:\log\python.txt"
    uv venv "C:\venv\evt2sigma"
    C:\venv\evt2sigma\Scripts\Activate.ps1 >> "C:\log\python.txt"
    uv pip install -r "C:\tmp\evt2sigma_requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Copy-Item "C:\tmp\evt2sigma.py" "C:\venv\evt2sigma\Scripts\evt2sigma.py"
    Set-Content "C:\venv\evt2sigma\Scripts\python.exe C:\venv\evt2sigma\Scripts\evt2sigma.py `$args" -Encoding Ascii -Path "C:\venv\default\Scripts\evt2sigma.ps1"
    deactivate
    Write-DateLog "Python venv evt2sigma done." >> "C:\log\python.txt"
}


#
# venv scare
#
Write-DateLog "Install packages in venv scare in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
uv venv "C:\venv\scare"
Copy-Item -Recurse "C:\git\scare" "C:\venv\scare"
Set-Location "C:\venv\scare\scare"
C:\venv\scare\Scripts\Activate.ps1 >> "C:\log\python.txt"
uv pip install ptpython pyreadline3 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
uv pip install -r .\requirements.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
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
uv venv "C:\venv\zircolite"
C:\venv\zircolite\Scripts\Activate.ps1 >> "C:\log\python.txt"
Copy-Item -Recurse "C:\git\zircolite" "C:\venv\zircolite"
Set-Location "C:\venv\zircolite\zircolite"
uv pip install -r .\requirements.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
python zircolite.py -U 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\zircolite\zircolite\zircolite.py" "C:\venv\zircolite\Scripts"
deactivate
Write-DateLog "Python venv zircolite done." >> "C:\log\python.txt"

#
# Venvs that needs Visual Studio Build Tools
#

$NeedVSBuildTools = $false

if (Test-Path "${TOOLS}\VSLayout\vs_BuildTools.exe" -and $NeedVSBuildTools -eq $true) {
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

    # Install Java for jep
    Write-DateLog "Start installation of Corretto Java." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Start-Process -Wait msiexec -ArgumentList "/i ${SETUP_PATH}\corretto.msi /qn /norestart"
    Get-Job | Receive-Job 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    $env:JAVA_HOME="C:\Program Files\Amazon Corretto\"+(Get-ChildItem 'C:\Program Files\Amazon Corretto\').Name

    ## Set environment variables for Visual Studio Build Tools
    $env:DISTUTILS_USE_SDK=1
    $env:MSSdk=1
    $env:LIB = "C:\BuildTools\VC\Tools\MSVC\14.29.30133\lib\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\shared\x64;" + $env:LIB
    $env:INCLUDE = "C:\BuildTools\VC\Tools\MSVC\14.29.30133\include" + ";C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0" + $env:INCLUDE
    C:\BuildTools\VC\Auxiliary\Build\vcvarsall.bat amd64 >> "C:\log\python.txt"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")+ ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64;C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64"

    #Write-DateLog "Install Python packages in sandbox needing Visual Studio Build Tools." >> "C:\log\python.txt"
    #uv venv "C:\venv\jep" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "mkdocs"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".md", ".yml")
    Tags = @("documentation", "markdown")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("malware-analysis", "autoit", "deobfuscation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("malware-analysis", "packaging")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "csvkit"
    Category = "Malware tools"
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("translation", "text-processing")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("office", "word", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("email", "outlook", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    FileExtensions = @()
    Tags = @()
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("reverse-engineering", "dynamic-analysis", "instrumentation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("markdown", "preview")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("binary-analysis", "metadata", "file-format")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("json", "data-processing", "tui")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("javascript", "deobfuscation", "beautifier")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("python", "notebook", "data-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("windows", "forensics", "shortcut-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("file-identification", "machine-learning")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "maldump"
    Category = "Malware tools"
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
    FileExtensions = @(".dmp")
    Tags = @("malware-analysis", "memory-forensics")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("conversion", "markdown", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("yara", "rule-generation", "malware-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "mwcp"
    Category = "Malware tools"
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
    Tags = @("malware-analysis", "configuration-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("hashing", "identification")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("network", "ip-address")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "numpy"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("data-analysis", "scientific-computing")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "oletools"
    Category = "Files and apps\Office"
    Shortcuts = @(
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
    Tags = @("office", "macro", "malware-analysis", "vba")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pdfalyzer"
    Category = "Files and apps\PDF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pdf")
    Tags = @("pdf", "malware-analysis", "visualization")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("protobuf", "reverse-engineering")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("python", "repl")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("exploitation", "post-exploitation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pyghidra"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf")
    Tags = @("reverse-engineering", "decompiler", "scripting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("Ghidra")
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("office", "onenote", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("image", "steganography")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("regex", "data-processing", "tui")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("network-analysis", "pcap", "packet-crafting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("osint", "network", "reconnaissance")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "stego-lsb"
    Category = "Utilities\CTF"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".png", ".bmp", ".wav")
    Tags = @("steganography", "image", "audio")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "sqlit-tui"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".db", ".sqlite", ".sqlite3")
    Tags = @("database", "sqlite", "tui")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("timestamp", "forensics", "decoding")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("office", "excel", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("office", "macro", "deobfuscation", "malware-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "XlsxWriter"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".xlsx")
    Tags = @("office", "excel")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("forensics", "incident-response", "disk-imaging")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "BeautifulSoup4"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".html", ".htm", ".xml")
    Tags = @("web", "html-parsing", "scraping")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @("enrichment")
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "cabarchive"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".cab")
    Tags = @("archive", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "elasticsearch"
    Category = "Files and apps\Database"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("database", "elasticsearch", "siem")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "keystone-engine"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("reverse-engineering", "assembler")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "matplotlib"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("visualization", "plotting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "msticpy"
    Category = "Forensics"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".json", ".csv")
    Tags = @("threat-intelligence", "incident-response", "jupyter")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "openpyxl"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".xlsx")
    Tags = @("office", "excel", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "paramiko"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "ssh", "scripting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pfp"
    Category = "Files and apps\PE"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".bin")
    Tags = @("binary-analysis", "file-format")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "ppdeep"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("hashing", "fuzzy-hashing", "similarity")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "prettytable"
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("data-processing", "formatting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pydivert"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".pcap")
    Tags = @("network", "packet-capture")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "PySocks"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "proxy")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "python-docx"
    Category = "Files and apps\Office"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".docx")
    Tags = @("office", "word", "data-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pyzipper"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".zip")
    Tags = @("archive", "encryption")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "rzpipe"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".exe", ".dll", ".elf", ".bin")
    Tags = @("reverse-engineering", "radare2", "scripting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-backend-elasticsearch"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "elasticsearch")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pySigma-backend-loki"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "loki")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-backend-splunk"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "splunk")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "pysigma-pipeline-sysmon"
    Category = "Signatures and information"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".yml", ".yaml")
    Tags = @("sigma", "detection", "sysmon")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "termcolor"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("terminal", "formatting")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "textsearch"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("text-processing", "search")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "tomlkit"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".toml")
    Tags = @("toml", "data-processing")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "treelib"
    Category = "Programming\Python"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("data-processing", "tree")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tags = @("url-analysis", "forensics", "visualization")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
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
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

$TOOL_DEFINITIONS += @{
    Name = "maclookup"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("network", "mac-address")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = $PYTHON_DEFAULT
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "python"
if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > C:\venv\default\done
