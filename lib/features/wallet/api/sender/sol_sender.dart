// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';
import 'sol_transaction_message.dart';

/// Solana chain sender.
class SolSender implements ChainSender {
  final SolApi _api;
  final Trustdart _trustdart;
  bool _sending = false;

  SolSender({SolApi? api, Trustdart? trustdart})
    : _api = api ?? SolApi(),
      _trustdart = trustdart ?? Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    if (_sending) return const SendResult.fail('A transfer is already pending');
    _sending = true;
    try {
      return await _send(params);
    } catch (_) {
      return const SendResult.fail('Unable to prepare or send Solana transfer');
    } finally {
      _sending = false;
    }
  }

  Future<SendResult> _send(SendParams params) async {
    final isContract = params.contractAddress.isNotEmpty;
    if (!params.amount.isFinite || params.amount <= 0) {
      return const SendResult.fail('Invalid transfer amount');
    }
    var valuePrice = isContract
        ? params.tokenValueWeiOverride ??
              ethToWeiString(params.amount.toString(), params.tokenDecimals)
        : params.valueWeiOverride ??
              ethToWeiString(params.amount.toString(), params.decimals);
    if (valuePrice <= BigInt.zero ||
        valuePrice > (BigInt.one << 64) - BigInt.one) {
      return const SendResult.fail('Invalid transfer amount');
    }
    final sourceTokenAccount = isContract
        ? await _trustdart.getPubKeySOL(
            params.fromAddress,
            params.contractAddress,
          )
        : '';
    if (isContract && sourceTokenAccount.isEmpty) {
      return const SendResult.fail('Failed to get token account');
    }
    final mmb = isContract
        ? await _api.getTokenAccountBalance(
            sourceTokenAccount,
            isTest: params.isTest,
          )
        : await _api.getBalance(params.fromAddress, '', isTest: params.isTest);
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final balance = mmb.data as BigInt;
    if (valuePrice > balance) {
      return SendResult.fail(
        isContract
            ? S.current.g_key_wallet_m4
            : S.current.g_key_wallet_m5('SOL'),
      );
    }
    var chainBalance = balance;
    if (isContract) {
      final native = await _api.getBalance(
        params.fromAddress,
        '',
        isTest: params.isTest,
      );
      if (native.error) return SendResult.fail(native.data?.toString());
      chainBalance = native.data as BigInt;
    }
    double adjustedAmount = params.amount;

    // Send
    final solApi = _api;
    String recipientTokenAddress = '';
    var accountRent = BigInt.zero;
    if (isContract) {
      recipientTokenAddress = await _trustdart.getPubKeySOL(
        params.toAddress,
        params.contractAddress,
      );
      if (recipientTokenAddress.isEmpty) {
        return const SendResult.fail('Failed to get token account');
      }
      final rdataAccount = await solApi.getAccountInfo(
        recipientTokenAddress,
        isTest: params.isTest,
      );
      if (rdataAccount.error) {
        return SendResult.fail(rdataAccount.data?.toString());
      }
      if (rdataAccount.data == null) {
        recipientTokenAddress = '';
        final rent = await solApi.getTokenAccountRent(isTest: params.isTest);
        if (rent.error) return SendResult.fail(rent.data?.toString());
        accountRent = rent.data as BigInt;
      }
    }

    // Get latest blockhash
    final mmblock = await solApi.getLatestBlockhash(isTest: params.isTest);
    if (mmblock.error) return SendResult.fail(mmblock.data?.toString());
    final recentBlockhash = mmblock.data as String;

    // Build tx data
    Map<String, dynamic> txData;
    if (!isContract) {
      txData = {
        'type': 'SOL',
        'recentBlockhash': recentBlockhash,
        'transferTransaction': {
          'recipient': params.toAddress,
          'value': valuePrice.toString(),
        },
        'encodeType': 'base58',
      };
    } else {
      txData = {
        'type': 'tokenCreate',
        'recentBlockhash': recentBlockhash,
        'tokenTransferTransaction': {
          'tokenMintAddress': params.contractAddress,
          'senderTokenAddress': params.fromAddress,
          'recipientTokenAddress': recipientTokenAddress,
          'recipientMainAddress': params.toAddress,
          'amount': valuePrice.toString(),
          'decimals': params.tokenDecimals.toString(),
        },
        'encodeType': 'base58',
      };
    }

    Future<String> sign() async {
      if (params.privateKey == null) {
        if (!AppGlobals.appContext.mounted) return '';
        return _trustdart.signTransaction(
          CoinType.SOL.name,
          params.path,
          txData,
          mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
        );
      }
      return _trustdart.signTransaction(
        CoinType.SOL.name,
        params.path,
        txData,
        pk: params.privateKey!,
      );
    }

    var signStr = await sign();
    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // Validate signature
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: CoinType.SOL.name,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(
        sigResult.errorMessage ?? 'Signature validation failed',
      );
    }

    final fee = await solApi.getFeeForMessage(
      solTransactionMessage(signStr),
      isTest: params.isTest,
    );
    if (fee.error) return SendResult.fail(fee.data?.toString());
    final totalGasPrice = (fee.data as BigInt) + accountRent;
    if (!isContract && params.sendMax && valuePrice == balance) {
      valuePrice -= totalGasPrice;
      if (valuePrice <= BigInt.zero) {
        return SendResult.fail(S.current.g_key_wallet_m5('SOL'));
      }
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
      (txData['transferTransaction'] as Map<String, dynamic>)['value'] =
          valuePrice.toString();
      signStr = await sign();
      // Validate the re-signed transaction before broadcasting it.
      solTransactionMessage(signStr);
    }
    if ((isContract ? BigInt.zero : valuePrice) + totalGasPrice >
        chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('SOL'));
    }

    final sendMm = await solApi.sendTransaction(signStr, isTest: params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    final hash = sendMm.data?.toString();
    if (hash == null || hash.trim().isEmpty) {
      return const SendResult.fail('Missing Solana transaction signature');
    }
    return SendResult.ok(hash, actualAmount: adjustedAmount);
  }
}
