// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/mev_protection.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/transfer_serializer.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// EVM-compatible chain sender.
/// Handles ETH, BNB, MATIC, AVAX, FTM, CELO, ONE, OP, ARB, BASE, etc.
class EvmSender implements ChainSender {
  final Map<String, dynamic>? _defaultChainConfig;
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

  EvmSender({Map<String, dynamic>? chainConfig})
    : _defaultChainConfig = chainConfig;

  @override
  Future<SendResult> send(SendParams params) {
    // 同一地址的发送串行化：nonce 从查询（pending tag）到广播之间没有
    // 互斥，快速双击/自动重试会拿到同一 nonce 各自签名广播（双花）。
    return TransferSerializer.run(
      '${params.coinType}:${params.fromAddress}',
      () => _sendSerialized(params),
    );
  }

  Future<SendResult> _sendSerialized(SendParams params) async {
    final coinType = params.coinType;
    final chainConfig = params.chainConfig ?? _defaultChainConfig;
    // CoinModel stores baseInfo itself, while other callers may pass a full
    // registry entry. Normalize both shapes before reading RPC settings.
    final int? resolvedChainId = resolveChainId(
      chainConfig,
      isTest: params.isTest,
    );
    // 测试网缺 chainId_test 时绝不能回退主网 chainId：签出的交易在主网合法。
    if (params.isTest && resolvedChainId == null) {
      return SendResult.fail('Missing testnet chain ID for $coinType');
    }
    final chainId = resolvedChainId ?? 1;
    final isContract = params.contractAddress.isNotEmpty;
    // 有 raw calldata(DEX/加速重放等)时按合约档取 gas 上限——native 档 50000
    // 对带 data 的估算可能因 cap 过低报 gas exceeds allowance。
    final hasCalldata = (params.calldata ?? '').length > 2;
    final gas = getCoinGas(coinType, contract: isContract || hasCalldata);

    // EVM 链有自己的 RPC 时统一直连。部分新链（包括 Sonic）尚未被旧的
    // TokenView 后端按 coinType 路由，继续走后端会产生 5xx/521，并可能把
    // 交易提交到错误的网络。测试网 URL 为空时保留后端回退。
    final String? rpcOverride = resolveRpcOverride(
      chainConfig,
      isTest: params.isTest,
    );

    // Get token balance if contract transfer
    BigInt balance = BigInt.zero;
    if (isContract) {
      final mm =
          await _tokenViewApi.getBalance(
            BlockchainType.Ethereum.name,
            coinType,
            params.fromAddress,
            contract: params.contractAddress,
            isTest: params.isTest,
            rpc: rpcOverride,
          ) ??
          _errMM();
      if (mm.error) return SendResult.fail(mm.data?.toString());
      balance = mm.data as BigInt;
      if (balance == BigInt.zero) {
        return SendResult.fail(S.current.g_key_wallet_m4);
      }
    }

    // Get chain balance for gas
    final mmchain =
        await _tokenViewApi.getBalance(
          BlockchainType.Ethereum.name,
          coinType,
          params.fromAddress,
          contract: '',
          isTest: params.isTest,
          rpc: rpcOverride,
        ) ??
        _errMM();
    if (mmchain.error) return SendResult.fail(mmchain.data?.toString());
    final chainBalance = mmchain.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Get gas price
    final mmg =
        await _tokenViewApi.getGasPrice(
          BlockchainType.Ethereum.name,
          coinType,
          isTest: params.isTest,
          rpc: rpcOverride,
        ) ??
        _errMM();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());

    final baseFee = mmg.data as BigInt;
    var gasPrice = get1559WithChainSymbol(coinType)
        ? baseFee * BigInt.from(2)
        : baseFee;
    // 加速/取消：期望 gasPrice 下限。取 max(网络当前, 期望值)，既保证覆盖交易
    // 一定 ≥ 网络当前（否则矿工不会替换），又保证 ≥ 原交易×提价系数。
    if (params.gasPriceOverride != null &&
        params.gasPriceOverride! > gasPrice) {
      gasPrice = params.gasPriceOverride!;
    }

