# DFIRWS Node.js Tools Installer (v2 - YAML-based)
# Installs Node.js packages from nodejs-tools.yaml using npm
# Version: 2.0

param(
    [Parameter(HelpMessage = "Install all Node.js tools")]
    [Switch]$All,

    [Parameter(HelpMessage = "Install specific tool by name")]
    [string]$ToolName,

    [Parameter(HelpMessage = "Dry run - show what would be done")]
    [Switch]$DryRun
)

# Import modules
. ".\resources\download\common.ps1"
. ".\resources\download\yaml-parser.ps1"

$ROOT_PATH = "${PWD}"

Write-DateLog "Node.js Tools Installer v2 - Loading definitions from YAML" > ${ROOT_PATH}\log\nodejs_tools.txt

# Load Node.js tools from YAML
$nodejsTools = Import-NodeJsToolsDefinition

if (-not $nodejsTools) {
    Write-DateLog "Failed to load Node.js tools definitions" >> ${ROOT_PATH}\log\nodejs_tools.txt
    exit 1
}

Write-DateLog "Loaded $($nodejsTools.Count) Node.js tools from YAML" >> ${ROOT_PATH}\log\nodejs_tools.txt

# Filter tools based on parameters
$toolsToInstall = $nodejsTools

if ($ToolName) {
    $toolsToInstall = $nodejsTools | Where-Object { $_.name -eq $ToolName }
    if (-not $toolsToInstall) {
        Write-Error "Tool not found: $ToolName"
        exit 1
    }
}

if ($DryRun) {
    Write-Output "`n=== DRY RUN MODE ==="
    Write-Output "Would install the following Node.js tools:"
    foreach ($tool in $toolsToInstall) {
        Write-Output "  - $($tool.name)"
        Write-Output "    Package: $($tool.package)"
        Write-Output "    Category: $($tool.category_type)"
    }
    Write-Output "===================`n"
    exit 0
}

function Install-NodeJsTool {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Tool
    )

    $toolName = $Tool.name
    $package = $Tool.package

    Write-DateLog "Installing Node.js tool: $toolName" >> ${ROOT_PATH}\log\nodejs_tools.txt

    try {
        # Install package globally with npm
        $result = npm install -g $package 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-DateLog "Successfully installed: $toolName" >> ${ROOT_PATH}\log\nodejs_tools.txt
            return $true
        } else {
            Write-DateLog "Failed to install $toolName : $result" >> ${ROOT_PATH}\log\nodejs_tools.txt
            return $false
        }
    } catch {
        Write-DateLog "Error installing $toolName : $_" >> ${ROOT_PATH}\log\nodejs_tools.txt
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
Write-DateLog "Starting installation of $($toolsToInstall.Count) Node.js tools" >> ${ROOT_PATH}\log\nodejs_tools.txt

foreach ($tool in $toolsToInstall) {
    $result = Install-NodeJsTool -Tool $tool

    if ($result) {
        $stats.success++
    } else {
        $stats.failed++
    }
}

# Summary
Write-DateLog "`n========================================" >> ${ROOT_PATH}\log\nodejs_tools.txt
Write-DateLog "Node.js Tools Installation Summary" >> ${ROOT_PATH}\log\nodejs_tools.txt
Write-DateLog "========================================" >> ${ROOT_PATH}\log\nodejs_tools.txt
Write-DateLog "Total tools: $($stats.total)" >> ${ROOT_PATH}\log\nodejs_tools.txt
Write-DateLog "Successfully installed: $($stats.success)" >> ${ROOT_PATH}\log\nodejs_tools.txt
Write-DateLog "Failed: $($stats.failed)" >> ${ROOT_PATH}\log\nodejs_tools.txt
Write-DateLog "========================================`n" >> ${ROOT_PATH}\log\nodejs_tools.txt

Write-Output "`n========================================`n"
Write-Output "Node.js Tools Installation Complete"
Write-Output "Success: $($stats.success) / $($stats.total)"
if ($stats.failed -gt 0) {
    Write-Output "Failed: $($stats.failed)"
}
Write-Output "========================================`n"
