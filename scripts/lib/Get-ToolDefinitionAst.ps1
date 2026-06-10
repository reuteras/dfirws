# Shared AST-based extraction of $TOOL_DEFINITIONS blocks from the dfirws
# download/install scripts. The scripts are parsed statically and never
# executed, so this is safe to run on any host (including CI).
# Dot-source this file from scripts/validate-tool-metadata.ps1 and
# scripts/update-tool-metadata.ps1.

# Canonical schema - keep in sync with Normalize-ToolDefinitions in setup/shared.ps1.
$TOOL_DEFINITION_KEYS = @(
    "Name", "Homepage", "Vendor", "License", "LicenseUrl", "Category",
    "Shortcuts", "InstallVerifyCommand", "Verify", "Notes", "Tips", "Usage",
    "SampleCommands", "SampleFiles", "Tags", "FileExtensions", "Dependencies",
    "PythonVersion"
)

# Returns one object per `$TOOL_DEFINITIONS += @{...}` block in the file:
#   File, Line, Name, Keys (key -> {Value, IsString, IsEmpty, StartOffset, EndOffset}),
#   GitHubRepo (nearest preceding Get-GitHubRelease -repo value),
#   WingetId (nearest preceding Get-WinGet AppId).
function Get-ToolDefinitionsFromFile {
    param (
        [Parameter(Mandatory=$True)] [string]$Path
    )

    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path $Path), [ref]$null, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0) {
        throw "Parse errors in ${Path}: $($parseErrors[0].Message)"
    }

    # Collect download commands so each definition can be associated with the
    # nearest preceding source (GitHub repo or winget AppId).
    $sourceMarkers = @()
    $commands = $ast.FindAll({ param($node)
        $node -is [System.Management.Automation.Language.CommandAst] }, $true)
    foreach ($cmd in $commands) {
        $cmdName = $cmd.GetCommandName()
        if ($cmdName -eq "Get-GitHubRelease") {
            for ($i = 0; $i -lt $cmd.CommandElements.Count - 1; $i++) {
                $el = $cmd.CommandElements[$i]
                if ($el -is [System.Management.Automation.Language.CommandParameterAst] -and
                    $el.ParameterName -eq "repo") {
                    $val = $cmd.CommandElements[$i + 1]
                    if ($val.PSObject.Properties["Value"]) {
                        $sourceMarkers += [PSCustomObject]@{
                            Offset = $cmd.Extent.StartOffset
                            Type   = "github"
                            Value  = $val.Value
                        }
                    }
                }
            }
        } elseif ($cmdName -eq "Get-WinGet") {
            # First positional argument is the winget AppId.
            $positional = $cmd.CommandElements |
                Select-Object -Skip 1 |
                Where-Object { $_ -isnot [System.Management.Automation.Language.CommandParameterAst] } |
                Select-Object -First 1
            if ($positional -and $positional.PSObject.Properties["Value"]) {
                $sourceMarkers += [PSCustomObject]@{
                    Offset = $cmd.Extent.StartOffset
                    Type   = "winget"
                    Value  = $positional.Value
                }
            }
        }
    }

    $assignments = $ast.FindAll({ param($node)
        $node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
        $node.Operator -eq [System.Management.Automation.Language.TokenKind]::PlusEquals -and
        $node.Left -is [System.Management.Automation.Language.VariableExpressionAst] -and
        $node.Left.VariablePath.UserPath -eq "TOOL_DEFINITIONS" }, $true)

    $definitions = [System.Collections.Generic.List[PSCustomObject]]::new()
    foreach ($assignment in $assignments) {
        $hashtable = $assignment.Right.Find({ param($node)
            $node -is [System.Management.Automation.Language.HashtableAst] }, $true)
        if ($null -eq $hashtable) {
            continue
        }

        $keys = [ordered]@{}
        foreach ($pair in $hashtable.KeyValuePairs) {
            $keyName = $pair.Item1.SafeGetValue()
            $valueAst = $pair.Item2

            $value = $null
            $isString = $false
            # A simple value is a pipeline with one CommandExpressionAst.
            $expr = $null
            if ($valueAst -is [System.Management.Automation.Language.PipelineAst] -and
                $valueAst.PipelineElements.Count -eq 1 -and
                $valueAst.PipelineElements[0] -is [System.Management.Automation.Language.CommandExpressionAst]) {
                $expr = $valueAst.PipelineElements[0].Expression
            }
            if ($expr -is [System.Management.Automation.Language.StringConstantExpressionAst] -or
                $expr -is [System.Management.Automation.Language.ExpandableStringExpressionAst]) {
                $value = $expr.Value
                $isString = $true
            }

            $keys[$keyName] = [PSCustomObject]@{
                Value       = $value
                IsString    = $isString
                IsEmpty     = ($isString -and [string]::IsNullOrWhiteSpace($value))
                StartOffset = $valueAst.Extent.StartOffset
                EndOffset   = $valueAst.Extent.EndOffset
            }
        }

        $offset = $assignment.Extent.StartOffset
        $github = $sourceMarkers |
            Where-Object { $_.Type -eq "github" -and $_.Offset -lt $offset } |
            Sort-Object Offset | Select-Object -Last 1
        $winget = $sourceMarkers |
            Where-Object { $_.Type -eq "winget" -and $_.Offset -lt $offset } |
            Sort-Object Offset | Select-Object -Last 1

        $name = $null
        if ($keys.Contains("Name") -and $keys["Name"].IsString) {
            $name = $keys["Name"].Value
        }

        $definitions.Add([PSCustomObject]@{
            File       = "$Path"
            Line       = $assignment.Extent.StartLineNumber
            Name       = $name
            Keys       = $keys
            GitHubRepo = if ($github) { $github.Value } else { $null }
            WingetId   = if ($winget) { $winget.Value } else { $null }
        })
    }

    return $definitions
}
