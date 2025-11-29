# DFIRWS Tool Addition Script
# Interactive script to add new tools with validation
# Version: 1.0

param(
    [Parameter(HelpMessage = "Tool name")]
    [string]$Name,

    [Parameter(HelpMessage = "Category")]
    [ValidateSet("forensics", "malware-analysis", "utilities", "network-analysis",
                 "reverse-engineering", "memory-forensics", "data-analysis",
                 "windows-forensics", "disk-forensics", "document-analysis",
                 "email-forensics", "threat-intelligence", "active-directory")]
    [string]$Category,

    [Parameter(HelpMessage = "Non-interactive mode using provided parameters")]
    [switch]$NonInteractive
)

# Import common functions
. ".\resources\download\common.ps1"
. ".\resources\download\tool-handler.ps1"

#region Helper Functions

function Show-Welcome {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "   DFIRWS Tool Addition Wizard" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    Write-Host "This wizard will help you add a new tool to DFIRWS."
    Write-Host "It will validate your input and generate properly formatted YAML.`n"
}

function Get-ValidatedInput {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [scriptblock]$Validator = $null,
        [switch]$Required,
        [string[]]$ValidOptions = $null
    )

    while ($true) {
        if ($Default) {
            $userInput = Read-Host "$Prompt [$Default]"
            if ([string]::IsNullOrWhiteSpace($userInput)) {
                $userInput = $Default
            }
        } else {
            $userInput = Read-Host $Prompt
        }

        # Check if required
        if ($Required -and [string]::IsNullOrWhiteSpace($userInput)) {
            Write-Output "  ✗ This field is required"
            continue
        }

        # Allow empty for optional fields
        if ([string]::IsNullOrWhiteSpace($userInput) -and -not $Required) {
            return ""
        }

        # Check valid options
        if ($ValidOptions -and $userInput -notin $ValidOptions) {
            Write-Output "  ✗ Invalid option. Valid options: $($ValidOptions -join ', ')"
            continue
        }

        # Run custom validator
        if ($Validator) {
            $result = & $Validator $userInput
            if ($result -ne $true) {
                Write-Output "  ✗ $result"
                continue
            }
        }

        return $userInput.Trim()
    }
}

function Test-GitHubRepo {
    param([string]$Repo)

    if ($Repo -notmatch '^[\w\-\.]+/[\w\-\.]+$') {
        return "Invalid format. Expected: owner/repo"
    }

    # Try to validate the repo exists
    try {
        $url = "https://api.github.com/repos/$Repo"
        $response = curl.exe --silent -L $url
        $json = $response | ConvertFrom-Json

        if ($json.id) {
            Write-Information "  ✓ Found: $($json.full_name) - $($json.description)" -InformationAction Continue
            return $true
        }
    } catch {
        return "Could not validate repository"
    }

    return "Repository not found"
}

function Test-Url {
    param([string]$Url)

    if ($Url -notmatch '^https?://') {
        return "URL must start with http:// or https://"
    }

    return $true
}

function Get-CategoryFilePath {
    param([string]$Category)
    return ".\resources\tools\$Category.yaml"
}

function Test-CategoryExists {
    param([string]$Category)
    return Test-Path (Get-CategoryFilePath -Category $Category)
}

function Get-ExistingCategories {
    $yamlFiles = Get-ChildItem ".\resources\tools\*.yaml" -ErrorAction SilentlyContinue
    return $yamlFiles | ForEach-Object { $_.BaseName }
}

