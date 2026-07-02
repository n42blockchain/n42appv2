// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:web3dart/web3dart.dart' show hexToBytes, bytesToHex;

/// Aave V3 lending protocol integration.
///
/// Provides direct in-wallet supply, borrow, repay, and withdraw operations
/// without redirecting to the DApp browser. Interacts with Aave V3 Pool
/// contracts on supported EVM chains.
///
/// Supported chains:
/// - Ethereum (Pool: 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2)
/// - Polygon (Pool: 0x794a61358D6845594F94dc1DB02A252b5b4814aD)
/// - Arbitrum (Pool: 0x794a61358D6845594F94dc1DB02A252b5b4814aD)
/// - Optimism (Pool: 0x794a61358D6845594F94dc1DB02A252b5b4814aD)
/// - Base (Pool: 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5)
/// - Avalanche (Pool: 0x794a61358D6845594F94dc1DB02A252b5b4814aD)
class AaveService {
  AaveService._();

  /// Aave V3 Pool contract addresses by chain ID.
  static const Map<int, String> poolAddresses = {
    1: '0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2', // Ethereum
    137: '0x794a61358D6845594F94dc1DB02A252b5b4814aD', // Polygon
    42161: '0x794a61358D6845594F94dc1DB02A252b5b4814aD', // Arbitrum
    10: '0x794a61358D6845594F94dc1DB02A252b5b4814aD', // Optimism
    8453: '0xA238Dd80C259a72e81d7e4664a9801593F98d1c5', // Base
    43114: '0x794a61358D6845594F94dc1DB02A252b5b4814aD', // Avalanche
  };

  /// Aave V3 UI Pool Data Provider addresses (for reading reserve data).
  static const Map<int, String> uiDataProviderAddresses = {
    1: '0x91c0eA31b49B69Ea18607702c5d9aC360bf3dE7d',
    137: '0xC69728f11E9E6127733751c8410432913123acF1',
    42161: '0x145dE30c929a065582da84Cf96F88460dB9745A7',
    10: '0xbd83DdBE37fc91923d59C8c1E0bDe0CccCa332d5',
    8453: '0x174446a6741300cD2E7C1b1A636Fee99c8F83502',
    43114: '0xF71DBe0FAEF1473ffC607d4c555dfF0aEaDb878d',
  };

  /// Maximum uint256 for "max" operations.
  static final BigInt maxUint256 = BigInt.parse(
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
    radix: 16,
  );

  /// Check if Aave V3 is available on a chain.
  static bool isAvailable(int chainId) => poolAddresses.containsKey(chainId);

  /// Get the pool address for a chain.
  static String? getPoolAddress(int chainId) => poolAddresses[chainId];

  // ==================== Transaction Builders ====================

  /// Build calldata to supply (deposit) an asset to Aave V3.
  ///
  /// function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode)
  static Uint8List buildSupplyCalldata({
    required String asset,
    required BigInt amount,
    required String onBehalfOf,
    int referralCode = 0,
  }) {
    // selector: supply(address,uint256,address,uint16)
    final selector = hexToBytes('617ba037');
    final result = Uint8List(4 + 4 * 32);
    result.setAll(0, selector);
    _writeAddress(result, 4, asset);
    _writeUint256(result, 36, amount);
    _writeAddress(result, 68, onBehalfOf);
    _writeUint256(result, 100, BigInt.from(referralCode));
    return result;
  }

  /// Build calldata to withdraw an asset from Aave V3.
  ///
  /// function withdraw(address asset, uint256 amount, address to)
  /// Use [maxUint256] for amount to withdraw all.
  static Uint8List buildWithdrawCalldata({
    required String asset,
    required BigInt amount,
    required String to,
  }) {
    final selector = hexToBytes('69328dec');
    final result = Uint8List(4 + 3 * 32);
    result.setAll(0, selector);
    _writeAddress(result, 4, asset);
    _writeUint256(result, 36, amount);
    _writeAddress(result, 68, to);
    return result;
  }

