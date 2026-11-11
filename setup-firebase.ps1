param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectId
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$firebaseConfigPath = Join-Path $repositoryRoot 'firebase.json'
$rulesPath = Join-Path $repositoryRoot 'firestore.rules'

if (-not (Test-Path $firebaseConfigPath -PathType Leaf)) {
    throw "Firebase CLI config was not found: $firebaseConfigPath"
}

if (-not (Test-Path $rulesPath -PathType Leaf)) {
    throw "Firestore rules were not found: $rulesPath"
}

$firebaseCommand = Get-Command firebase -ErrorAction SilentlyContinue
if ($null -eq $firebaseCommand) {
    throw 'Firebase CLI is not installed. Install it with: npm install -g firebase-tools'
}

if ([string]::IsNullOrWhiteSpace($ProjectId)) {
    $ProjectId = Read-Host 'Firebase project ID'
}
$ProjectId = $ProjectId.Trim()

if ($ProjectId -notmatch '^[a-z][a-z0-9-]{4,28}[a-z0-9]$') {
    throw 'Enter a valid Firebase project ID (6-30 lowercase letters, digits, or hyphens; start with a letter).'
}

$firebaseConfig = Get-Content -Raw $firebaseConfigPath | ConvertFrom-Json
if ($firebaseConfig.firestore.rules -ne 'firestore.rules') {
    throw 'firebase.json does not point to the expected firestore.rules file.'
}

Push-Location $repositoryRoot
try {
    Write-Host 'Checking Firebase CLI authentication...'
    & $firebaseCommand.Source login
    if ($LASTEXITCODE -ne 0) {
        throw 'Firebase CLI login failed.'
    }

    Write-Host "Deploying Firestore rules to project '$ProjectId'..."
    & $firebaseCommand.Source deploy --only firestore:rules --project $ProjectId
    if ($LASTEXITCODE -ne 0) {
        throw "Firestore rules deployment failed for project '$ProjectId'."
    }

    Write-Host 'Firestore rules deployed successfully.'
}
finally {
    Pop-Location
}
