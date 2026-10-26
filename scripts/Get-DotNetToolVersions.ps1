# Finds .NET programs under one or more folders and reports which .NET runtime
# each one needs. Nothing is executed; the files are only read.
#
# What is detected:
#   *.runtimeconfig.json        - framework dependent .NET (Core) 5+ apps
#   single-file .exe bundles    - runtimeconfig.json embedded in the apphost
#   managed .exe without config - .NET Framework apps (TargetFrameworkAttribute
#                                 or the metadata version string)
#   managed .dll (optional)     - libraries, with -IncludeLibraries
#
# For framework dependent apps the RollForward setting decides which installed
# runtimes can be used. The default (Minor) needs the same major version, so a
# .NET 9 app does not start with only .NET 10 installed.
#
# Examples (Windows PowerShell 5.1 or PowerShell 7):
#   .\scripts\Get-DotNetToolVersions.ps1                        # scans .\mount\Tools
#   .\scripts\Get-DotNetToolVersions.ps1 -Path C:\Tools         # inside the sandbox
#   .\scripts\Get-DotNetToolVersions.ps1 -AssumeInstalled 10    # what breaks with only .NET 10?
#   .\scripts\Get-DotNetToolVersions.ps1 -CsvPath .\log\dotnet.csv
#   .\scripts\Get-DotNetToolVersions.ps1 -AssumeInstalled 8,9,10 -FailOnMissing  # exit 1 if a program needs another runtime

param (
    [string[]]$Path = @(".\mount\Tools"),
    # Major versions of the .NET runtime to check against. Defaults to the
    # runtimes installed on this machine, or the ones dfirws installs in the sandbox.
    [int[]]$AssumeInstalled = @(),
    [switch]$IncludeLibraries,
    [int]$MaxFileSizeMB = 512,
    [string]$CsvPath = "",
    # Exit with code 1 if any program needs a runtime that is not in the checked list.
    [switch]$FailOnMissing
)

Set-StrictMode -Version Latest

# End of support dates from https://dotnet.microsoft.com/platform/support/policy/dotnet-core
$DOTNET_END_OF_SUPPORT = @{
    5  = "2022-05-10"
    6  = "2024-11-12"
    7  = "2024-05-14"
    8  = "2026-11-10"
    9  = "2026-11-10"
    10 = "2028-11-14"
}

# Runtimes installed by setup/start_sandbox.ps1
$SANDBOX_RUNTIMES = @(8, 9, 10)

$LATIN1 = [Text.Encoding]::GetEncoding(28591)

function Get-InstalledRuntimeMajors {
    $majors = @()
    $roots = @()
    if ($env:ProgramFiles) {
        $roots += Join-Path $env:ProgramFiles "dotnet\shared"
    }
    if ($env:DOTNET_ROOT) {
        $roots += Join-Path $env:DOTNET_ROOT "shared"
    }
    foreach ($root in $roots) {
        foreach ($framework in @("Microsoft.NETCore.App", "Microsoft.WindowsDesktop.App")) {
            $dir = Join-Path $root $framework
            if (Test-Path $dir) {
                foreach ($version in Get-ChildItem -Path $dir -Directory) {
                    if ($version.Name -match '^(\d+)\.') {
                        $majors += [int]$Matches[1]
                    }
                }
            }
        }
    }
    return @($majors | Sort-Object -Unique)
}

# Returns $true if the PE file has a CLR header (is a managed assembly).
function Test-ManagedPE {
    param ([byte[]]$Header)

    if ($Header.Length -lt 0x40 -or $Header[0] -ne 0x4D -or $Header[1] -ne 0x5A) {
        return $false
    }
    $peOffset = [BitConverter]::ToInt32($Header, 0x3C)
    if ($peOffset -lt 0 -or $peOffset + 24 -gt $Header.Length) {
        return $false
    }
    if ([BitConverter]::ToUInt32($Header, $peOffset) -ne 0x00004550) {
        return $false
    }
    $optionalHeader = $peOffset + 24
    $magic = [BitConverter]::ToUInt16($Header, $optionalHeader)
    if ($magic -eq 0x10b) {
        $dataDirectories = $optionalHeader + 96
    } elseif ($magic -eq 0x20b) {
        $dataDirectories = $optionalHeader + 112
    } else {
        return $false
    }
    # Data directory 14 is the CLR runtime header
    $clrDirectory = $dataDirectories + 14 * 8
    if ($clrDirectory + 8 -gt $Header.Length) {
        return $false
    }
    return [BitConverter]::ToUInt32($Header, $clrDirectory) -ne 0
}

