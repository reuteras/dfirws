. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# Autopsy - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Autopsy."
$status = Get-WinGet "SleuthKit.Autopsy" "Autopsy*.msi" "autopsy.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "Autopsy"
    Category = "Forensics"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Forensics\Autopsy (runs dfirws-install -Autopsy).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Autopsy"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Autopsy"
    Verify = @()
    FileExtensions = @(".dd", ".raw", ".E01", ".img", ".vmdk")
    Tags = @("disk-forensics", "forensics", "gui", "artifact-extraction")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Burp suite - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Burp Suite."
$status = Get-WinGet "PortSwigger.BurpSuite.${BURP_SUITE_EDITION}" "Burp*.exe" "burp.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Burp Suite"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Burp Suite (runs dfirws-install -BurpSuite).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -BurpSuite"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -BurpSuite"
    Verify = @()
    FileExtensions = @()
    Tags = @("web", "security-testing", "proxy")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Chrome - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Chrome."
$status = Get-WinGet "Google.Chrome" "Google*.msi" "chrome.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "Chrome"
    Category = "Utilities\Browsers"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Browsers\Chrome (runs dfirws-install -Chrome).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Chrome"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Chrome"
    Verify = @(
        @{
            Type = "command"
            Name = "chrome"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".html", ".htm", ".js", ".css")
    Tags = @("browser", "web")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# DotNet 6 Desktop runtime - installed during startup
Write-SynchronizedLog "winget: Downloading DotNet 6 Desktop runtime."
$status = Get-WinGet "Microsoft.DotNet.DesktopRuntime.6" "Microsoft*.exe" "dotnet6desktop.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "DotNet 6 Desktop Runtime"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("dotnet", "runtime")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# DotNet 8 Desktop runtime - installed during startup
Write-SynchronizedLog "winget: Downloading DotNet 8 Desktop runtime."
$status = Get-WinGet "Microsoft.DotNet.DesktopRuntime.8" "Microsoft*.exe" "dotnet8desktop.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "DotNet 8 Desktop Runtime"
    Category = "Programming\dotNET"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("dotnet", "runtime")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# IrfanView - installed during startup
Write-SynchronizedLog "winget: Downloading IrfanView."
$status = Get-WinGet "IrfanSkiljan.IrfanView" "IrfanView*.exe" "irfanview.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "IrfanView"
    Category = "Utilities\Media"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\IrfanView\i_view64.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".ico", ".webp")
    Tags = @("image-viewer", "multimedia")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Obsidian - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Obsidian."
$status = Get-WinGet "Obsidian.Obsidian" "Obsidian*.exe" "obsidian.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Obsidian"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Obsidian (runs dfirws-install -Obsidian).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Obsidian"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Obsidian"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Users\WDAGUtilityAccount\AppData\Local\Programs\Obsidian\Obsidian.exe"
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
}

# oh-my-posh - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading oh-my-posh."
$status = Get-WinGet "JanDeDobbeleer.OhMyPosh" "Oh*.msi" "oh-my-posh.msi" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "oh-my-posh"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Oh-My-Posh (runs dfirws-install -OhMyPosh).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -OhMyPosh"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -OhMyPosh"
    Verify = @()
    FileExtensions = @()
    Tags = @("terminal", "shell", "theming")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# PowerShell 7 - installed during startup
