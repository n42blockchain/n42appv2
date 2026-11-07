// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:web3dart/web3dart.dart';

import 'chain_sender.dart';

/// Algorand sender.
class AlgoSender implements ChainSender {
  final TokenViewApi _tokenViewApi;
  final Trustdart _trustdart;
  final AlgoApi _algoApi;
  final Object? Function() _ownerIdentity;
  final String? Function() _readMnemonic;
  bool _sending = false;
  static Object? _currentOwner() {
    try {
      if (!globalWapAdapter.isWalletReady) return null;
      return (
        AppGlobals.walletStorageUuid,
        AppGlobals.userInfo,
        globalWapAdapter.walletIndex,
        globalWapAdapter.walletInfo,
      );
    } catch (_) {
      return null;
    }
  }

  static String? _currentMnemonic() {
    try {
      return globalWapAdapter.isWalletReady
          ? globalWapAdapter.walletInfo.mnemonic
          : null;
    } catch (_) {
      return null;
    }
  }

  AlgoSender({
    TokenViewApi? tokenViewApi,
    Trustdart? trustdart,
    AlgoApi? algoApi,
    Object? Function()? ownerIdentity,
    String? Function()? readMnemonic,
  }) : _tokenViewApi = tokenViewApi ?? TokenViewApi(),
       _trustdart = trustdart ?? Trustdart(),
       _algoApi = algoApi ?? AlgoApi(),
       _ownerIdentity = ownerIdentity ?? _currentOwner,
       _readMnemonic = readMnemonic ?? _currentMnemonic;

  @override
  Future<SendResult> send(SendParams params) async {
    if (_sending) return const SendResult.fail('A transfer is already pending');
    _sending = true;
    try {
      final owner = _ownerIdentity();
      final mnemonic = params.privateKey == null ? _readMnemonic() : null;
      bool current() =>
          _ownerIdentity() == owner &&
          (params.privateKey != null ||
              (owner != null && mnemonic == _readMnemonic()));
      return await _send(params, mnemonic, current);
    } catch (_) {
      return const SendResult.fail(
        'Unable to prepare or send Algorand transfer',
      );
    } finally {
      _sending = false;
    }
  }

