# N42 Wallet Project Restructure Script
# PowerShell script for Windows
# 
# Copyright 2021-2026 N42 Inc.
# Author: Jiang Yiwei
#
# Usage: 
#   .\scripts\restructure.ps1
#   .\scripts\restructure.ps1 -DryRun

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

Write-Host "N42 Wallet Project Restructure Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Dry Run: $DryRun" -ForegroundColor Yellow
Write-Host ""

# Define directory structure
$directories = @(
    # Core layer
    "lib/core/config",
    "lib/core/app",
    "lib/core/error",
    "lib/core/network/interceptors",
    "lib/core/storage",
    "lib/core/platform",
    "lib/core/utils",
    "lib/core/di",
    "lib/core/router",
    "lib/core/security",
    "lib/core/monitoring",
    "lib/core/usecase",
    
    # Domain layer
    "lib/domain/entities",
    "lib/domain/repositories",
    "lib/domain/usecases/auth",
    "lib/domain/usecases/wallet",
    "lib/domain/usecases/chat",
    "lib/domain/usecases/mining",
    
    # Data layer
    "lib/data/datasources/remote",
    "lib/data/datasources/local",
    "lib/data/models",
    "lib/data/repositories",
    
    # Presentation layer
    "lib/presentation/providers/wallet",
    "lib/presentation/providers/chat",
    "lib/presentation/providers/mining",
    "lib/presentation/themes",
    "lib/presentation/widgets/common",
    "lib/presentation/widgets/dialog",
    
    # Features
    "lib/features/wallet/data/api",
    "lib/features/wallet/data/models",
    "lib/features/wallet/domain/entities",
    "lib/features/wallet/domain/usecases",
    "lib/features/wallet/presentation/pages",
    "lib/features/wallet/presentation/widgets",
    "lib/features/wallet/presentation/providers",
    "lib/features/wallet/utils",
    
    "lib/features/chat/data/api",
    "lib/features/chat/data/models",
    "lib/features/chat/domain/entities",
    "lib/features/chat/domain/usecases",
    "lib/features/chat/presentation/pages",
    "lib/features/chat/presentation/widgets",
    "lib/features/chat/presentation/providers",
    "lib/features/chat/utils",
    
    "lib/features/mining/data/api",
    "lib/features/mining/data/models",
    "lib/features/mining/domain/entities",
    "lib/features/mining/domain/usecases",
    "lib/features/mining/presentation/pages",
    "lib/features/mining/presentation/widgets",
    "lib/features/mining/presentation/providers",
    "lib/features/mining/utils",
    
    "lib/features/browser/data/api",
    "lib/features/browser/data/models",
    "lib/features/browser/presentation/pages",
    "lib/features/browser/presentation/widgets",
    "lib/features/browser/presentation/providers",
    
    "lib/features/auth/data/api",
    "lib/features/auth/data/models",
    "lib/features/auth/presentation/pages",
    "lib/features/auth/presentation/widgets",
    
    "lib/features/home/presentation/pages",
    "lib/features/home/presentation/widgets",
    
    "lib/features/notification/presentation/pages",
    
    "lib/features/wallet_connect/data/api",
    "lib/features/wallet_connect/data/models",
    "lib/features/wallet_connect/presentation/pages",
    "lib/features/wallet_connect/presentation/widgets",
    "lib/features/wallet_connect/presentation/providers",
    
    # Proto (elevated)
    "lib/proto"
)

# Create directories
Write-Host "Creating directory structure..." -ForegroundColor Green
foreach ($dir in $directories) {
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Write-Host "  [DIR] $dir" -ForegroundColor Gray
}

# File move mappings (source -> destination)
$fileMoves = @{
    # Core layer
    "lib/app_config.dart" = "lib/core/config/app_config_legacy.dart"
    "lib/application.dart" = "lib/core/app/app_globals.dart"
    "lib/src/https/base_http.dart" = "lib/core/network/base_http.dart"
    "lib/src/https/base_api.dart" = "lib/core/network/base_api.dart"
    "lib/src/https/request_url.dart" = "lib/core/network/request_url.dart"
    "lib/src/https/ipfs_api.dart" = "lib/core/network/ipfs_api.dart"
    "lib/src/https/my_http_overrides.dart" = "lib/core/network/http_overrides.dart"
    "lib/src/utils/sp_util.dart" = "lib/core/storage/sp_util.dart"
    "lib/src/sqlite/app_database.dart" = "lib/core/storage/app_database.dart"
    "lib/src/utils/event_bus.dart" = "lib/core/utils/event_bus.dart"
    "lib/src/utils/toast_utils.dart" = "lib/core/utils/toast_utils.dart"
    "lib/src/utils/regular.dart" = "lib/core/utils/regular.dart"
    "lib/src/utils/data_utils.dart" = "lib/core/utils/data_utils.dart"
    "lib/src/utils/base64_utils.dart" = "lib/core/utils/base64_utils.dart"
    "lib/src/utils/md5_util.dart" = "lib/core/utils/md5_util.dart"
    "lib/src/utils/device_info_util.dart" = "lib/core/platform/device_info_util.dart"
    "lib/src/utils/notfication_utils.dart" = "lib/core/platform/notification_utils.dart"
    "lib/src/utils/app_push_utils.dart" = "lib/core/platform/app_push_utils.dart"
    
    # Presentation layer
    "lib/src/state/public_provider.dart" = "lib/presentation/providers/public_provider.dart"
    "lib/src/utils/theme_adapter.dart" = "lib/presentation/themes/theme_adapter.dart"
    
    # Shared models
    "lib/src/models/user_info.dart" = "lib/data/models/user_info.dart"
    "lib/src/models/message_model.dart" = "lib/data/models/message_model.dart"
    
    # Component enums
    "lib/src/component/enums/load.dart" = "lib/core/utils/load_state.dart"
    "lib/src/component/enums/coin_type.dart" = "lib/core/utils/coin_type.dart"
}

