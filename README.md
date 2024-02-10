[![GitHub Super-Linter](https://github.com/reuteras/dfirws/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/super-linter)

# dfirws: DFIR in Windows

DFIRWS is a solution to do DFIR work in Windows. The tool has been enhanced since its start and now have the following parts.

- **downloadFiles.ps1** - download, update and prepare tools to use for DFIR work.
- **enrichment.ps1** - download data for later enrichment. Currently downloads data from TOR, MaxMind (if you have a key) and a couple of other sources.
- **createSandboxConfig.ps1** - create a Windows Sandbox configuration file for the tools.
  - **dfirws.wsb** - Windows Sandbox configuration file with network disabled.
  - **network_dfirws.wsb** - Windows Sandbox configuration file with network enabled.
- **createVM.ps1** - create a Windows 11 VM with the tools installed.

DFIRWS should work with the Windows Sandbox in both Windows 10 and Windows 11 even tough currently I only test it on Windows 11. The VM only creates a Windows 11 VM.

## Table of contents

- [Requirements](#requirements)
- [Installation and configuration](#installation-and-configuration)
- [Download tools and enrichment data](#download-tools-and-enrichment-data)
- [Usage and configuration of the sandbox](#usage-and-configuration-of-the-sandbox)
- [Usage and configuration of the VM](#usage-and-configuration-of-the-vm)
- [Update](#update)
- [Documentation](#documentation)

## Requirements

You need to have the following programs installed on your computer to be able to run the scripts in this repository (example commands to install them with **winget**).

```PowerShell
winget install 7zip.7zip
winget install Git.Git
winget install Rclone.Rclone
```

**Recommendation:** Exclude the folder where you have the dfirws code from your antivirus program. The reason is that at least Windows Defender will some time classify some tools as malware. Even though I try to exclude those tools I've found that a file can be classified as malware one day and not the next. The choice is yours.

The Windows Sandbox feature must be enabled on the host. This is true even if you only like to build a VM. The Sandbox feature is used to build some tools. You can enable the Sandbox feature by running the Windows tool **Add and remove Windows features** and add Windows Sandbox. An alternative way is to open a Windows terminal as administrator and run:

```PowerShell
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
```

If you haven't enabled the option to run PowerShell scripts you have to start a Windows Terminal or PowerShell prompt as administrator and run

```PowerShell
Set-executionPolicy -ExecutionPolicy Bypass
```

For more information about Windows Sandbox look at the Microsoft page [Windows Sandbox][wsa].

You also need a classic GitHub token, create it at [https://github.com/settings/tokens](https://github.com/settings/tokens). This is due to rate limiting on GitHub.

## Installation and configuration

Start a PowerShell terminal and checkout the code via Git.

```PowerShell
git clone https:/github.com/reuteras/dfirws.git
cd dfirws
```

Create the configuration files for the sandbox by running:

```PowerShell
.\createSandboxConfig.ps1
```

Two different configurations will be created:

- dfirws.wsb - network disabled
- network_dfirws.wsb - network enabled

You can copy the file *config.ps1.template* to *config.ps1* and change the settings to your liking. The file *config.ps1* is used by the scripts to specify token for MaxMind and GitHub (can be entered manually if you don't like to save them in a file). There is also a setting that controls if the Python virtual environment should be built (needed for Ghidrathon). There is a requirement for Visual Studio which is a rather large download.

## Download tools and enrichment data

Before using a sandbox or creating a VM all the tools has to be downloaded and prepared for use in DFIRWS. Sandboxes will be started to run and install packages for Python, bash, Rust and NodeJS. Since Windows only allows on running Sandbox at the time you have to close any running sandbox before running **downloadFiles.ps1**.

Download programs and prepare them for use by running:

```PowerShell
.\downloadFiles.ps1
```

If you like to have a more detailed view off the progress during the download (or update) you can run the **PowerShell** variant of **tail -f** after starting **.\downloadFiles.ps1**.

```PowerShell
ls .\log\ | ForEach-Object -Parallel { Get-Content -Path $_ -Wait }
```

Enrichment data can be downloaded by running:

```PowerShell
.\enrichment.ps1
```

## Usage and configuration of the sandbox

The quickest way to use the tool is to start a sandbox by clicking on **dfirws.wsb** or running **./dfirws.wsb** in a PowerShell terminal. The sandbox will start and the tools will be available after a couple of minutes.

By default the sandbox will have clipboard redirection off as well as secure defaults for other settings. If you like to enable clipboard copy and paste you should change `<ClipboardRedirection>Disable</ClipboardRedirection>` to `<ClipboardRedirection>Enable</ClipboardRedirection>`. More information about [Windows Sandbox configuration][wsc].

To customize the sandbox you can copy *local/default-config.txt* to *local/config.txt* and change the settings to your liking. The file *local/config.txt* is used by the scripts to specify which tools to install when the sandbox starts. Every tool will still be downloaded and can be installed later in the sandbox if needed. The difference will be the time it takes to start the sandbox, i.e. running an installer for a program on every start.

Extra tools can be installed in a running **dfirws** sandbox with the script **dfirws-install.ps1**. To list available tools run **Get-Help dfirws-install.ps1**. To install a tool run **dfirws-install.ps1 -<tool>**.

If you like to run your own PowerShell code to customize **dfirws** you can copy *local/customize.ps1* to *local/customize.ps1* and modify it. Observe that the latest version of PowerShell will be installed when you start **dfirws** which at the moment is PowerShell 7 and that some things are different from earlier versions of PowerShell.

The goal for startup time is set to around one minute on a computer with a Intel Core i7 and the default configuration. The following is an example screen of the sandbox running.

![Screen when installation is done](./resources/images/screen.png)

More usage information is available in the [wiki](https://github.com/reuteras/dfirws/wiki).

## Usage and configuration of the VM

You can create VM by running **.\createVM.ps1**.  Currently only VMWare Workstation is supported on Windows x64. The script will download the Windows 11 ISO and create a VM with the tools installed. The VM will be created in the root folder. The VM will be created with 4 cores and 16 GB of memory. The VM will be created with a 300 GB sparse disk. The VM will be created with a bridged network adapter. The VM will be created with a user named *dfirws* and a password *password*. You can change the settings in by copying *local/default-variables.pkr.hcl* to *local/variables.pkr.hcl* and change the settings to your liking. The file *local/variables.pkr.hcl* is then used by the scripts to specify which settings to use when creating the VM. You can change setting for autounattend to change the default keyboard to US (Swedish is the default).

## Update

Update scripts used to create the sandbox (i.e. this code) by running **git pull** and then update the tools by running **.\downloadFiles.ps1** again. Check *./local/default-config.txt* for changed and added configuration options. You can also opt to only update parts of the included tools. To update Python tools run:

```PowerShell
.\downloadFiles.ps1 -Python
```

To see available options run **Get-Help .\downloadFiles.ps1**.

## Documentation

More information about installed tools are available in the GitHub [wiki][wid].

  [wid]: https://github.com/reuteras/dfirws/wiki/Documentation
  [wsa]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview
  [wsc]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file
