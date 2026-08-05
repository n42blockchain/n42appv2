// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// Solana chain sender.
class SolSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    final isContract = params.contractAddress.isNotEmpty;
    final gas = getCoinGas(CoinType.SOL.name, contract: isContract);

    // Get SOL balance (and token balance if applicable)
    BigInt balance;
    final mmb =
        await _tokenViewApi.getBalance(
          BlockchainType.Solana.name,
          '',
          params.fromAddress,
          contract: params.contractAddress,
        ) ??
        MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    balance = mmb.data as BigInt;

    if (balance == BigInt.zero) {
      return SendResult.fail(
        isContract
            ? S.current.g_key_wallet_m4
            : S.current.g_key_wallet_m5('SOL'),
      );
    }

    // Get native SOL balance for gas
    BigInt chainBalance = balance;
    if (isContract) {
      final mmchain =
          await _tokenViewApi.getBalance(
            BlockchainType.Solana.name,
            '',
            params.fromAddress,
            contract: '',
          ) ??
          MessageModel.error();
      if (mmchain.error) return SendResult.fail(mmchain.data?.toString());
      chainBalance = mmchain.data as BigInt;
    }

    // Gas price
    final mmgas =
        await _tokenViewApi.getGasPrice(
          BlockchainType.Solana.name,
          CoinType.SOL.name,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmgas.error) return SendResult.fail(mmgas.data?.toString());
    final gasPrice = mmgas.data as BigInt;
    final totalGasPrice = gasPrice * BigInt.from(gas);

    BigInt valuePrice;
    double adjustedAmount = params.amount;

    if (!isContract) {
      valuePrice = ethToWeiString(params.amount.toString(), params.decimals);
      if (valuePrice == chainBalance && params.sendMax) {
        if (totalGasPrice >= valuePrice) {
          return SendResult.fail(S.current.g_key_wallet_m5('SOL'));
        }
        valuePrice = valuePrice - totalGasPrice;
        adjustedAmount = toEther(
          valuePrice.toString(),
          params.decimals,
        ).toDouble();
      }
      if (valuePrice <= BigInt.zero ||
          totalGasPrice + valuePrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5('SOL'));
      }
    } else {
      valuePrice = ethToWeiString(
        params.amount.toString(),
        params.tokenDecimals,
      );
      if (totalGasPrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5('SOL'));
      }
      if (valuePrice > balance) {
        return SendResult.fail(S.current.g_key_wallet_m4);
      }
    }

    // Send
    final solApi = SolApi();
    String recipientTokenAddress = '';
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
      if (rdataAccount.data == null) recipientTokenAddress = '';
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

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.SOL.name,
        params.path,
        txData,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.SOL.name,
        params.path,
        txData,
        pk: params.privateKey!,
      );
    }

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

    final sendMm = await solApi.sendTransaction(signStr, isTest: params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
