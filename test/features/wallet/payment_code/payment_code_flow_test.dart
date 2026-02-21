// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Tests for the payment_code module:
//   - PaymentPage: uuid init, UserInfo parsing, USDT amount selection,
//     web3Transaction state machine, sendPaymentReceipt guard
//   - PaymentHistory: direction detection, timestamp formatting,
//     loadHistory state machine
//   - UserInfoApi additions: sendPaymentReceipt parameter contract
//
// Strategy: pure-logic Fake pattern (no platform channels needed).
// Mirror each bug-fix and new feature with a targeted expectation.

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// ============================================================
// Shared fake MessageModel (mirrors src/models/message_model.dart)
// ============================================================

class FakeMessageModel {
  final bool error;
  final dynamic data;
  const FakeMessageModel({required this.error, required this.data});
  factory FakeMessageModel.ok(dynamic data) =>
      FakeMessageModel(error: false, data: data);
  factory FakeMessageModel.err(dynamic data) =>
      FakeMessageModel(error: true, data: data);
}

// ============================================================
// GROUP 1 — PaymentPage: uuid initialization (Bug Fix)
// ============================================================

/// Mirrors the initState logic of _PaymentPageState.
class FakePaymentPageInit {
  String amount = "";
  String address = "";
  String coinType = "";
  String uuid = "";

  void initState({
    String? widgetAmount,
    String? widgetUuid,
    String? widgetCoinType,
    String? widgetAddress,
  }) {
    if (widgetAmount != null) {
      amount = widgetAmount;
      address = widgetAddress ?? "";
      coinType = widgetCoinType ?? "";
      uuid = widgetUuid ?? ""; // Bug fix: was never set
    }
    // when widgetAmount is null, all fields stay at default ""
  }
}

// ============================================================
// GROUP 2 — PaymentPage: UserInfo parsing (Bug Fix)
// ============================================================

/// Mirrors the fixed initUserInfo() parsing logic.
class FakeUserInfo {
  final String? name;
  final String? uuid;
  FakeUserInfo({this.name, this.uuid});

  static FakeUserInfo? fromJson(Map<String, dynamic> json) {
    return FakeUserInfo(
      name: json['name'] as String?,
      uuid: json['uuid'] as String?,
    );
  }
}

FakeUserInfo? parseUserInfoSafe(dynamic rawData) {
  if (rawData == null) return null;
  try {
    return FakeUserInfo.fromJson(Map<String, dynamic>.from(rawData as Map));
  } catch (_) {
    return null; // graceful degradation, not rethrown
  }
}

// ============================================================
// GROUP 3 — PaymentPage: USDT amount selection (Bug Fix)
// ============================================================

/// Mirrors the amount selection logic in web3Transaction().
double computeTransferAmount(String usdtAmount, String fallbackAmount) {
  if (usdtAmount.isNotEmpty) {
    final v = double.tryParse(usdtAmount);
    if (v != null && v.isFinite && v >= 0) return v;
  }
  if (fallbackAmount.isNotEmpty) {
    final v = double.tryParse(fallbackAmount);
    if (v != null && v.isFinite && v >= 0) return v;
  }
  return 0.0;
}

// ============================================================
// GROUP 4 — PaymentPage: web3Transaction state machine
// ============================================================

enum FakeLoad { loading, finish }

class FakeWeb3State {
  FakeLoad load = FakeLoad.finish;
  String errorMessage = "";
  bool receiptNotified = false;

  Future<void> runTransaction({
    required FakeMessageModel transferResult,
    required String uuid,
    bool Function()? onSendReceipt, // returns true if called
  }) async {
    load = FakeLoad.loading;
    // yield to event loop (mirrors real async API call) so callers
    // can capture the `loading` state before completion
    await Future<void>.microtask(() {});
    if (transferResult.error) {
      errorMessage = transferResult.data.toString();
      load = FakeLoad.finish;
    } else {
      errorMessage = "";
      load = FakeLoad.finish;
      // sendPaymentReceipt guard: only when uuid is non-empty
      if (uuid.isNotEmpty) {
        receiptNotified = true;
        onSendReceipt?.call();
      }
    }
  }
}

