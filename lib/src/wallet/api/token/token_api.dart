// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Token API Module
///
/// This module provides a modular, maintainable structure for token-related APIs.
/// The original monolithic TokenViewApi class is preserved for backward compatibility,
/// while this module offers a cleaner architecture for new code.
///
/// ## Usage
///
/// For new code, prefer using the modular approach:
/// ```dart
/// import 'package:n42appv2/src/wallet/api/token/token_api.dart';
///
/// final api = ModularTokenApi();
/// final balance = await api.getBalanceEth('ETH', address, '');
/// ```
///
/// For existing code, continue using TokenViewApi which maintains full compatibility.
library;

export 'token_api_base.dart';
export 'btc_token_api.dart';
export 'eth_token_api.dart';
export 'sol_token_api.dart';
export 'trx_token_api.dart';

import 'token_api_base.dart';
import 'btc_token_api.dart';
import 'eth_token_api.dart';
import 'sol_token_api.dart';
import 'trx_token_api.dart';

/// Modular Token API
///
/// Combines all chain-specific mixins into a single class.
/// This class provides the same functionality as TokenViewApi but
/// with a cleaner, more maintainable architecture.
///
/// Each chain's methods are organized in their respective mixins:
/// - [BtcTokenApiMixin] - Bitcoin and UTXO chains
/// - [EthTokenApiMixin] - Ethereum and EVM chains
/// - [SolTokenApiMixin] - Solana
/// - [TrxTokenApiMixin] - Tron
class ModularTokenApi extends TokenApiBase
    with
        BtcTokenApiMixin,
        EthTokenApiMixin,
        SolTokenApiMixin,
        TrxTokenApiMixin {
  /// Singleton instance
  static ModularTokenApi? _instance;

  /// Factory constructor for singleton access
  factory ModularTokenApi() {
    _instance ??= ModularTokenApi._();
    return _instance!;
  }

  ModularTokenApi._() : super();

  /// Reset singleton instance (useful for testing)
  static void resetInstance() {
    _instance = null;
  }
}
