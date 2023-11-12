param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
$ROOT_PATH = Resolve-Path "$ScriptRoot\..\..\"

. $ScriptRoot\common.ps1

Write-DateLog "Download packages for Git for Windows (bash)."
Write-Output "" > .\log\bash.txt

$mutexName = "Global\dfirwsMutex"
$mutex = New-Object System.Threading.Mutex($false, $mutexName)

if (Test-Path -Path $ROOT_PATH\tmp\downloads\bash ) {
    Remove-Item -r -Force $ROOT_PATH\tmp\downloads\bash
}

$packages = "bash-completion", `
    "bc", `
    "binutils", `
    "cpio", `
    "expect", `
    "gnu-netcat", `
    "nasm", `
    "pv", `
    "python2", `
    "python2-pip", `
    "python2-setuptools", `
    "rsync", `
    "tree", `
    "zsh", `
    "zstd"

foreach ($package in $packages) {
    $url = Get-DownloadUrlMSYS "$package"
    Get-FileFromUri -uri "$url" -FilePath ".\downloads\bash\$package.pkg.tar.zst"
}

(Get-Content $ROOT_PATH\resources\templates\generate_bash.wsb.template).replace('__SANDBOX__', $ROOT_PATH) | Set-Content $ROOT_PATH\tmp\generate_bash.wsb

$mutex.WaitOne() | Out-Null
& $ROOT_PATH\tmp\generate_bash.wsb
Start-Sleep 10
Remove-Item $ROOT_PATH\tmp\generate_bash.wsb

Stop-SandboxWhenDone "$ROOT_PATH\downloads\bash\done" $mutex

Write-DateLog "Git for Windows (bash) done."
