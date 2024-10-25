# Set default encoding to UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

Write-Output "Start installation of Python in Sandbox."

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

$GHIDRA_INSTALL_DIR = (Get-ChildItem "${TOOLS}\ghidra\").FullName | findstr.exe PUBLIC | Select-Object -Last 1

if (! (Test-Path "${WSDFIR_TEMP}")) {
    New-Item -ItemType Directory -Force -Path "${WSDFIR_TEMP}" | Out-Null
}

Write-Output "Get-Content C:\log\python.txt -Wait" | Out-File -FilePath "C:\Progress.ps1" -Encoding "ascii"
Write-Output "PowerShell.exe -ExecutionPolicy Bypass -File C:\Progress.ps1" | Out-File -FilePath "$HOME\Desktop\Progress.cmd" -Encoding "ascii"

Write-DateLog "Install Git." >> "C:\log\python.txt"
Add-ToUserPath "${env:ProgramFiles}\Git\bin" | Out-Null
Add-ToUserPath "${env:ProgramFiles}\Git\cmd" | Out-Null
#Add-ToUserPath "${env:ProgramFiles}\Git\usr\bin" | Out-Null
Install-Git | Out-Null
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")

Write-DateLog "Install Python in Sandbox." >> "C:\log\python.txt"
$PYTHON_BIN="$env:ProgramFiles\Python311\python.exe"
Start-Process "${SETUP_PATH}\python3.exe" -Wait -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
Get-Job | Receive-Job 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

#
# venv default
#
Write-DateLog "Install packages in venv default in sandbox." >> "C:\log\python.txt"
if (Test-Path "C:\venv\default") {
    Get-ChildItem C:\venv\default\ -Exclude config.ps1 | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
}
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\default"
C:\venv\default\Scripts\Activate.ps1 >> "C:\log\python.txt"
Set-Location "C:\venv\default\"
python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
python -m pip install -U poetry 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
# TODO: Get latest version of package
python -m pip install https://github.com/msuhanov/dfir_ntfs/archive/1.1.18.tar.gz 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"

poetry init `
    --name default `
    --description "Default Python venv for dfirws." `
    --author "dfirws" `
    --license "MIT" `
    --no-interaction >> "C:\log\python.txt"

# Install packages with poetry
poetry add `
    aiohttp[speedups] `
    autoit-ripper `
    cabarchive `
    cart `
    deep_translator `
    dnslib `
    docx2txt `
    dotnetfile `
    dpkt `
    elasticsearch[async] `
    evtx `
    extract-msg>=0.48.4 `
    flatten_json `
    frida-tools `
    ghidriff `
    graphviz `
    grip `
    hachoir `
    jsbeautifier `
    jupyterlab `
    keystone-engine `
    lief `
    LnkParse3 `
    matplotlib `
    minidump `
    msticpy `
    mkyara `
    name-that-hash `
    neo4j `
    neo4j-driver `
    netaddr `
    networkx `
    numpy `
    olefile `
    oletools[full] `
    openpyxl `
    orjson `
    pcode2code `
    peutils `
    ppdeep `
    prettytable `
    protodeep `
    ptpython `
    pwncat `
    pyOneNote `
    pypdf `
    PyPDF2 `
    pypng `
    python-magic `
    python-magic-bin `
    pyvis `
    pyzipper `
    rzpipe `
    setuptools `
    shodan `
    stego-lsb `
    termcolor `
    textsearch `
    time-decode `
    tomlkit `
    treelib `
    unicorn `
    unpy2exe `
    visidata `
    xlrd `
    XLMMacroDeobfuscator `
    XlsxWriter `
    xxhash `
    yara-python 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"

Write-DateLog "Install extra scripts in venv." >> "C:\log\python.txt"
Set-Location "C:\venv\default\Scripts"
C:\Windows\System32\curl.exe -L --silent -o "machofile-cli.py" "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile-cli.py"
C:\Windows\System32\curl.exe -L --silent -o "machofile.py" "https://raw.githubusercontent.com/pstirparo/machofile/main/machofile.py"
C:\Windows\System32\curl.exe -L --silent -o "msidump.py" "https://raw.githubusercontent.com/mgeeky/msidump/main/msidump.py"
C:\Windows\System32\curl.exe -L --silent -o "shellconv.py" "https://raw.githubusercontent.com/hasherezade/shellconv/master/shellconv.py"
C:\Windows\System32\curl.exe -L --silent -o "smtpsmug.py" "https://raw.githubusercontent.com/hannob/smtpsmug/main/smtpsmug"
C:\Windows\System32\curl.exe -L --silent -o "SQLiteWalker.py" "https://raw.githubusercontent.com/stark4n6/SQLiteWalker/main/SQLiteWalker.py"
C:\Windows\System32\curl.exe -L --silent -o "CanaryTokenScanner.py" "https://raw.githubusercontent.com/0xNslabs/CanaryTokenScanner/main/CanaryTokenScanner.py"
C:\Windows\System32\curl.exe -L --silent -o "sigs.py" "https://raw.githubusercontent.com/clausing/scripts/master/sigs.py"

(Get-Content .\machofile-cli.py -raw) -replace "#!/usr/bin/python","#!/usr/bin/env python" | Set-Content -Path ".\machofile-cli2.py"
Copy-Item machofile-cli2.py machofile-cli.py
Remove-Item machofile-cli2.py

(Get-Content .\machofile.py -raw) -replace "#!/usr/bin/python","#!/usr/bin/env python" | Set-Content -Path ".\machofile2.py"
Copy-Item machofile2.py machofile.py
Remove-Item machofile2.py

# Install rat_king_parser
python -m pip install "git+https://github.com/jeFF0Falltrades/rat_king_parser.git" 2>&1 | ForEach-Object { "$_" } >> "C:\log\python.txt"

if (Test-Path "C:\git\bmc-tools\bmc-tools.py") {
    Copy-Item "C:\git\bmc-tools\bmc-tools.py" "C:\venv\default\Scripts\bmc-tools.py"
}

if (Test-Path "C:\git\dotnetfile\examples\dotnetfile_dump.py") {
    Copy-Item "C:\git\dotnetfile\examples\dotnetfile_dump.py" "C:\venv\default\Scripts\dotnetfile_dump.py"
}

foreach ($iShutdown in @("iShutdown_detect.py", "iShutdown_parse.py", "iShutdown_stats.py")) {
    if (Test-Path "C:\git\iShutdown\$iShutdown") {
        Copy-Item "C:\git\iShutdown\$iShutdown" "C:\venv\default\Scripts\$iShutdown"
    }
}

New-Item -ItemType Directory C:\tmp\rename 2>&1 | ForEach-Object{ "$_" } | Out-null
Get-ChildItem C:\venv\default\Scripts\ -Exclude *.exe,*.py,*.ps1,activate,__pycache__,*.bat | ForEach-Object { Move-Item $_ C:\tmp\rename }
Set-Location C:\tmp\rename
Get-ChildItem | Rename-Item -NewName { $_.Name +".py" }
Copy-Item * C:\venv\default\Scripts

deactivate
Write-DateLog "Python venv default done." >> "C:\log\python.txt"


#
# Venvs that needs Visual Studio Build Tools
#

# Get current versions to check if they have been updated and needs to be reinstalled
Get-LatestPipVersion ingestr > "${WSDFIR_TEMP}\visualstudio.txt"
Get-LatestPipVersion jep >> "${WSDFIR_TEMP}\visualstudio.txt"
Get-LatestPipVersion pdfalyzer >> "${WSDFIR_TEMP}\visualstudio.txt"
Get-LatestPipVersion regipy >> "${WSDFIR_TEMP}\visualstudio.txt"
((C:\Windows\System32\curl.exe -L --silent "https://api.github.com/repos/mandiant/Ghidrathon/releases/latest" | ConvertFrom-Json).zipball_url.ToString()).Split("/")[-1] >> "${WSDFIR_TEMP}\visualstudio.txt"
$GHIDRA_INSTALL_DIR >> "${WSDFIR_TEMP}\visualstudio.txt"

if (Test-Path "C:\venv\visualstudio.txt") {
    $CURRENT_VENV = "C:\venv\visualstudio.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash "${WSDFIR_TEMP}\visualstudio.txt").Hash -ne (Get-FileHash "$CURRENT_VENV").Hash) {
    # Install Visual Studio Build Tools
    Write-DateLog "Start installation of Visual Studio Build Tools." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    # https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019
    # https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2019
    # https://wiki.python.org/moin/WindowsCompilers
    if (Test-Path "${TOOLS}\VSLayout\vs_BuildTools.exe") {
        Start-Process -Wait "${TOOLS}\VSLayout\vs_BuildTools.exe" -ArgumentList "--passive --norestart --force --installWhileDownloading --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.TestTools.BuildTools --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.CLI.Support --installPath C:\BuildTools"
    } else {
        Start-Process -Wait "${SETUP_PATH}\vs_BuildTools.exe" -ArgumentList "--passive --norestart --force --installWhileDownloading --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.TestTools.BuildTools --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.CLI.Support --installPath C:\BuildTools"
    }
    C:\BuildTools\Common7\Tools\VsDevCmd.bat >> "C:\log\python.txt"

    #
    # venv jep and tools needed for jep
    #

    # Check if jep or ghidrathon has been updated
    Get-LatestPipVersion jep > ${WSDFIR_TEMP}\jep.txt
    ((C:\Windows\System32\curl.exe -L --silent "https://api.github.com/repos/mandiant/Ghidrathon/releases/latest" | ConvertFrom-Json).zipball_url.ToString()).Split("/")[-1] >> ${WSDFIR_TEMP}\jep.txt
    $GHIDRA_INSTALL_DIR >> ${WSDFIR_TEMP}\jep.txt

    if (Test-Path "C:\venv\jep\jep.txt") {
        $CURRENT_VENV = "C:\venv\jep\jep.txt"
    } else {
        $CURRENT_VENV = "C:\Progress.ps1"
    }

    if ((Get-FileHash C:\tmp\jep.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
        Write-DateLog "jep or ghidrathon has been updated. Update jep." >> "C:\log\python.txt"

        # Install Java for jep
        Write-DateLog "Start installation of Corretto Java." 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        Start-Process -Wait msiexec -ArgumentList "/i ${SETUP_PATH}\corretto.msi /qn /norestart"
        Get-Job | Receive-Job 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        $env:JAVA_HOME="C:\Program Files\Amazon Corretto\"+(Get-ChildItem 'C:\Program Files\Amazon Corretto\').Name

        # jep venv
        if (Test-Path "C:\venv\jep") {
            Get-ChildItem C:\venv\jep\ -Exclude jep.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
        }

        # Set environment variables for Visual Studio Build Tools
        $env:DISTUTILS_USE_SDK=1
        $env:MSSdk=1
        $env:LIB = "C:\BuildTools\VC\Tools\MSVC\14.29.30133\lib\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\shared\x64;" + $env:LIB
        $env:INCLUDE = "C:\BuildTools\VC\Tools\MSVC\14.29.30133\include" + ";C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0" + $env:INCLUDE
        C:\BuildTools\VC\Auxiliary\Build\vcvarsall.bat amd64 >> "C:\log\python.txt"
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")+ ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64;C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64"

        Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\jep"
        C:\venv\jep\Scripts\Activate.ps1 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        Set-Location "C:\venv\jep" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

        python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        python -m pip install -U setuptools 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        python -m pip install NumPy flare-capa 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

        # Build Ghidrathon for Gidhra
        Write-DateLog "Build Ghidrathon for Ghidra."
        Copy-Item -Force -Recurse "${TOOLS}\ghidrathon" "${WSDFIR_TEMP}"
        Set-Location "${WSDFIR_TEMP}\ghidrathon"
        python -m pip install -r requirements.txt NumPy flare-capa 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        python "ghidrathon_configure.py" "${GHIDRA_INSTALL_DIR}" --debug 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        if (! (Test-Path "${TOOLS}\ghidra_extensions")) {
            New-Item -ItemType Directory -Force -Path "${TOOLS}\ghidra_extensions" | Out-Null
        }
        Copy-Item ${WSDFIR_TEMP}\ghidrathon\*.zip "${TOOLS}\ghidra_extensions\" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

        Copy-Item "${WSDFIR_TEMP}\jep.txt" "C:\venv\jep\jep.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        deactivate
        Write-DateLog "Python venv jep done." >> "C:\log\python.txt"
    } else {
        Write-DateLog "Neither jep or ghidrathon has been updated, don't build jep." >> "C:\log\python.txt"
    }

    #
    # venv regipy
    #
    Get-LatestPipVersion regipy > ${WSDFIR_TEMP}\regipy.txt

    if (Test-Path "C:\venv\regipy\regipy.txt") {
        $CURRENT_VENV = "C:\venv\regipy\regipy.txt"
    } else {
        $CURRENT_VENV = "C:\Progress.ps1"
    }

    if ((Get-FileHash C:\tmp\regipy.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
        Write-DateLog "Install packages in venv regipy in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
        if (Test-Path "C:\venv\regipy") {
            Get-ChildItem C:\venv\regipy\ -Exclude regipy.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
        }
        Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\regipy"
        C:\venv\regipy\Scripts\Activate.ps1 >> "C:\log\python.txt"
        Set-Location "C:\venv\regipy"

        python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        python -m pip install -U zipp 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        python -m pip install -U regipy>=4.0.0 click libfwsi-python python-evtx tabulate 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

        Copy-Item "${WSDFIR_TEMP}\regipy.txt" "C:\venv\regipy\regipy.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

        # Download parseUSBs.py and update shebang
        Set-Location "C:\venv\regipy\Scripts"
        C:\Windows\System32\curl.exe -L --silent -o "parseUSBs.py" "https://raw.githubusercontent.com/khyrenz/parseusbs/main/parseUSBs.py"
        (Get-Content .\parseUSBs.py -raw) -replace "#!/bin/python","#!/usr/bin/env python" | Set-Content -Path ".\parseUSBs2.py"
        Copy-Item parseUSBs2.py parseUSBs.py
        Remove-Item parseUSBs2.py

        deactivate
        Write-DateLog "Python venv regipy done." >> "C:\log\python.txt"
    } else {
        Write-DateLog "regipy has not been updated, don't update regipy venv." >> "C:\log\python.txt"
    }


    #
    # Standard venvs needing Visual Studio Build Tools
    #

    foreach ($virtualenv in "ingestr", "pdfalyzer") {
        Get-LatestPipVersion "${virtualenv}" > "${WSDFIR_TEMP}\${virtualenv}.txt"

        if (Test-Path "C:\venv\${virtualenv}\${virtualenv}.txt") {
            $CURRENT_VENV = "C:\venv\${virtualenv}\${virtualenv}.txt"
        } else {
            $CURRENT_VENV = "C:\Progress.ps1"
        }

        if ((Get-FileHash C:\tmp\${virtualenv}.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
            Write-DateLog "Install packages in venv ${virtualenv} in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
            if (Test-Path "C:\venv\${virtualenv}") {
                Get-ChildItem C:\venv\${virtualenv}\ -Exclude ${virtualenv}.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
            }

            # Set environment variables for Visual Studio Build Tools
            $env:DISTUTILS_USE_SDK=1
            $env:MSSdk=1
            $env:LIB = "C:\BuildTools\VC\Tools\MSVC\14.29.30133\lib\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\shared\x64;" + $env:LIB
            $env:INCLUDE = "C:\BuildTools\VC\Tools\MSVC\14.29.30133\include" + ";C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0" + $env:INCLUDE
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64;C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64"

            Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\${virtualenv}"
            & "C:\venv\${virtualenv}\Scripts\Activate.ps1" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
            Set-Location "C:\venv\${virtualenv}"

            python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

            Write-DateLog "Install ${virtualenv} in venv." >> "C:\log\python.txt"
            python -m pip install -U "${virtualenv}" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

            Copy-Item "${WSDFIR_TEMP}\${virtualenv}.txt" "C:\venv\${virtualenv}\${virtualenv}.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

            deactivate
            Write-DateLog "Python venv ${virtualenv} done." >> "C:\log\python.txt"
        } else {
            Write-DateLog "${virtualenv} has not been updated, don't update ${virtualenv} venv." >> "C:\log\python.txt"
        }

        # Save current versions
        Copy-Item "${WSDFIR_TEMP}\${virtualenv}.txt" "C:\venv\${virtualenv}\${virtualenv}.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    }
    Copy-Item "${WSDFIR_TEMP}\visualstudio.txt" "C:\venv\visualstudio.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
} else {
    Write-DateLog "Visual Studio Build Tools or pypi packages requiring it has not been updated, don't update venvs needing Visual Studio Build Tools." >> "C:\log\python.txt"
}

#
# venv white-phoenix
#
C:\Windows\System32\curl.exe -L --silent -o "${WSDFIR_TEMP}\white-phoenix.txt" "https://raw.githubusercontent.com/cyberark/White-Phoenix/main/requirements.txt" >> "C:\log\python.txt"
Get-Content "${WSDFIR_TEMP}\white-phoenix.txt" >> "C:\log\python.txt"
if (Test-Path "C:\venv\white-phoenix\white-phoenix.txt") {
    $CURRENT_VENV = "C:\venv\white-phoenix\white-phoenix.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash ${WSDFIR_TEMP}\white-phoenix.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv white-phoenix in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    if (Test-Path "C:\venv\white-phoenix") {
        Get-ChildItem C:\venv\white-phoenix\ -Exclude white-phoenix.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
    }
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\white-phoenix"
    C:\venv\white-phoenix\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Set-Location "C:\venv\white-phoenix"

    python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -r "${WSDFIR_TEMP}\white-phoenix.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    Copy-Item "${WSDFIR_TEMP}\white-phoenix.txt" "C:\venv\white-phoenix\white-phoenix.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    deactivate
    Write-DateLog "Python venv white-phoenix done." >> "C:\log\python.txt"
} else {
    Write-DateLog "white-phoenix has not been updated, don't update white-phoenix venv." >> "C:\log\python.txt"
}

#
# venv dfir-unfurl
#
Get-LatestPipVersion dfir-unfurl > ${WSDFIR_TEMP}\dfir-unfurl.txt

if (Test-Path "C:\venv\dfir-unfurl\dfir-unfurl.txt") {
    $CURRENT_VENV = "C:\venv\dfir-unfurl\dfir-unfurl.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\dfir-unfurl.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv dfir-unfurl in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    if (Test-Path "C:\venv\dfir-unfurl") {
        Get-ChildItem C:\venv\dfir-unfurl\ -Exclude dfir-unfurl.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
    }
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\dfir-unfurl"
    C:\venv\dfir-unfurl\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Set-Location "C:\venv\dfir-unfurl"

    python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    python -m pip install -U `
        dfir-unfurl[ui] `
        hexdump `
        maclookup `
        tomlkit 2>&1 | ForEach-Object{ "$_" } 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

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
    Copy-Item ${WSDFIR_TEMP}\dfir-unfurl.txt "C:\venv\dfir-unfurl\dfir-unfurl.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    deactivate
    Set-Content "C:\venv\dfir-unfurl\Scripts\python.exe C:\venv\dfir-unfurl\Scripts\unfurl_app.py" -Encoding Ascii -Path "C:\venv\default\Scripts\unfurl_app.ps1"
    Set-Content "C:\venv\dfir-unfurl\Scripts\python.exe C:\venv\dfir-unfurl\Scripts\unfurl_cli.py `$args" -Encoding Ascii -Path "C:\venv\default\Scripts\unfurl_cli.ps1"
    Write-DateLog "Python venv dfir-unfurl done." >> "C:\log\python.txt"
} else {
    Write-DateLog "dfir-unfurl has not been updated, don't update dfir-unfurl venv." >> "C:\log\python.txt"
}


#
# venv aspose
#
Get-LatestPipVersion Aspose.Email-for-Python-via-Net > ${WSDFIR_TEMP}\aspose.txt

if (Test-Path "C:\venv\aspose\aspose.txt") {
    $CURRENT_VENV = "C:\venv\aspose\aspose.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\aspose.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv aspose in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    if (Test-Path "C:\venv\aspose") {
        Get-ChildItem C:\venv\aspose\ -Exclude aspose.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
    }
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\aspose"
    C:\venv\aspose\Scripts\Activate.ps1 >> "C:\log\python.txt"
    Set-Location "C:\venv\aspose"

    python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -U Aspose.Email-for-Python-via-Net 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    Copy-Item ${WSDFIR_TEMP}\aspose.txt "C:\venv\aspose\aspose.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    deactivate
    Write-DateLog "Python venv aspose done." >> "C:\log\python.txt"
} else {
    Write-DateLog "aspose has not been updated, don't update aspose venv." >> "C:\log\python.txt"
}

#
# venv pe2pic
#
Set-Location "C:\tmp"

C:\Windows\System32\curl.exe -L --silent -o "pe2pic.py" "https://raw.githubusercontent.com/hasherezade/pe2pic/master/pe2pic.py"
C:\Windows\System32\curl.exe -L --silent -o "pe2pic_requirements.txt" "https://raw.githubusercontent.com/hasherezade/pe2pic/master/requirements.txt"

Get-FileHash -Path "pe2pic.py" -Algorithm SHA256 | Select-Object -ExpandProperty Hash > "C:\tmp\pe2pic.txt"
Get-FileHash -Path "pe2pic_requirements.txt" -Algorithm SHA256 | Select-Object -ExpandProperty Hash >> "C:\tmp\pe2pic.txt"

if (Test-Path "C:\venv\pe2pic\pe2pic.txt") {
    $CURRENT_VENV = "C:\venv\pe2pic\pe2pic.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\pe2pic.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv pe2pic in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    if (Test-Path "C:\venv\pe2pic") {
        Get-ChildItem C:\venv\pe2pic\ -Exclude pe2pic.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
    }
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\pe2pic"
    C:\venv\pe2pic\Scripts\Activate.ps1 >> "C:\log\python.txt"

    python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -U setuptools wheel 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -r "C:\tmp\pe2pic_requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    Copy-Item "C:\tmp\pe2pic.py" "C:\venv\pe2pic\Scripts\pe2pic.py" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    Copy-Item "C:\tmp\pe2pic.txt" "C:\venv\pe2pic\pe2pic.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    deactivate
    Set-Content "C:\venv\pe2pic\Scripts\python.exe C:\venv\pe2pic\Scripts\pe2pic.py `$args" -Encoding Ascii -Path C:\venv\default\Scripts\pe2pic.ps1
    Write-DateLog "Python venv pe2pic done." >> "C:\log\python.txt"
} else {
    Write-DateLog "pe2pic has not been updated, don't update pe2pic venv." >> "C:\log\python.txt"
}


#
# venv evt2sigma
#
Set-Location "C:\tmp"

C:\Windows\System32\curl.exe -L --silent -o "evt2sigma.py" "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/evt2sigma.py"
C:\Windows\System32\curl.exe -L --silent -o "evt2sigma_requirements.txt" "https://raw.githubusercontent.com/Neo23x0/evt2sigma/master/requirements.txt"

Get-FileHash -Path "evt2sigma.py" -Algorithm SHA256 | Select-Object -ExpandProperty Hash > "C:\tmp\evt2sigma.txt"
Get-FileHash -Path "evt2sigma_requirements.txt" -Algorithm SHA256 | Select-Object -ExpandProperty Hash >> "C:\tmp\evt2sigma.txt"

if (Test-Path "C:\venv\evt2sigma\evt2sigma.txt") {
    $CURRENT_VENV = "C:\venv\evt2sigma\evt2sigma.txt"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\tmp\evt2sigma.txt).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv evt2sigma in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    if (Test-Path "C:\venv\evt2sigma") {
        Get-ChildItem C:\venv\evt2sigma\ -Exclude evt2sigma.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
    }
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\evt2sigma"
    C:\venv\evt2sigma\Scripts\Activate.ps1 >> "C:\log\python.txt"

    python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -U setuptools wheel 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -r "C:\tmp\evt2sigma_requirements.txt" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    Copy-Item "C:\tmp\evt2sigma.py" "C:\venv\evt2sigma\Scripts\evt2sigma.py"
    Set-Content "C:\venv\evt2sigma\Scripts\python.exe C:\venv\evt2sigma\Scripts\evt2sigma.py `$args" -Encoding Ascii -Path "C:\venv\default\Scripts\evt2sigma.ps1"

    Copy-Item "C:\tmp\evt2sigma.txt" "C:\venv\evt2sigma\evt2sigma.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    deactivate
    Write-DateLog "Python venv evt2sigma done." >> "C:\log\python.txt"
} else {
    Write-DateLog "evt2sigma has not been updated, don't update evt2sigma venv." >> "C:\log\python.txt"
}


