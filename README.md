# DFIR in a Windows Sandbox - dfirws

DFIRWS is an easy way to do DFIR work in a [Windows Sandbox][wsa]. This can be useful if you can't install tools on your computer but are allowed to run a Windows Sandbox. By default Windows Defender isn't running in the sandbox which also makes it easier to analyze malware. The scripts should work with the Windows Sandbox in both Windows 10 and Windows 11.

[![GitHub Super-Linter](https://github.com/reuteras/dfirws/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/super-linter)

## Requirements

You need to have the following programs installed on your computer to be able to run the scripts in this repository.

```PowerShell
winget install 7zip.7zip
winget install Git.Git
winget install Rclone.Rclone
```

Other requirements are handled by downloading tools inside of multiple Windows and prepare the tools for later use there.

The Windows Sandbox feature must be enabled on the host. You can enable it by running the Windows tool **Add and remove Windows features** and adding Windows Sandbox. An alternative is to open a windows terminal as administrator and run:

```PowerShell
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
```

If you haven't enabled the option to run PowerShell scripts you have to start a Windows Terminal or PowerShell prompt and run

```PowerShell
Set-executionPolicy -ExecutionPolicy Bypass
```

For more information about Windows Sandbox look at the Microsoft page [Windows Sandbox][wsa].

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

By default the sandbox will have clipboard redirection off as well as secure defaults for other settings. If you like to enable clipboard copy and paste you should change `<ClipboardRedirection>Disable</ClipboardRedirection>` to `<ClipboardRedirection>Enable</ClipboardRedirection>`. More information about [Windows Sandbox configuration][wsc].

This script will also create the file *./setup/config.txt*. Here you can select the tools you would like to be available in the sandbox. All tools will be downloaded and can be installed later in the sandbox if needed. The difference will be the time it takes to start the sandbox. You can also specify the configuration file to use for Sysmon. You can install extra tools in a running **dfirws** sandbox by using the script **dfirws-install.ps1**. 

If you like to run your own PowerShell code to customise **dfirws** you can change _local/customize.ps1_. Observe that the latest version of PowerShell will be installed when you start **dfirws** which at the moment is PowerShell 7 and that some things are different from earlier versions.

## Downloading tools

Now it's time to start downloading tools included in dfirws. Sandboxes will be started to run and install packages for Python, bash and NodeJS. Therefore you can't have any sandbox running during download since Microsoft only allows one sandbox running at the time. After download the tools will be extracted and prepared for faster usage in the sandbox.
Total space is currently around 14 GB. 

When you download tools you will need a classic GitHub token, create it at [https://github.com/settings/tokens](https://github.com/settings/tokens). This is to make sure that you don't have problems with rate limiting on GitHub.

Download programs and prepare them for use by running:

```PowerShell
.\downloadFiles.ps1
```

If you like to have a more detailed view off the progress during the download (or update) you can run the **PowerShell** variant of **tail -f** after starting **.\downloadFiles.ps1**.

```PowerShell
ls .\log\ | ForEach-Object -Parallel { Get-Content -Path $_ -Wait }
```

## Usage

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
