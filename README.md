# DFIR in a Windows Sandbox - dfirws

DFIRWS is an easy way to do DFIR work in a [Windows Sandbox][wsa]. This can be useful if you can't install tools on your computer but are allowed to run a Windows Sandbox. The sandbox will also add one layer of security. The scripts should work in Windows Sandbox on both Windows 10 and Windows 11.

[![GitHub Super-Linter](https://github.com/reuteras/dfirws/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

## Requirements

You need to have git and rclone installed to download files and resources. 7-zip and Python 3.10 must also be installed. Install with

```
winget install 7zip.7zip
winget install Git.Git
winget install Python.Python.3.10
winget install Rclone.Rclone
```

## Installation and configuration

First enable Windows Sandbox by running **Add and remove Windows features** and adding Windows Sandbox.

Now start a PowerShell terminal and download the code. You have to have git available to use this tool. Not only to checkout the code from the repository.

	git clone https:/github.com/reuteras/dfirws.git
	cd dfirws

Create configuration with your local path by running the following command:

	.\createSandboxConfig.ps1

This will also create *./setup/config.txt*. Select the tools you would like to be available in the Sandbox here. All tools will still be downloaded and can be installed later in the Sandbox.

Download all binaries and scripts with the help of the following command:

	.\downloadFiles.ps1

If you like to have a more detailed view off the progress during the download (and update) you can run the **PowerShell** variant of **tail -f**:

    Get-Content .\log\log.txt -Wait

## Usage

Start the Sandbox by clicking on **dfirws.wsb** or running **./dfirws.wsb** in a PowerShell terminal. Startup takes a just under one minute on a fast computer with the default configuration. The following is an example screen of when the installation is done.

![Screen when installation is done](./resources/images/screen.png)

## Tools

The following tools are available.

- [Amazon Corretto][amc]
- [BeaconHunter][bhu]
- [Bytecode Viewer][bcv]
- [capa][cap]
- [chainsaw][cha]
- [cmder][cer] (will probably be removed in favour of git bash)
- [Cutter][cut]
- [CyberChef][cyb]
- [DensityScout][den]
- [dnSpy][dns] (by dnSpyEx which is a unofficial continuation of the dnSpy project)
- [exiftool][ext]
- [flare-fakenet-ng][ffn]
- [flare-floss][flf]
- [fq][fq]
- [FullEventLogView][fel]
- [Ghidra][ghi]
- [Git][git]
- [GoReSym][grs]
- [HxD][hxd]
- [jq][jq]
- [Jumplist-Browser][jub]
- [LibreOffice][lio]
- [LOKI][lok]
- [Malcat][mal]
- [MessageViewer][mev]
- [ncat][nca]
- [Notepad++][not] with the following added plugins:
  - [comparePlus][ncp]
- [PdfStream Dumper][psd]
- [PE-bear][peb]
- [PEstudio][pes]
- [Python][pyt]
- [qpdf][qpd]
- [ripgrep][rip]
- [scdbg][scd]
- [sqlite][sql] cli
- [SysinternalsSuite][syi]
- [Sysmon][sym] started with [SwiftOnSecurity sysmon-config][sws]
- [Thumbcache viewer][thu]
- [TrID][tri]
- [x64dbg][xdb]
- [upx][upx]
- [visidata][vis]
- [Visual Studio Code][vsc]
- [yara][yar]
- [Zimmerman Tools][zim]
- [Selected][sdi] scripts from [Didier Stevens][dis]
- Selected pip packages for [Python][pip]

Downloaded but not installed by default:

- [Wireshark][wis]
- [npcap][npc]

Downloaded git repositories:

- https://github.com/keydet89/Events-Ripper.git
- https://github.com/Neo23x0/evt2sigma.git
- https://github.com/Neo23x0/signature-base.git
- https://github.com/pan-unit42/dotnetfile
- https://github.com/SigmaHQ/sigma.git
- https://github.com/volexity/threat-intel.git

**Observe that some of the repositories above might trigger alerts from antivirus tools!**

## Customize

Rename *.\local\example-customize.ps1* to *.\local\customize.ps1* and add your own PowerShell code to that file. Files needed should be placed in *.\local*.

## Documentation

Below are sections similar to the [REMnux docs][rem].

### Examine static properties of files

#### General

- ExifTool
- file-magic.py
- floss.exe
- nth.exe (Name-That-Hash)
- research.py
- ssdeep.py
- strings.py
- TrID
- Yara and the repo signature-base (collected in *C:\Tools\signature.yar*)
- zipdump.py


  [amc]: https://docs.aws.amazon.com/corretto/
  [bcv]: https://github.com/Konloch/bytecode-viewer
  [bhu]: https://github.com/3lp4tr0n/BeaconHunter
  [cap]: https://github.com/mandiant/capa
  [cer]: https://github.com/cmderdev/cmder
  [cha]: https://github.com/WithSecureLabs/chainsaw
  [cut]: https://github.com/rizinorg/cutter
  [cyb]: https://github.com/gchq/CyberChef
  [den]: https://cert.at/en/downloads/software/software-densityscout 
  [dis]: https://github.com/DidierStevens/DidierStevensSuite
  [dns]: https://github.com/dnSpyEx/dnSpy
  [ext]: https://exiftool.org/
  [fel]: https://www.nirsoft.net/utils/full_event_log_view.html
  [ffn]: https://github.com/mandiant/flare-fakenet-ng
  [flf]: https://github.com/mandiant/flare-floss
  [fq]:  https://github.com/wader/fq
  [ghi]: https://github.com/NationalSecurityAgency/ghidra
  [git]: https://github.com/git-for-windows/git/
  [grs]: https://github.com/mandiant/GoReSym
  [hxd]: https://mh-nexus.de/
  [jq]:  https://github.com/stedolan/jq
  [jub]: https://github.com/kacos2000/Jumplist-Browser
  [lio]: https://www.libreoffice.org/
  [lok]: https://github.com/Neo23x0/Loki
  [mal]: https://malcat.fr/
  [mev]: https://github.com/lolo101/MsgViewer
  [nca]: https://nmap.org/ncat/
  [ncp]: https://github.com/pnedev/comparePlus
  [not]: https://notepad-plus-plus.org/
  [npc]: https://npcap.com/
  [peb]: https://github.com/hasherezade/pe-bear
  [pes]: https://www.winitor.com/
  [pip]: ./resources/download/python.ps1
  [psd]: https://github.com/dzzie/pdfstreamdumper/
  [pyt]: https://python.org/
  [qpd]: https://github.com/qpdf/qpdf
  [rad]: https://github.com/radareorg/radare2
  [rem]: https://docs.remnux.org/discover-the-tools/examine+static+properties/general
  [rip]: https://github.com/BurntSushi/ripgrep
  [scd]: https://github.com/dzzie/VS_LIBEMU
  [sdi]: ./resources/download/didier.ps1
  [sql]: https://sqlite.org/
  [sws]: https://github.com/SwiftOnSecurity/sysmon-config
  [syi]: https://learn.microsoft.com/en-us/sysinternals/
  [sym]: https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon
  [thu]: https://thumbcacheviewer.github.io/
  [tri]: https://mark0.net/soft-trid-e.html
  [upx]: https://github.com/upx/upx
  [vis]: https://www.visidata.org/
  [vsc]: https://code.visualstudio.com/
  [wis]: https://wireshark.org/
  [wsa]: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview
  [xdb]: https://x64dbg.com/
  [yar]: https://github.com/VirusTotal/yara
  [zim]: https://github.com/EricZimmerman
