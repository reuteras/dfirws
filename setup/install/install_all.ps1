$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# Run install_*.ps1 helper scripts.  Each script is launched in its own
# PowerShell subprocess via Start-Process -Wait so that a fatal error in one
# script (an installer that terminates its parent process, an `exit` call in
# a generated helper, etc.) cannot prevent the next script from running.
$INSTALL_SCRIPTS = Get-ChildItem -Path "${SETUP_PATH}\dfirws" -Filter "install_*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $INSTALL_SCRIPTS) {
    Write-SynchronizedLog "Started install script: $($script.Name)"
    try {
        $proc = Start-Process -Wait -PassThru "${POWERSHELL_EXE}" -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", "`"$($script.FullName)`""
        )
        Write-SynchronizedLog "Finished install script: $($script.Name) (exit code $($proc.ExitCode))"
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