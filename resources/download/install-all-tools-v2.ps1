# DFIRWS Unified Tool Installer (v2 - YAML-based)
# Master installer for all tool categories
# Version: 2.0

param(
    [Parameter(HelpMessage = "Install all tools from all categories")]
    [Switch]$All,

    [Parameter(HelpMessage = "Install only standard GitHub release tools")]
    [Switch]$StandardTools,

    [Parameter(HelpMessage = "Install only Python tools")]
    [Switch]$PythonTools,

    [Parameter(HelpMessage = "Install only Git repositories")]
    [Switch]$GitRepos,

    [Parameter(HelpMessage = "Install only Node.js tools")]
    [Switch]$NodeJsTools,

    [Parameter(HelpMessage = "Install only Didier Stevens tools")]
    [Switch]$DidierStevensTools,

    [Parameter(HelpMessage = "Install by category (forensics, malware-analysis, etc.)")]
    [string]$Category,

    [Parameter(HelpMessage = "Install by priority (critical, high, medium, low)")]
    [string]$Priority,

    [Parameter(HelpMessage = "Enable parallel downloads for standard tools")]
    [Switch]$Parallel,

    [Parameter(HelpMessage = "Number of parallel jobs (default: 5)")]
    [int]$ThrottleLimit = 5,

    [Parameter(HelpMessage = "Dry run - show what would be done")]
    [Switch]$DryRun,

    [Parameter(HelpMessage = "Show tool counts by category")]
    [Switch]$ShowCounts
)

# Import common modules
. ".\resources\download\common.ps1"
. ".\resources\download\yaml-parser.ps1"

$ROOT_PATH = "${PWD}"

# Create log directory if it doesn't exist
if (-not (Test-Path "${ROOT_PATH}\log")) {
    New-Item -ItemType Directory -Path "${ROOT_PATH}\log" -Force | Out-Null
}

Write-DateLog "========================================" > ${ROOT_PATH}\log\install_all_v2.txt
Write-DateLog "DFIRWS v2 Unified Tool Installer" >> ${ROOT_PATH}\log\install_all_v2.txt
Write-DateLog "========================================" >> ${ROOT_PATH}\log\install_all_v2.txt
Write-DateLog "Started: $(Get-Date)" >> ${ROOT_PATH}\log\install_all_v2.txt

# Show tool counts if requested
if ($ShowCounts) {
    Write-Output "`n========================================`n"
    Write-Output "DFIRWS v2 Tool Counts"
    Write-Output "========================================`n"

    # Count standard tools
    $allToolFiles = Get-ChildItem -Path ".\resources\tools" -Filter "*.yaml"
    $excludeFiles = @("python-tools.yaml", "git-repositories.yaml", "nodejs-tools.yaml", "didier-stevens-tools.yaml")
    $standardToolFiles = $allToolFiles | Where-Object { $excludeFiles -notcontains $_.Name }
    $standardToolCount = 0
    foreach ($file in $standardToolFiles) {
        $count = (Get-Content $file.FullName | Select-String -Pattern "^\s+-\s+name:").Count
        $standardToolCount += $count
        Write-Output "  $($file.BaseName): $count tools"
    }

    Write-Output "`nStandard GitHub Release Tools: $standardToolCount"

    # Count specialized tools
    $pythonToolsList = Import-PythonToolsDefinition
    if (-not $pythonToolsList) { $pythonToolsList = @() }
    Write-Output "Python Tools: $($pythonToolsList.Count)"

    $gitReposList = Import-GitRepositoriesDefinition
    if (-not $gitReposList) { $gitReposList = @() }
    Write-Output "Git Repositories: $($gitReposList.Count)"

    $nodejsToolsList = Import-NodeJsToolsDefinition
    if (-not $nodejsToolsList) { $nodejsToolsList = @() }
    Write-Output "Node.js Tools: $($nodejsToolsList.Count)"

    $didierToolsList = Import-DidierStevensToolsDefinition
    if (-not $didierToolsList) { $didierToolsList = @() }
    Write-Output "Didier Stevens Tools: $($didierToolsList.Count)"

    $totalTools = $standardToolCount + $pythonToolsList.Count + $gitReposList.Count + $nodejsToolsList.Count + $didierToolsList.Count
    Write-Output "`nTotal Tools: $totalTools"
    Write-Output "========================================`n"

    exit 0
}

# Determine what to install
$installStandard = $false
$installPython = $false
$installGit = $false
$installNodeJs = $false
$installDidier = $false

if ($All) {
    $installStandard = $true
    $installPython = $true
    $installGit = $true
    $installNodeJs = $true
    $installDidier = $true
} elseif ($StandardTools) {
    $installStandard = $true
} elseif ($PythonTools) {
    $installPython = $true
} elseif ($GitRepos) {
    $installGit = $true
} elseif ($NodeJsTools) {
    $installNodeJs = $true
} elseif ($DidierStevensTools) {
    $installDidier = $true
} else {
    # Default: install all
    $installStandard = $true
    $installPython = $true
    $installGit = $true
    $installNodeJs = $true
    $installDidier = $true
}

