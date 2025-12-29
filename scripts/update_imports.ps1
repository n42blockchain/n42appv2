# Copyright 2021-2026 N42 Inc. All rights reserved.
# Script to update import paths from old structure to new structure
# Author: Jiang Yiwei

param(
    [switch]$DryRun = $false,
    [switch]$GitCommit = $false
)

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $projectRoot

Write-Host "=== N42 Import Path Migration Script ===" -ForegroundColor Cyan
Write-Host "Project Root: $projectRoot"
Write-Host "Dry Run: $DryRun"
Write-Host ""

# Define import replacements
$replacements = @(
    @{
        Old = "import 'package:n42appv2/application.dart'"
        New = "import 'package:n42appv2/core/app/app_globals.dart'"
        Desc = "Application -> AppGlobals"
    },
    @{
        Old = "import 'package:n42appv2/app_config.dart'"
        New = "import 'package:n42appv2/core/config/app_config.dart'"
        Desc = "AppConfig"
    },
    @{
        Old = "import 'package:n42appv2/src/utils/theme_adapter.dart'"
        New = "import 'package:n42appv2/presentation/themes/theme_adapter.dart'"
        Desc = "ThemeAdapter"
    },
    @{
        Old = "import 'package:n42appv2/src/utils/event_bus.dart'"
        New = "import 'package:n42appv2/core/utils/event_bus.dart'"
        Desc = "EventBus"
    },
    @{
        Old = "import 'package:n42appv2/src/utils/toast_utils.dart'"
        New = "import 'package:n42appv2/core/utils/toast_utils.dart'"
        Desc = "ToastUtils"
    },
    @{
        Old = "import 'package:n42appv2/src/utils/sp_util.dart'"
        New = "import 'package:n42appv2/core/storage/sp_util.dart'"
        Desc = "SPUtil"
    },
    @{
        Old = "import 'package:n42appv2/src/sqlite/app_database.dart'"
        New = "import 'package:n42appv2/core/storage/app_database.dart'"
        Desc = "AppDatabase"
    },
    @{
        Old = "import 'package:n42appv2/src/https/base_http.dart'"
        New = "import 'package:n42appv2/core/network/base_http.dart'"
        Desc = "BaseHttp"
    },
    @{
        Old = "import 'package:n42appv2/src/models/user_info.dart'"
        New = "import 'package:n42appv2/data/models/user_info.dart'"
        Desc = "UserInfo"
    }
)

# Class name replacements (Application -> AppGlobals)
$classReplacements = @(
    @{
        Old = "Application.AppContext"
        New = "AppGlobals.appContext"
        Desc = "AppContext"
    },
    @{
        Old = "Application.navigatorKey"
        New = "AppGlobals.navigatorKey"
        Desc = "navigatorKey"
    },
    @{
        Old = "Application.routeObserver"
        New = "AppGlobals.routeObserver"
        Desc = "routeObserver"
    },
    @{
        Old = "Application.userInfo"
        New = "AppGlobals.userInfo"
        Desc = "userInfo"
    },
    @{
        Old = "Application.currentId"
        New = "AppGlobals.currentId"
        Desc = "currentId"
    },
    @{
        Old = "Application.login"
        New = "AppGlobals.login"
        Desc = "login"
    },
    @{
        Old = "Application.logout"
        New = "AppGlobals.logout"
        Desc = "logout"
    }
)

$totalFiles = 0
$totalReplacements = 0

# Get all Dart files in lib/src
$dartFiles = Get-ChildItem -Path "lib/src" -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileModified = $false
    
    # Apply import replacements
    foreach ($r in $replacements) {
        if ($content -match [regex]::Escape($r.Old)) {
            $content = $content -replace [regex]::Escape($r.Old), $r.New
            $fileModified = $true
            Write-Host "  [IMPORT] $($r.Desc)" -ForegroundColor Yellow
        }
    }
    
    # Apply class replacements
    foreach ($r in $classReplacements) {
        if ($content -match [regex]::Escape($r.Old)) {
            $content = $content -replace [regex]::Escape($r.Old), $r.New
            $fileModified = $true
            Write-Host "  [CLASS] $($r.Desc)" -ForegroundColor Magenta
        }
    }
    
    if ($fileModified) {
        $totalFiles++
        $relativePath = $file.FullName.Substring($projectRoot.Length + 1)
        Write-Host "Modified: $relativePath" -ForegroundColor Green
        
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        }
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Total files modified: $totalFiles"

if ($DryRun) {
    Write-Host "(Dry run - no files were actually changed)" -ForegroundColor Yellow
}

# Git commit if requested
if ($GitCommit -and -not $DryRun -and $totalFiles -gt 0) {
    Write-Host ""
    Write-Host "=== Creating Git Commit ===" -ForegroundColor Cyan
    
    git add -A
    $commitMessage = "refactor: migrate import paths to new architecture

- Updated $totalFiles files with new import paths
- Application -> AppGlobals
- app_config.dart -> core/config/app_config.dart
- theme_adapter.dart -> presentation/themes/theme_adapter.dart
- event_bus.dart -> core/utils/event_bus.dart
- toast_utils.dart -> core/utils/toast_utils.dart
- sp_util.dart -> core/storage/sp_util.dart
- base_http.dart -> core/network/base_http.dart
- user_info.dart -> data/models/user_info.dart"
    
    git commit -m $commitMessage
    Write-Host "Git commit created successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green

