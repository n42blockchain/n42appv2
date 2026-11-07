#!/usr/bin/env bash
# Sourced by disposable CI runners. Keep targets and defines allowlisted.
case "${N42_NATIVE_SUITE:-all}" in
  all) native_test_args=(integration_test/) ;;
  mlkit) native_test_args=(integration_test/mlkit_native_smoke_test.dart
    --dart-define=N42_MLKIT_DOWNLOAD_MODEL=true) ;;
  *) echo 'Unknown native CI suite.' >&2; exit 64 ;;
esac
