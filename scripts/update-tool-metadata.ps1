# Fills empty Homepage/Vendor/License/LicenseUrl fields in $TOOL_DEFINITIONS
# blocks from authoritative sources:
#   - release.ps1 (and any file using Get-GitHubRelease): the GitHub repo of the
#     nearest preceding Get-GitHubRelease call
#   - git.ps1: the $repourls entry whose basename matches the tool name
#   - winget.ps1: the cached `winget show` metadata in downloads/.metadata/winget/
#   - install_python_tools.ps1: PyPI metadata for the tool Name (needs network; when
#     the project links a GitHub repo, license facts come from that repo)
#   - install_node.ps1: npm registry metadata for the tool Name (needs network)
#   - install_rust_tools.ps1: crates.io metadata for the tool Name (needs network)
#
# Data sources, in order:
#   1. Cached downloads/.metadata/github/<owner_repo>.json and
#      downloads/.metadata/winget/<AppId>.json (populated on the Windows box by
#      every download run - no network needed)
#   2. GitHub API fallback (uses $GITHUB_TOKEN from dfirws-config.ps1 when set;
#      skip with -NoApi)
#
# Default mode prints a report of proposed values. -Apply splices them into the
# script files, only ever replacing values that are exactly "".
# Usage/Tips/Notes are intentionally never generated - they are human-authored.
#
# Run: pwsh ./scripts/update-tool-metadata.ps1 [-Apply] [-NoApi]

param (
    [switch]$Apply,
    [switch]$NoApi
)

Set-StrictMode -Version Latest

. "$PSScriptRoot/lib/Get-ToolDefinitionAst.ps1"

$repoRoot = Resolve-Path "$PSScriptRoot/.."
$fillKeys = @("Homepage", "Vendor", "License", "LicenseUrl")

# GitHub credentials from dfirws-config.ps1 (same convention as downloadFiles.ps1).
$GITHUB_TOKEN = ""
if (Test-Path (Join-Path $repoRoot "dfirws-config.ps1")) {
    . (Join-Path $repoRoot "dfirws-config.ps1")
}
$apiHeaders = @{ "User-Agent" = "dfirws-metadata-updater" }
if ($GITHUB_TOKEN -and $GITHUB_TOKEN -ne "YOUR GITHUB TOKEN") {
    $apiHeaders["Authorization"] = "token $GITHUB_TOKEN"
}

$script:apiBudgetExhausted = $false

$script:githubFactsCache = @{}

# Queries the GitHub license endpoint. Returns @{Found; Spdx; Url}: Found=$false when the repo
# has no license file (404), Spdx is $null when the license is not a recognised SPDX one.
# Returns $null when the answer is unknown (-NoApi, rate limit or other API failure).
function Get-GitHubLicenseInfo {
    param([string]$Repo)

    if ($NoApi -or $script:apiBudgetExhausted) {
        return $null
    }
    try {
        $licenseData = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/license" -Headers $apiHeaders -ErrorAction Stop
        $spdx = $null
        if ($licenseData.license -and $licenseData.license.spdx_id -and $licenseData.license.spdx_id -ne "NOASSERTION") {
            $spdx = $licenseData.license.spdx_id
        }
        return [PSCustomObject]@{ Found = $true; Spdx = $spdx; Url = $licenseData.html_url }
    } catch {
        $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
        if ($status -in @(403, 429)) {
            Write-Warning "GitHub API rate limit hit - remaining repos use cache only. Set GITHUB_TOKEN in dfirws-config.ps1 to raise the limit."
            $script:apiBudgetExhausted = $true
        } elseif ($status -eq 404) {
            return [PSCustomObject]@{ Found = $false; Spdx = $null; Url = $null }
        }
        return $null
    }
}

