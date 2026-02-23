// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/wallet/api/token_view_api.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/src/wallet/utils/chain_1559.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:n42_wallet/src/wallet/utils/coin_gas.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for EVM-compatible chains
///
/// Supports: ETH, BNB, MATIC, AVAX, FTM, CELO, ONE, OP, ARB, etc.
class EvmTransferHandler extends BaseTransferHandler {
  final String _chainSymbol;

  EvmTransferHandler(this._chainSymbol);

  @override
  String get chainSymbol => _chainSymbol;

  @override
  bool supports(String chainSymbol) {
    const evmChains = {
      'ETH', 'BNB', 'MATIC', 'AVAX', 'FTM', 'CELO', 'ONE', 'MOVR',
      'KLAY', 'METIS', 'ASTR', 'BOBA', 'EVMOS', 'CANTO', 'CRO',
      'OP', 'ARB', 'ZKSYNC', 'LINEA', 'BASE', 'SCROLL', 'MANTA',
      'BLAST', 'MODE', 'N',
    };
    return evmChains.contains(normalizeSymbol(chainSymbol));
  }

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      return createError(S.current.g_key_wallet_m1(params.chainSymbol));
    }

    final coinType = normalizeSymbol(params.chainSymbol);
    final chainId = chainMap['chainId'] as int? ?? 1;
    final decimals = chainMap['decimals'] as int? ?? 18;
    final path = chainMap['path'] as String? ?? "m/44'/60'/0'/0/0";

    return _transferEth(
      chainId: chainId,
      coinType: coinType,
      fromAddress: params.fromAddress,
      toAddress: params.toAddress,
      value: params.value,
      decimals: decimals,
      path: path,
      contractAddress: params.contractAddress,
      tokenDecimals: params.token?['decimals'] ?? 0,
      isTest: params.isTest,
      maxValue: params.maxValue,
      message: params.message,
    );
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async {
    final coinType = normalizeSymbol(params.chainSymbol);
    final isContract = params.contractAddress.isNotEmpty;
    final gasLimit = BigInt.from(getCoinGas(coinType, contract: isContract));

    final mmg = await tokenViewApi.getGasPrice(
      BlockchainType.Ethereum.name,
      coinType,
      isTest: params.isTest,
    );

    if (mmg == null || mmg.error) {
      return GasEstimation(
        gasLimit: gasLimit,
        gasPrice: BigInt.zero,
        totalFee: BigInt.zero,
        errorMessage: mmg?.data?.toString() ?? 'Failed to get gas price',
      );
    }

    final gasPrice = mmg.data as BigInt;
    final adjustedGasPrice = get1559WithChainSymbol(coinType)
        ? gasPrice * BigInt.from(2)
        : gasPrice;

    return GasEstimation(
      gasLimit: gasLimit,
      gasPrice: adjustedGasPrice,
      totalFee: adjustedGasPrice * gasLimit,
    );
  }

  Future<MessageModel> _transferEth({
    required int chainId,
    required String coinType,
    required String fromAddress,
    required String toAddress,
    required double value,
    required int decimals,
    required String path,
    String contractAddress = '',
    int tokenDecimals = 0,
    bool isTest = false,
    bool maxValue = true,
    String? message,
  }) async {
    final gas = getCoinGas(coinType, contract: contractAddress.isNotEmpty);

    BigInt balance = BigInt.zero;
    BigInt chainBalance = BigInt.zero;

    // Get token balance if contract transfer
    if (contractAddress.isNotEmpty) {
      final mm = await getBalanceEth(
        coinType,
        fromAddress,
        contract: contractAddress,
        isTest: isTest,
      );
      if (mm.error) return mm;
      balance = mm.data;
      if (balance == BigInt.zero) {
        return createError(S.current.g_key_wallet_m4);
      }
    }

    // Get chain balance for gas
    final mmchain = await getBalanceEth(coinType, fromAddress, contract: '', isTest: isTest);
    if (mmchain.error) return mmchain;
    chainBalance = mmchain.data;
    if (chainBalance == BigInt.zero) {
      return createError(S.current.g_key_wallet_m5(coinType));
    }

    // Get gas price
    final mmg = await tokenViewApi.getGasPrice(
      BlockchainType.Ethereum.name,
      coinType,
      isTest: isTest,
    ) ?? MessageModel.error();
    if (mmg.error) return mmg;

    BigInt gasPrice2 = mmg.data;
    BigInt gasPrice = mmg.data;
    if (get1559WithChainSymbol(coinType)) {
      gasPrice = gasPrice * BigInt.from(2);
    }

    // Estimate gas
    int gasLimit = gas;
    final estimateMm = await TokenViewApi().getGasEstimateEthV2(
      fromAddress,
      toAddress,
      gasPrice,
      ethToWeiString(value.toString(), contractAddress.isEmpty ? decimals : tokenDecimals),
      BigInt.from(gas),
      coinType,
      contract: contractAddress,
      isTest: isTest,
    );

    if (!estimateMm.error) {
      gasLimit = (estimateMm.data as BigInt).toInt();
      if (coinType == CoinType.OP.name || coinType == CoinType.BOBA.name) {
        gasLimit = (gasLimit * 1.5).toInt();
      }
    } else {
      return estimateMm;
    }

    final totalGasPrice = gasPrice * BigInt.from(gasLimit);

    // Calculate value and validate
    BigInt valuePrice;
    double adjustedValue = value;

    if (contractAddress.isEmpty) {
      valuePrice = ethToWeiString(value.toString(), decimals);
      if (valuePrice == chainBalance && maxValue) {
        valuePrice = valuePrice - totalGasPrice;
        adjustedValue = toEther(valuePrice.toString(), decimals).toDouble();
      }
      if (adjustedValue < 0) {
        return createError(S.current.g_key_wallet_m5(coinType == CoinType.N.name ? CoinType.N.name : coinType));
      }
      if (totalGasPrice + valuePrice > chainBalance) {
        return createError(S.current.g_key_wallet_m5(coinType == CoinType.N.name ? CoinType.N.name : coinType));
      }
    } else {
      valuePrice = ethToWeiString(value.toString(), tokenDecimals);
      if (valuePrice > balance) {
        return createError(S.current.g_key_wallet_m4);
      }
      if (totalGasPrice > chainBalance) {
        return createError(S.current.g_key_wallet_m5(coinType == CoinType.N.name ? CoinType.N.name : coinType));
      }
    }

    // Execute transfer
    final rmm = await _transferEthSend(
      fromAddress: fromAddress,
      toAddress: toAddress,
      valuePrice: valuePrice,
      path: path,
      gasPrice: gasPrice,
      gasPrice2: gasPrice2,
      gas: gasLimit,
      coinType: coinType,
      chainId: chainId,
      contractAddress: contractAddress,
      isTest: isTest ? 'test' : 'main',
      message: message,
    );

    if (!rmm.error) {
      rmm.data = {
        'txHash': rmm.data,
        'value': adjustedValue,
      };
    }
    return rmm;
  }

  Future<MessageModel> _transferEthSend({
    required String fromAddress,
    required String toAddress,
    required BigInt valuePrice,
    required String path,
    required BigInt gasPrice,
    required BigInt gasPrice2,
    required int gas,
    required String coinType,
    required int chainId,
    String contractAddress = '',
    String isTest = 'main',
    String? privateKey,
    String? nonce,
    String? message,
    String erc721Or1155 = '',
    bool returnSignHash = false,
    String? rpc,
  }) async {
    String nonceHex;

    if (nonce == null) {
      final mmn = await tokenViewApi.getTransactionCountEth(
        coinType,
        fromAddress,
        netMode: isTest,
        rpc: rpc,
      );
      if (mmn.error) return mmn;
      nonceHex = dataUtils.bigIntToHex(mmn.data, need0x: false);
    } else {
      nonceHex = dataUtils.strip0x(nonce);
    }

    if (gasPrice == BigInt.zero) {
      return createError('Gas price error');
    }

    final gasPriceHex = dataUtils.bigIntToHex(gasPrice, need0x: false);
    final gasPrice2Hex = dataUtils.bigIntToHex(gasPrice2, need0x: false);
    final amountHex = dataUtils.bigIntToHex(valuePrice, need0x: false);
    final chainIdHex = dataUtils.bigIntToHex(BigInt.from(chainId), need0x: false);
    final gasLimitHex = dataUtils.bigIntToHex(BigInt.from(gas * 4), need0x: false);

    String messageHex = '';
    if (message != null) {
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
      'erc721Or1155': erc721Or1155,
      'is1559': get1559WithChainSymbol(coinType) ? 'true' : 'false',
    };

    String signStr;
    if (privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return createError('Context is no longer valid');
      }
      signStr = await trustdart.signTransaction(
        coinType,
        path,
        signMap,
        mnemonic: globalWapAdapter
            .walletInfo
            .mnemonic ?? '',
      );
    } else {
      signStr = await trustdart.signTransaction(coinType, path, signMap, pk: privateKey);
    }

    if (signStr.isEmpty) {
      return createError(S.current.g_key_wallet_m6);
    }

    signStr = '0x$signStr';

    if (returnSignHash) {
      return createSuccess(data: signStr);
    }

    return await tokenViewApi.sendTx(
      BlockchainType.Ethereum.name,
      coinType,
      signStr,
      netMode: isTest,
      rpc: rpc,
    ) ?? MessageModel.error();
  }

  Future<MessageModel> getBalanceEth(
    String coinType,
    String address, {
    required String contract,
    required bool isTest,
  }) async {
    return await tokenViewApi.getBalance(
      BlockchainType.Ethereum.name,
      coinType,
      address,
      contract: contract,
      isTest: isTest,
    ) ?? MessageModel.error();
  }
}