Write-SynchronizedLog "winget: Downloading PowerShell 7."
$status = Get-WinGet "Microsoft.PowerShell" "PowerShell*.msi" "powershell.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "PowerShell 7"
    Category = "Programming\PowerShell"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ps1", ".psm1", ".psd1")
    Tags = @("scripting", "shell", "automation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Putty - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Putty."
$status = Get-WinGet "PuTTY.PuTTY" "PuTTY*.msi" "putty.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "PuTTY"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\PuTTY (runs dfirws-install -PuTTY).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -PuTTY"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -PuTTY"
    Verify = @(
        @{
            Type = "command"
            Name = "putty"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("ssh", "network", "terminal")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Qemu - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Qemu."
$status = Get-WinGet "SoftwareFreedomConservancy.QEMU" "QEMU*.exe" "qemu.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "QEMU"
    Category = "Files and apps"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Qemu"
    Verify = @(
        @{
            Type = "command"
            Name = "qemu-img"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".qcow2", ".vmdk", ".vdi", ".img", ".iso")
    Tags = @("virtualization", "emulation")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Ruby - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Ruby."
$status = Get-WinGet "RubyInstallerTeam.Ruby.3.4" "Ruby*.exe" "ruby.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Ruby"
    Category = "Programming\Ruby"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Ruby"
    Verify = @(
        @{
            Type = "command"
            Name = "ruby"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".rb")
    Tags = @("scripting", "ruby")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# VideoLAN VLC - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading VLC."
$status = Get-WinGet "VideoLAN.VLC" "VLC*.exe" "vlc_installer.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "VLC"
    Category = "Utilities\Media"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Media\VLC (runs dfirws-install -VLC).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -VLC"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -VLC"
    Verify = @(
        @{
            Type = "command"
            Name = "vlc"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".mp4", ".avi", ".mkv", ".mov", ".mp3", ".wav", ".flac")
    Tags = @("multimedia", "video", "audio")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# VirusTotal CLI
Write-SynchronizedLog "winget: Downloading VirusTotal CLI."
$status = Get-WinGet "VirusTotal.vt-cli" "vt-cli*.zip" "vt.zip" -check "Zip archive data"
if ($status) {
    & "${env:ProgramFiles}\7-Zip\7z.exe" x -aoa ".\downloads\vt.zip" -o"${TOOLS}\bin" | Out-Null
}

$TOOL_DEFINITIONS += @{
    Name = "VirusTotal CLI"
    Category = "Signatures and information\Online tools"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Signatures and information\Online tools\vt (A command-line tool for interacting with VirusTotal).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command vt help"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "vt"
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
}

# WinMerge - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading WinMerge."
$status = Get-WinGet "WinMerge.WinMerge" "WinMerge*.exe" "winmerge.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "WinMerge"
    Category = "Files and apps"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\WinMerge (runs dfirws-install -WinMerge).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -WinMerge"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -WinMerge"
    Verify = @(
        @{
            Type = "command"
            Name = "WinMergeU"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("diff", "file-comparison")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# OpenVPN - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading OpenVPN."
$status = Get-WinGet "OpenVPNTechnologies.OpenVPNConnect" "OpenVPN*.msi" "openvpn.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "OpenVPN"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @(".ovpn")
    Tags = @("vpn", "network")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Google Earth Pro - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Google Earth Pro."
$status = Get-WinGet "Google.EarthPro" "Google*.exe" "googleearth.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Google Earth Pro"
    Category = "Utilities"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Google Earth (runs dfirws-install -GoogleEarth).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -GoogleEarth"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -GoogleEarth"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\Google\Google Earth Pro\client\googleearth.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".kml", ".kmz")
    Tags = @("geolocation", "osint", "visualization")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Passmark OSFMount - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading OSFMount."
$status = Get-WinGet "PassmarkSoftware.OSFMount" "OSFMount*.exe" "osfmount.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "OSFMount"
    Category = "Files and apps\Disk"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\Disk\OSFMount (runs dfirws-install -OSFMount).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -OSFMount"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\osfmount.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".dd", ".raw", ".E01", ".img", ".vmdk", ".iso")
    Tags = @("disk-forensics", "mounting", "filesystem")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# WireGuard.WireGuard - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading WireGuard."
$status = Get-WinGet "WireGuard.WireGuard" "wireguard*.msi" "wireguard.msi" -check "Composite Document File V2 Document"

$TOOL_DEFINITIONS += @{
    Name = "WireGuard"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @("vpn", "network")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Wireshark - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Wireshark."
$status = Get-WinGet "WiresharkFoundation.Wireshark" "Wireshark*.exe" "wireshark.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Wireshark"
    Category = "Network"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Network\Wireshark (runs dfirws-install -Wireshark).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Wireshark"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Wireshark"
    Verify = @(
        @{
            Type = "command"
            Name = "Wireshark"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pcap", ".pcapng", ".cap")
    Tags = @("network-analysis", "pcap", "protocol-analysis")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# tailscale - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Tailscale."
$status = Get-WinGet "Tailscale.Tailscale" "Tailscale*.exe" "tailscale.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Tailscale"
    Category = "Network"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "C:\downloads\tailscale.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @()
    Tags = @("vpn", "network")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Firefox - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Firefox."
$status = Get-WinGet "Mozilla.Firefox" "Firefox*.exe" "firefox.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Firefox"
    Category = "Utilities\Browsers"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Utilities\Browsers\Firefox (runs dfirws-install -Firefox).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Firefox"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Firefox"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\Mozilla Firefox\firefox.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".html", ".htm", ".js", ".css")
    Tags = @("browser", "web")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Foxit PDF Reader - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Foxit PDF Reader."
$status = Get-WinGet "Foxit.FoxitReader" "Foxit*.exe" "foxitreader.exe" -check "PE32"

$TOOL_DEFINITIONS += @{
    Name = "Foxit PDF Reader"
    Category = "Files and apps\PDF"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Files and apps\PDF\Foxit Reader for pdf files (runs dfirws-install -FoxitReader).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -FoxitReader"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -FoxitReader"
    Verify = @(
        @{
            Type = "command"
            Name = "C:\Program Files\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".pdf")
    Tags = @("pdf", "viewer")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

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
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Windbg - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Windbg."
$status = Get-WinGet "Microsoft.WinDbg" "WinDbg*.msi" "windbg.msi" -check "Zip archive data"

$TOOL_DEFINITIONS += @{
    Name = "WinDbg"
    Category = "Reverse Engineering"
    Shortcuts = @()
    InstallVerifyCommand = "dfirws-install.ps1 -Windbg"
    Verify = @()
    FileExtensions = @(".dmp", ".exe", ".dll", ".sys")
    Tags = @("debugging", "memory-forensics", "kernel")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

# Neovim - available for installation via dfirws-install.ps1
Write-SynchronizedLog "winget: Downloading Neovim."
$status = Get-WinGet "Neovim.Neovim" "nvim*.msi" "nvim.msi"
if ($status) {
    Copy-Item -Path ".\downloads\nvim.msi\Neovim*.msi" -Destination ".\downloads\neovim.msi" -Force
    Remove-Item -Path ".\downloads\nvim.msi" -Force -Recurse
}
Get-FileFromUri "https://github.com/vim/vim/raw/refs/heads/master/runtime/spell/en.utf-8.spl" -FilePath ".\downloads\en.utf-8.spl"
Get-FileFromUri "https://github.com/vim/vim/raw/refs/heads/master/runtime/spell/en.utf-8.sug" -FilePath ".\downloads\en.utf-8.sug"

$TOOL_DEFINITIONS += @{
    Name = "Neovim"
    Category = "Editors"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\Editors\Neovim (runs dfirws-install -Neovim).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command dfirws-install.ps1 -Neovim"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = "dfirws-install.ps1 -Neovim"
    Verify = @(
        @{
            Type = "command"
            Name = "nvim"
            Expect = "PE32"
        }
    )
    FileExtensions = @(".txt", ".md", ".log", ".ps1", ".py", ".rb", ".js")
    Tags = @("text-editor", "code-editor", "terminal")
    Notes = ""
    Tips = ""
    Usage = ""
    SampleCommands = @()
    SampleFiles = @()
}

Write-SynchronizedLog "winget: Download complete."

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "winget"