    // Estimate gas
    final effectiveDecimals = isContract
        ? params.tokenDecimals
        : params.decimals;
    final estimateMm = await _tokenViewApi.getGasEstimateEthV2(
      params.fromAddress,
      params.toAddress,
      gasPrice,
      ethToWeiString(params.amount.toString(), effectiveDecimals),
      BigInt.from(gas),
      coinType,
      contract: params.contractAddress,
      // 关键:raw calldata 必须参与估算——否则对合约地址的"无 data 裸估"
      // 要么 revert 要么估出 21000,上链后 out-of-gas(接线复审 P0-1,
      // 波及 DEX approve/swap、Aave、staking、DApp 签名与交易加速重放)。
      data: params.calldata ?? '',
      isTest: params.isTest,
      rpc: rpcOverride,
    );
    if (estimateMm.error) return SendResult.fail(estimateMm.data?.toString());

    int gasLimit = (estimateMm.data as BigInt).toInt();
    if (coinType == CoinType.OP.name || coinType == CoinType.BOBA.name) {
      gasLimit = (gasLimit * 1.5).toInt();
    }
    // Apply the safety buffer here (once) so the balance check below reserves
    // exactly what will be signed. Previously the ×1.2 buffer lived only in
    // _sign, so a MAX native send (value = balance - fee at 1.0×) signed a tx
    // whose fee ceiling was 1.2× fee and got rejected by the node for
    // insufficient funds.
    gasLimit = (gasLimit * 1.2).ceil();

    final totalGasPrice = gasPrice * BigInt.from(gasLimit);

    // Calculate value and validate
    BigInt valuePrice;
    double adjustedValue = params.amount;

    if (!isContract) {
      // 精确 wei 优先:有 override 直接用它,避免 double 往返上浮——否则合法
      // MAX(balance-fee 的精确 BigInt 降级 double 后重建上浮几 wei)会在下面
      // 的余额校验被误判"余额不足"而发不出(第三轮 P1;加速重放亦走此路)。
      if (params.valueWeiOverride != null) {
        valuePrice = params.valueWeiOverride!;
      } else {
        valuePrice = ethToWeiString(params.amount.toString(), params.decimals);
      }
      // Send-max reconciliation. The caller computes the max transferable
      // amount with its own fee estimate, but this sender applies the ×1.2
      // safety buffer, so the two disagree by 0.2×fee and the balance check
      // below would reject a legitimate max send that the caller just offered
      // the user. Whenever the requested value sits in [balance - fee,
      // balance] the intent is "send as much as possible", so settle it
      // against the fee actually being signed. A value above the balance is
      // still a genuine shortfall and falls through to the failure below.
      final maxSendable = chainBalance - totalGasPrice;
      if (valuePrice <= chainBalance &&
          maxSendable > BigInt.zero &&
          valuePrice >= maxSendable) {
        valuePrice = maxSendable;
        adjustedValue = toEther(
          valuePrice.toString(),
          params.decimals,
        ).toDouble();
      }
      if (adjustedValue < 0 || totalGasPrice + valuePrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    } else {
      // 合约代币金额同样优先精确 override(18 位代币 MAX 上浮同病)。
      if (params.tokenValueWeiOverride != null) {
        valuePrice = params.tokenValueWeiOverride!;
      } else {
        valuePrice = ethToWeiString(
          params.amount.toString(),
          params.tokenDecimals,
        );
      }
      if (valuePrice > balance) {
        return SendResult.fail(S.current.g_key_wallet_m4);
      }
      if (totalGasPrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    }

    // 原生 valueWeiOverride 已在上面 native 分支应用;此处仅保留额外的
    // 上限复核(加速重放路径同样受益)。
    if (params.valueWeiOverride != null && !isContract) {
      if (totalGasPrice + valuePrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    }
    // 1559 tip 下限(RBF):tipCap 也须 ≥ 原值×1.1,取 max(网络, 期望)。
    var effectiveTip = baseFee;
    if (params.tipOverride != null && params.tipOverride! > effectiveTip) {
      effectiveTip = params.tipOverride!;
      // maxFee 不得低于 tip
      if (gasPrice < effectiveTip) gasPrice = effectiveTip;
    }

    // Sign and broadcast
    final signResult = await _sign(
      coinType: coinType,
      path: params.path,
      fromAddress: params.fromAddress,
      toAddress: params.toAddress,
      valuePrice: valuePrice,
      gasPrice: gasPrice,
      gasPrice2: effectiveTip,
      gasLimit: gasLimit,
      chainId: chainId,
      contractAddress: params.contractAddress,
      isTest: params.isTest,
      privateKey: params.privateKey,
      message: params.memo,
      calldata: params.calldata,
      rpc: rpcOverride,
      nonceOverride: params.nonceOverride,
    );
    if (signResult is SendResult) return signResult;

    final signStr = signResult as String;

    // Validate signature
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: coinType,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(
        sigResult.errorMessage ?? 'Signature validation failed',
      );
    }

    // MEV 保护：高风险交易（DEX swap/授权/大额转账）在支持的链（当前仅主网
    // ETH，见 MevProtectionService.supportedChains）上优先经 Flashbots
    // Protect 私有交易池广播，绕开公开 mempool 防三明治/抢跑攻击；失败
    // （网络问题/端点不可用）静默回退到普通 RPC 广播，不因保护层故障阻断
    // 用户的正常交易。
    if (!params.isTest &&
        // 加速/取消(nonceOverride)不得进私池:原交易在公共 mempool,私池
        // 替换概率性失效且新 hash 公共 RPC 查不到(接线复审 P1-2);
        // 非 ETH 链即便配置的 RPC 返回 chainId 1 也不能被劫持到主网
        // Flashbots；ETH 仍保留原有私有广播路径。
        params.nonceOverride == null &&
        (rpcOverride == null || coinType == CoinType.ETH.name) &&
        MevProtectionService.instance.isEnabled &&
        MevProtectionService.isAvailable(chainId) &&
        MevProtectionService.assessRisk(
          chainId: chainId,
          data: params.calldata ?? '0x',
          value: valuePrice,
        ).shouldProtect) {
      try {
        final txHash = await MevProtectionService.instance
            .sendProtectedTransaction(chainId: chainId, signedTx: signStr);
        return SendResult.ok(txHash, actualAmount: adjustedValue);
      } catch (_) {
        // 落到下方普通 RPC 广播兜底。
      }
    }

    final sendMm =
        await _tokenViewApi.sendTx(
          BlockchainType.Ethereum.name,
          coinType,
          signStr,
          netMode: params.isTest ? 'test' : 'main',
          rpc: rpcOverride,
        ) ??
        _errMM();

    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedValue);
  }

