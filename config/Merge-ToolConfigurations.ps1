<#
.SYNOPSIS
    Combines multiple tool configuration files into a single master configuration with schema validation.

.DESCRIPTION
    This script reads multiple category-specific tool configuration files,
    validates them against a JSON schema, and combines them into a single master 
    configuration file for use with the Invoke-ToolsDownload.ps1 script.

.PARAMETER InputDirectory
    Directory containing the category-specific configuration files.

.PARAMETER OutputFile
    Path to output the combined configuration file.

.PARAMETER SchemaFile
    Path to the JSON schema file for validation.

.PARAMETER StrictValidation
    If set, the script will exit with an error if any configuration files fail validation.
    Default is to warn about invalid files but continue with the merge.

.EXAMPLE
    .\Merge-ToolConfigurations.ps1 -InputDirectory .\config -OutputFile .\config\downloads-config.json

.NOTES
    File Name      : Merge-ToolConfigurations.ps1
    Author         : DFIRWS Project
    Prerequisite   : PowerShell 5.1 or higher
    Version        : 1.1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$InputDirectory = ".\config",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = ".\config\downloads-config.json",
    
    [Parameter(Mandatory=$false)]
    [string]$SchemaFile = ".\config\downloads-config-schema.json",
    
    [Parameter(Mandatory=$false)]
    [switch]$StrictValidation
)

function Test-JsonWithSchema {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$JsonPath,
        
        [Parameter(Mandatory=$true)]
        [string]$SchemaPath
    )
    
    # Check if we have PowerShell 6.0+ with built-in Test-Json schema validation
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        Write-Verbose "Using PowerShell Core's Test-Json for schema validation"
        try {
            $schema = Get-Content -Path $SchemaPath -Raw
            $result = Get-Content -Path $JsonPath -Raw | Test-Json -Schema $schema -ErrorAction Stop
            return @{
                IsValid = $result
                Errors = $null
            }
        }
        catch {
            return @{
                IsValid = $false
                Errors = $_.Exception.Message
            }
        }
    }
    else {
        # For PowerShell 5.1, use a custom validator implementation
        Write-Verbose "Using custom schema validation for PowerShell 5.1"
        
        try {
            $jsonContent = Get-Content -Path $JsonPath -Raw | ConvertFrom-Json
            $schema = Get-Content -Path $SchemaPath -Raw | ConvertFrom-Json
            
            # Implement basic schema validation
            $errors = @()
            
            # Check if tools property exists and is an array
            if (-not ($jsonContent.PSObject.Properties.Name -contains "tools")) {
                $errors += "Missing required 'tools' property"
            }
            elseif ($jsonContent.tools -isnot [Array]) {
                $errors += "'tools' property must be an array"
            }
            else {
                # Validate each tool in the array
                foreach ($tool in $jsonContent.tools) {
                    $toolErrors = @()
                    
                    # Required properties check
                    $requiredProps = @("name", "type", "source", "destination")
                    foreach ($prop in $requiredProps) {
                        if (-not ($tool.PSObject.Properties.Name -contains $prop)) {
                            $toolErrors += "Tool '$($tool.name)' is missing required property: $prop"
                        }
                    }
                    
                    # Enum validation for type
                    if ($tool.PSObject.Properties.Name -contains "type") {
                        $validTypes = @("github", "http", "winget", "didier", "vscode-extension", "custom", "git", "powershell-module")
                        if ($validTypes -notcontains $tool.type) {
                            $toolErrors += "Tool '$($tool.name)' has invalid type: $($tool.type). Valid types: $($validTypes -join ', ')"
                        }
                    }
                    
                    # Category validation if present
                    if ($tool.PSObject.Properties.Name -contains "category") {
                        $validCategories = @("forensics", "development", "utilities", "analysis", "reversing", "network")
                        if ($validCategories -notcontains $tool.category) {
                            $toolErrors += "Tool '$($tool.name)' has invalid category: $($tool.category). Valid categories: $($validCategories -join ', ')"
                        }
                    }
                    
                    # Add tool errors to the main errors array
                    $errors += $toolErrors
                }
            }
            
            return @{
                IsValid = ($errors.Count -eq 0)
                Errors = $errors
            }
        }
        catch {
            return @{
                IsValid = $false
                Errors = @("Error parsing JSON: $($_.Exception.Message)")
            }
        }
    }
}

