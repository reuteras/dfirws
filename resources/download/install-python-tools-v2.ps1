# DFIRWS Python Tools Installer (v2 - YAML-based)
# Installs Python tools from python-tools.yaml using UV package manager
# Version: 2.0

param(
    [Parameter(HelpMessage = "Install all Python tools")]
    [Switch]$All,

    [Parameter(HelpMessage = "Install specific tool by name")]
    [string]$ToolName,

    [Parameter(HelpMessage = "Install only special install tools")]
    [Switch]$SpecialOnly,

    [Parameter(HelpMessage = "Install only standard tools")]
    [Switch]$StandardOnly,

    [Parameter(HelpMessage = "Dry run - show what would be done")]
    [Switch]$DryRun
)

# Import modules
. ".\resources\download\common.ps1"
. ".\resources\download\yaml-parser.ps1"

# Ensure powershell-yaml is installed
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "Installing powershell-yaml module..."
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}

$ROOT_PATH = "${PWD}"

Write-DateLog "Python Tools Installer v2 - Loading definitions from YAML" > ${ROOT_PATH}\log\python_tools.txt

# Load Python tools from YAML
$pythonTools = Import-PythonToolsDefinition

if (-not $pythonTools) {
    Write-DateLog "Failed to load Python tools definitions" >> ${ROOT_PATH}\log\python_tools.txt
    exit 1
}

Write-DateLog "Loaded $($pythonTools.Count) Python tools from YAML" >> ${ROOT_PATH}\log\python_tools.txt

# Filter tools based on parameters
$toolsToInstall = $pythonTools

if ($ToolName) {
    $toolsToInstall = $pythonTools | Where-Object { $_.name -eq $ToolName }
    if (-not $toolsToInstall) {
        Write-Error "Tool not found: $ToolName"
        exit 1
    }
} elseif ($SpecialOnly) {
    $toolsToInstall = $pythonTools | Where-Object { $_.install_type -eq "special" }
} elseif ($StandardOnly) {
    $toolsToInstall = $pythonTools | Where-Object { $_.install_type -eq "standard" }
}

if ($DryRun) {
    Write-Output "`n=== DRY RUN MODE ==="
    Write-Output "Would install the following Python tools:"
    foreach ($tool in $toolsToInstall) {
        Write-Output "  - $($tool.name) (type: $($tool.install_type))"
        if ($tool.package) {
            Write-Output "    Package: $($tool.package)"
        }
        if ($tool.with) {
            Write-Output "    Dependencies: $($tool.with)"
        }
    }
    Write-Output "===================`n"
    exit 0
}

function Install-PythonTool {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Tool
    )

    $toolName = $Tool.name
    $package = $Tool.package

    Write-DateLog "Installing Python tool: $toolName" >> ${ROOT_PATH}\log\python_tools.txt

    try {
        # Build UV install command arguments
        $uvArgs = @("tool", "install")

        # Add dependencies if specified
        if ($Tool.with) {
            $dependencies = $Tool.with.Split(',') | ForEach-Object { $_.Trim() }
            foreach ($dep in $dependencies) {
                $uvArgs += "--with"
                $uvArgs += $dep
            }
        }

        # Add package
        $uvArgs += $package

        # Execute UV command
        Write-DateLog "Executing: uv $($uvArgs -join ' ')" >> ${ROOT_PATH}\log\python_tools.txt

        $result = & uv $uvArgs 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-DateLog "Successfully installed: $toolName" >> ${ROOT_PATH}\log\python_tools.txt
            return $true
        } else {
            Write-DateLog "Failed to install $toolName : $result" >> ${ROOT_<em>PATH}\log\python_tools.txt
            return $false
        }
    } catch {
        Write-DateLog "Error installing $toolName : $</em>" >> ${ROOT_PATH}\log\python_tools.txt
        return $false
    }
}

# Statistics
$stats = @{
    total = $toolsToInstall.Count
    success = 0
    failed = 0
}

# Install tools
Write-DateLog "Starting installation of $($toolsToInstall.Count) Python tools" >> ${ROOT_PATH}\log\python_tools.txt

foreach ($tool in $toolsToInstall) {
    # Skip if not a package install (direct downloads, utility scripts handled separately)
    if (-not $tool.package) {
        Write-DateLog "Skipping non-package tool: $($tool.name)" >> ${ROOT_PATH}\log\python_tools.txt
        continue
    }

    $result = Install-PythonTool -Tool $tool

    if ($result) {
        $stats.success++
    } else {
        $stats.failed++
    }
}

# Summary
Write-DateLog "`n========================================" >> ${ROOT_PATH}\log\python_tools.txt
Write-DateLog "Python Tools Installation Summary" >> ${ROOT_PATH}\log\python_tools.txt
Write-DateLog "========================================" >> ${ROOT_PATH}\log\python_tools.txt
Write-DateLog "Total tools: $($stats.total)" >> ${ROOT_PATH}\log\python_tools.txt
Write-DateLog "Successfully installed: $($stats.success)" >> ${ROOT_PATH}\log\python_tools.txt
Write-DateLog "Failed: $($stats.failed)" >> ${ROOT_PATH}\log\python_tools.txt
Write-DateLog "========================================`n" >> ${ROOT_PATH}\log\python_tools.txt

Write-Output "`n========================================`n"
Write-Output "Python Tools Installation Complete"
Write-Output "Success: $($stats.success) / $($stats.total)"
if ($stats.failed -gt 0) {
    Write-Output "Failed: $($stats.failed)"
}
Write-Output "========================================`n"