  Future<SendResult> _send(
    SendParams params,
    String? mnemonic,
    bool Function() current,
  ) async {
    final asset = params.contractAddress.isNotEmpty;
    final exact = asset
        ? params.tokenValueWeiOverride
        : params.valueWeiOverride;
    final value =
        exact ??
        ethToWeiString(
          params.amountDecimalString,
          asset ? params.tokenDecimals : params.decimals,
        );
    if (value <= BigInt.zero ||
        value > BigInt.from(0x7fffffffffffffff) ||
        (asset &&
            (!RegExp(r'^[0-9]+$').hasMatch(params.contractAddress) ||
                BigInt.tryParse(params.contractAddress) == null ||
                BigInt.parse(params.contractAddress) <= BigInt.zero ||
                BigInt.parse(params.contractAddress) >
                    BigInt.from(0x7fffffffffffffff)))) {
      return const SendResult.fail('Invalid transfer amount or asset ID');
    }
    if (!current() || (params.privateKey ?? mnemonic ?? '').trim().isEmpty) {
      return const SendResult.fail('Wallet is not ready');
    }
    final derived = await _trustdart.generateAddress(
      CoinType.ALGO.name,
      params.path,
      'legacy',
      mnemonic: params.privateKey == null ? mnemonic! : '',
      pk: params.privateKey ?? '',
      isTest: params.isTest,
    );
    if (!current() ||
        params.fromAddress.isEmpty ||
        derived['legacy'] != params.fromAddress) {
      return const SendResult.fail(
        'Signing key does not match the selected wallet',
      );
    }
    // Get balance
    final mmb =
        await _tokenViewApi.getBalance(
          BlockchainType.Algorand.name,
          CoinType.ALGO.name,
          params.fromAddress,
          isTest: params.isTest,
        ) ??
        MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final account = mmb.data as Map;
    final chainBalance = account['balance'] as BigInt;
    final reserve = account['minBalance'] as BigInt;
    if (chainBalance < BigInt.zero ||
        reserve < BigInt.zero ||
        reserve > chainBalance) {
      return const SendResult.fail('Invalid Algorand account balance');
    }
    var assetBalance = BigInt.zero;
    if (asset) {
      final response = await _tokenViewApi.getBalance(
        BlockchainType.Algorand.name,
        CoinType.ALGO.name,
        params.fromAddress,
        contract: params.contractAddress,
        isTest: params.isTest,
      );
      if (response == null || response.error) {
        return const SendResult.fail('Unable to load asset balance');
      }
      assetBalance = (response.data as Map)['balance'] as BigInt;
    }
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('ALGO'));
    }

    // Get gas price from transaction params
    final mminfo = await _algoApi.getTransactionsParams(isTest: params.isTest);
    if (mminfo.error) return SendResult.fail(mminfo.data?.toString());
    final txParams = mminfo.data as Map<String, dynamic>;
    final fee = txParams['min-fee'];
    final round = txParams['last-round'];
    final genesis = txParams['genesis-id'];
    final genesisHash = txParams['genesis-hash'];
    // Match the current native bridge's integer and base64 input contract.
    if (fee is! int ||
        fee <= 0 ||
        fee > 0x7fffffff ||
        round is! int ||
        round < 0 ||
        round > 0x7fffffff ||
        genesis is! String ||
        genesis.isEmpty ||
        genesisHash is! String ||
        base64Decode(genesisHash).length != 32) {
      return const SendResult.fail('Invalid Algorand transaction parameters');
    }
    final totalGasPrice = BigInt.from(fee);
    var valuePrice = value;
    double adjustedAmount = toEther(
      valuePrice.toString(),
      asset ? params.tokenDecimals : params.decimals,
    ).toDouble();
    if (!asset &&
        params.sendMax &&
        (valuePrice == chainBalance || valuePrice == chainBalance - reserve)) {
      valuePrice = chainBalance - reserve - totalGasPrice;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero ||
        (asset && valuePrice > assetBalance) ||
        (asset ? BigInt.zero : valuePrice) + totalGasPrice + reserve >
            chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('ALGO'));
    }
    if (!current()) {
      return const SendResult.fail('Wallet changed before signing');
    }

    final txData = <String, dynamic>{
      'type': asset ? 'Asset' : 'ALGO',
      'toAddress': params.toAddress,
      'amount': valuePrice.toString(),
      'assetId': params.contractAddress,
      'fee': txParams['min-fee'],
      'genesisId': txParams['genesis-id'],
      'genesisHash': txParams['genesis-hash'],
      'round': txParams['last-round'],
    };

    Map<dynamic, dynamic> rValue;
    if (params.privateKey != null) {
      rValue = await _trustdart.signTransactionByteArray(
        CoinType.ALGO.name,
        params.path,
        txData,
        pk: params.privateKey!,
      );
    } else {
      rValue = await _trustdart.signTransactionByteArray(
        CoinType.ALGO.name,
        params.path,
        txData,
        mnemonic: mnemonic!,
      );
    }

    if (!current() || rValue['result'] != true) {
      return SendResult.fail(S.current.g_key_wallet_m6);
    }
    final encoded = rValue['signHash'];
    if (encoded is! String ||
        !RegExp(r'^(?:0x)?(?:[0-9a-fA-F]{2})+$').hasMatch(encoded)) {
      return const SendResult.fail('Invalid signed Algorand transaction');
    }
    final Uint8List signBytes = hexToBytes(encoded);

    final sendMm =
        await _tokenViewApi.sendTx(
          BlockchainType.Algorand.name,
          CoinType.ALGO.name,
          signBytes,
          netMode: params.isTest ? 'test' : 'main',
        ) ??
        MessageModel.error();

    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    final hash = sendMm.data;
    if (hash is! String || hash.trim().isEmpty) {
      return const SendResult.fail('Missing Algorand transaction ID');
    }
    return SendResult.ok(hash, actualAmount: adjustedAmount);
  }
}