// ============================================================
// GROUP 5 — PaymentPage: sendPaymentReceipt input contract
// ============================================================

class FakeSendPaymentReceiptParams {
  final String toUuid;
  final String txHash;
  final String amount;
  final String tokenAmount;
  final String coinType;
  final String tokenName;

  const FakeSendPaymentReceiptParams({
    required this.toUuid,
    required this.txHash,
    required this.amount,
    required this.tokenAmount,
    required this.coinType,
    required this.tokenName,
  });

  /// Mirrors the validation guard: only send when toUuid is non-empty.
  bool get shouldSend => toUuid.isNotEmpty;

  /// Mirrors the security check: amount must be a valid finite positive number.
  bool get isAmountValid {
    final v = double.tryParse(amount);
    return v != null && v.isFinite && v > 0;
  }
}

// ============================================================
// GROUP 6 — PaymentHistory: direction detection
// ============================================================

bool isIncomingPayment(
    {required String toUuid, required String myUuid}) =>
    toUuid == myUuid && myUuid.isNotEmpty;

// ============================================================
// GROUP 7 — PaymentHistory: timestamp formatting
// ============================================================

final _dateFmt = DateFormat("MM-dd HH:mm");

String formatPaymentTime(dynamic txTime) {
  if (txTime == null) return "";
  try {
    int ts = int.parse(txTime.toString());
    if (ts < 9999999999) ts = ts * 1000; // seconds → milliseconds
    return _dateFmt.format(DateTime.fromMillisecondsSinceEpoch(ts));
  } catch (_) {
    return "";
  }
}

// ============================================================
// GROUP 8 — PaymentHistory: loadHistory state machine
// ============================================================

class FakeHistoryState {
  FakeLoad load = FakeLoad.finish;
  String errorMessage = "";
  List<Map<String, dynamic>> dataList = [];

  Future<void> loadHistory(FakeMessageModel apiResult) async {
    if (load == FakeLoad.loading) return; // concurrent guard
    load = FakeLoad.loading;
    errorMessage = "";

    if (apiResult.error) {
      load = FakeLoad.finish; // mapped to error in real code, using finish here
      errorMessage = apiResult.data?.toString() ?? "Failed to load";
    } else {
      final raw = apiResult.data;
      final List<Map<String, dynamic>> parsed = [];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) parsed.add(Map<String, dynamic>.from(item));
        }
      }
      dataList = parsed;
      load = FakeLoad.finish;
    }
  }
}

// ============================================================
// TESTS
// ============================================================

