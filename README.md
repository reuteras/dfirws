# dfirws: DFIR in a Windows Sandbox

DFIRWS is a solution to do DFIR work in a [Windows Sandbox][wsa] and analyze malware and much more. The sandbox includes a many open source tools and its easy to extend it with more tools. The sandbox is also easy to customize with your own tools and scripts.

DFIRWS should work with the Windows Sandbox in both Windows 10 and Windows 11 even tough currently only Windows 11 is tested.

[![GitHub Super-Linter](https://github.com/reuteras/dfirws/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/super-linter)

## Requirements

You need to have the following programs installed on your computer to be able to run the scripts in this repository.

```PowerShell
winget install 7zip.7zip
winget install Git.Git
winget install Rclone.Rclone
```

The Windows Sandbox feature must be enabled on the host. You can enable it by running the Windows tool **Add and remove Windows features** and adding Windows Sandbox. An alternative is to open a windows terminal as administrator and run:

```PowerShell
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
```

If you haven't enabled the option to run PowerShell scripts you have to start a Windows Terminal or PowerShell prompt as administrator and run

```PowerShell
Set-executionPolicy -ExecutionPolicy Bypass
```

For more information about Windows Sandbox look at the Microsoft page [Windows Sandbox][wsa].

You also need a classic GitHub token, create it at [https://github.com/settings/tokens](https://github.com/settings/tokens). This is to make sure that you don't have problems with rate limiting on GitHub.

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

## Download tools

Before use all the tools has to be downloaded and prepared for use in DFIRWS. Sandboxes will be started to run and install packages for Python, bash, Rust and NodeJS. Therefore you can't have any sandbox running during download since Microsoft only allows one sandbox running at the time.

When you download tools you will need a classic GitHub token, create it at [https://github.com/settings/tokens](https://github.com/settings/tokens). This is to make sure that you don't have problems with rate limiting on GitHub.

Download programs and prepare them for use by running:

```PowerShell
.\downloadFiles.ps1
```

If you like to have a more detailed view off the progress during the download (or update) you can run the **PowerShell** variant of **tail -f** after starting **.\downloadFiles.ps1**.

```PowerShell
ls .\log\ | ForEach-Object -Parallel { Get-Content -Path $_ -Wait }
```

## Usage and configuration

By default the sandbox will have clipboard redirection off as well as secure defaults for other settings. If you like to enable clipboard copy and paste you should change `<ClipboardRedirection>Disable</ClipboardRedirection>` to `<ClipboardRedirection>Enable</ClipboardRedirection>`. More information about [Windows Sandbox configuration][wsc].

The script will also create *./setup/config.txt*. Here you can select the tools that should always be available when you run the sandbox. All tools will be downloaded and can be installed later in the sandbox if needed. The difference will be the time it takes to start the sandbox, i.e. running an installer for a program on every start.
Extra tools can be installed in a running **dfirws** sandbox with the script **dfirws-install.ps1**.

If you like to run your own PowerShell code to customize **dfirws** you can change *local/customize.ps1*. Observe that the latest version of PowerShell will be installed when you start **dfirws** which at the moment is PowerShell 7 and that some things are different from earlier versions.

Start the sandbox by clicking on **dfirws.wsb** or running **./dfirws.wsb** in a PowerShell terminal. The goal for startup time is set to one minute on a computer with a Intel Core i7 and the default configuration. The following is an example screen of when the sandbox is running.

![Screen when installation is done](./resources/images/screen.png)

More usage information is available in the [wiki](https://github.com/reuteras/dfirws/wiki).

## Update

Update scripts used to create the sandbox (i.e. this code) by running **git pull** and then update the tools by running **.\downloadFiles.ps1** again. Check *./setup/default-config.txt* for changed configuration options. You can also select to update parts of the included tools based on how they are downloaded. To update Python tools run:

```PowerShell
.\downloadFiles.ps1 --python
```

## Documentation

More information about installed tools are available in the GitHub [wiki][wid].

  [wid]: https://github.com/reuteras/dfirws/wiki/Documentation
  [wsa]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview
  [wsc]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file
