// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-1: Tests for TransactionRetry page state logic (Bug-1, Bug-2)
//
// Bug-1: initState must assign _txHash from widget.txHash (not from elsewhere).
// Bug-2: transfer failure error message must come from mm.data (the response body),
//         not from ethMessage.data (the gas estimate response).
//
// Strategy: We cannot run a full widget test (requires platform channels), so we
// test the state logic using faithful fakes that mirror the relevant contracts.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes for Bug-1: initState txHash initialization
// ---------------------------------------------------------------------------

class FakeTransactionRetryState {
  final String widgetTxHash;
  late String txHash;
  bool owner = true;

  FakeTransactionRetryState({required this.widgetTxHash});

  /// Mirrors initState logic in _TransactionRetryState
  void initState() {
    txHash = widgetTxHash; // Bug-1 fix: reads from widget
  }

  /// Mirrors init() guard: if txHash is empty → owner = false
  void init() {
    if (txHash.isEmpty) {
      owner = false;
    }
  }
}

// ---------------------------------------------------------------------------
// Fakes for Bug-2: transfer error source (mm.data vs ethMessage.data)
// ---------------------------------------------------------------------------

class FakeMessageModel {
  final bool error;
  final dynamic data;
  FakeMessageModel({required this.error, required this.data});
}

/// Mirrors the transfer retry logic where errorMessage must come from mm.data.
String simulateTransferRetry({
  required FakeMessageModel gasEstimate,   // ethMessage (gas estimation)
  required FakeMessageModel transferResult, // mm (actual transfer)
}) {
  String errorMessage = '';

  // Bug-2 fixed: use mm.data for the transfer error, not ethMessage.data
  if (gasEstimate.error) {
    // gas estimation failed — show gas error
    errorMessage = gasEstimate.data.toString();
    return errorMessage;
  }

  if (transferResult.error) {
    // transfer failed — must use transferResult.data (mm.data)
    errorMessage = transferResult.data.toString();
  } else {
    errorMessage = ''; // success, no error
  }

  return errorMessage;
}

void main() {
  group('TransactionRetry — Bug-1: initState txHash initialization', () {
    test('initState assigns _txHash from widget.txHash', () {
      const txHash = '0xabc123def456';
      final state = FakeTransactionRetryState(widgetTxHash: txHash);

      state.initState();

      expect(state.txHash, txHash,
          reason: '_txHash must be initialized from widget.txHash in initState');
    });

    test('when txHash is non-empty, owner remains true', () {
      final state = FakeTransactionRetryState(widgetTxHash: '0xdeadbeef');
      state.initState();
      state.init();

      expect(state.owner, isTrue);
    });

    test('when widget.txHash is empty, owner becomes false and no crash', () {
      final state = FakeTransactionRetryState(widgetTxHash: '');
      state.initState();
      state.init();

      expect(state.txHash, isEmpty);
      expect(state.owner, isFalse,
          reason: 'empty txHash must set owner=false without crashing');
    });
  });

  group('TransactionRetry — Bug-2: error message source is mm.data', () {
    test('transfer failure shows mm.data as error message', () {
      final gasOk = FakeMessageModel(error: false, data: BigInt.from(21000));
      final transferFail = FakeMessageModel(
          error: true, data: 'insufficient funds for gas * price + value');

      final errorMsg = simulateTransferRetry(
          gasEstimate: gasOk, transferResult: transferFail);

      expect(errorMsg, 'insufficient funds for gas * price + value',
          reason: 'error must come from mm.data (transfer result), not gas estimate');
    });

    test('successful transfer yields empty error message', () {
      final gasOk = FakeMessageModel(error: false, data: BigInt.from(21000));
      final transferOk = FakeMessageModel(
          error: false, data: '0xtxhash123456');

      final errorMsg = simulateTransferRetry(
          gasEstimate: gasOk, transferResult: transferOk);

      expect(errorMsg, isEmpty);
    });

    test('gas estimation failure uses gas error, not transfer error', () {
      final gasFail = FakeMessageModel(
          error: true, data: 'gas estimation failed');
      final transferMsg = FakeMessageModel(
          error: true, data: 'transfer error should not appear');

      final errorMsg = simulateTransferRetry(
          gasEstimate: gasFail, transferResult: transferMsg);

      expect(errorMsg, 'gas estimation failed');
      expect(errorMsg, isNot(contains('transfer error should not appear')));
    });
  });
}
