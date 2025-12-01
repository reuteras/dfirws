# DFIRWS YAML Parser Module
# Provides functions to parse specialized YAML tool definitions
# Version: 1.0

#region PowerShell-YAML Module Handling

function Test-YamlModule {
    <#
    .SYNOPSIS
        Check if powershell-yaml module is available and load it
    #>
    if (Get-Module -ListAvailable -Name powershell-yaml) {
        try {
            Import-Module powershell-yaml -ErrorAction Stop
            return $true
        } catch {
            # Silently fall back to manual parser
            return $false
        }
    } else {
        # Silently use fallback parser
        return $false
    }
}

#endregion

#region Standard Tools YAML Parser (Category-based)

function Import-ToolDefinition {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Category
    )

    $yamlFile = "${PSScriptRoot}\..\tools\${Category}.yaml"

    if (-not (Test-Path $yamlFile)) {
        throw "YAML file not found: $yamlFile"
    }

    $tools = @()
    $content = Get-Content $yamlFile -Raw
    $lines = $content -split "`n"

    $currentTool = $null
    $inTools = $false

    foreach ($line in $lines) {
        $trimmed = $line.TrimEnd()

        # Detect tools section
        if ($trimmed -match "^tools:") {
            $inTools = $true
            continue
        }

        # Detect end of tools section
        if ($inTools -and $trimmed -match "^[a-zA-Z]" -and -not $trimmed.StartsWith(" ")) {
            $inTools = $false
            continue
        }

        # Parse tool entries
        if ($inTools -and $trimmed -match "^\s*-\s*name:\s*(.+)") {
            # Save previous tool
            if ($currentTool) {
                $tools += $currentTool
            }

            # Start new tool
            $currentTool = [PSCustomObject]@{
                name = $matches[1].Trim()
                category = $Category
            }
        } elseif ($currentTool -and $trimmed -match "^\s*(\w+):\s*(.+)") {
            $key = $matches[1]
            $value = $matches[2].Trim('"').Trim("'")
            $currentTool | Add-Member -NotePropertyName $key -NotePropertyValue $value -Force
        }
    }

    # Add last tool
    if ($currentTool) {
        $tools += $currentTool
    }

    return $tools
}

#endregion

#region Python Tools YAML Parser