# Returns @{Homepage; Vendor; License; LicenseUrl; Origin} for a GitHub repo,
# from the local metadata cache when present, otherwise from the GitHub API.
# The cache stores only the generic SPDX API URL, so LicenseUrl always comes from the
# license endpoint (when the repo has a detectable license).
function Get-GitHubRepoFacts {
    param([string]$Repo)

    if ($script:githubFactsCache.ContainsKey($Repo)) {
        return $script:githubFactsCache[$Repo]
    }

    $facts = $null
    $safeRepo = $Repo -replace "/", "_"
    $cacheFile = Join-Path $repoRoot "downloads/.metadata/github/$safeRepo.json"
    if (Test-Path $cacheFile) {
        try {
            $data = Get-Content $cacheFile -Raw | ConvertFrom-Json
            $license = $null
            if ($data.PSObject.Properties["License"] -and $data.License -and
                $data.License.SpdxId -and $data.License.SpdxId -ne "NOASSERTION") {
                $license = $data.License.SpdxId
            }
            $facts = [PSCustomObject]@{
                Homepage   = if ($data.Homepage) { $data.Homepage } else { $data.HtmlUrl }
                Vendor     = $data.Owner
                License    = $license
                LicenseUrl = $null
                Origin     = "cache"
            }
        } catch { }
    }

    if ($null -eq $facts -and -not $NoApi -and -not $script:apiBudgetExhausted) {
        try {
            $data = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo" -Headers $apiHeaders -ErrorAction Stop
            $license = $null
            if ($data.license -and $data.license.spdx_id -and $data.license.spdx_id -ne "NOASSERTION") {
                $license = $data.license.spdx_id
            }
            $facts = [PSCustomObject]@{
                Homepage   = if ($data.homepage) { $data.homepage } else { $data.html_url }
                Vendor     = $data.owner.login
                License    = $license
                LicenseUrl = $null
                Origin     = "api"
            }
        } catch {
            if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -in @(403, 429)) {
                Write-Warning "GitHub API rate limit hit - remaining repos use cache only. Set GITHUB_TOKEN in dfirws-config.ps1 to raise the limit."
                $script:apiBudgetExhausted = $true
            }
        }
    }

    if ($null -ne $facts) {
        $licenseInfo = Get-GitHubLicenseInfo -Repo $Repo
        if ($null -ne $licenseInfo) {
            if ($licenseInfo.Found) {
                $facts.LicenseUrl = $licenseInfo.Url
                if (-not $facts.License) {
                    # A license file exists but is not a recognised SPDX license.
                    $facts.License = if ($licenseInfo.Spdx) { $licenseInfo.Spdx } else { "See repository" }
                }
            } else {
                # No single license file GitHub can detect (none at all, or e.g. dual LICENSE-MIT /
                # LICENSE-APACHE files): don't claim there is no license, point at the repository.
                $facts.LicenseUrl = "https://github.com/$Repo"
                if (-not $facts.License) { $facts.License = "See repository" }
            }
        }
    }
    $script:githubFactsCache[$Repo] = $facts
    return $facts
}

# Returns a property value, or $null when the object or property does not exist (StrictMode safe).
function Get-OptionalProperty {
    param($Object, [string]$Name)

    if ($null -eq $Object -or $Object -is [string]) { return $null }
    $prop = $Object.PSObject.Properties[$Name]
    if ($prop) { return $prop.Value }
    return $null
}

