<#
.SYNOPSIS
    Downloads Didier Stevens tools for DFIR analysis.

.DESCRIPTION
    This script downloads the Didier Stevens suite of tools and beta tools
    for digital forensics and incident response analysis. These tools are 
    maintained at https://github.com/DidierStevens.

.NOTES
    File Name      : didier.ps1
    Author         : DFIRWS Project
    Prerequisite   : PowerShell 5.1 or later
    Version        : 2.0

.LINK
    https://github.com/reuteras/dfirws
    https://github.com/DidierStevens/DidierStevensSuite
#>

[CmdletBinding()]
param()

# Source common functions
. ".\resources\download\common.ps1"

#region Initialization

# Create destination directory if it doesn't exist
$destinationPath = "${TOOLS}\DidierStevens"
if (!(Test-Path -Path $destinationPath)) {
    Write-DateLog "Creating Didier Stevens tools directory"
    New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null
}

# Set error action preference
$ErrorActionPreference = "Stop"

# Initialize counters for reporting
$totalFiles = 0
$downloadedFiles = 0
$errorFiles = 0

#endregion Initialization

#region Main Repository Tools

Write-DateLog "Downloading tools from Didier Stevens Suite repository"

# List of tools to download from the main suite
$DidierStevensSuite = @(
    "1768.json", 
    "1768.py", 
    "amsiscan.py", 
    "base64dump.py", 
    "byte-stats.py", 
    "cipher-tool.py", 
    "count.py", 
    "cs-analyze-processdump.py", 
    "cs-decrypt-metadata.py", 
    "cs-extract-key.py", 
    "csv-stats.py", 
    "cut-bytes.py", 
    "decode-vbe.py", 
    "decoder_add1.py", 
    "decoder_ah.py", 
    "decoder_chr.py", 
    "decoder_rol1.py", 
    "decoder_xor1.py", 
    "decompress_rtf.py", 
    "defuzzer.py", 
    "disitool.py", 
    "emldump.py", 
    "file-magic.def", 
    "file-magic.py", 
    "find-file-in-file.py", 
    "format-bytes.py", 
    "hash.py", 
    "headtail.py", 
    "hex-to-bin.py", 
    "jpegdump.py", 
    "js-ascii.exe", 
    "js-file.exe", 
    "libnspr4.dll", 
    "msoffcrypto-crack.py", 
    "myjson-filter.py", 
    "myjson-transform.py", 
    "nsrl.py", 
    "numbers-to-hex.py", 
    "numbers-to-string.py", 
    "oledump.py", 
    "pdf-parser.py", 
    "pdfid.ini", 
    "pdfid.py", 
    "pdftool.py", 
    "pecheck.py", 
    "plugin_biff.py", 
    "plugin_clsid.py", 
    "plugin_dridex.py", 
    "plugin_dttm.py", 
    "plugin_embeddedfile.py", 
    "plugin_hifo.py", 
    "plugin_http_heuristics.py", 
    "plugin_jumplist.py", 
    "plugin_linear.py", 
    "plugin_list", 
    "plugin_metadata.py", 
    "plugin_msg_summary.py", 
    "plugin_msg.py", 
    "plugin_msi.py", 
    "plugin_msi_info.py", 
    "plugin_nameobfuscation.py", 
    "plugin_office_crypto.py", 
    "plugin_olestreams.py", 
    "plugin_pcode_dumper.py", 
    "plugin_ppt.py", 
    "plugin_str_sub.py", 
    "plugin_stream_o.py", 
    "plugin_stream_sample.py", 
    "plugin_triage.py", 
    "plugin_vba_dco.py", 
    "plugin_vba_dir.py", 
    "plugin_vba_routines.py", 
    "plugin_vba_summary.py", 
    "plugin_vba.py", 
    "plugin_vbaproject.py", 
    "plugin_version_vba.py", 
    "process-binary-file.py", 
    "process-text-file.py", 
    "python-per-line.library", 
    "python-per-line.py", 
    "re-search.py", 
    "reextra.py", 
    "rtfdump.py", 
    "sets.py", 
    "sortcanon.py", 
    "split-overlap.py", 
    "split.py", 
    "ssdeep.py", 
    "strings.py", 
    "teeplus.py", 
    "translate.py", 
    "what-is-new.py", 
    "xmldump.py", 
    "xor-kpa.py", 
    "xorsearch.py", 
    "zipdump.py"
)

$totalFiles += $DidierStevensSuite.Count

# Download each tool from the main suite
foreach ($tool in $DidierStevensSuite) {
    try {
        # Determine expected file type based on extension
        $extension = [System.IO.Path]::GetExtension($tool)
        $checkString = switch ($extension) {
            ".exe"  { "PE32" }
            ".dll"  { "PE32" }
            ".py"   { "(Python script|^$)" }
            ".def"  { "magic text fragment" }
            ".json" { "JSON text data" }
            default { "ASCII text" }
        }
        
        # Download the file
        $sourceUrl = "https://raw.githubusercontent.com/DidierStevens/DidierStevensSuite/master/${tool}"
        $destPath = "${destinationPath}\${tool}"
        
        Write-Verbose "Downloading $tool from $sourceUrl"
        $status = Get-FileFromUri -uri $sourceUrl -FilePath $destPath -check $checkString
        
        if ($status -eq $true) {
            $downloadedFiles++
            Write-Verbose "Successfully downloaded $tool"
        }
    }
    catch {
        $errorFiles++
        Write-DateLog "ERROR: Failed to download $tool - $_"
    }
}

#endregion Main Repository Tools

#region Beta Repository Tools

Write-DateLog "Downloading tools from Didier Stevens Beta repository"

# List of beta tools to download
$DidierStevensBeta = @(
    "metatool.py",
    "onedump.py",
    "pngdump.py",
    "xlsbdump.py"
)

$totalFiles += $DidierStevensBeta.Count

# Download each beta tool
foreach ($tool in $DidierStevensBeta) {
    try {
        # Beta tools are all Python scripts
        $sourceUrl = "https://raw.githubusercontent.com/DidierStevens/Beta/master/${tool}"
        $destPath = "${destinationPath}\${tool}"
        
        Write-Verbose "Downloading beta tool $tool from $sourceUrl"
        $status = Get-FileFromUri -uri $sourceUrl -FilePath $destPath -check "Python script"
        
        if ($status -eq $true) {
            $downloadedFiles++
            Write-Verbose "Successfully downloaded beta tool $tool"
        }
    }
    catch {
        $errorFiles++
        Write-DateLog "ERROR: Failed to download beta tool $tool - $_"
    }
}

#endregion Beta Repository Tools

# Summary
Write-DateLog "Didier Stevens tools download summary: Downloaded $downloadedFiles of $totalFiles files. Errors: $errorFiles"
