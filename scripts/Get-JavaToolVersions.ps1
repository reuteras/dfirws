# Finds Java programs under one or more folders and reports which Java version
# each one needs. Nothing is executed; the files are only read.
#
# What is detected:
#   *.jar                    - the highest class file version in the jar
#                              (META-INF/versions/* and module-info.class are
#                              skipped since older runtimes never load them)
#   application.properties   - application.java.min, used by Ghidra. The jars
#                              in that installation are not reported one by one.
#   release                  - Java runtimes bundled with a tool (jlink/jpackage)
#                              or installed in the scanned folders. Jars in the
#                              tool folder are checked against the bundled runtime.
#
# Not detected: jars wrapped in an .exe (launch4j and similar) and loose .class files.
#
# Examples (Windows PowerShell 5.1 or PowerShell 7):
#   .\scripts\Get-JavaToolVersions.ps1                          # scans .\mount\Tools
#   .\scripts\Get-JavaToolVersions.ps1 -Path C:\Tools           # inside the sandbox
#   .\scripts\Get-JavaToolVersions.ps1 -AssumeInstalled 21      # what breaks with only Java 21?
#   .\scripts\Get-JavaToolVersions.ps1 -CsvPath .\log\java.csv
#   .\scripts\Get-JavaToolVersions.ps1 -FailOnMissing           # exit 1 if a program needs a newer Java

param (
    [string[]]$Path = @(".\mount\Tools"),
    # Major version of the default Java runtime to check against. Defaults to
    # the java on PATH, or the newest Amazon Corretto installed on this machine.
    [int]$AssumeInstalled = 0,
    [int]$MaxFileSizeMB = 512,
    [string]$CsvPath = "",
    # Exit with code 1 if any program needs a newer Java than the checked runtime.
    [switch]$FailOnMissing
)

Set-StrictMode -Version Latest

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Returns the Java major version from a version string like 21.0.5, 25 or 1.8.0_402.
function ConvertTo-JavaMajor {
    param ([string]$Version)

    if ($Version -match '^1\.(\d+)') {
        return [int]$Matches[1]
    }
    if ($Version -match '^(\d+)') {
        return [int]$Matches[1]
    }
    return $null
}

# Returns the Java major version from a runtime "release" file, or $null.
function Get-ReleaseFileMajor {
    param ([string]$ReleaseFile)

    if (-not (Test-Path -LiteralPath $ReleaseFile -PathType Leaf)) {
        return $null
    }
    if ((Get-Item -LiteralPath $ReleaseFile).Length -gt 64KB) {
        return $null
    }
    foreach ($line in Get-Content -LiteralPath $ReleaseFile -ErrorAction SilentlyContinue) {
        if ($line -match '^JAVA_VERSION="?([^"]+)"?') {
            return ConvertTo-JavaMajor $Matches[1]
        }
    }
    return $null
}

function Get-DefaultJavaMajor {
    $java = Get-Command java -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $java) {
        $release = Join-Path (Split-Path (Split-Path $java.Source)) "release"
        $major = Get-ReleaseFileMajor $release
        if ($null -ne $major) {
            return @{ Major = $major; Source = $java.Source }
        }
    }
    if ($env:ProgramFiles) {
        $corretto = Join-Path $env:ProgramFiles "Amazon Corretto"
        if (Test-Path $corretto) {
            $found = foreach ($dir in Get-ChildItem -Path $corretto -Directory) {
                $major = Get-ReleaseFileMajor (Join-Path $dir.FullName "release")
                if ($null -ne $major) {
                    @{ Major = $major; Source = $dir.FullName }
                }
            }
            $newest = @($found | Sort-Object { $_.Major } -Descending)
            if ($newest.Count -gt 0) {
                return $newest[0]
            }
        }
    }
    return $null
}

# Returns $true if $File is inside $Directory.
function Test-UnderDirectory {
    param ([string]$File, [string]$Directory)

    return $File.StartsWith($Directory.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)
}

