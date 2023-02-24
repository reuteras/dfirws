# DFIR in a Windows Sandbox - dfirws

This repository contains a collection of scripts to install tools for DFIR work in a Windows Sandbox. This started with the code in [Windows Sandbox Configuration][wsc]. Tools has been updated, added and removed.

Tools included:

- [Amazon Corretto][amc]
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
- [Ghidra][ghi]
- [Git][git]
- [GoReSym][grs]
- [HxD][hxd]
- [jq][jq]
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
- https://github.com/SigmaHQ/sigma.git
- https://github.com/volexity/threat-intel.git

## Installation and configuration

First enable Windows Sandbox by running **Add and remove Windows features** and adding Windows Sandbox.

Now start a PowerShell terminal and download the code. You have to have git available to use this tool. Not only to checkout the code from the repository.

	git clone https:/github.com/reuteras/irtools.git
	cd irtools\wsb

Create configuration with your local path by running.

	.\createSandboxConfig.ps1

You need to have Python 3.10 installed (or change to another version in the Sandbox by modifying the scripts) and then download all binaries and scripts with the help of the following command.

	.\downloadFiles.ps1

If you like to have a more detailed view on the progress you can run the following **PowerShell** variant of **tail -f**

    Get-Content .\log\log.txt -Wait
    

## Usage

Start the Sandbox by clicking on **sandbox_tools_no_network.wsb** or running **./sandbox_tools_no_network.wsb** in a PowerShell terminal. Installation will take around two minutes and the background will change when its done.

![Screen when installation is done](./resources/images/screen.png)

Python pip packages will be installed in the background and that installation is done when there is a _README.md_ file on the Desktop.

## TODO

- [ ] Would be nice to get Windows Terminal in the sandbox.

  [amc]: https://docs.aws.amazon.com/corretto/
  [bcv]: https://github.com/Konloch/bytecode-viewer
  [cap]: https://github.com/mandiant/capa
  [cer]: https://github.com/cmderdev/cmder
  [cha]: https://github.com/WithSecureLabs/chainsaw
  [cut]: https://github.com/rizinorg/cutter
  [cyb]: https://github.com/gchq/CyberChef
  [den]: https://cert.at/en/downloads/software/software-densityscout 
  [dis]: https://github.com/DidierStevens/DidierStevensSuite
  [dns]: https://github.com/dnSpyEx/dnSpy
  [ext]: https://exiftool.org/
  [ffn]: https://github.com/mandiant/flare-fakenet-ng
  [flf]: https://github.com/mandiant/flare-floss
  [ghi]: https://github.com/NationalSecurityAgency/ghidra
  [git]: https://github.com/git-for-windows/git/
  [grs]: https://github.com/mandiant/GoReSym
  [hxd]: https://mh-nexus.de/
  [jq]:  https://github.com/stedolan/jq
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
  [wsc]: https://github.com/firefart/sandbox
  [xdb]: https://x64dbg.com/
  [yar]: https://github.com/VirusTotal/yara
  [zim]: https://github.com/EricZimmerman