function Format-YAMLValue {
    param(
        [string]$Value,
        [switch]$Quoted
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ""
    }

    if ($Quoted) {
        # Escape quotes in value
        $escaped = $Value -replace '"', '\"'
        return "`"$escaped`""
    }

    return $Value
}

function New-ToolYAML {
    param(
        [hashtable]$ToolInfo
    )

    $yaml = @()
    $yaml += "- name: $($ToolInfo.name)"
    $yaml += "  description: $(Format-YAMLValue $ToolInfo.description -Quoted)"
    $yaml += "  source: $($ToolInfo.source)"

    if ($ToolInfo.source -eq "github") {
        $yaml += "  repo: $($ToolInfo.repo)"
        $yaml += "  match: $(Format-YAMLValue $ToolInfo.match -Quoted)"
    } elseif ($ToolInfo.source -eq "http") {
        if ($ToolInfo.url_pattern) {
            $yaml += "  url_pattern: $(Format-YAMLValue $ToolInfo.url_pattern -Quoted)"
            $yaml += "  match: $(Format-YAMLValue $ToolInfo.match -Quoted)"
        } else {
            $yaml += "  url: $(Format-YAMLValue $ToolInfo.url -Quoted)"
        }
    }

    if ($ToolInfo.version) {
        $yaml += "  version: $(Format-YAMLValue $ToolInfo.version -Quoted)"
    }

    if ($ToolInfo.sha256) {
        $yaml += "  sha256: $(Format-YAMLValue $ToolInfo.sha256 -Quoted)"
    }

    if ($ToolInfo.update_policy -and $ToolInfo.update_policy -ne "notify") {
        $yaml += "  update_policy: $(Format-YAMLValue $ToolInfo.update_policy -Quoted)"
    }

    $yaml += "  file_type: $($ToolInfo.file_type)"
    $yaml += "  install_method: $($ToolInfo.install_method)"

    if ($ToolInfo.install_method -eq "extract") {
        $yaml += "  extract_to: $(Format-YAMLValue $ToolInfo.extract_to -Quoted)"
    } elseif ($ToolInfo.install_method -eq "run") {
        $yaml += "  run_args: $(Format-YAMLValue $ToolInfo.run_args -Quoted)"
    } elseif ($ToolInfo.install_method -eq "copy") {
        $yaml += "  copy_to: $(Format-YAMLValue $ToolInfo.copy_to -Quoted)"
    }

    # Post-install steps
    if ($ToolInfo.post_install -and $ToolInfo.post_install.Count -gt 0) {
        $yaml += "  post_install:"
        foreach ($step in $ToolInfo.post_install) {
            $yaml += "    - type: $($step.type)"
            foreach ($key in $step.Keys) {
                if ($key -ne "type") {
                    $yaml += "      ${key}: $(Format-YAMLValue $step[$key] -Quoted)"
                }
            }
        }
    }

    $yaml += "  enabled: $($ToolInfo.enabled)"
    $yaml += "  priority: $($ToolInfo.priority)"

    return $yaml -join "`n"
}

function Add-ToolToCategory {
    param(
        [string]$Category,
        [string]$ToolYAML
    )

    $filePath = Get-CategoryFilePath -Category $Category

    # Create category file if it doesn't exist
    if (-not (Test-Path $filePath)) {
        Write-Host "`nCreating new category file: $Category.yaml" -ForegroundColor Yellow
        Set-Content -Path $filePath -Value "# $Category tools`n"
    }

    # Append the tool
    Add-Content -Path $filePath -Value "`n$ToolYAML"
    Write-Host "`n✓ Tool added to $Category.yaml" -ForegroundColor Green
}

function Test-YAMLSyntax {
    param([string]$FilePath)

    # Basic YAML validation
    try {
        $content = Get-Content $FilePath -Raw

        # Check for common YAML issues
        if ($content -match '^\s+[^-\s]') {
            Write-Warning "Potential indentation issue detected"
        }

        # Extract category from filename
        $category = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)

        # Try to parse with tool-handler functions
        $tools = Import-ToolDefinitions -Category $category -Path (Split-Path $FilePath)
        if ($tools) {
            Write-Host "✓ YAML validation passed - $($tools.Count) tools in file" -ForegroundColor Green
            return $true
        } else {
            Write-Warning "No tools found in YAML file (might be valid but empty)"
            return $true
        }
    } catch {
        Write-Error "YAML validation failed: $_"
        return $false
    }
}

function Show-ToolSummary {
    param([hashtable]$ToolInfo)

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "   Tool Summary" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    foreach ($key in $ToolInfo.Keys | Sort-Object) {
        $value = $ToolInfo[$key]
        if ($value -is [array]) {
            Write-Host "$key`:" -ForegroundColor Yellow
            foreach ($item in $value) {
                Write-Host "  - $item" -ForegroundColor Gray
            }
        } elseif ($value -is [hashtable]) {
            Write-Host "$key`:" -ForegroundColor Yellow
            foreach ($k in $value.Keys) {
                Write-Host "  $k`: $($value[$k])" -ForegroundColor Gray
            }
        } else {
            Write-Host "$key`: " -NoNewline -ForegroundColor Yellow
            Write-Host $value -ForegroundColor Gray
        }
    }
    Write-Host ""
}

