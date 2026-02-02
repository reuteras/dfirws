param(
    [string]$JsonPath = ".\\downloads\\dfirws\\tools_http.json",
    [string]$DocsRoot = ".\\docs",
    [string]$CategoriesScript = ".\\setup\\utils\\dfirws_folder.ps1"
)

if (! (Test-Path -Path $JsonPath)) {
    throw "Tools JSON not found at $JsonPath. Run resources\\download\\http.ps1 to generate it."
}

$tools_doc = Get-Content -Path $JsonPath -Raw | ConvertFrom-Json
$tools = @()
if ($null -ne $tools_doc.Tools) {
    $tools = $tools_doc.Tools
}

function Get-Slug {
    param([string]$Value)
    if ($null -eq $Value) {
        return "category"
    }
    $slug = $Value.ToLowerInvariant()
    $slug = $slug -replace "[^a-z0-9]+", "-"
    $slug = $slug.Trim("-")
    if ($slug -eq "") {
        $slug = "category"
    }
    return $slug
}

function Get-ToolSummary {
    param($Tool)
    if ($null -ne $Tool.Notes) {
        if ($Tool.Notes -is [System.Array] -and $Tool.Notes.Count -gt 0) {
            $note = $Tool.Notes[0]
            if ($note -ne "") {
                return $note
            }
        }
        if ($Tool.Notes -is [string] -and $Tool.Notes -ne "") {
            return $Tool.Notes
        }
    }
    if ($null -ne $Tool.Usage) {
        if ($Tool.Usage -is [System.Array] -and $Tool.Usage.Count -gt 0) {
            $usage = $Tool.Usage[0]
            if ($usage -ne "") {
                return $usage
            }
        }
        if ($Tool.Usage -is [string] -and $Tool.Usage -ne "") {
            return $Tool.Usage
        }
    }
    return ""
}

function Get-StringList {
    param($Value)
    if ($null -eq $Value) {
        return @()
    }
    if ($Value -is [System.Array]) {
        return $Value
    }
    if ($Value -is [string] -and $Value -ne "") {
        return @($Value)
    }
    return @()
}

function Get-ToolPageSlug {
    param(
        [string]$Name,
        [string]$CategoryPath,
        [hashtable]$UsedSlugs
    )
    $base = "$CategoryPath $Name"
    $slug = Get-Slug $base
    if (! $UsedSlugs.ContainsKey($slug)) {
        $UsedSlugs[$slug] = 1
        return $slug
    }
    $index = $UsedSlugs[$slug] + 1
    $UsedSlugs[$slug] = $index
    return ("{0}-{1}" -f $slug, $index)
}

function Get-CategoryOrder {
    param([string]$Path)
    $order = @()
    if (! (Test-Path -Path $Path)) {
        return $order
    }
    $lines = Get-Content -Path $Path
    foreach ($line in $lines) {
        if ($line -match 'New-Item -Force -ItemType Directory "\$\{HOME\}\\Desktop\\dfirws\\(.+)"') {
            $category_path = $Matches[1]
            if ($category_path -ne "") {
                if ($order -notcontains $category_path) {
                    $order += $category_path
                }
            }
        }
    }
    return $order
}

$category_order = Get-CategoryOrder -Path $CategoriesScript

$grouped = @{}
foreach ($tool in $tools) {
    $category_path = $tool.CategoryPath
    if ($null -eq $category_path -or $category_path -eq "") {
        $category_path = $tool.Category
    }
    if ($null -eq $category_path -or $category_path -eq "") {
        $category_path = "Uncategorized"
    }
    if (! $grouped.ContainsKey($category_path)) {
        $grouped[$category_path] = @()
    }
    $grouped[$category_path] += $tool
}

$ordered_categories = @()
foreach ($category_path in $category_order) {
    if ($grouped.ContainsKey($category_path)) {
        $ordered_categories += $category_path
    }
}
foreach ($category_path in ($grouped.Keys | Sort-Object)) {
    if ($ordered_categories -notcontains $category_path) {
        $ordered_categories += $category_path
    }
}

New-Item -Force -ItemType Directory -Path $DocsRoot | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $DocsRoot "tools") | Out-Null

$tools_index_path = Join-Path $DocsRoot "tools\\index.md"
New-Item -Force -ItemType Directory -Path (Join-Path $DocsRoot "tools\\pages") | Out-Null

