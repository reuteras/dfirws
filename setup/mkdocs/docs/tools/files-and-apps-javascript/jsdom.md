# jsdom

**Category:** Files and apps / JavaScript

**Source:** npm

**Profiles:** Full, Basic

**File Extensions:** `.html`, `.htm`, `.js`

**Tags:** javascript, parsing

jsdom is a pure-JavaScript implementation of many web standards, notably the WHATWG DOM and HTML Standards, for use with Node.js. In general, the goal of the project is to emulate enough of a subset of a web browser to be useful for testing and scraping real-world web applications.

## Tips
Use jsdom in Node scripts to emulate a browser DOM when stepping through malicious JavaScript that expects document and window objects. box-js is the packaged alternative for WScript samples.

## Usage
node -e "const {JSDOM} = require('jsdom'); const dom = new JSDOM('<p>hi</p>'); console.log(dom.window.document.body.textContent)"
