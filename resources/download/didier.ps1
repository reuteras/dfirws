Write-Host "Download Didier Stevens tools."
New-Item -ItemType Directory -Force -Path .\tools\downloads\DidierStevens > $null
New-Item -ItemType Directory -Force -Path .\tmp\tools\downloads\DidierStevens > $null

. $PSScriptRoot\common.ps1

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
    "extractscripts.py", `
    "file-magic.def", `
    "file-magic.py", `
    "find-file-in-file.py", `
    "format-bytes.py", `
    "hash.py", `
    "headtail.py", `
    "hex-to-bin.py", `
    "jpegdump.py", `
    "msoffcrypto-crack.py", `
    "myjson-filter.py", `
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
    "plugin_jumplist.py", `
    "plugin_linear.py", `
    "plugin_list", `
    "plugin_metadata.py", `
    "plugin_msg_summary.py", `
    "plugin_msg.py", `
    "plugin_msi.py", `
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

foreach ($Tool in $DidierStevensSuite)
{
  Get-FileFromUri -uri https://raw.githubusercontent.com/DidierStevens/DidierStevensSuite/master/$Tool -FilePath .\tools\downloads\DidierStevens\$Tool
}

$DidierStevensBeta = "metatool.py", `
    "onedump.py", `
    "pngdump.py", `
    "xlsbdump.py"

foreach ($Tool in $DidierStevensBeta)
{
  Get-FileFromUri -uri https://raw.githubusercontent.com/DidierStevens/Beta/master/$Tool -FilePath .\tools\downloads\DidierStevens\$Tool
}

Remove-Item -r .\tmp\tools