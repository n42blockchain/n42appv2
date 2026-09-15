// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/result.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Constructors
  // ---------------------------------------------------------------------------

  group('Result constructors', () {
    test('Result.success holds value', () {
      const r = Result<int, String>.success(42);
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
      expect(r.valueOrNull, 42);
      expect(r.errorOrNull, isNull);
    });

    test('Result.failure holds error', () {
      const r = Result<int, String>.failure('oops');
      expect(r.isSuccess, isFalse);
      expect(r.isFailure, isTrue);
      expect(r.valueOrNull, isNull);
      expect(r.errorOrNull, 'oops');
    });

    test('Result.success accepts null value type', () {
      const r = Result<String?, String>.success(null);
      expect(r.isSuccess, isTrue);
      expect(r.valueOrNull, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // getOrElse / getOrThrow
  // ---------------------------------------------------------------------------

  group('getOrElse', () {
    test('returns value on success', () {
      const r = Result<int, String>.success(7);
      expect(r.getOrElse((_) => -1), 7);
    });

    test('returns fallback on failure', () {
      const r = Result<int, String>.failure('err');
      expect(r.getOrElse((e) => e.length), 3); // 'err'.length == 3
    });
  });

  group('getOrThrow', () {
    test('returns value on success', () {
      const r = Result<int, String>.success(99);
      expect(r.getOrThrow(), 99);
    });

    test('throws error object on failure', () {
      const r = Result<int, AppError>.failure(
        NetworkError('timeout', code: 'NET_TIMEOUT'),
      );
      expect(() => r.getOrThrow(), throwsA(isA<NetworkError>()));
    });
  });

  // ---------------------------------------------------------------------------
  // when
  // ---------------------------------------------------------------------------

  group('when', () {
    test('calls success branch for Success', () {
      const r = Result<String, int>.success('hello');
      final result = r.when(success: (v) => 'ok:$v', failure: (e) => 'fail:$e');
      expect(result, 'ok:hello');
    });

    test('calls failure branch for Failure', () {
      const r = Result<String, int>.failure(404);
      final result = r.when(success: (v) => 'ok:$v', failure: (e) => 'fail:$e');
      expect(result, 'fail:404');
    });
  });

  // ---------------------------------------------------------------------------
  // map
  // ---------------------------------------------------------------------------

  group('map', () {
    test('transforms success value', () {
      const r = Result<int, String>.success(5);
      final mapped = r.map((v) => v * 2);
      expect(mapped.valueOrNull, 10);
    });

    test('preserves failure unchanged', () {
      const r = Result<int, String>.failure('err');
      final mapped = r.map((v) => v * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.errorOrNull, 'err');
    });
  });

  // ---------------------------------------------------------------------------
  // mapError
  // ---------------------------------------------------------------------------

  group('mapError', () {
    test('transforms failure error', () {
      const r = Result<int, String>.failure('short');
      final mapped = r.mapError((e) => e.length);
      expect(mapped.errorOrNull, 5);
    });

    test('preserves success unchanged', () {
      const r = Result<int, String>.success(3);
      final mapped = r.mapError((e) => e.length);
      expect(mapped.isSuccess, isTrue);
      expect(mapped.valueOrNull, 3);
    });
  });

  // ---------------------------------------------------------------------------
  // flatMap
  // ---------------------------------------------------------------------------

  group('flatMap', () {
    test('chains success through transformation', () {
      const r = Result<int, String>.success(4);
      final chained = r.flatMap((v) => Result.success(v + 1));
      expect(chained.valueOrNull, 5);
    });

    test('chains success to failure', () {
      const r = Result<int, String>.success(4);
      final chained = r.flatMap<int>((v) => const Result.failure('abort'));
      expect(chained.isFailure, isTrue);
    });

    test('skips transformation on failure', () {
      const r = Result<int, String>.failure('err');
      var called = false;
      r.flatMap((v) {
        called = true;
        return Result.success(v + 1);
      });
      expect(called, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // onSuccess / onFailure extensions
  // ---------------------------------------------------------------------------

  group('side-effect extensions', () {
    test('onSuccess runs action for Success', () {
      var captured = 0;
      const Result<int, String>.success(42).onSuccess((v) => captured = v);
      expect(captured, 42);
    });

    test('onSuccess is skipped for Failure', () {
      var called = false;
      const Result<int, String>.failure('e').onSuccess((_) => called = true);
      expect(called, isFalse);
    });

    test('onFailure runs action for Failure', () {
      String? captured;
      const Result<int, String>.failure('boom').onFailure((e) => captured = e);
      expect(captured, 'boom');
    });

    test('onFailure is skipped for Success', () {
      var called = false;
      const Result<int, String>.success(1).onFailure((_) => called = true);
      expect(called, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // FutureResultExtension.toResult
  // ---------------------------------------------------------------------------

  group('toResult()', () {
    test('wraps resolved future as Success', () async {
      final result = await Future.value(42).toResult();
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 42);
    });

    test('wraps rejected future as Failure', () async {
      final result = await Future<int>.error('boom').toResult();
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnknownError>());
    });
  });

  // ---------------------------------------------------------------------------
  // AppError hierarchy
  // ---------------------------------------------------------------------------

  group('AppError factories', () {
    test('AppError.network creates NetworkError', () {
      final e = AppError.network('timeout', code: 'NET_TIMEOUT');
      expect(e, isA<NetworkError>());
      expect(e.message, 'timeout');
      expect(e.code, 'NET_TIMEOUT');
    });

    test('AppError.blockchain creates BlockchainError', () {
      final e = AppError.blockchain('rpc error', code: 'ETH_RPC');
      expect(e, isA<BlockchainError>());
      expect(e.message, 'rpc error');
    });

    test('AppError.unknown creates UnknownError', () {
      final e = AppError.unknown('???');
      expect(e, isA<UnknownError>());
    });

    test('AppError.fromException wraps non-AppError', () {
      final e = AppError.fromException(Exception('raw'));
      expect(e, isA<UnknownError>());
      expect(e.message, contains('raw'));
    });

    test('AppError.fromException passes AppError through unchanged', () {
      final original = AppError.network('original');
      final wrapped = AppError.fromException(original);
      expect(identical(original, wrapped), isTrue);
    });

    test('toString includes type and code', () {
      final e = AppError.network('msg', code: 'X1');
      expect(e.toString(), contains('NetworkError'));
      expect(e.toString(), contains('msg'));
      expect(e.toString(), contains('X1'));
    });
  });

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  group('equality', () {
    test('two Success with same value are equal', () {
      const a = Result<int, String>.success(1);
      const b = Result<int, String>.success(1);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('two Failure with same error are equal', () {
      const a = Result<int, String>.failure('err');
      const b = Result<int, String>.failure('err');
      expect(a, equals(b));
    });

    test('Success and Failure with same payload are not equal', () {
      const a = Result<int, int>.success(1);
      const b = Result<int, int>.failure(1);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // toString
  // ---------------------------------------------------------------------------

  group('toString', () {
    test('Success prints value', () {
      const r = Result<int, String>.success(7);
      expect(r.toString(), 'Success(7)');
    });

    test('Failure prints error', () {
      const r = Result<int, String>.failure('oops');
      expect(r.toString(), 'Failure(oops)');
    });
  });
}
