#
# Common functions for notebooks
#

import os
import subprocess
from pathlib import Path

READONLY = Path(os.getenv("USERPROFILE") + "/Desktop/readonly")


def execute7z(zipPathInput, zipPassword, zipPathOutput):
    """Excecute 7zip batch command using subprocess call"""
    process = subprocess.Popen([r"7z.exe", "x", zipPathInput, "-p{}".format(zipPassword), "-o{}".format(zipPathOutput)])
    process.wait()
    process.kill()
    return 0
 