# Extracts the JSON object that contains "runtimeOptions" from text, or $null.
function Get-EmbeddedRuntimeConfig {
    param ([string]$Text)

    $index = $Text.IndexOf('"runtimeOptions"')
    if ($index -lt 0) {
        return $null
    }
    $start = $Text.LastIndexOf('{', $index)
    if ($start -lt 0 -or $index - $start -gt 64) {
        return $null
    }
    $depth = 0
    for ($i = $start; $i -lt $Text.Length -and $i -lt $start + 65536; $i++) {
        $c = $Text[$i]
        if ($c -eq '{') {
            $depth++
        } elseif ($c -eq '}') {
            $depth--
            if ($depth -eq 0) {
                try {
                    return $Text.Substring($start, $i - $start + 1) | ConvertFrom-Json
                } catch {
                    return $null
                }
            }
        }
    }
    return $null
}

function Get-OptionalProperty {
    param ($Object, [string]$Name)

    if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }
    return $null
}

# Turns a parsed runtimeconfig.json into the fields of a result row.
function Get-RuntimeConfigInfo {
    param ($Config)

    $options = Get-OptionalProperty $Config "runtimeOptions"
    $info = @{
        Tfm         = [string](Get-OptionalProperty $options "tfm")
        Frameworks  = ""
        RollForward = "Minor"
        Major       = $null
        Kind        = "FrameworkDependent"
    }

    $rollForward = Get-OptionalProperty $options "rollForward"
    if ($rollForward) {
        $info.RollForward = [string]$rollForward
    } else {
        $configProperties = Get-OptionalProperty $options "configProperties"
        $rollForwardOnNoCandidate = Get-OptionalProperty $configProperties "System.Runtime.RollForwardOnNoCandidateFx"
        if ($rollForwardOnNoCandidate -eq 2) {
            $info.RollForward = "Major"
        }
    }

    $frameworks = @()
    $framework = Get-OptionalProperty $options "framework"
    if ($null -ne $framework) {
        $frameworks += $framework
    }
    $list = Get-OptionalProperty $options "frameworks"
    if ($null -ne $list) {
        $frameworks += $list
    }
    $included = Get-OptionalProperty $options "includedFrameworks"
    if ($null -ne $included) {
        $frameworks += $included
        $info.Kind = "SelfContained"
    }

    $info.Frameworks = ($frameworks | ForEach-Object { "$($_.name) $($_.version)" }) -join "; "
    foreach ($fw in $frameworks) {
        if ([string]$fw.version -match '^(\d+)\.') {
            $major = [int]$Matches[1]
            if ($null -eq $info.Major -or $major -gt $info.Major) {
                $info.Major = $major
            }
        }
    }
    if ($null -eq $info.Major -and $info.Tfm -match '^net(\d+)\.') {
        $info.Major = [int]$Matches[1]
    }
    return $info
}