  /// Build calldata to borrow an asset from Aave V3.
  ///
  /// function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)
  /// interestRateMode: 1 = stable (deprecated on most), 2 = variable
  static Uint8List buildBorrowCalldata({
    required String asset,
    required BigInt amount,
    required String onBehalfOf,
    int interestRateMode = 2, // variable
    int referralCode = 0,
  }) {
    final selector = hexToBytes('a415bcad');
    final result = Uint8List(4 + 5 * 32);
    result.setAll(0, selector);
    _writeAddress(result, 4, asset);
    _writeUint256(result, 36, amount);
    _writeUint256(result, 68, BigInt.from(interestRateMode));
    _writeUint256(result, 100, BigInt.from(referralCode));
    _writeAddress(result, 132, onBehalfOf);
    return result;
  }

  /// Build calldata to repay a borrow on Aave V3.
  ///
  /// function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf)
  /// Use [maxUint256] for amount to repay all.
  static Uint8List buildRepayCalldata({
    required String asset,
    required BigInt amount,
    required String onBehalfOf,
    int interestRateMode = 2,
  }) {
    final selector = hexToBytes('573ade81');
    final result = Uint8List(4 + 4 * 32);
    result.setAll(0, selector);
    _writeAddress(result, 4, asset);
    _writeUint256(result, 36, amount);
    _writeUint256(result, 68, BigInt.from(interestRateMode));
    _writeAddress(result, 100, onBehalfOf);
    return result;
  }

  /// Build ERC-20 approve calldata (needed before supply/repay).
  ///
  /// function approve(address spender, uint256 amount)
  static Uint8List buildApproveCalldata({
    required String spender,
    required BigInt amount,
  }) {
    final selector = hexToBytes('095ea7b3');
    final result = Uint8List(4 + 2 * 32);
    result.setAll(0, selector);
    _writeAddress(result, 4, spender);
    _writeUint256(result, 36, amount);
    return result;
  }

  /// Check current ERC-20 allowance for `owner -> spender` on [tokenAddr]
  /// via `eth_call`. Returns [BigInt.zero] on any error — callers treat
  /// that as "needs approval", which is the safe default.
  static Future<BigInt> checkAllowance({
    required String coinType,
    required String tokenAddr,
    required String owner,
    required String spender,
  }) async {
    try {
      // allowance(address,address) selector: 0xdd62ed3e
      final selector = hexToBytes('dd62ed3e');
      final callData = Uint8List(4 + 2 * 32);
      callData.setAll(0, selector);
      _writeAddress(callData, 4, owner);
      _writeAddress(callData, 36, spender);
      final dataHex = '0x${bytesToHex(callData)}';

      final result = await EthAPI()
          .baseRPCEth(
            'eth_call',
            [
              {'to': tokenAddr, 'data': dataHex},
              'latest',
            ],
            coinType: coinType,
            enableRetry: false,
          )
          .timeout(const Duration(seconds: 6));

      if (result.isSuccess) {
        final hex = result.valueOrNull?.toString() ?? '';
        if (hex.startsWith('0x') && hex.length > 2) {
          return BigInt.parse(hex.substring(2), radix: 16);
        }
      }
      return BigInt.zero;
    } catch (e) {
      AppLogger.w('AaveService', 'checkAllowance error: $e');
      return BigInt.zero;
    }
  }

  // ==================== Data Models ====================

  /// Aave's official public GraphQL API (api.v3.aave.com) — no API key
  /// required. Replaces the old `api.thegraph.com/subgraphs/name/...`
  /// hosted-service URL, which TheGraph decommissioned (now 301s to
  /// error.thegraph.com) — that endpoint silently returned zero reserves
  /// in production, making the whole Supply/Borrow list permanently empty.
  static const String _graphApiUrl = 'https://api.v3.aave.com/graphql';

