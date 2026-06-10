# Pester tests for the pure logic in resources/download/changelog.ps1.
# The script under test resolves all paths relative to its own location, so the
# tests copy it into a temporary directory tree and seed metadata/state files
# there. Run with: pwsh -Command "Invoke-Pester tests"

BeforeAll {
    # Stub used by the script under test.
    function Write-DateLog { param([string]$Message) }

    # Re-creates the temp repo layout and dot-sources a fresh copy of changelog.ps1.
    function Initialize-TestRepo {
        $root = Join-Path ([System.IO.Path]::GetTempPath()) "dfirws-changelog-test-$([guid]::NewGuid())"
        New-Item -ItemType Directory -Force -Path (Join-Path $root "resources/download") | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $root "downloads") | Out-Null
        Copy-Item (Join-Path $PSScriptRoot "../resources/download/changelog.ps1") (Join-Path $root "resources/download/changelog.ps1")
        return $root
    }

    # Writes a {Name, Version, Source[, Venv]} metadata JSON for a sandbox-side source.
    function Write-ToolMetadata {
        param($Root, $Source, $Name, $Version, $Venv)
        $dir = Join-Path $Root "mount/Tools/.metadata/$Source"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        $data = [ordered]@{ Name = $Name; Version = $Version; Source = $Source }
        $fileName = "$Name.json"
        if ($Venv) {
            $data["Venv"] = $Venv
            $fileName = "${Venv}__$Name.json"
        }
        $data | ConvertTo-Json | Set-Content -Path (Join-Path $dir $fileName)
    }

    # Writes changelog ignore entries to local/defaults/changelog-ignore.txt.
    function Write-IgnoreList {
        param($Root, [string[]]$Entries, [string]$File = "local/defaults/changelog-ignore.txt")
        $path = Join-Path $Root $File
        New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
        $Entries | Set-Content -Path $path
    }

    # Same URI hashing scheme as Get-FileFromUri in common.ps1 / Get-UriEtag.
    function Write-EtagFile {
        param($Root, $Uri, $Etag)
        $stream = [System.IO.MemoryStream]::new()
        $writer = [System.IO.StreamWriter]::new($stream)
        $writer.write("$Uri")
        $writer.Flush()
        $stream.Position = 0
        $hash = Get-FileHash -InputStream $stream -Algorithm SHA256 | Select-Object -ExpandProperty Hash
        $dir = Join-Path $Root "downloads/.etag"
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content -Path (Join-Path $dir $hash) -Value $Etag -NoNewline
    }
}

Describe "Get-VersionFromUrl" {
    BeforeAll {
        $root = Initialize-TestRepo
        . (Join-Path $root "resources/download/changelog.ps1")
    }
    AfterAll { Remove-Item -Recurse -Force $root }

    It "extracts a v-prefixed version from a path segment" {
        Get-VersionFromUrl -Url "https://example.com/releases/v1.2.3/tool.zip" | Should -Be "1.2.3"
    }

    It "extracts a version embedded in a file name" {
        Get-VersionFromUrl -Url "https://example.com/tool-2.10.1-win.zip" | Should -Be "2.10.1"
    }

    It "returns null when no version is present" {
        Get-VersionFromUrl -Url "https://example.com/latest/tool.zip" | Should -BeNullOrEmpty
    }
}

Describe "HTTP snapshot format compatibility" {
    BeforeAll {
        $root = Initialize-TestRepo
        . (Join-Path $root "resources/download/changelog.ps1")
    }
    AfterAll { Remove-Item -Recurse -Force $root }

    It "reads the legacy plain-string format" {
        Get-HttpSnapshotUrl -Entry "https://example.com/tool.zip" | Should -Be "https://example.com/tool.zip"
        Get-HttpSnapshotEtag -Entry "https://example.com/tool.zip" | Should -BeNullOrEmpty
    }

    It "reads the {Url, Etag} object format" {
        $entry = [PSCustomObject]@{ Url = "https://example.com/tool.zip"; Etag = "abc123" }
        Get-HttpSnapshotUrl -Entry $entry | Should -Be "https://example.com/tool.zip"
        Get-HttpSnapshotEtag -Entry $entry | Should -Be "abc123"
    }
}

