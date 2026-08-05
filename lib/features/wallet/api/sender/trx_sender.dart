// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// Tron chain sender.
class TrxSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

  @override
  Future<SendResult> send(SendParams params) async {
    final isContract = params.contractAddress.isNotEmpty;
    final gas = getCoinGas(CoinType.TRX.name, contract: isContract);
    final isTestnet = params.isTest;

    // Get native TRX balance
    final mmChain =
        await _tokenViewApi.getBalance(
          BlockchainType.Tron.name,
          CoinType.TRX.name,
          params.fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmChain.error) return SendResult.fail(mmChain.data?.toString());
    final rawChainData = mmChain.data;
    BigInt chainBalance = _extractTrxBalance(rawChainData, '');
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('TRX'));
    }

    // Get token balance if contract
    BigInt tokenBalance = BigInt.zero;
    if (isContract) {
      tokenBalance = _extractTrxBalance(rawChainData, params.contractAddress);
      if (tokenBalance == BigInt.zero) {
        return SendResult.fail(S.current.g_key_wallet_m4);
      }
    }

    // Get gas price
    MessageModel mmg =
        await _tokenViewApi.getGasPrice(
          BlockchainType.Tron.name,
          CoinType.TRX.name,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmg.error) {
      mmg = await TrxApi().getGasPriceTrx(isTest: false);
    }
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
    final totalGasPrice = gasPrice * BigInt.from(gas);

    BigInt valuePrice;
    double adjustedAmount = params.amount;

    if (!isContract) {
      valuePrice = ethToWeiString(params.amount.toString(), params.decimals);
      if (valuePrice == chainBalance && params.sendMax) {
        if (totalGasPrice >= valuePrice) {
          return SendResult.fail(S.current.g_key_wallet_m5('TRX'));
        }
        valuePrice = valuePrice - totalGasPrice;
        adjustedAmount = toEther(
          valuePrice.toString(),
          params.decimals,
        ).toDouble();
      }
      if (valuePrice <= BigInt.zero ||
          totalGasPrice + valuePrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5('TRX'));
      }
    } else {
      valuePrice = ethToWeiString(
        params.amount.toString(),
        params.tokenDecimals,
      );
      if (valuePrice > tokenBalance) {
        return SendResult.fail(S.current.g_key_wallet_m4);
      }
      if (totalGasPrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5('TRX'));
      }
    }

    // Get latest block
    final trxApi = TrxApi();
    MessageModel mmlbn = await _tokenViewApi.getLatestBlockNumberTrx(
      isTest: isTestnet,
    );
    if (mmlbn.error || !_hasUsableTrxBlockData(mmlbn.data)) {
      mmlbn = await trxApi.getBlockNowTrx(isTest: isTestnet);
    }
    if (mmlbn.error) return SendResult.fail(mmlbn.data?.toString());

    final blockInfo =
        (mmlbn.data as Map<String, dynamic>)['raw_data']
            as Map<String, dynamic>;
    final txData = <String, dynamic>{
      'ownerAddress': params.fromAddress,
      'toAddress': params.toAddress,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'blockTime': blockInfo['timestamp'],
      'txTrieRoot': blockInfo['txTrieRoot'],
      'witnessAddress': blockInfo['witness_address'],
      'parentHash': blockInfo['parentHash'],
      'version': blockInfo['version'],
      'number': blockInfo['number'],
      'feeLimit': totalGasPrice.toInt(),
    };

    if (isContract) {
      txData['cmd'] = 'TRC20';
      txData['contractAddress'] = params.contractAddress;
      txData['amount'] = _dataUtils.bigIntToHex(valuePrice, need0x: false);
    } else {
      txData['amount'] = valuePrice.toInt();
      txData['cmd'] = CoinType.TRX.name;
    }

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.TRX.name,
        params.path,
        txData,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.TRX.name,
        params.path,
        txData,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // Validate signature
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: CoinType.TRX.name,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(
        sigResult.errorMessage ?? 'Signature validation failed',
      );
    }

    // Broadcast
    final isTestStr = isTestnet ? 'test' : 'main';
    MessageModel mmtx = await _tokenViewApi.sendTxTrx(signStr, isTestStr);
    final txHash = _extractTrxBroadcastHash(mmtx.data);
    if (mmtx.error || txHash.isEmpty) {
      mmtx = await trxApi.sendTxTrx(signStr, isTest: isTestnet);
      if (!mmtx.error) {
        final h = _extractTrxBroadcastHash(mmtx.data);
        return SendResult.ok(h, actualAmount: adjustedAmount);
      }
      return SendResult.fail(mmtx.data?.toString());
    }

    return SendResult.ok(txHash, actualAmount: adjustedAmount);
  }

  BigInt _extractTrxBalance(dynamic data, String contractAddress) {
    if (data == null) return BigInt.zero;
    if (contractAddress.isEmpty) {
      if (data is Map && data['balance'] != null) {
        return BigInt.from(data['balance'] as int);
      }
      return BigInt.zero;
    }
    // Token balance
    if (data is Map) {
      final List<dynamic> trc20 = (data['trc20'] as List?) ?? [];
      for (final Map owner in trc20) {
        for (final key in owner.keys) {
          if (contractAddress.toUpperCase() == key.toString().toUpperCase()) {
            final cBalance = owner[key]?.toString();
            if (cBalance != null) return BigInt.parse(cBalance);
          }
        }
      }
    }
    return BigInt.zero;
  }

  bool _hasUsableTrxBlockData(dynamic data) =>
      data is Map && data['raw_data'] is Map;

  String _extractTrxBroadcastHash(dynamic data) {
    if (data is String) return data;
    if (data is Map) {
      final direct = data['txid']?.toString();
      if (direct != null && direct.isNotEmpty) return direct;
      final nested = data['transaction'] is Map
          ? data['transaction']['txid']?.toString()
          : null;
      if (nested != null && nested.isNotEmpty) return nested;
      final hash = data['hash']?.toString();
      if (hash != null && hash.isNotEmpty) return hash;
    }
    return '';
  }
}