# Maps the free-form license strings used by package registries onto the SPDX style used
# elsewhere in the metadata ("MIT", "Apache-2.0", "GPL-3.0"). Unknown values pass through,
# except URLs and "non-standard", which are replaced by "See repository".
function ConvertTo-LicenseName {
    param([string]$License)

    if ([string]::IsNullOrWhiteSpace($License)) { return $null }
    $value = $License.Trim()
    switch -Regex ($value) {
        '^MIT( Licen[cs]e)?$'                                   { return "MIT" }
        '^(Apache([- ]License)?[- ,(]*(v|version )?2(\.0)?\)?|ASL 2\.0|Apache License,? Version 2\.0)$' { return "Apache-2.0" }
        '^(GPLv3|GPL-3\.0 licen[cs]e|GNU General Public License v3( \(GPLv3\))?|GNU GPL v3)$' { return "GPL-3.0" }
        '^(GPLv2|GNU GPL v2|GNU General Public License v2( \(GPLv2\))?)$' { return "GPL-2.0" }
        '^BSD Licen[cs]e$'                                      { return "BSD" }
        '^Python Software Foundation License$'                  { return "PSF-2.0" }
        '^https?://'                                            { return "See repository" }
        '^non-standard$'                                        { return "See repository" }
        default                                                 { return $value }
    }
}

# Extracts owner/name from the first GitHub repository URL found in the given strings.
function Find-GitHubRepo {
    param([string[]]$Urls)

    foreach ($url in $Urls) {
        if ($url -match '^https?://(?:www\.)?github\.com/([^/\s]+)/([^/\s#?]+?)(?:\.git)?(?:[/#?].*)?$') {
            return "$($Matches[1])/$($Matches[2])"
        }
    }
    return $null
}

# Facts for a package on PyPI, completed from its GitHub repo when one is linked.
function Get-PyPIFacts {
    param([string]$Package)

    if ($NoApi) { return $null }
    try {
        $data = Invoke-RestMethod -Uri "https://pypi.org/pypi/$([uri]::EscapeDataString($Package))/json" -ErrorAction Stop
    } catch {
        return $null
    }
    $info = $data.info
    $urls = @()
    if ($info.project_urls) {
        foreach ($label in "Homepage", "Home", "Source", "Source Code", "Repository", "Code", "GitHub", "Documentation") {
            $prop = $info.project_urls.PSObject.Properties[$label]
            if ($prop -and $prop.Value) { $urls += $prop.Value }
        }
        $urls += @($info.project_urls.PSObject.Properties | ForEach-Object { $_.Value })
    }
    if ($info.home_page) { $urls = @($info.home_page) + $urls }
    $urls = @($urls | Where-Object { $_ -match '^https?://' })

    $repo = Find-GitHubRepo -Urls $urls
    $gh = if ($repo) { Get-GitHubRepoFacts -Repo $repo } else { $null }

    $license = $null
    if ($info.PSObject.Properties["license_expression"] -and $info.license_expression) {
        $license = $info.license_expression
    } elseif ($info.license -and $info.license.Length -le 40 -and $info.license -notmatch "\n") {
        $license = $info.license
    } else {
        $classifier = @($info.classifiers | Where-Object { $_ -like "License :: OSI Approved :: *" }) | Select-Object -First 1
        if ($classifier) { $license = ($classifier -split " :: ")[-1] }
    }
    if (-not $license -and $gh) { $license = $gh.License }

    $vendor = $null
    if ($gh -and $gh.Vendor) {
        $vendor = $gh.Vendor
    } elseif ($info.author -and $info.author -notmatch "@") {
        $vendor = $info.author
    } elseif ($info.maintainer -and $info.maintainer -notmatch "@") {
        $vendor = $info.maintainer
    } elseif ($info.author_email -and $info.author_email -match '^(?:"?([^"<]+?)"?\s*<|([^@\s]+)@)') {
        $vendor = if ($Matches[1]) { $Matches[1] } else { $Matches[2] }
    }

    return [PSCustomObject]@{
        Homepage   = if ($urls.Count -gt 0) { $urls[0] } else { $info.package_url }
        Vendor     = $vendor
        License    = $license
        LicenseUrl = if ($gh -and $gh.LicenseUrl) { $gh.LicenseUrl } else { "https://pypi.org/project/$Package/" }
        Origin     = "pypi"
    }
}

