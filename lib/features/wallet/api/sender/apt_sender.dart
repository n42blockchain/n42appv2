// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';

import 'chain_sender.dart';
import '../../services/apt_submission_journal.dart';
import '../../utils/aptos/coin_transfer.dart';

/// Aptos chain sender.
class AptSender implements ChainSender {
  final Map<String, dynamic>? _defaultChainConfig;
  final Trustdart _trustdart;
  final AptApi Function(bool isTest) _apiFactory;
  final Object? Function() _ownerIdentity;
  final String? Function() _readMnemonic;
  final AptSubmissionJournal _journal;
  final Future<void> Function(AptPendingSubmission, AptTransactionReceipt)?
  _reconcileWriter;

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

  AptSender({
    Map<String, dynamic>? chainConfig,
    Trustdart? trustdart,
    AptApi Function(bool isTest)? apiFactory,
    Object? Function()? ownerIdentity,
    String? Function()? readMnemonic,
    AptSubmissionJournal? journal,
    Future<void> Function(AptPendingSubmission, AptTransactionReceipt)?
    reconcileWriter,
  }) : _reconcileWriter = reconcileWriter,
       _defaultChainConfig = chainConfig,
       _trustdart = trustdart ?? Trustdart(),
       _apiFactory = apiFactory ?? ((isTest) => AptApi(isTest: isTest)),
       _ownerIdentity = ownerIdentity ?? _currentOwner,
       _readMnemonic = readMnemonic ?? _currentMnemonic,
       _journal = journal ?? AptSubmissionJournal();

