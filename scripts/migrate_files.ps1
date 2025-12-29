# File Migration Script for Feature-first Architecture
# Copyright 2021-2026 N42 Inc. All rights reserved.

param(
    [switch]$DryRun = $false,
    [string]$Feature = "all"
)

$ErrorActionPreference = "Stop"

Write-Host "=== N42 Wallet File Migration Script ===" -ForegroundColor Cyan
Write-Host "DryRun: $DryRun" -ForegroundColor Yellow

# Define migration mappings
$migrations = @{
    # Settings Feature
    "settings" = @(
        @{
            Source = "lib/src/home/setting/setting_theme.dart"
            Target = "lib/features/settings/presentation/pages/setting_theme_legacy.dart"
            Note = "Theme settings - has Riverpod version"
        },
        @{
            Source = "lib/src/home/setting/setting_sys_language.dart"
            Target = "lib/features/settings/presentation/pages/setting_language_legacy.dart"
            Note = "Language settings - has Riverpod version"
        },
        @{
            Source = "lib/src/home/setting/security/security_setting.dart"
            Target = "lib/features/settings/presentation/pages/security/security_setting.dart"
            Note = "Security settings"
        },
        @{
            Source = "lib/src/home/setting/browser_setting.dart"
            Target = "lib/features/browser/presentation/pages/browser_setting.dart"
            Note = "Browser settings - move to browser feature"
        }
    )
    
    # Wallet Feature
    "wallet" = @(
        @{
            Source = "lib/src/wallet/provider/wallet_action_provider.dart"
            Target = "lib/features/wallet/presentation/providers/wallet_action_provider_legacy.dart"
            Note = "Legacy provider - gradually migrate to Riverpod"
        },
        @{
            Source = "lib/src/wallet/pages/wallet_page.dart"
            Target = "lib/features/wallet/presentation/pages/wallet_page_legacy.dart"
            Note = "Main wallet page"
        },
        @{
            Source = "lib/src/wallet/models/wallet_info.dart"
            Target = "lib/features/wallet/data/models/wallet_info.dart"
            Note = "Wallet info model"
        },
        @{
            Source = "lib/src/wallet/models/coin_model.dart"
            Target = "lib/features/wallet/data/models/coin_model.dart"
            Note = "Coin model"
        }
    )
    
    # Chat Feature
    "chat" = @(
        @{
            Source = "lib/src/chat/provider/chat_message_provider.dart"
            Target = "lib/features/chat/presentation/providers/chat_message_provider.dart"
            Note = "Chat message provider"
        },
        @{
            Source = "lib/src/chat/pages/chat_index_page.dart"
            Target = "lib/features/chat/presentation/pages/chat_index_page.dart"
            Note = "Chat index page"
        },
        @{
            Source = "lib/src/chat/utils/websocket_util.dart"
            Target = "lib/features/chat/data/datasources/websocket_util.dart"
            Note = "WebSocket utility"
        }
    )
    
    # Mining Feature
    "mining" = @(
        @{
            Source = "lib/src/miningV2/provider/mining_v2_provider.dart"
            Target = "lib/features/mining/presentation/providers/mining_provider.dart"
            Note = "Mining provider"
        },
        @{
            Source = "lib/src/miningV2/pages/mining_today_v2.dart"
            Target = "lib/features/mining/presentation/pages/mining_today.dart"
            Note = "Mining today page"
        },
        @{
            Source = "lib/src/miningV2/api/mining_api.dart"
            Target = "lib/features/mining/data/api/mining_api.dart"
            Note = "Mining API"
        }
    )
    
    # Browser Feature
    "browser" = @(
        @{
            Source = "lib/src/browser/provider/browser_provider.dart"
            Target = "lib/features/browser/presentation/providers/browser_provider.dart"
            Note = "Browser provider"
        },
        @{
            Source = "lib/src/browser/pages/browser_page.dart"
            Target = "lib/features/browser/presentation/pages/browser_page.dart"
            Note = "Browser page"
        }
    )
    
    # Auth Feature
    "auth" = @(
        @{
            Source = "lib/src/login/pages/login_page.dart"
            Target = "lib/features/auth/presentation/pages/login_page.dart"
            Note = "Login page"
        },
        @{
            Source = "lib/src/login/api/login_api.dart"
            Target = "lib/features/auth/data/api/login_api.dart"
            Note = "Login API"
        }
    )
}

function Ensure-Directory {
    param([string]$Path)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would create directory: $dir" -ForegroundColor Gray
        } else {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "  Created directory: $dir" -ForegroundColor Green
        }
    }
}

function Migrate-File {
    param(
        [string]$Source,
        [string]$Target,
        [string]$Note
    )
    
    Write-Host "`nMigrating: $Note" -ForegroundColor White
    Write-Host "  From: $Source" -ForegroundColor Gray
    Write-Host "  To:   $Target" -ForegroundColor Gray
    
    if (-not (Test-Path $Source)) {
        Write-Host "  [SKIP] Source file does not exist" -ForegroundColor Yellow
        return
    }
    
    if (Test-Path $Target) {
        Write-Host "  [SKIP] Target file already exists" -ForegroundColor Yellow
        return
    }
    
    Ensure-Directory -Path $Target
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would copy file" -ForegroundColor Gray
    } else {
        Copy-Item -Path $Source -Destination $Target
        Write-Host "  [OK] File copied" -ForegroundColor Green
    }
}

# Execute migrations
if ($Feature -eq "all") {
    $featuresToMigrate = $migrations.Keys
} else {
    $featuresToMigrate = @($Feature)
}

foreach ($feat in $featuresToMigrate) {
    if ($migrations.ContainsKey($feat)) {
        Write-Host "`n=== Migrating $feat Feature ===" -ForegroundColor Cyan
        foreach ($migration in $migrations[$feat]) {
            Migrate-File -Source $migration.Source -Target $migration.Target -Note $migration.Note
        }
    } else {
        Write-Host "Unknown feature: $feat" -ForegroundColor Red
    }
}

Write-Host "`n=== Migration Complete ===" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "This was a dry run. No files were actually moved." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to perform actual migration." -ForegroundColor Yellow
}

