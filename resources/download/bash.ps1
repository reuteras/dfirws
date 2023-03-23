param (
    [String] $ScriptRoot=$PSScriptRoot
)

$ScriptRoot = "$ScriptRoot\resources\download"
$ROOT_PATH = Resolve-Path "$ScriptRoot\..\..\"

Write-Output "Download packages for Git for Windows (bash)."

. $ScriptRoot\common.ps1

$mutexName = "Global\dfirwsMutex"
$mutex = New-Object System.Threading.Mutex($false, $mutexName)

if (Test-Path -Path $ROOT_PATH\tmp\download\bash ) {
    Remove-Item -r -Force $ROOT_PATH\tmp\download\bash
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

$mutex.WaitOne()
& $ROOT_PATH\tmp\generate_bash.wsb
Start-Sleep 10
Remove-Item $ROOT_PATH\tmp\generate_bash.wsb

Stop-SandboxWhenDone "$ROOT_PATH\downloads\bash\done" $mutex

Write-Output "Git for Windows (bash) done."