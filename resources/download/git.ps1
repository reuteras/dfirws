YNOPSIS
    Downloads and updates Git repositories for DFIRWS.

.DESCRIPTION
    This script clones or updates Git repositories containing various tools and 
    resources useful for digital forensics and incident response. It maintains
    a local copy of each repository in the mount/git directory.
    
    The script also handles special-case patching of certain repositories like
    PatchaPalooza to ensure compatibility with Windows environments.

.NOTES
    File Name      : git.ps1
    Author         : DFIRWS Project
    Prerequisite   : PowerShell 5.1 or later, Git
    Version        : 2.0

.LINK
    https://github.com/reuteras/dfirws
#>

[CmdletBinding()]
param()

# Source common functions
. ".\resources\download\common.ps1"

#region Initialization

# Set error action preference
$ErrorActionPreference = "Continue"

# Check if git is available
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-DateLog "ERROR: Git is not installed or not in PATH. Please install Git."
    Exit 1
}

# Define git directory
$gitDir = "mount\git"

# Create git directory if it doesn't exist
if (!(Test-Path -Path $gitDir)) {
    Write-DateLog "Creating git directory: $gitDir"
    New-Item -ItemType Directory -Force -Path $gitDir | Out-Null
}

# Change to git directory
Set-Location $gitDir

# Remove PatchaPalooza if it exists since we do custom patching
if (Test-Path -Path ".\PatchaPalooza") {
    Write-DateLog "Removing existing PatchaPalooza directory for clean clone"
    Remove-Item -Recurse -Force ".\PatchaPalooza" 2>&1 | Out-Null
}

# Initialize counters
$totalRepositories = 0
$successfulClones = 0
$successfulUpdates = 0
$failedRepositories = 0

#endregion Initialization

#region Repository Definition

# Define repository URLs
$repoUrls = @(
    "https://github.com/ahmedkhlief/APT-Hunter.git",
    "https://github.com/AndrewRathbun/DFIRArtifactMuseum.git",
    "https://github.com/ANSSI-FR/bmc-tools.git",
    "https://github.com/Bert-JanP/Incident-Response-Powershell.git",
    "https://github.com/BSI-Bund/RdpCacheStitcher.git",
    "https://github.com/crypto2011/IDR.git",
    "https://github.com/cyberark/White-Phoenix.git",
    "https://github.com/ExeinfoASL/ASL.git",
    "https://github.com/fr0gger/jupyter-collection.git",
    "https://github.com/gehaxelt/Python-dsstore.git",
    "https://github.com/import-pandas-as-numpy/chainsaw-rules",
    "https://github.com/JavierYuste/radare2-deep-graph.git",
    "https://github.com/jeFF0Falltrades/rat_king_parser.git",
    "https://github.com/jklepsercyber/defender-detectionhistory-parser.git",
    "https://github.com/joeavanzato/Trawler.git",
    "https://github.com/JPCERTCC/ToolAnalysisResultSheet.git",
    "https://github.com/KasperskyLab/iShutdown.git",
    "https://github.com/keraattin/EmailAnalyzer.git",
    "https://github.com/keydet89/Events-Ripper.git",
    "https://github.com/keydet89/RegRipper4.0",
    "https://github.com/khyrenz/parseusbs.git",
    "https://github.com/last-byte/PersistenceSniper.git",
    "https://github.com/last-byte/PersistenceSniper.wiki.git",
    "https://github.com/LibreOffice/dictionaries.git",
    "https://github.com/Malandrone/PowerDecode.git",
    "https://github.com/mandiant/flare-floss.git",
    "https://github.com/mandiant/gootloader.git",
    "https://github.com/mandiant/GoReSym.git",
    "https://github.com/mari-mari/CapaExplorer.git",
    "https://github.com/MarkBaggett/ese-analyst.git",
    "https://github.com/mattifestation/CimSweep.git",
    "https://github.com/montysecurity/malware-bazaar-advanced-search.git",
    "https://github.com/Neo23x0/god-mode-rules.git",
    "https://github.com/Neo23x0/signature-base.git",
    "https://github.com/netspooky/scare.git",
    "https://github.com/ninewayhandshake/capa-explorer.git",
    "https://github.com/pan-unit42/dotnetfile.git",
    "https://github.com/rabbitstack/fibratus.git",
    "https://github.com/reuteras/dfirws.wiki.git",
    "https://github.com/reuteras/dfirws-sample-files.git",
    "https://github.com/reuteras/MSRC.git",
    "https://github.com/rizinorg/cutter-jupyter.git",
    "https://github.com/Seabreg/Regshot.git",
    "https://github.com/SigmaHQ/legacy-sigmatools.git",
    "https://github.com/SigmaHQ/sigma.git",
    "https://github.com/StrangerealIntel/Shadow-Pulse.git",
    "https://github.com/swisscom/PowerSponse.git",
    "https://github.com/techchipnet/HiddenWave.git",
    "https://github.com/thewhiteninja/deobshell.git",
    "https://github.com/TrimarcJake/BlueTuxedo.git",
    "https://github.com/ufrisk/LeechCore.wiki.git",
    "https://github.com/ufrisk/MemProcFS.wiki.git",
    "https://github.com/volexity/one-extract.git",
    "https://github.com/volexity/threat-intel.git",
    "https://github.com/wagga40/Zircolite.git",
    "https://github.com/reuteras/PatchaPalooza.git",
    "https://github.com/The-DFIR-Report/Sigma-Rules.git",
    "https://github.com/xaitax/TotalRecall.git",
    "https://github.com/Yamato-Security/hayabusa-rules.git",
    "https://github.com/YosfanEilay/AuthLogParser.git",
    "https://github.com/yossizap/cutterref.git"
)

