// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-5: Tests for WalletConnect data models
//   - WCEthSignTransaction (fromJson / field access)
//   - WCEthSignMessage (enum values and construction)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/models/wc_eth_sign_transcation.dart';
import 'package:n42_wallet/features/wallet_connect/models/wc_eth_sign_message.dart';

void main() {
  // -------------------------------------------------------------------------
  group('WCEthSignTransaction', () {
    group('fromJson — complete payload', () {
      late Map<String, dynamic> fullJson;

      setUp(() {
        fullJson = {
          'from': '0xSender',
          'to': '0xRecipient',
          'nonce': '0x5',
          'gasPrice': '0xAbCdEf',
          'maxFeePerGas': '0x100',
          'maxPriorityFeePerGas': '0x50',
          'gas': '0x5208',
          'gasLimit': '0x7530',
          'value': '0xDE0B6B3A7640000',
          'data': '0xabcd1234',
        };
      });

      test('from field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.from, '0xSender');
      });

      test('to field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.to, '0xRecipient');
      });

      test('nonce field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.nonce, '0x5');
      });

      test('gasPrice field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.gasPrice, '0xAbCdEf');
      });

      test('maxFeePerGas field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.maxFeePerGas, '0x100');
      });

      test('maxPriorityFeePerGas field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.maxPriorityFeePerGas, '0x50');
      });

      test('gas field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.gas, '0x5208');
      });

      test('gasLimit field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.gasLimit, '0x7530');
      });

      test('value field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.value, '0xDE0B6B3A7640000');
      });

      test('data field is parsed', () {
        final tx = WCEthSignTransaction.fromJson(fullJson);
        expect(tx.data, '0xabcd1234');
      });
    });

    group('fromJson — minimal payload (EIP-1559 style)', () {
      test('missing optional fields are null', () {
        final tx = WCEthSignTransaction.fromJson({
          'from': '0xSender',
          'to': '0xRecipient',
          'gas': '0x5208',
        });

        expect(tx.from, '0xSender');
        expect(tx.to, '0xRecipient');
        expect(tx.gas, '0x5208');
        expect(tx.nonce, isNull);
        expect(tx.gasPrice, isNull);
        expect(tx.value, isNull);
        expect(tx.data, isNull);
      });
    });

    group('fromJson — empty payload', () {
      test('all fields are null when json is empty', () {
        final tx = WCEthSignTransaction.fromJson({});

        expect(tx.from, isNull);
        expect(tx.to, isNull);
        expect(tx.gas, isNull);
        expect(tx.value, isNull);
        expect(tx.data, isNull);
      });
    });

    group('constructor — named parameters', () {
      test('required from field can be set', () {
        final tx = WCEthSignTransaction(
          from: '0xMyAddr',
          to: '0xDest',
          value: '0x1',
        );
        expect(tx.from, '0xMyAddr');
        expect(tx.to, '0xDest');
        expect(tx.value, '0x1');
        expect(tx.data, isNull);
      });

      test('from can be null', () {
        final tx = WCEthSignTransaction(from: null);
        expect(tx.from, isNull);
      });
    });
  });

  // -------------------------------------------------------------------------
  group('WCEthSignMessage', () {
    group('WCSignType enum', () {
      test('all expected variants exist', () {
        expect(WCSignType.values, contains(WCSignType.MESSAGE));
        expect(WCSignType.values, contains(WCSignType.PERSONAL_MESSAGE));
        expect(WCSignType.values, contains(WCSignType.TYPED_MESSAGE_V1));
        expect(WCSignType.values, contains(WCSignType.TYPED_MESSAGE_V3));
        expect(WCSignType.values, contains(WCSignType.TYPED_MESSAGE_V4));
      });

      test('enum has exactly 5 values', () {
        expect(WCSignType.values.length, 5);
      });
    });

    group('WCEthSignMessage construction', () {
      test('all fields are stored correctly', () {
        const msg = WCEthSignMessage(
          data: '0xSomeData',
          address: '0xMyAddress',
          type: WCSignType.PERSONAL_MESSAGE,
        );

        expect(msg.data, '0xSomeData');
        expect(msg.address, '0xMyAddress');
        expect(msg.type, WCSignType.PERSONAL_MESSAGE);
      });

      test('TYPED_MESSAGE_V4 variant is stored', () {
        const msg = WCEthSignMessage(
          data: '{"domain":{}}',
          address: '0xSender',
          type: WCSignType.TYPED_MESSAGE_V4,
        );

        expect(msg.type, WCSignType.TYPED_MESSAGE_V4);
      });

      test('MESSAGE vs PERSONAL_MESSAGE are distinct', () {
        expect(WCSignType.MESSAGE, isNot(WCSignType.PERSONAL_MESSAGE));
      });
    });
  });
}