# Track overall statistics
$overallStats = @{
    standard = @{ success = 0; failed = 0; total = 0 }
    python = @{ success = 0; failed = 0; total = 0 }
    git = @{ success = 0; failed = 0; total = 0 }
    nodejs = @{ success = 0; failed = 0; total = 0 }
    didier = @{ success = 0; failed = 0; total = 0 }
}

$startTime = Get-Date

#region Standard GitHub Release Tools

if ($installStandard) {
    Write-Output "`n========================================`n"
    Write-Output "Installing Standard GitHub Release Tools"
    Write-Output "========================================`n"

    Write-DateLog "Starting Standard GitHub Release Tools installation" >> ${ROOT_PATH}\log\install_all_v2.txt

    $params = @{}

    if ($Category) {
        $params.Category = $Category
    }

    if ($Priority) {
        $params.Priority = $Priority
    }

    if ($Parallel) {
        $params.Parallel = $true
        $params.ThrottleLimit = $ThrottleLimit
    }

    if ($DryRun) {
        $params.DryRun = $true
    }

    # Call the existing install-tools.ps1
    & ".\resources\download\install-tools.ps1" @params

    # Log completion
    Write-DateLog "Completed Standard GitHub Release Tools installation" >> ${ROOT_PATH}\log\install_all_v2.txt
}

#endregion

#region Python Tools

if ($installPython) {
    Write-Output "`n========================================`n"
    Write-Output "Installing Python Tools"
    Write-Output "========================================`n"

    Write-DateLog "Starting Python Tools installation" >> ${ROOT_PATH}\log\install_all_v2.txt

    $params = @{ All = $true }

    if ($DryRun) {
        $params.DryRun = $true
    }

    & ".\resources\download\install-python-tools-v2.ps1" @params

    Write-DateLog "Completed Python Tools installation" >> ${ROOT_PATH}\log\install_all_v2.txt
}

#endregion

#region Git Repositories

if ($installGit) {
    Write-Output "`n========================================`n"
    Write-Output "Cloning Git Repositories"
    Write-Output "========================================`n"

    Write-DateLog "Starting Git Repositories installation" >> ${ROOT_PATH}\log\install_all_v2.txt

    $params = @{ All = $true; Update = $true }

    if ($DryRun) {
        $params.DryRun = $true
    }

    & ".\resources\download\install-git-repos-v2.ps1" @params

    Write-DateLog "Completed Git Repositories installation" >> ${ROOT_PATH}\log\install_all_v2.txt
}

#endregion

#region Node.js Tools

if ($installNodeJs) {
    Write-Output "`n========================================`n"
    Write-Output "Installing Node.js Tools"
    Write-Output "========================================`n"

    Write-DateLog "Starting Node.js Tools installation" >> ${ROOT_PATH}\log\install_all_v2.txt

    $params = @{ All = $true }

    if ($DryRun) {
        $params.DryRun = $true
    }

    & ".\resources\download\install-nodejs-tools-v2.ps1" @params

    Write-DateLog "Completed Node.js Tools installation" >> ${ROOT_PATH}\log\install_all_v2.txt
}

#endregion

#region Didier Stevens Tools

if ($installDidier) {
    Write-Output "`n========================================`n"
    Write-Output "Installing Didier Stevens Tools"
    Write-Output "========================================`n"

    Write-DateLog "Starting Didier Stevens Tools installation" >> ${ROOT_PATH}\log\install_all_v2.txt

    $params = @{ All = $true }

    if ($DryRun) {
        $params.DryRun = $true
    }

    & ".\resources\download\install-didier-stevens-v2.ps1" @params

    Write-DateLog "Completed Didier Stevens Tools installation" >> ${ROOT_PATH}\log\install_all_v2.txt
}

#endregion

# Calculate elapsed time
$endTime = Get-Date
$elapsed = $endTime - $startTime

# Final Summary
Write-Output "`n========================================`n"
Write-Output "DFIRWS v2 Installation Complete"
Write-Output "========================================`n"
Write-Output "Elapsed Time: $($elapsed.ToString('hh\:mm\:ss'))"
Write-Output "`nCheck individual log files for details:"
Write-Output "  .\log\install_all_v2.txt"
Write-Output "  .\log\python_tools.txt"
Write-Output "  .\log\git_repos.txt"
Write-Output "  .\log\nodejs_tools.txt"
Write-Output "  .\log\didier_stevens.txt"
Write-Output "========================================`n"

Write-DateLog "========================================" >> ${ROOT_PATH}\log\install_all_v2.txt
Write-DateLog "Installation Complete" >> ${ROOT_PATH}\log\install_all_v2.txt
Write-DateLog "Elapsed Time: $($elapsed.ToString('hh\:mm\:ss'))" >> ${ROOT_PATH}\log\install_all_v2.txt
Write-DateLog "Finished: $(Get-Date)" >> ${ROOT_PATH}\log\install_all_v2.txt
Write-DateLog "========================================" >> ${ROOT_PATH}\log\install_all_v2.txt
