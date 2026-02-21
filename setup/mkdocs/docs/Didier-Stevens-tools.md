# Didier Stevens tools

[Didier Stevens](https://github.com/DidierStevens/DidierStevensSuite) tools are available under *C:\Tools\DidierStevens*.

Below is a collection of links to ISC Storm Center that uses the tools in Didier Stevens suite. All the examples can be run in dfirws. I have also added PDFs for offline use.

- [String Obfuscation: Character Pair Reversal](https://isc.sans.edu/forums/diary/String+Obfuscation+Character+Pair+Reversal/29654/) [(PDF)](./resources/String.Obfuscation_.Character.Pair.Reversal.-.SANS.Internet.Storm.Center.pdf)
  - `zipdump.py`
  - `strings.py`
  - `re-search.py`
  - `python-per-line.py`
- [Extra: "String Obfuscation: Character Pair Reversal"](https://isc.sans.edu/forums/diary/Extra+String+Obfuscation+Character+Pair+Reversal/29656/)
  [(PDF)](./resources/Extra_._String.Obfuscation_.Character.Pair.Reversal_.-.SANS.Internet.Storm.Center.pdf)
  - `strings.py`
  - `python-per-line.py` (*Reverse* and *ReverseFind*)
  - `numbers-to-strings.py`
- [Extracting Multiple Streams From OLE Files](https://isc.sans.edu/forums/diary/Extracting+Multiple+Streams+From+OLE+Files/29688/)
  [(PDF)](./resources/Extracting.Multiple.Streams.From.OLE.Files.-.SANS.Internet.Storm.Center.pdf)
  - `oledump.py`
  - `file-magic.py`
  - `myjson-filter.py`
  - Uses *--jsoninput* and *--jsonoutput* in the pipe
- [Another Malicious HTA File Analysis - Part 1](https://isc.sans.edu/forums/diary/Another+Malicious+HTA+File+Analysis+Part+1/29674/)
  [(PDF)](./resources/Another.Malicious.HTA.File.Analysis.-.Part.1.-.SANS.Internet.Storm.Center.pdf)
  - `zipdump.py`
  - `python-per-line.py` (*--split*, *--regex*, *oMatch.groups()* and *--join*)
- [Another Malicious HTA File Analysis - Part 2](https://isc.sans.edu/forums/diary/Another+Malicious+HTA+File+Analysis+Part+2/29676/) [(PDF)](./resources/Another.Malicious.HTA.File.Analysis.-.Part.2.-.SANS.Internet.Storm.Center.pdf)
  - `zipdump.py`
  - `python-per-line.py` (*--split*, *--regex*, *--join*)
  - `base64dump.py` (*--jsonoutput*)
  - `myjson-transform.py`(*--script*)
  - `numbers-to-string.py`
