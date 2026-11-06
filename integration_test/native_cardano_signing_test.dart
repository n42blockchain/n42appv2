import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/cardano/signed_transfer.dart';

/// Public BIP39 fixture and synthetic inputs. No RPC or broadcast.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const mnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  const path = "m/1852'/1815'/0'/0/0";
  final sdk = Trustdart();
  Future<Map<String, dynamic>> request() async {
    final sender = (await sdk.generateAddress(
      'ADA',
      path,
      'legacy',
      mnemonic: mnemonic,
    ))['legacy'];
    final recipient = (await sdk.generateAddress(
      'ADA',
      "m/1852'/1815'/0'/0/1",
      'legacy',
      mnemonic: mnemonic,
    ))['legacy'];
    expect(sender, isA<String>());
    expect(sender, startsWith('addr1'));
    expect(recipient, startsWith('addr1'));
    expect(sender, isNot(recipient));
    return {
      'toAddress': recipient,
      'changeAddress': sender,
      'amount': '2000000',
      'ttl': '103600',
      'utxos': [
        {
          'txHash': 'ab' * 32,
          'outputIndex': 0,
          'amount': '10000000',
          'address': sender,
        },
      ],
    };
  }

  testWidgets(
    'NATIVE-ADA-01 ordinary and maximum plans survive MethodChannel and JNI',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final data = await request();
      final legacy = await sdk.signTransaction(
        'ADA',
        path,
        data,
        mnemonic: mnemonic,
      );
      expect(legacy, matches(RegExp(r'^(0x)?([0-9a-fA-F]{2})+$')));
      final ordinary = await sdk.signTransaction('ADA', path, {
        ...data,
        'returnMetadata': true,
      }, mnemonic: mnemonic);
      final parsed = CardanoSignedTransfer.parse(
        ordinary,
        requested: BigInt.from(2000000),
        available: BigInt.from(10000000),
        sendMax: false,
      );
      expect(parsed.encoded, '0x${legacy.replaceFirst(RegExp(r"^0x"), "")}');
      expect(parsed.amount, BigInt.from(2000000));
      expect(parsed.fee, greaterThan(BigInt.zero));
      final maximum = await sdk.signTransaction('ADA', path, {
        ...data,
        'amount': '10000000',
        'useMaxAmount': true,
        'returnMetadata': true,
      }, mnemonic: mnemonic);
      final maxPlan = CardanoSignedTransfer.parse(
        maximum,
        requested: BigInt.from(10000000),
        available: BigInt.from(10000000),
        sendMax: true,
      );
      expect(maxPlan.amount + maxPlan.fee, BigInt.from(10000000));
      expect(jsonDecode(maximum)['change'], '0');
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'NATIVE-ADA-02 malformed fields and SDK failures cannot return signed bytes',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final data = await request();
      for (final field in ['amount', 'ttl', 'utxos', 'toAddress']) {
        final invalid = Map<String, dynamic>.from(data)..remove(field);
        expect(
          await sdk.signTransaction('ADA', path, invalid, mnemonic: mnemonic),
          isEmpty,
        );
      }
      for (final override in <Map<String, dynamic>>[
        {'toAddress': 'invalid'},
        {'amount': '100000000'},
        {'ttl': true},
        {
          'utxos': [
            {
              'txHash': 'ab' * 32,
              'outputIndex': 0,
              'amount': [
                {'unit': 'lovelace', 'quantity': '10000000'},
              ],
            },
          ],
        },
      ]) {
        expect(
          await sdk.signTransaction('ADA', path, {
            ...data,
            ...override,
          }, mnemonic: mnemonic),
          isEmpty,
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
