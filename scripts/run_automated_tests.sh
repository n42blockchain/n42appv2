#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# A serial Flutter coverage run opens one descriptor per accumulated trace on
# macOS and can otherwise hit the default soft limit of 256 near suite end.
ulimit -n 10240 2>/dev/null || ulimit -n 4096 2>/dev/null || true
MODE="${1:-quick}"

log() {
  printf '\n==> %s\n' "$1"
}

run_format() {
  cd "$ROOT"

  log "Auditing Dart formatting"
  dart format \
    --output=none \
    --set-exit-if-changed \
    lib test integration_test
}

run_quick() {
  cd "$ROOT"

  log "Running Flutter analyzer"
  flutter analyze --no-fatal-infos --no-pub

  log "Running automation quality gates"
  flutter test \
    --no-pub \
    test/quality/integration_test_quality_test.dart
}

report_coverage() {
  local coverage_file="$ROOT/coverage/lcov.info"
  if [[ ! -f "$coverage_file" ]]; then
    printf 'Coverage file not found: %s\n' "$coverage_file" >&2
    return 1
  fi

  awk -F: '
    /^LF:/ { total += $2 }
    /^LH:/ { hit += $2 }
    END {
      if (total == 0) {
        print "Coverage data contains no lines" > "/dev/stderr"
        exit 1
      }
      printf "Raw line coverage: %d/%d = %.2f%%\n", hit, total, 100 * hit / total
    }
  ' "$coverage_file"
}

run_full() {
  run_quick

  cd "$ROOT"
  log "Running root Flutter suite with coverage"
  flutter test --no-pub --coverage --concurrency=1
  report_coverage

  log "Running Chat package suite"
  (
    cd "$ROOT/packages/n42_chat"
    flutter test --no-pub
  )

  log "Running JMT verification package suite"
  (
    cd "$ROOT/packages/n42_jmt_verify"
    dart test
  )

  log "Running mining plugin Dart suite"
  (
    cd "$ROOT/plugins/flutter_mining"
    flutter test --no-pub
  )

  for module in livekit-jwt social-auth swap loyalty; do
    log "Running Go tests: backend/$module"
    (
      cd "$ROOT/backend/$module"
      go test -count=1 ./...
    )
  done

  log "Running Loyalty contract tests"
  (
    cd "$ROOT/contracts/loyalty"
    forge test
  )
}

run_device() {
  if [[ -z "${DEVICE_ID:-}" ]]; then
    printf 'DEVICE_ID is required for device mode. Run `flutter devices`.\n' >&2
    return 2
  fi

  local flutter_args=(
    test
    --no-pub
    integration_test/device_full_flow_test.dart
    -d
    "$DEVICE_ID"
  )
  local define_args=()

  if [[ -z "${N42_E2E_CHAT_USERNAME:-}" || -z "${N42_E2E_CHAT_PASSWORD:-}" ]]; then
    printf 'N42_E2E_CHAT_USERNAME and N42_E2E_CHAT_PASSWORD are required for device mode.\n' >&2
    return 2
  fi

  define_args+=(
    "--dart-define=N42_E2E_CHAT_USERNAME=$N42_E2E_CHAT_USERNAME"
    "--dart-define=N42_E2E_CHAT_PASSWORD=$N42_E2E_CHAT_PASSWORD"
  )

  if [[ -n "${DART_DEFINE_FILE:-}" ]]; then
    if [[ ! -r "$DART_DEFINE_FILE" ]]; then
      printf 'DART_DEFINE_FILE is not readable: %s\n' "$DART_DEFINE_FILE" >&2
      return 2
    fi
    define_args+=("--dart-define-from-file=$DART_DEFINE_FILE")
  fi
  flutter_args+=("${define_args[@]}")

  cd "$ROOT"
  log "Running safe Wallet and Chat click flows on device $DEVICE_ID"
  if [[ "${PUBLISH_PORT:-0}" == "1" ]]; then
    flutter drive \
      --no-pub \
      --driver=test_driver/integration_test.dart \
      --target=integration_test/device_full_flow_test.dart \
      -d "$DEVICE_ID" \
      --publish-port \
      "${define_args[@]}"
  else
    flutter "${flutter_args[@]}"
  fi
}

run_device_smoke() {
  if [[ -z "${DEVICE_ID:-}" ]]; then
    printf 'DEVICE_ID is required for device-smoke mode. Run `flutter devices`.\n' >&2
    return 2
  fi

  cd "$ROOT"
  log "Running app smoke on device $DEVICE_ID"
  flutter test --no-pub integration_test/app_test.dart -d "$DEVICE_ID"
}

case "$MODE" in
  quick)
    run_quick
    ;;
  full)
    run_full
    ;;
  device)
    run_device
    ;;
  device-smoke)
    run_device_smoke
    ;;
  format)
    run_format
    ;;
  *)
    printf 'Usage: %s {quick|full|device|device-smoke|format}\n' "$0" >&2
    exit 2
    ;;
esac
