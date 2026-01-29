// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'transfer_handler.dart';
import 'handlers/evm_transfer_handler.dart';
import 'handlers/btc_transfer_handler.dart';
import 'handlers/sol_transfer_handler.dart';
import 'handlers/trx_transfer_handler.dart';
import 'handlers/apt_transfer_handler.dart';
import 'handlers/dot_transfer_handler.dart';
import 'handlers/atom_transfer_handler.dart';
import 'handlers/xrp_transfer_handler.dart';
import 'handlers/ton_transfer_handler.dart';
import 'handlers/algo_transfer_handler.dart';
import 'handlers/xtz_transfer_handler.dart';
import 'handlers/fil_transfer_handler.dart';
import 'handlers/zil_transfer_handler.dart';

/// Factory for creating chain-specific transfer handlers
///
/// This factory determines the correct handler based on the chain symbol
/// and creates an instance of the appropriate handler class.
class TransferHandlerFactory {
  /// Singleton instance
  static final TransferHandlerFactory _instance = TransferHandlerFactory._();
  static TransferHandlerFactory get instance => _instance;

  TransferHandlerFactory._();

  /// Cache of handler instances
  final Map<String, TransferHandler> _handlers = {};

  /// Get a transfer handler for the given chain symbol
  ///
  /// Throws [UnsupportedChainException] if the chain is not supported
  TransferHandler getHandler(String chainSymbol) {
    final normalizedSymbol = _normalizeChainSymbol(chainSymbol);

    // Return cached handler if available
    if (_handlers.containsKey(normalizedSymbol)) {
      return _handlers[normalizedSymbol]!;
    }

    // Create new handler based on chain type
    final handler = _createHandler(normalizedSymbol);
    _handlers[normalizedSymbol] = handler;
    return handler;
  }

  /// Normalize chain symbol for consistent lookup
  String _normalizeChainSymbol(String symbol) {
    final upper = symbol.toUpperCase();

    // Handle aliases
    return switch (upper) {
      'BSC' => 'BNB',
      'AVAXC' => 'AVAX',
      'OPTIMISM' => 'OP',
      _ => upper,
    };
  }

  /// Create a handler instance for the given chain
  TransferHandler _createHandler(String chainSymbol) {
    // EVM-compatible chains
    if (_isEvmChain(chainSymbol)) {
      return EvmTransferHandler(chainSymbol);
    }

    // UTXO-based chains (Bitcoin family)
    if (_isUtxoChain(chainSymbol)) {
      return BtcTransferHandler(chainSymbol);
    }

    // Other chains with specific implementations
    return switch (chainSymbol) {
      'SOL' => SolTransferHandler(),
      'TRX' => TrxTransferHandler(),
      'APT' => AptTransferHandler(),
      'DOT' || 'KSM' => DotTransferHandler(chainSymbol),
      'ATOM' => AtomTransferHandler(),
      'XRP' => XrpTransferHandler(),
      'TON' => TonTransferHandler(),
      'ALGO' => AlgoTransferHandler(),
      'XTZ' => XtzTransferHandler(),
      'FIL' => FilTransferHandler(),
      'ZIL' => ZilTransferHandler(),
      _ => throw UnsupportedChainException(chainSymbol),
    };
  }

  /// Check if the chain is EVM-compatible
  bool _isEvmChain(String chainSymbol) {
    const evmChains = {
      'ETH', 'BNB', 'MATIC', 'AVAX', 'FTM', 'CELO', 'ONE', 'MOVR',
      'KLAY', 'METIS', 'ASTR', 'BOBA', 'EVMOS', 'CANTO', 'CRO',
      'OP', 'ARB', 'ZKSYNC', 'LINEA', 'BASE', 'SCROLL', 'MANTA',
      'BLAST', 'MODE', 'N',
    };
    return evmChains.contains(chainSymbol);
  }

  /// Check if the chain uses UTXO model (Bitcoin family)
  bool _isUtxoChain(String chainSymbol) {
    const utxoChains = {'BTC', 'LTC', 'DOGE', 'BCH', 'DASH', 'ZEC', 'DGB', 'RVN'};
    return utxoChains.contains(chainSymbol);
  }

  /// Check if a chain is supported
  bool isSupported(String chainSymbol) {
    try {
      _createHandler(_normalizeChainSymbol(chainSymbol));
      return true;
    } on UnsupportedChainException {
      return false;
    }
  }

  /// Clear handler cache
  void clearCache() {
    _handlers.clear();
  }
}
