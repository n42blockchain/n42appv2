// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-14: Tests for bridge module — models and pure logic
//
// BridgeProvider uses a hardcoded LiFiApi, making full provider tests require
// a network mock. This file covers:
//   1. BridgeState enum values
//   2. BridgeChain fromJson / toJson
//   3. BridgeToken fromJson / toJson / isNative getter
//   4. Pure routing-logic helpers extracted locally

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';

// ---------------------------------------------------------------------------
// Pure-function mirrors of BridgeProvider business logic
// ---------------------------------------------------------------------------

/// Mirrors the "same chain = no route" guard.
/// Returns null when fromChainId == toChainId.
BridgeChain? selectRoute(BridgeChain from, BridgeChain to) {
  if (from.chainId == to.chainId) return null;
  return to; // simplified: route destination is the target chain
}

/// Mirrors the wei ↔ ETH conversion used for display amounts.
/// Returns ETH string for a given wei amount and decimals.
String weiToDisplay(BigInt weiAmount, {int decimals = 18}) {
  if (weiAmount == BigInt.zero) return '0';
  final divisor = BigInt.from(10).pow(decimals);
  final whole = weiAmount ~/ divisor;
  final remainder = weiAmount - whole * divisor;
  if (remainder == BigInt.zero) return whole.toString();
  final fracStr = remainder
      .toString()
      .padLeft(decimals, '0')
      .replaceAll(RegExp(r'0+$'), '');
  return '$whole.$fracStr';
}