# Describes a .NET Framework assembly from its bytes (as Latin-1 text).
function Get-NetFrameworkInfo {
    param ([string]$Text, [switch]$Library)

    $tfm = ""
    $match = [regex]::Match($Text, '\.NET(Framework|CoreApp|Standard),Version=v[0-9.]+')
    if ($match.Success) {
        $tfm = $match.Value
    }

    $metadataVersion = ""
    $bsjb = $Text.IndexOf("BSJB")
    if ($bsjb -ge 0 -and $bsjb + 16 -lt $Text.Length) {
        $length = [int]$Text[$bsjb + 12] + 256 * [int]$Text[$bsjb + 13]
        if ($length -gt 0 -and $length -lt 256 -and $bsjb + 16 + $length -le $Text.Length) {
            $metadataVersion = $Text.Substring($bsjb + 16, $length).TrimEnd([char]0)
        }
    }

    $kind = "NETFramework"
    if ($tfm -like ".NETCoreApp*") {
        $kind = "FrameworkDependent"
    } elseif ($tfm -like ".NETStandard*") {
        $kind = "NETStandard"
    }
    if (-not $tfm) {
        if ($metadataVersion -like "v2.*") {
            $tfm = ".NETFramework 2.0-3.5 ($metadataVersion)"
        } elseif ($metadataVersion -like "v4.*" -and -not $Library) {
            # .NET (Core) apps always have a runtimeconfig.json, so a v4 exe without one is .NET Framework
            $tfm = ".NETFramework 4.x ($metadataVersion)"
        } else {
            $tfm = "unknown ($metadataVersion)"
        }
    }
    $major = $null
    if ($tfm -match '^\.NETCoreApp,Version=v(\d+)\.') {
        $major = [int]$Matches[1]
    }
    return @{ Kind = $kind; Tfm = $tfm; Major = $major }
}

function Get-RuntimeStatus {
    param ($Row, [int[]]$Installed)

    switch ($Row.Kind) {
        "SelfContained" { return "OK (self-contained)" }
        "Library" { return "Library" }
        "NETStandard" { return "Library" }
        "NETFramework" {
            if ($Row.Tfm -match 'v(2|3)\.|2\.0-3\.5') {
                return "Needs .NET Framework 3.5 feature"
            }
            return "OK (.NET Framework 4.x is part of Windows)"
        }
    }

    if ($null -eq $Row.Major) {
        return "Unknown"
    }
    $major = [int]$Row.Major
    if ($Row.RollForward -in @("Major", "LatestMajor")) {
        $candidates = @($Installed | Where-Object { $_ -ge $major })
    } else {
        $candidates = @($Installed | Where-Object { $_ -eq $major })
    }
    if ($candidates.Count -eq 0) {
        return "MISSING .NET $major"
    }
    $uses = ($candidates | Measure-Object -Minimum).Minimum
    if ($Row.RollForward -eq "LatestMajor") {
        $uses = ($candidates | Measure-Object -Maximum).Maximum
    }
    if ($uses -ne $major) {
        return "OK (rolls forward to .NET $uses)"
    }
    return "OK"
}

if ($AssumeInstalled.Count -gt 0) {
    $installed = $AssumeInstalled
    $installedSource = "-AssumeInstalled"
} else {
    $installed = @(Get-InstalledRuntimeMajors)
    $installedSource = "this machine"
    if ($installed.Count -eq 0) {
        $installed = $SANDBOX_RUNTIMES
        $installedSource = "dfirws sandbox defaults"
    }
}

$results = [System.Collections.Generic.List[PSCustomObject]]::new()
$maxBytes = [int64]$MaxFileSizeMB * 1MB

