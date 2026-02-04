# patch-vite-config.ps1
param(
  [string]$ConfigPath = ".\vite.config.ts"
)

$marker = "// __LUMEN_SANDBOX_PATCH__"

if (-not (Test-Path $ConfigPath)) {
  throw "File not found: $ConfigPath"
}

$content = Get-Content $ConfigPath -Raw -Encoding UTF8

if ($content -match [regex]::Escape($marker)) {
  Write-Host "Patch already applied."
  exit 0
}

function Ensure-ResolvePreserveSymlinks([string]$text) {
  if ($text -match "(?ms)^\s*resolve\s*:\s*\{.*?\}") {
    # resolve exists: add preserveSymlinks if missing
    if ($text -notmatch "(?ms)^\s*resolve\s*:\s*\{.*?\bpreserveSymlinks\s*:") {
      $text = [regex]::Replace(
        $text,
        "(?ms)(^\s*resolve\s*:\s*\{)",
        "`$1`n    preserveSymlinks: true,",
        1
      )
    }
    return $text
  }

  # resolve doesn't exist: insert it near top (right after defineConfig({)
  if ($text -match "export\s+default\s+defineConfig\s*\(\s*\{") {
    $inject = @"
$marker
  resolve: { preserveSymlinks: true },
"@
    # put marker + resolve right after defineConfig({
    $text = [regex]::Replace(
      $text,
      "(?ms)(export\s+default\s+defineConfig\s*\(\s*\{)",
      "`$1`n$inject",
      1
    )
    return $text
  }

  throw "Could not find 'export default defineConfig({' in $ConfigPath"
}

function Ensure-ServerWatchPolling([string]$text) {
  # If there is no server block, create one (single server key).
  if ($text -notmatch "(?ms)^\s*server\s*:") {
    $text = [regex]::Replace(
      $text,
      "(?ms)(export\s+default\s+defineConfig\s*\(\s*\{)",
      "`$1`n  server: { watch: { usePolling: true, interval: 250 } },",
      1
    )
    return $text
  }

  # server exists. Ensure watch exists.
  if ($text -notmatch "(?ms)^\s*server\s*:\s*\{.*?\bwatch\s*:") {
    # Insert watch block at top of server object
    $text = [regex]::Replace(
      $text,
      "(?ms)(^\s*server\s*:\s*\{)",
      "`$1`n    watch: { usePolling: true, interval: 250 },",
      1
    )
    return $text
  }

  # watch exists inside server. Ensure usePolling + interval.
  if ($text -notmatch "(?ms)^\s*server\s*:\s*\{.*?\bwatch\s*:\s*\{.*?\busePolling\s*:") {
    $text = [regex]::Replace(
      $text,
      "(?ms)(^\s*server\s*:\s*\{.*?\bwatch\s*:\s*\{)",
      "`$1`n      usePolling: true,",
      1
    )
  }

  if ($text -notmatch "(?ms)^\s*server\s*:\s*\{.*?\bwatch\s*:\s*\{.*?\binterval\s*:") {
    $text = [regex]::Replace(
      $text,
      "(?ms)(^\s*server\s*:\s*\{.*?\bwatch\s*:\s*\{)",
      "`$1`n      interval: 250,",
      1
    )
  }

  return $text
}

# Apply merges (do NOT add duplicate keys)
$content = Ensure-ResolvePreserveSymlinks $content
$content = Ensure-ServerWatchPolling $content

# If marker wasn't injected already (because resolve existed), prepend it once at top.
if ($content -notmatch [regex]::Escape($marker)) {
  $content = $marker + "`n" + $content
}

Set-Content $ConfigPath -Value $content -Encoding UTF8
Write-Host "Patch applied (merged into existing config without duplicate keys)."