function Add-IncludedConfigurations {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ConfigPath,
        
        [Parameter(Mandatory=$true)]
        [ref]$ConfigFilesRef
    )
    
    try {
        $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        
        # If the config has an "include" property, add those files to the list
        if ($config.include) {
            foreach ($includeFile in $config.include) {
                $fullPath = Join-Path -Path (Split-Path -Parent $ConfigPath) -ChildPath $includeFile
                
                if (Test-Path $fullPath) {
                    # Add the included file to the list if it's not already there
                    if ($ConfigFilesRef.Value.FullName -notcontains $fullPath) {
                        $fileInfo = Get-Item -Path $fullPath
                        $ConfigFilesRef.Value += $fileInfo
                        
                        # Recursively process any includes in this file
                        Add-IncludedConfigurations -ConfigPath $fullPath -ConfigFilesRef $ConfigFilesRef
                    }
                }
                else {
                    Write-Warning "Included file not found: $includeFile (referenced in $ConfigPath)"
                }
            }
        }
    }
    catch {
        Write-Warning "Error processing includes in ${ConfigPath}: $_"
    }
}

# Ensure the output directory exists
$outputDir = Split-Path -Parent $OutputFile
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
}

# Check if schema file exists
if (!(Test-Path $SchemaFile)) {
    Write-Warning "Schema file not found at $SchemaFile - validation will be skipped"
    $SchemaFile = $null
}

# Get all JSON files in the input directory
$configFiles = @(Get-ChildItem -Path $InputDirectory -Filter "*.json" | 
                Where-Object { $_.Name -ne (Split-Path -Leaf $OutputFile) -and 
                               $_.Name -ne (Split-Path -Leaf $SchemaFile) })

# Find and process main config file with includes first
$mainConfigFile = $configFiles | Where-Object { $_.Name -eq "dfirws-tools.json" } | Select-Object -First 1

if ($mainConfigFile) {
    Write-Host "Found main configuration file: $($mainConfigFile.Name)"
    
    # Create a new array with the main config file first
    $processedFiles = @($mainConfigFile)
    
    # Process includes
    Add-IncludedConfigurations -ConfigPath $mainConfigFile.FullName -ConfigFilesRef ([ref]$processedFiles)
    
    # Add any other files not included by the main config
    $configFiles | Where-Object { $processedFiles.FullName -notcontains $_.FullName } | ForEach-Object {
        $processedFiles += $_
    }
    
    # Use the processed files as our config files
    $configFiles = $processedFiles
}

if ($configFiles.Count -eq 0) {
    Write-Warning "No configuration files found in $InputDirectory"
    exit 1
}

Write-Host "Found $($configFiles.Count) configuration files to process:"
$configFiles | ForEach-Object { Write-Host "  - $($_.Name)" }

# Validate each config file against the schema
$validFiles = @()
$invalidFiles = @()

foreach ($file in $configFiles) {
    Write-Host "Validating $($file.Name)..."
    
    if ($SchemaFile) {
        $validationResult = Test-JsonWithSchema -JsonPath $file.FullName -SchemaPath $SchemaFile
        
        if ($validationResult.IsValid) {
            Write-Host "  Validation successful" -ForegroundColor Green
            $validFiles += $file
        }
        else {
            Write-Host "  Validation failed:" -ForegroundColor Red
            foreach ($error in $validationResult.Errors) {
                Write-Host "    - $error" -ForegroundColor Red
            }
            $invalidFiles += $file
        }
    }
    else {
        # Basic JSON parsing check if no schema is available
        try {
            Get-Content -Path $file.FullName -Raw | ConvertFrom-Json | Out-Null
            Write-Host "  Basic JSON syntax check passed" -ForegroundColor Green
            $validFiles += $file
        }
        catch {
            Write-Host "  Invalid JSON syntax: $_" -ForegroundColor Red
            $invalidFiles += $file
        }
    }
}

