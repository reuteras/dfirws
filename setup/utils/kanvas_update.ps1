# Kanvas Auto-Update Script for Windows PowerShell
# This script automates the update process for the Kanvas application

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-StatusWarning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-StatusError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Main script execution
try {
    Write-Status "Starting Kanvas Auto-Update..."

    # Check if we're in the correct directory
    if (-not (Test-Path "kanvas.py")) {
        Write-StatusError "kanvas.py not found. Please run this script from the Kanvas directory."
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Check if Python is available
    $pythonCmd = $null
    try {
        $null = python --version 2>$null
        $pythonCmd = "python"
        Write-Status "Using Python command: python"
    }
    catch {
        try {
            $null = python3 --version 2>$null
            $pythonCmd = "python3"
            Write-Status "Using Python command: python3"
        }
        catch {
            Write-StatusError "Python is not installed or not in PATH"
            Read-Host "Press Enter to exit"
            exit 1
        }
    }

    # Check if required modules are available
    Write-Status "Checking dependencies..."
    try {
        & $pythonCmd -c "import requests, sqlite3, pandas, openpyxl" 2>$null
        Write-Status "All dependencies found"
    }
    catch {
        Write-StatusWarning "Some dependencies might be missing. The script will attempt to run anyway."
    }

    # Create the simple updater script if it doesn't exist
    if (-not (Test-Path "simple_updater.py")) {
        Write-Status "Creating simple updater script..."
        
        $updaterScript = @'
#!/usr/bin/env python3
"""
Simple Kanvas Updater - Automated version
This script runs the download updates functionality without the GUI
"""

import sys
import os
import logging
from pathlib import Path

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('update.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def run_updates():
    """Run the download updates process"""
    try:
        # Add current directory to path
        current_dir = Path(__file__).parent
        sys.path.insert(0, str(current_dir))
        
        # Import required modules
        from helper.database_utils import create_all_tables
        from helper.download_updates import DownloadWorker
        
        # Initialize database
        db_path = "kanvas.db"
        logger.info("Initializing database...")
        create_all_tables(db_path)
        
        # URLs from the original code
        urls = {
            "dan.txt": "https://raw.githubusercontent.com/alireza-rezaee/tor-nodes/main/latest.all.csv",
            "torproject.txt": "https://check.torproject.org/torbulkexitlist",
            "d3fend-full-mappings.csv": "https://d3fend.mitre.org/api/ontology/inference/d3fend-full-mappings.csv",
            "user.json": "https://raw.githubusercontent.com/adamfowlerit/msportals.io/refs/heads/master/_data/portals/user.json",
            "admin.json": "https://raw.githubusercontent.com/adamfowlerit/msportals.io/refs/heads/master/_data/portals/admin.json",
            "thirdparty.json": "https://raw.githubusercontent.com/adamfowlerit/msportals.io/refs/heads/master/_data/portals/thirdparty.json",
            "us-govt.json": "https://raw.githubusercontent.com/adamfowlerit/msportals.io/refs/heads/master/_data/portals/us-govt.json",
            "china.json": "https://raw.githubusercontent.com/adamfowlerit/msportals.io/refs/heads/master/_data/portals/china.json",
            "edu.json": "https://raw.githubusercontent.com/adamfowlerit/msportals.io/refs/heads/master/_data/portals/edu.json",
            "licensing.json": "https://raw.githubusercontent.com/adamfowlerit/msportals.io/refs/heads/master/_data/portals/licensing.json",
            "training.json": "https://raw.githubusercontent.com/adamfowlerit/msportals.io/refs/heads/master/_data/portals/training.json",
            "evtx_id.csv": "https://raw.githubusercontent.com/arimboor/lookups/refs/heads/main/evtx_id.csv",
            "mitre_techniques.csv": "https://raw.githubusercontent.com/arimboor/lookups/refs/heads/main/mitre_techniques_v17.csv",
            "known_exploited_vulnerabilities.csv": "https://www.cisa.gov/sites/default/files/csv/known_exploited_vulnerabilities.csv",
            "MicrosoftApps.csv": "https://raw.githubusercontent.com/merill/microsoft-info/main/_info/MicrosoftApps.csv",
            "GraphAppRoles.csv": "https://raw.githubusercontent.com/merill/microsoft-info/main/_info/GraphAppRoles.csv",
            "GraphDelegateRoles.csv": "https://raw.githubusercontent.com/merill/microsoft-info/main/_info/GraphDelegateRoles.csv",
            "Malicious_EntraID.csv": "https://raw.githubusercontent.com/arimboor/lookups/refs/heads/main/Malicious_EntraID.csv",
            "onetracker.csv": "https://raw.githubusercontent.com/arimboor/lookups/refs/heads/main/onetracker.csv",
            "evidencetype.csv": "https://raw.githubusercontent.com/arimboor/lookups/refs/heads/main/evidencetype.csv",
            "secureupdates.txt": "https://secureupdates.checkpoint.com/IP-list/TOR.txt",
        }
        
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
        
        # Create and run worker
        worker = DownloadWorker(db_path, urls, headers)
        logger.info("Starting download process...")
        worker.run()
        logger.info("Update process completed successfully")
        
    except Exception as e:
        logger.error(f"Error during update: {e}")
        import traceback
        traceback.print_exc()
        raise

if __name__ == "__main__":
    run_updates()
'@

        $updaterScript | Out-File -FilePath "simple_updater.py" -Encoding UTF8
        Write-Status "Simple updater script created successfully"
    }

    # Run the update
    Write-Status "Starting Kanvas update process..."
    Write-Host "This may take a few minutes depending on your internet connection..." -ForegroundColor Cyan
    
    $process = Start-Process -FilePath $pythonCmd -ArgumentList "simple_updater.py" -Wait -PassThru -NoNewWindow
    
    # Check if the update was successful
    if ($process.ExitCode -eq 0) {
        Write-Status "Update completed successfully!"
        
        # Check if update.log exists and show last few lines
        if (Test-Path "update.log") {
            Write-Status "Recent log entries:"
            Get-Content "update.log" | Select-Object -Last 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
        }
        
        Write-Host "`nUpdate process finished successfully!" -ForegroundColor Green
        Write-Host "You can now run the Kanvas application with the latest data." -ForegroundColor Green
    }
    else {
        Write-StatusError "Update failed. Exit code: $($process.ExitCode)"
        
        # Show error logs if available
        if (Test-Path "update.log") {
            Write-Host "`nRecent log entries:" -ForegroundColor Yellow
            Get-Content "update.log" | Select-Object -Last 10 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        }
        
        Write-Host "`nTroubleshooting tips:" -ForegroundColor Yellow
        Write-Host "1. Check your internet connection" -ForegroundColor Yellow
        Write-Host "2. Ensure all Python dependencies are installed" -ForegroundColor Yellow
        Write-Host "3. Check the update.log file for detailed error information" -ForegroundColor Yellow
        Write-Host "4. Try running the update manually: python simple_updater.py" -ForegroundColor Yellow
        
        Read-Host "`nPress Enter to exit"
        exit 1
    }
}
catch {
    Write-StatusError "An unexpected error occurred: $($_.Exception.Message)"
    Write-Host "Stack trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    Read-Host "`nPress Enter to exit"
    exit 1
}

Write-Status "Cleaning up temporary files..."

# List of temporary files that might be created during download
$tempFiles = @(
    "dan.txt", "torproject.txt", "d3fend-full-mappings.csv", "user.json", 
    "admin.json", "thirdparty.json", "us-govt.json", "china.json", 
    "edu.json", "licensing.json", "training.json", "evtx_id.csv", 
    "mitre_techniques.csv", "known_exploited_vulnerabilities.csv", 
    "MicrosoftApps.csv", "GraphAppRoles.csv", "GraphDelegateRoles.csv", 
    "Malicious_EntraID.csv", "onetracker.csv", "evidencetype.csv", 
    "secureupdates.txt"
)

foreach ($file in $tempFiles) {
    if (Test-Path $file) {
        try {
            Remove-Item $file -Force
            Write-Host "  Removed: $file" -ForegroundColor Gray
        }
        catch {
            Write-StatusWarning "Could not remove $file"
        }
    }
}

Write-Status "Cleanup completed"
Write-Host "`nScript execution completed." -ForegroundColor Green
