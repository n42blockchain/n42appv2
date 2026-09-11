import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/signature_decoder.dart';
import 'package:n42_wallet/core/security/tx_risk_models.dart';

const spender = '0x1234567890123456789012345678901234567890';
String call(String selector, String amount) =>
    '0x$selector${spender.substring(2).padLeft(64, '0')}${amount.padLeft(64, '0')}';
String? field(SignatureDecodedResult result, String label) =>
    result.fields.where((f) => f.label == label).firstOrNull?.value;

void main() {
  group('native value preview', () {
    for (final (wei, expected) in [
      ('0', '0'),
      ('1', '0.000000000000000001'),
      ('1000000000000000000', '1'),
      ('1500000000000000000', '1.5'),
      (
        '900719925474099312345678901234567890',
        '900719925474099312.34567890123456789',
      ),
    ]) {
      test('preserves exact wei amount $wei', () {
        final result = SignatureDecoder.decodeContractCall(
          calldata: '0x',
          contractAddress: spender,
          value: '0x${BigInt.parse(wei).toRadixString(16)}',
        );
        expect(field(result, 'Amount'), '$expected ETH');
        expect(field(result, 'To'), spender);
        expect(result.description, contains('$expected ETH'));
      });
    }
    test('invalid value remains visible instead of fabricated zero', () {
      final result = SignatureDecoder.decodeContractCall(
        calldata: '0x',
        value: 'invalid',
      );
      expect(field(result, 'Amount'), 'invalid ETH');
    });
  });

  group('approval and transfer decoding', () {
    test('unlimited approval is dangerous for both hex letter cases', () {
      for (final amount in ['f' * 64, 'F' * 64]) {
        final result = SignatureDecoder.decodeContractCall(
          calldata: call('095ea7b3', amount),
          contractAddress: 'token',
        );
        expect(result.isDangerous, isTrue);
        expect(result.hasWarnings, isTrue);
        expect(field(result, 'Spender'), spender);
        expect(field(result, 'Amount'), 'UNLIMITED');
        expect(
          result.fields.singleWhere((f) => f.label == 'Amount').isHighlighted,
          isTrue,
        );
      }
    });
    test(
      'limited approval and exact transfer amount are decoded without rounding',
      () {
        const amount = '9007199254740993123456789';
        final hex = BigInt.parse(amount).toRadixString(16);
        final approve = SignatureDecoder.decodeContractCall(
          calldata: call('095ea7b3', hex),
        );
        expect(approve.riskLevel, TxRiskLevel.caution);
        expect(field(approve, 'Amount'), amount);
        final transfer = SignatureDecoder.decodeContractCall(
          calldata: call('a9059cbb', hex),
        );
        expect(field(transfer, 'Amount'), amount);
        expect(field(transfer, 'To'), spender);
      },
    );
    test('truncated approval preserves a caution warning', () {
      final result = SignatureDecoder.decodeContractCall(
        calldata: '0x095ea7b3',
      );
      expect(result.riskLevel, TxRiskLevel.caution);
      expect(result.hasWarnings, isTrue);
      expect(result.fields, isEmpty);
    });
    test('NFT grant and revocation show opposite permissions', () {
      for (final approved in [true, false]) {
        final result = SignatureDecoder.decodeContractCall(
          calldata: call('a22cb465', approved ? '1' : '0'),
          contractAddress: 'collection',
        );
        expect(result.isDangerous, approved);
        expect(result.hasWarnings, approved);
        expect(field(result, 'Operator'), spender);
        expect(field(result, 'Collection'), 'collection');
        expect(
          field(result, 'Approved'),
          approved ? 'YES — All NFTs' : 'NO — Revoked',
        );
      }
    });
    test(
      'transfer-from warns that an existing permission moves another account funds',
      () {
        final result = SignatureDecoder.decodeContractCall(
          calldata: call('23b872dd', '1'),
        );
        expect(result.riskLevel, TxRiskLevel.caution);
        expect(result.hasWarnings, isTrue);
        expect(
          SignatureDecoder.decodeContractCall(calldata: '0x42842e0e').title,
          'NFT Transfer',
        );
        expect(
          SignatureDecoder.decodeContractCall(calldata: '0xa9059cbb').fields,
          isEmpty,
        );
        expect(
          SignatureDecoder.decodeContractCall(
            calldata: '0xa22cb465',
          ).isDangerous,
          isTrue,
        );
        expect(
          SignatureDecoder.decodeContractCall(
            calldata: '0xd505accf',
          ).isDangerous,
          isTrue,
        );
      },
    );
    test(
      'value-bearing calls show exact native funds and preserve unknown-function warning',
      () {
        for (final selector in [
          'd0e30db0',
          '7ff36ab5',
          'fb0f3ee1',
          'a1903eab',
          'deadbeef',
        ]) {
          final result = SignatureDecoder.decodeContractCall(
            calldata: '0x$selector',
            contractAddress: spender,
            value: '0x1',
          );
          expect(
            result.fields.any((f) => f.value == '0.000000000000000001'),
            isTrue,
          );
          if (selector == 'deadbeef') {
            expect(result.riskLevel, TxRiskLevel.caution);
            expect(result.hasWarnings, isTrue);
          }
        }
      },
    );
  });

  group('typed signatures', () {
    test('permit displays spender, expiry and unlimited warning', () {
      final result = SignatureDecoder.decodeTypedData({
        'primaryType': 'Permit',
        'domain': {'name': 'USDC'},
        'message': {
          'spender': spender,
          'value': (BigInt.two.pow(256) - BigInt.one).toString(),
          'deadline': '1800000000',
        },
      });
      expect(result.isDangerous, isTrue);
      expect(field(result, 'Spender'), spender);
      expect(field(result, 'Token'), 'USDC');
      expect(field(result, 'Expires'), matches(r'^2027-01-\d{2}$'));
      expect(field(result, 'Amount'), 'UNLIMITED');
      expect(result.warnings, hasLength(2));
    });
    test(
      'limited permit preserves raw amount and handles absent or invalid deadline',
      () {
        for (final deadline in ['', 'invalid', '-999999999999999']) {
          final result = SignatureDecoder.decodeTypedData({
            'primaryType': 'Permit',
            'message': {
              'spender': 'short',
              'value': '123456789',
              'deadline': deadline,
            },
          });
          expect(result.riskLevel, TxRiskLevel.caution);
          expect(field(result, 'Amount'), '123456789');
          expect(field(result, 'Expires'), isNull);
        }
      },
    );
    test('far future expiry is displayed explicitly', () {
      final result = SignatureDecoder.decodeTypedData({
        'primaryType': 'Permit',
        'message': {'deadline': '1000000000000001'},
      });
      expect(field(result, 'Expires'), 'Never');
    });
    test('Permit2 preserves nested token amounts and spender for review', () {
      for (final type in ['PermitSingle', 'PermitBatch']) {
        final result = SignatureDecoder.decodeTypedData({
          'primaryType': type,
          'message': {
            'details': {
              'token': 'token',
              'amount': '999',
              'expiration': '1800000000',
            },
            'spender': spender,
          },
        });
        expect(result.hasWarnings, isTrue);
        expect(field(result, 'details.amount'), '999');
        expect(field(result, 'details.token'), 'token');
        expect(field(result, 'spender'), spender);
      }
    });
    test(
      'Safe transaction preserves nonce and target; unknown typed data stays caution',
      () {
        final safe = SignatureDecoder.decodeTypedData({
          'primaryType': 'SafeTx',
          'message': {'to': spender, 'value': '42', 'nonce': 7},
        });
        expect(field(safe, 'To'), spender);
        expect(field(safe, 'Value'), '42');
        expect(field(safe, 'Nonce'), '7');
        final generic = SignatureDecoder.decodeTypedData({
          'primaryType': 'Custom',
          'message': {
            'nested': {'value': null},
          },
        });
        expect(generic.riskLevel, TxRiskLevel.caution);
        expect(generic.hasWarnings, isTrue);
        expect(field(generic, 'nested.value'), 'null');
        final order = SignatureDecoder.decodeTypedData({
          'primaryType': 'OrderComponents',
          'message': {'offerer': spender},
        });
        expect(order.riskLevel, TxRiskLevel.caution);
        expect(order.hasWarnings, isTrue);
        expect(field(order, 'offerer'), spender);
      },
    );
  });

  group('personal messages', () {
    test('hex UTF-8 is readable and malformed hex remains visible', () {
      const text = '钱包消息';
      final hex = utf8
          .encode(text)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      expect(SignatureDecoder.decodePersonalSign('0x$hex').description, text);
      for (final bad in ['0x0', '0xGG']) {
        expect(SignatureDecoder.decodePersonalSign(bad).description, bad);
      }
    });
    test(
      'message preview truncates long content and retains a review warning',
      () {
        final result = SignatureDecoder.decodePersonalSign('a' * 501);
        expect(result.description, '${'a' * 200}...');
        expect(result.hasWarnings, isTrue);
        expect(
          SignatureDecoder.decodePersonalSign('hello').description,
          'hello',
        );
      },
    );
    test('terms and login descriptions retain short message details', () {
      expect(
        SignatureDecoder.decodePersonalSign('I accept terms').title,
        'Accept Terms',
      );
      expect(
        SignatureDecoder.decodePersonalSign(
          'Terms of Service ${'x' * 300}',
        ).description.length,
        203,
      );
      final login = SignatureDecoder.decodePersonalSign('Sign in\nNonce: 1234');
      expect(field(login, 'Message'), 'Sign in\nNonce: 1234');
      expect(
        SignatureDecoder.decodePersonalSign('Login ${'x' * 501}').fields,
        isEmpty,
      );
    });
  });
}
