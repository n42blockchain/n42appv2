// Tests for pure-Dart classes in user_operation_receipt.dart:
//   UserOperationStatus (enum), UserOperationReceipt, TransactionReceiptInfo,
//   UserOperationLog — including fromJson / toJson round-trips and
//   the private _parseBigInt / _parseInt helpers exercised through fromJson.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/aa/models/user_operation_receipt.dart';

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────

/// Minimal TransactionReceiptInfo used inside UserOperationReceipt
TransactionReceiptInfo _receipt({int status = 1}) => TransactionReceiptInfo(
      blockHash: '0xblock',
      blockNumber: BigInt.from(100),
      transactionHash: '0xtxhash',
      transactionIndex: 0,
      from: '0xfrom',
      to: '0xto',
      cumulativeGasUsed: BigInt.zero,
      gasUsed: BigInt.from(21000),
      status: status,
      effectiveGasPrice: BigInt.from(1000000000),
    );

void main() {
  // ─────────────────────────────────────────────────
  // UserOperationStatus enum
  // ─────────────────────────────────────────────────

  group('UserOperationStatus enum', () {
    test('has 6 values', () {
      expect(UserOperationStatus.values.length, 6);
    });

    test('contains all expected values', () {
      expect(UserOperationStatus.values, containsAll([
        UserOperationStatus.pending,
        UserOperationStatus.included,
        UserOperationStatus.success,
        UserOperationStatus.failed,
        UserOperationStatus.replaced,
        UserOperationStatus.unknown,
      ]));
    });
  });

  // ─────────────────────────────────────────────────
  // TransactionReceiptInfo — constructor
  // ─────────────────────────────────────────────────

  group('TransactionReceiptInfo constructor', () {
    test('stores all required fields', () {
      final r = _receipt();
      expect(r.blockHash, '0xblock');
      expect(r.blockNumber, BigInt.from(100));
      expect(r.transactionHash, '0xtxhash');
      expect(r.from, '0xfrom');
      expect(r.to, '0xto');
      expect(r.status, 1);
    });

    test('contractAddress is null when not provided', () {
      expect(_receipt().contractAddress, isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // TransactionReceiptInfo.isSuccess
  // ─────────────────────────────────────────────────

  group('TransactionReceiptInfo.isSuccess', () {
    test('status 1 → true', () {
      expect(_receipt(status: 1).isSuccess, isTrue);
    });

    test('status 0 → false', () {
      expect(_receipt(status: 0).isSuccess, isFalse);
    });

    test('any other status → false', () {
      expect(_receipt(status: 2).isSuccess, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // TransactionReceiptInfo.fromJson — _parseBigInt variations
  // ─────────────────────────────────────────────────

  group('TransactionReceiptInfo.fromJson _parseBigInt', () {
    Map<String, dynamic> _base({dynamic blockNumber = '0x64'}) => {
          'blockHash': '0xabc',
          'blockNumber': blockNumber,
          'transactionHash': '0xtx',
          'transactionIndex': 0,
          'from': '0xfrom',
          'to': '0xto',
          'cumulativeGasUsed': '0x0',
          'gasUsed': '0x5208',
          'status': '0x1',
          'effectiveGasPrice': '0x3b9aca00',
        };

    test('hex string "0x64" → BigInt 100', () {
      final r = TransactionReceiptInfo.fromJson(_base(blockNumber: '0x64'));
      expect(r.blockNumber, BigInt.from(100));
    });

    test('decimal string "100" → BigInt 100', () {
      final r = TransactionReceiptInfo.fromJson(_base(blockNumber: '100'));
      expect(r.blockNumber, BigInt.from(100));
    });

    test('int 100 → BigInt 100', () {
      final r = TransactionReceiptInfo.fromJson(_base(blockNumber: 100));
      expect(r.blockNumber, BigInt.from(100));
    });

    test('null → BigInt.zero', () {
      final r = TransactionReceiptInfo.fromJson(_base(blockNumber: null));
      expect(r.blockNumber, BigInt.zero);
    });
  });

  // ─────────────────────────────────────────────────
  // TransactionReceiptInfo.fromJson — _parseInt variations
  // ─────────────────────────────────────────────────

  group('TransactionReceiptInfo.fromJson _parseInt', () {
    Map<String, dynamic> _base({dynamic transactionIndex = '0x1'}) => {
          'blockHash': '0xabc',
          'blockNumber': '0x1',
          'transactionHash': '0xtx',
          'transactionIndex': transactionIndex,
          'from': '0xfrom',
          'to': '0xto',
          'cumulativeGasUsed': '0x0',
          'gasUsed': '0x0',
          'status': '0x1',
          'effectiveGasPrice': '0x0',
        };

    test('hex string "0x1" → 1', () {
      final r = TransactionReceiptInfo.fromJson(_base(transactionIndex: '0x1'));
      expect(r.transactionIndex, 1);
    });

    test('decimal string "5" → 5', () {
      final r = TransactionReceiptInfo.fromJson(_base(transactionIndex: '5'));
      expect(r.transactionIndex, 5);
    });

    test('int 3 → 3', () {
      final r = TransactionReceiptInfo.fromJson(_base(transactionIndex: 3));
      expect(r.transactionIndex, 3);
    });

    test('null → 0', () {
      final r = TransactionReceiptInfo.fromJson(_base(transactionIndex: null));
      expect(r.transactionIndex, 0);
    });
  });

  // ─────────────────────────────────────────────────
  // TransactionReceiptInfo.toJson
  // ─────────────────────────────────────────────────

  group('TransactionReceiptInfo.toJson', () {
    test('encodes blockNumber as hex string', () {
      final r = _receipt();
      final json = r.toJson();
      expect(json['blockNumber'], '0x64'); // 100 in hex
    });

    test('encodes status as hex string', () {
      final r = _receipt(status: 1);
      final json = r.toJson();
      expect(json['status'], '0x1');
    });

    test('contractAddress: null is preserved in json', () {
      final json = _receipt().toJson();
      expect(json['contractAddress'], isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // UserOperationLog.fromJson
  // ─────────────────────────────────────────────────

  group('UserOperationLog.fromJson', () {
    final _logJson = <String, dynamic>{
      'logIndex': '0x0',
      'transactionIndex': '0x0',
      'transactionHash': '0xtx',
      'blockHash': '0xblock',
      'blockNumber': '0x1',
      'address': '0xcontract',
      'data': '0xdata',
      'topics': ['0xtopic1', '0xtopic2'],
    };

    test('stores all fields from JSON', () {
      final log = UserOperationLog.fromJson(_logJson);
      expect(log.transactionHash, '0xtx');
      expect(log.address, '0xcontract');
      expect(log.data, '0xdata');
      expect(log.topics, ['0xtopic1', '0xtopic2']);
    });

    test('parses logIndex from hex', () {
      final log = UserOperationLog.fromJson(_logJson);
      expect(log.logIndex, 0);
    });

    test('parses blockNumber from hex', () {
      final log = UserOperationLog.fromJson(_logJson);
      expect(log.blockNumber, BigInt.one);
    });

    test('missing topics defaults to empty list', () {
      final json = Map<String, dynamic>.from(_logJson)..remove('topics');
      final log = UserOperationLog.fromJson(json);
      expect(log.topics, isEmpty);
    });

    test('missing data defaults to "0x"', () {
      final json = Map<String, dynamic>.from(_logJson)..remove('data');
      final log = UserOperationLog.fromJson(json);
      expect(log.data, '0x');
    });
  });

  group('UserOperationLog.toJson', () {
    test('encodes logIndex as hex string', () {
      final log = UserOperationLog(
        logIndex: 2,
        transactionIndex: 0,
        transactionHash: '0xtx',
        blockHash: '0xblock',
        blockNumber: BigInt.one,
        address: '0xaddr',
        data: '0x',
        topics: [],
      );
      expect(log.toJson()['logIndex'], '0x2');
    });
  });

  // ─────────────────────────────────────────────────
  // UserOperationReceipt — constructor
  // ─────────────────────────────────────────────────

  group('UserOperationReceipt constructor', () {
    test('stores all required fields', () {
      final r = UserOperationReceipt(
        userOpHash: '0xhash',
        sender: '0xsender',
        nonce: BigInt.from(5),
        success: true,
        actualGasUsed: BigInt.from(50000),
        actualGasCost: BigInt.from(1000000),
        receipt: _receipt(),
        logs: [],
      );
      expect(r.userOpHash, '0xhash');
      expect(r.sender, '0xsender');
      expect(r.nonce, BigInt.from(5));
      expect(r.success, isTrue);
      expect(r.actualGasUsed, BigInt.from(50000));
      expect(r.paymaster, isNull);
      expect(r.logs, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // UserOperationReceipt.fromJson
  // ─────────────────────────────────────────────────

  group('UserOperationReceipt.fromJson', () {
    Map<String, dynamic> _receiptJson() => {
          'blockHash': '0xblock',
          'blockNumber': '0x1',
          'transactionHash': '0xtx',
          'transactionIndex': '0x0',
          'from': '0xfrom',
          'to': '0xto',
          'cumulativeGasUsed': '0x0',
          'gasUsed': '0x5208',
          'status': '0x1',
          'effectiveGasPrice': '0x3b9aca00',
        };

    Map<String, dynamic> _json({bool? success}) => {
          'userOpHash': '0xopHash',
          'sender': '0xsender',
          'nonce': '0x5',
          'success': success,
          'paymaster': '0xpaymaster',
          'actualGasUsed': '0xc350',  // 50000
          'actualGasCost': '0xf4240', // 1000000
          'receipt': _receiptJson(),
          'logs': [],
        };

    test('parses all fields correctly', () {
      final op = UserOperationReceipt.fromJson(_json(success: true));
      expect(op.userOpHash, '0xopHash');
      expect(op.sender, '0xsender');
      expect(op.nonce, BigInt.from(5));
      expect(op.success, isTrue);
      expect(op.paymaster, '0xpaymaster');
      expect(op.actualGasUsed, BigInt.from(50000));
      expect(op.actualGasCost, BigInt.from(1000000));
      expect(op.logs, isEmpty);
    });

    test('missing success field defaults to true', () {
      final json = _json(success: null);
      final op = UserOperationReceipt.fromJson(json);
      expect(op.success, isTrue);
    });

    test('missing logs defaults to empty list', () {
      final json = Map<String, dynamic>.from(_json(success: true))
        ..remove('logs');
      final op = UserOperationReceipt.fromJson(json);
      expect(op.logs, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────
  // UserOperationReceipt.toJson
  // ─────────────────────────────────────────────────

  group('UserOperationReceipt.toJson', () {
    test('encodes nonce as hex string', () {
      final op = UserOperationReceipt(
        userOpHash: '0xhash',
        sender: '0xsender',
        nonce: BigInt.from(10),
        success: true,
        actualGasUsed: BigInt.zero,
        actualGasCost: BigInt.zero,
        receipt: _receipt(),
        logs: [],
      );
      expect(op.toJson()['nonce'], '0xa'); // 10 in hex
    });

    test('encodes actualGasUsed as hex string', () {
      final op = UserOperationReceipt(
        userOpHash: '0xhash',
        sender: '0xsender',
        nonce: BigInt.zero,
        success: true,
        actualGasUsed: BigInt.from(255),
        actualGasCost: BigInt.zero,
        receipt: _receipt(),
        logs: [],
      );
      expect(op.toJson()['actualGasUsed'], '0xff');
    });
  });

  // ─────────────────────────────────────────────────
  // UserOperationReceipt.toString
  // ─────────────────────────────────────────────────

  group('UserOperationReceipt.toString', () {
    test('contains userOpHash', () {
      final op = UserOperationReceipt(
        userOpHash: '0xuserOp1',
        sender: '0xsender',
        nonce: BigInt.zero,
        success: true,
        actualGasUsed: BigInt.zero,
        actualGasCost: BigInt.zero,
        receipt: _receipt(),
        logs: [],
      );
      expect(op.toString(), contains('0xuserOp1'));
    });

    test('contains success field', () {
      final op = UserOperationReceipt(
        userOpHash: '0xhash',
        sender: '0xsender',
        nonce: BigInt.zero,
        success: false,
        actualGasUsed: BigInt.zero,
        actualGasCost: BigInt.zero,
        receipt: _receipt(),
        logs: [],
      );
      expect(op.toString(), contains('false'));
    });

    test('contains receipt txHash', () {
      final op = UserOperationReceipt(
        userOpHash: '0xhash',
        sender: '0xsender',
        nonce: BigInt.zero,
        success: true,
        actualGasUsed: BigInt.zero,
        actualGasCost: BigInt.zero,
        receipt: _receipt(),
        logs: [],
      );
      expect(op.toString(), contains('0xtxhash'));
    });
  });
}
