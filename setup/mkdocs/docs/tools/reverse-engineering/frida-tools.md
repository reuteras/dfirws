# frida-tools

**Category:** Reverse Engineering

**Homepage:** <https://frida.re>

**Vendor:** frida

**License:** [LGPL-2.0-or-later WITH WxWindows-exception-3.1](https://github.com/frida/frida-tools/blob/main/COPYING)

**Source:** Python

**Profiles:** Full, Basic

**File Extensions:** `.exe`, `.apk`, `.ipa`

**Tags:** reverse-engineering, dynamic-analysis

Frida CLI tools.

## Tips
Dynamic instrumentation: frida-trace traces API calls, frida -p <pid> -l script.js injects a script and frida-ps lists processes. Only instrument samples inside the sandbox.

## Usage
frida-trace -i 'CreateFile*' <exe>
