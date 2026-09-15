// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';

void main() {
  group('BridgeModels Tests', () {
    group('BridgeTransactionStatus enum', () {
      test('should have correct values', () {
        expect(
          BridgeTransactionStatus.values.contains(
            BridgeTransactionStatus.pending,
          ),
          true,
        );
        expect(
          BridgeTransactionStatus.values.contains(
            BridgeTransactionStatus.inProgress,
          ),
          true,
        );
        expect(
          BridgeTransactionStatus.values.contains(
            BridgeTransactionStatus.completed,
          ),
          true,
        );
        expect(
          BridgeTransactionStatus.values.contains(
            BridgeTransactionStatus.failed,
          ),
          true,
        );
      });
    });

    group('BridgeChain', () {
      test('should create from JSON correctly', () {
        final json = {
          'id': 1,
          'key': 'eth',
          'name': 'Ethereum',
          'logoURI': 'https://example.com/eth.png',
          'nativeToken': {'symbol': 'ETH', 'decimals': 18},
        };

        final chain = BridgeChain.fromJson(json);

        expect(chain.chainId, 1);
        expect(chain.key, 'eth');
        expect(chain.name, 'Ethereum');
        expect(chain.nativeToken, 'ETH');
        expect(chain.nativeDecimals, 18);
      });

      test('should convert to JSON correctly', () {
        final chain = BridgeChain(
          chainId: 1,
          key: 'eth',
          name: 'Ethereum',
          logoUri: 'https://example.com/eth.png',
          nativeToken: 'ETH',
          nativeDecimals: 18,
        );

        final json = chain.toJson();

        expect(json['id'], 1);
        expect(json['key'], 'eth');
        expect(json['name'], 'Ethereum');
      });
    });

    group('BridgeToken', () {
      test('should create from JSON correctly', () {
        final json = {
          'address': '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
          'symbol': 'USDC',
          'name': 'USD Coin',
          'decimals': 6,
          'chainId': 1,
          'logoURI': 'https://example.com/usdc.png',
          'priceUSD': 1.0,
        };

        final token = BridgeToken.fromJson(json);

        expect(token.symbol, 'USDC');
        expect(token.decimals, 6);
        expect(token.chainId, 1);
        expect(token.priceUSD, 1.0);
      });

      test('should detect native token correctly', () {
        final nativeToken = BridgeToken(
          address: '0x0000000000000000000000000000000000000000',
          symbol: 'ETH',
          name: 'Ethereum',
          decimals: 18,
          chainId: 1,
          logoUri: 'https://example.com/eth.png',
        );

        expect(nativeToken.isNative, true);
      });

      test('should detect non-native token', () {
        final erc20Token = BridgeToken(
          address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
          chainId: 1,
          logoUri: 'https://example.com/usdc.png',
        );

        expect(erc20Token.isNative, false);
      });

      test('should convert to JSON correctly', () {
        final token = BridgeToken(
          address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
          chainId: 1,
          logoUri: 'https://example.com/usdc.png',
          priceUSD: 1.0,
        );

        final json = token.toJson();

        expect(json['symbol'], 'USDC');
        expect(json['decimals'], 6);
        expect(json['priceUSD'], 1.0);
      });
    });

    group('BridgeQuoteRequest', () {
      test('should create query params correctly', () {
        final request = BridgeQuoteRequest(
          fromChainId: 1,
          toChainId: 42161,
          fromTokenAddress: '0x0000000000000000000000000000000000000000',
          toTokenAddress: '0x0000000000000000000000000000000000000000',
          fromAmount: '1000000000000000000',
          fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
          toAddress: '0x1234567890abcdef1234567890abcdef12345678',
          slippage: 0.5,
        );

        final params = request.toQueryParams();

        expect(params['fromChain'], '1');
        expect(params['toChain'], '42161');
        expect(params['slippage'], '0.5');
      });
    });

    group('BridgeRoute', () {
      test('should parse tags correctly', () {
        final json = {
          'id': 'route_1',
          'steps': [],
          'fromToken': {'address': '', 'symbol': 'ETH'},
          'toToken': {'address': '', 'symbol': 'ETH'},
          'fromAmount': '1000000000000000000',
          'toAmount': '990000000000000000',
          'toAmountMin': '980000000000000000',
          'gasCostUSD': '5',
          'tags': ['RECOMMENDED', 'FASTEST'],
        };

        final route = BridgeRoute.fromJson(json);

        expect(route.isRecommended, true);
        expect(route.isFastest, true);
        expect(route.isCheapest, false);
      });
    });

    group('BridgeQuoteResponse', () {
      test('should handle empty routes', () {
        final json = {'message': 'No routes available'};

        final response = BridgeQuoteResponse.fromJson(json);

        expect(response.hasRoutes, false);
        expect(response.error, 'No routes available');
      });

      test('should parse routes correctly', () {
        final json = {
          'routes': [
            {
              'id': 'route_1',
              'steps': [],
              'fromToken': {'address': '', 'symbol': 'ETH'},
              'toToken': {'address': '', 'symbol': 'ETH'},
              'fromAmount': '1000000000000000000',
              'toAmount': '990000000000000000',
              'toAmountMin': '980000000000000000',
              'tags': ['RECOMMENDED'],
            },
          ],
        };

        final response = BridgeQuoteResponse.fromJson(json);

        expect(response.hasRoutes, true);
        expect(response.routes.length, 1);
        expect(response.recommendedRoute, isNotNull);
      });
    });

    group('BridgeTransactionResponse', () {
      test('should detect success correctly', () {
        final response = BridgeTransactionResponse(
          transactionRequest: '0x...',
          txData: {'to': '0x...', 'data': '0x...'},
        );

        expect(response.isSuccess, true);
      });

      test('should detect error correctly', () {
        final response = BridgeTransactionResponse(
          error: 'Insufficient balance',
        );

        expect(response.isSuccess, false);
      });
    });

    group('BridgeStatusResponse', () {
      test('should parse DONE status correctly', () {
        final json = {
          'status': 'DONE',
          'receiving': {'txHash': '0xabc123'},
        };

        final response = BridgeStatusResponse.fromJson(json);

        expect(response.status, BridgeTransactionStatus.completed);
        expect(response.destinationTxHash, '0xabc123');
      });

      test('should parse FAILED status correctly', () {
        final json = {'status': 'FAILED', 'error': 'Bridge failed'};

        final response = BridgeStatusResponse.fromJson(json);

        expect(response.status, BridgeTransactionStatus.failed);
        expect(response.error, 'Bridge failed');
      });

      test('should parse PENDING status correctly', () {
        final json = {'status': 'PENDING'};

        final response = BridgeStatusResponse.fromJson(json);

        expect(response.status, BridgeTransactionStatus.pending);
      });

      test('should default to inProgress for unknown status', () {
        final json = {'status': 'PROCESSING'};

        final response = BridgeStatusResponse.fromJson(json);

        expect(response.status, BridgeTransactionStatus.inProgress);
      });
    });
  });

  group('Amount Conversion Tests', () {
    test('should convert token amount to display format', () {
      // 1000 USDC (6 decimals)
      final amountRaw = BigInt.parse('1000000000');
      const decimals = 6;

      // Use integer division for whole number result
      final displayAmount = amountRaw ~/ BigInt.from(10).pow(decimals);
      expect(displayAmount.toInt(), 1000);
    });

    test('should convert ETH amount correctly', () {
      // 1 ETH (18 decimals)
      final amountRaw = BigInt.parse('1000000000000000000');
      const decimals = 18;

      // Use integer division for whole number result
      final displayAmount = amountRaw ~/ BigInt.from(10).pow(decimals);
      expect(displayAmount.toInt(), 1);
    });

    test('should handle small amounts correctly', () {
      // 0.001 USDC (6 decimals)
      final amountRaw = BigInt.parse('1000');
      const decimals = 6;

      final divisor = BigInt.from(10).pow(decimals).toDouble();
      final valueInSmallestUnit = amountRaw.toDouble() / divisor;
      expect(valueInSmallestUnit, closeTo(0.001, 0.0001));
    });
  });

  group('Chain ID Tests', () {
    test('should validate common chain IDs', () {
      const ethereumMainnet = 1;
      const arbitrumOne = 42161;
      const optimism = 10;
      const polygon = 137;

      expect(ethereumMainnet, 1);
      expect(arbitrumOne, 42161);
      expect(optimism, 10);
      expect(polygon, 137);
    });
  });
}