# Reads up to $Count bytes from a stream (deflate streams can return fewer bytes per read).
function Read-StreamBytes {
    param ([IO.Stream]$Stream, [int]$Count)

    $buffer = New-Object byte[] $Count
    $read = 0
    while ($read -lt $Count) {
        $n = $Stream.Read($buffer, $read, $Count - $read)
        if ($n -le 0) {
            break
        }
        $read += $n
    }
    if ($read -lt $Count) {
        return $null
    }
    return $buffer
}

# Returns the highest Java major version needed by the classes in a jar, or $null.
function Get-JarJavaMajor {
    param ([string]$JarPath)

    $zip = [IO.Compression.ZipFile]::OpenRead($JarPath)
    try {
        $maxClassVersion = 0
        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName
            if (-not $name.EndsWith(".class", [StringComparison]::OrdinalIgnoreCase)) {
                continue
            }
            if ($name.StartsWith("META-INF/versions/", [StringComparison]::OrdinalIgnoreCase) -or $name -match '(^|/)module-info\.class$') {
                continue
            }
            $stream = $entry.Open()
            try {
                $header = Read-StreamBytes $stream 8
            } finally {
                $stream.Dispose()
            }
            # Class files start with 0xCAFEBABE, then minor and major version (big endian)
            if ($null -eq $header -or $header[0] -ne 0xCA -or $header[1] -ne 0xFE -or $header[2] -ne 0xBA -or $header[3] -ne 0xBE) {
                continue
            }
            $classVersion = [int]$header[6] * 256 + [int]$header[7]
            if ($classVersion -gt $maxClassVersion) {
                $maxClassVersion = $classVersion
            }
        }
    } finally {
        $zip.Dispose()
    }
    # Class file version 45 is Java 1.1, 52 is Java 8, 65 is Java 21
    if ($maxClassVersion -lt 45) {
        return $null
    }
    return [Math]::Max($maxClassVersion - 44, 1)
}

if ($AssumeInstalled -gt 0) {
    $installed = $AssumeInstalled
    $installedSource = "-AssumeInstalled"
} else {
    $default = Get-DefaultJavaMajor
    if ($null -eq $default) {
        Write-Host "ERROR: No Java runtime found. Install Amazon Corretto or use -AssumeInstalled."
        exit 1
    }
    $installed = [int]$default.Major
    $installedSource = $default.Source
}

$results = [System.Collections.Generic.List[PSCustomObject]]::new()
$maxBytes = [int64]$MaxFileSizeMB * 1MB

