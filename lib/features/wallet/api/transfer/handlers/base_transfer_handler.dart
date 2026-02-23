// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

import '../transfer_handler.dart';

/// Base class for all transfer handlers
///
/// Provides common utilities and services used by all chain handlers.
abstract class BaseTransferHandler implements TransferHandler {
  // Lazy-loaded services
  TokenViewApi? _tokenViewApi;
  DataUtils? _dataUtils;
  Trustdart? _trustdart;

  /// Token view API for balance and price queries
  TokenViewApi get tokenViewApi {
    _tokenViewApi ??= TokenViewApi();
    return _tokenViewApi!;
  }

  /// Data utilities
  DataUtils get dataUtils {
    _dataUtils ??= DataUtils();
    return _dataUtils!;
  }

  /// Trust wallet dart library
  Trustdart get trustdart {
    _trustdart ??= Trustdart();
    return _trustdart!;
  }

  /// Get wallet action provider
  WalletActionProvider get walletProvider {
    return globalWapAdapter;
  }

  /// Get chain map for the specified chain symbol
  Map<String, dynamic>? getChainMap(String chainSymbol) {
    return walletProvider.walletMap[chainSymbol.toUpperCase()];
  }

  /// Process address for specific chains (e.g., BCH prefix)
  String processAddress(String address, String chainSymbol) {
    if (chainSymbol == 'BCH') {
      final parts = address.split(':');
      if (parts.length == 2) {
        return parts[1];
      }
    }
    return address;
  }

  /// Normalize chain symbol (handle aliases)
  String normalizeSymbol(String symbol) {
    return switch (symbol.toUpperCase()) {
      'BSC' => 'BNB',
      'AVAXC' => 'AVAX',
      'OPTIMISM' => 'OP',
      _ => symbol.toUpperCase(),
    };
  }

  /// Create error message model
  MessageModel createError(String message, {dynamic data}) {
    final model = MessageModel.error();
    model.data = data ?? message;
    return model;
  }

  /// Create success message model
  MessageModel createSuccess({dynamic data}) {
    final model = MessageModel();
    model.data = data;
    return model;
  }

  @override
  Future<MessageModel> transferFromModel({
    TransationRecordModel? trModel,
    BtcTransactionRecodeModel? trModelBtc,
    String? privateKey,
    int pathIndex = 0,
  }) async {
    // Default implementation - subclasses should override if needed
    return createError('transferFromModel not implemented for $chainSymbol');
  }

  @override
  Future<String> getMaxTransferAmount(
    String blockchain,
    String coinType,
    Map<String, dynamic> signData,
    String path, {
    String? privateKey,
  }) async {
    // Default implementation - subclasses should override if needed
    return '0';
  }
}