Describe "Get-UriEtag" {
    BeforeAll {
        $root = Initialize-TestRepo
        . (Join-Path $root "resources/download/changelog.ps1")
    }
    AfterAll { Remove-Item -Recurse -Force $root }

    It "reads the cached etag for a URI" {
        Write-EtagFile -Root $root -Uri "https://example.com/a.zip" -Etag '"etag-value-1"'
        Get-UriEtag -Uri "https://example.com/a.zip" | Should -Be '"etag-value-1"'
    }

    It "returns null when no etag is cached" {
        Get-UriEtag -Uri "https://example.com/never-downloaded.zip" | Should -BeNullOrEmpty
    }
}

Describe "Update-ToolChangelog" {
    BeforeEach {
        $root = Initialize-TestRepo
        . (Join-Path $root "resources/download/changelog.ps1")
        $changelogFile = Join-Path $root "downloads/CHANGELOG.md"
        $versionsFile = Join-Path $root "downloads/.changelog/versions.json"
    }
    AfterEach { Remove-Item -Recurse -Force $root }

    It "records a baseline without writing an entry on the first run" {
        Write-ToolMetadata -Root $root -Source "cargo" -Name "dfir-toolkit" -Version "0.12.0"
        Update-ToolChangelog
        Test-Path $versionsFile | Should -BeTrue
        Test-Path $changelogFile | Should -BeFalse
    }

    It "reports a version change for a cargo tool" {
        Write-ToolMetadata -Root $root -Source "cargo" -Name "dfir-toolkit" -Version "0.12.0"
        Update-ToolChangelog
        Write-ToolMetadata -Root $root -Source "cargo" -Name "dfir-toolkit" -Version "0.12.1"
        Update-ToolChangelog
        $content = Get-Content $changelogFile -Raw
        $content | Should -Match "Updated Tools"
        $content | Should -Match ([regex]::Escape("**dfir-toolkit** (cargo: dfir-toolkit): 0.12.0 -> 0.12.1"))
    }

    It "reports new go and msys2 tools after the baseline run" {
        Write-ToolMetadata -Root $root -Source "cargo" -Name "dfir-toolkit" -Version "0.12.0"
        Update-ToolChangelog
        Write-ToolMetadata -Root $root -Source "go" -Name "protodump" -Version "v0.0.0-20240101"
        Write-ToolMetadata -Root $root -Source "msys2" -Name "gcc" -Version "13.2.0-1"
        Update-ToolChangelog
        $content = Get-Content $changelogFile -Raw
        $content | Should -Match "New Tools"
        $content | Should -Match ([regex]::Escape("**protodump** (go: protodump): v0.0.0-20240101"))
        $content | Should -Match ([regex]::Escape("**gcc** (msys2: gcc): 13.2.0-1"))
    }

    It "reports raw script updates as content changes without hashes" {
        Write-ToolMetadata -Root $root -Source "raw" -Name "sigs.py" -Version "aaaaaaaaaaaa"
        Update-ToolChangelog
        Write-ToolMetadata -Root $root -Source "raw" -Name "sigs.py" -Version "bbbbbbbbbbbb"
        Update-ToolChangelog
        $content = Get-Content $changelogFile -Raw
        $content | Should -Match ([regex]::Escape("**sigs.py** (raw: sigs.py): updated (content changed)"))
        $content | Should -Not -Match "aaaaaaaaaaaa"
    }

    It "detects a content change behind a mutable URL via the etag" {
        # First run records the version baseline and returns before the HTTP
        # snapshot is handled, so the HTTP baseline lands on the second run.
        Write-ToolMetadata -Root $root -Source "cargo" -Name "dfir-toolkit" -Version "0.12.0"
        Update-ToolChangelog

        $url = "https://example.com/latest/tool.zip"
        "URL,Name`n$url,MutableTool" | Set-Content (Join-Path $root "downloads/tools_downloaded.csv")
        Write-EtagFile -Root $root -Uri $url -Etag '"etag-one"'
        Update-ToolChangelog

        Write-EtagFile -Root $root -Uri $url -Etag '"etag-two"'
        Update-ToolChangelog
        $content = Get-Content $changelogFile -Raw
        $content | Should -Match ([regex]::Escape("**MutableTool**: updated (content changed, same URL)"))
    }

    It "tracks pip packages per venv and renders the venv in the identifier" {
        Write-ToolMetadata -Root $root -Source "pip" -Name "oletools" -Version "0.60.1" -Venv "default"
        Write-ToolMetadata -Root $root -Source "pip" -Name "oletools" -Version "0.59.0" -Venv "white-phoenix"
        Update-ToolChangelog
        Write-ToolMetadata -Root $root -Source "pip" -Name "oletools" -Version "0.60.2" -Venv "default"
        Update-ToolChangelog
        $content = Get-Content $changelogFile -Raw
        $content | Should -Match ([regex]::Escape("**oletools** (pip: default/oletools): 0.60.1 -> 0.60.2"))
        # The white-phoenix copy did not change and must not be reported.
        $content | Should -Not -Match ([regex]::Escape("white-phoenix/oletools"))
    }

    It "suppresses pip packages on the ignore list" {
        Write-IgnoreList -Root $root -Entries @("# comment", "pip:six", "pip:flatten_json")
        Write-ToolMetadata -Root $root -Source "pip" -Name "oletools" -Version "0.60.1" -Venv "default"
        Write-ToolMetadata -Root $root -Source "pip" -Name "six" -Version "1.16.0" -Venv "default"
        # Hyphen/underscore and case differences must still match.
        Write-ToolMetadata -Root $root -Source "pip" -Name "Flatten-JSON" -Version "0.1.14" -Venv "default"
        Update-ToolChangelog
        Write-ToolMetadata -Root $root -Source "pip" -Name "oletools" -Version "0.60.2" -Venv "default"
        Write-ToolMetadata -Root $root -Source "pip" -Name "six" -Version "1.17.0" -Venv "default"
        Write-ToolMetadata -Root $root -Source "pip" -Name "Flatten-JSON" -Version "0.1.15" -Venv "default"
        Update-ToolChangelog
        $content = Get-Content $changelogFile -Raw
        $content | Should -Match ([regex]::Escape("**oletools**"))
        $content | Should -Not -Match "six"
        $content | Should -Not -Match "Flatten"
    }

    It "applies a source-prefixed ignore entry only to that source" {
        Write-IgnoreList -Root $root -Entries @("pip:graphviz")
        Write-ToolMetadata -Root $root -Source "pip" -Name "graphviz" -Version "0.20.1" -Venv "default"
        Write-ToolMetadata -Root $root -Source "msys2" -Name "graphviz" -Version "9.0.0-1"
        Update-ToolChangelog
        Write-ToolMetadata -Root $root -Source "pip" -Name "graphviz" -Version "0.20.3" -Venv "default"
        Write-ToolMetadata -Root $root -Source "msys2" -Name "graphviz" -Version "10.0.1-1"
        Update-ToolChangelog
        $content = Get-Content $changelogFile -Raw
        $content | Should -Match ([regex]::Escape("**graphviz** (msys2: graphviz): 9.0.0-1 -> 10.0.1-1"))
        $content | Should -Not -Match ([regex]::Escape("pip: default/graphviz"))
    }

    It "merges user entries from local/changelog-ignore.txt with the defaults" {
        Write-IgnoreList -Root $root -Entries @("pip:six")
        Write-IgnoreList -Root $root -Entries @("pip:oletools") -File "local/changelog-ignore.txt"
        Write-ToolMetadata -Root $root -Source "pip" -Name "six" -Version "1.16.0" -Venv "default"
        Write-ToolMetadata -Root $root -Source "pip" -Name "oletools" -Version "0.60.1" -Venv "default"
        Write-ToolMetadata -Root $root -Source "pip" -Name "pefile" -Version "2024.8.26" -Venv "default"
        $versions = Get-ChangelogCurrentVersions
        @($versions.Keys) | Should -Be @("pip:default:pefile")
    }

    It "upgrades a legacy string-format HTTP snapshot without a false update" {
        Write-ToolMetadata -Root $root -Source "cargo" -Name "dfir-toolkit" -Version "0.12.0"
        Update-ToolChangelog

        # Simulate state saved by the previous changelog version: plain URL strings.
        $url = "https://example.com/latest/tool.zip"
        $snapshotDir = Join-Path $root "downloads/.changelog"
        '{ "MutableTool": "' + $url + '" }' | Set-Content (Join-Path $snapshotDir "http_snapshot.json")
        "URL,Name`n$url,MutableTool" | Set-Content (Join-Path $root "downloads/tools_downloaded.csv")
        Write-EtagFile -Root $root -Uri $url -Etag '"etag-one"'

        Update-ToolChangelog
        # Same URL, no stored etag in the old format: no entry should be produced.
        Test-Path (Join-Path $root "downloads/CHANGELOG.md") | Should -BeFalse

        # The snapshot is upgraded to the {Url, Etag} format on save.
        $saved = Get-Content (Join-Path $snapshotDir "http_snapshot.json") -Raw | ConvertFrom-Json
        $saved.MutableTool.Url | Should -Be $url
        $saved.MutableTool.Etag | Should -Be '"etag-one"'
    }
}
