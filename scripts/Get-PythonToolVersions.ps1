# Finds Python virtual environments and Python projects under one or more
# folders and reports which Python versions they can move to. Nothing is
# executed; the files are only read.
#
# What is detected:
#   pyvenv.cfg          - venvs (C:\venv\default, uv tool venvs in C:\venv\uv\...)
#                         and the Python version and interpreter they use
#   *.dist-info         - every installed package in a venv:
#                           Requires-Python from METADATA
#                           wheel tags from WHEEL. A package built for one
#                           Python (cp311-cp311-win_amd64) needs a new wheel
#                           for another Python; pure Python (none) and stable
#                           ABI (abi3) packages do not.
#   pyproject.toml      - requires-python in projects (C:\git\...)
#   setup.cfg/setup.py  - python_requires in projects
#
# For each -TargetVersion a package is reported as OK, blocked by
# Requires-Python, or as a binary package that needs a wheel for that Python.
# With -CheckPyPI (needs network, use it on the host) the latest release on
# PyPI is checked for a matching Requires-Python and wheel.
#
# Problems that break a venv now (fails with -FailOnMissing):
#   - the interpreter in pyvenv.cfg is missing (with -CheckInterpreter)
#   - a binary package is built for another Python than the venv uses
#   - a package's Requires-Python excludes the venv's Python
#
# Examples (Windows PowerShell 5.1 or PowerShell 7):
#   .\scripts\Get-PythonToolVersions.ps1                                  # scans .\mount\venv and .\mount\git
#   .\scripts\Get-PythonToolVersions.ps1 -TargetVersion 3.13 -CheckPyPI   # what blocks moving to 3.13?
#   .\scripts\Get-PythonToolVersions.ps1 -Path C:\venv, C:\git -CheckInterpreter -FailOnMissing  # inside the sandbox
#   .\scripts\Get-PythonToolVersions.ps1 -CsvPath .\log\python.csv

param (
    [string[]]$Path = @(".\mount\venv", ".\mount\git"),
    # Python versions (major.minor) to check if the venvs and projects can move to.
    [string[]]$TargetVersion = @("3.12", "3.13", "3.14"),
    # Wheel platform tag to look for with -CheckPyPI.
    [string]$Platform = "win_amd64",
    # Check the latest release of blocking packages on PyPI.
    [switch]$CheckPyPI,
    # Report venvs whose interpreter (home in pyvenv.cfg) does not exist.
    [switch]$CheckInterpreter,
    [string]$CsvPath = "",
    # Exit with code 1 if any venv is broken with the Python it uses now.
    [switch]$FailOnMissing
)

Set-StrictMode -Version Latest

# Returns the numeric parts of a version string (3.11.9 -> 3,11,9), or $null.
function ConvertTo-VersionParts {
    param ([string]$Version)

    $match = [regex]::Match($Version, '^\s*v?(\d+(?:\.\d+)*)')
    if (-not $match.Success) {
        return $null
    }
    return ,[int[]]($match.Groups[1].Value -split '\.')
}

# Compares two version part arrays. Returns -1, 0 or 1.
function Compare-VersionParts {
    param ([int[]]$A, [int[]]$B)

    $length = [Math]::Max($A.Length, $B.Length)
    for ($i = 0; $i -lt $length; $i++) {
        $x = 0
        $y = 0
        if ($i -lt $A.Length) { $x = $A[$i] }
        if ($i -lt $B.Length) { $y = $B[$i] }
        if ($x -lt $y) { return -1 }
        if ($x -gt $y) { return 1 }
    }
    return 0
}

# Returns $true if the first parts of $Version are $Prefix.
function Test-VersionPrefix {
    param ([int[]]$Version, [int[]]$Prefix)

    for ($i = 0; $i -lt $Prefix.Length; $i++) {
        $x = 0
        if ($i -lt $Version.Length) { $x = $Version[$i] }
        if ($x -ne $Prefix[$i]) {
            return $false
        }
    }
    return $true
}

