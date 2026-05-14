// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';

/// Transfer parameters for all chain types
class TransferParams {
  final String chainSymbol;
  final String fromAddress;
  final String toAddress;
  final double value;
  final String contractAddress;
  final bool isTest;
  final bool maxValue;
  final String? message;
  final String? privateKey;
  final int pathIndex;
  final Map<String, dynamic>? chainMap;
  final Map<String, dynamic>? token;

  const TransferParams({
    required this.chainSymbol,
    required this.fromAddress,
    required this.toAddress,
    required this.value,
    this.contractAddress = '',
    this.isTest = false,
    this.maxValue = true,
    this.message,
    this.privateKey,
    this.pathIndex = 0,
    this.chainMap,
    this.token,
  });
}

/// Result of gas estimation
class GasEstimation {
  final BigInt gasLimit;
  final BigInt gasPrice;
  final BigInt totalFee;
  final String? errorMessage;

  const GasEstimation({
    required this.gasLimit,
    required this.gasPrice,
    required this.totalFee,
    this.errorMessage,
  });

  bool get isSuccess => errorMessage == null;
}

/// Abstract base class for chain-specific transfer handlers
///
/// Each blockchain implements its own handler with specific
/// transaction building, signing, and broadcasting logic.
abstract class TransferHandler {
  /// The chain symbol this handler supports (e.g., 'BTC', 'ETH')
  String get chainSymbol;

  /// Check if this handler supports the given chain
  bool supports(String chainSymbol);

  /// Execute a transfer
  ///
  /// Returns a [MessageModel] with the transaction result
  Future<MessageModel> transfer(TransferParams params);

  /// Estimate gas/fee for a transfer
  ///
  /// Returns [GasEstimation] with fee details
  Future<GasEstimation> estimateGas(TransferParams params);

  /// Execute a pre-built transfer from TransactionRecordModel
  Future<MessageModel> transferFromModel({
    TransationRecordModel? trModel,
    BtcTransactionRecodeModel? trModelBtc,
    String? privateKey,
    int pathIndex = 0,
  });

  /// Get the maximum transferable amount
  Future<String> getMaxTransferAmount(
    String blockchain,
    String coinType,
    Map<String, dynamic> signData,
    String path, {
    String? privateKey,
  });
}

/// Exception thrown when a chain is not supported
class UnsupportedChainException implements Exception {
  final String chainSymbol;

  const UnsupportedChainException(this.chainSymbol);

  @override
  String toString() => 'Unsupported chain: $chainSymbol';
}

/// Exception thrown when a transfer fails
class TransferException implements Exception {
  final String message;
  final String? details;

  const TransferException(this.message, {this.details});

  @override
  String toString() => details != null ? '$message: $details' : message;
}
