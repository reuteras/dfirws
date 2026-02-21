# Investigate JavaScript files

You can use the following tools to inspect JavaScript:

- [synchrony](https://github.com/relative/synchrony/)
- [Visual Studio Code](https://code.visualstudio.com/) with [Node.js](https://nodejs.org/en) and [jsdom](https://www.npmjs.com/package/jsdom)
- [js-beautify](https://github.com/beautify-web/js-beautify) installed via Python pip

There is also a [Jupyter Notebook](https://github.com/reuteras/dfirws/blob/main/setup/jupyter/pdf.ipynb) available.

## synchrony

Save the script and only the script in a file, for example *malware.js*. Then run

```PowerShell
synchrony .\malware.js
```

The cleaned file will be available as *malware.cleaned.js*.

## js-beautify

The command below will save the beautified script in the file *beautified.js*. Without the `-o beautified.js` option the cleaned code will be sent to `stdout`.

```PowerShell
js-beautify.exe -o beautified.js .\obfuscated.js
```

## jsdom in Visual Studio Code

This options allows you to load a HTML file and run the JavaScript in the file. First open **PowerShell** and runt the following commands:

```PowerShell
(venv) PS C:\Users\WDAGUtilityAccount\node> Copy-Node
(venv) PS C:\Users\WDAGUtilityAccount\node> cd .\node\
(venv) PS C:\Users\WDAGUtilityAccount\node> cp C:\Users\WDAGUtilityAccount\Desktop\readonly\malware.zip .
(venv) PS C:\Users\WDAGUtilityAccount\node> 7z -pinfected x .\malware.zip | Out-Null
(venv) PS C:\Users\WDAGUtilityAccount\node> # Extracts the file .\malware.html
(venv) PS C:\Users\WDAGUtilityAccount\node> code.cmd .
```

In Visual Studio Code trust the folder and create a new file *malware.js* in the *node* directory with the following content:

```JavaScript
'use strict';

const { JSDOM } = require('jsdom');

const options = {
  resources: 'usable',
  runScripts: 'dangerously',
};

JSDOM.fromFile('index.html', options).then((dom) => {
  console.log(dom.window.document.body.textContent.trim());

  setTimeout(() => {
    console.log(dom.window.document.body.textContent.trim());
  }, 5000);
});
```

**Make sure you are in a Sandbox without network access!**

Then select the menu option `Run` -> `Start Debugging` and select Node.js

It the script tries to access the network you will have an error message like the following:

```bash
Error: Could not load script: "https://example.com/directory/nextevilthing"
```

Now assume your sandbox is toast and close it and start a new one.

