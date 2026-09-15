// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-3: Tests for TRON transaction field mapping (P0 audit issue)
//
// Mirrors the tron_signTransaction branch of setActionDataMap in
// wallet_connect_provider.dart (lines 143–179).
// Strategy: extract pure mapping logic into a local function to avoid
// instantiating the Flutter-dependent WalletConnectProvider.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Mirror of the tron_signTransaction mapping logic
// ---------------------------------------------------------------------------
class _TronTxResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? errorMsg;

  _TronTxResult.ok(this.data) : success = true, errorMsg = null;
  _TronTxResult.err(String msg) : success = false, data = null, errorMsg = msg;
}

/// Mirrors lines 143–179 of wallet_connect_provider.dart.
_TronTxResult processTronSignTransaction(dynamic rawParams) {
  if (rawParams == null ||
      rawParams is! Map ||
      !rawParams.containsKey('transaction')) {
    return _TronTxResult.err('Invalid TRON transaction: missing params');
  }
  final Map<String, dynamic> trMap = Map<String, dynamic>.from(
    rawParams['transaction'] as Map,
  );
  final tronInnerTx = trMap['transaction'] as Map<String, dynamic>? ?? {};
  final tronRawData = tronInnerTx['raw_data'] as Map<String, dynamic>? ?? {};

  final tronContractRaw = tronRawData['contract'];
  String tronContractType = '';
  Map<String, dynamic> tronContractValue = {};
  if (tronContractRaw is List && tronContractRaw.isNotEmpty) {
    final item = tronContractRaw[0] as Map<String, dynamic>;
    tronContractType = item['type'] as String? ?? '';
    tronContractValue =
        (item['parameter']?['value'] as Map<String, dynamic>?) ?? {};
  } else if (tronContractRaw is Map<String, dynamic>) {
    tronContractType = tronContractRaw['type'] as String? ?? '';
    tronContractValue =
        (tronContractRaw['parameter']?['value'] as Map<String, dynamic>?) ?? {};
  }

  final tronOwnerAddr = tronContractValue['owner_address'] as String? ?? '';
  final tronToAddr = tronContractValue['to_address'] as String? ?? '';
  final tronContractAddr =
      tronContractValue['contract_address'] as String? ?? '';
  final tronFeeLimit = tronRawData['fee_limit'] as int? ?? 0;
  final isTrc20 = tronContractType == 'TriggerSmartContract';

  return _TronTxResult.ok({
    'gas': tronFeeLimit.toString(),
    'from': tronOwnerAddr,
    'to': isTrc20 ? tronContractAddr : tronToAddr,
    'data': tronInnerTx['raw_data_hex'] as String? ?? '',
    'signType': 'transaction',
  });
}

/// Mirror of the tron_signMessage branch.
Map<String, dynamic> processTronSignMessage(Map<String, dynamic> params) {
  return {
    'from': params['address'] as String? ?? '',
    'data': params['message'] as String? ?? '',
    'signType': 'message',
  };
}

// ---------------------------------------------------------------------------
// Helpers to build test payloads
// ---------------------------------------------------------------------------
Map<String, dynamic> _nativeTrxParams({
  String ownerAddress = 'TXyZ1234Owner',
  String toAddress = 'TXyZ5678To',
  int feeLimit = 1000000,
  String rawDataHex = 'deadbeef01',
}) {
  return {
    'transaction': {
      'transaction': {
        'raw_data': {
          'contract': [
            {
              'type': 'TransferContract',
              'parameter': {
                'value': {
                  'owner_address': ownerAddress,
                  'to_address': toAddress,
                },
              },
            },
          ],
          'fee_limit': feeLimit,
        },
        'raw_data_hex': rawDataHex,
      },
    },
  };
}

Map<String, dynamic> _trc20Params({
  String ownerAddress = 'TXyZ1234Owner',
  String contractAddress = 'TXyZ9999Contract',
  int feeLimit = 5000000,
  String rawDataHex = 'cafebabe',
}) {
  return {
    'transaction': {
      'transaction': {
        'raw_data': {
          'contract': [
            {
              'type': 'TriggerSmartContract',
              'parameter': {
                'value': {
                  'owner_address': ownerAddress,
                  'contract_address': contractAddress,
                },
              },
            },
          ],
          'fee_limit': feeLimit,
        },
        'raw_data_hex': rawDataHex,
      },
    },
  };
}

