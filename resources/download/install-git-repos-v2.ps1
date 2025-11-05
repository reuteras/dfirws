# DFIRWS Git Repositories Installer (v2 - YAML-based)
# Clones/updates Git repositories from git-repositories.yaml
# Version: 2.0

param(
    [Parameter(HelpMessage = "Clone/update all repositories")]
    [Switch]$All,

    [Parameter(HelpMessage = "Clone/update specific repository by name")]
    [string]$RepoName,

    [Parameter(HelpMessage = "Filter by category type")]
    [string]$CategoryType,

    [Parameter(HelpMessage = "Dry run - show what would be done")]
    [Switch]$DryRun,

    [Parameter(HelpMessage = "Update existing repositories")]
    [Switch]$Update
)

# Import modules
. ".\resources\download\common.ps1"
. ".\resources\download\yaml-parser.ps1"

$ROOT_PATH = "${PWD}"
$GIT_BASE_PATH = "${ROOT_PATH}\mount\git"

Write-DateLog "Git Repositories Installer v2 - Loading definitions from YAML" > ${ROOT_PATH}\log\git_repos.txt

# Ensure git directory exists
if (-not (Test-Path $GIT_BASE_PATH)) {
    New-Item -ItemType Directory -Path $GIT_BASE_PATH -Force | Out-Null
    Write-DateLog "Created git directory: $GIT_BASE_PATH" >> ${ROOT_PATH}\log\git_repos.txt
}

# Load Git repositories from YAML
$gitRepos = Import-GitRepositoriesDefinition

if (-not $gitRepos) {
    Write-DateLog "Failed to load Git repositories definitions" >> ${ROOT_PATH}\log\git_repos.txt
    exit 1
}

Write-DateLog "Loaded $($gitRepos.Count) Git repositories from YAML" >> ${ROOT_PATH}\log\git_repos.txt

# Filter repositories based on parameters
$reposToInstall = $gitRepos

if ($RepoName) {
    $reposToInstall = $gitRepos | Where-Object { $_.name -eq $RepoName }
    if (-not $reposToInstall) {
        Write-Error "Repository not found: $RepoName"
        exit 1
    }
} elseif ($CategoryType) {
    $reposToInstall = $gitRepos | Where-Object { $_.category_type -eq $CategoryType }
}

if ($DryRun) {
    Write-Output "`n=== DRY RUN MODE ==="
    Write-Output "Would clone/update the following repositories:"
    foreach ($repo in $reposToInstall) {
        Write-Output "  - $($repo.name) ($($repo.category_type))"
        Write-Output "    URL: $($repo.url)"
        Write-Output "    Priority: $($repo.priority)"
    }
    Write-Output "===================`n"
    exit 0
}

function Install-GitRepository {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Repo
    )

    $repoName = $Repo.name
    $repoUrl = $Repo.url
    $repoPath = Join-Path $GIT_BASE_PATH $repoName

    Write-DateLog "Processing repository: $repoName" >> ${ROOT_PATH}\log\git_repos.txt

    try {
        if (Test-Path $repoPath) {
            if ($Update) {
                Write-DateLog "Updating existing repository: $repoName" >> ${ROOT_PATH}\log\git_repos.txt

                Push-Location $repoPath
                $result = git pull origin 2>&1
                Pop-Location

                if ($LASTEXITCODE -eq 0) {
                    Write-DateLog "Successfully updated: $repoName" >> ${ROOT_PATH}\log\git_repos.txt
                    return $true
                } else {
                    Write-DateLog "Failed to update $repoName : $result" >> ${ROOT_PATH}\log\git_repos.txt
                    return $false
                }
            } else {
                Write-DateLog "Repository already exists: $repoName (use -Update to update)" >> ${ROOT_PATH}\log\git_repos.txt
                return $true
            }
        } else {
            Write-DateLog "Cloning repository: $repoName from $repoUrl" >> ${ROOT_PATH}\log\git_repos.txt

            $result = git clone $repoUrl $repoPath 2>&1

            if ($LASTEXITCODE -eq 0) {
                Write-DateLog "Successfully cloned: $repoName" >> ${ROOT_PATH}\log\git_repos.txt

                # Apply post-clone patches if specified
                if ($Repo.post_clone) {
                    Write-DateLog "Applying post-clone patches for $repoName" >> ${ROOT_PATH}\log\git_repos.txt
                    Invoke-PostClonePatches -Repo $Repo -RepoPath $repoPath
                }

                return $true
            } else {
                Write-DateLog "Failed to clone $repoName : $result" >> ${ROOT_PATH}\log\git_repos.txt
                return $false
            }
        }
    } catch {
        Write-DateLog "Error processing $repoName : $_" >> ${ROOT_PATH}\log\git_repos.txt
        return $false
    }
}

function Invoke-PostClonePatches {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Repo,

        [Parameter(Mandatory=$true)]
        [string]$RepoPath
    )

    # This would handle post-clone operations like:
    # - Applying patches
    # - Running setup scripts
    # - Copying specific files

    if ($Repo.notes -and $Repo.notes -match "patch") {
        Write-DateLog "Repository $($Repo.name) may require patches (see notes)" >> ${ROOT_PATH}\log\git_repos.txt
    }
}

# Statistics
$stats = @{
    total = $reposToInstall.Count
    success = 0
    failed = 0
    skipped = 0
}

# Install repositories
Write-DateLog "Starting processing of $($reposToInstall.Count) Git repositories" >> ${ROOT_PATH}\log\git_repos.txt

foreach ($repo in $reposToInstall) {
    $result = Install-GitRepository -Repo $repo

    if ($result) {
        $stats.success++
    } else {
        $stats.failed++
    }
}

# Summary
Write-DateLog "`n========================================" >> ${ROOT_PATH}\log\git_repos.txt
Write-DateLog "Git Repositories Installation Summary" >> ${ROOT_PATH}\log\git_repos.txt
Write-DateLog "========================================" >> ${ROOT_PATH}\log\git_repos.txt
Write-DateLog "Total repositories: $($stats.total)" >> ${ROOT_PATH}\log\git_repos.txt
Write-DateLog "Successfully processed: $($stats.success)" >> ${ROOT_PATH}\log\git_repos.txt
Write-DateLog "Failed: $($stats.failed)" >> ${ROOT_PATH}\log\git_repos.txt
Write-DateLog "========================================`n" >> ${ROOT_PATH}\log\git_repos.txt

Write-Output "`n========================================`n"
Write-Output "Git Repositories Installation Complete"
Write-Output "Success: $($stats.success) / $($stats.total)"
if ($stats.failed -gt 0) {
    Write-Output "Failed: $($stats.failed)"
}
Write-Output "========================================`n"