  Future<Object> _sign({
    required String coinType,
    required String path,
    required String fromAddress,
    required String toAddress,
    required BigInt valuePrice,
    required BigInt gasPrice,
    required BigInt gasPrice2,
    required int gasLimit,
    required int chainId,
    String contractAddress = '',
    bool isTest = false,
    String? privateKey,
    String? message,
    String? calldata,
    String? rpc,
    BigInt? nonceOverride,
  }) async {
    final gasPriceHex = _dataUtils.bigIntToHex(gasPrice, need0x: false);
    final gasPrice2Hex = _dataUtils.bigIntToHex(gasPrice2, need0x: false);
    final amountHex = _dataUtils.bigIntToHex(valuePrice, need0x: false);
    final chainIdHex = _dataUtils.bigIntToHex(
      BigInt.from(chainId),
      need0x: false,
    );
    // gasLimit already includes the safety buffer (applied in the send path);
    // do not re-multiply here or the signed limit would drift from the value
    // reserved by the balance check.
    final gasLimitHex = _dataUtils.bigIntToHex(
      BigInt.from(gasLimit),
      need0x: false,
    );

    // Get nonce — 加速/取消时强制复用 pending 交易的 nonce 以形成覆盖交易；
    // 否则查询 pending tag。
    final BigInt nonceBig;
    if (nonceOverride != null) {
      nonceBig = nonceOverride;
    } else {
      final mmn = await _tokenViewApi.getTransactionCountEth(
        coinType,
        fromAddress,
        netMode: isTest ? 'test' : 'main',
        rpc: rpc,
      );
      if (mmn.error) return SendResult.fail(mmn.data?.toString());
      nonceBig = mmn.data as BigInt;
    }
    final nonceHex = _dataUtils.bigIntToHex(nonceBig, need0x: false);

    if (gasPrice == BigInt.zero) return SendResult.fail('Gas price error');

    final messageHex = buildMsgData(
      calldata: calldata,
      message: message,
      isAndroid: Platform.isAndroid,
    );

    final signMap = <String, String>{
      'chainId': chainIdHex,
      'gasPrice': gasPriceHex,
      'gasPrice2': gasPrice2Hex,
      'gasLimit': gasLimitHex,
      'toAddress': toAddress,
      'nonce': nonceHex,
      'contract': contractAddress.toLowerCase(),
      'amount': amountHex,
      'msgData': messageHex,
      'erc721Or1155': '',
      'is1559': get1559WithChainSymbol(coinType) ? 'true' : 'false',
    };

    String signStr;
    if (privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        coinType,
        path,
        signMap,
        pk: privateKey,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);
    return '0x$signStr';
  }

