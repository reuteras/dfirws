param(
    [string]$JsonPath = ".\\downloads\\dfirws\\tools_http.json",
    [string]$DocsRoot = ".\\docs",
    [string]$CategoriesScript = ".\\setup\\utils\\dfirws_folder.ps1",
    [string]$MkdocsConfigPath = ".\\mkdocs.yml"
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

function Get-NavLabel {
    param([string]$Value)
    if ($null -eq $Value -or $Value -eq "") {
        return "Docs"
    }
    $label = $Value -replace "[-_]+", " "
    $label = $label.Trim()
    if ($label -eq "") {
        return "Docs"
    }
    $words = $label -split "\s+"
    $words = $words | ForEach-Object {
        if ($_.Length -le 1) { $_.ToUpperInvariant() } else { $_.Substring(0,1).ToUpperInvariant() + $_.Substring(1) }
    }
    return ($words -join " ")
}

function Get-DocsNavLines {
    param(
        [string]$RootPath,
        [string]$RelativePath = "",
        [int]$Indent = 2
    )
    $lines = @()
    $current_path = $RootPath
    if ($RelativePath -ne "") {
        $current_path = Join-Path $RootPath $RelativePath
    }
    if (! (Test-Path -Path $current_path)) {
        return $lines
    }

    $indent_text = " " * $Indent
    $index_file = Join-Path $current_path "index.md"
    $files = Get-ChildItem -Path $current_path -File -Filter "*.md" | Where-Object { $_.Name -ne "index.md" } | Sort-Object Name
    $dirs = Get-ChildItem -Path $current_path -Directory | Sort-Object Name

    if (Test-Path -Path $index_file) {
        $rel = if ($RelativePath -eq "") { "index.md" } else { ($RelativePath + "/index.md") }
        $label = if ($RelativePath -eq "") { "Home" } else { "Overview" }
        $lines += ("{0}- {1}: {2}" -f $indent_text, $label, $rel)
    }

    foreach ($file in $files) {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $label = Get-NavLabel -Value $name
        $rel = if ($RelativePath -eq "") { $file.Name } else { ($RelativePath + "/" + $file.Name) }
        $lines += ("{0}- {1}: {2}" -f $indent_text, $label, $rel)
    }

    foreach ($dir in $dirs) {
        $dir_label = Get-NavLabel -Value $dir.Name
        $lines += ("{0}- {1}:" -f $indent_text, $dir_label)
        $next_rel = if ($RelativePath -eq "") { $dir.Name } else { ($RelativePath + "/" + $dir.Name) }
        $lines += Get-DocsNavLines -RootPath $RootPath -RelativePath $next_rel -Indent ($Indent + 2)
    }

    return $lines
}

function Get-ToolsNavLines {
    param(
        [string]$DocsRootPath,
        [int]$Indent = 2
    )
    $lines = @()
    $indent_text = " " * $Indent
    $tools_root = Join-Path $DocsRootPath "tools"
    if (! (Test-Path -Path $tools_root)) {
        return $lines
    }

    $lines += ("{0}- Tools:" -f $indent_text)
    $tools_indent = " " * ($Indent + 2)
    $index_path = Join-Path $tools_root "index.md"
    if (Test-Path -Path $index_path) {
        $lines += ("{0}- Overview: tools/index.md" -f $tools_indent)
    }

    $category_files = Get-ChildItem -Path $tools_root -File -Filter "*.md" | Where-Object { $_.Name -ne "index.md" } | Sort-Object Name
    $pages_root = Join-Path $tools_root "pages"
    $tool_pages = @()
    if (Test-Path -Path $pages_root) {
        $tool_pages = Get-ChildItem -Path $pages_root -File -Filter "*.md" | Sort-Object Name
    }

    foreach ($file in $category_files) {
        $category_slug = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $category_label = Get-NavLabel -Value $category_slug
        $lines += ("{0}- {1}:" -f $tools_indent, $category_label)
        $lines += ("{0}- Overview: tools/{1}.md" -f (" " * ($Indent + 4)), $category_slug)

        if ($tool_pages.Count -gt 0) {
            $prefix = $category_slug + "-"
            $matching = $tool_pages | Where-Object { $_.Name.StartsWith($prefix) } | Sort-Object Name
            foreach ($page in $matching) {
                $page_slug = [System.IO.Path]::GetFileNameWithoutExtension($page.Name)
                $tail = $page_slug.Substring($prefix.Length)
                $tool_label = Get-NavLabel -Value $tail
                $lines += ("{0}- {1}: tools/pages/{2}.md" -f (" " * ($Indent + 4)), $tool_label, $page_slug)
            }
        }
    }

    return $lines
}

function Update-MkDocsNav {
    param(
        [string]$ConfigPath,
        [string]$DocsRootPath
    )
    if (! (Test-Path -Path $ConfigPath)) {
        Write-Output "mkdocs.yml not found at $ConfigPath. Skipping nav update."
        return
    }

    $existing = Get-Content -Path $ConfigPath
    $before = @()
    $after = @()
    $in_nav = $false
    $found_nav = $false
    $in_loose_nav = $false
    foreach ($line in $existing) {
        if (! $in_nav) {
            if ($line -match '^\s*nav\s*:') {
                $in_nav = $true
                $found_nav = $true
                continue
            }
            if (! $found_nav -and ! $in_loose_nav -and $line -match '^- ') {
                $in_loose_nav = $true
                continue
            }
            if ($in_loose_nav) {
                if ($line -match '^\S' -and $line -notmatch '^- ') {
                    $in_loose_nav = $false
                    $after += $line
                }
                continue
            }
            $before += $line
            continue
        }
        if ($line -match '^\S') {
            $in_nav = $false
            $after += $line
        }
    }
    if ($in_nav) {
        $in_nav = $false
    }
    if ($in_loose_nav) {
        $in_loose_nav = $false
    }

    $nav_lines = @("nav:")
    $root_index = Join-Path $DocsRootPath "index.md"
    if (Test-Path -Path $root_index) {
        $nav_lines += "- Home: index.md"
    }

    $top_files = Get-ChildItem -Path $DocsRootPath -File -Filter "*.md" | Where-Object { $_.Name -ne "index.md" } | Sort-Object Name
    foreach ($file in $top_files) {
        $label = Get-NavLabel -Value ([System.IO.Path]::GetFileNameWithoutExtension($file.Name))
        $nav_lines += ("- {0}: {1}" -f $label, $file.Name)
    }

    $top_dirs = Get-ChildItem -Path $DocsRootPath -Directory | Sort-Object Name
    foreach ($dir in $top_dirs) {
        if ($dir.Name -eq "tools") {
            $nav_lines += Get-ToolsNavLines -DocsRootPath $DocsRootPath
            continue
        }
        $nav_lines += ("- {0}:" -f (Get-NavLabel -Value $dir.Name))
        $nav_lines += Get-DocsNavLines -RootPath $DocsRootPath -RelativePath $dir.Name -Indent 2
    }

    $output = @()
    $output += $before
    if ($output.Count -gt 0 -and $output[-1] -ne "") {
        $output += ""
    }
    $output += $nav_lines
    if ($after.Count -gt 0) {
        $output += ""
        $output += $after
    }
    Set-Content -Path $ConfigPath -Value ($output -join "`n")
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

$ordered_categories = $grouped.Keys | Sort-Object

New-Item -Force -ItemType Directory -Path $DocsRoot | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $DocsRoot "tools") | Out-Null

$tools_index_path = Join-Path $DocsRoot "tools\\index.md"
New-Item -Force -ItemType Directory -Path (Join-Path $DocsRoot "tools\\pages") | Out-Null

$tools_index_lines = @()
$tools_index_lines += "# Categories"
$tools_index_lines += ""
$tools_index_lines += "Categories generated from dfirws shortcuts."
$tools_index_lines += ""
$tools_index_lines += "## Categories Index"
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

Update-MkDocsNav -ConfigPath $MkdocsConfigPath -DocsRootPath $DocsRoot
