import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/proxy_config.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/models/transaction/explorer_response_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';

import 'discovered_token.dart';

// ─── Explorer configuration ──────────────────────────────────────────────────

class _Explorer {
  final String baseUrl;
  const _Explorer(this.baseUrl);
}

// ─── Token-discovery service ─────────────────────────────────────────────────

/// Scans EVM and Solana chains for tokens received by the wallet that are not
/// yet known.  Returns only tokens with a non-zero on-chain balance.
///
/// All errors are swallowed per-chain; a failed chain simply returns nothing.
class TokenDiscoveryService {
  // Explorer APIs indexed by internal coin type — now via proxy (no API key).
  static final Map<String, _Explorer> _evmExplorers = {
    'ETH': _Explorer(ProxyConfig.explorerTokentx('eth')),
    'BSC': _Explorer(ProxyConfig.explorerTokentx('bnb')),
    'MATIC': const _Explorer('https://api.polygonscan.com/api'),
    'ARBITRUM': const _Explorer('https://api.arbiscan.io/api'),
    'OPTIMISM': const _Explorer('https://api-optimistic.etherscan.io/api'),
    'BASE': _Explorer(ProxyConfig.explorerTokentx('base')),
    'AVAXC': const _Explorer('https://api.snowtrace.io/api'),
  };

  /// Solana Token program — owns all SPL token accounts.
  static const String _solTokenProgram =
      'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA';

