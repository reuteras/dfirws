The first steps of getting started are described in the [README.md](https://github.com/reuteras/dfirws/blob/main/README.md) file in the git [repository](https://github.com/reuteras/dfirws). First follow the steps in [Installation and configuration](https://github.com/reuteras/dfirws?tab=readme-ov-file#installation-and-configuration) then continue with the steps in the section [Download tools and enrichment data](https://github.com/reuteras/dfirws?tab=readme-ov-file#download-tools-and-enrichment-data).

Next step is to start the sandbox and you can choose between **dfirws.wsb** and **network_dfirws.wsb**. The first one has no network access or the other one has network access. When the sandbox is running you should see this screen:
 
![Default start screen](images/default.png)

You can search for tools in the search bar (in this case Ghidra):

![Search example](images/search.png)

If you like to access a local version of this wiki click on *dfirws wiki*. If you like to use a [[Jupyter notebooks]] to investigate files click on *jupyter*.

Links to some of the installed tools can be found if open the folder *dfirws* on the desktop. (**Help wanted:** If you have any suggestions on how to make it easier to find the tools please create an [issue](https://github.com/reuteras/dfirws/issues)).

Tools are generally found under *C:\Tools* if they don't require a setup. Installed tools are installed in their default location (*C:\Program files* in most cases). Python based tools are in virtual environments under *C:\venv*. Git repositories are stored under *C:\git*. If you have opted in to download data for enrichment it is available under *C:\enrichment*.

## Security

Personally I wouldn't run malware in a Windows sandbox. I prefer to do that in a virtual machine. Even if there are tools included in the sandbox for running and debugging malware I wouldn't recommend that you use them in that way.
