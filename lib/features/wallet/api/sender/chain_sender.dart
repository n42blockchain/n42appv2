// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/shared/domain/entities/message_model.dart';

/// Parameters for a transfer operation.
class SendParams {
  final String coinType; // e.g. 'ETH', 'BNB', 'SOL'
  final String fromAddress;
  final String toAddress;
  final double amount; // decimal amount
  final int decimals; // coin decimals
  final String path; // derivation path
  final bool sendMax; // deduct fee from amount
  final bool isTest;
  final String contractAddress; // empty = native transfer
  final int tokenDecimals; // token decimals if contractAddress non-empty
  final String? memo;
  final String?
  calldata; // raw hex calldata (DEX approve/swap), bypasses memo encoding
  final String? privateKey; // null = use wallet mnemonic
  /// Full registry entry or the runtime `CoinModel.coin` (`baseInfo`) map.
  final Map<String, dynamic>? chainConfig;
  final int? destinationTag; // XRP destination tag (exchange deposits)
  final String? nftTokenId; // ERC721/1155 token ID
  final String? nftStandard; // 'ERC721' | 'ERC1155'
  final int? nftQuantity; // ERC1155 transfer quantity (default 1)
  // BTC-family optimisation: when provided, BtcSender skips the corresponding
  // network round-trips (fee-rate API / UTXO fetch) that the UI already made.
  final int? btcFeeRate; // sat/byte; skips fee-rate API query
  final List<Map<String, dynamic>>? prebuiltUtxos; // skips UTXO fetch
  // EVM 交易加速/取消（replace-by-fee）：复用某笔 pending 交易的 nonce，用更高
  // gasPrice 广播一笔覆盖交易。[nonceOverride] 强制使用该 nonce（而非查询
  // pending tag）；[gasPriceOverride] 是期望的 gasPrice 下限（EvmSender 取
  // max(网络当前, 此值)，保证一定 ≥ 网络且 ≥ 原交易×提价系数）。均为 null 时
  // 走原有查询逻辑，普通发送行为完全不变。
  final BigInt? nonceOverride;
  final BigInt? gasPriceOverride;
  // 1559 链的 tip(maxPriorityFeePerGas)下限:RBF 要求 feeCap 与 tipCap 同时
  // ≥ 原值×1.1——只提 maxFee 不提 tip 会被节点拒 "replacement underpriced"。
  final BigInt? tipOverride;
  // 精确 wei 金额(绕过 double 的 15-16 位精度截断):非空时忽略 amount。
  // 原生转账 value。
  final BigInt? valueWeiOverride;
  // 合约代币转账的精确最小单位金额(同上,针对 ERC20 transfer 金额)——
  // 18 位代币 MAX 全额从 BigInt 降级 double 会上浮、被误判余额不足(第三轮 P1)。
  final BigInt? tokenValueWeiOverride;

  /// Original display-unit decimal text for requests that must not pass through
  /// binary floating point before a chain sender converts it to base units.
  final String? decimalAmountOverride;

  String get amountDecimalString => decimalAmountOverride ?? amount.toString();

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
    this.nonceOverride,
    this.gasPriceOverride,
    this.tipOverride,
    this.valueWeiOverride,
    this.tokenValueWeiOverride,
    this.decimalAmountOverride,
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
