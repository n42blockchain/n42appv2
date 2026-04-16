// Tests for CleanupResult — the pure-Dart data class in media_lifecycle_service.dart.
// CleanupResult has no platform dependencies; only the + operator and constructor
// are covered here.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/media_lifecycle_service.dart';

void main() {
  // ─────────────────────────────────────────────────
  // CleanupResult — constructor
  // ─────────────────────────────────────────────────

  group('CleanupResult constructor', () {
    test('all fields default to 0', () {
      const result = CleanupResult();
      expect(result.filesDeleted, 0);
      expect(result.bytesFreed, 0);
      expect(result.errors, 0);
    });

    test('named fields can be set', () {
      const result = CleanupResult(
        filesDeleted: 3,
        bytesFreed: 1024 * 512,
        errors: 1,
      );
      expect(result.filesDeleted, 3);
      expect(result.bytesFreed, 1024 * 512);
      expect(result.errors, 1);
    });
  });

  // ─────────────────────────────────────────────────
  // CleanupResult.operator+
  // ─────────────────────────────────────────────────

  group('CleanupResult.operator+', () {
    test('two zero results produce zero result', () {
      const a = CleanupResult();
      const b = CleanupResult();
      final sum = a + b;
      expect(sum.filesDeleted, 0);
      expect(sum.bytesFreed, 0);
      expect(sum.errors, 0);
    });

    test('adds filesDeleted from both results', () {
      const a = CleanupResult(filesDeleted: 5);
      const b = CleanupResult(filesDeleted: 3);
      expect((a + b).filesDeleted, 8);
    });

    test('adds bytesFreed from both results', () {
      const a = CleanupResult(bytesFreed: 1024);
      const b = CleanupResult(bytesFreed: 2048);
      expect((a + b).bytesFreed, 3072);
    });

    test('adds errors from both results', () {
      const a = CleanupResult(errors: 2);
      const b = CleanupResult(errors: 1);
      expect((a + b).errors, 3);
    });

    test('full aggregation across all fields', () {
      const a = CleanupResult(filesDeleted: 10, bytesFreed: 5000, errors: 1);
      const b = CleanupResult(filesDeleted: 4, bytesFreed: 3000, errors: 2);
      final sum = a + b;
      expect(sum.filesDeleted, 14);
      expect(sum.bytesFreed, 8000);
      expect(sum.errors, 3);
    });

    test('chaining + is commutative for field sums', () {
      const a = CleanupResult(filesDeleted: 7, bytesFreed: 100);
      const b = CleanupResult(filesDeleted: 3, bytesFreed: 200);
      final ab = a + b;
      final ba = b + a;
      expect(ab.filesDeleted, ba.filesDeleted);
      expect(ab.bytesFreed, ba.bytesFreed);
    });

    test('chaining multiple + calls accumulates correctly', () {
      const a = CleanupResult(filesDeleted: 1);
      const b = CleanupResult(filesDeleted: 2);
      const c = CleanupResult(filesDeleted: 3);
      final total = a + b + c;
      expect(total.filesDeleted, 6);
    });
  });
}
