# Copyright 2021-2026 N42 Inc. All rights reserved.
# Script for automatic git commits during refactoring
# Author: Jiang Yiwei

param(
    [Parameter(Mandatory=$true)]
    [string]$Message,
    
    [string]$Type = "refactor",
    
    [switch]$Push = $false
)

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $projectRoot

Write-Host "=== Auto Git Commit ===" -ForegroundColor Cyan

# Check for changes
$status = git status --porcelain
if (-not $status) {
    Write-Host "No changes to commit." -ForegroundColor Yellow
    exit 0
}

# Stage all changes
git add -A

# Create commit message with conventional commit format
$fullMessage = "$Type`: $Message"

# Commit
git commit -m $fullMessage

if ($LASTEXITCODE -eq 0) {
    Write-Host "Commit created: $fullMessage" -ForegroundColor Green
    
    if ($Push) {
        Write-Host "Pushing to remote..." -ForegroundColor Cyan
        git push
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Pushed successfully!" -ForegroundColor Green
        } else {
            Write-Host "Push failed!" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Commit failed!" -ForegroundColor Red
}