foreach ($root in $Path) {
    if (-not (Test-Path $root)) {
        Write-Warning "Path not found: $root"
        continue
    }
    $rootFull = (Resolve-Path -LiteralPath $root).ProviderPath.TrimEnd('\', '/')

    $files = Get-ChildItem -Path $rootFull -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "*.runtimeconfig.json" -or $_.Extension -in @(".exe", ".dll") } |
        # Skip the installed .NET runtimes and SDKs themselves (e.g. C:\Program Files\dotnet\shared\...)
        Where-Object { $_.FullName -notmatch '\\dotnet\\(shared|host|sdk|packs)\\' }

    foreach ($file in $files) {
        $relative = $file.FullName.Substring($rootFull.Length).TrimStart('\', '/')
        $tool = ($relative -split '[\\/]')[0]
        $row = [ordered]@{
            Tool        = $tool
            File        = $relative
            Kind        = ""
            Tfm         = ""
            Frameworks  = ""
            RollForward = ""
            Major       = $null
            EndOfSupport = ""
            Status      = ""
        }

        if ($file.Name -like "*.runtimeconfig.json") {
            try {
                $config = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
            } catch {
                Write-Warning "Unable to parse $($file.FullName): $($_.Exception.Message)"
                continue
            }
            $info = Get-RuntimeConfigInfo $config
        } else {
            if ($file.Length -gt $maxBytes -or $file.Length -lt 0x200) {
                continue
            }
            $baseName = [IO.Path]::GetFileNameWithoutExtension($file.Name)
            # Apps with a runtimeconfig.json next to them are reported from that file
            if (Test-Path -LiteralPath (Join-Path $file.DirectoryName "$baseName.runtimeconfig.json")) {
                continue
            }
            try {
                $bytes = [IO.File]::ReadAllBytes($file.FullName)
            } catch {
                Write-Warning "Unable to read $($file.FullName): $($_.Exception.Message)"
                continue
            }
            $headerLength = [Math]::Min($bytes.Length, 4096)
            $header = New-Object byte[] $headerLength
            [Array]::Copy($bytes, $header, $headerLength)
            $managed = Test-ManagedPE $header

            if ($file.Extension -eq ".dll" -and -not ($managed -and $IncludeLibraries)) {
                continue
            }

            $text = $LATIN1.GetString($bytes)
            $config = $null
            if ($file.Extension -eq ".exe") {
                $config = Get-EmbeddedRuntimeConfig $text
            }
            if ($null -ne $config) {
                $info = Get-RuntimeConfigInfo $config
                if ($info.Kind -eq "FrameworkDependent") {
                    $info.Kind = "SingleFile"
                } else {
                    $info.Kind = "SingleFileSelfContained"
                }
            } elseif ($managed) {
                $info = Get-NetFrameworkInfo $text -Library:($file.Extension -eq ".dll")
                if ($file.Extension -eq ".dll") {
                    $info.Kind = "Library"
                }
            } else {
                continue
            }
        }

        foreach ($key in $info.Keys) {
            $row[$key] = $info[$key]
        }
        if ($null -ne $row.Major -and $DOTNET_END_OF_SUPPORT.ContainsKey([int]$row.Major)) {
            $row.EndOfSupport = $DOTNET_END_OF_SUPPORT[[int]$row.Major]
        }
        $statusKind = $row.Kind
        if ($statusKind -eq "SingleFile") {
            $statusKind = "FrameworkDependent"
        } elseif ($statusKind -eq "SingleFileSelfContained") {
            $statusKind = "SelfContained"
        }
        $row.Status = Get-RuntimeStatus ([PSCustomObject]@{ Kind = $statusKind; Tfm = $row.Tfm; Major = $row.Major; RollForward = $row.RollForward }) $installed
        $results.Add([PSCustomObject]$row)
    }
}

$sorted = $results | Sort-Object Tool, File

Write-Host ""
Write-Host "Runtimes checked against ($installedSource): $(($installed | ForEach-Object { ".NET $_" }) -join ', ')"
Write-Host ""
Write-Host "Programs that need a .NET runtime, by major version:"
$sorted | Where-Object { $_.Kind -in @("FrameworkDependent", "SingleFile") } |
    Group-Object Major | Sort-Object { [int]$_.Name } | ForEach-Object {
        $eos = ""
        if ($DOTNET_END_OF_SUPPORT.ContainsKey([int]$_.Name)) {
            $eos = " (end of support $($DOTNET_END_OF_SUPPORT[[int]$_.Name]))"
        }
        $tools = ($_.Group | Select-Object -ExpandProperty Tool -Unique) -join ", "
        Write-Host ("  .NET {0,-3}{1}: {2} programs in {3}" -f $_.Name, $eos, $_.Count, $tools)
    }

$problems = @($sorted | Where-Object { $_.Status -like "MISSING*" -or $_.Status -like "Needs*" })
if ($problems.Count -gt 0) {
    Write-Host ""
    Write-Host "Programs that will not start with the runtimes above:" -ForegroundColor Yellow
    $problems | Format-Table Tool, File, Tfm, RollForward, Status -AutoSize | Out-String -Width 4096 | Write-Host
}

if ($CsvPath) {
    $sorted | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "Saved $($sorted.Count) rows to $CsvPath"
}

$sorted

if ($FailOnMissing -and $problems.Count -gt 0) {
    Write-Host "ERROR: $($problems.Count) programs need a .NET runtime other than $(($installed | ForEach-Object { ".NET $_" }) -join ', ')."
    exit 1
}
