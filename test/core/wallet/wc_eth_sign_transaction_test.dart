// Tests for WCEthSignTransaction in wc_eth_sign_transcation.dart.
// Pure Dart model — no platform deps.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet_connect/models/wc_eth_sign_transcation.dart';

void main() {
  // ─────────────────────────────────────────────────
  // Constructor
  // ─────────────────────────────────────────────────

  group('WCEthSignTransaction constructor', () {
    test('stores required from field', () {
      final tx = WCEthSignTransaction(from: '0xSender');
      expect(tx.from, '0xSender');
    });

    test('optional fields default to null', () {
      final tx = WCEthSignTransaction(from: '0xSender');
      expect(tx.to, isNull);
      expect(tx.nonce, isNull);
      expect(tx.gasPrice, isNull);
      expect(tx.maxFeePerGas, isNull);
      expect(tx.maxPriorityFeePerGas, isNull);
      expect(tx.gas, isNull);
      expect(tx.gasLimit, isNull);
      expect(tx.value, isNull);
      expect(tx.data, isNull);
    });

    test('stores all provided optional fields', () {
      final tx = WCEthSignTransaction(
        from: '0xFrom',
        to: '0xTo',
        nonce: '0x01',
        gasPrice: '0xE8D4A51000',
        maxFeePerGas: '0x3B9ACA00',
        maxPriorityFeePerGas: '0x77359400',
        gas: '0x5208',
        gasLimit: '0x5208',
        value: '0xDE0B6B3A7640000',
        data: '0x',
      );

      expect(tx.to, '0xTo');
      expect(tx.nonce, '0x01');
      expect(tx.gasPrice, '0xE8D4A51000');
      expect(tx.maxFeePerGas, '0x3B9ACA00');
      expect(tx.maxPriorityFeePerGas, '0x77359400');
      expect(tx.gas, '0x5208');
      expect(tx.gasLimit, '0x5208');
      expect(tx.value, '0xDE0B6B3A7640000');
      expect(tx.data, '0x');
    });
  });

  // ─────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────

  group('WCEthSignTransaction.fromJson', () {
    test('parses all fields from JSON', () {
      final json = {
        'from': '0xFrom',
        'to': '0xTo',
        'nonce': '0x5',
        'gasPrice': '0x3B9ACA00',
        'maxFeePerGas': '0x77359400',
        'maxPriorityFeePerGas': '0x2FAF080',
        'gas': '0x5208',
        'gasLimit': '0x5208',
        'value': '0x0',
        'data': '0x1234',
      };
      final tx = WCEthSignTransaction.fromJson(json);

      expect(tx.from, '0xFrom');
      expect(tx.to, '0xTo');
      expect(tx.nonce, '0x5');
      expect(tx.gasPrice, '0x3B9ACA00');
      expect(tx.maxFeePerGas, '0x77359400');
      expect(tx.maxPriorityFeePerGas, '0x2FAF080');
      expect(tx.gas, '0x5208');
      expect(tx.gasLimit, '0x5208');
      expect(tx.value, '0x0');
      expect(tx.data, '0x1234');
    });

    test('missing optional fields in JSON become null', () {
      final tx = WCEthSignTransaction.fromJson({'from': '0xSender'});

      expect(tx.from, '0xSender');
      expect(tx.to, isNull);
      expect(tx.nonce, isNull);
      expect(tx.gasPrice, isNull);
      expect(tx.value, isNull);
      expect(tx.data, isNull);
    });

    test('explicit null values in JSON are preserved as null', () {
      final tx = WCEthSignTransaction.fromJson({
        'from': '0xSender',
        'to': null,
        'value': null,
      });

      expect(tx.from, '0xSender');
      expect(tx.to, isNull);
      expect(tx.value, isNull);
    });

    test('EIP-1559 tx without gasPrice', () {
      final tx = WCEthSignTransaction.fromJson({
        'from': '0xSender',
        'to': '0xReceiver',
        'maxFeePerGas': '0x3B9ACA00',
        'maxPriorityFeePerGas': '0x77359400',
        'gasLimit': '0x5208',
        'value': '0xDE0B6B3A7640000',
      });

      expect(tx.gasPrice, isNull);
      expect(tx.maxFeePerGas, '0x3B9ACA00');
      expect(tx.maxPriorityFeePerGas, '0x77359400');
    });
  });

  // ─────────────────────────────────────────────────
  // Mutable fields can be reassigned
  // ─────────────────────────────────────────────────

  group('WCEthSignTransaction mutability', () {
    test('fields can be reassigned after construction', () {
      final tx = WCEthSignTransaction(from: '0xOld');
      tx.from = '0xNew';
      tx.to = '0xTo';
      tx.value = '0x1';

      expect(tx.from, '0xNew');
      expect(tx.to, '0xTo');
      expect(tx.value, '0x1');
    });
  });
}
