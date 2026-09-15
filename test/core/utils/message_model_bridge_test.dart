// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/utils/message_model_bridge.dart';
import 'package:n42_wallet/core/utils/result.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Success path
  // ---------------------------------------------------------------------------

  group('resultToMessageModel — Success', () {
    test('error flag is false on Success', () {
      final result = Result<String, AppError>.success('hello');
      final mm = resultToMessageModel(result);
      expect(mm.error, isFalse);
    });

    test('data field holds the success value', () {
      final result = Result<int, AppError>.success(42);
      final mm = resultToMessageModel(result);
      expect(mm.data, 42);
    });

    test('data field holds null when value is null', () {
      final result = Result<String?, AppError>.success(null);
      final mm = resultToMessageModel(result);
      expect(mm.error, isFalse);
      expect(mm.data, isNull);
    });

    test('data field holds Map value', () {
      final map = {'key': 'value', 'count': 1};
      final result = Result<Map, AppError>.success(map);
      final mm = resultToMessageModel(result);
      expect(mm.error, isFalse);
      expect(mm.data, map);
    });

    test('data field holds List value', () {
      final list = [1, 2, 3];
      final result = Result<List, AppError>.success(list);
      final mm = resultToMessageModel(result);
      expect(mm.error, isFalse);
      expect(mm.data, list);
    });
  });

  // ---------------------------------------------------------------------------
  // Failure path — each AppError subtype
  // ---------------------------------------------------------------------------

  group('resultToMessageModel — Failure', () {
    test('error flag is true on Failure', () {
      final result = Result<dynamic, AppError>.failure(
        AppError.network('timeout'),
      );
      final mm = resultToMessageModel(result);
      expect(mm.error, isTrue);
    });

    test('data field holds the error message string', () {
      final result = Result<dynamic, AppError>.failure(
        AppError.network('request timed out', code: 'NET_TIMEOUT'),
      );
      final mm = resultToMessageModel(result);
      expect(mm.data, 'request timed out');
    });

    test('NetworkError message is propagated', () {
      final result = Result<dynamic, AppError>.failure(
        AppError.network('connection refused'),
      );
      expect(resultToMessageModel(result).data, 'connection refused');
    });

    test('BlockchainError message is propagated', () {
      final result = Result<dynamic, AppError>.failure(
        AppError.blockchain('gas required exceeds allowance'),
      );
      expect(
        resultToMessageModel(result).data,
        'gas required exceeds allowance',
      );
    });

    test('AuthError message is propagated', () {
      final result = Result<dynamic, AppError>.failure(
        AppError.auth('unauthorized'),
      );
      expect(resultToMessageModel(result).data, 'unauthorized');
    });

    test('ValidationError message is propagated', () {
      final result = Result<dynamic, AppError>.failure(
        AppError.validation('invalid address'),
      );
      expect(resultToMessageModel(result).data, 'invalid address');
    });

    test('UnknownError message is propagated', () {
      final result = Result<dynamic, AppError>.failure(
        AppError.unknown('something went wrong'),
      );
      expect(resultToMessageModel(result).data, 'something went wrong');
    });
  });

  // ---------------------------------------------------------------------------
  // Round-trip: result → MessageModel immutability check
  // ---------------------------------------------------------------------------

  group('resultToMessageModel — each call returns a new MessageModel', () {
    test('two calls on same result return independent instances', () {
      final result = Result<int, AppError>.success(1);
      final mm1 = resultToMessageModel(result);
      final mm2 = resultToMessageModel(result);
      mm1.data = 99;
      expect(mm2.data, 1); // mm2 is independent
    });
  });
}
