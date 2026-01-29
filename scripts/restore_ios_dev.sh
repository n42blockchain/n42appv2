#!/bin/bash
# Restore iOS Development Settings
# Run this after release to restore development configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IOS_DIR="$PROJECT_ROOT/ios"

echo "=== Restoring iOS Development Settings ==="

ENTITLEMENTS_FILE="$IOS_DIR/Runner/Runner.entitlements"
BACKUP_FILE="$ENTITLEMENTS_FILE.backup"

if [ -f "$BACKUP_FILE" ]; then
    echo "Restoring entitlements from backup..."
    mv "$BACKUP_FILE" "$ENTITLEMENTS_FILE"
    echo "Done! Development settings restored."
else
    echo "No backup found. Manually updating entitlements..."
    sed -i '' 's/<string>production<\/string>/<string>development<\/string>/g' "$ENTITLEMENTS_FILE"
    echo "Done! aps-environment set to 'development'"
fi
