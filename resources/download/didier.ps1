. ".\resources\download\common.ps1"
$TOOL_DEFINITIONS = @()

New-Item -ItemType Directory -Force -Path "${TOOLS}\DidierStevens" | Out-Null

$DidierStevensSuite = `
    "1768.json", `
    "1768.py", `
    "amsiscan.py", `
    "base64dump.py", `
    "byte-stats.py", `
    "cipher-tool.py", `
    "count.py", `
    "cs-analyze-processdump.py", `
    "cs-decrypt-metadata.py", `
    "cs-extract-key.py", `
    "csv-stats.py", `
    "cut-bytes.py", `
    "decode-vbe.py", `
    "decoder_add1.py", `
    "decoder_ah.py", `
    "decoder_chr.py", `
    "decoder_rol1.py", `
    "decoder_xor1.py", `
    "decompress_rtf.py", `
    "defuzzer.py", `
    "disitool.py", `
    "emldump.py", `
    "file-magic.def", `
    "file-magic.py", `
    "find-file-in-file.py", `
    "format-bytes.py", `
    "hash.py", `
    "headtail.py", `
    "hex-to-bin.py", `
    "jpegdump.py", `
    "js-ascii.exe", `
    "js-file.exe", `
    "libnspr4.dll", `
    "msoffcrypto-crack.py", `
    "myipaddress.py", `
    "myjson-filter.py", `
    "myjson-transform.py", `
    "nsrl.py", `
    "numbers-to-hex.py", `
    "numbers-to-string.py", `
    "oledump.py", `
    "pdf-parser.py", `
    "pdfid.ini", `
    "pdfid.py", `
    "pdftool.py", `
    "pecheck.py", `
    "plugin_biff.py", `
    "plugin_clsid.py", `
    "plugin_dridex.py", `
    "plugin_dttm.py", `
    "plugin_embeddedfile.py", `
    "plugin_hifo.py", `
    "plugin_http_heuristics.py", `
    "plugin_hyperlink.py", `
    "plugin_jumplist.py", `
    "plugin_linear.py", `
    "plugin_list", `
    "plugin_metadata.py", `
    "plugin_msg_summary.py", `
    "plugin_msg.py", `
    "plugin_msi.py", `
    "plugin_msi_info.py", `
    "plugin_nameobfuscation.py", `
    "plugin_office_crypto.py", `
    "plugin_olestreams.py", `
    "plugin_pcode_dumper.py", `
    "plugin_ppt.py", `
    "plugin_str_sub.py", `
    "plugin_stream_o.py", `
    "plugin_stream_sample.py", `
    "plugin_triage.py", `
    "plugin_vba_dco.py", `
    "plugin_vba_dir.py", `
    "plugin_vba_routines.py", `
    "plugin_vba_summary.py", `
    "plugin_vba.py", `
    "plugin_vbaproject.py", `
    "plugin_version_vba.py", `
    "process-binary-file.py", `
    "process-text-file.py", `
    "python-per-line.library", `
    "python-per-line.py", `
    "re-search.py", `
    "reextra.py", `
    "rtfdump.py", `
    "sets.py", `
    "sortcanon.py", `
    "split-overlap.py", `
    "split.py", `
    "ssdeep.py", `
    "strings.py", `
    "teeplus.py", `
    "translate.py", `
    "what-is-new.py", `
    "xmldump.py", `
    "xor-kpa.py", `
    "xorsearch.py", `
    "zipdump.py"

foreach ($Tool in ${DidierStevensSuite}) {
    $extension = [System.IO.Path]::GetExtension($Tool)
    if ($extension -eq ".exe") {
        $checkString = "PE32"
    } elseif ($extension -eq ".dll") {
        $checkString = "PE32"
    } elseif ($extension -eq ".py") {
        $checkString = "(Python script|^$)"
    } elseif ($extension -eq ".def") {
        $checkString = "magic text fragment"
    } elseif ($extension -eq ".json") {
        $checkString = "JSON text data"
    } elseif ($extension -eq "") {
        $checkString = "ASCII text"
    } else {
        $checkString = "ASCII text"
    }
    $status = Get-FileFromUri -uri "https://raw.githubusercontent.com/DidierStevens/DidierStevensSuite/master/${Tool}" -FilePath "${TOOLS}\DidierStevens\${Tool}" -check "${checkString}"
}

