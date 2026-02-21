# Investigate OneNote files

Included tools (not a complete list).

- [pyOneNote][pon]
- [onedump.py][opy]

## Example

The file is available on [Malware Bazaar](https://bazaar.abuse.ch/sample/29d154eafeb75a7059fc164c70ae746c6f3eb83d29853b3856d0aa8f8df0adde/).

First lets unpack the file.

![Unpack file](../images/OneNote/one1.png)

We can use **Yara**, **file-magic.py**, **file.exe** and **trid.exe** to check the file.

![Check file with Yara, file-magic.py, file and Trid](../images/OneNote/one2.png)

The tools **onenote.py** and **pyonenote.exe** are two tools that can be used to extract files from OneNote documents.

![Extract files from OneNote with onenote.py or pyonenote.exe](../images/OneNote/one3.png)

Output from **pyonenote.exe**.

![Output from pyonenote.exe](../images/OneNote/one4.png)

Look at *file_1.bat* (named by **pyonenote.exe**) in **Notepad++**. Remove the first line.

![Image of file_1.bat](../images/OneNote/one5.png)

Cut line `61` and save it for later.

![Show line 61](../images/OneNote/one6.png)
![File with line 61](../images/OneNote/one7.png)
![Line 61 removed](../images/OneNote/one8.png)

The last lines of the files looks like this.

![Last lines of the file](../images/OneNote/one9.png)

Change the last line of the file to:

![Changed the last lines of the files](../images/OneNote/one10.png)

Save the file and run it. **WARNING** This is malware and it can infect your computer!

Copy the command part of the output.

![Output](../images/OneNote/one11.png)

The command in **Notepad++**. Only two lines when pasted.

![Command in Notepad++](../images/OneNote/one12.png)

Change ";" to "\n".

![Change ";" to "\n"](../images/OneNote/one13.png)

The PowerShell script is now a bit easier to read. Almost the same code, use the second half.

![The PowerShell script](../images/OneNote/one14.png)

We can see that the code gets line 61 from the first *bat* file.

![PowerShell code to read line 61 from the bat file](../images/OneNote/one15.png)

Modified script with line 61 inserted and a added **Write-Host** statement and the last lines commented out.

![Modified script](../images/OneNote/one16.png)

Run the command.

![Output from the command when executed](../images/OneNote/one17.png)

Copy and paste the output from the command to **CyberChef** and use its **magic** functions.

![Output added to Cyberchef](../images/OneNote/one18.png)

Press the disc icon to save the output to file (a MZ-file).

![Save the file](../images/OneNote/one19.png)

You have to press keep to save the file.

![Press keep to save the file](../images/OneNote/one20.png)

The file is now under *~/Downloads*.

![The file is in the Downloads directory](../images/OneNote/one21.png)

We can check the file with **capa.exe**.

![Output from capa.exe](../images/OneNote/one22.png)

Look at available tools matching *PE*.

![PE tools](../images/OneNote/one23.png)

Open in **pestudio**. We can see that it is a 32-bit .Net binary

![File opened in pestudio](../images/OneNote/one24.png)

We can use *dnSpy32* to look at it. Let's search for the program.

![dnSpy32 and dnSpy64 are available in the sandbox](../images/OneNote/one25.png)

The file opened at the *main* function in **dnSpy32**.

![dnspy32 opened the file](../images/OneNote/one26.png)

  [opy]: https://github.com/DidierStevens/Beta/blob/master/onedump.py
  [pon]: https://pypi.org/project/pyOneNote/
