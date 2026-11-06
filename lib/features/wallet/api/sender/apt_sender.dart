// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';

import 'chain_sender.dart';

/// Aptos chain sender.
class AptSender implements ChainSender {
  final Map<String, dynamic>? _defaultChainConfig;
  final Trustdart _trustdart;
  final AptApi Function(bool isTest) _apiFactory;

  AptSender({
    Map<String, dynamic>? chainConfig,
    Trustdart? trustdart,
    AptApi Function(bool isTest)? apiFactory,
  }) : _defaultChainConfig = chainConfig,
       _trustdart = trustdart ?? Trustdart(),
       _apiFactory = apiFactory ?? ((isTest) => AptApi(isTest: isTest));

  @override
  Future<SendResult> send(SendParams params) async {
    final coinType = params.coinType.toUpperCase();
    final isContract = params.contractAddress.isNotEmpty;
    final gas = getCoinGas(coinType, contract: isContract);
    final aptApi = _apiFactory(params.isTest);

    // Get balance
    final mm = await aptApi.getBalance(
      params.fromAddress,
      contract: params.contractAddress,
    );
    if (mm.error) return SendResult.fail(mm.data?.toString());
    final chainBalance = mm.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Get gas price
    final mmg = await aptApi.getGasPrice();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
    if (gasPrice <= BigInt.zero ||
        gasPrice > ((BigInt.one << 64) - BigInt.one)) {
      return const SendResult.fail('Invalid Aptos gas unit price');
    }
    final totalGasPrice = gasPrice * BigInt.from(gas);

    final exactAmount = isContract
        ? params.tokenValueWeiOverride
        : params.valueWeiOverride;
    BigInt valuePrice =
        exactAmount ??
        ethToWeiString(
          params.amountDecimalString,
          isContract ? params.tokenDecimals : params.decimals,
        );
    if (valuePrice <= BigInt.zero || valuePrice >= (BigInt.one << 64)) {
      return const SendResult.fail('Invalid Aptos transfer amount');
    }
    double adjustedAmount = params.amount;

    if (!isContract) {
      if (valuePrice == chainBalance && params.sendMax) {
        if (totalGasPrice >= valuePrice) {
          return SendResult.fail(S.current.g_key_wallet_m5(coinType));
        }
        valuePrice = valuePrice - totalGasPrice;
        adjustedAmount = toEther(
          valuePrice.toString(),
          params.decimals,
        ).toDouble();
      }
      if (valuePrice <= BigInt.zero ||
          totalGasPrice + valuePrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
    }

    // Get account sequence and ledger timestamp
    final sequenceNumber = await aptApi.getAccountInfo(params.fromAddress);
    if (sequenceNumber.error) {
      return SendResult.fail(sequenceNumber.data?.toString());
    }

    final ledgerTimestamp = await aptApi.getServiceInfo();
    if (ledgerTimestamp.error) {
      return SendResult.fail(ledgerTimestamp.data?.toString());
    }
    final lt = (ledgerTimestamp.data as int) ~/ 1000000 + 60;

    final int? resolvedChainId = resolveChainConfigIdOrNull(
      params.chainConfig ?? _defaultChainConfig,
      isTest: params.isTest,
    );
    // Aptos 测试网 chain_id=2；缺配置时回退 1 签出的交易在主网合法，拒发。
    if (params.isTest && resolvedChainId == null) {
      return SendResult.fail('Missing testnet chain ID for $coinType');
    }
    final chainId = resolvedChainId ?? 1;

    final signMap = <String, dynamic>{
      'amount': valuePrice.toString(),
      'toAddress': params.toAddress,
      'SequenceNumber': sequenceNumber.data,
      'fromAddress': params.fromAddress,
      'contractAddress': params.contractAddress,
      'contractModule': '',
      'contractName': '',
      'gasUnitPrice': gasPrice.toString(),
      'maxGasAmount': gas,
      'expirationTimestampSecs': lt,
      'chainId': chainId,
    };

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        coinType,
        params.path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        coinType,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

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

    final sendMm = await aptApi.sendTxHash(signStr);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