$totalRepositories = $repoUrls.Count

#endregion Repository Definition

#region Clone/Update Repositories

Write-DateLog "Starting download and update of $totalRepositories Git repositories"

foreach ($repoUrl in $repoUrls) {
    try {
        # Extract repository name from URL
        $repoName = $repoUrl -replace "^.*/" -replace "\.git$"
        
        if (Test-Path -Path "$repoName") {
            # Repository already exists, update it
            Write-DateLog "Updating repository: $repoName"
            Set-Location "$repoName"
            
            # Perform git pull and capture output
            $result = git pull 2>&1
            Write-SynchronizedLog $result
            
            # Check if update was successful
            if ($LASTEXITCODE -eq 0) {
                $successfulUpdates++
                Write-DateLog "Successfully updated $repoName"
            }
            else {
                $failedRepositories++
                Write-DateLog "Failed to update $repoName"
            }
            
            # Return to git directory
            Set-Location ".."
        }
        else {
            # Repository doesn't exist, clone it
            Write-DateLog "Cloning repository: $repoName"
            
            # Perform git clone and capture output
            $result = git clone "$repoUrl" 2>&1
            Write-SynchronizedLog $result
            
            # Check if clone was successful
            if ($LASTEXITCODE -eq 0) {
                $successfulClones++
                Write-DateLog "Successfully cloned $repoName"
            }
            else {
                $failedRepositories++
                Write-DateLog "Failed to clone $repoName"
            }
        }
    }
    catch {
        $failedRepositories++
        Write-DateLog "ERROR: Exception while processing repository $repoUrl : $_"
    }
}

#endregion Clone/Update Repositories

#region Special Repository Handling

# Patch PatchaPalooza for Windows compatibility
if (Test-Path -Path ".\PatchaPalooza") {
    try {
        Write-DateLog "Patching PatchaPalooza for Windows compatibility"
        Set-Location "PatchaPalooza"
        
        # Read the original file content
        $content = Get-Content ".\PatchaPalooza.py" -Raw
        
        # Add the colorama import and initialization
        $patchedContent = $content -replace "import termcolor", "import termcolor`nimport colorama`ncolorama.init()"
        
        # Write to a temporary file first
        $patchedContent | Set-Content ".\PatchaPalooza2.py"
        
        # Copy back to the original file and remove the temporary file
        Copy-Item ".\PatchaPalooza2.py" ".\PatchaPalooza.py" -Force
        Remove-Item ".\PatchaPalooza2.py"
        
        Write-DateLog "Successfully patched PatchaPalooza"
        
        # Return to git directory
        Set-Location ".."
    }
    catch {
        Write-DateLog "ERROR: Failed to patch PatchaPalooza: $_"
    }
}

# Extract exeinfope.zip from ASL repository
if (Test-Path -Path ".\ASL\exeinfope.zip") {
    try {
        Write-DateLog "Extracting exeinfope.zip from ASL repository"
        
        # Check if 7-Zip is available
        $sevenZipPath = "$env:ProgramFiles\7-Zip\7z.exe"
        if (!(Test-Path -Path $sevenZipPath)) {
            throw "7-Zip is not installed or not found at $sevenZipPath"
        }
        
        # Extract the zip file
        & "$sevenZipPath" x -aoa "ASL\exeinfope.zip" -o"..\Tools" | Out-Null
        
        Write-DateLog "Successfully extracted exeinfope.zip"
    }
    catch {
        Write-DateLog "ERROR: Failed to extract exeinfope.zip: $_"
    }
}

#endregion Special Repository Handling

# Return to original directory
Set-Location "..\.."

# Report summary
Write-DateLog "Git repositories processing summary:"
Write-DateLog "- Total repositories: $totalRepositories"
Write-DateLog "- Successfully cloned: $successfulClones"
Write-DateLog "- Successfully updated: $successfulUpdates"
Write-DateLog "- Failed repositories: $failedRepositories"