#
# venv maldump
#

if (! (Test-Path "C:\venv\maldump\Scripts\maldump.exe")) {
    Write-DateLog "Install packages in venv maldump in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    if (Test-Path "C:\venv\maldump") {
        Get-ChildItem C:\venv\maldump\ -Exclude maldump.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
    }
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\maldump"
    C:\venv\maldump\Scripts\Activate.ps1 >> "C:\log\python.txt"

    python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -U setuptools wheel 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -r https://raw.githubusercontent.com/NUKIB/maldump/v0.2.0/requirements.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install maldump==0.2.0 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    deactivate

    Set-Content "`$ErrorActionPreference= 'silentlycontinue'`ndeactivate`nC:\venv\maldump\Scripts\Activate.ps1" -Encoding Ascii -Path "C:\venv\default\Scripts\maldump.ps1"
    Write-DateLog "Python venv maldump done." >> "C:\log\python.txt"
} else {
    Write-DateLog "maldump already installed." >> "C:\log\python.txt"
}


#
# venv scare
#
if (Test-Path "C:\venv\scare\scare\.git\refs\heads\main") {
    $CURRENT_VENV = "C:\venv\scare\scare\.git\refs\heads\main"
} else {
    $CURRENT_VENV = "C:\Progress.ps1"
}

