Write-Output $PWD

. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

# Download Visual Studio Build Tools if not already present
Write-SynchronizedLog "Download Visual Studio buildtools."

if (! (Test-Path "${TOOLS}\VSLayout\Layout.json")) {
    Start-Process -Wait "${SETUP_PATH}\vs_BuildTools.exe" -ArgumentList "--layout .\mount\Tools\VSLayout --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.TestTools.BuildTools --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.CLI.Support --lang En-us --passive"
} else {
    Start-Process -Wait "${SETUP_PATH}\vs_BuildTools.exe" -ArgumentList "--layout .\mount\Tools\VSLayout --passive"
}

$TOOL_DEFINITIONS += @{
    Name = "Visual Studio Build Tools"
    Homepage = "https://visualstudio.microsoft.com/visual-cpp-build-tools/"
    Vendor = "Microsoft"
    License = "Microsoft Software License Terms"
    LicenseUrl = "https://visualstudio.microsoft.com/license-terms/"
    Category = "Development"
    Shortcuts = @()
    InstallVerifyCommand = ""
    Verify = @()
    FileExtensions = @()
    Tags = @()
    Notes = "The most comprehensive IDE for .NET and C++ developers on Windows for building web, cloud, desktop, mobile apps, services and games."
    Tips = "Only downloaded when you run downloadFiles.ps1 -VisualStudioBuildTools. Needed for building Python packages with native extensions and other MSVC projects inside the sandbox; the layout is large so keep it optional."
    Usage = "dfirws-install.ps1 -VisualStudioBuildTools"
    SampleCommands = @()
    SampleFiles = @()
    Dependencies = @()
    PythonVersion = ""
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "visualstudiobuildtools"

Write-SynchronizedLog "Visual Studio: Download complete."