Write-Host ""
Write-Host "Moving core files..." -ForegroundColor Green

foreach ($source in $fileMoves.Keys) {
    $dest = $fileMoves[$source]
    if (Test-Path $source) {
        if (-not $DryRun) {
            Copy-Item -Path $source -Destination $dest -Force
        }
        Write-Host "  [COPY] $source -> $dest" -ForegroundColor Gray
    } else {
        Write-Host "  [SKIP] $source (not found)" -ForegroundColor Yellow
    }
}

# Directory copies for features
$dirCopies = @{
    # Wallet feature
    "lib/src/wallet/api" = "lib/features/wallet/data/api"
    "lib/src/wallet/models" = "lib/features/wallet/data/models"
    "lib/src/wallet/pages" = "lib/features/wallet/presentation/pages"
    "lib/src/wallet/widgets" = "lib/features/wallet/presentation/widgets"
    "lib/src/wallet/provider" = "lib/features/wallet/presentation/providers"
    "lib/src/wallet/utils" = "lib/features/wallet/utils"
    
    # Chat feature
    "lib/src/chat/api" = "lib/features/chat/data/api"
    "lib/src/chat/models" = "lib/features/chat/data/models"
    "lib/src/chat/pages" = "lib/features/chat/presentation/pages"
    "lib/src/chat/widgets" = "lib/features/chat/presentation/widgets"
    "lib/src/chat/provider" = "lib/features/chat/presentation/providers"
    "lib/src/chat/utils" = "lib/features/chat/utils"
    
    # Mining feature
    "lib/src/miningV2/api" = "lib/features/mining/data/api"
    "lib/src/miningV2/models" = "lib/features/mining/data/models"
    "lib/src/miningV2/pages" = "lib/features/mining/presentation/pages"
    "lib/src/miningV2/widgets" = "lib/features/mining/presentation/widgets"
    "lib/src/miningV2/provider" = "lib/features/mining/presentation/providers"
    "lib/src/miningV2/utils" = "lib/features/mining/utils"
    
    # Browser feature
    "lib/src/browser/api" = "lib/features/browser/data/api"
    "lib/src/browser/models" = "lib/features/browser/data/models"
    "lib/src/browser/pages" = "lib/features/browser/presentation/pages"
    "lib/src/browser/provider" = "lib/features/browser/presentation/providers"
    
    # Auth feature
    "lib/src/login/api" = "lib/features/auth/data/api"
    "lib/src/login/pages" = "lib/features/auth/presentation/pages"
    "lib/src/login/widgets" = "lib/features/auth/presentation/widgets"
    
    # Home feature
    "lib/src/home" = "lib/features/home/presentation"
    
    # Notification feature
    "lib/src/notification/pages" = "lib/features/notification/presentation/pages"
    
    # WalletConnect feature
    "lib/src/wallet_connect/models" = "lib/features/wallet_connect/data/models"
    "lib/src/wallet_connect/pages" = "lib/features/wallet_connect/presentation/pages"
    "lib/src/wallet_connect/widgets" = "lib/features/wallet_connect/presentation/widgets"
    "lib/src/wallet_connect/provider" = "lib/features/wallet_connect/presentation/providers"
    
    # Widgets
    "lib/src/widgets" = "lib/presentation/widgets/common"
    "lib/src/widgets/dialog_widget" = "lib/presentation/widgets/dialog"
    
    # Proto
    "lib/src/proto" = "lib/proto"
}

Write-Host ""
Write-Host "Copying feature directories..." -ForegroundColor Green

foreach ($source in $dirCopies.Keys) {
    $dest = $dirCopies[$source]
    if (Test-Path $source) {
        if (-not $DryRun) {
            Copy-Item -Path $source -Destination $dest -Recurse -Force
        }
        Write-Host "  [COPY] $source -> $dest" -ForegroundColor Gray
    } else {
        Write-Host "  [SKIP] $source (not found)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Restructure complete!" -ForegroundColor Green

if ($DryRun) {
    Write-Host ""
    Write-Host "This was a dry run. No files were modified." -ForegroundColor Yellow
    Write-Host "Remove -DryRun to apply changes." -ForegroundColor Yellow
}