  /// Lightweight Dio instance for Etherscan requests.
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );

  // ──────────────────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────────────────

  /// Scan multiple chains for unknown tokens.
  ///
  /// [addressByChain] maps internal coinType → wallet address.
  /// [knownContracts]  contract addresses already in the wallet (lower-cased).
  /// [ignoredContracts] contracts the user previously dismissed (lower-cased).
  ///
  /// Returns a deduplicated list of [DiscoveredToken] with non-zero balances,
  /// sorted by chain then symbol.
  static Future<List<DiscoveredToken>> scanAll({
    required Map<String, String?> addressByChain,
    required Set<String> knownContracts,
    required Set<String> ignoredContracts,
  }) async {
    final results = <DiscoveredToken>[];

    for (final entry in addressByChain.entries) {
      final coinType = entry.key;
      final address = entry.value;
      if (address == null || address.isEmpty) continue;

      try {
        List<DiscoveredToken> chainResult;
        if (coinType == 'SOL') {
          chainResult = await _scanSolana(address, knownContracts, ignoredContracts);
        } else if (_evmExplorers.containsKey(coinType)) {
          chainResult = await _scanEvm(
            coinType: coinType,
            address: address,
            knownContracts: knownContracts,
            ignoredContracts: ignoredContracts,
          );
        } else {
          continue; // non-EVM, non-SOL: skip
        }
        results.addAll(chainResult);
      } catch (e) {
        debugPrint('[TokenDiscovery] $coinType scan error: $e');
      }
    }

    // Sort: by coinType then by symbol for a predictable order.
    results.sort((a, b) {
      final ct = a.coinType.compareTo(b.coinType);
      if (ct != 0) return ct;
      return a.symbol.compareTo(b.symbol);
    });
    return results;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EVM scanning (Etherscan tokentx + eth_call balanceOf)
  // ──────────────────────────────────────────────────────────────────────────

  static Future<List<DiscoveredToken>> _scanEvm({
    required String coinType,
    required String address,
    required Set<String> knownContracts,
    required Set<String> ignoredContracts,
  }) async {
    final explorer = _evmExplorers[coinType]!;

    // 1. Fetch ERC-20 transfer history from Etherscan-compatible explorer.
    final params = <String, dynamic>{
      'address': address,
      if (!explorer.baseUrl.startsWith(ProxyConfig.baseUrl)) ...{
        'module': 'account',
        'action': 'tokentx',
        'sort': 'desc',
        'offset': '50', // last 50 transfers is plenty
      },
      'page': '1',
      if (explorer.baseUrl.startsWith(ProxyConfig.baseUrl)) 'size': '50',
    };

    final response = await _dio.get<Map<String, dynamic>>(
      explorer.baseUrl,
      queryParameters: params,
      options: Options(
        headers: ProxyConfig.mergeAuthHeaders(explorer.baseUrl, const {
          'Accept': 'application/json',
        }),
      ),
    );
    final body = response.data;
    if (body == null) {
      return [];
    }

    final txList = extractExplorerItems(body);
    if (txList.isEmpty) {
      return [];
    }

    // 2. Deduplicate unique contracts (preserve first occurrence).
    final seen = <String>{};
    final candidates = <_EvmCandidate>[];

    for (final normalized in txList) {
      final contract = (explorerString(
                normalized,
                const ['contractAddress', 'tokenAddr', 'token'],
              ) ??
              '')
          .toLowerCase();
      if (contract.isEmpty ||
          !seen.add(contract) ||
          knownContracts.contains(contract) ||
          ignoredContracts.contains(contract)) {
        continue;
      }

      candidates.add(_EvmCandidate(
        contract: explorerString(
              normalized,
              const ['contractAddress', 'tokenAddr', 'token'],
            ) ??
            '',
        symbol: explorerString(normalized, const ['tokenSymbol']) ?? '',
        name: explorerString(normalized, const ['tokenName']) ?? '',
        decimals: int.tryParse(
              explorerString(
                    normalized,
                    const ['tokenDecimal', 'tokenDecimals', 'decimals'],
                  ) ??
                  '0',
            ) ??
            0,
      ));
      if (candidates.length >= 30) break; // safety cap
    }

    if (candidates.isEmpty) return [];

    // 3. Verify non-zero on-chain balance in parallel (batches of 5).
    final results = <DiscoveredToken>[];
    for (var i = 0; i < candidates.length; i += 5) {
      final batch = candidates.sublist(i, min(i + 5, candidates.length));
      final futures = batch.map(
        (c) => _verifyEvmBalance(coinType: coinType, address: address, candidate: c),
      );
      final batchResults = await Future.wait(futures, eagerError: false);
      results.addAll(batchResults.nonNulls);
    }
    return results;
  }

  /// Call ERC-20 `balanceOf(address)` via eth_call and return a
  /// [DiscoveredToken] if the balance is non-zero, or null otherwise.
  static Future<DiscoveredToken?> _verifyEvmBalance({
    required String coinType,
    required String address,
    required _EvmCandidate candidate,
  }) async {
    try {
      // balanceOf(address) selector: 0x70a08231
      final stripped = address.replaceFirst(RegExp(r'^0x', caseSensitive: false), '').toLowerCase();
      final calldata = '0x70a08231${stripped.padLeft(64, '0')}';

      final result = await EthAPI()
          .baseRPCEth(
            'eth_call',
            [
              {'to': candidate.contract, 'data': calldata},
              'latest',
            ],
            coinType: coinType,
            enableRetry: false,
          )
          .timeout(const Duration(seconds: 6));

      if (!result.isSuccess) return null;
      final hex = result.valueOrNull?.toString() ?? '';
      if (!hex.startsWith('0x') || hex.length <= 2) return null;

      final balance = BigInt.tryParse(hex.substring(2), radix: 16) ?? BigInt.zero;
      if (balance == BigInt.zero) return null;

      return DiscoveredToken(
        coinType: coinType,
        blockchainType: 'Ethereum',
        contractAddress: candidate.contract,
        symbol: candidate.symbol,
        name: candidate.name,
        decimals: candidate.decimals,
        rawBalance: balance,
      );
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Solana scanning (getTokenAccountsByOwner)
  // ──────────────────────────────────────────────────────────────────────────

  static Future<List<DiscoveredToken>> _scanSolana(
    String address,
    Set<String> knownContracts,
    Set<String> ignoredContracts,
  ) async {
    final result = await SolApi()
        .baseRPCSol(
          'getTokenAccountsByOwner',
          [
            address,
            {'programId': _solTokenProgram},
            {'encoding': 'jsonParsed'},
          ],
          isTest: false,
        )
        .timeout(const Duration(seconds: 12));

    if (!result.isSuccess || result.valueOrNull == null) return [];

    final data = result.valueOrNull!;
    final accounts = data['value'] as List<dynamic>? ?? [];
    return accounts
        .map((a) => _parseSolanaAccount(a, knownContracts, ignoredContracts))
        .nonNulls
        .toList();
  }

  /// Parse a single Solana token account into a [DiscoveredToken], or null
  /// if it should be skipped (zero balance, already known, parse error).
  static DiscoveredToken? _parseSolanaAccount(
    dynamic account,
    Set<String> knownContracts,
    Set<String> ignoredContracts,
  ) {
    try {
      final parsed =
          account['account']['data']['parsed'] as Map<String, dynamic>?;
      if (parsed == null) return null;
      final info = parsed['info'] as Map<String, dynamic>? ?? {};

      final mint = info['mint'] as String? ?? '';
      if (mint.isEmpty) return null;
      if (knownContracts.contains(mint)) return null;
      if (ignoredContracts.contains(mint)) return null;

      final tokenAmount = info['tokenAmount'] as Map<String, dynamic>? ?? {};
      final amountStr = tokenAmount['amount'] as String? ?? '0';
      final decimals = (tokenAmount['decimals'] as num?)?.toInt() ?? 0;
      final balance = BigInt.tryParse(amountStr) ?? BigInt.zero;
      if (balance == BigInt.zero) return null;

      // SPL tokens don't embed metadata in token accounts.
      // The discovery UI shows the truncated mint address instead.
      return DiscoveredToken(
        coinType: 'SOL',
        blockchainType: 'Solana',
        contractAddress: mint,
        symbol: '',
        name: '',
        decimals: decimals,
        rawBalance: balance,
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── Internal helpers ─────────────────────────────────────────────────────────

class _EvmCandidate {
  final String contract;
  final String symbol;
  final String name;
  final int decimals;
  const _EvmCandidate({
    required this.contract,
    required this.symbol,
    required this.name,
    required this.decimals,
  });
}
