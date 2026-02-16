# Profile definitions for DFIRWS distribution profiles.
# Used by downloadFiles.ps1 to control which tools are downloaded.
#
# Each profile defines:
#   Scripts      - Which build sandbox scripts to run (node, rust, go, msys2)
#   ExcludeTools - Large or optional tools to skip in download scripts
#   ExcludeGitRepos - Git repositories to skip in git.ps1

$DFIRWS_PROFILES = @{
    "Basic" = @{
        Scripts = @{
            "node"   = $true
            "rust"   = $false
            "go"     = $false
            "msys2"  = $false
        }
        ExcludeTools = @(
            # basic.ps1
            "Ghidra",
            "ClamAV",
            # winget.ps1
            "Autopsy",
            "Burp Suite",
            "QEMU",
            "Google Earth Pro",
            "Obsidian",
            "OpenVPN",
            "Tailscale",
            "Chrome",
            "Firefox",
            "VLC",
            "PuTTY",
            "WireGuard",
            "Foxit PDF Reader",
            "Ruby",
            "VirusTotal CLI",
            # http.ps1
            "Binary Ninja",
            "Neo4j",
            "hashcat",
            "Volatility Workbench 3",
            "Volatility Workbench 2.1",
            "LibreOffice",
            "Elastic Stack (ELK + Beats)",
            "Tor Browser",
            "VeraCrypt",
            "capa Explorer Web",
            # release.ps1
            "Audacity",
            "Zui",
            "ffmpeg",
            "cmder",
            "DBeaver",
            "godap",
            "Recaf",
            "4n4lDetector",
            "Dokany",
            "adalanche",
            "Cutter",
            "Fibratus",
            "h2database",
            "Strawberry Perl",
            "zaproxy",
            "YAMAGoya",
            "Velociraptor",
            "fqlite",
            # release.ps1 - Obsidian plugins (excluded with Obsidian)
            "obsidian-mitre-attack",
            "obsidian-dataview",
            "obsidian-kanban",
            "quickadd",
            "obsidian-calendar-plugin",
            "Templater",
            "obsidian-tasks",
            "obsidian-excalidraw-plugin",
            "admonitions",
            "obsidian-timeline"
        )
        ExcludeGitRepos = @(
            "DFIRArtifactMuseum",
            "dictionaries",
            "dfirws-sample-files",
            "IDR",
            "MSRC",
            "fibratus",
            "MemProcFS.wiki",
            "LeechCore.wiki",
            "Trawler"
        )
    }
    "Full" = @{
        Scripts = @{
            "node"   = $true
            "rust"   = $true
            "go"     = $true
            "msys2"  = $true
        }
        ExcludeTools = @()
        ExcludeGitRepos = @()
    }
}