function Import-PythonToolsDefinition {
    <#
    .SYNOPSIS
        Import Python tools from python-tools.yaml

    .DESCRIPTION
        Parses python-tools.yaml which contains:
        - special_installs: Python packages with complex dependencies
        - tools: Standard Python packages

    .PARAMETER Path
        Path to python-tools.yaml file
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "${PSScriptRoot}\..\tools\python-tools.yaml"
    )

    if (-not (Test-Path $Path)) {
        Write-Error "Python tools definition not found: $Path"
        return $null
    }

    $useYamlModule = Test-YamlModule

    if ($useYamlModule) {
        # Use powershell-yaml for full parsing
        $content = Get-Content -Path $Path -Raw
        $definition = ConvertFrom-Yaml -Yaml $content

        $allTools = @()

        # Add special installs
        if ($definition.special_installs) {
            foreach ($tool in $definition.special_installs) {
                $tool | Add-Member -NotePropertyName "install_type" -NotePropertyValue "special" -Force
                $tool | Add-Member -NotePropertyName "category" -NotePropertyValue "python-tools" -Force
                $allTools += $tool
            }
        }

        # Add standard tools
        if ($definition.tools) {
            foreach ($tool in $definition.tools) {
                $tool | Add-Member -NotePropertyName "install_type" -NotePropertyValue "standard" -Force
                $tool | Add-Member -NotePropertyName "category" -NotePropertyValue "python-tools" -Force
                $allTools += $tool
            }
        }

        # Add repo scripts
        if ($definition.repo_scripts) {
            foreach ($tool in $definition.repo_scripts) {
                $tool | Add-Member -NotePropertyName "install_type" -NotePropertyValue "repo_script" -Force
                $tool | Add-Member -NotePropertyName "category" -NotePropertyValue "python-tools" -Force
                $allTools += $tool
            }
        }

        # Add direct scripts
        if ($definition.direct_scripts) {
            foreach ($tool in $definition.direct_scripts) {
                $tool | Add-Member -NotePropertyName "install_type" -NotePropertyValue "direct_script" -Force
                $tool | Add-Member -NotePropertyName "category" -NotePropertyValue "python-tools" -Force
                $allTools += $tool
            }
        }

        # Add utility scripts
        if ($definition.utility_scripts) {
            foreach ($tool in $definition.utility_scripts) {
                $tool | Add-Member -NotePropertyName "install_type" -NotePropertyValue "utility_script" -Force
                $tool | Add-Member -NotePropertyName "category" -NotePropertyValue "python-tools" -Force
                $allTools += $tool
            }
        }

        return $allTools
    } else {
        # Fallback: Simple parser
        $content = Get-Content -Path $Path
        $allTools = @()
        $currentTool = $null
        $inSpecialInstalls = $false
        $inTools = $false

        foreach ($line in $content) {
            $trimmed = $line.TrimStart()

            if ($trimmed -match "^special_installs:") {
                $inSpecialInstalls = $true
                $inTools = $false
                continue
            }

            if ($trimmed -match "^tools:") {
                $inTools = $true
                $inSpecialInstalls = $false
                continue
            }

            if ($trimmed -match "^notes:") {
                $inSpecialInstalls = $false
                $inTools = $false
                continue
            }

            if (($inSpecialInstalls -or $inTools) -and $trimmed -match "^\s*-\s*name:\s*(.+)") {
                # Save previous tool
                if ($currentTool) {
                    $currentTool | Add-Member -NotePropertyName "install_type" -NotePropertyValue $(if ($inSpecialInstalls) { "special" } else { "standard" }) -Force
                    $currentTool | Add-Member -NotePropertyName "category" -NotePropertyValue "python-tools" -Force
                    $allTools += $currentTool
                }

                # Start new tool
                $currentTool = [PSCustomObject]@{
                    name = $matches[1]
                }
            } elseif ($currentTool -and $trimmed -match "^\s*(\w+):\s*(.+)") {
                $key = $matches[1]
                $value = $matches[2].Trim('"').Trim("'")
                $currentTool | Add-Member -NotePropertyName $key -NotePropertyValue $value -Force
            }
        }

        # Add last tool
        if ($currentTool) {
            $currentTool | Add-Member -NotePropertyName "install_type" -NotePropertyValue $(if ($inSpecialInstalls) { "special" } else { "standard" }) -Force
            $currentTool | Add-Member -NotePropertyName "category" -NotePropertyValue "python-tools" -Force
            $allTools += $currentTool
        }

        return $allTools
    }
}

#endregion

#region Git Repositories YAML Parser

function Import-GitRepositoriesDefinition {
    <#
    .SYNOPSIS
        Import Git repositories from git-repositories.yaml

    .PARAMETER Path
        Path to git-repositories.yaml file
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "${PSScriptRoot}\..\tools\git-repositories.yaml"
    )

    if (-not (Test-Path $Path)) {
        Write-Error "Git repositories definition not found: $Path"
        return $null
    }

    $useYamlModule = Test-YamlModule

    if ($useYamlModule) {
        $content = Get-Content -Path $Path -Raw
        $definition = ConvertFrom-Yaml -Yaml $content

        $allRepos = @()

        if ($definition.repositories) {
            foreach ($repo in $definition.repositories) {
                $repo | Add-Member -NotePropertyName "category" -NotePropertyValue "git-repositories" -Force
                $allRepos += $repo
            }
        }

        return $allRepos
    } else {
        # Fallback parser
        $content = Get-Content -Path $Path
        $allRepos = @()
        $currentRepo = $null
        $inRepositories = $false

        foreach ($line in $content) {
            $trimmed = $line.TrimStart()

            if ($trimmed -match "^repositories:") {
                $inRepositories = $true
                continue
            }

            if ($trimmed -match "^notes:") {
                $inRepositories = $false
                continue
            }

            if ($inRepositories -and $trimmed -match "^\s*-\s*name:\s*(.+)") {
                # Save previous repo
                if ($currentRepo) {
                    $currentRepo | Add-Member -NotePropertyName "category" -NotePropertyValue "git-repositories" -Force
                    $allRepos += $currentRepo
                }

                # Start new repo
                $currentRepo = [PSCustomObject]@{
                    name = $matches[1]
                }
            } elseif ($currentRepo -and $trimmed -match "^\s*(\w+):\s*(.+)") {
                $key = $matches[1]
                $value = $matches[2].Trim('"').Trim("'")
                $currentRepo | Add-Member -NotePropertyName $key -NotePropertyValue $value -Force
            }
        }

        # Add last repo
        if ($currentRepo) {
            $currentRepo | Add-Member -NotePropertyName "category" -NotePropertyValue "git-repositories" -Force
            $allRepos += $currentRepo
        }

        return $allRepos
    }
}

