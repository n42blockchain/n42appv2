// ignore_for_file: invalid_use_of_internal_member
// Tests for async_state.dart extensions on AsyncValue<T>.
// Covers: LoadState enum and AsyncValueToLoadState.loadState.
// No platform dependencies — uses flutter_riverpod (pure Dart).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/state/async_state.dart';

void main() {
  // ─────────────────────────────────────────────────
  // LoadState enum
  // ─────────────────────────────────────────────────

  group('LoadState enum', () {
    test('contains all four expected values', () {
      expect(LoadState.values, containsAll([
        LoadState.initial,
        LoadState.loading,
        LoadState.success,
        LoadState.error,
      ]));
    });

    test('four values total', () {
      expect(LoadState.values.length, 4);
    });
  });

  // ─────────────────────────────────────────────────
  // AsyncValueToLoadState — loadState
  // ─────────────────────────────────────────────────

  group('AsyncValueToLoadState.loadState', () {
    test('loading → LoadState.loading', () {
      const state = AsyncValue<int>.loading();
      expect(state.loadState, LoadState.loading);
    });

    test('error → LoadState.error', () {
      final state = AsyncValue<int>.error(Exception(), StackTrace.empty);
      expect(state.loadState, LoadState.error);
    });

    test('data → LoadState.success', () {
      const state = AsyncValue.data(42);
      expect(state.loadState, LoadState.success);
    });

    test('refreshing (loading with value) → LoadState.loading', () {
      const prev = AsyncValue.data(10);
      final refreshing = const AsyncValue<int>.loading().copyWithPrevious(prev);
      expect(refreshing.loadState, LoadState.loading);
    });
  });
}