  @override
  Future<SendResult> send(SendParams params) async {
    // Capture the signing account and its mnemonic before any asynchronous
    // work: a wallet switch must never sign with the replacement mnemonic.
    final owner = _ownerIdentity();
    if (owner == null) return const SendResult.fail('Wallet is not ready');
    final mnemonic = params.privateKey == null ? _readMnemonic() : null;
    if ((params.privateKey ?? mnemonic ?? '').trim().isEmpty) {
      return const SendResult.fail('Wallet is not ready');
    }
    bool ownerIsCurrent() {
      try {
        return _ownerIdentity() == owner &&
            (params.privateKey != null || mnemonic == _readMnemonic());
      } catch (_) {
        return false;
      }
    }

    final coinType = params.coinType.toUpperCase();
    // Resolve mutable configuration before the first asynchronous operation.
    final int? resolvedChainId = resolveChainConfigIdOrNull(
      params.chainConfig ?? _defaultChainConfig,
      isTest: params.isTest,
    );
    // Aptos 测试网 chain_id=2；缺配置时回退 1 签出的交易在主网合法，拒发。
    if (params.isTest && resolvedChainId == null) {
      return SendResult.fail('Missing testnet chain ID for $coinType');
    }
    final chainId = resolvedChainId ?? 1;
    if (chainId < 1 || chainId > 255) {
      return const SendResult.fail('Invalid Aptos chain ID');
    }

    try {
      var pending = await _journal.pending(chainId, params.fromAddress);
      if (pending != null) {
        // Settle the previous submission from chain state first (receipt by
        // hash, then the sequence/expiry proof). Only an outcome that is still
        // pending or undeterminable keeps the account blocked for recovery.
        try {
          await _journal.reconcile(
            chainId: chainId,
            sender: params.fromAddress,
            api: _apiFactory(params.isTest),
            saveResult:
                _reconcileWriter ?? AppDatabase().completeAptFromReceipt,
          );
        } catch (_) {
          // Unknown stays unknown: the durable record is kept.
        }
        pending = await _journal.pending(chainId, params.fromAddress);
      }
      if (pending != null) {
        return SendResult.uncertain(
          pending.hash,
          'Reconcile the original Aptos transaction',
        );
      }
    } catch (e) {
      return SendResult.fail(e.toString());
    }
    if (!ownerIsCurrent()) {
      return const SendResult.fail('Wallet changed before Aptos signing');
    }
    final isContract = params.contractAddress.isNotEmpty;
    final isFungibleAsset =
        isContract &&
        RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(params.contractAddress) &&
        !params.contractAddress.contains(RegExp(r'\s'));
    AptosCoinType? genericCoin;
    if (isContract &&
        !isFungibleAsset &&
        params.contractAddress.contains('<')) {
      try {
        genericCoin = AptosCoinType.parse(params.contractAddress);
      } on FormatException catch (e) {
        return SendResult.fail(e.message);
      }
      if (chainId != 1 && chainId != 2) {
        return const SendResult.fail(
          'Generic Aptos Coin signing supports mainnet and testnet',
        );
      }
    }
    final assetParts = params.contractAddress.split('::');
    if (isContract &&
        !isFungibleAsset &&
        genericCoin == null &&
        (assetParts.length != 3 ||
            !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(assetParts[0]) ||
            !RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(assetParts[1]) ||
            !RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(assetParts[2]) ||
            params.contractAddress.contains(RegExp(r'\s')))) {
      return const SendResult.fail(
        'Aptos coin transfer requires a complete non-generic asset type',
      );
    }
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

    if (isContract) {
      if (valuePrice > chainBalance) {
        return const SendResult.fail('Insufficient Aptos token balance');
      }
      final nativeBalance = await aptApi.getBalance(params.fromAddress);
      if (nativeBalance.error) {
        return SendResult.fail(nativeBalance.data?.toString());
      }
      if (nativeBalance.data is! BigInt || nativeBalance.data < totalGasPrice) {
        return const SendResult.fail(
          'Insufficient APT balance for transaction fees',
        );
      }
    }

    // Get account sequence and ledger timestamp
    final sequenceNumber = await aptApi.getAccountInfo(params.fromAddress);
    if (sequenceNumber.error) {
      return SendResult.fail(sequenceNumber.data?.toString());
    }

    final ledgerTimestamp = await aptApi.getServiceInfo(
      expectedChainId: chainId,
    );
    if (ledgerTimestamp.error) {
      return SendResult.fail(ledgerTimestamp.data?.toString());
    }
    final BigInt sequence;
    final BigInt lt;
    try {
      sequence = AptApi.parseUint64(sequenceNumber.data);
      final micros = AptApi.parseUint64(ledgerTimestamp.data);
      if (micros == BigInt.zero) {
        return const SendResult.fail('Invalid Aptos ledger timestamp');
      }
      lt = micros ~/ BigInt.from(1000000) + BigInt.from(60);
    } on FormatException {
      return const SendResult.fail('Invalid Aptos account or ledger response');
    }

    final signMap = <String, dynamic>{
      'amount': valuePrice.toString(),
      'toAddress': params.toAddress,
      'SequenceNumber': sequence.toString(),
      'fromAddress': params.fromAddress,
      'type': isFungibleAsset ? 'APT_FA_TRANSFER' : 'APT_TRANSFER',
      'contractAddress': isContract ? assetParts[0] : '',
      'contractModule': isContract && !isFungibleAsset ? assetParts[1] : '',
      'contractName': isContract && !isFungibleAsset ? assetParts[2] : '',
      'gasUnitPrice': gasPrice.toString(),
      'maxGasAmount': gas,
      'expirationTimestampSecs': lt.toString(),
      'chainId': chainId,
    };

    Uint8List? genericRaw;
    if (genericCoin != null) {
      try {
        genericRaw = genericCoin.transfer(
          sender: params.fromAddress,
          recipient: params.toAddress,
          sequence: sequence,
          amount: valuePrice,
          maxGas: BigInt.from(gas),
          gasPrice: gasPrice,
          expiration: lt,
          chainId: chainId,
        );
      } on FormatException catch (e) {
        return SendResult.fail(e.message);
      }
      signMap['type'] = 'WC_APT';
      signMap['encodedTransaction'] = base64Encode(genericRaw);
    }
    if (!ownerIsCurrent()) {
      return const SendResult.fail('Wallet changed before Aptos signing');
    }
    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        coinType,
        params.path,
        signMap,
        mnemonic: mnemonic!,
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

    if (genericRaw != null) {
      final expected = genericRaw
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      final signed = signStr.replaceFirst(RegExp(r'^0[xX]'), '').toLowerCase();
      if (signed.length != expected.length + 198 ||
          !signed.startsWith(expected)) {
        return const SendResult.fail(
          'Signed Aptos transfer differs from approved transaction',
        );
      }
    }

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

    if (!ownerIsCurrent()) {
      return const SendResult.fail('Wallet changed before Aptos submission');
    }
    String? dispatchedHash;
    try {
      final record = await _journal.broadcast(
        chainId: chainId,
        sender: params.fromAddress,
        sequence: sequence,
        expirationSeconds: lt,
        signedTx: signStr,
        isCurrent: ownerIsCurrent,
        beforePersist: (record) async =>
            params.beforeBroadcast?.call(record.hash),
        send: (record) async {
          dispatchedHash = record.hash;
          final result = await aptApi.sendTxHash(signStr);
          if (result.error || result.data != record.hash) {
            throw StateError('Aptos submission outcome is unconfirmed');
          }
        },
      );
      return SendResult.ok(record.hash, actualAmount: adjustedAmount);
    } on AptSubmissionPending catch (e) {
      return SendResult.uncertain(e.submission.hash, e.message);
    } catch (e) {
      return dispatchedHash == null
          ? SendResult.fail(e.toString())
          : SendResult.uncertain(dispatchedHash, e.toString());
    }
  }
}
