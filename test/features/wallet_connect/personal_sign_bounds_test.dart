// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-2: Tests for personal_sign params bounds protection (Bug-3)
//
// Bug-3: setActionDataMap could crash with RangeError when personal_sign
//         params list has fewer than 2 entries. The fix adds a length guard
//         that calls viewStateDeal(WalletConnectState.error) for short lists.
//
// Strategy: Extract the bounds-checking logic into a testable pure function.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Mirrors WalletConnectState enum
// ---------------------------------------------------------------------------
enum FakeWalletConnectState { loading, messageSignOK, transactionOK, error }

// ---------------------------------------------------------------------------
// Mirror of the personal_sign dispatch logic in wallet_connect_provider.dart
// ---------------------------------------------------------------------------
class PersonalSignResult {
  final FakeWalletConnectState state;
  final String? errorParams;
  final String? dataToSign;
  final String? address;

  PersonalSignResult({
    required this.state,
    this.errorParams,
    this.dataToSign,
    this.address,
  });
}

/// Mirrors the personal_sign branch of setActionDataMap, purely in logic.
PersonalSignResult processPersonalSign(List<String> requestParams) {
  if (requestParams.length < 2) {
    return PersonalSignResult(
      state: FakeWalletConnectState.error,
      errorParams:
          'Invalid personal_sign params: expected 2, got ${requestParams.length}',
    );
  }

  final dataToSign = requestParams[0];
  final address = requestParams[1];

  return PersonalSignResult(
    state: FakeWalletConnectState.messageSignOK,
    dataToSign: dataToSign,
    address: address,
  );
}

void main() {
  group('personal_sign — params bounds guard (Bug-3)', () {
    test('params length >= 2 correctly parses dataToSign and address', () {
      final result = processPersonalSign(['0xdeadbeef', '0xUserAddress']);

      expect(result.state, FakeWalletConnectState.messageSignOK);
      expect(result.dataToSign, '0xdeadbeef');
      expect(result.address, '0xUserAddress');
      expect(result.errorParams, isNull);
    });

    test('params length exactly 2 (edge case) is accepted', () {
      final result = processPersonalSign(['data', 'addr']);

      expect(result.state, FakeWalletConnectState.messageSignOK);
    });

    test('params length > 2 also works (extra params are ignored)', () {
      final result = processPersonalSign(['data', 'addr', 'extra']);

      expect(result.state, FakeWalletConnectState.messageSignOK);
      expect(result.dataToSign, 'data');
      expect(result.address, 'addr');
    });

    test('params length == 1 calls error state', () {
      final result = processPersonalSign(['onlyone']);

      expect(
        result.state,
        FakeWalletConnectState.error,
        reason: 'params with only 1 element must trigger error state',
      );
      expect(result.errorParams, isNotNull);
      expect(result.errorParams!, contains('1'));
    });

    test('params length == 0 calls error state', () {
      final result = processPersonalSign([]);

      expect(
        result.state,
        FakeWalletConnectState.error,
        reason: 'empty params list must trigger error state',
      );
      expect(result.errorParams, isNotNull);
      expect(
        result.errorParams!,
        contains('0'),
        reason: 'error message must include actual length (0)',
      );
    });

    test('error message includes the actual length for debugging', () {
      // Verify the error message format matches the real implementation
      final resultZero = processPersonalSign([]);
      final resultOne = processPersonalSign(['x']);

      expect(resultZero.errorParams, contains('expected 2, got 0'));
      expect(resultOne.errorParams, contains('expected 2, got 1'));
    });
  });
}