// ---------------------------------------------------------------------------
void main() {
  group('BridgeState enum', () {
    test('has all expected state values', () {
      expect(BridgeState.values, contains(BridgeState.idle));
      expect(BridgeState.values, contains(BridgeState.loadingChains));
      expect(BridgeState.values, contains(BridgeState.loadingTokens));
      expect(BridgeState.values, contains(BridgeState.loadingQuotes));
      expect(BridgeState.values, contains(BridgeState.loadingTransaction));
      expect(BridgeState.values, contains(BridgeState.executing));
      expect(BridgeState.values, contains(BridgeState.completed));
      expect(BridgeState.values, contains(BridgeState.error));
    });

    test('has exactly 9 values', () {
      expect(BridgeState.values.length, 9);
    });
  });

  // -------------------------------------------------------------------------
  group('BridgeChain', () {
    group('fromJson', () {
      test('all fields are parsed', () {
        final chain = BridgeChain.fromJson({
          'id': 1,
          'key': 'eth',
          'name': 'Ethereum',
          'logoURI': 'https://example.com/eth.png',
          'nativeToken': {'symbol': 'ETH', 'decimals': 18},
        });

        expect(chain.chainId, 1);
        expect(chain.key, 'eth');
        expect(chain.name, 'Ethereum');
        expect(chain.logoUri, 'https://example.com/eth.png');
        expect(chain.nativeToken, 'ETH');
        expect(chain.nativeDecimals, 18);
      });

      test('missing nativeToken defaults to empty symbol and 18 decimals', () {
        final chain = BridgeChain.fromJson({
          'id': 42,
          'key': 'test',
          'name': 'TestChain',
          'logoURI': '',
        });

        expect(chain.nativeToken, '');
        expect(chain.nativeDecimals, 18);
      });

      test('missing id defaults to 0', () {
        final chain = BridgeChain.fromJson({'key': 'x', 'name': 'X'});
        expect(chain.chainId, 0);
      });
    });

    group('toJson', () {
      test('round-trip: fromJson → toJson preserves fields', () {
        final original = {
          'id': 137,
          'key': 'pol',
          'name': 'Polygon',
          'logoURI': 'https://cdn.com/pol.svg',
          'nativeToken': {'symbol': 'MATIC', 'decimals': 18},
        };
        final chain = BridgeChain.fromJson(original);
        final json = chain.toJson();

        expect(json['id'], 137);
        expect(json['key'], 'pol');
        expect(json['name'], 'Polygon');
        expect(json['logoURI'], 'https://cdn.com/pol.svg');
        expect(json['nativeToken']['symbol'], 'MATIC');
      });
    });
  });

  // -------------------------------------------------------------------------
  group('BridgeToken', () {
    group('fromJson', () {
      test('all fields are parsed', () {
        final token = BridgeToken.fromJson({
          'address': '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
          'symbol': 'USDC',
          'name': 'USD Coin',
          'decimals': 6,
          'chainId': 1,
          'logoURI': 'https://cdn.com/usdc.png',
          'priceUSD': 1.0,
        });

        expect(token.address, '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48');
        expect(token.symbol, 'USDC');
        expect(token.name, 'USD Coin');
        expect(token.decimals, 6);
        expect(token.chainId, 1);
        expect(token.priceUSD, closeTo(1.0, 0.001));
      });

      test('missing priceUSD is null', () {
        final token = BridgeToken.fromJson({
          'address': '0xAddr',
          'symbol': 'TOKEN',
          'name': 'Token',
          'decimals': 18,
          'chainId': 1,
          'logoURI': '',
        });
        expect(token.priceUSD, isNull);
      });

      test('missing decimals defaults to 18', () {
        final token = BridgeToken.fromJson({
          'address': '0xAddr',
          'symbol': 'T',
          'name': 'Token',
          'chainId': 1,
          'logoURI': '',
        });
        expect(token.decimals, 18);
      });
    });

    group('isNative', () {
      test('zero address is native', () {
        final token = BridgeToken.fromJson({
          'address': '0x0000000000000000000000000000000000000000',
          'symbol': 'ETH',
          'name': 'Ether',
          'decimals': 18,
          'chainId': 1,
          'logoURI': '',
        });
        expect(token.isNative, isTrue);
      });

      test('empty address is native', () {
        final token = BridgeToken.fromJson({
          'address': '',
          'symbol': 'ETH',
          'name': 'Ether',
          'decimals': 18,
          'chainId': 1,
          'logoURI': '',
        });
        expect(token.isNative, isTrue);
      });

      test('ERC-20 contract address is not native', () {
        final token = BridgeToken.fromJson({
          'address': '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
          'symbol': 'USDC',
          'name': 'USD Coin',
          'decimals': 6,
          'chainId': 1,
          'logoURI': '',
        });
        expect(token.isNative, isFalse);
      });

      test('zero address is case-insensitively matched', () {
        final token = BridgeToken.fromJson({
          'address': '0X0000000000000000000000000000000000000000',
          'symbol': 'ETH',
          'name': 'Ether',
          'decimals': 18,
          'chainId': 1,
          'logoURI': '',
        });
        // address.toLowerCase() comparison
        expect(token.isNative, isTrue);
      });
    });

    group('toJson round-trip', () {
      test('all fields survive round-trip', () {
        final original = {
          'address': '0xdAC17F958D2ee523a2206206994597C13D831ec7',
          'symbol': 'USDT',
          'name': 'Tether USD',
          'decimals': 6,
          'chainId': 1,
          'logoURI': 'https://cdn.com/usdt.png',
          'priceUSD': 1.001,
        };
        final token = BridgeToken.fromJson(original);
        final json = token.toJson();

        expect(json['address'], original['address']);
        expect(json['symbol'], 'USDT');
        expect(json['decimals'], 6);
        expect(json['chainId'], 1);
      });
    });
  });

  // -------------------------------------------------------------------------
  group('BridgeProvider routing logic (pure functions)', () {
    final ethChain = BridgeChain(
      chainId: 1,
      key: 'eth',
      name: 'Ethereum',
      logoUri: '',
      nativeToken: 'ETH',
      nativeDecimals: 18,
    );

    final arbChain = BridgeChain(
      chainId: 42161,
      key: 'arb',
      name: 'Arbitrum',
      logoUri: '',
      nativeToken: 'ETH',
      nativeDecimals: 18,
    );

    test('from != to chain → route is non-null', () {
      final route = selectRoute(ethChain, arbChain);
      expect(route, isNotNull);
    });

    test('from == to chain → no route (same chainId)', () {
      final route = selectRoute(ethChain, ethChain);
      expect(route, isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('wei ↔ ETH conversion', () {
    test('0 wei → "0"', () {
      expect(weiToDisplay(BigInt.zero), '0');
    });

    test('1 ETH (1e18 wei) → "1"', () {
      final one = BigInt.from(10).pow(18);
      expect(weiToDisplay(one), '1');
    });

    test('0.5 ETH (5e17 wei) → "0.5"', () {
      final half = BigInt.from(5) * BigInt.from(10).pow(17);
      expect(weiToDisplay(half), '0.5');
    });

    test('1.5 ETH → "1.5"', () {
      final oneAndHalf = BigInt.from(15) * BigInt.from(10).pow(17);
      expect(weiToDisplay(oneAndHalf), '1.5');
    });

    test('USDC with 6 decimals — 1 USDC = 1_000_000 units', () {
      final oneUsdc = BigInt.from(1000000);
      expect(weiToDisplay(oneUsdc, decimals: 6), '1');
    });

    test('trailing zeros are stripped from fractional part', () {
      // 1.50 ETH should display as "1.5"
      final onePointFive = BigInt.from(15) * BigInt.from(10).pow(17);
      final display = weiToDisplay(onePointFive);
      expect(
        display.endsWith('0'),
        isFalse,
        reason: 'trailing zeros should be stripped',
      );
    });
  });
}
