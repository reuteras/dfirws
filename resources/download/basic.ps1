# Script to download files needed in sandboxes during download.

. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# https://www.7-zip.org/download.html - 7-Zip - installed during start
Write-SynchronizedLog "Downloading 7-Zip."
$7zip_path = Get-DownloadUrlFromPage -url "https://www.7-zip.org/download.html" -RegEx '[^"]+x64.msi'
$status = Get-FileFromUri -uri "https://www.7-zip.org/${7zip_path}" -FilePath ".\downloads\7zip.msi" -CheckURL "Yes" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "7-Zip"
    Homepage = "https://www.7-zip.org/"
    Vendor = "7-Zip"
    License = "GNU LGPL"
    LicenseUrl = "https://www.7-zip.org/license.txt"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\7-Zip.lnk"
            Target   = "`${env:ProgramFiles}\7-Zip\7zFM.exe"
            Args     = ""
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${env:ProgramFiles}\7-Zip\7zFM.exe"
            Expect = "PE32"
        }
    )
    Notes = "7-Zip is a file archive tool."
    Tips = "7-Zip is a free and open-source file archive tool."
    Usage = "7-Zip is a file archive tool with both a graphical and command-line interface."
    SampleCommands = @(
        "7z x archive.zip -oC:\ExtractedFiles",
        "7z a archive.7z C:\FilesToCompress"
        "7z x -pinfected password_protected.7z -oC:\ExtractedFiles"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
    Tags = @()
    FileExtensions = @()
    PythonVersion = ""
}

# git - installed during start
$status = Get-GitHubRelease -repo "git-for-windows/git" -path "${SETUP_PATH}\git.exe" -match "64-bit.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "git"
    Homepage = "https://gitforwindows.org/"
    Vendor = ""
    License = ""
    LicenseUrl = ""
    Category = "Utilities"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Git"
    Verify = @()
    Notes = "A fork of Git containing Windows-specific patches."
    Tips = ""
    Usage = ""
    SampleCommands = @(
        "git clone https://github.com/reuteras/dfirws.git"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
    Tags = @()
    FileExtensions = @()
    PythonVersion = ""
}
#
# Packages used in freshclam sandbox
if ($all -or $Freshclam) {
    # ClamAV - installed during start
    if (Test-ToolIncluded -ToolName "ClamAV") {
        $status = Get-GitHubRelease -repo "Cisco-Talos/clamav" -path "${SETUP_PATH}\clamav.msi" -match "win.x64.msi$" -check "Composite Document File V2 Document"
    }
}

