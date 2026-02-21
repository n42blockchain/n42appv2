// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/aa_config.dart';
import '../../widgets/aa/paymaster_option_card.dart';

/// Service for loading Paymaster options per chain.
///
/// Integrates with Pimlico's ERC-7677 paymaster RPC endpoint
/// (`pm_getPaymasterStubData` / `pm_getPaymasterData`).
///
/// Design notes:
/// - Sponsorship availability is confirmed by a lightweight RPC probe.
///   A full `pm_getPaymasterStubData` call requires a valid UserOperation;
///   we instead call `eth_chainId` on the paymaster URL to verify connectivity
///   and treat chain presence in [AAConfig.paymasterUrls] as the availability
///   signal (matches Pimlico's own supported-chain list).
/// - ERC-20 token options are sourced from [AAConfig.chainErc20Tokens],
///   which contains vetted per-chain contract addresses.
/// - Exchange rates are not fetched in this layer; the caller should integrate
///   a price oracle (e.g., CoinGecko) if live cost estimates are needed.
class PaymasterService {
  PaymasterService._();

  static final http.Client _client = http.Client();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Load all paymaster options for [chainId] / [chainSymbol].
  ///
  /// Returns at minimum [PaymasterOption.none] (self-pay). Sponsored and
  /// ERC-20 options are appended when the chain is supported.
  ///
  /// [apiKey] is the Pimlico API key; pass null to use the unauthenticated
  /// tier (rate-limited).
  static Future<List<PaymasterOption>> loadOptions({
    required int chainId,
    required String chainSymbol,
    String? apiKey,
  }) async {
    final symbol = chainSymbol.toUpperCase();
    final options = <PaymasterOption>[PaymasterOption.none];

    if (!AAConfig.isChainSupported(symbol)) {
      // Chain not supported → only self-pay available
      options.add(const PaymasterOption(
        type: PaymasterType.sponsored,
        isAvailable: false,
      ));
      return options;
    }

    // Probe sponsorship availability
    final sponsorshipAvailable = await _probeSponsorship(
      chainId: chainId,
      symbol: symbol,
      apiKey: apiKey,
    );

    options.add(PaymasterOption(
      type: PaymasterType.sponsored,
      isAvailable: sponsorshipAvailable,
    ));

    // Add ERC-20 token options from config
    final tokens = AAConfig.getChainTokens(symbol);
    for (final token in tokens) {
      options.add(PaymasterOption(
        type: PaymasterType.erc20,
        tokenSymbol: token.symbol,
        tokenAddress: token.address,
        decimals: token.decimals,
        isAvailable: true,
      ));
    }

    return options;
  }

  /// Human-readable list of chain symbols that have paymaster support.
  static List<String> get supportedChainSymbols =>
      AAConfig.paymasterUrls.keys.toList();

  // ── Private ────────────────────────────────────────────────────────────────

  /// Confirm the paymaster endpoint is reachable and the chain is in scope.
  ///
  /// Uses a minimal JSON-RPC `eth_chainId` call — no UserOperation needed.
  /// Falls back to `true` if the network request itself fails (prevents
  /// blocking the UI on connectivity issues; the actual UserOperation
  /// submission will surface the real error).
  static Future<bool> _probeSponsorship({
    required int chainId,
    required String symbol,
    String? apiKey,
  }) async {
    final baseUrl = AAConfig.paymasterUrls[symbol];
    if (baseUrl == null) return false;

    final url = apiKey != null && apiKey.isNotEmpty
        ? '$baseUrl?apikey=$apiKey'
        : baseUrl;

    try {
      final resp = await _client
          .post(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'method': 'eth_chainId',
              'params': [],
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (resp.statusCode != 200) return false;

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      if (body['result'] == null) return false;

      // Verify the returned chainId matches what we expect
      final returnedChainId =
          int.tryParse((body['result'] as String).replaceFirst('0x', ''), radix: 16);
      return returnedChainId == chainId;
    } catch (e) {
      // Network error → optimistically allow, real error shown at submission
      assert(() {
        debugPrint('[PaymasterService] probe error: $e');
        return true;
      }());
      return true;
    }
  }
}
