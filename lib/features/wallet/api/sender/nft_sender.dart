// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// EVM NFT sender — handles ERC-721 and ERC-1155 transfers.
///
/// Requires [SendParams.contractAddress], [SendParams.nftTokenId],
/// [SendParams.nftStandard] ('ERC721' or 'ERC1155'), and optionally
/// [SendParams.nftQuantity] (defaults to 1 for ERC721).
class NftSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

  @override
  Future<SendResult> send(SendParams params) async {
    final coinType = params.coinType;
    final tokenId = params.nftTokenId ?? '';
    final nftStandard = params.nftStandard ?? 'ERC721';
    final nftQuantity = params.nftQuantity ?? 1;

    if (tokenId.isEmpty) {
      return SendResult.fail('NFT token ID is required');
    }
    if (params.contractAddress.isEmpty) {
      return SendResult.fail('NFT contract address is required');
    }

    final chainId = resolveChainConfigId(
      params.chainConfig,
      isTest: params.isTest,
    );
    final gas = getCoinGas(coinType, contract: true);

    // Chain balance for gas
    final mmchain =
        await _tokenViewApi.getBalance(
          BlockchainType.Ethereum.name,
          coinType,
          params.fromAddress,
          contract: '',
          isTest: params.isTest,
        ) ??
        _errMM();
    if (mmchain.error) return SendResult.fail(mmchain.data?.toString());
    final chainBalance = mmchain.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Gas price
    final mmg =
        await _tokenViewApi.getGasPrice(
          BlockchainType.Ethereum.name,
          coinType,
          isTest: params.isTest,
        ) ??
        _errMM();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());

    final baseFee = mmg.data as BigInt;
    final gasPrice = get1559WithChainSymbol(coinType)
        ? baseFee * BigInt.from(2)
        : baseFee;

    // Sign
    final signResult = await _sign(
      coinType: coinType,
      path: params.path,
      fromAddress: params.fromAddress,
      toAddress: params.toAddress,
      gasPrice: gasPrice,
      gasPrice2: baseFee,
      gasLimit: gas,
      chainId: chainId,
      contractAddress: params.contractAddress,
      isTest: params.isTest,
      privateKey: params.privateKey,
      tokenId: tokenId,
      nftStandard: nftStandard,
      nftQuantity: nftQuantity,
    );
    if (signResult is SendResult) return signResult;

    final signStr = signResult as String;

    // Validate
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: coinType,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(
        sigResult.errorMessage ?? 'Signature validation failed',
      );
    }

    // Broadcast
    final sendMm =
        await _tokenViewApi.sendTx(
          BlockchainType.Ethereum.name,
          coinType,
          signStr,
          netMode: params.isTest ? 'test' : 'main',
        ) ??
        _errMM();

    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString());
  }

  Future<Object> _sign({
    required String coinType,
    required String path,
    required String fromAddress,
    required String toAddress,
    required BigInt gasPrice,
    required BigInt gasPrice2,
    required int gasLimit,
    required int chainId,
    required String contractAddress,
    required String tokenId,
    required String nftStandard,
    required int nftQuantity,
    bool isTest = false,
    String? privateKey,
  }) async {
    final gasPriceHex = _dataUtils.bigIntToHex(gasPrice, need0x: false);
    final gasPrice2Hex = _dataUtils.bigIntToHex(gasPrice2, need0x: false);
    final chainIdHex = _dataUtils.bigIntToHex(
      BigInt.from(chainId),
      need0x: false,
    );
    final gasLimitHex = _dataUtils.bigIntToHex(
      BigInt.from(gasLimit),
      need0x: false,
    );
    final amountHex = _dataUtils.bigIntToHex(BigInt.zero, need0x: false);
    final tokenIdHex = _dataUtils.bigIntToHex(
      BigInt.parse(tokenId),
      need0x: false,
    );
    final trValueHex = _dataUtils.bigIntToHex(
      BigInt.from(nftQuantity),
      need0x: false,
    );

    // Nonce
    final mmn = await _tokenViewApi.getTransactionCountEth(
      coinType,
      fromAddress,
      netMode: isTest ? 'test' : 'main',
    );
    if (mmn.error) return SendResult.fail(mmn.data?.toString());
    final nonceHex = _dataUtils.bigIntToHex(mmn.data, need0x: false);

    if (gasPrice == BigInt.zero) return SendResult.fail('Gas price error');

    final signMap = <String, String>{
      'chainId': chainIdHex,
      'gasPrice': gasPriceHex,
      'gasPrice2': gasPrice2Hex,
      'gasLimit': gasLimitHex,
      'toAddress': toAddress,
      'nonce': nonceHex,
      'contract': contractAddress.toLowerCase(),
      'amount': amountHex,
      'erc721Or1155': nftStandard,
      'tokenId': tokenIdHex,
      'trValue': trValueHex,
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