# Returns $true if $Version matches a PEP 440 specifier set like ">=3.8,<3.13".
# Specifiers that cannot be parsed are ignored.
function Test-SpecifierSet {
    param ([string]$Specifier, [int[]]$Version)

    foreach ($clause in $Specifier -split ',') {
        $clause = $clause.Trim()
        if (-not $clause) {
            continue
        }
        $match = [regex]::Match($clause, '^(~=|===|==|!=|<=|>=|<|>)\s*(\S+)$')
        if (-not $match.Success) {
            continue
        }
        $op = $match.Groups[1].Value
        $value = $match.Groups[2].Value
        $wildcard = $value.EndsWith(".*")
        $parts = ConvertTo-VersionParts ($value -replace '\.\*$', '')
        if ($null -eq $parts) {
            continue
        }
        $cmp = Compare-VersionParts $Version $parts
        $ok = switch ($op) {
            "==" { if ($wildcard) { Test-VersionPrefix $Version $parts } else { $cmp -eq 0 } }
            "===" { $cmp -eq 0 }
            "!=" { if ($wildcard) { -not (Test-VersionPrefix $Version $parts) } else { $cmp -ne 0 } }
            "<" { $cmp -lt 0 }
            "<=" { $cmp -le 0 }
            ">" { $cmp -gt 0 }
            ">=" { $cmp -ge 0 }
            "~=" {
                $prefix = $parts
                if ($parts.Length -gt 1) {
                    $prefix = $parts[0..($parts.Length - 2)]
                }
                ($cmp -ge 0) -and (Test-VersionPrefix $Version $prefix)
            }
        }
        if (-not $ok) {
            return $false
        }
    }
    return $true
}

# Returns $true if some release of Python major.minor matches the specifier set.
function Test-PythonAllowed {
    param ([string]$Specifier, [string]$Python)

    if (-not $Specifier) {
        return $true
    }
    $parts = ConvertTo-VersionParts $Python
    $series = @($parts[0], $parts[1])
    return (Test-SpecifierSet $Specifier ($series + 0)) -or (Test-SpecifierSet $Specifier ($series + 99))
}

# Reads "key = value" lines (pyvenv.cfg) into a hashtable.
function Read-KeyValueFile {
    param ([string]$FilePath)

    $values = @{}
    foreach ($line in Get-Content -LiteralPath $FilePath -ErrorAction SilentlyContinue) {
        if ($line -match '^\s*([^=#]+?)\s*=\s*(.*?)\s*$') {
            $values[$Matches[1].ToLower()] = $Matches[2]
        }
    }
    return $values
}

# Reads Name, Version, Requires-Python and wheel tags from a .dist-info folder.
function Read-DistInfo {
    param ([string]$DistInfo)

    $info = @{ Name = ""; Version = ""; RequiresPython = ""; Tags = @() }
    $metadata = Join-Path $DistInfo "METADATA"
    if (Test-Path -LiteralPath $metadata) {
        # Headers end at the first empty line, the description follows
        foreach ($line in Get-Content -LiteralPath $metadata -ErrorAction SilentlyContinue) {
            if ($line -eq "") {
                break
            }
            if ($line -match '^Name:\s*(.+)$') {
                $info.Name = $Matches[1].Trim()
            } elseif ($line -match '^Version:\s*(.+)$') {
                $info.Version = $Matches[1].Trim()
            } elseif ($line -match '^Requires-Python:\s*(.+)$') {
                $info.RequiresPython = $Matches[1].Trim()
            }
        }
    }
    $wheel = Join-Path $DistInfo "WHEEL"
    if (Test-Path -LiteralPath $wheel) {
        $info.Tags = @(Get-Content -LiteralPath $wheel -ErrorAction SilentlyContinue |
            Where-Object { $_ -match '^Tag:\s*(\S+)' } | ForEach-Object { ($_ -replace '^Tag:\s*', '').Trim() })
    }
    return $info
}

# Describes how a package is tied to a Python version from its wheel tags:
#   Kind "Pure"   - abi none, runs on any Python 3
#   Kind "Abi3"   - stable ABI, runs on Python >= MinPython
#   Kind "Binary" - built for one Python (Python = "3.11")
#   Kind "Unknown" - no WHEEL file
function Get-WheelAbi {
    param ([string[]]$Tags)

    if ($Tags.Count -eq 0) {
        return @{ Kind = "Unknown"; Python = "" }
    }
    $binary = ""
    foreach ($tag in $Tags) {
        $fields = $tag -split '-'
        if ($fields.Count -ne 3) {
            continue
        }
        $abis = $fields[1] -split '\.'
        $pythons = $fields[0] -split '\.'
        if ($abis -contains "none") {
            return @{ Kind = "Pure"; Python = "" }
        }
        if ($abis -contains "abi3") {
            $min = $pythons | ForEach-Object { if ($_ -match '^cp3(\d+)$') { "3.$([int]$Matches[1])" } } | Select-Object -First 1
            return @{ Kind = "Abi3"; Python = [string]$min }
        }
        foreach ($abi in $abis) {
            # cp313t is the free-threaded build, which needs its own wheels
            if ($abi -match '^cp3(\d+)m?$') {
                $binary = "3.$([int]$Matches[1])"
            }
        }
    }
    if ($binary) {
        return @{ Kind = "Binary"; Python = $binary }
    }
    return @{ Kind = "Unknown"; Python = "" }
}