# Facts for a package in the npm registry, completed from its GitHub repo when linked.
function Get-NpmFacts {
    param([string]$Package)

    if ($NoApi) { return $null }
    try {
        $data = Invoke-RestMethod -Uri "https://registry.npmjs.org/$($Package -replace '/', '%2F')" -ErrorAction Stop
    } catch {
        return $null
    }
    # Registry documents omit fields freely and StrictMode rejects missing properties.
    $repository = Get-OptionalProperty -Object $data -Name "repository"
    $homepage = Get-OptionalProperty -Object $data -Name "homepage"
    $licenseField = Get-OptionalProperty -Object $data -Name "license"
    $author = Get-OptionalProperty -Object $data -Name "author"
    $authorName = if ($author -is [string]) { $author } else { Get-OptionalProperty -Object $author -Name "name" }

    $repoUrl = $null
    if ($repository) {
        $repoUrl = if ($repository -is [string]) { $repository } else { Get-OptionalProperty -Object $repository -Name "url" }
        $repoUrl = "$repoUrl" -replace '^git\+', '' -replace '^git://', 'https://' -replace '^ssh://git@', 'https://'
    }
    $repo = Find-GitHubRepo -Urls @($repoUrl, $homepage)
    $gh = if ($repo) { Get-GitHubRepoFacts -Repo $repo } else { $null }
    $license = if ($licenseField -is [string]) { $licenseField } elseif ($licenseField) { Get-OptionalProperty -Object $licenseField -Name "type" } else { $null }
    if (-not $license -and $gh) { $license = $gh.License }

    return [PSCustomObject]@{
        Homepage   = if ($homepage) { $homepage } else { "https://www.npmjs.com/package/$Package" }
        Vendor     = if ($gh -and $gh.Vendor) { $gh.Vendor } elseif ($authorName) { $authorName } else { $null }
        License    = $license
        LicenseUrl = if ($gh -and $gh.LicenseUrl) { $gh.LicenseUrl } else { "https://www.npmjs.com/package/$Package" }
        Origin     = "npm"
    }
}

# Facts for a crate on crates.io, completed from its GitHub repo when linked.
function Get-CratesFacts {
    param([string]$Crate)

    if ($NoApi) { return $null }
    try {
        $data = Invoke-RestMethod -Uri "https://crates.io/api/v1/crates/$Crate" -Headers @{ "User-Agent" = "dfirws-metadata-updater" } -ErrorAction Stop
    } catch {
        return $null
    }
    $info = $data.crate
    $repo = Find-GitHubRepo -Urls @($info.repository, $info.homepage)
    $gh = if ($repo) { Get-GitHubRepoFacts -Repo $repo } else { $null }
    $license = $null
    $latest = @($data.versions) | Select-Object -First 1
    if ($latest -and $latest.license) { $license = $latest.license }
    if (-not $license -and $gh) { $license = $gh.License }

    return [PSCustomObject]@{
        Homepage   = if ($info.homepage) { $info.homepage } elseif ($info.repository) { $info.repository } else { "https://crates.io/crates/$Crate" }
        Vendor     = if ($gh -and $gh.Vendor) { $gh.Vendor } else { $null }
        License    = $license
        LicenseUrl = if ($gh -and $gh.LicenseUrl) { $gh.LicenseUrl } else { "https://crates.io/crates/$Crate" }
        Origin     = "crates.io"
    }
}

# Returns facts for a winget AppId from the local metadata cache (winget itself
# is only available on the Windows box).
function Get-WingetFacts {
    param([string]$AppId)

    $cacheFile = Join-Path $repoRoot "downloads/.metadata/winget/$AppId.json"
    if (-not (Test-Path $cacheFile)) {
        return $null
    }
    try {
        $data = Get-Content $cacheFile -Raw | ConvertFrom-Json
        $get = { param($key) if ($data.PSObject.Properties[$key]) { $data.$key } else { $null } }
        return [PSCustomObject]@{
            Homepage   = & $get "Homepage"
            Vendor     = & $get "Publisher"
            License    = & $get "License"
            LicenseUrl = & $get "LicenseUrl"
            Origin     = "winget-cache"
        }
    } catch {
        return $null
    }
}

