Write-Output $PWD

. ".\resources\download\common.ps1"

# Download Visual Studio Build Tools if not already present
Write-SynchronizedLog "Download Visual Studio buildtools."

if (! (Test-Path "${TOOLS}\VSLayout\Layout.json")) {
    Start-Process -Wait "${SETUP_PATH}\vs_BuildTools.exe" -ArgumentList "--layout .\mount\Tools\VSLayout --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.TestTools.BuildTools --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.CLI.Support --lang En-us --passive"
} else {
    Start-Process -Wait "${SETUP_PATH}\vs_BuildTools.exe" -ArgumentList "--layout .\mount\Tools\VSLayout --passive"
}

# TODO: Add TOOL_DEFINITIONS entries for Visual Studio Build Tools

Write-SynchronizedLog "Visual Studio: Download complete."