$TOOL_DEFINITIONS += @{
    Name = "ClamAV"
    Homepage = "https://www.clamav.net/"
    Vendor = "Cisco Talos"
    License = "GPL-2.0"
    LicenseUrl = "https://github.com/Cisco-Talos/clamav?tab=GPL-2.0-1-ov-file"
    Category = "Malware tools"
    Shortcuts = @(
        # Add-Shortcut -SourceLnk "${HOME}\Desktop\dfirws\Malware tools\clamav (runs dfirws-install -ClamAV).lnk" -DestinationPath "${CLI_TOOL}" -WorkingDirectory "${HOME}\Desktop" -Arguments "${CLI_TOOL_ARGS} -command dfirws-install.ps1 -ClamAV"
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Malware tools\clamav (runs dfirws-install -ClamAV).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -ClamAV"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -ClamAV"
    Verify = @(
        @{
            Type = "command"
            Name = "`clamscan"
            Expect = "PE32"
        }
    )
    Notes = "ClamAV is an open-source antivirus engine for detecting malware."
    Tips = "ClamAV is a free and open-source antivirus engine for detecting malware, viruses, trojans, and other malicious software."
    Usage = "ClamAV is an antivirus engine that can be used to scan files and directories for malware."
    SampleCommands = @(
        "clamscan -r C:\FilesToScan",
        "clamscan --infected --remove C:\FilesToScan"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
    Tags = @()
    FileExtensions = @()
    PythonVersion = ""
}

#
# Packages used in NodeJS sandbox
if ($all -or $Node) {
    $NodeJSVersion = (Get-DownloadUrlFromPage -url "https://nodejs.org/en/download/prebuilt-binaries" -RegEx 'https://nodejs.org/dist/(v[^/]+)').split('/')[4]

    # nodejs - installed via sandbox during download and setup of tools for dfirws
    $status = Get-FileFromUri -uri "https://nodejs.org/dist/${NodeJSVersion}/node-${NodeJSVersion}-win-x64.zip" -FilePath ".\downloads\nodejs.zip" -CheckURL "Yes" -check "Zip archive data"
}

#
# Packages used in Python sandbox
if ($all -or $Python) {
    # https://www.python.org/downloads/ - Python - installed during start
    Write-SynchronizedLog "winget: Downloading Python."
    $status = Get-WinGet "Python.Python.3.11" "Python*.exe" "python3.exe" -check "PE32"

    # uv - available for installation via dfirws-install.ps1
    Write-SynchronizedLog "winget: Downloading uv."
    $status = Get-WinGet "astral-sh.uv" "uv*.zip" "uv" -check "data"
    if ($status) {
        & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\downloads\uv\uv*.zip" -o"${TOOLS}\bin" | Out-Null
    }

    $TOOL_DEFINITIONS += @{
        Name = "uv"
        Category = "Programming\Python"
        Shortcuts = @()
        InstallVerifyCommand = ""
        Verify = @()
        FileExtensions = @(".py")
        Tags = @("python", "package-management")
        Notes = "uv is a fast Python package installer and manager. It can be used to create and manage virtual environments, install packages, and run Python scripts. It is designed to be a faster and more efficient alternative to pip and virtualenv."
        Tips = ""
        Usage = ""
        SampleCommands = @()
        SampleFiles = @()
        Dependencies = @()
        Homepage = ""
    Vendor = ""
    License = ""
    LicenseUrl = ""
    PythonVersion = ""
}


    # Get Amazon Corretto - installed during start
    $status = Get-FileFromUri -uri "https://corretto.aws/downloads/latest/amazon-corretto-21-x64-windows-jdk.msi" -FilePath ".\downloads\corretto.msi" -check "Composite Document File V2 Document"

    # Ghidra - latest release
    if (Test-ToolIncluded -ToolName "Ghidra") {
        $status = Get-GitHubRelease -repo "NationalSecurityAgency/ghidra" -path "${SETUP_PATH}\ghidra.zip" -match "_PUBLIC_" -check "Zip archive data"
        if ($status) {
            if (Test-Path "${TOOLS}\ghidra") {
                Remove-Item "${TOOLS}\ghidra" -Recurse -Force
            }
            & "$env:ProgramFiles\7-Zip\7z.exe" x -aoa "${SETUP_PATH}\ghidra.zip" -o"${TOOLS}" | Out-Null
            New-Item -ItemType Directory -Force -Path "${TOOLS}\ghidra" | Out-Null
            Move-Item ${TOOLS}\ghidra_1* "${TOOLS}\ghidra\"
            Copy-Item "${TOOLS}\ghidra\*\support\ghidra.ico" "${TOOLS}\ghidra" -Recurse -Force
        }
    }

    $TOOL_DEFINITIONS += @{
        Name = "Ghidra"
        Homepage = "https://ghidra-sre.org/"
        Vendor = "National Security Agency"
        License = "Apache-2.0"
        LicenseUrl = "https://github.com/NationalSecurityAgency/ghidra/blob/master/LICENSE"
        Category = "Reverse engineering"
        Shortcuts = @()
        InstallVerifyCommand = ""
        Verify = @(
            @{
                Type = "file"
                Name = "ghidraRun.bat"
                Expect = "Batch file"
            }
        )
        Notes = "Ghidra is a software reverse engineering (SRE) framework developed by NSA's Research Directorate."
        Tips = "Ghidra is a free and open-source software reverse engineering (SRE) framework developed by NSA's Research Directorate."
        Usage = "Ghidra is used for analyzing compiled code on a variety of platforms including Windows, macOS, and Linux."
        SampleCommands = @(
            "ghidraRun.bat"
        )
        SampleFiles = @(
            "N/A"
        )
        Dependencies = @("openjdk11")
        Tags = @()
    FileExtensions = @()
    PythonVersion = ""
}

    # Tools to compile and build - version 2019
    $status = Get-FileFromUri -uri "https://aka.ms/vs/16/release/vs_BuildTools.exe" -FilePath ".\downloads\vs_BuildTools.exe" -check "PE32"
}

# MSYS2
if (($all -and $profileMsys2Enabled) -or $MSYS2) {
    $status = Get-FileFromUri -uri "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" -FilePath "${SETUP_PATH}\msys2.exe" -CheckURL "No" -check "PE32"
    if ($status) {
        Copy-Item "${SETUP_PATH}\msys2.exe" "${TOOLS}\bin\msys2.exe"
    }
    # TOOL_DEFINITIONS entry for MSYS2 is added in msys2.ps1
}

#
# Packages used in Go sandbox
if (($all -and $profileGoEnabled) -or $Go) {
    # GoLang - available for installation via dfirws-install.ps1
    Write-SynchronizedLog "winget: Downloading GoLang."
    $status = Get-WinGet "GoLang.Go" "Go*.msi" "golang.msi" -check "Composite Document File V2 Document"
    $TOOL_DEFINITIONS += @{
        Name = "GoLang"
        Homepage = "https://go.dev/"
        Vendor = ""
        License = ""
        LicenseUrl = ""
        Category = "Programming"
        Shortcuts = @(
            @{
                Lnk      = "`${HOME}\Desktop\dfirws\Programming\Go\GoLang (runs dfirws-install -GoLang).lnk"
                Target   = "`${CLI_TOOL}"
                Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -GoLang"
                Icon     = ""
                WorkDir  = "`${HOME}\Desktop"
            }
        )
        InstallVerifyCommand = "dfirws-install.ps1 -GoLang"
        Verify = @(
            @{
                Type = "command"
                Name = "go.exe"
                Expect = "PE32"
            }
        )
        Notes = "Go programming language."
        Tips = ""
        Usage = ""
        SampleCommands = @()
        SampleFiles = @(
            "N/A"
        )
        Dependencies = @("openjdk11")
        Tags = @()
        FileExtensions = @()
        PythonVersion = ""
    }
}

#
# Packages used in Rust sandbox
if (($all -and $profileRustEnabled) -or $Rust) {
    # Rust - available for installation via dfirws-install.ps1
    Write-SynchronizedLog "winget: Downloading Rust."
    $status = Get-WinGet "Rustlang.Rust.GNU" "Rust*.msi" "rust.msi" -check "Composite Document File V2 Document"

    $TOOL_DEFINITIONS += @{
        Name = "Rust"
        Homepage = "https://rust-lang.org/"
        Vendor = ""
        License = ""
        LicenseUrl = ""
        Category = "Programming"
        Shortcuts = @(
            @{
                Lnk      = "`${HOME}\Desktop\dfirws\Programming\Rust\Rust (runs dfirws-install -Rust).lnk"
                Target   = "`${CLI_TOOL}"
                Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Rust"
                Icon     = ""
                WorkDir  = "`${HOME}\Desktop"
            }
        )
        InstallVerifyCommand = "dfirws-install.ps1 -Rust"
        Verify = @(
            @{
                Type = "command"
                Name = "rustc.exe"
                Expect = "PE32"
            }
        )
        Notes = "Rust programming language."
        Tips = ""
        Usage = ""
        SampleCommands = @()
        SampleFiles = @(
            "N/A"
        )
        Dependencies = @("openjdk11")
        Tags = @()
        FileExtensions = @()
        PythonVersion = ""
    }
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "basic"