if ((Get-FileHash C:\git\scare\.git\refs\heads\main).Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
    Write-DateLog "Install packages in venv scare in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
    if (Test-Path "C:\venv\scare") {
        Get-ChildItem C:\venv\scare\ -Exclude scare.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
    }
    Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\scare"
    C:\venv\scare\Scripts\Activate.ps1 >> "C:\log\python.txt"

    python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
    python -m pip install -U ptpython setuptools wheel 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    Copy-Item -Recurse "C:\git\scare" "C:\venv\scare"
    Set-Location "C:\venv\scare\scare"

    (Get-Content .\requirements.txt -raw) -replace "capstone","capstone`npyreadline3" | Set-Content -Path ".\requirements2.txt" -Encoding ascii
    python -m pip install -r .\requirements2.txt 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

    (Get-Content .\scarelib.py -raw) -replace "print\(splash\)","splash = 'Simple Configurable Asm REPL && Emulator'`n    print(splash)" | Set-Content -Path ".\scarelib2.py" -Encoding ascii
    Copy-Item scarelib2.py scarelib.py
    Remove-Item scarelib2.py
    Copy-Item C:\venv\scare\scare\*.py "C:\venv\scare\Scripts"

    deactivate

    Set-Content "cd C:\venv\scare\scare && C:\venv\scare\Scripts\ptpython.exe -- C:\venv\scare\scare\scare.py `$args" -Encoding Ascii -Path "C:\venv\default\Scripts\scare.ps1"
    Write-DateLog "Python venv scare done." >> "C:\log\python.txt"
} else {
    Write-DateLog "scare already up to date." >> "C:\log\python.txt"
}


