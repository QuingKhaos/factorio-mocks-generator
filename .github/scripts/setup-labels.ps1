# Setup Labels for factorio-mocks-generator Repository
# This script creates essential labels for PR management in the generator repository

param(
    [string]$RepoName = "QuingKhaos/factorio-mocks-generator"
)

Write-Host "Setting up essential labels for $RepoName repository..." -ForegroundColor Cyan

# Check if GitHub CLI is available
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) is not installed or not in PATH. Please install GitHub CLI first."
    exit 1
}

# Check authentication
gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "GitHub CLI is not authenticated. Please run 'gh auth login' first."
    exit 1
}

Write-Host "GitHub CLI is authenticated and ready." -ForegroundColor Green

# Function to create or update a label
function Set-Label {
    param(
        [string]$Name,
        [string]$Color,
        [string]$Description,
        [string]$Repository
    )

    Write-Host "Creating/updating label: $Name" -ForegroundColor Yellow

    # Try to create the label, if it exists, update it
    $createResult = gh label create $Name --color $Color --description $Description --repo $Repository 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [+] Created label: $Name" -ForegroundColor Green
    } else {
        # Label might already exist, try to edit it
        $editResult = gh label edit $Name --color $Color --description $Description --repo $Repository 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [+] Updated label: $Name" -ForegroundColor Green
        } else {
            Write-Host "  [X] Failed to create/update label: $Name" -ForegroundColor Red
            Write-Host "    Create error: $createResult" -ForegroundColor Red
            Write-Host "    Edit error: $editResult" -ForegroundColor Red
        }
    }
}

# Function to remove default GitHub labels that don't fit our workflow
function Remove-DefaultLabel {
    param(
        [string]$Name,
        [string]$Repository
    )

    Write-Host "Removing default label: $Name" -ForegroundColor Yellow

    gh label delete $Name --yes --repo $Repository 2>&1 | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [+] Removed label: $Name" -ForegroundColor Green
    } else {
        Write-Host "  [-] Label not found or already removed: $Name" -ForegroundColor Gray
    }
}

Write-Host "`nCreating Type Labels..." -ForegroundColor Magenta
Set-Label "type: bug" "d73a4a" "Bug fixes and error corrections" $RepoName
Set-Label "type: feature" "0075ca" "New functionality and enhancements" $RepoName
Set-Label "type: documentation" "0052cc" "Documentation updates" $RepoName
Set-Label "type: maintenance" "fbca04" "Dependency updates, refactoring, housekeeping" $RepoName

Write-Host "`nCreating Component Labels..." -ForegroundColor Magenta
Set-Label "component: extraction" "1d76db" "Data extraction functionality" $RepoName
Set-Label "component: validation" "1d76db" "Data validation and quality checks" $RepoName
Set-Label "component: distribution" "1d76db" "Git publishing and data distribution" $RepoName
Set-Label "component: ci-cd" "1d76db" "CI/CD workflows and automation" $RepoName

Write-Host "`nCreating Ecosystem Labels..." -ForegroundColor Magenta
Set-Label "ecosystem: generator" "7057ff" "Generator repository coordination" $RepoName

Write-Host "`nRemoving Default GitHub Labels..." -ForegroundColor Magenta
$defaultLabels = @("bug", "documentation", "duplicate", "enhancement", "good first issue", "help wanted", "invalid", "question", "wontfix")

foreach ($label in $defaultLabels) {
    Remove-DefaultLabel $label $RepoName
}

Write-Host "`n[SUCCESS] Label setup completed for $RepoName repository!" -ForegroundColor Green
Write-Host "`nEssential labels created:" -ForegroundColor Cyan
Write-Host "  * Type labels (4): bug, feature, documentation, maintenance" -ForegroundColor White
Write-Host "  * Component labels (4): extraction, validation, distribution, ci-cd" -ForegroundColor White
Write-Host "  * Ecosystem labels (1): generator" -ForegroundColor White
Write-Host "`nTotal: 9 essential labels for PR management" -ForegroundColor Cyan
