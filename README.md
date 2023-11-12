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

Other requirements are handled by starting multiple Windows sandboxes during download and preparing the tools inside the sandboxes.

Windows Sandbox must be enabled on the host. You can enable it by running the Windows tool **Add and remove Windows features** and adding Windows Sandbox. An alternative is to open a windows terminal as administrator and run:

```PowerShell
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
```

If you haven't enabled the option to run PowerShell scripts you have to start a Windows Terminal or PowerShell prompt and run

```PowerShell
Set-executionPolicy -ExecutionPolicy bypass
```

For more information about requirements for the sandbox look at the Microsoft page [Windows Sandbox][wsa].

## Installation and configuration

Start a PowerShell terminal and checkout the code via Git.

```PowerShell
git clone https:/github.com/reuteras/dfirws.git
cd dfirws
```

During download of the tolls you will need a classic GitHub token, see [https://github.com/settings/tokens](https://github.com/settings/tokens), to make sure that don't have problems with rate limiting on GitHub.

Now it's time to start downloading tools included in dfirws. Sandboxes will be started to run and install packages for Python, bash and NodeJS. Therefore you can't have any sandbox running during download since Microsoft only allows one sandbox running at the time. After download the tools will be extracted and prepared for faster usage in the sandbox.
Total space is currently around 8 GB. Download and preparations are done via

```PowerShell
.\downloadFiles.ps1
```

If you like to have a more detailed view off the progress during the download (or update) you can run the **PowerShell** variant of **tail -f** after starting **.\downloadFiles.ps1**.

```PowerShell
ls .\log\ | ForEach-Object -Parallel { Get-Content -Path $_ -Wait }
```

After the **downloadFiles.ps1** script is finished you can create configuration files for the sandbox with your local path by running the following command:

```PowerShell
.\createSandboxConfig.ps1
```

Two different configurations will be created:

- dfirws.wsb - network disabled
- network_dfirws.wsb - network enabled

This script will also create the file *./setup/config.txt*. Here you can select the tools you would like to be available in the sandbox. All tools will be downloaded and can be installed later in the sandbox if needed. The difference will be the time it takes to start the sandbox. You can also turn off Sysmon and specify the configuration file to use.

By default the sandbox will have clipboard redirection off as well as secure defaults for other settings. If you like to enable clipboard copy and paste you should change `<ClipboardRedirection>Disable</ClipboardRedirection>` to `<ClipboardRedirection>Enable</ClipboardRedirection>`. More information about [Windows Sandbox configuration][wsc].

## Usage

Start the sandbox by clicking on **dfirws.wsb** or running **./dfirws.wsb** in a PowerShell terminal. Startup takes around one minute on a computer with a Intel Core i7 and the default configuration. The following is an example screen of when the sandbox is running.

![Screen when installation is done](./resources/images/screen.png)

## Customize

Copy *.\local\example-customize.ps1* to *.\local\customize.ps1* and add your own PowerShell code to that file. Files needed by your script should be placed in the folder *.\local*.

## Update

Update scripts used to create the sandbox (i.e. this code) by running **git pull** and then update the tools by running **.\downloadFiles.ps1** again. Check *./setup/default-config.txt* for new configuration options.

## Documentation

More information about installed tools are available in the GitHub [wiki][wid].

  [wid]: https://github.com/reuteras/dfirws/wiki/Documentation
  [wsa]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview
  [wsc]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file