  /// Fetch reserve data for [chainId] from Aave's official GraphQL API.
  static Future<List<AaveReserve>> getReserves(int chainId) async {
    final poolAddress = poolAddresses[chainId];
    if (poolAddress == null) return [];

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.post(
        _graphApiUrl,
        data: {
          'query': '''
          query MarketReserves(\$chainId: ChainId!, \$address: EvmAddress!) {
            market(request: { chainId: \$chainId, address: \$address }) {
              reserves {
                underlyingToken { address symbol name decimals }
                size { usd }
                supplyInfo { apy { value } }
                borrowInfo {
                  apy { value }
                  total { usd }
                  availableLiquidity { usd }
                }
              }
            }
          }
        ''',
          'variables': {'chainId': chainId, 'address': poolAddress},
        },
      );

      final reserves =
          response.data['data']?['market']?['reserves'] as List<dynamic>?;
      if (reserves == null) return [];

      return reserves
          .map((r) => AaveReserve.fromGraphApi(r as Map<String, dynamic>))
          .where((r) => r.symbol.isNotEmpty)
          .toList()
        ..sort((a, b) => b.totalLiquidityUsd.compareTo(a.totalLiquidityUsd));
    } catch (e) {
      AppLogger.w('AaveService', 'reserves error: $e');
      return [];
    }
  }

  static void _writeAddress(Uint8List buffer, int offset, String address) {
    final hex = address.replaceFirst('0x', '').padLeft(64, '0');
    final bytes = hexToBytes(hex);
    buffer.setAll(offset, bytes);
  }

  static void _writeUint256(Uint8List buffer, int offset, BigInt value) {
    var v = value;
    for (var i = 31; i >= 0; i--) {
      buffer[offset + i] = (v & BigInt.from(0xFF)).toInt();
      v >>= 8;
    }
  }
}

/// Aave V3 reserve (market) data.
class AaveReserve {
  final String symbol;
  final String name;
  final String underlyingAsset;
  final double supplyApy;
  final double borrowApy;
  final double totalLiquidityUsd;
  final double availableLiquidityUsd;
  final double totalBorrowedUsd;
  final int decimals;

  AaveReserve({
    required this.symbol,
    required this.name,
    required this.underlyingAsset,
    required this.supplyApy,
    required this.borrowApy,
    required this.totalLiquidityUsd,
    required this.availableLiquidityUsd,
    required this.totalBorrowedUsd,
    required this.decimals,
  });

  /// Parse a `Reserve` object returned by Aave's official GraphQL API
  /// (api.v3.aave.com). `apy.value` fields are raw fractions (0.03 = 3%).
  factory AaveReserve.fromGraphApi(Map<String, dynamic> json) {
    final token = json['underlyingToken'] as Map<String, dynamic>? ?? {};
    final supplyInfo = json['supplyInfo'] as Map<String, dynamic>?;
    final borrowInfo = json['borrowInfo'] as Map<String, dynamic>?;

    double apyOf(Map<String, dynamic>? info) {
      final apy = info?['apy'] as Map<String, dynamic>?;
      return (double.tryParse(apy?['value']?.toString() ?? '0') ?? 0) * 100;
    }

    double usdOf(Map<String, dynamic>? node) =>
        double.tryParse(node?['usd']?.toString() ?? '0') ?? 0;

    return AaveReserve(
      symbol: token['symbol'] as String? ?? '',
      name: token['name'] as String? ?? '',
      underlyingAsset: token['address'] as String? ?? '',
      supplyApy: apyOf(supplyInfo),
      borrowApy: apyOf(borrowInfo),
      totalLiquidityUsd: usdOf(json['size'] as Map<String, dynamic>?),
      availableLiquidityUsd: usdOf(
        borrowInfo?['availableLiquidity'] as Map<String, dynamic>?,
      ),
      totalBorrowedUsd: usdOf(borrowInfo?['total'] as Map<String, dynamic>?),
      decimals: token['decimals'] as int? ?? 18,
    );
  }
}