# Maps repo basenames (lowercased, without .git) to owner/name for git.ps1.
function Get-GitRepoBasenames {
    param([string]$Path)

    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path $Path), [ref]$null, [ref]$parseErrors)
    $map = @{}
    $strings = $ast.FindAll({ param($node)
        $node -is [System.Management.Automation.Language.StringConstantExpressionAst] -and
        $node.Value -match '^https://github\.com/[^/]+/[^/]+' }, $true)
    foreach ($s in $strings) {
        if ($s.Value -match '^https://github\.com/([^/]+)/([^/]+?)(\.git)?/?$') {
            $map[$Matches[2].ToLower()] = "$($Matches[1])/$($Matches[2])"
        }
    }
    return $map
}

# Escapes a value for splicing into a double-quoted PowerShell string literal.
function ConvertTo-QuotedLiteral {
    param([string]$Value)
    $escaped = $Value -replace '`', '``' -replace '"', '`"' -replace '\$', '`$'
    return "`"$escaped`""
}

$proposals = [System.Collections.Generic.List[PSCustomObject]]::new()
$unmatched = [System.Collections.Generic.List[string]]::new()
$backlog = @{}

$scanFiles = @(
    Get-ChildItem -Path (Join-Path $repoRoot "resources/download") -Filter "*.ps1"
    Get-ChildItem -Path (Join-Path $repoRoot "setup/install") -Filter "*.ps1"
)
foreach ($file in $scanFiles) {
    $definitions = @(Get-ToolDefinitionsFromFile -Path $file.FullName)
    if ($definitions.Count -eq 0) {
        continue
    }

    $gitRepoMap = @{}
    if ($file.Name -eq "git.ps1") {
        $gitRepoMap = Get-GitRepoBasenames -Path $file.FullName
    }

    foreach ($def in $definitions) {
        if (-not $def.Name) {
            continue
        }

        foreach ($key in @("Usage", "Tips")) {
            if (-not $def.Keys.Contains($key) -or $def.Keys[$key].IsEmpty) {
                if (-not $backlog.ContainsKey($file.Name)) { $backlog[$file.Name] = 0 }
                $backlog[$file.Name]++
            }
        }

        $emptyKeys = $fillKeys | Where-Object { $def.Keys.Contains($_) -and $def.Keys[$_].IsEmpty }
        if (-not $emptyKeys) {
            continue
        }

        $facts = $null
        if ($def.GitHubRepo) {
            $facts = Get-GitHubRepoFacts -Repo $def.GitHubRepo
        } elseif ($file.Name -eq "git.ps1") {
            # Match the tool name against repo basenames (spaces/underscores vs hyphens).
            $repo = $null
            $candidates = @(
                $def.Name.ToLower(),
                ($def.Name.ToLower() -replace "[ _]", "-")
            ) | Select-Object -Unique
            foreach ($candidate in $candidates) {
                if ($gitRepoMap.ContainsKey($candidate)) {
                    $repo = $gitRepoMap[$candidate]
                    break
                }
            }
            if ($null -eq $repo -and $def.Keys.Contains("Homepage") -and $def.Keys["Homepage"].IsString) {
                $repo = Find-GitHubRepo -Urls @($def.Keys["Homepage"].Value)
            }
            if ($null -eq $repo) {
                $unmatched.Add("$($file.Name):$($def.Line) ($($def.Name)): no matching repo URL found - fill manually")
                continue
            }
            $facts = Get-GitHubRepoFacts -Repo $repo
        } elseif ($def.WingetId) {
            $facts = Get-WingetFacts -AppId $def.WingetId
        } elseif ($file.Name -eq "install_python_tools.ps1") {
            $facts = Get-PyPIFacts -Package $def.Name
        } elseif ($file.Name -eq "install_node.ps1") {
            $facts = Get-NpmFacts -Package $def.Name
        } elseif ($file.Name -eq "install_rust_tools.ps1") {
            $facts = Get-CratesFacts -Crate $def.Name
        }

        # Not found through the download source (e.g. a git+ install or a manual download):
        # fall back to the GitHub repo named by the tool's own Homepage, when it has one.
        if ($null -eq $facts -and $def.Keys.Contains("Homepage") -and $def.Keys["Homepage"].IsString) {
            $homepageRepo = Find-GitHubRepo -Urls @($def.Keys["Homepage"].Value)
            if ($homepageRepo) {
                $facts = Get-GitHubRepoFacts -Repo $homepageRepo
            }
        }

        # No cache entry and no API data - nothing to propose for this tool.
        if ($null -eq $facts) {
            continue
        }

        foreach ($key in $emptyKeys) {
            $value = $facts.$key
            if ($key -eq "License") {
                $value = ConvertTo-LicenseName -License $value
            }
            if ([string]::IsNullOrWhiteSpace($value)) {
                continue
            }
            $proposals.Add([PSCustomObject]@{
                File        = $file.FullName
                FileName    = $file.Name
                Line        = $def.Line
                Tool        = $def.Name
                Key         = $key
                Value       = $value
                Origin      = $facts.Origin
                StartOffset = $def.Keys[$key].StartOffset
                EndOffset   = $def.Keys[$key].EndOffset
            })
        }
    }
}

if ($proposals.Count -eq 0) {
    Write-Output "No fillable fields found (or no cache/API data available)."
} else {
    $proposals | Sort-Object FileName, Line, Key |
        Format-Table @{n="File";e={$_.FileName}}, Line, Tool, Key, Value, Origin -AutoSize |
        Out-String -Width 4096 | Write-Output
    Write-Output "Proposed values: $($proposals.Count)"
}

if ($unmatched.Count -gt 0) {
    Write-Output ""
    Write-Output "Unmatched tools (no repo association, fill manually):"
    $unmatched | ForEach-Object { Write-Output "  $_" }
}

if ($backlog.Count -gt 0) {
    Write-Output ""
    Write-Output "Human-authored backlog (empty Usage/Tips fields):"
    $backlog.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Output "  $($_.Key): $($_.Value)"
    }
}

if (-not $Apply) {
    if ($proposals.Count -gt 0) {
        Write-Output ""
        Write-Output "Report mode - rerun with -Apply to write these values."
    }
    exit 0
}

# Apply: splice values into the files, from the end backwards so earlier
# offsets stay valid. Only extents whose current text is exactly '""' are
# touched - anything else means the file changed since parsing.
foreach ($group in ($proposals | Group-Object File)) {
    $path = $group.Name
    $hasBom = $false
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $hasBom = $true
    }
    $text = Get-Content $path -Raw

    $applied = 0
    foreach ($edit in ($group.Group | Sort-Object StartOffset -Descending)) {
        $current = $text.Substring($edit.StartOffset, $edit.EndOffset - $edit.StartOffset)
        if ($current -ne '""') {
            Write-Warning "$($edit.FileName):$($edit.Line) ($($edit.Tool)) $($edit.Key): expected empty string at offset $($edit.StartOffset), found '$current' - skipped"
            continue
        }
        $text = $text.Substring(0, $edit.StartOffset) +
            (ConvertTo-QuotedLiteral -Value $edit.Value) +
            $text.Substring($edit.EndOffset)
        $applied++
    }

    $encoding = if ($hasBom) { [System.Text.UTF8Encoding]::new($true) } else { [System.Text.UTF8Encoding]::new($false) }
    [System.IO.File]::WriteAllText($path, $text, $encoding)
    Write-Output "Applied $applied change(s) to $(Split-Path $path -Leaf)."
}

Write-Output "Done. Review with git diff, then run scripts/validate-tool-metadata.ps1."