#endregion

#region Main Script

Show-Welcome

# Collect tool information
$toolInfo = @{}

# 1. Tool name
if ($Name) {
    $toolInfo.name = $Name
} else {
    $toolInfo.name = Get-ValidatedInput `
        -Prompt "Tool name" `
        -Required `
        -Validator {
            param($v)
            if ($v -match '^[a-zA-Z0-9\-_\.]+$') { return $true }
            return "Tool name can only contain letters, numbers, hyphens, underscores, and dots"
        }
}

# 2. Description
$toolInfo.description = Get-ValidatedInput `
    -Prompt "Description" `
    -Required

# 3. Category
if ($Category) {
    $toolInfo.category = $Category
} else {
    $existingCategories = Get-ExistingCategories
    Write-Host "`nExisting categories:"
    $existingCategories | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    Write-Host ""

    $toolInfo.category = Get-ValidatedInput `
        -Prompt "Category" `
        -Required `
        -ValidOptions @(
            "forensics", "malware-analysis", "utilities", "network-analysis",
            "reverse-engineering", "memory-forensics", "data-analysis",
            "windows-forensics", "disk-forensics", "document-analysis",
            "email-forensics", "threat-intelligence", "active-directory"
        )
}

# 4. Source
$toolInfo.source = Get-ValidatedInput `
    -Prompt "Source (github/http)" `
    -Default "github" `
    -Required `
    -ValidOptions @("github", "http")

# 5. Source-specific fields
if ($toolInfo.source -eq "github") {
    $toolInfo.repo = Get-ValidatedInput `
        -Prompt "GitHub repository (owner/repo)" `
        -Required `
        -Validator ${function:Test-GitHubRepo}

    $toolInfo.match = Get-ValidatedInput `
        -Prompt "Asset filename pattern (regex)" `
        -Required

} elseif ($toolInfo.source -eq "http") {
    $useDynamic = Get-ValidatedInput `
        -Prompt "Use dynamic URL detection? (y/n)" `
        -Default "n" `
        -ValidOptions @("y", "n")

    if ($useDynamic -eq "y") {
        $toolInfo.url_pattern = Get-ValidatedInput `
            -Prompt "URL pattern (page to scrape)" `
            -Required `
            -Validator ${function:Test-Url}

        $toolInfo.match = Get-ValidatedInput `
            -Prompt "Download link regex pattern" `
            -Required
    } else {
        $toolInfo.url = Get-ValidatedInput `
            -Prompt "Direct download URL" `
            -Required `
            -Validator ${function:Test-Url}
    }
}

# 6. Version pinning
$pinVersion = Get-ValidatedInput `
    -Prompt "Pin to specific version? (y/n)" `
    -Default "n" `
    -ValidOptions @("y", "n")

if ($pinVersion -eq "y") {
    $toolInfo.version = Get-ValidatedInput `
        -Prompt "Version number" `
        -Required
}

# 7. SHA256 checksum
$addSHA256 = Get-ValidatedInput `
    -Prompt "Add SHA256 checksum? (y/n)" `
    -Default "n" `
    -ValidOptions @("y", "n")

if ($addSHA256 -eq "y") {
    $toolInfo.sha256 = Get-ValidatedInput `
        -Prompt "SHA256 checksum (or leave empty to calculate later)"
}

