$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# Run install_*.ps1 helper scripts.  Each script is launched in its own
# PowerShell subprocess via Start-Process -Wait so that a fatal error in one
# script (an installer that terminates its parent process, an `exit` call in
# a generated helper, etc.) cannot prevent the next script from running.
#
# stdout/stderr are redirected to C:\log (mapped back to the host) instead of
# being left in the subprocess's own console window, which closes the moment
# the process exits. Without this, a hard crash in one of the per-tool
# install commands (e.g. a COM/Appx deployment failure that takes down the
# whole PowerShell host rather than raising a catchable .NET exception) is
# invisible after the fact - only the numeric exit code survives.
# C:\log is mapped back to the host and persists across sandbox runs, so stale
# logs from a script that no longer exists (excluded source, skipped flag, ...)
# would otherwise linger and could be mistaken for current output.
if (Test-Path "C:\log\install-logs") {
    Remove-Item -Recurse -Force "C:\log\install-logs" | Out-Null
}
New-Item -ItemType Directory -Force -Path "C:\log\install-logs" | Out-Null
$INSTALL_SCRIPTS = Get-ChildItem -Path "${SETUP_PATH}\dfirws" -Filter "install_*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $INSTALL_SCRIPTS) {
    Write-SynchronizedLog "Started install script: $($script.Name)"
    $stdoutLog = "C:\log\install-logs\$($script.BaseName).stdout.log"
    $stderrLog = "C:\log\install-logs\$($script.BaseName).stderr.log"
    try {
        $proc = Start-Process -Wait -PassThru "${POWERSHELL_EXE}" -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", "`"$($script.FullName)`""
        ) -RedirectStandardOutput $stdoutLog -RedirectStandardError $stderrLog
        Write-SynchronizedLog "Finished install script: $($script.Name) (exit code $($proc.ExitCode))"
        if ($proc.ExitCode -ne 0) {
            Write-SynchronizedLog "ERROR: $($script.Name) exited with code $($proc.ExitCode). See install-logs\$($script.BaseName).stderr.log for details."
        }
    }
    catch {
        Write-SynchronizedLog "ERROR in install script $($script.Name): $_"
    }
}

Write-SynchronizedLog "Install all tools in the sandbox."
Write-OutPut "Install all tools in the sandbox."
if (Test-Path -Path C:\venv\visualstudio.txt) {
    Write-SynchronizedLog ([string](dfirws-install.ps1 -VisualStudioBuildTools))
}

Write-SynchronizedLog "Install all tools in the sandbox completed."
if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}