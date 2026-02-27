import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/config/api_keys_config.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';

import 'discovered_token.dart';

// ─── Explorer configuration ──────────────────────────────────────────────────

class _Explorer {
  final String baseUrl;
  final String apiKey;
  const _Explorer(this.baseUrl, this.apiKey);
}

// ─── Token-discovery service ─────────────────────────────────────────────────

/// Scans EVM and Solana chains for tokens received by the wallet that are not
/// yet known.  Returns only tokens with a non-zero on-chain balance.
///
/// All errors are swallowed per-chain; a failed chain simply returns nothing.
class TokenDiscoveryService {
  // Etherscan-compatible explorer APIs indexed by internal coin type.
  static const Map<String, _Explorer> _evmExplorers = {
    'ETH': _Explorer(
      'https://api.etherscan.io/api',
      ApiKeysConfig.etherscan,
    ),
    'BSC': _Explorer(
      'https://api.bscscan.com/api',
      ApiKeysConfig.bscscan,
    ),
    'MATIC': _Explorer(
      'https://api.polygonscan.com/api',
      '', // free tier works without key
    ),
    'ARBITRUM': _Explorer(
      'https://api.arbiscan.io/api',
      '', // separate key not configured; free tier OK
    ),
    'OPTIMISM': _Explorer(
      'https://api-optimistic.etherscan.io/api',
      ApiKeysConfig.etherscan,
    ),
    'BASE': _Explorer(
      'https://api.basescan.org/api',
      ApiKeysConfig.basescan,
    ),
    'AVAXC': _Explorer(
      'https://api.snowtrace.io/api',
      '',
    ),
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
      'module': 'account',
      'action': 'tokentx',
      'address': address,
      'sort': 'desc',
      'offset': '50', // last 50 transfers is plenty
      'page': '1',
    };
    if (explorer.apiKey.isNotEmpty) {
      params['apikey'] = explorer.apiKey;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      explorer.baseUrl,
      queryParameters: params,
    );
    final body = response.data;
    if (body == null || body['status'] != '1') {
      // status '0' with message "No transactions found" is a normal case.
      return [];
    }

    final txList = body['result'] as List<dynamic>? ?? [];

    // 2. Deduplicate unique contracts (preserve first occurrence).
    final seen = <String>{};
    final candidates = <_EvmCandidate>[];

    for (final tx in txList) {
      if (tx is! Map) continue;
      final contract = (tx['contractAddress'] as String?)?.toLowerCase() ?? '';
      if (contract.isEmpty) continue;
      if (seen.contains(contract)) continue;
      if (knownContracts.contains(contract)) continue;
      if (ignoredContracts.contains(contract)) continue;
      seen.add(contract);

      candidates.add(_EvmCandidate(
        contract: tx['contractAddress'] as String,
        symbol: tx['tokenSymbol'] as String? ?? '',
        name: tx['tokenName'] as String? ?? '',
        decimals: int.tryParse(tx['tokenDecimal'] as String? ?? '0') ?? 0,
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
      for (final r in batchResults) {
        if (r != null) results.add(r);
      }
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
    final results = <DiscoveredToken>[];

    for (final account in accounts) {
      try {
        final parsed =
            account['account']['data']['parsed'] as Map<String, dynamic>?;
        if (parsed == null) continue;
        final info = parsed['info'] as Map<String, dynamic>? ?? {};

        final mint = info['mint'] as String? ?? '';
        if (mint.isEmpty) continue;
        if (knownContracts.contains(mint)) continue;
        if (ignoredContracts.contains(mint)) continue;

        final tokenAmount = info['tokenAmount'] as Map<String, dynamic>? ?? {};
        final amountStr = tokenAmount['amount'] as String? ?? '0';
        final decimals = (tokenAmount['decimals'] as num?)?.toInt() ?? 0;
        final balance = BigInt.tryParse(amountStr) ?? BigInt.zero;
        if (balance == BigInt.zero) continue;

        // Symbol/name: SPL tokens don't embed metadata in token accounts.
        // We leave them empty; the discovery UI shows the truncated mint address.
        results.add(DiscoveredToken(
          coinType: 'SOL',
          blockchainType: 'Solana',
          contractAddress: mint,
          symbol: '',
          name: '',
          decimals: decimals,
          rawBalance: balance,
        ));
      } catch (_) {
        continue;
      }
    }
    return results;
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
