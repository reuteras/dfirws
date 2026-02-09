$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

. "C:\Users\WDAGUtilityAccount\Documents\tools\wscommon.ps1"

# Run tests in $SETUP_PATH\dfirws\install_*.ps1 if they exists
$INSTALL_SCRIPTS = Get-ChildItem -Path "${SETUP_PATH}\dfirws" -Filter "install_*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $INSTALL_SCRIPTS) {
    Write-SynchronizedLog "Running install script: $($script.FullName)"
    & $script.FullName
}

Write-SynchronizedLog "Install all tools in the sandbox."
Write-OutPut "Install all tools in the sandbox."
Write-SynchronizedLog ([string](dfirws-install.ps1 -ClamAV))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Git))
Write-SynchronizedLog ([string](dfirws-install.ps1 -GoLang))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Kape))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Node))
Write-SynchronizedLog ([string](dfirws-install.ps1 -Rust))
if (Test-Path -Path C:\venv\visualstudio.txt) {
    Write-SynchronizedLog ([string](dfirws-install.ps1 -VisualStudioBuildTools))
}

Write-SynchronizedLog "Install all tools in the sandbox completed."
if (Test-Path -Path "${TOOLS}\Debug") {
    Read-Host "Press Enter to continue"
}

exit 0