#
# venv dissect
#

# Build every time because of to many dependencies to check in dissect.target
Write-DateLog "Install packages in venv dissect in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
if (Test-Path "C:\venv\dissect") {
    Get-ChildItem C:\venv\dissect\ -Exclude dissect.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
}
Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\dissect"
C:\venv\dissect\Scripts\Activate.ps1 >> "C:\log\python.txt"
python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

pip install `
    acquire `
    dissect `
    dissect.target[yara] `
    flow.record `
    geoip2 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

Copy-Item "C:\venv\dissect\Scripts\acquire-decrypt.exe" "C:\venv\default\Scripts\acquire-decrypt.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\acquire.exe" "C:\venv\default\Scripts\acquire.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\asdf-dd.exe" "C:\venv\default\Scripts\asdf-dd.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\asdf-meta.exe" "C:\venv\default\Scripts\asdf-meta.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\asdf-repair.exe" "C:\venv\default\Scripts\asdf-repair.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\asdf-verify.exe" "C:\venv\default\Scripts\asdf-verify.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\dump-nskeyedarchiver.exe" "C:\venv\default\Scripts\dump-nskeyedarchiver.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\envelope-decrypt.exe" "C:\venv\default\Scripts\envelope-decrypt.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\parse-lnk.exe" "C:\venv\default\Scripts\parse-lnk.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\pip.exe" "C:\venv\default\Scripts\pip.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\pygmentize.exe" "C:\venv\default\Scripts\pygmentize.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\rdump.exe" "C:\venv\default\Scripts\rdump.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\rgeoip.exe" "C:\venv\default\Scripts\rgeoip.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-build-pluginlist.exe" "C:\venv\default\Scripts\target-build-pluginlist.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-dd.exe" "C:\venv\default\Scripts\target-dd.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-dump.exe" "C:\venv\default\Scripts\target-dump.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-fs.exe" "C:\venv\default\Scripts\target-fs.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-info.exe" "C:\venv\default\Scripts\target-info.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-mount.exe" "C:\venv\default\Scripts\target-mount.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-query.exe" "C:\venv\default\Scripts\target-query.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-reg.exe" "C:\venv\default\Scripts\target-reg.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\target-shell.exe" "C:\venv\default\Scripts\target-shell.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\thumbcache-extract-indexed.exe" "C:\venv\default\Scripts\thumbcache-extract-indexed.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\thumbcache-extract.exe" "C:\venv\default\Scripts\thumbcache-extract.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
Copy-Item "C:\venv\dissect\Scripts\vma-extract.exe" "C:\venv\default\Scripts\vma-extract.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

deactivate
Write-DateLog "Python venv dissect done." >> "C:\log\python.txt"


foreach ($virtualenv in "binary-refinery", "chepy", "csvkit", "ghidrecomp", "jpterm", "magika", "malwarebazaar", "mwcp", "peepdf3", "rexi", "sigma-cli", "toolong") {
    #
    # Create simple venv for each tool in list above
    #
    if ("${virtualenv}" -eq "peepdf3") {
        Get-LatestPipVersion "peepdf-3" > "${WSDFIR_TEMP}\${virtualenv}.txt"
    } else {
        Get-LatestPipVersion ${virtualenv} > "${WSDFIR_TEMP}\${virtualenv}.txt"
    }

    if (Test-Path "C:\venv\${virtualenv}\${virtualenv}.txt") {
        $CURRENT_VENV = "C:\venv\${virtualenv}\${virtualenv}.txt"
    } else {
        $CURRENT_VENV = "C:\Progress.ps1"
    }

    if ((Get-FileHash "C:\tmp\${virtualenv}.txt").Hash -ne (Get-FileHash $CURRENT_VENV).Hash) {
        Write-DateLog "Install packages in venv ${virtualenv} in sandbox (needs specific versions of packages)." >> "C:\log\python.txt"
        if (Test-Path "C:\venv\${virtualenv}") {
            Get-ChildItem C:\venv\${virtualenv}\ -Exclude ${virtualenv}.txt | Remove-Item -Force -Recurse 2>&1 | ForEach-Object{ "$_" } | Out-null
        }
        Start-Process -Wait -FilePath "$PYTHON_BIN" -ArgumentList "-m venv C:\venv\${virtualenv}"
        & "C:\venv\${virtualenv}\Scripts\Activate.ps1" >> "C:\log\python.txt"
        Set-Location "C:\venv\${virtualenv}"
        python -m pip install -U pip 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        python -m pip install -U poetry 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

        poetry init `
            --name "${virtualenv}venv" `
            --description "Python venv for ${virtualenv}." `
            --author "dfirws" `
            --license "MIT" `
            --no-interaction 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

        if ("${virtualenv}" -eq "binary-refinery") {
            #python -m pip install -U "zipp>=3.20" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
            python -m pip install `
                binary-refinery[all] "zipp>=3.20" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        } elseif ("${virtualenv}" -eq "chepy") {
            python -m pip install `
                chepy[extras] 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        } elseif (("${virtualenv}" -eq "malwarebazaar") -or ("${virtualenv}" -eq "magika") -or ("${virtualenv}" -eq "sigma-cli")) {
            python -m pip install `
                "${virtualenv}" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        } elseif ("${virtualenv}" -eq "peepdf3") {
            poetry add `
                peepdf-3 pyreadline3 stpyv8 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        } else {
            poetry add `
                "${virtualenv}" 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        }

        Copy-Item "${WSDFIR_TEMP}\${virtualenv}.txt" "C:\venv\${virtualenv}\${virtualenv}.txt" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

        # Custom code for each tool
        if ("${virtualenv}" -eq "sigma-cli") {
            sigma plugin install --force-install sqlite windows sysmon elasticsearch splunk 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"
        }

        deactivate
        Write-DateLog "Python venv ${virtualenv} done." >> "C:\log\python.txt"
    } else {
        Write-DateLog "${virtualenv} has not been updated, don't update ${virtualenv} venv." >> "C:\log\python.txt"
    }
}

Copy-Item "C:\venv\rexi\Scripts\rexi.exe" "C:\venv\default\Scripts\rexi.exe" -Force 2>&1 | ForEach-Object{ "$_" } >> "C:\log\python.txt"

if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

Write-Output "" > C:\venv\default\done