#endregion

#region Node.js Tools YAML Parser

function Import-NodeJsToolsDefinition {
    <#
    .SYNOPSIS
        Import Node.js tools from nodejs-tools.yaml

    .PARAMETER Path
        Path to nodejs-tools.yaml file
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "${PSScriptRoot}\..\tools\nodejs-tools.yaml"
    )

    if (-not (Test-Path $Path)) {
        Write-Error "Node.js tools definition not found: $Path"
        return $null
    }

    $useYamlModule = Test-YamlModule

    if ($useYamlModule) {
        $content = Get-Content -Path $Path -Raw
        $definition = ConvertFrom-Yaml -Yaml $content

        $allTools = @()

        if ($definition.tools) {
            foreach ($tool in $definition.tools) {
                $tool | Add-Member -NotePropertyName "category" -NotePropertyValue "nodejs-tools" -Force
                $allTools += $tool
            }
        }

        return $allTools
    } else {
        # Fallback parser
        $content = Get-Content -Path $Path
        $allTools = @()
        $currentTool = $null
        $inTools = $false

        foreach ($line in $content) {
            $trimmed = $line.TrimStart()

            if ($trimmed -match "^tools:") {
                $inTools = $true
                continue
            }

            if ($trimmed -match "^notes:") {
                $inTools = $false
                continue
            }

            if ($inTools -and $trimmed -match "^\s*-\s*name:\s*(.+)") {
                # Save previous tool
                if ($currentTool) {
                    $currentTool | Add-Member -NotePropertyName "category" -NotePropertyValue "nodejs-tools" -Force
                    $allTools += $currentTool
                }

                # Start new tool
                $currentTool = [PSCustomObject]@{
                    name = $matches[1]
                }
            } elseif ($currentTool -and $trimmed -match "^\s*(\w+):\s*(.+)") {
                $key = $matches[1]
                $value = $matches[2].Trim('"').Trim("'")
                $currentTool | Add-Member -NotePropertyName $key -NotePropertyValue $value -Force
            }
        }

        # Add last tool
        if ($currentTool) {
            $currentTool | Add-Member -NotePropertyName "category" -NotePropertyValue "nodejs-tools" -Force
            $allTools += $currentTool
        }

        return $allTools
    }
}

#endregion

#region Didier Stevens Tools YAML Parser