// ---------------------------------------------------------------------------
void main() {
  group('tron_signTransaction — field mapping', () {
    group('native TRX transfer (TransferContract)', () {
      test('from = owner_address', () {
        final result = processTronSignTransaction(
          _nativeTrxParams(ownerAddress: 'TOwner'),
        );
        expect(result.success, isTrue);
        expect(result.data!['from'], 'TOwner');
      });

      test('to = to_address', () {
        final result = processTronSignTransaction(
          _nativeTrxParams(toAddress: 'TDest'),
        );
        expect(result.success, isTrue);
        expect(result.data!['to'], 'TDest');
      });

      test('to is NOT contract_address for native transfer', () {
        final result = processTronSignTransaction(
          _nativeTrxParams(toAddress: 'TDestAddr', ownerAddress: 'TOwner'),
        );
        expect(result.data!['to'], 'TDestAddr');
        expect(result.data!['to'], isNot(''));
      });
    });

    group('TRC-20 token transfer (TriggerSmartContract)', () {
      test('to = contract_address, not to_address', () {
        final result = processTronSignTransaction(
          _trc20Params(contractAddress: 'TContract'),
        );
        expect(result.success, isTrue);
        expect(result.data!['to'], 'TContract');
      });

      test('from = owner_address even for TRC-20', () {
        final result = processTronSignTransaction(
          _trc20Params(ownerAddress: 'TOwner20'),
        );
        expect(result.data!['from'], 'TOwner20');
      });
    });

    group('gas / fee_limit field', () {
      test('gas field is fee_limit as decimal string', () {
        final result = processTronSignTransaction(
          _nativeTrxParams(feeLimit: 2000000),
        );
        expect(result.data!['gas'], '2000000');
      });

      test('fee_limit=0 is valid and serialised as "0"', () {
        final result = processTronSignTransaction(
          _nativeTrxParams(feeLimit: 0),
        );
        expect(result.data!['gas'], '0');
      });

      test('large fee_limit does not overflow', () {
        final result = processTronSignTransaction(
          _nativeTrxParams(feeLimit: 1000000000),
        );
        expect(result.data!['gas'], '1000000000');
      });
    });

    group('data / raw_data_hex field', () {
      test('raw_data_hex is passed through verbatim', () {
        final result = processTronSignTransaction(
          _nativeTrxParams(rawDataHex: 'aabb1234'),
        );
        expect(result.data!['data'], 'aabb1234');
      });

      test('missing raw_data_hex defaults to empty string', () {
        final params = {
          'transaction': {
            'transaction': {
              'raw_data': {
                'contract': [
                  {
                    'type': 'TransferContract',
                    'parameter': {'value': <String, dynamic>{}},
                  },
                ],
                'fee_limit': 0,
              },
              // no raw_data_hex key
            },
          },
        };
        final result = processTronSignTransaction(params);
        expect(result.data!['data'], '');
      });
    });

    group('empty / missing fields fallback to empty string', () {
      test('missing owner_address => from=""', () {
        final params = {
          'transaction': {
            'transaction': {
              'raw_data': {
                'contract': [
                  {
                    'type': 'TransferContract',
                    'parameter': {
                      'value': {'to_address': 'TDest'},
                    },
                  },
                ],
                'fee_limit': 0,
              },
              'raw_data_hex': '',
            },
          },
        };
        final result = processTronSignTransaction(params);
        expect(result.data!['from'], '');
      });

      test('missing contract fields => to=""', () {
        final params = {
          'transaction': {
            'transaction': {
              'raw_data': {
                'contract': [
                  {
                    'type': 'TransferContract',
                    'parameter': {'value': <String, dynamic>{}},
                  },
                ],
                'fee_limit': 0,
              },
              'raw_data_hex': '',
            },
          },
        };
        final result = processTronSignTransaction(params);
        expect(result.data!['to'], '');
      });
    });

    group('contract as Map (non-List variant)', () {
      test('Map-shaped contract is parsed correctly', () {
        final params = {
          'transaction': {
            'transaction': {
              'raw_data': {
                'contract': {
                  'type': 'TransferContract',
                  'parameter': {
                    'value': {
                      'owner_address': 'TMapOwner',
                      'to_address': 'TMapDest',
                    },
                  },
                },
                'fee_limit': 500,
              },
              'raw_data_hex': 'mapdata',
            },
          },
        };
        final result = processTronSignTransaction(params);
        expect(result.success, isTrue);
        expect(result.data!['from'], 'TMapOwner');
        expect(result.data!['to'], 'TMapDest');
        expect(result.data!['gas'], '500');
      });
    });

    group('error handling', () {
      test('null params returns error', () {
        final result = processTronSignTransaction(null);
        expect(result.success, isFalse);
        expect(result.errorMsg, contains('missing params'));
      });

      test('non-Map params returns error', () {
        final result = processTronSignTransaction('invalid');
        expect(result.success, isFalse);
      });

      test('Map without "transaction" key returns error', () {
        final result = processTronSignTransaction({'foo': 'bar'});
        expect(result.success, isFalse);
        expect(result.errorMsg, contains('missing params'));
      });
    });

    test('signType is always "transaction"', () {
      final result = processTronSignTransaction(_nativeTrxParams());
      expect(result.data!['signType'], 'transaction');
    });
  });

  // ---------------------------------------------------------------------------
  group('tron_signMessage — routing to message branch', () {
    test('signType is "message"', () {
      final result = processTronSignMessage({
        'message': '0xHello',
        'address': 'TXyz1234',
      });
      expect(result['signType'], 'message');
    });

    test('from = address field', () {
      final result = processTronSignMessage({
        'message': 'data',
        'address': 'TSender',
      });
      expect(result['from'], 'TSender');
    });

    test('data = message field', () {
      final result = processTronSignMessage({
        'message': 'Hello TRON',
        'address': 'TXyz',
      });
      expect(result['data'], 'Hello TRON');
    });

    test('missing address falls back to empty string', () {
      final result = processTronSignMessage({'message': 'data'});
      expect(result['from'], '');
    });

    test('missing message falls back to empty string', () {
      final result = processTronSignMessage({'address': 'TAddr'});
      expect(result['data'], '');
    });
  });
}