# Returns $true if the wheel package can be used on Python $Python (major.minor).
function Test-WheelAbiAllowed {
    param ($Abi, [string]$Python)

    switch ($Abi.Kind) {
        "Binary" { return $Abi.Python -eq $Python }
        "Abi3" {
            if (-not $Abi.Python) {
                return $true
            }
            return (Compare-VersionParts (ConvertTo-VersionParts $Python) (ConvertTo-VersionParts $Abi.Python)) -ge 0
        }
    }
    return $true
}

$PYPI_CACHE = @{}

function Get-PyPIProject {
    param ([string]$Name)

    $key = $Name.ToLower()
    if (-not $PYPI_CACHE.ContainsKey($key)) {
        try {
            $PYPI_CACHE[$key] = Invoke-RestMethod -Uri "https://pypi.org/pypi/$([uri]::EscapeDataString($Name))/json" -TimeoutSec 30 -ErrorAction Stop
        } catch {
            $PYPI_CACHE[$key] = $null
        }
    }
    return $PYPI_CACHE[$key]
}

# Checks if the latest release on PyPI supports Python $Python on $Platform.
function Get-PyPIStatus {
    param ([string]$Name, [string]$Python, [string]$Platform)

    $project = Get-PyPIProject $Name
    if ($null -eq $project) {
        return "not on PyPI"
    }
    $latest = [string]$project.info.version
    $requiresPython = [string]$project.info.requires_python
    if (-not (Test-PythonAllowed $requiresPython $Python)) {
        return "latest $latest has Requires-Python $requiresPython"
    }
    $cp = "cp" + ($Python -replace '\.', '')
    $hasSdist = $false
    foreach ($file in @($project.urls)) {
        if ($file.packagetype -eq "sdist") {
            $hasSdist = $true
            continue
        }
        if ($file.packagetype -ne "bdist_wheel") {
            continue
        }
        $fields = ([IO.Path]::GetFileNameWithoutExtension($file.filename)) -split '-'
        if ($fields.Count -lt 5) {
            continue
        }
        $pythons = $fields[-3] -split '\.'
        $abis = $fields[-2] -split '\.'
        $platforms = $fields[-1] -split '\.'
        if (-not ($platforms -contains "any" -or $platforms -contains $Platform)) {
            continue
        }
        $abi = Get-WheelAbi @("$($fields[-3])-$($fields[-2])-$($fields[-1])")
        if ($abis -contains "none" -and -not ($pythons -match '^(py3|py2|cp3)' )) {
            continue
        }
        if (Test-WheelAbiAllowed $abi $Python) {
            if ($abi.Kind -eq "Binary" -and -not ($pythons -contains $cp)) {
                continue
            }
            return "OK in latest $latest"
        }
    }
    if ($hasSdist) {
        return "no $cp wheel in latest $latest (source only, needs a compiler)"
    }
    return "no $cp wheel in latest $latest"
}

$targets = @($TargetVersion | ForEach-Object {
    $parts = ConvertTo-VersionParts $_
    "$($parts[0]).$($parts[1])"
})

$rows = [System.Collections.Generic.List[PSCustomObject]]::new()

# Adds a result row with one status column per target version.
function Add-ResultRow {
    param ([hashtable]$Fields, [hashtable]$TargetStatus)

    $row = [ordered]@{}
    foreach ($key in @("Venv", "Kind", "Python", "Package", "Version", "RequiresPython", "Wheel", "Problem")) {
        $row[$key] = $Fields[$key]
    }
    foreach ($target in $targets) {
        $row["Python $target"] = $TargetStatus[$target]
    }
    $rows.Add([PSCustomObject]$row)
}

