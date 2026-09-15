#!/usr/bin/env bash
# Release preparation delegates to the canonical version-preserving builder.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "$PROJECT_ROOT/build_release.sh" ipa "$@"