function New-ResultRow {
    param ([string]$RootFull, [string]$FullName, [string]$Kind, $Major, [string]$Detail, [string]$Status)

    $relative = $FullName.Substring($RootFull.Length).TrimStart('\', '/')
    return [PSCustomObject][ordered]@{
        Tool   = ($relative -split '[\\/]')[0]
        File   = $relative
        Kind   = $Kind
        Major  = $Major
        Detail = $Detail
        Status = $Status
    }
}

foreach ($root in $Path) {
    if (-not (Test-Path $root)) {
        Write-Warning "Path not found: $root"
        continue
    }
    $rootFull = (Resolve-Path -LiteralPath $root).ProviderPath.TrimEnd('\', '/')

    $files = @(Get-ChildItem -Path $rootFull -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -eq ".jar" -or $_.Name -eq "release" -or $_.Name -eq "application.properties" })

    # Java runtimes (bundled or installed). Their own jars are skipped, and jars
    # in the folder above the runtime (the tool folder) run with that runtime.
    $runtimes = @()
    foreach ($file in $files | Where-Object { $_.Name -eq "release" }) {
        $major = Get-ReleaseFileMajor $file.FullName
        if ($null -eq $major) {
            continue
        }
        $runtimeDir = $file.DirectoryName
        $appDir = Split-Path $runtimeDir
        if ($appDir.TrimEnd('\', '/') -eq $rootFull) {
            $appDir = $runtimeDir
        }
        $runtimes += @{ RuntimeDir = $runtimeDir; AppDir = $appDir; Major = $major }
        $results.Add((New-ResultRow -RootFull $rootFull -FullName $file.FullName -Kind "Runtime" -Major $major -Detail "Java runtime" -Status "Runtime"))
    }

    # Applications that declare the Java version they need (Ghidra)
    $declaredApps = @()
    foreach ($file in $files | Where-Object { $_.Name -eq "application.properties" }) {
        $javaMin = $null
        $javaMax = ""
        foreach ($line in Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue) {
            if ($line -match '^\s*application\.java\.min\s*=\s*(\S+)') {
                $javaMin = ConvertTo-JavaMajor $Matches[1]
            } elseif ($line -match '^\s*application\.java\.max\s*=\s*(\S+)') {
                $javaMax = $Matches[1]
            }
        }
        if ($null -eq $javaMin) {
            continue
        }
        # Ghidra keeps application.properties in <install>\Ghidra\
        $appDir = Split-Path $file.DirectoryName
        if ($appDir.TrimEnd('\', '/') -eq $rootFull) {
            $appDir = $file.DirectoryName
        }
        $declaredApps += $appDir
        $detail = "application.java.min=$javaMin"
        $status = "OK"
        if ($javaMin -gt $installed) {
            $status = "MISSING Java $javaMin"
        }
        if ($javaMax) {
            $detail += " application.java.max=$javaMax"
            $maxMajor = ConvertTo-JavaMajor $javaMax
            if ($null -ne $maxMajor -and $installed -gt $maxMajor) {
                $status = "Needs Java $javaMin to $maxMajor"
            }
        }
        $results.Add((New-ResultRow -RootFull $rootFull -FullName $file.FullName -Kind "Declared" -Major $javaMin -Detail $detail -Status $status))
    }

    foreach ($file in $files | Where-Object { $_.Extension -eq ".jar" }) {
        if ($file.Length -gt $maxBytes) {
            continue
        }
        if (@($runtimes | Where-Object { Test-UnderDirectory $file.FullName $_.RuntimeDir }).Count -gt 0) {
            continue
        }
        if (@($declaredApps | Where-Object { Test-UnderDirectory $file.FullName $_ }).Count -gt 0) {
            continue
        }
        try {
            $major = Get-JarJavaMajor $file.FullName
        } catch {
            Write-Warning "Unable to read $($file.FullName): $($_.Exception.Message)"
            continue
        }
        if ($null -eq $major) {
            continue
        }

        $bundled = @($runtimes | Where-Object { Test-UnderDirectory $file.FullName $_.AppDir } |
            Sort-Object { $_.AppDir.Length } -Descending)
        if ($bundled.Count -gt 0) {
            $available = [int]$bundled[0].Major
            $detail = "class files for Java $major, bundled Java $available"
            if ($major -le $available) {
                $status = "OK (bundled Java $available)"
            } else {
                $status = "MISSING Java $major (bundled Java $available)"
            }
        } else {
            $detail = "class files for Java $major"
            if ($major -le $installed) {
                $status = "OK"
            } else {
                $status = "MISSING Java $major"
            }
        }
        $results.Add((New-ResultRow -RootFull $rootFull -FullName $file.FullName -Kind "Jar" -Major $major -Detail $detail -Status $status))
    }
}

$sorted = $results | Sort-Object Tool, File

Write-Host ""
Write-Host "Java runtime checked against ($installedSource): Java $installed"
Write-Host ""
Write-Host "Programs that need Java, by major version:"
$sorted | Where-Object { $_.Kind -in @("Jar", "Declared") } |
    Group-Object Major | Sort-Object { [int]$_.Name } | ForEach-Object {
        $tools = ($_.Group | Select-Object -ExpandProperty Tool -Unique) -join ", "
        Write-Host ("  Java {0,-3}: {1} programs in {2}" -f $_.Name, $_.Count, $tools)
    }

$problems = @($sorted | Where-Object { $_.Status -like "MISSING*" -or $_.Status -like "Needs*" })
if ($problems.Count -gt 0) {
    Write-Host ""
    Write-Host "Programs that will not start with the runtime above:" -ForegroundColor Yellow
    $problems | Format-Table Tool, File, Detail, Status -AutoSize | Out-String -Width 4096 | Write-Host
}

if ($CsvPath) {
    $sorted | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
    Write-Host "Saved $(@($sorted).Count) rows to $CsvPath"
}

$sorted

if ($FailOnMissing -and $problems.Count -gt 0) {
    Write-Host "ERROR: $($problems.Count) programs need a newer Java than Java $installed."
    exit 1
}
