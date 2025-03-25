# DFIRWS

# Import common functions
if (Test-Path "${HOME}\Documents\tools\wscommon.ps1") {
    . "${HOME}\Documents\tools\wscommon.ps1"
} else {
    . '\\vmware-host\Shared Folders\dfirws\setup\wscommon.ps1'
}

# Verify that the file command is installed

try {
    Get-Command -ErrorAction Stop file.exe | Out-Null
}
catch {
    Write-Output "ERROR: Command file.exe isn't available. Exiting."
    return
}

# Basic tools
Test-Command 7z PE32

# Extra tools
Test-Command code DOS
Test-Command HxD PE32

Test-Command apimonitor-x86.exe PE32
Test-Command apimonitor-x64.exe PE32
$AutopsyExecutable = (Get-ChildItem "C:\Program Files\Autopsy*" -Include autopsy64.exe -Recurse).FullName
Test-Command $AutopsyExecutable PE32
$BinaryNinjaExecutable = (Get-ChildItem C:\Users\WDAGUtilityAccount\AppData\Local\Vector35\ -Recurse -Include binaryninja.exe).FullName
Test-Command $BinaryNinjaExecutable PE32
Test-Command BurpSuiteCommunity PE32
Test-Command chrome PE32
Test-Command clamscan PE32
Test-Command Cmder PE32
Test-Command "C:\Program Files\dbeaver\dbeaver-cli.exe" PE32
Test-Command "C:\Program Files\dbeaver\dbeaver.exe" PE32
Test-Command "C:\Program Files (x86)\Digital Detective\DCode v5\DCode.exe" PE32
$DokanyExecutable = (Get-ChildItem 'C:\Program Files\Dokan\' -Recurse -Include dokanctl.exe).FullName | Select-Object -Last 1
Test-Command $DokanyExecutable PE32
Test-Command "C:\Program Files\Mozilla Firefox\firefox.exe" PE32
Test-Command "C:\Program Files (x86)\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe" PE32
Test-Command go.exe PE32
Test-Command "C:\Program Files\Google\Google Earth Pro\client\googleearth.exe" PE32
Test-Command gpg PE32
Test-Command hashcat PE32
$JadxLibrary = (Get-ChildItem 'C:\Program Files\Jadx\' -Recurse -Include *.jar).FullName
Test-Command $JadxLibrary "Zip archive data"
Test-Command kape PE32
Test-Command "C:\Program Files (x86)\LibreOffice\program\soffice.exe" PE32
Test-Command loki PE32
#$MaltegoExecutable = (Get-ChildItem 'C:\Program Files (x86)\Paterva\Maltego\' -Include maltego.exe -Recurse).FullName
#Test-Command $MaltegoExecutable PE32
Test-Command neo4j ASCII
Test-Command node PE32
Test-Command "C:\Users\WDAGUtilityAccount\AppData\Local\Programs\Obsidian\Obsidian.exe" PE32
#Test-Command oh-my-posh PE32
Test-Command "C:\Sandsprite\PDFStreamDumper\PDFStreamDumper.exe" PE32
Test-Command putty PE32
Test-Command qemu-img PE32
Test-Command ruby PE32
Test-Command rustc PE32
Test-Command "C:\Users\WDAGUtilityAccount\Desktop\Tor Browser\Browser\firefox.exe" PE32
Test-Command veracrypt PE32
Test-Command vlc PE32
Test-Command WinMergeU PE32
Test-Command Wireshark PE32
Test-Command x64dbg PE32
Test-Command zap PE32
Test-Command zui PE32

# Development
Test-Command bash PE32
Test-Command gcc PE32
Test-Command gdb PE32

# First generated with the command below and then cleaned manually.
# foreach ($name in (Get-ChildItem C:\Tools\ -Include *.exe -Recurse) ) {"Test-Command", $name.name.Split('.')[0], "PE32      #", $name.FullName  -join " " }
Test-Command artemis PE32      # C:\Tools\artemis\artemis.exe
Test-Command Audacity PE32
Test-Command adalanche PE32      # C:\Tools\bin\adalanche.exe
Test-Command aleapp PE32      # C:\Tools\bin\aleapp.exe
Test-Command aleappGUI PE32      # C:\Tools\bin\aleappGUI.exe
Test-Command ares PE32      # C:\Tools\bin\ares.exe
Test-Command binlex PE32      # C:\Tools\bin\binlex.exe
Test-Command blyara PE32      # C:\Tools\bin\blyara.exe
Test-Command CobaltStrikeScan PE32      # C:\Tools\bin\CobaltStrikeScan.exe
Test-Command debloat PE32      # C:\Tools\bin\debloat.exe
Test-Command densityscout PE32      # C:\Tools\bin\densityscout.exe
Test-Command dll_load32 PE32      # C:\Tools\bin\dll_load32.exe
Test-Command dll_load64 PE32      # C:\Tools\bin\dll_load64.exe
Test-Command dll_to_exe PE32      # C:\Tools\bin\dll_to_exe.exe
Test-Command dsq PE32      # C:\Tools\bin\dsq.exe
Test-Command evtx_dump PE32      # C:\Tools\bin\evtx_dump.exe
Test-Command ffmpeg PE32      # C:\Tools\ffmpeg\bin\ffmpeg.exe
Test-Command fq PE32      # C:\Tools\bin\fq.exe
Test-Command fx PE32      # C:\Tools\bin\fx.exe
Test-Command gron PE32      # C:\Tools\bin\gron.exe
Test-Command hfs PE32      # C:\Tools\bin\hfs.exe
Test-Command hindsight_gui PE32      # C:\Tools\bin\hindsight_gui.exe
Test-Command hindsight PE32      # C:\Tools\bin\hindsight.exe
Test-Command hollows_hunter PE32      # C:\Tools\bin\hollows_hunter.exe
Test-Command ileapp PE32      # C:\Tools\bin\ileapp.exe
Test-Command ileappGUI PE32      # C:\Tools\bin\ileappGUI.exe
Test-Command jq PE32      # C:\Tools\bin\jq.exe
Test-Command JumplistBrowser PE32      # C:\Tools\bin\JumplistBrowser.exe
Test-Command kdb_check PE32      # C:\Tools\bin\kdb_check.exe
Test-Command MetadataPlus PE32      # C:\Tools\bin\MetadataPlus.exe
Test-Command MFTBrowser PE32      # C:\Tools\bin\MFTBrowser.exe
Test-Command msys2 PE32
Test-Command pe_check PE32      # C:\Tools\bin\pe_check.exe
Test-Command pe-sieve PE32      # C:\Tools\bin\pe-sieve.exe
Test-Command recbin PE32      # C:\Tools\bin\recbin.exe
Test-Command PrefetchBrowser PE32      # C:\Tools\bin\PrefetchBrowser.exe
Test-Command sidr PE32      # C:\Tools\bin\sidr.exe
Test-Command velociraptor PE32      # C:\Tools\bin\velociraptor.exe
Test-Command vt PE32      # C:\Tools\bin\vt.exe
Test-Command yara PE32      # C:\Tools\bin\yara.exe
Test-Command yarac PE32      # C:\Tools\bin\yarac.exe
Test-Command yq PE32      # C:\Tools\bin\yq.exe
Test-Command yr PE32      # C:\Tools\bin\yr.exe
Test-Command bulk_extractor64 PE32      # C:\Tools\bulk_extractor\win64\bulk_extractor64.exe
Test-Command capa PE32      # C:\Tools\capa\capa.exe
Test-Command capa-ghidra PE32      # C:\Tools\capa-ghidra\capa-ghidra.exe
Test-Command cleanhive PE32      # C:\Tools\cargo\bin\cleanhive.exe
Test-Command cute PE32      # C:\Tools\cargo\bin\cute.exe
Test-Command es4forensics PE32      # C:\Tools\cargo\bin\es4forensics.exe
Test-Command evtx2bodyfile PE32      # C:\Tools\cargo\bin\evtx2bodyfile.exe
Test-Command evtxanalyze PE32      # C:\Tools\cargo\bin\evtxanalyze.exe
Test-Command evtxcat PE32      # C:\Tools\cargo\bin\evtxcat.exe
Test-Command evtxls PE32      # C:\Tools\cargo\bin\evtxls.exe
Test-Command evtxscan PE32      # C:\Tools\cargo\bin\evtxscan.exe
Test-Command hivescan PE32      # C:\Tools\cargo\bin\hivescan.exe
Test-Command ipgrep PE32      # C:\Tools\cargo\bin\ipgrep.exe
Test-Command lnk2bodyfile PE32      # C:\Tools\cargo\bin\lnk2bodyfile.exe
Test-Command mactime2 PE32      # C:\Tools\cargo\bin\mactime2.exe
Test-Command mft2bodyfile PE32      # C:\Tools\cargo\bin\mft2bodyfile.exe
Test-Command pf2bodyfile PE32      # C:\Tools\cargo\bin\pf2bodyfile.exe
Test-Command pol_export PE32      # C:\Tools\cargo\bin\pol_export.exe
Test-Command regdump PE32      # C:\Tools\cargo\bin\regdump.exe
Test-Command sshniff PE32      # C:\Tools\cargo\bin\sshniff.exe
Test-Command ts2date PE32      # C:\Tools\cargo\bin\ts2date.exe
Test-Command usnjrnl_dump PE32      # C:\Tools\cargo\bin\usnjrnl_dump.exe
Test-Command zip2bodyfile PE32      # C:\Tools\cargo\bin\zip2bodyfile.exe
Test-Command chainsaw PE32      # C:\Tools\chainsaw\chainsaw.exe
Test-Command cutter PE32      # C:\Tools\cutter\cutter.exe
Test-Command rizin PE32      # C:\Tools\cutter\rizin.exe
Test-Command js-file PE32      # C:\Tools\DidierStevens\js-file.exe
Test-Command die PE32      # C:\Tools\die\die.exe
Test-Command diec PE32      # C:\Tools\die\diec.exe
Test-Command "C:\Tools\capa-explorer-web\index.html" HTML
Test-Command "C:\Tools\dnSpy64\bin\dnSpy.dll" PE32
Test-Command dumpbin PE32      # C:\Tools\dumpbin\dumpbin.exe
Test-Command elfparser-ng PE32      # C:\Tools\elfparser-ng\Release\elfparser-ng.exe
Test-Command exiftool PE32      # C:\Tools\exiftool\exiftool.exe
Test-Command fakenet PE32      # C:\Tools\fakenet\fakenet.exe
Test-Command FASM PE32      # C:\Tools\fasm\FASM.EXE
Test-Command floss PE32      # C:\Tools\floss\floss.exe
Test-Command "C:\Users\WDAGUtilityAccount\AppData\Local\fqlite\fqlite.exe" PE32
Test-Command FullEventLogView PE32      # C:\Tools\FullEventLogView\FullEventLogView.exe
Test-Command gftrace PE32      # C:\Tools\gftrace64\gftrace.exe
Test-Command ghidraRun ASCII
Test-Command "C:\Tools\ghidra\ghidra_10.4_PUBLIC\ghidraRun" ASCII
Test-Command godap PE32      # C:\Tools\godap\godap.exe
Test-Command GoReSym PE32      # C:\Tools\GoReSym\GoReSym.exe
Test-Command "C:\Tools\hashcat\hashcat.exe" PE32
Test-Command hayabusa PE32      # C:\Tools\hayabusa\hayabusa.exe
Test-Command "C:\Tools\iaito\iaito.exe" PE32
Test-Command imhex-gui PE32      # C:\Tools\imhex\imhex-gui.exe
Test-Command imhex PE32      # C:\Tools\imhex\imhex.exe
Test-Command INDXRipper PE32      # C:\Tools\INDXRipper\INDXRipper.exe
Test-Command jd-gui PE32      # C:\Tools\jd-gui\jd-gui.exe
Test-Command lessmsi-gui PE32      # C:\Tools\lessmsi\lessmsi-gui.exe
Test-Command lessmsi PE32      # C:\Tools\lessmsi\lessmsi.exe
Test-Command "C:\Tools\LogBoost\LogBoost.exe" PE32
Test-Command "C:\Tools\LogBoost\threats.db" "SQLite"
Test-Command MailView PE32      # C:\Tools\MailView\MailView.exe
Test-Command "C:\Tools\mboxviewer\mboxview64.exe" PE32 # GUI not in path
Test-Command MemProcFS PE32      # C:\Tools\MemProcFS\MemProcFS.exe
Test-Command mmdbinspect PE32      # C:\Tools\mmdbinspect\mmdbinspect.exe
Test-Command "C:\Tools\nirsoft\BrowsingHistoryView.exe" PE32
Test-Command "C:\Tools\nirsoft\ChromeCacheView.exe" PE32
Test-Command "C:\Tools\nirsoft\IECacheView.exe" PE32
Test-Command "C:\Tools\nirsoft\iecv.exe" PE32
Test-Command "C:\Tools\nirsoft\LastActivityView.exe" PE32
Test-Command "C:\Tools\nirsoft\MZCacheView.exe" PE32
Test-Command "C:\Tools\nirsoft\mzcv.exe" PE32
Test-Command ncat PE32      # C:\Tools\nmap\ncat.exe
Test-Command nmap PE32      # C:\Tools\nmap\nmap.exe
Test-Command node PE32      # C:\Tools\node\node.exe
Test-Command PE-bear PE32      # C:\Tools\pebear\PE-bear.exe
Test-Command pestudio PE32      # C:\Tools\pestudio\pestudio.exe
Test-Command ofs2rva PE32      # C:\Tools\pev\ofs2rva.exe
Test-Command pescan PE32      # C:\Tools\pev\pescan.exe
Test-Command php PE32      # C:\Tools\php\php.exe
Test-Command procdot PE32      # C:\Tools\procdot\win64\procdot.exe
Test-Command pstwalker PE32      # C:\Tools\pstwalker\pstwalker.exe
Test-Command qpdf PE32      # C:\Tools\qpdf\bin\qpdf.exe
Test-Command qrtool PE32      # C:\Tools\qrtool\qrtool.exe
Test-Command radare2 PE32      # C:\Tools\radare2\bin\radare2.exe
Test-Command RdpCacheStitcher PE32      # C:\Tools\RdpCacheStitcher\RdpCacheStitcher.exe
Test-Command redress PE32      # C:\Tools\redress\redress.exe
Test-Command rg PE32      # C:\Tools\ripgrep\rg.exe
Test-Command blkcalc PE32      # C:\Tools\sleuthkit\bin\blkcalc.exe
Test-Command sqldiff PE32      # C:\Tools\sqlite\sqldiff.exe
Test-Command sqlite3 PE32      # C:\Tools\sqlite\sqlite3.exe
Test-Command "C:\Tools\sqlitebrowser\DB Browser for SQLite.exe" PE32
Test-Command "C:\Tools\takajo\takajo.exe" PE32
Test-Command SSView PE32      # C:\Tools\ssview\SSView.exe
Test-Command autorunsc64 PE32      # C:\Tools\sysinternals\autorunsc64.exe
Test-Command procdump64 PE32      # C:\Tools\sysinternals\procdump64.exe
Test-Command procexp64 PE32      # C:\Tools\sysinternals\procexp64.exe
Test-Command pskill64 PE32      # C:\Tools\sysinternals\pskill64.exe
Test-Command ZoomIt64 PE32      # C:\Tools\sysinternals\ZoomIt64.exe
Test-Command Tabby PE32      # C:\Tools\tabby\Tabby.exe
Test-Command thumbcache_viewer PE32      # C:\Tools\thumbcacheviewer\thumbcache_viewer.exe
Test-Command trid PE32      # C:\Tools\trid\trid.exe
Test-Command upx PE32      # C:\Tools\upx\upx.exe
Test-Command VolatilityWorkbench PE32      # C:\Tools\VolatilityWorkbench2\VolatilityWorkbench.exe
Test-Command WinApiSearch32 PE32      # C:\Tools\WinApiSearch\WinApiSearch32.exe
Test-Command WinApiSearch64 PE32      # C:\Tools\WinApiSearch\WinApiSearch64.exe
Test-Command WinObjEx64 PE32      # C:\Tools\WinObjEx64\WinObjEx64.exe
Test-Command xelfviewer PE32      # C:\Tools\XELFViewer\xelfviewer.exe
Test-Command LECmd PE32      # C:\Tools\Zimmerman\LECmd.exe
Test-Command MFTECmd PE32      # C:\Tools\Zimmerman\MFTECmd.exe
Test-Command PECmd PE32      # C:\Tools\Zimmerman\PECmd.exe
Test-Command RBCmd PE32      # C:\Tools\Zimmerman\RBCmd.exe
Test-Command SQLECmd PE32      # C:\Tools\Zimmerman\SQLECmd\SQLECmd.exe
Test-Command zircolite PE32      # C:\Tools\zircolite\zircolite.exe
Test-Command evtx_dump_win PE32      # C:\Tools\zircolite\bin\evtx_dump_win.exe
Test-Command zstd PE32      # C:\Tools\zstd\zstd.exe

# Test some git repositories

Test-Command dhparser PE32
Test-Command ese2csv PE32
Test-Command evtxparse PE32
Test-Command C:\git\iShutdown\Win\iShutdown_detect.exe PE32
Test-Command rip PE32
Test-Command Regshot-x64-Unicode PE32
Test-Command trawler CRLF

# Program files

Test-Command BeaconHunter PE32
Test-Command 4N4LDetector PE32
$jaccessinspectorExecutable = (Get-ChildItem 'C:\Program Files\Amazon Corretto' -Recurse -Include jaccessinspector.exe).FullName
Test-Command $jaccessinspectorExecutable PE32
Test-Command 'C:\Program Files\AuthLogParser\MasterParser.ps1' CRLF
Test-Command fibratus PE32
Test-Command git PE32
Test-Command gxl2dot PE32
Test-Command idr PE32
Test-Command iisGeolocate PE32
Test-Command "C:\Program Files\IrfanView\i_view64.exe" PE32
Test-Command malcat PE32
Test-Command notepad++ PE32
Test-Command python PE32

# foreach ($name in (Get-ChildItem C:\venv\*\scripts -Recurse -Include *.exe -Exclude python.exe,pip.exe,pip3.exe,pip3.11.exe,poetry.exe,virtualenv.exe,pythonw.exe,pkginfo.exe,doesitcache.exe,dulwich.exe,keyring.exe,pyproject-build.exe,normalizer.exe,pygmentize.exe,wheel.exe)) {"Test-Command", $name.Fullname, "PE32"  -join " " }
Test-Command C:\venv\binary-refinery\Scripts\binref.exe PE32
Test-Command C:\venv\chepy\Scripts\chepy.exe PE32
Test-Command C:\venv\chepy\Scripts\markdown_py.exe PE32
Test-Command C:\venv\chepy\Scripts\pyjwt.exe PE32
Test-Command C:\venv\chepy\Scripts\scapy.exe PE32
Test-Command C:\venv\csvkit\Scripts\csvclean.exe PE32
Test-Command C:\venv\csvkit\Scripts\csvcut.exe PE32
Test-Command C:\venv\default\Scripts\acquire-decrypt.exe PE32
Test-Command C:\venv\default\Scripts\acquire.exe PE32
Test-Command C:\venv\default\Scripts\asdf-dd.exe PE32
Test-Command C:\venv\default\Scripts\asdf-meta.exe PE32
Test-Command C:\venv\default\Scripts\asdf-repair.exe PE32
Test-Command C:\venv\default\Scripts\asdf-verify.exe PE32
Test-Command C:\venv\default\Scripts\autoit-ripper.exe PE32
Test-Command C:\venv\default\Scripts\bokeh.exe PE32
Test-Command C:\venv\default\Scripts\cart.exe PE32
Test-Command C:\venv\default\Scripts\deep-translator.exe PE32
Test-Command C:\venv\default\Scripts\dt.exe PE32
Test-Command C:\venv\default\Scripts\dump-nskeyedarchiver.exe PE32
Test-Command C:\venv\default\Scripts\editorconfig.exe PE32
Test-Command C:\venv\default\Scripts\envelope-decrypt.exe PE32
Test-Command C:\venv\default\Scripts\extract_msg.exe PE32
Test-Command C:\venv\default\Scripts\ezhexviewer.exe PE32
Test-Command C:\venv\default\Scripts\f2py.exe PE32
Test-Command C:\venv\default\Scripts\flask.exe PE32
Test-Command C:\venv\default\Scripts\flatten_json.exe PE32
Test-Command C:\venv\default\Scripts\fonttools.exe PE32
Test-Command C:\venv\default\Scripts\frida-apk.exe PE32
Test-Command C:\venv\default\Scripts\frida.exe PE32
Test-Command C:\venv\default\Scripts\ftguess.exe PE32
Test-Command C:\venv\default\Scripts\ghidriff.exe PE32
Test-Command C:\venv\default\Scripts\grip.exe PE32
Test-Command C:\venv\default\Scripts\hachoir-wx.exe PE32
Test-Command C:\venv\default\Scripts\httpx.exe PE32
Test-Command C:\venv\default\Scripts\jlpm.exe PE32
Test-Command C:\venv\default\Scripts\js-beautify.exe PE32
Test-Command C:\venv\default\Scripts\jsonschema.exe PE32
Test-Command C:\venv\default\Scripts\jupyter.exe PE32
Test-Command C:\venv\default\Scripts\lnkparse.exe PE32
Test-Command C:\venv\default\Scripts\markdown_py.exe PE32
Test-Command C:\venv\default\Scripts\minidump.exe PE32
Test-Command C:\venv\default\Scripts\mkyara.exe PE32
Test-Command C:\venv\default\Scripts\mraptor.exe PE32
Test-Command C:\venv\default\Scripts\msodde.exe PE32
Test-Command C:\venv\default\Scripts\msoffcrypto-tool.exe PE32
Test-Command C:\venv\default\Scripts\name-that-hash.exe PE32
Test-Command C:\venv\default\Scripts\netaddr.exe PE32
Test-Command C:\venv\default\Scripts\numpy-config.exe PE32
Test-Command C:\venv\default\Scripts\olebrowse.exe PE32
Test-Command C:\venv\default\Scripts\oledir.exe PE32
Test-Command C:\venv\default\Scripts\olefile.exe PE32
Test-Command C:\venv\default\Scripts\oleid.exe PE32
Test-Command C:\venv\default\Scripts\olemap.exe PE32
Test-Command C:\venv\default\Scripts\olemeta.exe PE32
Test-Command C:\venv\default\Scripts\oleobj.exe PE32
Test-Command C:\venv\default\Scripts\oletimes.exe PE32
Test-Command C:\venv\default\Scripts\olevba.exe PE32
Test-Command C:\venv\default\Scripts\parse-lnk.exe PE32
Test-Command C:\venv\default\Scripts\pcode2code.exe PE32
Test-Command C:\venv\default\Scripts\pcodedmp.exe PE32
Test-Command C:\venv\default\Scripts\protodeep.exe PE32
Test-Command C:\venv\default\Scripts\ptipython3.exe PE32
Test-Command C:\venv\default\Scripts\ptpython.exe PE32
Test-Command C:\venv\default\Scripts\pybabel.exe PE32
Test-Command C:\venv\default\Scripts\pyftmerge.exe PE32
Test-Command C:\venv\default\Scripts\pyftsubset.exe PE32
#Test-Command C:\venv\default\Scripts\pyhidra.exe PE32
Test-Command C:\venv\default\Scripts\pyjson5.exe PE32
Test-Command C:\venv\default\Scripts\pylupdate6.exe PE32
Test-Command C:\venv\default\Scripts\pyonenote.exe PE32
Test-Command C:\venv\default\Scripts\pyuic6.exe PE32
Test-Command C:\venv\default\Scripts\pyxswf.exe PE32
Test-Command C:\venv\default\Scripts\rdump.exe PE32
Test-Command C:\venv\default\Scripts\rexi.exe PE32
Test-Command C:\venv\default\Scripts\rgeoip.exe PE32
Test-Command C:\venv\default\Scripts\roman.exe PE32
Test-Command C:\venv\default\Scripts\rtfobj.exe PE32
Test-Command C:\venv\default\Scripts\send2trash.exe PE32
Test-Command C:\venv\default\Scripts\shodan.exe PE32
Test-Command C:\venv\default\Scripts\target-shell.exe PE32
Test-Command C:\venv\default\Scripts\thumbcache-extract.exe PE32
Test-Command C:\venv\default\Scripts\time-decode.exe PE32
Test-Command C:\venv\default\Scripts\tldextract.exe PE32
Test-Command C:\venv\default\Scripts\tqdm.exe PE32
Test-Command C:\venv\default\Scripts\ttx.exe PE32
Test-Command C:\venv\default\Scripts\visidata.exe PE32
Test-Command C:\venv\default\Scripts\vma-extract.exe PE32
Test-Command C:\venv\default\Scripts\wsdump.exe PE32
Test-Command C:\venv\default\Scripts\xlmdeobfuscator.exe PE32
Test-Command C:\venv\dfir-unfurl\Scripts\flask.exe PE32
Test-Command C:\venv\dfir-unfurl\Scripts\unfurl.exe PE32
Test-Command C:\venv\dissect\Scripts\acquire.exe PE32
Test-Command C:\venv\dissect\Scripts\thumbcache-extract.exe PE32
Test-Command C:\venv\dissect\Scripts\vma-extract.exe PE32
Test-Command C:\venv\ghidrecomp\Scripts\ghidrecomp.exe PE32
Test-Command C:\venv\jpterm\Scripts\httpx.exe PE32
Test-Command C:\venv\jpterm\Scripts\jpterm.exe PE32
Test-Command C:\venv\jpterm\Scripts\jupyter.exe PE32
Test-Command C:\venv\jpterm\Scripts\markdown-it.exe PE32
Test-Command C:\venv\jpterm\Scripts\rich-click.exe PE32
Test-Command C:\venv\jpterm\Scripts\vimg.exe PE32
Test-Command C:\venv\litecli\Scripts\litecli.exe PE32
Test-Command C:\venv\magika\Scripts\magika.exe PE32
Test-Command C:\venv\magika\Scripts\tqdm.exe PE32
Test-Command C:\venv\maldump\Scripts\maldump.exe PE32
Test-Command C:\venv\malwarebazaar\Scripts\bazaar.exe PE32
Test-Command C:\venv\malwarebazaar\Scripts\yaraify.exe PE32
Test-Command C:\venv\mwcp\Scripts\flask.exe PE32
Test-Command C:\venv\mwcp\Scripts\mwcp.exe PE32
Test-Command C:\venv\mwcp\Scripts\numpy-config.exe PE32
Test-Command C:\venv\mwcp\Scripts\tabulate.exe PE32
Test-Command C:\venv\peepdf3\Scripts\js-beautify.exe PE32
Test-Command C:\venv\peepdf3\Scripts\peepdf.exe PE32
Test-Command C:\venv\rexi\Scripts\markdown-it.exe PE32
Test-Command C:\venv\rexi\Scripts\rexi.exe PE32
Test-Command C:\venv\scare\Scripts\ptpython.exe PE32
Test-Command C:\venv\sigma-cli\Scripts\sigma.exe PE32
Test-Command C:\venv\toolong\Scripts\markdown-it.exe PE32
Test-Command C:\venv\toolong\Scripts\tl.exe PE32
Test-Command C:\venv\white-phoenix\Scripts\f2py.exe PE32

# foreach ($name in (Get-ChildItem C:\venv\*\scripts -Recurse -Include *.py)) {"Test-Command", $name.Fullname, "Python"  -join " " }
Test-Command C:\venv\binary-refinery\Scripts\evtx_dump.py Python
Test-Command C:\venv\binary-refinery\Scripts\evtx_info.py Python
Test-Command C:\venv\binary-refinery\Scripts\readelf.py Python
Test-Command C:\venv\chepy\Scripts\exrex.py Python
Test-Command C:\venv\chepy\Scripts\jp.py Python
Test-Command C:\venv\chepy\Scripts\readelf.py Python
Test-Command C:\venv\csvkit\Scripts\runxlrd.py Python
Test-Command C:\venv\default\Scripts\bmc-tools.py Python
Test-Command C:\venv\default\Scripts\CanaryTokenScanner.py Python
Test-Command C:\venv\default\Scripts\docx2txt.py Python
Test-Command C:\venv\default\Scripts\dotnetfile_dump.py Python
Test-Command C:\venv\default\Scripts\fat_parser.py Python
Test-Command C:\venv\default\Scripts\hash-id.py Python
Test-Command C:\venv\default\Scripts\ipexpand.py Python
Test-Command C:\venv\default\Scripts\iShutdown_parse.py Python
Test-Command C:\venv\default\Scripts\jsonpointer.py Python
Test-Command C:\venv\default\Scripts\machofile.py Python
Test-Command C:\venv\default\Scripts\msidump.py Python
Test-Command C:\venv\default\Scripts\ntfs_parser.py Python
Test-Command C:\venv\default\Scripts\priweavepng.py Python
Test-Command C:\venv\default\Scripts\pwncat.py Python
Test-Command C:\venv\default\Scripts\runxlrd.py Python
Test-Command C:\venv\default\Scripts\shellconv.py Python
Test-Command C:\venv\default\Scripts\sigs.py Python
Test-Command C:\venv\default\Scripts\smtpsmug.py Python
Test-Command C:\venv\default\Scripts\SQLiteWalker.py Python
Test-Command C:\venv\default\Scripts\unpy2exe.py Python
Test-Command C:\venv\default\Scripts\vba_extract.py Python
Test-Command C:\venv\default\Scripts\vd.py Python
Test-Command C:\venv\default\Scripts\vsc_mount.py Python
Test-Command C:\venv\evt2sigma\Scripts\evt2sigma.py Python
Test-Command C:\venv\mwcp\Scripts\readelf.py Python
Test-Command C:\venv\pe2pic\Scripts\pe2pic.py Python
Test-Command C:\venv\scare\Scripts\scare.py Python

# Downloads only files
Test-Command C:\downloads\intel_driver.exe PE32
Test-Command C:\downloads\openvpn.msi "MSI Installer"
Test-Command C:\downloads\osfmount.exe PE32
Test-Command C:\downloads\tailscale.exe PE32
Test-Command C:\downloads\wireguard.msi "MSI Installer"
Test-Command C:\downloads\comparePlus.zip "Zip archive data"
Test-Command C:\downloads\DSpellCheck.zip "Zip archive data"
Test-Command C:\downloads\NppMarkdownPanel.zip "Zip archive data"

# Verify length of file names in Start Menu
(Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" -Recurse).FullName | ForEach-Object { if ($_.Length -gt 250) {$message = "ERROR: Folder name to long " + ${_}.Length + " " + $_ ; Write-Output $message} }

if (Test-Path "C:\venv\visualstudio.txt") {
    Test-Command C:\venv\ingestr\Scripts\ingestr.exe PE32
    Test-Command C:\venv\jep\Lib\site-packages\jep\jep.dll PE32
    Test-Command C:\venv\jep\Scripts\capa.exe PE32
    Test-Command C:\venv\jep\Scripts\f2py.exe PE32
    Test-Command C:\venv\jep\Scripts\markdown-it.exe PE32
    Test-Command C:\venv\jep\Scripts\numpy-config.exe PE32
    Test-Command C:\venv\jep\Scripts\readelf.py Python
    Test-Command C:\venv\pdfalyzer\Scripts\pdfalyze.exe PE32
    Test-Command C:\venv\pdfalyzer\Scripts\yaralyze.exe PE32
    Test-Command C:\venv\regipy\Scripts\regipy-diff.exe PE32
    Test-Command C:\venv\regipy\Scripts\regipy-dump.exe PE32
    Test-Command C:\venv\regipy\Scripts\tabulate.exe PE32
    Test-Command C:\venv\regipy\Scripts\parseUSBs.py Python
}