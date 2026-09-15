// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Contract tests for CoinConfigView. The view must:
//   - Never throw on missing keys (return typed defaults).
//   - Coerce String numerics into int/double (chain config stores some
//     numbers as strings, e.g. balance / chainId from market APIs).
//   - Round-trip the underlying map without mutation (the view is a
//     non-owning overlay; callers may still rely on `cm.coin` being the
//     same map reference).
//   - Preserve the CoinModel.config extension contract.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';

void main() {
  group('CoinConfigView identity fields', () {
    test('reads the canonical chain-config baseInfo shape', () {
      final view = CoinConfigView(const {
        'mKey': 'N',
        'blockchainType': 'Ethereum',
        'coinType': 'N',
        'name': 'N42',
        'miniName': 'N',
        'unit': 'N',
        'decimals': 18,
      });

      expect(view.mKey, 'N');
      expect(view.blockchainType, 'Ethereum');
      expect(view.coinType, 'N');
      expect(view.name, 'N42');
      expect(view.miniName, 'N');
      expect(view.unit, 'N');
      expect(view.decimals, 18);
    });

    test('returns empty strings for missing string keys', () {
      const view = CoinConfigView({});
      expect(view.coinType, '');
      expect(view.name, '');
      expect(view.miniName, '');
      expect(view.unit, '');
      expect(view.symbol, '');
      expect(view.mKey, '');
      expect(view.blockchainType, '');
    });
  });

  group('CoinConfigView numerics', () {
    test('decimals accepts num and falls back to legacy "decimal" key', () {
      expect(const CoinConfigView({'decimals': 18}).decimals, 18);
      expect(const CoinConfigView({'decimal': 6}).decimals, 6);
      expect(const CoinConfigView({}).decimals, 0);
    });

    test('decimals coerces String to int', () {
      expect(const CoinConfigView({'decimals': '8'}).decimals, 8);
    });

    test('chainId and chainIdTest default to 0', () {
      const view = CoinConfigView({});
      expect(view.chainId, 0);
      expect(view.chainIdTest, 0);
    });

    test('chainId reads int from chain config', () {
      const view = CoinConfigView({'chainId': 94, 'chainId_test': 1142});
      expect(view.chainId, 94);
      expect(view.chainIdTest, 1142);
    });

    test(
      'coinPrice falls back to market "price" key when coinPrice absent',
      () {
        expect(const CoinConfigView({'coinPrice': 1.5}).coinPrice, 1.5);
        expect(const CoinConfigView({'price': 2.5}).coinPrice, 2.5);
        expect(const CoinConfigView({}).coinPrice, 0);
      },
    );

    test('coinPrice handles String numerics from market APIs', () {
      expect(const CoinConfigView({'price': '1.23'}).coinPrice, 1.23);
    });

    test('percentage defaults to 0', () {
      expect(const CoinConfigView({}).percentage, 0);
      expect(const CoinConfigView({'percentage': -2.5}).percentage, -2.5);
    });
  });

  group('CoinConfigView flags', () {
    test('isContract defaults to false', () {
      expect(const CoinConfigView({}).isContract, false);
      expect(const CoinConfigView({'isContract': true}).isContract, true);
    });

    test('canEdit / custom / isAggregated default to false', () {
      const view = CoinConfigView({});
      expect(view.canEdit, false);
      expect(view.custom, false);
      expect(view.isAggregated, false);
    });

    test('non-bool flag values are not coerced (typed contract)', () {
      // Legacy maps occasionally pass 1/0 — the view returns false to
      // surface the type confusion rather than silently coerce.
      expect(const CoinConfigView({'isContract': 1}).isContract, false);
      expect(const CoinConfigView({'isContract': 'true'}).isContract, false);
    });
  });

  group('CoinConfigView network endpoints', () {
    test('reads service / service_test', () {
      const view = CoinConfigView({
        'service': 'https://rpc.n42.world',
        'service_test': 'https://testrpc.n42.world',
      });
      expect(view.service, 'https://rpc.n42.world');
      expect(view.serviceTest, 'https://testrpc.n42.world');
    });

    test('contract / contract_test default to empty', () {
      const view = CoinConfigView({});
      expect(view.contract, '');
      expect(view.contractTest, '');
    });
  });

  group('CoinConfigView HD derivation paths', () {
    test('pathMap reads typed map', () {
      const view = CoinConfigView({
        'path': {'legacy': "m/44'/60'/0'/0/0", 'segwit': "m/49'/0'/0'/0/0"},
      });
      expect(view.pathMap, {
        'legacy': "m/44'/60'/0'/0/0",
        'segwit': "m/49'/0'/0'/0/0",
      });
      expect(view.pathForAddrType('legacy'), "m/44'/60'/0'/0/0");
      expect(view.pathForAddrType('segwit'), "m/49'/0'/0'/0/0");
    });

    test('pathMap returns null when path key missing', () {
      const view = CoinConfigView({});
      expect(view.pathMap, isNull);
      expect(view.pathForAddrType('legacy'), isNull);
    });

    test('pathForAddrType returns null for unregistered addrType', () {
      const view = CoinConfigView({
        'path': {'legacy': "m/44'/60'/0'/0/0"},
      });
      expect(view.pathForAddrType('segwit'), isNull);
    });

    test('pathMap returns null when path is not a Map', () {
      const view = CoinConfigView({'path': 'not-a-map'});
      expect(view.pathMap, isNull);
    });
  });

  group('CoinConfigView escape hatch', () {
    test('operator [] returns raw value for arbitrary keys', () {
      const view = CoinConfigView({'totally_custom_key': 42});
      expect(view['totally_custom_key'], 42);
      expect(view['absent_key'], isNull);
    });

    test('contains reflects underlying map', () {
      const view = CoinConfigView({'a': 1, 'b': null});
      expect(view.contains('a'), true);
      expect(view.contains('b'), true);
      expect(view.contains('c'), false);
    });
  });

  group('CoinConfigView is non-owning', () {
    test('raw is the same map reference passed in', () {
      final map = <String, dynamic>{'coinType': 'N'};
      final view = CoinConfigView(map);
      expect(identical(view.raw, map), isTrue);
    });

    test('mutating raw map after construction is visible through view', () {
      final map = <String, dynamic>{'coinType': 'N'};
      final view = CoinConfigView(map);
      expect(view.coinType, 'N');

      map['coinType'] = 'BTC';
      expect(view.coinType, 'BTC');
    });
  });

  group('CoinModelConfigViewExt', () {
    test('CoinModel.config exposes typed view over .coin', () {
      final cm = CoinModel.fromMap({
        'coinType': 'BTC',
        'name': 'Bitcoin',
        'decimals': 8,
        'isContract': false,
      });

      expect(cm.config.coinType, 'BTC');
      expect(cm.config.name, 'Bitcoin');
      expect(cm.config.decimals, 8);
      expect(cm.config.isContract, false);

      // The extension is a fresh view per access — but both views must
      // observe the same backing map.
      expect(identical(cm.config.raw, cm.coin), isTrue);
    });

    test('CoinModel.config reflects later cm.coin updates', () {
      final cm = CoinModel.fromMap({'coinType': 'N'});
      expect(cm.config.coinType, 'N');

      cm.coin = {'coinType': 'BTC'};
      expect(cm.config.coinType, 'BTC');
    });
  });
}