$tools_index_lines = @()
$tools_index_lines += "# Tools"
$tools_index_lines += ""
$tools_index_lines += "Categories generated from dfirws shortcuts."
$tools_index_lines += ""
$tools_index_lines += "## Categories"
$tools_index_lines += ""
foreach ($category_path in $ordered_categories) {
    $display_name = $category_path -replace "\\\\", " / "
    $slug = Get-Slug $category_path
    $tools_index_lines += "- [$display_name]($slug.md)"
}
Set-Content -Path $tools_index_path -Value ($tools_index_lines -join "`n")

function Write-ToolPage {
    param(
        $Tool,
        [string]$CategoryPath,
        [string]$Slug
    )
    $page_path = Join-Path $DocsRoot ("tools\\pages\\" + $Slug + ".md")
    $lines = @()
    $lines += "# $($Tool.Name)"
    $lines += ""
    $lines += "**Category:** $($CategoryPath -replace "\\\\", " / ")"
    $lines += ""
    $meta_added = $false
    if ($null -ne $Tool.Homepage -and $Tool.Homepage -ne "") {
        $lines += "**Homepage:** <$($Tool.Homepage)>"
        $lines += ""
        $meta_added = $true
    }
    if ($null -ne $Tool.Vendor -and $Tool.Vendor -ne "") {
        $lines += "**Vendor:** $($Tool.Vendor)"
        $lines += ""
        $meta_added = $true
    }
    if ($null -ne $Tool.License -and $Tool.License -ne "") {
        if ($null -ne $Tool.LicenseUrl -and $Tool.LicenseUrl -ne "") {
            $lines += "**License:** [$($Tool.License)]($($Tool.LicenseUrl))"
        } else {
            $lines += "**License:** $($Tool.License)"
        }
        $meta_added = $true
    } elseif ($null -ne $Tool.LicenseUrl -and $Tool.LicenseUrl -ne "") {
        $lines += "**License:** <$($Tool.LicenseUrl)>"
        $meta_added = $true
    }
    if ($meta_added) {
        $lines += ""
    }
    $summary = Get-ToolSummary -Tool $Tool
    if ($summary -ne "") {
        $lines += $summary
        $lines += ""
    }
    $notes = Get-StringList -Value $Tool.Notes
    if ($notes.Count -gt 0) {
        $lines += "## Notes"
        foreach ($note in $notes) {
            $lines += $note
            $lines += ""
        }
    }
    $tips = Get-StringList -Value $Tool.Tips
    if ($tips.Count -gt 0) {
        $lines += "## Tips"
        foreach ($tip in $tips) {
            $lines += $tip
            $lines += ""
        }
    }
    $usage = Get-StringList -Value $Tool.Usage
    if ($usage.Count -gt 0) {
        $lines += "## Usage"
        foreach ($item in $usage) {
            $lines += $item
            $lines += ""
        }
    }
    $sample_commands = Get-StringList -Value $Tool.SampleCommands
    if ($sample_commands.Count -gt 0) {
        $lines += "## Sample Commands"
        foreach ($command in $sample_commands) {
            $lines += "- ``$command``"
        }
        $lines += ""
    }
    $sample_files = Get-StringList -Value $Tool.SampleFiles
    if ($sample_files.Count -gt 0) {
        $lines += "## Sample Files"
        foreach ($file in $sample_files) {
            $lines += "- $file"
        }
        $lines += ""
    }
    
    Set-Content -Path $page_path -Value ($lines -join "`n")
    return $page_path
}

$tool_page_slugs = @{}

foreach ($category_path in $ordered_categories) {
    $display_name = $category_path -replace "\\\\", " / "
    $slug = Get-Slug $category_path
    $category_file = Join-Path $DocsRoot ("tools\\" + $slug + ".md")
    $lines = @()
    $lines += "# $display_name"
    $lines += ""
    $lines += "| Tool | Description |"
    $lines += "| --- | --- |"
    $tools_in_category = $grouped[$category_path] | Sort-Object Name
    foreach ($tool in $tools_in_category) {
        $tool_slug = Get-ToolPageSlug -Name $tool.Name -CategoryPath $category_path -UsedSlugs $tool_page_slugs
        $tool_page = Write-ToolPage -Tool $tool -CategoryPath $category_path -Slug $tool_slug
        $tool_link = "pages/$tool_slug.md"
        $summary = Get-ToolSummary -Tool $tool
        $summary = $summary -replace "\|", "\|"
        $lines += "| [$($tool.Name)]($tool_link) | $summary |"
    }
    Set-Content -Path $category_file -Value ($lines -join "`n")
}
