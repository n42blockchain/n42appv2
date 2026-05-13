// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// Bitcoin-family sender: BTC, LTC, DOGE, BCH, DASH.
class BtcSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    final coinType = params.coinType.toUpperCase();
    final isTestNet = params.isTest;
    String fromAddress = params.fromAddress;

    // BCH uses legacy address for UTXOs
    if (coinType == CoinType.BCH.name) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      fromAddress = globalWapAdapter.getAddress(coinType, addrType: 'legacy');
    }

    // Check last tx confirmation
    final checkErr = await _checkLastTx(coinType, fromAddress, isTestNet);
    if (checkErr != null) return SendResult.fail(checkErr);

    // Get fee rate
    int averageValue;
    if (coinType == CoinType.BTC.name) {
      final gasFeeMM = await _tokenViewApi.getGasFeeBtc(isTest: isTestNet);
      if (gasFeeMM.error) return SendResult.fail(gasFeeMM.data?.toString());
      averageValue = gasFeeMM.data as int;
    } else {
      averageValue = getCoinGas(coinType);
    }

    // Get balance
    final mmb = await _tokenViewApi.getBalance(
      BlockchainType.Bitcoin.name,
      coinType,
      fromAddress,
      isTest: isTestNet,
    ) ?? MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final balance = mmb.data as BigInt;

    if (balance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    final valuePrice = ethToWeiString(params.amount.toString(), 8);
    final allValue = balance == valuePrice && params.sendMax;

    // Collect UTXOs
    final List<Map<String, dynamic>> utxos = [];
    final mmutxo = await _getUTXO(
      coinType, params.amount, fromAddress, utxos, 0,
      averageValue, 1000, 1, allValue, isTest: isTestNet,
    );
    if (mmutxo.error) return SendResult.fail(mmutxo.data?.toString());
    final collectedUtxos = List<Map<String, dynamic>>.from(mmutxo.data['utxo'] as List);

    // Calculate byte size and fees
    final byteSize = await _getSignByteSize(
      coinType, params.path, collectedUtxos, valuePrice,
      averageValue, fromAddress, params.toAddress,
      max: allValue, privateKey: params.privateKey,
    );
    final byteSizeFees = byteSize * averageValue;

    double adjustedAmount = params.amount;
    if (allValue) {
      final feeInBtc = toEther(byteSizeFees.toString(), 8).toDouble();
      if (feeInBtc >= params.amount) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
      adjustedAmount = params.amount - feeInBtc;
    } else {
      if (BigInt.from(byteSizeFees) + valuePrice > balance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    }
    if (adjustedAmount <= 0) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Normalize BCH toAddress (strip "bitcoincash:" prefix)
    String toAddress = params.toAddress;
    if (coinType == CoinType.BCH.name) {
      final parts = toAddress.split(':');
      if (parts.length == 2) toAddress = parts[1];
    }

    // Sign
    final btcTxMap = <String, dynamic>{
      'toAddress': toAddress,
      'amount': valuePrice.toInt(),
      'byteFee': averageValue,
      'changeAddress': fromAddress,
      'fees': byteSizeFees,
      'utxo': collectedUtxos,
      'max': allValue,
    };

    String signStr;
    if (params.privateKey?.isNotEmpty ?? false) {
      signStr = await _trustdart.signTransaction(
        coinType, params.path, btcTxMap, pk: params.privateKey!,
      );
    } else {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        coinType,
        params.path,
        btcTxMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // Validate signature
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: coinType,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(sigResult.errorMessage ?? 'Signature validation failed');
    }

    // Broadcast
    final sendMm = await _tokenViewApi.sendTx(
      BlockchainType.Bitcoin.name,
      coinType,
      signStr,
      netMode: params.isTest ? 'test' : 'main',
    ) ?? MessageModel.error();

    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }

  /// Returns null if OK, error string if blocked.
  Future<String?> _checkLastTx(String coinType, String address, bool isTest) async {
    String lookupAddress = address;
    if (coinType == CoinType.BCH.name) {
      lookupAddress = globalWapAdapter.getAddress(coinType, addrType: 'legacy');
    }
    final txModel = await _tokenViewApi.getTxListBtc(
      coinType, lookupAddress, pageNum: 1, pageSize: 1,
    );
    if (txModel.error) return txModel.data?.toString();
    if ((txModel.data as List).isEmpty) return null;
    final btcData = txModel.data[0] as Map<String, dynamic>;
    if (btcData['txCount'] == 0) return null;
    if ((btcData['txs'] as List).isNotEmpty) {
      if (double.parse(btcData['txs'][0]['confirmations'].toString()) >= 6) return null;
      return S.current.g_key_wallet_m19(coinType);
    }
    return 'error';
  }

  Future<MessageModel> _getUTXO(
    String coinType,
    double value,
    String address,
    List<Map<String, dynamic>> utxos,
    int input2Price,
    int gasFee,
    int pageSize,
    int pageNum,
    bool allValue, {
    bool isTest = false,
  }) async {
    final mm = await _tokenViewApi.getUTXOBtc(
      coinType,
      address,
      pageSize: pageSize,
      pageNum: pageNum,
      isTest: isTest,
    );
    if (mm.error) return mm;

    final unspents = mm.data as List<dynamic>;
    final bool lastPage = unspents.length < (pageSize * pageNum);

    final mmutxoC = await _calculateGasFee(
      value, unspents, utxos, input2Price, gasFee, isTest: isTest,
    );
    if (!mmutxoC.error) return mmutxoC;

    if (lastPage) {
      if (!allValue) mmutxoC.data = S.current.g_key_wallet_m5(coinType);
      return mmutxoC;
    }
    return _getUTXO(
      coinType, value, address,
      (mmutxoC.data['utxo'] as List).cast<Map<String, dynamic>>(),
      mmutxoC.data['inputPrice'] as int,
      gasFee, pageSize, pageNum + 1, allValue, isTest: isTest,
    );
  }

  Future<MessageModel> _calculateGasFee(
    double value,
    List<dynamic> unspents,
    List<Map<String, dynamic>> utxos,
    int input2Price,
    int gasFee, {
    bool isTest = false,
  }) async {
    final int valuePriceInt = ethToWeiString(value.toString(), 8).toInt();

    for (final item in unspents) {
      final u = item as Map<String, dynamic>;
      if (isTest) {
        if (u['hex'] == null) {
          final utxoTx = await BtcApi(test: true).getUTXOTxid(u['txid'] as String);
          if (!utxoTx.error) {
            u['hex'] = (utxoTx.data as Map)['vout']?[u['vout']]?['scriptpubkey'];
          }
        }
        final amount = u['value'] as int;
        input2Price += amount;
        utxos.add({
          'txid': u['txid'],
          'vout': u['vout'],
          'value': amount.toString(),
          'script': u['hex'],
        });
      } else {
        final amount = ethToWeiString(double.parse(u['value'].toString()).toString(), 8);
        input2Price += amount.toInt();
        utxos.add({
          'txid': u['txid'],
          'vout': u['output_no'],
          'value': amount.toString(),
          'script': u['hex'],
        });
      }

      final byteSizeFees = (utxos.length * 148 + 78) * gasFee;
      if (byteSizeFees + valuePriceInt <= input2Price) break;
    }

    final rmm = MessageModel();
    rmm.data = {'utxo': utxos, 'inputPrice': input2Price};
    return rmm;
  }

  Future<int> _getSignByteSize(
    String coinType,
    String path,
    List<Map<String, dynamic>> utxos,
    BigInt price,
    int byteFee,
    String address,
    String toAddress, {
    bool max = false,
    String? privateKey,
  }) async {
    final btcTxMap = <String, dynamic>{
      'utxo': utxos,
      'toAddress': toAddress,
      'amount': price,
      'byteFee': byteFee,
      'changeAddress': address,
      'max': max,
    };
    String signByteSize;
    if (privateKey == null) {
      signByteSize = await _trustdart.signTransactionMaxValue(
        coinType,
        path,
        btcTxMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signByteSize = await _trustdart.signTransactionMaxValue(
        coinType, '', btcTxMap, pk: privateKey,
      );
    }
    return signByteSize.isEmpty ? 0 : int.parse(signByteSize);
  }
}
