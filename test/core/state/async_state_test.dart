// Tests for async_state.dart extensions on AsyncValue<T>.
// Covers: LoadState enum, AsyncStateX (isRefreshing, dataOr, mapData,
// whenHasData) and AsyncValueToLoadState.loadState.
// No platform dependencies — uses flutter_riverpod (pure Dart).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/core/state/async_state.dart';

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
  // AsyncStateX — isRefreshing
  // ─────────────────────────────────────────────────

  group('AsyncStateX.isRefreshing', () {
    // Use explicit extension invocation to disambiguate from riverpod's own
    // isRefreshing (added in riverpod 3.x).

    test('false for data state', () {
      const state = AsyncValue.data(42);
      expect(AsyncStateX(state).isRefreshing, isFalse);
    });

    test('false for loading without previous value', () {
      const state = AsyncValue<int>.loading();
      expect(AsyncStateX(state).isRefreshing, isFalse);
    });

    test('true for loading with previous value (refreshing)', () {
      const previous = AsyncValue.data(99);
      final refreshing = const AsyncValue<int>.loading().copyWithPrevious(previous);
      expect(refreshing.isLoading, isTrue);
      expect(refreshing.hasValue, isTrue);
      expect(AsyncStateX(refreshing).isRefreshing, isTrue);
    });

    test('false for error state', () {
      final state = AsyncValue<int>.error(Exception('oops'), StackTrace.empty);
      expect(AsyncStateX(state).isRefreshing, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // AsyncStateX — dataOr
  // ─────────────────────────────────────────────────

  group('AsyncStateX.dataOr', () {
    test('returns data value when available', () {
      const state = AsyncValue.data(42);
      expect(state.dataOr(0), 42);
    });

    test('returns default when loading (no value)', () {
      const state = AsyncValue<int>.loading();
      expect(state.dataOr(-1), -1);
    });

    test('returns default when error', () {
      final state = AsyncValue<int>.error(Exception(), StackTrace.empty);
      expect(state.dataOr(99), 99);
    });

    test('works for String type', () {
      const state = AsyncValue.data('hello');
      expect(state.dataOr('world'), 'hello');
    });

    test('returns default string when loading', () {
      const state = AsyncValue<String>.loading();
      expect(state.dataOr('default'), 'default');
    });
  });

  // ─────────────────────────────────────────────────
  // AsyncStateX — mapData
  // ─────────────────────────────────────────────────

  group('AsyncStateX.mapData', () {
    test('maps data value', () {
      const state = AsyncValue.data(10);
      final mapped = state.mapData((v) => v * 2);
      expect(mapped, isA<AsyncValue<int>>());
      expect(mapped.value, 20);
    });

    test('maps data to different type', () {
      const state = AsyncValue.data(42);
      final mapped = state.mapData((v) => 'value is $v');
      expect(mapped.value, 'value is 42');
    });

    test('preserves loading state', () {
      const state = AsyncValue<int>.loading();
      final mapped = state.mapData((v) => v * 2);
      expect(mapped.isLoading, isTrue);
      expect(mapped.hasValue, isFalse);
    });

    test('preserves error state with same error object', () {
      final err = Exception('fail');
      final state = AsyncValue<int>.error(err, StackTrace.empty);
      final mapped = state.mapData((v) => v * 2);
      expect(mapped.hasError, isTrue);
      // Verify the exact same error instance is preserved, not a wrapper.
      expect(mapped.error, same(err));
    });
  });

  // ─────────────────────────────────────────────────
  // AsyncStateX — whenHasData
  // ─────────────────────────────────────────────────

  group('AsyncStateX.whenHasData', () {
    test('calls action when has data', () {
      const state = AsyncValue.data(7);
      int? captured;
      state.whenHasData((v) => captured = v);
      expect(captured, 7);
    });

    test('does NOT call action when loading', () {
      const state = AsyncValue<int>.loading();
      bool called = false;
      state.whenHasData((_) => called = true);
      expect(called, isFalse);
    });

    test('does NOT call action when error', () {
      final state = AsyncValue<int>.error(Exception(), StackTrace.empty);
      bool called = false;
      state.whenHasData((_) => called = true);
      expect(called, isFalse);
    });

    test('passes correct data value to action', () {
      const state = AsyncValue.data('test string');
      String? result;
      state.whenHasData((v) => result = v.toUpperCase());
      expect(result, 'TEST STRING');
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
