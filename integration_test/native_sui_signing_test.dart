import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

import 'package:web3dart/web3dart.dart' show hexToBytes;

import '../test/native/sui_reference_vectors.dart';

/// Public deterministic keys and synthetic gas objects. No RPC or broadcast.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'NATIVE-SUI-01 matches independent transaction-intent signatures',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final sdk = Trustdart();
      for (final vector in suiReferenceVectors) {
        final signed = await sdk.signTransaction('SUI', '', {
          'type': 'WC_SUI',
          'transaction': vector['raw'],
        }, pk: base64Encode(hexToBytes(vector['seed']!)));
        expect(signed, vector['signature']);
        for (final invalid in <Object?>[
          '',
          '!',
          'Zg',
          'Zh==',
          '${vector['raw']}\n',
          42,
          null,
        ]) {
          final rejected = await sdk.signTransaction('SUI', '', {
            'type': 'WC_SUI',
            'transaction': invalid,
          }, pk: base64Encode(hexToBytes(vector['seed']!)));
          expect(rejected, isEmpty);
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
  testWidgets(
    'NATIVE-SUI-02 ordinary transfers retain signature and reject invalid fields',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final sdk = Trustdart();
      final vector = suiReferenceVectors.first;
      final key = base64Encode(hexToBytes(vector['seed']!));
      final transfer = <String, Object?>{
        'type': 'SUI_TRANSFER',
        'fromAddress': vector['sender'],
        'toAddress': '0x${'2' * 64}',
        'amount': '9007199254740993',
        'gasBudget': '2000000',
        'referenceGasPrice': '1000',
        'utxo': [
          {
            'objectId': '0x${'3' * 64}',
            'version': '1',
            'objectDigest': '1' * 32,
          },
        ],
      };
      final signed = await sdk.signTransaction('SUI', '', transfer, pk: key);
      final parts = signed.split('|');
      expect(parts.length, 2);
      expect(
        await sdk.signTransaction('SUI', '', {
          'type': 'WC_SUI',
          'transaction': parts[0],
        }, pk: key),
        parts[1],
      );
      for (final field in ['amount', 'gasBudget', 'referenceGasPrice']) {
        for (final invalid in <Object>[
          '0',
          '-1',
          '18446744073709551616',
          '01',
          true,
          1.5,
        ]) {
          expect(
            await sdk.signTransaction('SUI', '', {
              ...transfer,
              field: invalid,
            }, pk: key),
            isEmpty,
          );
        }
      }
      expect(
        await sdk.signTransaction('SUI', '', {
          ...transfer,
          'fromAddress': transfer['toAddress'],
        }, pk: key),
        isEmpty,
      );
      final coins = transfer['utxo']! as List;
      expect(
        await sdk.signTransaction('SUI', '', {
          ...transfer,
          'utxo': [...coins, ...coins],
        }, pk: key),
        isEmpty,
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
