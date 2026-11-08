#!/usr/bin/env bash
# Sourced by disposable CI runners. Keep targets and defines allowlisted.
case "${N42_NATIVE_SUITE:-all}" in
  all) native_test_args=(integration_test/ --dart-define=N42_DISPOSABLE_WALLET_QA=true) ;;
  browser) native_test_args=(integration_test/browser_provider_native_test.dart) ;;
  mlkit) native_test_args=(integration_test/mlkit_native_smoke_test.dart
    --dart-define=N42_MLKIT_DOWNLOAD_MODEL=true) ;;
  wallet_forms) native_test_args=(integration_test/flows/wallet_flow_test.dart
    --dart-define=N42_DISPOSABLE_WALLET_QA=true) ;;
  *) echo 'Unknown native CI suite.' >&2; exit 64 ;;
esac
