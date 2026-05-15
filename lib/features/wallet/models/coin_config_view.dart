// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
//
// Typed view over the dynamic [CoinModel.coin] map.
//
// Background: `coin` is a `Map<String, dynamic>` populated either from
// the hand-coded chain registry (the `baseInfo` subtree of each entry
// in `wallet_chain_configs_part{1,2}`) or from market API responses
// that layer additional fields (image / thumb / large / symbol / ...)
// onto the same map. Direct `coin['xxx']` access is sprinkled across
// the codebase 770+ times for 38 distinct keys.
//
// [CoinConfigView] is a non-invasive overlay: it wraps the existing
// map without copying or mutating it, and exposes the most-used keys
// as typed getters with safe nullable defaults. Use it for new code:
//
// ```dart
// final view = cm.config;   // via CoinModelConfigViewExt
// final ct = view.coinType; // String, no `coin['coinType']` cast
// ```
//
// Old call sites continue to use `coin['xxx']` — this view does NOT
// require any migration. The escape hatch [operator []] re-exposes
// raw access for keys not yet covered.

import 'package:n42_wallet/features/wallet/models/coin_model.dart';

class CoinConfigView {
  /// The underlying map. Kept public for cases that genuinely need to
  /// pass the raw dynamic shape (e.g. into legacy APIs); prefer the
  /// typed getters below.
  final Map<String, dynamic> raw;

  const CoinConfigView(this.raw);

  // ── Identity ────────────────────────────────────────────────────────────

  /// CoinType enum name (e.g. "N", "BTC", "ETH"). Empty when absent.
  String get coinType => _readString('coinType');

  /// BlockchainType enum name (e.g. "Ethereum", "Bitcoin"). Empty when absent.
  String get blockchainType => _readString('blockchainType');

  /// Stable internal map key (e.g. "N", "BTC"). Empty when absent.
  String get mKey => _readString('mKey');

  /// Human-facing display name (e.g. "N42", "Bitcoin"). Empty when absent.
  String get name => _readString('name');

  /// Short display label / ticker (e.g. "N", "BTC", "ETH"). Empty when absent.
  String get miniName => _readString('miniName');

  /// Currency-style unit symbol used in formatting. Empty when absent.
  String get unit => _readString('unit');

  /// Trading pair symbol from market APIs. Empty when absent.
  String get symbol => _readString('symbol');

  // ── Numeric ─────────────────────────────────────────────────────────────

  /// Decimal precision of the on-chain unit. Reads both `decimals` and
  /// the legacy `decimal` typo; returns 0 when both absent.
  int get decimals {
    final v = raw['decimals'] ?? raw['decimal'];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  /// EVM chain ID for the mainnet network. 0 when absent.
  int get chainId => _readInt('chainId');

  /// EVM chain ID for the testnet network. 0 when absent.
  int get chainIdTest => _readInt('chainId_test');

  /// Last-known price in fiat (USD). 0 when absent.
  double get coinPrice {
    final v = raw['coinPrice'] ?? raw['price'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  /// 24h percent change. 0 when absent.
  double get percentage => _readDouble('percentage');

  // ── Flags ───────────────────────────────────────────────────────────────

  /// True when this coin entry represents an ERC20/SPL/TRC20 token
  /// rather than a chain native asset.
  bool get isContract => _readBool('isContract');

  /// True when this is an aggregated multi-chain stablecoin row.
  bool get isAggregated => _readBool('isAggregated');

  /// True when this entry was added by the user (custom token).
  bool get custom => _readBool('custom');

  /// True when the chain config allows the user to edit the contract
  /// or name (mainly for custom tokens).
  bool get canEdit => _readBool('canEdit');

  // ── Network endpoints ───────────────────────────────────────────────────

  /// Primary mainnet RPC/HTTP endpoint. Empty when absent.
  String get service => _readString('service');

  /// Testnet endpoint counterpart. Empty when absent.
  String get serviceTest => _readString('service_test');

  /// Contract address for token rows on mainnet. Empty for native coins.
  String get contract => _readString('contract');

  /// Contract address for token rows on testnet. Empty for native coins.
  String get contractTest => _readString('contract_test');

  // ── Visual ──────────────────────────────────────────────────────────────

  /// Primary icon URL. Empty when absent.
  String get icon => _readString('icon');

  /// Market-API supplied image URL (CoinGecko-style "small"/"large").
  String get image => _readString('image');

  /// CoinGecko-style thumb URL. Empty when absent.
  String get thumb => _readString('thumb');

  /// CoinGecko-style large URL. Empty when absent.
  String get large => _readString('large');

  /// CoinGecko slug used for cross-references. Empty when absent.
  String get coinGeckoId => _readString('coin_gecko_id');

  // ── HD derivation ───────────────────────────────────────────────────────

  /// Raw derivation-path map, keyed by addrType ("legacy", "segwit", …).
  /// Returns null when absent — callers must resolve via [pathForAddrType].
  Map<String, dynamic>? get pathMap {
    final v = raw['path'];
    return v is Map<String, dynamic> ? v : null;
  }

  /// Resolve the BIP-44/49/84 derivation template for a given addrType.
  /// Returns null when no path is registered for that addrType.
  String? pathForAddrType(String addrType) {
    final p = pathMap?[addrType];
    return p is String ? p : null;
  }

  // ── Balance hints (rarely used; CoinModel.balance is the source of truth)

  /// Stored balance string (chain-config initial value, not live).
  String get storedBalance => _readString('balance');

  /// Stored testnet balance string.
  String get storedBalanceTest => _readString('balance_test');

  // ── Escape hatch ────────────────────────────────────────────────────────

  /// Raw map access for keys not (yet) covered by a typed getter.
  /// Prefer adding a typed getter above to keep call sites typed.
  dynamic operator [](String key) => raw[key];

  /// Whether [key] is present in the underlying map.
  bool contains(String key) => raw.containsKey(key);

  // ── Internal helpers ────────────────────────────────────────────────────

  String _readString(String key) {
    final v = raw[key];
    return v is String ? v : '';
  }

  int _readInt(String key) {
    final v = raw[key];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  double _readDouble(String key) {
    final v = raw[key];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  bool _readBool(String key) {
    final v = raw[key];
    return v is bool ? v : false;
  }
}

/// Extension giving every [CoinModel] a typed view of its `coin` map.
///
/// Usage:
/// ```dart
/// final cm = ...;
/// final type = cm.config.coinType;        // String
/// final dec = cm.config.decimals;          // int
/// final path = cm.config.pathForAddrType('legacy');
/// ```
extension CoinModelConfigViewExt on CoinModel {
  /// Typed view over [CoinModel.coin]. The view holds no extra state
  /// and is safe to materialise on demand.
  CoinConfigView get config => CoinConfigView(coin);
}