function Get-TargetStatus {
    param ([string]$Name, [string]$RequiresPython, $Abi, [string]$Current)

    $status = @{}
    foreach ($target in $targets) {
        if ($target -eq $Current) {
            $status[$target] = "current"
            continue
        }
        $reasons = @()
        if (-not (Test-PythonAllowed $RequiresPython $target)) {
            $reasons += "Requires-Python $RequiresPython"
        }
        if ($null -ne $Abi -and -not (Test-WheelAbiAllowed $Abi $target)) {
            $reasons += "binary wheel for $($Abi.Python)"
        }
        if ($reasons.Count -eq 0) {
            $status[$target] = "OK"
            continue
        }
        $text = "BLOCKED: " + ($reasons -join ", ")
        if ($CheckPyPI -and $Name) {
            $text += " (PyPI: $(Get-PyPIStatus -Name $Name -Python $target -Platform $Platform))"
        }
        $status[$target] = $text
    }
    return $status
}

$venvSummaries = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($root in $Path) {
    if (-not (Test-Path $root)) {
        Write-Warning "Path not found: $root"
        continue
    }
    $rootFull = (Resolve-Path -LiteralPath $root).ProviderPath.TrimEnd('\', '/')

    $files = @(Get-ChildItem -Path $rootFull -Recurse -Depth 3 -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -in @("pyvenv.cfg", "pyproject.toml", "setup.cfg", "setup.py") })

    $venvDirs = @($files | Where-Object { $_.Name -eq "pyvenv.cfg" } | ForEach-Object { $_.DirectoryName })

    foreach ($cfgFile in $files | Where-Object { $_.Name -eq "pyvenv.cfg" }) {
        $venvDir = $cfgFile.DirectoryName
        $venvName = $venvDir.Substring($rootFull.Length).TrimStart('\', '/')
        if (-not $venvName) {
            $venvName = Split-Path $venvDir -Leaf
        }
        $cfg = Read-KeyValueFile $cfgFile.FullName
        $pythonVersion = ""
        foreach ($key in @("version_info", "version")) {
            if ($cfg.ContainsKey($key)) {
                $pythonVersion = $cfg[$key]
                break
            }
        }
        $current = ""
        $currentParts = ConvertTo-VersionParts $pythonVersion
        if ($null -ne $currentParts -and $currentParts.Length -ge 2) {
            $current = "$($currentParts[0]).$($currentParts[1])"
        }

        if ($CheckInterpreter -and $cfg.ContainsKey("home") -and -not (Test-Path -LiteralPath $cfg["home"])) {
            Add-ResultRow @{ Venv = $venvName; Kind = "Venv"; Python = $pythonVersion; Problem = "MISSING interpreter $($cfg["home"])" } @{}
        }

        $sitePackages = @()
        if (Test-Path (Join-Path $venvDir "Lib\site-packages")) {
            $sitePackages += Join-Path $venvDir "Lib\site-packages"
        }
        $sitePackages += @(Get-ChildItem -Path (Join-Path $venvDir "lib") -Directory -Filter "python*" -ErrorAction SilentlyContinue |
            ForEach-Object { Join-Path $_.FullName "site-packages" } | Where-Object { Test-Path $_ })

        $packageCount = 0
        $blocked = @{}
        foreach ($target in $targets) {
            $blocked[$target] = 0
        }
        foreach ($distInfo in $sitePackages | ForEach-Object { Get-ChildItem -Path $_ -Directory -Filter "*.dist-info" -ErrorAction SilentlyContinue }) {
            $info = Read-DistInfo $distInfo.FullName
            if (-not $info.Name) {
                continue
            }
            $packageCount++
            $abi = Get-WheelAbi $info.Tags
            $wheel = $abi.Kind
            if ($abi.Python) {
                $wheel += " $($abi.Python)"
            }
            $problem = ""
            if ($current) {
                if (-not (Test-WheelAbiAllowed $abi $current)) {
                    $problem = "binary wheel for $($abi.Python) in a Python $current venv"
                } elseif (-not (Test-PythonAllowed $info.RequiresPython $current)) {
                    $problem = "Requires-Python $($info.RequiresPython) excludes Python $current"
                }
            }
            $status = Get-TargetStatus -Name $info.Name -RequiresPython $info.RequiresPython -Abi $abi -Current $current
            foreach ($target in $targets) {
                if ($status[$target] -like "BLOCKED*") {
                    $blocked[$target]++
                }
            }
            Add-ResultRow @{
                Venv = $venvName; Kind = "Package"; Python = $current; Package = $info.Name; Version = $info.Version
                RequiresPython = $info.RequiresPython; Wheel = $wheel; Problem = $problem
            } $status
        }

        $summary = [ordered]@{ Venv = $venvName; Python = $pythonVersion; Packages = $packageCount }
        foreach ($target in $targets) {
            if ($target -eq $current) {
                $summary["Python $target"] = "current"
            } elseif ($blocked[$target] -eq 0) {
                $summary["Python $target"] = "OK"
            } else {
                $summary["Python $target"] = "$($blocked[$target]) blocked"
            }
        }
        $venvSummaries.Add([PSCustomObject]$summary)
    }

    # Projects (git repositories) that declare the Python versions they support
    foreach ($file in $files | Where-Object { $_.Name -ne "pyvenv.cfg" }) {
        if (@($venvDirs | Where-Object { $file.FullName.StartsWith($_ + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) }).Count -gt 0) {
            continue
        }
        $text = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
        if (-not $text) {
            continue
        }
        $pattern = switch ($file.Name) {
            "pyproject.toml" { '(?m)^\s*requires-python\s*=\s*["'']([^"'']+)["'']' }
            "setup.cfg" { '(?m)^\s*python_requires\s*=\s*([^\r\n#]+)' }
            "setup.py" { 'python_requires\s*=\s*["'']([^"'']+)["'']' }
        }
        $match = [regex]::Match($text, $pattern)
        if (-not $match.Success) {
            continue
        }
        $relative = $file.FullName.Substring($rootFull.Length).TrimStart('\', '/')
        $specifier = $match.Groups[1].Value.Trim()
        Add-ResultRow @{
            Venv = ""; Kind = "Project"; Package = $relative; RequiresPython = $specifier
        } (Get-TargetStatus -Name "" -RequiresPython $specifier -Abi $null -Current "")
    }
}

$sorted = $rows | Sort-Object Kind, Venv, Package

Write-Host ""
Write-Host "Target Python versions: $($targets -join ', ')"
if ($CheckPyPI) {
    Write-Host "Blocked packages are checked against the latest release on PyPI ($Platform)."
}
Write-Host ""
Write-Host "Venvs:"
$venvSummaries | Sort-Object Venv | Format-Table -AutoSize | Out-String -Width 4096 | Write-Host

# Packages that block a target, grouped by package over all venvs
foreach ($target in $targets) {
    $column = "Python $target"
    $blockers = @($sorted | Where-Object { $_.Kind -eq "Package" -and $_.$column -like "BLOCKED*" })
    if ($blockers.Count -eq 0) {
        Write-Host "Python ${target}: no installed package blocks it."
        continue
    }
    Write-Host "Python ${target}: $(@($blockers | Select-Object -ExpandProperty Package -Unique).Count) packages block it:"
    $blockers | Group-Object Package | Sort-Object Name | ForEach-Object {
        $first = $_.Group[0]
        $venvs = ($_.Group | Select-Object -ExpandProperty Venv -Unique) -join ", "
        Write-Host ("  {0} {1}: {2} - in {3}" -f $first.Package, $first.Version, ($first.$column -replace '^BLOCKED: ', ''), $venvs)
    }
    Write-Host ""
}

$projects = @($sorted | Where-Object { $_.Kind -eq "Project" })
if ($projects.Count -gt 0) {
    Write-Host "Projects with a Python requirement:"
    $columns = @("Package", "RequiresPython") + @($targets | ForEach-Object { "Python $_" })
    $projects | Format-Table $columns -AutoSize | Out-String -Width 4096 | Write-Host
}

$problems = @($sorted | Where-Object { $_.Problem })
if ($problems.Count -gt 0) {
    Write-Host ""
    Write-Host "Broken with the Python they use now:" -ForegroundColor Yellow
    $problems | Format-Table Venv, Package, Version, Problem -AutoSize | Out-String -Width 4096 | Write-Host
}

if ($CsvPath) {
    $sorted | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "Saved $(@($sorted).Count) rows to $CsvPath"
}

$sorted

if ($FailOnMissing -and $problems.Count -gt 0) {
    Write-Host "ERROR: $($problems.Count) problems in Python venvs."
    exit 1
}