function Import-DidierStevensToolsDefinition {
    <#
    .SYNOPSIS
        Import Didier Stevens tools from didier-stevens-tools.yaml

    .PARAMETER Path
        Path to didier-stevens-tools.yaml file
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "${PSScriptRoot}\..\tools\didier-stevens-tools.yaml"
    )

    if (-not (Test-Path $Path)) {
        Write-Error "Didier Stevens tools definition not found: $Path"
        return $null
    }

    $useYamlModule = Test-YamlModule

    if ($useYamlModule) {
        $content = Get-Content -Path $Path -Raw
        $definition = ConvertFrom-Yaml -Yaml $content

        $allTools = @()

        # Main suite tools
        if ($definition.main_suite -and $definition.main_suite.tools) {
            foreach ($tool in $definition.main_suite.tools) {
                $tool | Add-Member -NotePropertyName "source" -NotePropertyValue $definition.main_suite.source -Force
                $tool | Add-Member -NotePropertyName "destination" -NotePropertyValue $definition.main_suite.destination -Force
                $tool | Add-Member -NotePropertyName "suite" -NotePropertyValue "main" -Force
                $tool | Add-Member -NotePropertyName "category" -NotePropertyValue "didier-stevens-tools" -Force
                $allTools += $tool
            }
        }

        # Beta tools
        if ($definition.beta_tools -and $definition.beta_tools.tools) {
            foreach ($tool in $definition.beta_tools.tools) {
                $tool | Add-Member -NotePropertyName "source" -NotePropertyValue $definition.beta_tools.source -Force
                $tool | Add-Member -NotePropertyName "destination" -NotePropertyValue $definition.beta_tools.destination -Force
                $tool | Add-Member -NotePropertyName "suite" -NotePropertyValue "beta" -Force
                $tool | Add-Member -NotePropertyName "category" -NotePropertyValue "didier-stevens-tools" -Force
                $allTools += $tool
            }
        }

        return $allTools
    } else {
        # Fallback parser
        $content = Get-Content -Path $Path
        $allTools = @()
        $currentTool = $null
        $inMainSuite = $false
        $inBetaTools = $false
        $inTools = $false
        $currentSource = ""
        $currentDestination = ""

        foreach ($line in $content) {
            $trimmed = $line.TrimStart()

            if ($trimmed -match "^main_suite:") {
                $inMainSuite = $true
                $inBetaTools = $false
                $inTools = $false
                continue
            }

            if ($trimmed -match "^beta_tools:") {
                $inBetaTools = $true
                $inMainSuite = $false
                $inTools = $false
                continue
            }

            if (($inMainSuite -or $inBetaTools) -and $trimmed -match "^\s*source:\s*(.+)") {
                $currentSource = $matches[1].Trim('"').Trim("'")
                continue
            }

            if (($inMainSuite -or $inBetaTools) -and $trimmed -match "^\s*destination:\s*(.+)") {
                $currentDestination = $matches[1].Trim('"').Trim("'")
                continue
            }

            if (($inMainSuite -or $inBetaTools) -and $trimmed -match "^\s*tools:") {
                $inTools = $true
                continue
            }

            if ($trimmed -match "^notes:") {
                $inTools = $false
                continue
            }

            if ($inTools -and $trimmed -match "^\s*-\s*name:\s*(.+)") {
                # Save previous tool
                if ($currentTool) {
                    $currentTool | Add-Member -NotePropertyName "source" -NotePropertyValue $currentSource -Force
                    $currentTool | Add-Member -NotePropertyName "destination" -NotePropertyValue $currentDestination -Force
                    $currentTool | Add-Member -NotePropertyName "suite" -NotePropertyValue $(if ($inMainSuite) { "main" } else { "beta" }) -Force
                    $currentTool | Add-Member -NotePropertyName "category" -NotePropertyValue "didier-stevens-tools" -Force
                    $allTools += $currentTool
                }

                # Start new tool
                $currentTool = [PSCustomObject]@{
                    name = $matches[1]
                }
            } elseif ($currentTool -and $trimmed -match "^\s*(\w+):\s*(.+)") {
                $key = $matches[1]
                $value = $matches[2].Trim('"').Trim("'")
                $currentTool | Add-Member -NotePropertyName $key -NotePropertyValue $value -Force
            }
        }

        # Add last tool
        if ($currentTool) {
            $currentTool | Add-Member -NotePropertyName "source" -NotePropertyValue $currentSource -Force
            $currentTool | Add-Member -NotePropertyName "destination" -NotePropertyValue $currentDestination -Force
            $currentTool | Add-Member -NotePropertyName "suite" -NotePropertyValue $(if ($inMainSuite) { "main" } else { "beta" }) -Force
            $currentTool | Add-Member -NotePropertyName "category" -NotePropertyValue "didier-stevens-tools" -Force
            $allTools += $currentTool
        }

        return $allTools
    }
}

#endregion

# Note: Export-ModuleMember removed - this script is dot-sourced, not imported as a module
# All functions are automatically available when dot-sourced
