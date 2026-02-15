# Profile definitions for DFIRWS distribution profiles.
# Used by downloadFiles.ps1 to control which tools are downloaded.
#
# Each profile defines:
#   Scripts      - Which build sandbox scripts to run (node, rust, go, msys2)
#   ExcludeTools - Large tools to skip in shared download scripts (winget.ps1, http.ps1)

$DFIRWS_PROFILES = @{
    "Basic" = @{
        Scripts = @{
            "node"   = $true
            "rust"   = $false
            "go"     = $false
            "msys2"  = $false
        }
        ExcludeTools = @(
            "Autopsy",
            "QEMU",
            "Burp Suite",
            "Google Earth Pro",
            "Binary Ninja",
            "Neo4j",
            "hashcat",
            "Volatility Workbench 3",
            "Volatility Workbench 2.1",
            "LibreOffice",
            "Elastic Stack (ELK + Beats)"
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
    }
}
