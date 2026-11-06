import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';

/// Public BIP39 fixture and synthetic sequence. No RPC or broadcast.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const mnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  const path = "m/44'/148'/0'";
  final sdk = Trustdart();

  testWidgets('NATIVE-XLM-01 string fee and network reach the real signer', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final address = await sdk.generateAddress(
      'XLM',
      "m/44'/148'/1'",
      'legacy',
      mnemonic: mnemonic,
    );
    expect(address['legacy'], startsWith('G'));
    final signatures = <String>[];
    for (final network in [
      'Public Global Stellar Network ; September 2015',
      'Test SDF Network ; September 2015',
    ]) {
      final signature = await sdk.signTransaction('XLM', path, {
        'toAddress': address['legacy'],
        'amount': '12500000',
        'fee': '100',
        'sequence': '8',
        'memo': 'invoice 42',
        'passphrase': network,
      }, mnemonic: mnemonic);
      expect(signature, isNotEmpty);
      expect(base64Decode(signature), isNotEmpty);
      signatures.add(signature);
    }
    expect(signatures[0], isNot(signatures[1]));
  });
}
