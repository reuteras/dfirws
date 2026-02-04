[Didier Stevens](https://github.com/DidierStevens/DidierStevensSuite) tools are available under *C:\Tools\DidierStevens*.

Below is a collection of links to ISC Storm Center that uses the tools in Didier Stevens suite. All the examples can be run in dfirws. I have also added PDF:s for offline use.

- [String Obfuscation: Character Pair Reversal](https://isc.sans.edu/forums/diary/String+Obfuscation+Character+Pair+Reversal/29654/) [(pdf)](./resources/String.Obfuscation_.Character.Pair.Reversal.-.SANS.Internet.Storm.Center.pdf)
   - `zipdump.py`
   - `strings.py`
   - `re-search.py`
   - `python-per-line.py` 
- [Extra: "String Obfuscation: Character Pair Reversal"](https://isc.sans.edu/forums/diary/Extra+String+Obfuscation+Character+Pair+Reversal/29656/)
[(pdf)](./resources/Extra_._String.Obfuscation_.Character.Pair.Reversal_.-.SANS.Internet.Storm.Center.pdf)
    - `strings.py`
    - `python-per-line.py` (_Reverse_ and _ReverseFind_)
    - `numbers-to-strings.py`
- [Extracting Multiple Streams From OLE Files](https://isc.sans.edu/forums/diary/Extracting+Multiple+Streams+From+OLE+Files/29688/) 
[(pdf)](./resources/Extracting.Multiple.Streams.From.OLE.Files.-.SANS.Internet.Storm.Center.pdf)
   - `oledump.py`
   - `file-magic.py`
   - `myjson-filter.py`
   - Uses _--jsoninput_ and _--jsonoutput_ in the pipe
- [Another Malicious HTA File Analysis - Part 1](https://isc.sans.edu/forums/diary/Another+Malicious+HTA+File+Analysis+Part+1/29674/) 
[(pdf)](./resources/Another.Malicious.HTA.File.Analysis.-.Part.1.-.SANS.Internet.Storm.Center.pdf)
   - `zipdump.py`
   - `python-per-line.py` (_--split_, _--regex_, _oMatch.groups()_ and _--join_)
- [Another Malicious HTA File Analysis - Part 2](https://isc.sans.edu/forums/diary/Another+Malicious+HTA+File+Analysis+Part+2/29676/) [(pdf)](./resources/Another.Malicious.HTA.File.Analysis.-.Part.2.-.SANS.Internet.Storm.Center.pdf)
   - `zipdump.py`
   - `python-per-line.py` (_--split_, _--regex_, _--join_)
   - `base64dump.py` (_--jsonoutput_)
   - `myjson-transform.py `(_--script_)
   - `numbers-to-string.py`