# Exit if strict validation is enabled and there are invalid files
if ($StrictValidation -and $invalidFiles.Count -gt 0) {
    Write-Error "Validation failed for $($invalidFiles.Count) file(s). Use -Verbose for details."
    exit 1
}

# Initialize the combined configuration
$combinedConfig = @{
    tools = @()
}

# Process each valid config file
foreach ($file in $validFiles) {
    Write-Host "Processing $($file.Name)..."
    
    try {
        $config = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        
        # Skip files that are just include containers
        if ($config.PSObject.Properties.Name -contains "include" -and 
            (-not ($config.PSObject.Properties.Name -contains "tools") -or $config.tools.Count -eq 0)) {
            Write-Host "  Skipping include container file" -ForegroundColor Yellow
            continue
        }
        
        if ($config.tools) {
            $combinedConfig.tools += $config.tools
            Write-Host "  Added $($config.tools.Count) tools from $($file.Name)"
        }
        else {
            Write-Warning "  No tools found in $($file.Name)"
        }
    }
    catch {
        Write-Error "Error processing $($file.Name): $_"
    }
}

# Check for duplicate tool names
$toolNameGroups = $combinedConfig.tools | 
                 Where-Object { $_ -ne $null -and $_.name -ne $null } |
                 Group-Object -Property name

$duplicates = $toolNameGroups | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name

if ($duplicates) {
    Write-Warning "Duplicate tool names found:"
    $duplicates | ForEach-Object { 
        Write-Warning "  - $_"
        
        # Show which files contain each duplicate
        $toolName = $_
        foreach ($file in $validFiles) {
            $fileJson = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
            if ($fileJson.tools | Where-Object { $_.name -eq $toolName }) {
                Write-Warning "    Found in: $($file.Name)"
            }
        }
    }
    
    if ($StrictValidation) {
        Write-Error "Duplicate tool names found. Use -Verbose for details."
        exit 1
    }
}

# Check for tools missing required properties
$invalidTools = @()
foreach ($tool in $combinedConfig.tools) {
    $requiredProps = @("name", "type", "source", "destination")
    $missingProps = $requiredProps | Where-Object { 
        -not ($tool.PSObject.Properties.Name -contains $_) -or 
        [string]::IsNullOrEmpty($tool.$_)
    }
    
    if ($missingProps) {
        $invalidTools += @{
            Name = $tool.name
            MissingProperties = $missingProps
        }
    }
}

if ($invalidTools) {
    Write-Warning "Found tools with missing required properties:"
    foreach ($tool in $invalidTools) {
        Write-Warning "  - $($tool.Name): Missing $($tool.MissingProperties -join ', ')"
    }
    
    if ($StrictValidation) {
        Write-Error "Tools with missing required properties found. Use -Verbose for details."
        exit 1
    }
}

# Write the combined configuration to the output file
try {
    $combinedConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputFile
    Write-Host "Combined configuration written to $OutputFile with $($combinedConfig.tools.Count) tools" -ForegroundColor Green
}
catch {
    Write-Error "Error writing combined configuration: $_"
    exit 1
}

# Perform a final validation on the combined output
if ($SchemaFile) {
    Write-Host "Validating final combined configuration..."
    $finalValidation = Test-JsonWithSchema -JsonPath $OutputFile -SchemaPath $SchemaFile
    
    if ($finalValidation.IsValid) {
        Write-Host "Final validation successful" -ForegroundColor Green
    }
    else {
        Write-Host "Final validation failed:" -ForegroundColor Red
        foreach ($error in $finalValidation.Errors) {
            Write-Host "  - $error" -ForegroundColor Red
        }
        
        if ($StrictValidation) {
            Write-Error "Final validation failed. Use -Verbose for details."
            exit 1
        }
    }
}

Write-Host "Configuration merge completed successfully" -ForegroundColor Green

# Print a summary
Write-Host "`nSummary:"
Write-Host "  - Total files processed: $($configFiles.Count)"
Write-Host "  - Valid files: $($validFiles.Count)"
Write-Host "  - Invalid files: $($invalidFiles.Count)"
Write-Host "  - Total tools in combined config: $($combinedConfig.tools.Count)"
Write-Host "  - Output file: $OutputFile"