$DidierStevensBeta = "metatool.py", `
    "onedump.py", `
    "pngdump.py", `
    "xlsbdump.py"

foreach ($Tool in ${DidierStevensBeta}) {
  $status = Get-FileFromUri -uri "https://raw.githubusercontent.com/DidierStevens/Beta/master/${Tool}" -FilePath "${TOOLS}\DidierStevens\${Tool}" -check "Python script"
}

Copy-Item "${TOOLS}\DidierStevens\*" "${TOOLS}\bin" -Force | Out-Null

$null = $status

$TOOL_DEFINITIONS += @{
    Name = "Didier Stevens Suite"
    Homepage = "https://blog.didierstevens.com/didier-stevens-suite/"
    Vendor = "Didier Stevens"
    License = "Unknown"
    Category = "DidierStevens"
    Shortcuts = @(
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\1768.py (Analyze Cobalt Strike beacons).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command 1768.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\amsiscan.py (Scan input with AmsiScanBuffer).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command amsiscan.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\base64dump.py (Extract base64 strings from file).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command base64dump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\byte-stats.py (Calculate byte statistics).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command byte-stats.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\cipher-tool.py (Cipher tool).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command cipher-tool.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\count.py (count unique items).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command count.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\cs-analyze-processdump.py (Analyze Cobalt Strike beacon process dumps for further analysis).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command cs-analyze-processdump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\cs-decrypt-metadata.py (Cobalt Strike - RSA decrypt metadata).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command cs-decrypt-metadata.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\cs-extract-key.py (Extract cryptographic keys from Cobalt Strike beacon process dump).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command cs-extract-key.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\csv-stats.py (Tool to produce statistics for CSV files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command csv-stats.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\cut-bytes.py (Cut a section of bytes out of a file).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command cut-bytes.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\decode-vbe.py (Decode VBE script).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command decode-vbe.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\decompress_rtf.py (Tool to decompress compressed RTF).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command decompress_rtf.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\defuzzer.py (Merge 3 or more fuzzed files back to original).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command defuzzer.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\disitool.py.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command disitool.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\emldump.py (EML dump utility).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command emldump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\file-magic.py (Essentially a wrapper for file (libmagic)).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command file-magic.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\find-file-in-file.py (Find if a file is present in another file).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command find-file-in-file.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\format-bytes.py (This is essentially a wrapper for the struct module).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command format-bytes.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\hash.py (This is essentially a wrapper for the hashlib module).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command hash.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\headtail.py (Output head and tail of input).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command headtail.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\hex-to-bin.py.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command hex-to-bin.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\jpegdump.py (JPEG file analysis tool).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command jpegdump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\js-ascii.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command js-ascii.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\js-file.exe.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command js-file.exe -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\metatool.py (Tool for Metasploit).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command metatool.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\msoffcrypto-crack.py (Crack MS Office document password).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command msoffcrypto-crack.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\myjson-filter.py.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command myjson-filter.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\myjson-transform.py.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command myjson-transform.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\nsrl.py.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command nsrl.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\numbers-to-hex.py (Program to convert decimal numbers into hex numbers).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command numbers-to-hex.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\numbers-to-string.py (Program to convert numbers into a string).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command numbers-to-string.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\oledump.py (Analyze OLE files (Compound Binary Files)).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command oledump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\onedump.py (Dump tool for OneNote files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command onedump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\pdf-parser.py (use it to parse a PDF document).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pdf-parser.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\pdfid.py (Tool to test a PDF file).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pdfid.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\pdftool.py (Tool to process PDFs).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pdftool.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\pecheck.py (Tool for displaying PE file info).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pecheck.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\pngdump.py.lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command pngdump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\python-per-line.py (Program to evaluate a Python expression for each line in the provided text file(s)).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command python-per-line.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\re-search.py (Program to use Pythons re.findall on files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command re-search.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\rtfdump.py (Analyze RTF files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command rtfdump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\sets.py (Set operations on 1 or 2 files).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sets.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\sortcanon.py (Sort with canonicalization function).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command sortcanon.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\split-overlap.py (Split file with overlap).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command split-overlap.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\split.py (Split a text file into X number of files (2 by default)).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command split.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\ssdeep.py (ssdeep tool).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command ssdeep.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\strings.py (Strings command in Python).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command strings.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\teeplus.py (Save binary data while piping it from stdin to stdout ).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command teeplus.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\translate.py (Translate bytes according to a Python expression).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command translate.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\what-is-new.py (Tool to monitor new items).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command what-is-new.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\xlsbdump.py (XLSB parser).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command xlsbdump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\xmldump.py (This is essentially a wrapper for xml.etree.ElementTree).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command xmldump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\xor-kpa.py (XOR known-plaintext attack).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command xor-kpa.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\xorsearch.py (Bruteforce a file for encodings and search).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command xorsearch.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
        @{
            Lnk      = "`${HOME}\Desktop\dfirws\DidierStevens\zipdump.py (ZIP dump utility).lnk"
            Target   = "`${CLI_TOOL}"
            Args     = "`${CLI_TOOL_ARGS} -command zipdump.py -h"
            Icon     = ""
            WorkDir  = "`${HOME}\Desktop"
        }
    )
    InstallVerifyCommand = ""
    Verify = @(
        @{
            Type = "command"
            Name = "`${TOOLS}\DidierStevens\js-file.exe"
            Expect = "PE32"
        }
    )
    Notes = "Didier Stevens Suite is a collection of tools written in Python and some compiled executables for various digital forensics and incident response tasks."
    Tips = ""
    Usage = "Didier Stevens Suite is a collection of tools written in Python and some compiled executables for various digital forensics and incident response tasks."
    SampleCommands = @(
        "1768.py -h",
        "amsiscan.py -h",
        "base64dump.py -h",
        "byte-stats.py -h",
        "cipher-tool.py -h",
        "count.py -h",
        "cs-analyze-processdump.py -h",
        "cs-decrypt-metadata.py -h",
        "cs-extract-key.py -h",
        "csv-stats.py -h",
        "cut-bytes.py -h",
        "decode-vbe.py -h",
        "decompress_rtf.py -h",
        "defuzzer.py -h",
        "disitool.py -h",
        "emldump.py -h",
        "file-magic.py -h",
        "find-file-in-file.py -h",
        "format-bytes.py -h",
        "hash.py -h",
        "headtail.py -h",
        "hex-to-bin.py -h",
        "jpegdump.py -h",
        "js-ascii.exe -h",
        "js-file.exe -h",
        "metatool.py -h",
        "msoffcrypto-crack.py -h",
        "myjson-filter.py -h",
        "myjson-transform.py -h",
        "nsrl.py -h",
        "numbers-to-hex.py -h",
        "numbers-to-string.py -h",
        "oledump.py -h",
        "onedump.py -h",
        "pdf-parser.py -h",
        "pdfid.py -h",
        "pdftool.py -h",
        "pecheck.py -h",
        "pngdump.py -h",
        "python-per-line.py -h",
        "re-search.py -h",
        "rtfdump.py -h",
        "sets.py -h",
        "sortcanon.py -h",
        "split-overlap.py -h",
        "split.py -h",
        "ssdeep.py -h",
        "strings.py -h",
        "teeplus.py -h",
        "translate.py -h",
        "what-is-new.py -h",
        "xlsbdump.py -h",
        "xmldump.py -h",
        "xor-kpa.py -h",
        "xorsearch.py -h",
        "zipdump.py -h"
    )
    SampleFiles = @(
        "N/A"
    )
    Dependencies = @()
}

New-CreateToolFiles -ToolDefinitions $TOOL_DEFINITIONS -Source "didier"