  /// 把 calldata / memo 规范化为原生签名层期望的「不带 0x 前缀的 hex」。
  ///
  /// 此前 calldata 原样（含 0x）下发：Android 原生对它做 `toByteArray()`
  /// （UTF-8），等于把 hex 文本本身当字符串写进 tx data——所有合约调用
  /// （swap/approve/staking）上链必 revert，却仍返回 txHash 报成功、白烧 gas；
  /// iOS 的 `handHexData` 也不剥离 0x。统一在此规范化后，两端一律按 hex 解码。
  ///
  /// memo 一律先按 UTF-8 编码再转 hex，与 Android 原生此前的字节语义一致
  /// （原生对原始字符串做 UTF-8）。iOS 此前传的是 `codeUnits`(UTF-16) 的 hex：
  /// ASCII 下与 UTF-8 等价，但中文等非 ASCII memo 的码点超出单字节范围，会产出
  /// 错误/非法的 hex——统一为 UTF-8 同时修掉这一点。
  ///
  /// [isAndroid] 保留用于平台差异回归定位；当前两端契约已统一。
  @visibleForTesting
  static String buildMsgData({
    String? calldata,
    String? message,
    required bool isAndroid,
  }) {
    if (calldata != null) return strip0x(calldata);
    if (message != null) return bytesToHex(utf8.encode(message));
    return '';
  }

  static MessageModel _errMM() => MessageModel.error();

  /// 从完整链配置解析当前网络的 EIP-155 chain ID。
  ///
  /// 配置同时保留 `chainId` 与 `chainId_test`。过去签名始终读取前者，测试网
  /// 交易会带主网 chain ID，被节点以 `invalid chain id for signer` 拒绝。
  ///
  /// 测试网缺独立 chain ID 时返回 null（fail-closed）：绝不能回退主网
  /// chainId——用主网 chain ID 签出的"测试网"交易在主网合法、可被重放。
  static int? resolveChainId(
    Map<String, dynamic>? chainConfig, {
    required bool isTest,
  }) {
    final baseInfo = _baseInfo(chainConfig);

    int read(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final selected = isTest
        ? read(baseInfo?['chainId_test'] ?? chainConfig?['testnetChainID'])
        : read(baseInfo?['chainId'] ?? chainConfig?['mainnetChainID']);
    return selected > 0 ? selected : null;
  }

  /// Returns the configured RPC for the selected EVM network when available.
  /// Accepts both registry entries and the baseInfo map stored in CoinModel.
  static String? resolveRpcOverride(
    Map<String, dynamic>? chainConfig, {
    required bool isTest,
  }) {
    final baseInfo = _baseInfo(chainConfig);
    final key = isTest ? 'service_test' : 'service';
    final rpc = baseInfo?[key]?.toString().trim();
    return rpc == null || rpc.isEmpty ? null : rpc;
  }

  /// Normalizes callers that provide either a full registry entry or baseInfo.
  static Map<String, dynamic>? _baseInfo(Map<String, dynamic>? chainConfig) {
    final nested = chainConfig?['baseInfo'];
    if (nested is Map<String, dynamic>) return nested;
    return chainConfig;
  }
}