# 8. Update policy
$toolInfo.update_policy = Get-ValidatedInput `
    -Prompt "Update policy (manual/auto/notify)" `
    -Default "notify" `
    -ValidOptions @("manual", "auto", "notify")

# 9. File type
$toolInfo.file_type = Get-ValidatedInput `
    -Prompt "File type (zip/exe/msi/jar/war)" `
    -Default "zip" `
    -Required `
    -ValidOptions @("zip", "exe", "msi", "jar", "war")

# 10. Install method
$toolInfo.install_method = Get-ValidatedInput `
    -Prompt "Install method (extract/run/copy)" `
    -Default "extract" `
    -Required `
    -ValidOptions @("extract", "run", "copy")

# 11. Install method specific fields
if ($toolInfo.install_method -eq "extract") {
    $toolInfo.extract_to = Get-ValidatedInput `
        -Prompt "Extract to path" `
        -Default "`${TOOLS}/$($toolInfo.name)" `
        -Required

} elseif ($toolInfo.install_method -eq "run") {
    $toolInfo.run_args = Get-ValidatedInput `
        -Prompt "Run arguments (e.g., /S /D=path)"

} elseif ($toolInfo.install_method -eq "copy") {
    $toolInfo.copy_to = Get-ValidatedInput `
        -Prompt "Copy to path" `
        -Required
}

# 12. Post-install steps
$addPostInstall = Get-ValidatedInput `
    -Prompt "Add post-install steps? (y/n)" `
    -Default "n" `
    -ValidOptions @("y", "n")

if ($addPostInstall -eq "y") {
    $toolInfo.post_install = @()

    Write-Host "`nAvailable post-install step types:"
    Write-Host "  - rename: Rename files/directories"
    Write-Host "  - move: Move files to different location"
    Write-Host "  - delete: Delete files/directories"
    Write-Host "  - symlink: Create symbolic link"
    Write-Host ""

    while ($true) {
        $stepType = Get-ValidatedInput `
            -Prompt "Post-install step type (or 'done' to finish)" `
            -ValidOptions @("rename", "move", "delete", "symlink", "done")

        if ($stepType -eq "done") { break }

        $step = @{ type = $stepType }

        switch ($stepType) {
            "rename" {
                $step.pattern = Get-ValidatedInput -Prompt "  Pattern to match" -Required
                $step.target = Get-ValidatedInput -Prompt "  New name" -Required
            }
            "move" {
                $step.source = Get-ValidatedInput -Prompt "  Source path" -Required
                $step.destination = Get-ValidatedInput -Prompt "  Destination path" -Required
            }
            "delete" {
                $step.path = Get-ValidatedInput -Prompt "  Path to delete" -Required
            }
            "symlink" {
                $step.source = Get-ValidatedInput -Prompt "  Source path" -Required
                $step.target = Get-ValidatedInput -Prompt "  Link path" -Required
            }
        }

        $toolInfo.post_install += $step
    }
}

# 13. Priority
$toolInfo.priority = Get-ValidatedInput `
    -Prompt "Priority (critical/high/medium/low)" `
    -Default "medium" `
    -Required `
    -ValidOptions @("critical", "high", "medium", "low")

# 14. Enabled
$toolInfo.enabled = Get-ValidatedInput `
    -Prompt "Enable tool? (true/false)" `
    -Default "true" `
    -Required `
    -ValidOptions @("true", "false")

# Show summary
Show-ToolSummary -ToolInfo $toolInfo

# Confirm
$confirm = Get-ValidatedInput `
    -Prompt "Add this tool? (y/n)" `
    -Default "y" `
    -ValidOptions @("y", "n")

if ($confirm -ne "y") {
    Write-Host "`nTool addition cancelled" -ForegroundColor Yellow
    exit 0
}

# Generate YAML
$toolYAML = New-ToolYAML -ToolInfo $toolInfo

Write-Host "`nGenerated YAML:" -ForegroundColor Cyan
Write-Host "----------------------------------------"
Write-Host $toolYAML -ForegroundColor Gray
Write-Host "----------------------------------------`n"

# Add to category file
Add-ToolToCategory -Category $toolInfo.category -ToolYAML $toolYAML

# Validate YAML
$categoryFile = Get-CategoryFilePath -Category $toolInfo.category
Write-Host "Validating YAML syntax..." -ForegroundColor Cyan
Test-YAMLSyntax -FilePath $categoryFile

Write-Host "`n✓ Tool '$($toolInfo.name)' successfully added!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Review the YAML in: $categoryFile"
Write-Host "  2. Test installation: .\install-tools.ps1 -Category $($toolInfo.category) -DryRun"
Write-Host "  3. Install the tool: .\install-tools.ps1 -Category $($toolInfo.category)`n"

#endregion