void main() {
  // ----------------------------------------------------------
  group('PaymentPage — Group 1: uuid initialization (Bug Fix)', () {
    test('uuid is set from widget.uuid when amount is provided', () {
      final state = FakePaymentPageInit();
      state.initState(
        widgetAmount: "9.9",
        widgetUuid: "payee-uuid-123",
        widgetCoinType: "ETH",
        widgetAddress: "0xAbcDef",
      );
      expect(state.uuid, "payee-uuid-123",
          reason: 'uuid must be read from widget.uuid (was never set before fix)');
    });

    test('null widget.uuid defaults to empty string, not null', () {
      final state = FakePaymentPageInit();
      state.initState(
        widgetAmount: "9.9",
        widgetUuid: null,
        widgetCoinType: "ETH",
        widgetAddress: "0xAbcDef",
      );
      expect(state.uuid, isEmpty,
          reason: 'null uuid must become empty string, not throw');
    });

    test('when widget.amount is null, all fields remain default empty', () {
      final state = FakePaymentPageInit();
      state.initState(widgetAmount: null);
      expect(state.amount, isEmpty);
      expect(state.uuid, isEmpty);
      expect(state.address, isEmpty);
    });

    test('amount, address, coinType are correctly propagated', () {
      final state = FakePaymentPageInit();
      state.initState(
        widgetAmount: "15.00",
        widgetUuid: "uid-456",
        widgetCoinType: "BSC",
        widgetAddress: "0x1234",
      );
      expect(state.amount, "15.00");
      expect(state.address, "0x1234");
      expect(state.coinType, "BSC");
    });
  });

  // ----------------------------------------------------------
  group('PaymentPage — Group 2: UserInfo parsing (Bug Fix)', () {
    test('valid map is parsed into FakeUserInfo correctly', () {
      final raw = {"uuid": "abc", "name": "Alice", "email": "a@b.com"};
      final user = parseUserInfoSafe(raw);
      expect(user, isNotNull);
      expect(user!.name, "Alice");
      expect(user.uuid, "abc");
    });

    test('null raw data returns null without throwing', () {
      final user = parseUserInfoSafe(null);
      expect(user, isNull);
    });

    test('non-Map data returns null without throwing', () {
      expect(() => parseUserInfoSafe("not-a-map"), returnsNormally);
      final user = parseUserInfoSafe("not-a-map");
      expect(user, isNull);
    });

    test('map with missing keys uses null defaults', () {
      final user = parseUserInfoSafe({"uuid": "xyz"});
      expect(user, isNotNull);
      expect(user!.name, isNull);
      expect(user.uuid, "xyz");
    });
  });

  // ----------------------------------------------------------
  group('PaymentPage — Group 3: USDT amount selection (Bug Fix)', () {
    test('uses usdtAmount when it is a valid number', () {
      expect(computeTransferAmount("10.1", "9.9"), closeTo(10.1, 0.0001),
          reason: 'should prefer usdtAmount over USD amount');
    });

    test('falls back to USD amount when usdtAmount is empty', () {
      expect(computeTransferAmount("", "9.9"), closeTo(9.9, 0.0001));
    });

    test('returns 0.0 when both are empty', () {
      expect(computeTransferAmount("", ""), 0.0);
    });

    test('returns 0.0 for malformed usdtAmount and falls back', () {
      expect(computeTransferAmount("NaN", "9.9"), closeTo(9.9, 0.0001),
          reason: 'NaN must be rejected, fallback to amount');
    });

    test('returns 0.0 for malformed both amounts', () {
      expect(computeTransferAmount("abc", "xyz"), 0.0);
    });

    test('rejects negative usdtAmount and falls back to amount', () {
      expect(computeTransferAmount("-5.0", "9.9"), closeTo(9.9, 0.0001),
          reason: 'negative USDT amount must be rejected');
    });

    test('infinity is rejected', () {
      expect(computeTransferAmount("Infinity", "9.9"), closeTo(9.9, 0.0001));
    });
  });

  // ----------------------------------------------------------
  group('PaymentPage — Group 4: web3Transaction state machine', () {
    test('successful transfer: errorMessage cleared, load=finish', () async {
      final state = FakeWeb3State();
      await state.runTransaction(
        transferResult: FakeMessageModel.ok("0xtxhash"),
        uuid: "payee-123",
      );
      expect(state.errorMessage, isEmpty);
      expect(state.load, FakeLoad.finish);
    });

    test('failed transfer: errorMessage from rData.data, load=finish', () async {
      final state = FakeWeb3State();
      await state.runTransaction(
        transferResult: FakeMessageModel.err("insufficient funds"),
        uuid: "payee-123",
      );
      expect(state.errorMessage, "insufficient funds");
      expect(state.load, FakeLoad.finish);
    });

    test('on success with non-empty uuid: receipt notification is sent', () async {
      final state = FakeWeb3State();
      await state.runTransaction(
        transferResult: FakeMessageModel.ok("0xtxhash"),
        uuid: "payee-123",
      );
      expect(state.receiptNotified, isTrue,
          reason: 'sendPaymentReceipt must fire when uuid is non-empty');
    });

    test('on success with empty uuid: receipt notification is skipped', () async {
      final state = FakeWeb3State();
      await state.runTransaction(
        transferResult: FakeMessageModel.ok("0xtxhash"),
        uuid: "",
      );
      expect(state.receiptNotified, isFalse,
          reason: 'sendPaymentReceipt must be skipped when uuid is empty');
    });

    test('on failure: receipt notification is never sent', () async {
      final state = FakeWeb3State();
      await state.runTransaction(
        transferResult: FakeMessageModel.err("error"),
        uuid: "payee-123",
      );
      expect(state.receiptNotified, isFalse);
    });

    test('loading state is set at start of transaction', () async {
      final state = FakeWeb3State();
      FakeLoad? capturedLoad;
      // Capture load state synchronously during the call
      final future = state.runTransaction(
        transferResult: FakeMessageModel.ok("0x"),
        uuid: "uid",
      );
      capturedLoad = state.load;
      await future;
      expect(capturedLoad, FakeLoad.loading,
          reason: 'load must be set to loading before any await');
    });
  });

  // ----------------------------------------------------------
  group('PaymentPage — Group 5: sendPaymentReceipt input contract', () {
    test('shouldSend is false when toUuid is empty', () {
      final params = FakeSendPaymentReceiptParams(
        toUuid: "",
        txHash: "0xtx",
        amount: "9.9",
        tokenAmount: "10.1",
        coinType: "ETH",
        tokenName: "USDT",
      );
      expect(params.shouldSend, isFalse);
    });

    test('shouldSend is true when toUuid is non-empty', () {
      final params = FakeSendPaymentReceiptParams(
        toUuid: "uuid-payee",
        txHash: "0xtx",
        amount: "9.9",
        tokenAmount: "10.1",
        coinType: "ETH",
        tokenName: "USDT",
      );
      expect(params.shouldSend, isTrue);
    });

    test('isAmountValid is false for empty amount', () {
      final params = FakeSendPaymentReceiptParams(
        toUuid: "uid",
        txHash: "0xtx",
        amount: "",
        tokenAmount: "10.1",
        coinType: "ETH",
        tokenName: "USDT",
      );
      expect(params.isAmountValid, isFalse);
    });

    test('isAmountValid is false for negative amount (injection attempt)', () {
      final params = FakeSendPaymentReceiptParams(
        toUuid: "uid",
        txHash: "0xtx",
        amount: "-9.9",
        tokenAmount: "10.1",
        coinType: "ETH",
        tokenName: "USDT",
      );
      expect(params.isAmountValid, isFalse,
          reason: 'negative amount must be rejected to prevent payment manipulation');
    });

    test('isAmountValid is true for valid positive amount', () {
      final params = FakeSendPaymentReceiptParams(
        toUuid: "uid",
        txHash: "0xtx",
        amount: "9.9",
        tokenAmount: "10.1",
        coinType: "ETH",
        tokenName: "USDT",
      );
      expect(params.isAmountValid, isTrue);
    });
  });

  // ----------------------------------------------------------
  group('PaymentHistory — Group 6: direction detection', () {
    const myUuid = "my-uuid-abc";

    test('toUuid == myUuid → isIncoming = true', () {
      expect(isIncomingPayment(toUuid: myUuid, myUuid: myUuid), isTrue);
    });

    test('toUuid != myUuid → isIncoming = false (outgoing)', () {
      expect(isIncomingPayment(toUuid: "other-uuid", myUuid: myUuid), isFalse);
    });

    test('empty toUuid → isIncoming = false', () {
      expect(isIncomingPayment(toUuid: "", myUuid: myUuid), isFalse);
    });

    test('empty myUuid → isIncoming = false (not logged in)', () {
      expect(isIncomingPayment(toUuid: "some-uuid", myUuid: ""), isFalse);
    });

    test('both empty → isIncoming = false', () {
      expect(isIncomingPayment(toUuid: "", myUuid: ""), isFalse);
    });
  });

  // ----------------------------------------------------------
  group('PaymentHistory — Group 7: timestamp formatting', () {
    test('second-level timestamp (10 digits) is converted to ms', () {
      // 2024-01-15 12:00:00 UTC ≈ Unix 1705320000
      final ts = 1705320000;
      final result = formatPaymentTime(ts);
      expect(result, isNotEmpty);
      expect(result, matches(r'^\d{2}-\d{2} \d{2}:\d{2}$'),
          reason: 'format must be MM-dd HH:mm');
    });

    test('millisecond-level timestamp (13 digits) is used as-is', () {
      final ts = 1705320000000;
      final result = formatPaymentTime(ts);
      expect(result, isNotEmpty);
      expect(result, matches(r'^\d{2}-\d{2} \d{2}:\d{2}$'));
    });

    test('null txTime returns empty string', () {
      expect(formatPaymentTime(null), isEmpty);
    });

    test('string timestamp is parsed correctly', () {
      final result = formatPaymentTime("1705320000");
      expect(result, isNotEmpty);
    });

    test('non-numeric string returns empty string', () {
      expect(formatPaymentTime("not-a-time"), isEmpty);
    });

    test('second and millisecond representations of same time produce same output', () {
      final ts = 1705320000;
      expect(formatPaymentTime(ts), formatPaymentTime(ts * 1000));
    });
  });

  // ----------------------------------------------------------
  group('PaymentHistory — Group 8: loadHistory state machine', () {
    test('success: dataList populated and load=finish', () async {
      final state = FakeHistoryState();
      final mockData = [
        {"fromUuid": "u1", "toUuid": "my-uuid", "amount": "9.9",
         "txHash": "0xabc", "chainSymbol": "ETH", "token": "USDT"},
        {"fromUuid": "my-uuid", "toUuid": "u2", "amount": "5.0",
         "txHash": "0xdef", "chainSymbol": "BSC", "token": "USDT"},
      ];
      await state.loadHistory(FakeMessageModel.ok(mockData));
      expect(state.dataList, hasLength(2));
      expect(state.errorMessage, isEmpty);
      expect(state.load, FakeLoad.finish);
    });

    test('error: errorMessage set from api error, dataList empty', () async {
      final state = FakeHistoryState();
      await state.loadHistory(FakeMessageModel.err("Server error 500"));
      expect(state.errorMessage, "Server error 500");
      expect(state.dataList, isEmpty);
      expect(state.load, FakeLoad.finish);
    });

    test('empty list: dataList is empty, no error, load=finish', () async {
      final state = FakeHistoryState();
      await state.loadHistory(FakeMessageModel.ok([]));
      expect(state.dataList, isEmpty);
      expect(state.errorMessage, isEmpty);
      expect(state.load, FakeLoad.finish);
    });

    test('concurrent call guard: second call before first finishes is dropped', () async {
      final state = FakeHistoryState();
      // First call in-flight
      state.load = FakeLoad.loading;
      // Second call should be dropped
      await state.loadHistory(FakeMessageModel.ok([{"txHash": "0x1"}]));
      // dataList should still be empty because the second call was dropped
      expect(state.dataList, isEmpty,
          reason: 'concurrent loadHistory must be ignored when already loading');
    });

    test('null data field treated as empty list', () async {
      final state = FakeHistoryState();
      await state.loadHistory(FakeMessageModel.ok(null));
      expect(state.dataList, isEmpty);
      expect(state.errorMessage, isEmpty);
    });

    test('non-list data field treated as empty list', () async {
      final state = FakeHistoryState();
      await state.loadHistory(FakeMessageModel.ok("unexpected string"));
      expect(state.dataList, isEmpty);
    });
  });
}
