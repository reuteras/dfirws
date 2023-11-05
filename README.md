# DFIR in a Windows Sandbox - dfirws

DFIRWS is an easy way to do DFIR work in a [Windows Sandbox][wsa]. This can be useful if you can't install tools on your computer but are allowed to run a Windows Sandbox. By default Windows Defender isn't running in the sandbox which also makes it easier to analyze malware. The scripts should work with the Windows Sandbox in both Windows 10 and Windows 11.

[![GitHub Super-Linter](https://github.com/reuteras/dfirws/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/super-linter)

## Requirements

You need to have git installed to download files and resources. **7-zip** must be installed to extract files. The program **rclone** is used to copy files. Install the tools you don't already have installed with the following commands.

```PowerShell
winget install 7zip.7zip
winget install Git.Git
winget install Rclone.Rclone
```

Other requirements are handled by starting different Windows sandboxes during download and installing the tools inside the sandboxes.

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

You will need a classic GitHub token, see [https://github.com/settings/tokens](https://github.com/settings/tokens), to make sure that don't have problems with rate limiting on GitHub.

Now it's time to start downloading tools included in dfirws. Sandboxes will be started to run and install packages for Python, bash and NodeJS. Therefore you can't have any sandbox running during download since Microsoft only allows one sandbox running at the time. After download the tools will be extracted and prepared for faster usage in the sandbox.
Total space is currently around 8 GB. Download and preparations are done via

```PowerShell
.\downloadFiles.ps1
```

If you like to have a more detailed view off the progress during the download (or update) you can run the **PowerShell** variant of **tail -f** after starting **.\downloadFiles.ps1**.

```PowerShell
ls .\log\ | ForEach-Object -Parallel { Get-Content -Path $_ -Wait }
```

After download is finished you can create configuration files for the sandbox with your local path by running the following command:

```PowerShell
.\createSandboxConfig.ps1
```

Two different configurations will be created:

- dfirws.wsb - no network
- network_dfirws.wsb - network enabled

This will also create *./setup/config.txt* file. Here you can select the tools you would like to be available in the sandbox. All tools will still be downloaded and can be installed later in the sandbox if needed. You can also turn off Sysmon and specify the configuration file to use. By default the sandbox will use the old expanded format for right-click but that can be changed.

By default this sandbox will have clipboard redirection off as well as limit other settings. If you like to enable clipboard copy and paste you should change `<ClipboardRedirection>Disable</ClipboardRedirection>` to `<ClipboardRedirection>Enable</ClipboardRedirection>`. More information about [Windows Sandbox configuration][wsc].

## Usage

Start the sandbox by clicking on **dfirws.wsb** or running **./dfirws.wsb** in a PowerShell terminal. Startup takes around one minute on a fast computer with the default configuration. The following is an example screen of when the sandbox is running.

![Screen when installation is done](./resources/images/screen.png)

## Customize

Copy *.\local\example-customize.ps1* to *.\local\customize.ps1* and add your own PowerShell code to that file. Files needed by your script should be placed in the folder *.\local*.

## Update

Update scripts used to create the sandbox (i.e. this code) by running **git pull** and then update programs and tools by running **.\downloadFiles.ps1** again. Check *./setup/default-config.txt* for new configuration options.

## Documentation

More information about installed tools are available in the GitHub [wiki][wid].

  [wid]: https://github.com/reuteras/dfirws/wiki/Documentation
  [wsa]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview
  [wsc]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file
