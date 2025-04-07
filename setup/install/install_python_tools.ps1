# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-Output "Start installation of Python in Sandbox."

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

$GHIDRA_INSTALL_DIR = (Get-ChildItem "${TOOLS}\ghidra\").FullName | findstr.exe PUBLIC | Select-Object -Last 1

$env:UV_TOOL_BIN_DIR = "C:\venv\bin"
$env:UV_TOOL_DIR = "C:\venv\uv"
$env:UV_INSTALL_DIR = "C:\venv\pkg"
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

uv tool install "https://github.com/msuhanov/dfir_ntfs/archive/1.1.19.tar.gz" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
uv tool install "git+https://github.com/jeFF0Falltrades/rat_king_parser.git" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
uv tool install --with "zipp>=3.20" "binary-refinery[extended]" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
uv tool install --with "click, libfwsi-python, python-evtx, tabulate, zipp" "regipy>=4.0.0" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
uv tool install --with "pyreadline3, stpyv8" "peepdf-3" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"

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
    "jpterm",  `
    "jsbeautifier", `
    "jupyterlab", `
    "litecli",  `
    "LnkParse3", `
    "magika", `
    "maldump", `
    "malwarebazaar", `
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
    "pyghidra", `
    "pyOneNote", `
    "pypng", `
    "rexi", `
    "scapy", `
    "shodan", `
    "stego-lsb", `
    "time-decode", `
    "toolong", `
    "unpy2exe", `
    "visidata", `
    "xlrd", `
    "XLMMacroDeobfuscator", `
    "XlsxWriter") {
        uv tool install $package 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"
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

Write-DateLog "Install packages in venv default in sandbox." >> "C:\log\python.txt"
uv venv "C:\venv\default" >> "C:\log\python.txt"
C:\venv\default\Scripts\Activate.ps1 >> "C:\log\python.txt"
Set-Location "C:\venv\default"
uv pip install -U `
    "acquire", `
    "aiohttp[speedups]", `
    "Aspose.Email-for-Python-via-Net", `
    "compressed_rtf", `
    "dissect", `
    "dissect.target[yara]", `
    "flow.record", `
    "geoip2", `
    "cabarchive", `
    "dnslib", `
    "dotnetfile", `
    "dpkt", `
    "elasticsearch", `
    "evtx", `
    "graphviz", `
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
    "openpyxl", `
    "orjson", `
    "peutils", `
    "pefile", `
    "ppdeep", `
    "prettytable", `
    "pypdf", `
    "pypdf2", `
    "python-magic", `
    "python-magic-bin", `
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
    "termcolor", `
    "textsearch", `
    "tomlkit", `
    "treelib", `
    "unicorn", `
    "xxhash", `
    "yara-python" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

#
# venv white-phoenix
#
Write-DateLog "Install packages in venv white-phoenix in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
C:\Windows\System32\curl.exe -L --silent -o "${WSDFIR_TEMP}\white-phoenix.txt" "https://raw.githubusercontent.com/cyberark/White-Phoenix/main/requirements.txt" 2>&1 >> "C:\log\python.txt"
uv venv "C:\venv\white-phoenix" >> "C:\log\python.txt"
C:\venv\white-phoenix\Scripts\Activate.ps1 >> "C:\log\python.txt"
Set-Location "C:\venv\white-phoenix"
uv pip install -r "${WSDFIR_TEMP}\white-phoenix.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
deactivate
Write-DateLog "Python venv white-phoenix done." >> "C:\log\python.txt"

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
# Venvs that needs Visual Studio Build Tools
#

if (Test-Path "${TOOLS}\VSLayout\vs_BuildTools.exe") {
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

    Write-DateLog "Install Python packages in sandbox needing Visual Studio Build Tools." >> "C:\log\python.txt"
    uv venv "C:\venv\jep" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    C:\venv\jep\Scripts\Activate.ps1 >> "C:\log\python.txt"

    # Build Ghidrathon for Gidhra
    Write-DateLog "Build Ghidrathon for Ghidra." >> "C:\log\python.txt"
    Copy-Item -Force -Recurse "${TOOLS}\ghidrathon" "${WSDFIR_TEMP}"
    Set-Location "${WSDFIR_TEMP}\ghidrathon"
    Get-Content requirements.txt >> "C:\log\python.txt"
    uv pip install "jep==4.2.0" NumPy flare-capa 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    uv pip install -r requirements.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python "ghidrathon_configure.py" "${GHIDRA_INSTALL_DIR}" --debug 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    if (! (Test-Path "${TOOLS}\ghidra_extensions")) {
        New-Item -ItemType Directory -Force -Path "${TOOLS}\ghidra_extensions" | Out-Null
    }
    Copy-Item ${WSDFIR_TEMP}\ghidrathon\*.zip "${TOOLS}\ghidra_extensions\" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv jep done." >> "C:\log\python.txt"
}
# End venvs needing Visual Studio Build Tools

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > C:\venv\default\done
