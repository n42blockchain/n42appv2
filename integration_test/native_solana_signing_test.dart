import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/sol_transaction_message.dart';

/// Native plugin + cryptographic verification + read-only testnet RPC.
/// The disposable mnemonic is never persisted or printed. No transaction is sent.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'NATIVE-SOL-01 signs with Wallet Core and verifies Ed25519',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('N42 native Solana signing acceptance')),
        ),
      );
      final sdk = Trustdart();
      var mnemonic = await sdk.generateMnemonic();
      try {
        // Do not pass secret material to expect(): a failed matcher can print it.
        expect(
          mnemonic.split(' ').length == 12,
          isTrue,
          reason: 'Native mnemonic generation failed',
        );
        expect(await sdk.checkMnemonic(mnemonic), isTrue);
        const path = "m/44'/501'/0'/0'";
        final addresses = await sdk.generateAddress(
          'SOL',
          path,
          'legacy',
          mnemonic: mnemonic,
          isTest: true,
        );
        final address = addresses['legacy'] as String? ?? '';
        expect(await sdk.validateAddress('SOL', address), isTrue);
        final publicKey = Base58Decode(address);
        expect(publicKey.length, 32);
        final api = SolApi();
        final latest = await api.getLatestBlockhash(isTest: true);
        expect(
          latest.error,
          isFalse,
          reason: 'Solana Testnet latest blockhash RPC failed',
        );
        final signed = await sdk.signTransaction('SOL', path, {
          'type': 'SOL',
          'recentBlockhash': latest.data,
          'transferTransaction': {'recipient': address, 'value': '1000000'},
          'encodeType': 'base58',
        }, mnemonic: mnemonic);
        expect(
          signed.isNotEmpty,
          isTrue,
          reason: 'Wallet Core returned no signed transaction',
        );
        final wire = Base58Decode(signed);
        expect(wire.first, 1, reason: 'Expected a single native signature');
        final encodedMessage = solTransactionMessage(signed);
        final verified = await Ed25519().verify(
          base64Decode(encodedMessage),
          signature: Signature(
            wire.sublist(1, 65),
            publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
          ),
        );
        expect(
          verified,
          isTrue,
          reason: 'Native signature does not match the generated account',
        );
        final fee = await api.getFeeForMessage(encodedMessage, isTest: true);
        expect(
          fee.error,
          isFalse,
          reason: 'Testnet rejected the native transaction message',
        );
        expect(
          fee.data is BigInt && (fee.data as BigInt) > BigInt.zero,
          isTrue,
        );
        debugPrint(
          'NATIVE_SOLANA_VERIFIED network=testnet address=$address feeLamports=${fee.data} broadcast=false',
        );
      } finally {
        mnemonic = '';
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
