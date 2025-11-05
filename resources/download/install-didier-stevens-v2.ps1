# DFIRWS Didier Stevens Tools Installer (v2 - YAML-based)
# Downloads Didier Stevens tools from didier-stevens-tools.yaml
# Version: 2.0

param(
    [Parameter(HelpMessage = "Install all Didier Stevens tools")]
    [Switch]$All,

    [Parameter(HelpMessage = "Install specific tool by name")]
    [string]$ToolName,

    [Parameter(HelpMessage = "Install only main suite tools")]
    [Switch]$MainOnly,

    [Parameter(HelpMessage = "Install only beta tools")]
    [Switch]$BetaOnly,

    [Parameter(HelpMessage = "Dry run - show what would be done")]
    [Switch]$DryRun
)

# Import modules
. ".\resources\download\common.ps1"
. ".\resources\download\yaml-parser.ps1"

$ROOT_PATH = "${PWD}"
$DIDIER_TOOLS_PATH = "${ROOT_PATH}\mount\Tools\DidierStevens"

Write-DateLog "Didier Stevens Tools Installer v2 - Loading definitions from YAML" > ${ROOT_PATH}\log\didier_stevens.txt

# Ensure directory exists
if (-not (Test-Path $DIDIER_TOOLS_PATH)) {
    New-Item -ItemType Directory -Path $DIDIER_TOOLS_PATH -Force | Out-Null
    Write-DateLog "Created DidierStevens directory: $DIDIER_TOOLS_PATH" >> ${ROOT_PATH}\log\didier_stevens.txt
}

# Load Didier Stevens tools from YAML
$didierTools = Import-DidierStevensToolsDefinition

if (-not $didierTools) {
    Write-DateLog "Failed to load Didier Stevens tools definitions" >> ${ROOT_PATH}\log\didier_stevens.txt
    exit 1
}

Write-DateLog "Loaded $($didierTools.Count) Didier Stevens tools from YAML" >> ${ROOT_PATH}\log\didier_stevens.txt

# Filter tools based on parameters
$toolsToInstall = $didierTools

if ($ToolName) {
    $toolsToInstall = $didierTools | Where-Object { $_.name -eq $ToolName }
    if (-not $toolsToInstall) {
        Write-Error "Tool not found: $ToolName"
        exit 1
    }
} elseif ($MainOnly) {
    $toolsToInstall = $didierTools | Where-Object { $_.suite -eq "main" }
} elseif ($BetaOnly) {
    $toolsToInstall = $didierTools | Where-Object { $_.suite -eq "beta" }
}

if ($DryRun) {
    Write-Output "`n=== DRY RUN MODE ==="
    Write-Output "Would install the following Didier Stevens tools:"
    $mainCount = ($toolsToInstall | Where-Object { $_.suite -eq "main" }).Count
    $betaCount = ($toolsToInstall | Where-Object { $_.suite -eq "beta" }).Count
    Write-Output "  Main suite tools: $mainCount"
    Write-Output "  Beta tools: $betaCount"
    Write-Output "  Total: $($toolsToInstall.Count)"
    Write-Output "===================`n"
    exit 0
}

function Install-DidierStevensTool {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Tool
    )

    $toolName = $Tool.name
    $sourceUrl = $Tool.source + $toolName
    $destination = $Tool.destination -replace '\$\{TOOLS\}', "${ROOT_PATH}\mount\Tools"
    $filePath = Join-Path $destination $toolName

    Write-DateLog "Installing: $toolName from $($Tool.suite) suite" >> ${ROOT_PATH}\log\didier_stevens.txt

    try {
        # Determine expected file type for validation
        $extension = [System.IO.Path]::GetExtension($toolName)
        $checkString = switch ($extension) {
            ".exe" { "PE32" }
            ".dll" { "PE32" }
            ".py" { "(Python script|^$)" }
            ".def" { "magic text fragment" }
            ".json" { "JSON text data" }
            ".library" { "ASCII text" }
            ".ini" { "ASCII text" }
            default { "ASCII text" }
        }

        # Download using common function
        $status = Get-FileFromUri -uri $sourceUrl -FilePath $filePath -check $checkString

        if ($status) {
            Write-DateLog "Successfully installed: $toolName" >> ${ROOT_PATH}\log\didier_stevens.txt
            return $true
        } else {
            Write-DateLog "Failed to install $toolName" >> ${ROOT_PATH}\log\didier_stevens.txt
            return $false
        }
    } catch {
        Write-DateLog "Error installing $toolName : $_" >> ${ROOT_PATH}\log\didier_stevens.txt
        return $false
    }
}

# Statistics
$stats = @{
    total = $toolsToInstall.Count
    success = 0
    failed = 0
    main = 0
    beta = 0
}

# Install tools
Write-DateLog "Starting installation of $($toolsToInstall.Count) Didier Stevens tools" >> ${ROOT_PATH}\log\didier_stevens.txt

foreach ($tool in $toolsToInstall) {
    $result = Install-DidierStevensTool -Tool $tool

    if ($result) {
        $stats.success++
        if ($tool.suite -eq "main") {
            $stats.main++
        } else {
            $stats.beta++
        }
    } else {
        $stats.failed++
    }
}

# Summary
Write-DateLog "`n========================================" >> ${ROOT_PATH}\log\didier_stevens.txt
Write-DateLog "Didier Stevens Tools Installation Summary" >> ${ROOT_PATH}\log\didier_stevens.txt
Write-DateLog "========================================" >> ${ROOT_PATH}\log\didier_stevens.txt
Write-DateLog "Total tools: $($stats.total)" >> ${ROOT_PATH}\log\didier_stevens.txt
Write-DateLog "Main suite: $($stats.main)" >> ${ROOT_PATH}\log\didier_stevens.txt
Write-DateLog "Beta tools: $($stats.beta)" >> ${ROOT_PATH}\log\didier_stevens.txt
Write-DateLog "Successfully installed: $($stats.success)" >> ${ROOT_PATH}\log\didier_stevens.txt
Write-DateLog "Failed: $($stats.failed)" >> ${ROOT_PATH}\log\didier_stevens.txt
Write-DateLog "========================================`n" >> ${ROOT_PATH}\log\didier_stevens.txt

Write-Output "`n========================================`n"
Write-Output "Didier Stevens Tools Installation Complete"
Write-Output "Success: $($stats.success) / $($stats.total)"
Write-Output "  Main suite: $($stats.main)"
Write-Output "  Beta tools: $($stats.beta)"
if ($stats.failed -gt 0) {
    Write-Output "Failed: $($stats.failed)"
}
Write-Output "========================================`n"
