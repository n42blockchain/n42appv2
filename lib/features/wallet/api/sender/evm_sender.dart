// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/mev_protection.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
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
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

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
    final baseInfo = params.chainConfig?['baseInfo'] as Map<String, dynamic>?;
    final chainId = (baseInfo?['chainId'] as int?) ?? 1;
    final isContract = params.contractAddress.isNotEmpty;
    final gas = getCoinGas(coinType, contract: isContract);

    // 自定义链（baseInfo.custom == true）：所有 EVM RPC 调用直连该链自己的
    // RPC，绕开只认内建 coinType 的 N42 后端。内建链 rpcOverride 恒为 null，
    // 走原有后端路径，行为完全不变。
    final String? rpcOverride = (baseInfo?['custom'] == true)
        ? (baseInfo?['service'] as String?)?.trim()
        : null;

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
    final gasPrice = get1559WithChainSymbol(coinType)
        ? baseFee * BigInt.from(2)
        : baseFee;

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
      isTest: params.isTest,
      rpc: rpcOverride,
    );
    if (estimateMm.error) return SendResult.fail(estimateMm.data?.toString());

    int gasLimit = (estimateMm.data as BigInt).toInt();
    if (coinType == CoinType.OP.name || coinType == CoinType.BOBA.name) {
      gasLimit = (gasLimit * 1.5).toInt();
    }

    final totalGasPrice = gasPrice * BigInt.from(gasLimit);

    // Calculate value and validate
    BigInt valuePrice;
    double adjustedValue = params.amount;

    if (!isContract) {
      valuePrice = ethToWeiString(params.amount.toString(), params.decimals);
      if (valuePrice == chainBalance && params.sendMax) {
        valuePrice = valuePrice - totalGasPrice;
        adjustedValue = toEther(
          valuePrice.toString(),
          params.decimals,
        ).toDouble();
      }
      if (adjustedValue < 0 || totalGasPrice + valuePrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    } else {
      valuePrice = ethToWeiString(
        params.amount.toString(),
        params.tokenDecimals,
      );
      if (valuePrice > balance) {
        return SendResult.fail(S.current.g_key_wallet_m4);
      }
      if (totalGasPrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    }

    // Sign and broadcast
    final signResult = await _sign(
      coinType: coinType,
      path: params.path,
      fromAddress: params.fromAddress,
      toAddress: params.toAddress,
      valuePrice: valuePrice,
      gasPrice: gasPrice,
      gasPrice2: baseFee,
      gasLimit: gasLimit,
      chainId: chainId,
      contractAddress: params.contractAddress,
      isTest: params.isTest,
      privateKey: params.privateKey,
      message: params.memo,
      calldata: params.calldata,
      rpc: rpcOverride,
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
  }) async {
    final gasPriceHex = _dataUtils.bigIntToHex(gasPrice, need0x: false);
    final gasPrice2Hex = _dataUtils.bigIntToHex(gasPrice2, need0x: false);
    final amountHex = _dataUtils.bigIntToHex(valuePrice, need0x: false);
    final chainIdHex = _dataUtils.bigIntToHex(
      BigInt.from(chainId),
      need0x: false,
    );
    final gasLimitHex = _dataUtils.bigIntToHex(
      BigInt.from((gasLimit * 1.2).ceil()),
      need0x: false,
    );

    // Get nonce
    final mmn = await _tokenViewApi.getTransactionCountEth(
      coinType,
      fromAddress,
      netMode: isTest ? 'test' : 'main',
      rpc: rpc,
    );
    if (mmn.error) return SendResult.fail(mmn.data?.toString());
    final nonceHex = _dataUtils.bigIntToHex(mmn.data, need0x: false);

    if (gasPrice == BigInt.zero) return SendResult.fail('Gas price error');

    String messageHex = '';
    if (calldata != null) {
      messageHex = calldata; // raw hex ABI calldata — use as-is, no encoding
    } else if (message != null) {
      messageHex = Platform.isAndroid ? message : bytesToHex(message.codeUnits);
    }

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

  static MessageModel _errMM() => MessageModel.error();
}
