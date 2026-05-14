// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Parameters for a transfer operation.
class SendParams {
  final String coinType;        // e.g. 'ETH', 'BNB', 'SOL'
  final String fromAddress;
  final String toAddress;
  final double amount;          // decimal amount
  final int decimals;           // coin decimals
  final String path;            // derivation path
  final bool sendMax;           // deduct fee from amount
  final bool isTest;
  final String contractAddress; // empty = native transfer
  final int tokenDecimals;      // token decimals if contractAddress non-empty
  final String? memo;
  final String? calldata;       // raw hex calldata (DEX approve/swap), bypasses memo encoding
  final String? privateKey;     // null = use wallet mnemonic
  final Map<String, dynamic>? chainConfig; // full chain config from chainUrlMap
  final int? destinationTag;    // XRP destination tag (exchange deposits)
  final String? nftTokenId;     // ERC721/1155 token ID
  final String? nftStandard;    // 'ERC721' | 'ERC1155'
  final int? nftQuantity;       // ERC1155 transfer quantity (default 1)
  // BTC-family optimisation: when provided, BtcSender skips the corresponding
  // network round-trips (fee-rate API / UTXO fetch) that the UI already made.
  final int? btcFeeRate;        // sat/byte; skips fee-rate API query
  final List<Map<String, dynamic>>? prebuiltUtxos; // skips UTXO fetch

  const SendParams({
    required this.coinType,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.decimals,
    required this.path,
    this.sendMax = false,
    this.isTest = false,
    this.contractAddress = '',
    this.tokenDecimals = 0,
    this.memo,
    this.calldata,
    this.privateKey,
    this.chainConfig,
    this.destinationTag,
    this.nftTokenId,
    this.nftStandard,
    this.nftQuantity,
    this.btcFeeRate,
    this.prebuiltUtxos,
  });
}

/// Result of a send operation.
class SendResult {
  final bool success;
  final String? txHash;
  final double? actualAmount; // after fee deduction when sendMax=true
  final String? error;

  const SendResult.ok(this.txHash, {this.actualAmount})
      : success = true,
        error = null;
  const SendResult.fail(this.error)
      : success = false,
        txHash = null,
        actualAmount = null;

  /// Convert to legacy MessageModel for compatibility.
  MessageModel toMessageModel() {
    if (success) {
      return MessageModel()..data = {'txHash': txHash, 'value': actualAmount};
    }
    return MessageModel.error()..data = error;
  }
}

/// Abstract base for all chain-specific senders.
abstract class ChainSender {
  /// Execute a transfer. Returns [SendResult].
  Future<SendResult> send(SendParams params);
}
