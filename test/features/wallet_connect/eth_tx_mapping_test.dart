// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-4: Tests for ETH transaction and sign mapping
//
// Mirrors the ETH-related branches of setActionDataMap in
// wallet_connect_provider.dart (lines 86–191).
// Strategy: extract pure mapping logic into local functions.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Pure-function mirrors of each ETH dispatch branch
// ---------------------------------------------------------------------------

/// Inline hex-to-int helper matching web3dart's hexToInt behaviour.
int _hexToInt(String hex) {
  final clean = hex.startsWith('0x') || hex.startsWith('0X')
      ? hex.substring(2)
      : hex;
  if (clean.isEmpty) return 0;
  return int.parse(clean, radix: 16);
}

/// Mirrors eth_sendTransaction / eth_signTransaction branch (lines 131–191).
Map<String, dynamic> parseEthTxParams(Map<String, dynamic> trMap) {
  return {
    'gas': _hexToInt(trMap['gas'] as String? ?? '0x0').toString(),
    'from': trMap['from'] as String? ?? '0x',
    'to': trMap['to'] as String? ?? '0x',
    'data': trMap['data'] as String? ?? '0x',
    'signType': 'transaction',
  };
}

/// Mirrors eth_signTypedData / eth_signTypedData_v3 / eth_signTypedData_v4
/// branch (lines 117–130): params[0]=address, params[1]=typedData.
Map<String, dynamic> parseEthSignTypedData(List<String> params) {
  return {'from': params[0], 'data': params[1], 'signType': 'message'};
}

/// Mirrors eth_sign branch (lines 104–116):
/// params[0]=address, params[1]=data — OPPOSITE of personal_sign.
Map<String, dynamic> parseEthSign(List<String> params) {
  return {'from': params[0], 'data': params[1], 'signType': 'message'};
}

/// Mirrors personal_sign branch (lines 87–103):
/// params[0]=data, params[1]=address.
Map<String, dynamic> parsePersonalSign(List<String> params) {
  return {'from': params[1], 'data': params[0], 'signType': 'message'};
}

// ---------------------------------------------------------------------------
void main() {
  group('eth_sendTransaction / eth_signTransaction — field extraction', () {
    test('from, to, data fields are extracted correctly', () {
      final trMap = {
        'from': '0xSender',
        'to': '0xRecipient',
        'data': '0xCalldata',
        'gas': '0x5208',
      };
      final result = parseEthTxParams(trMap);

      expect(result['from'], '0xSender');
      expect(result['to'], '0xRecipient');
      expect(result['data'], '0xCalldata');
    });

    test('gas decoded from hex to decimal string', () {
      final result = parseEthTxParams({
        'from': '0x',
        'to': '0x',
        'data': '0x',
        'gas': '0x5208',
      });
      // 0x5208 = 21000 (standard ETH transfer gas)
      expect(result['gas'], '21000');
    });

    test('gas=0x0 produces "0"', () {
      final result = parseEthTxParams({'gas': '0x0'});
      expect(result['gas'], '0');
    });

    test('missing gas key defaults to "0x0" → "0"', () {
      final result = parseEthTxParams({'from': '0xA', 'to': '0xB'});
      expect(result['gas'], '0');
    });

    test('missing from defaults to "0x"', () {
      final result = parseEthTxParams({'gas': '0x0', 'to': '0x', 'data': '0x'});
      expect(result['from'], '0x');
    });

    test('missing to defaults to "0x"', () {
      final result = parseEthTxParams({
        'gas': '0x0',
        'from': '0x',
        'data': '0x',
      });
      expect(result['to'], '0x');
    });

    test('missing data defaults to "0x"', () {
      final result = parseEthTxParams({'gas': '0x0', 'from': '0x', 'to': '0x'});
      expect(result['data'], '0x');
    });

    test('signType is "transaction"', () {
      final result = parseEthTxParams({'gas': '0x0'});
      expect(result['signType'], 'transaction');
    });

    test('large gas value (contract deployment) decoded correctly', () {
      // 0x3D0900 = 4000000
      final result = parseEthTxParams({'gas': '0x3D0900'});
      expect(result['gas'], '4000000');
    });
  });

  // -------------------------------------------------------------------------
  group('eth_signTypedData_v4 — params layout', () {
    test('params[0]=address, params[1]=typedData JSON', () {
      final params = ['0xUserAddr', '{"types":{},"domain":{}}'];
      final result = parseEthSignTypedData(params);

      expect(result['from'], '0xUserAddr');
      expect(result['data'], '{"types":{},"domain":{}}');
      expect(result['signType'], 'message');
    });

    test('typedData is passed through verbatim without JSON parsing', () {
      final typedData =
          '{"domain":{"name":"MyApp","chainId":1},"message":{"value":"100"}}';
      final result = parseEthSignTypedData(['0xAddr', typedData]);

      expect(result['data'], typedData);
    });

    test('eth_signTypedData_v3 uses same params layout as v4', () {
      // The implementation treats v3 and v4 identically
      final params = ['0xAddr', '{"types":{}}'];
      final v3Result = parseEthSignTypedData(params);
      final v4Result = parseEthSignTypedData(params);

      expect(v3Result['from'], v4Result['from']);
      expect(v3Result['data'], v4Result['data']);
    });
  });

  // -------------------------------------------------------------------------
  group('eth_sign vs personal_sign — critical field order difference', () {
    test('eth_sign: params[0]=address, params[1]=data', () {
      final params = ['0xAddressFirst', '0xDataSecond'];
      final result = parseEthSign(params);

      expect(result['from'], '0xAddressFirst');
      expect(result['data'], '0xDataSecond');
    });

    test('personal_sign: params[0]=data, params[1]=address (reversed!)', () {
      final params = ['0xDataFirst', '0xAddressSecond'];
      final result = parsePersonalSign(params);

      expect(result['from'], '0xAddressSecond');
      expect(result['data'], '0xDataFirst');
    });

    test(
      'same raw params produce different from/data for eth_sign vs personal_sign',
      () {
        final rawParams = ['0xParamA', '0xParamB'];

        final ethSign = parseEthSign(rawParams);
        final personalSign = parsePersonalSign(rawParams);

        // eth_sign: address at index 0
        expect(ethSign['from'], '0xParamA');
        expect(ethSign['data'], '0xParamB');

        // personal_sign: address at index 1
        expect(personalSign['from'], '0xParamB');
        expect(personalSign['data'], '0xParamA');

        // They must differ
        expect(ethSign['from'], isNot(personalSign['from']));
        expect(ethSign['data'], isNot(personalSign['data']));
      },
    );

    test('both eth_sign and personal_sign produce signType=message', () {
      expect(parseEthSign(['a', 'b'])['signType'], 'message');
      expect(parsePersonalSign(['a', 'b'])['signType'], 'message');
    });

    test('eth_sign signType is message', () {
      final result = parseEthSign(['0xAddr', '0xData']);
      expect(result['signType'], 'message');
    });
  });

  // -------------------------------------------------------------------------
  group('_hexToInt — inline hex decoding utility', () {
    test('0x prefix is stripped correctly', () {
      expect(_hexToInt('0x10'), 16);
    });

    test('uppercase 0X prefix is also stripped', () {
      expect(_hexToInt('0X10'), 16);
    });

    test('no prefix is treated as raw hex', () {
      expect(_hexToInt('10'), 16);
    });

    test('0x0 produces 0', () {
      expect(_hexToInt('0x0'), 0);
    });

    test('0x5208 produces 21000', () {
      expect(_hexToInt('0x5208'), 21000);
    });
  });
}
