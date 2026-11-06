import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:web3dart/web3dart.dart' show hexToBytes;

import '../test/native/aptos_reference_vectors.dart';
import '../test/native/aptos_coin_reference_vectors.dart' as coin;
import '../test/native/aptos_fa_reference_vectors.dart' as fa;

/// Public test keys, synthetic transactions, no network or broadcast.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'NATIVE-APT-01 raw and ordinary signing match independent vectors',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final sdk = Trustdart();
      for (final vector in [
        ...aptosReferenceVectors,
        ...coin.aptosReferenceVectors,
        ...fa.aptosReferenceVectors,
      ]) {
        final isToken = vector['token'] == true;
        final isFA = vector['fa'] == true;
        final raw = vector['raw']! as String;
        final key = base64Encode(hexToBytes(vector['seed']! as String));
        final chain = vector['chain']! as int;
        final expected = vector['signed']! as String;
        final request = {
          'type': 'WC_APT',
          'encodedTransaction': base64Encode(hexToBytes(raw)),
          'chainId': chain,
        };
        final signed = await sdk.signTransaction('APT', '', request, pk: key);
        expect(signed.replaceFirst(RegExp(r'^0x'), ''), expected);
        expect(
          await sdk.signTransaction('APT', '', {
            ...request,
            'chainId': chain == 1 ? 2 : 1,
          }, pk: key),
          isEmpty,
        );
        expect(
          await sdk.signTransaction(
            'APT',
            '',
            request,
            pk: base64Encode(List.filled(32, 2)),
          ),
          isEmpty,
        );
        for (var length = 0; length < 67; length++) {
          expect(
            await sdk.signTransaction('APT', '', {
              ...request,
              'encodedTransaction': base64Encode(
                hexToBytes(raw).sublist(0, length),
              ),
            }, pk: key),
            isEmpty,
          );
        }
        final transfer = {
          'type': isFA ? 'APT_FA_TRANSFER' : 'APT_TRANSFER',
          'fromAddress': '0x${raw.substring(0, 64)}',
          'toAddress': '0x2',
          'amount': 1,
          'SequenceNumber': 0,
          'gasUnitPrice': 100,
          'maxGasAmount': 10000,
          'expirationTimestampSecs': 2000000000,
          'chainId': chain,
          'contractAddress': isToken || isFA ? '0x2a' : '',
          'contractModule': isToken ? 'usd' : '',
          'contractName': isToken ? 'USDC' : '',
        };
        final ordinary = await sdk.signTransaction(
          'APT',
          '',
          transfer,
          pk: key,
        );
        expect(ordinary.replaceFirst(RegExp(r'^0x'), ''), expected);
        final strings = Map<String, Object>.from(transfer);
        for (final field in [
          'amount',
          'SequenceNumber',
          'gasUnitPrice',
          'maxGasAmount',
          'expirationTimestampSecs',
        ]) {
          strings[field] = transfer[field].toString();
        }
        expect(
          (await sdk.signTransaction(
            'APT',
            '',
            strings,
            pk: key,
          )).replaceFirst(RegExp(r'^0x'), ''),
          expected,
        );
        final maxRaw = hexToBytes(raw);
        maxRaw.fillRange(32, 40, 255);
        maxRaw.fillRange(maxRaw.length - 33, maxRaw.length - 25, 255);
        final maxSigned = await sdk.signTransaction('APT', '', {
          ...strings,
          'amount': '18446744073709551615',
          'SequenceNumber': '18446744073709551615',
        }, pk: key);
        final maxRawSigned = await sdk.signTransaction('APT', '', {
          ...request,
          'encodedTransaction': base64Encode(maxRaw),
        }, pk: key);
        expect(maxSigned, isNotEmpty);
        expect(maxSigned, maxRawSigned);
        expect(
          maxSigned.replaceFirst(RegExp(r'^0x'), ''),
          startsWith(
            maxRaw.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
          ),
        );
        if (isToken || isFA) {
          for (final invalid in ['0xgg', '0x1::coin::Token', '0x2a\n']) {
            expect(
              await sdk.signTransaction('APT', '', {
                ...transfer,
                'contractAddress': invalid,
              }, pk: key),
              isEmpty,
            );
          }
        }
        for (final field in [
          'amount',
          'SequenceNumber',
          'gasUnitPrice',
          'maxGasAmount',
          'expirationTimestampSecs',
        ]) {
          for (final invalid in <Object>[
            -1,
            1.5,
            true,
            '18446744073709551616',
          ]) {
            expect(
              await sdk.signTransaction('APT', '', {
                ...transfer,
                field: invalid,
              }, pk: key),
              isEmpty,
            );
          }
        }
        expect(
          await sdk.signTransaction('APT', '', {
            ...transfer,
            'fromAddress': '0x2',
          }, pk: key),
          isEmpty,
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
