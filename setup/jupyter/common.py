#
# Common functions for notebooks
#

import subprocess
from pathlib import Path

READONLY = Path("C:/Users/WDAGUtilityAccount/Desktop/readonly")


def execute7z(zipPathInput, zipPassword, zipPathOutput):
    """Execute 7zip batch command using subprocess call"""
    process = subprocess.Popen(
        [
            r"7z.exe",
            "x",
            zipPathInput,
            f"-p{zipPassword}",
            f"-o{zipPathOutput}",
        ]
    )
    process.wait()
    process.kill()
    return 0
