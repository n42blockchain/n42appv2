import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/activity_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/atom_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/btc_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/dot_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/fil_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sol_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ton_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xtz_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/zil_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:decimal/decimal.dart';
import 'package:web3dart/web3dart.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/generated/l10n.dart';

part 'transfer/transfer_base.dart';
part 'transfer/transfer_evm.dart';
part 'transfer/transfer_btc.dart';
part 'transfer/transfer_sol.dart';
part 'transfer/transfer_trx.dart';
part 'transfer/transfer_cosmos_family.dart';
part 'transfer/transfer_others.dart';

class TransferApi
    with
        _TransferBaseMixin,
        _TransferEvmMixin,
        _TransferBtcMixin,
        _TransferSolMixin,
        _TransferTrxMixin,
        _TransferCosmosFamilyMixin,
        _TransferOthersMixin {

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// 交易成功后延迟上报活动事件
  void _pushTransactionActivity(String coinType, dynamic txData, String network) {
    final pushMap = {
      "uuid": AppGlobals.userInfo?.uuid ?? "",
      "coin": coinType,
      "tx": txData,
      "network": network,
    };
    ActivityApi().collectDelayPush(json.encode(pushMap), event: "transaction");
  }

  /// Convert isTest flag (0/1) to network string.
  static String _networkStr(int isTest) => isTest == 0 ? "main" : "test";

  /// Build derivation path from a transaction record model.
  static String _txPath(dynamic trModel, int pathIndex) =>
      getPathWithIndex(trModel.coin['path'][trModel.addrType], pathIndex);

  /// 转账方法
  /// chainSymbol 链缩写 例如：Bitcoin:btc或BTC都可以
  /// fromAddress 转出地址
  /// toAddress 转入地址
  /// value 转账金额 double类型
  /// maxValue 是否是最大转账金额，默认 是最大转账金额
  /// contractAddress 合约地址，如果是合约币转账，传入合约地址
  Future<MessageModel> transfer(
    String chainSymbol,
    String toAddress,
    double value, {
    String contractAddress = "",
    String fromAddress = "",
    bool isTest = false,
    bool maxValue = true,
    String? message,
  }) async {
    // ── Input validation ─────────────────────────────────────
    // Reject zero, negative, infinite, or NaN amounts
    if (value <= 0 || value.isNaN || value.isInfinite) {
      return MessageModel.error()..data = 'Invalid transfer amount';
    }
    // Reject empty or whitespace-only recipient address
    if (toAddress.trim().isEmpty) {
      return MessageModel.error()..data = 'Recipient address is empty';
    }
    // ─────────────────────────────────────────────────────────
    final WalletActionProvider wap = globalWapAdapter;
    chainSymbol = symbolDealWith(chainSymbol);
    final Map<String, dynamic>? txChainMap =
        wap.walletMap[chainSymbol.toString().toUpperCase()];
    if (txChainMap == null) {
      return MessageModel.error()..data = S.current.g_key_wallet_m1(chainSymbol);
    }

    Map<String, dynamic>? token;
    if (contractAddress != "") {
      final contractKey = contractAddress.toString().toUpperCase();
      if (isTest) {
        if (txChainMap['testnets']['testnetContract'].length != 0) {
          token = txChainMap['testnets']['testnetContract'][contractKey];
        }
      } else {
        if (txChainMap['mainnets'].length != 0) {
          token = txChainMap['mainnets'][contractKey];
        }
      }
      if (token == null) {
        return MessageModel.error()..data = S.current.g_key_wallet_m2;
      }
    }

    if (fromAddress == "") {
      final String? fAddress = wap.getAddress(
        txChainMap['baseInfo']['coinType'],
        addrType: txChainMap['addrType'],
      );
      if (fAddress == null) {
        return MessageModel.error()
          ..data = S.current.g_key_wallet_m3(txChainMap['baseInfo']['coinType']);
      }
      fromAddress = fAddress;
    }

    // Prevent self-send (same address after case-insensitive comparison)
    if (fromAddress.toLowerCase() == toAddress.toLowerCase()) {
      return MessageModel.error()..data = 'Cannot send to your own address';
    }

    final String blockchain = txChainMap['baseInfo']['blockchainType'];
    final int pathIndex = txChainMap["pathIndex"] ?? 0;
    final String path = getPathWithIndex(
      txChainMap['baseInfo']['path'][txChainMap['addrType']],
      pathIndex,
    );
    final String coinType = txChainMap['baseInfo']['coinType'];
    final baseInfo = txChainMap['baseInfo'];
    final int tokenDecimals = token == null ? 0 : token['decimals'];
    final String networkStr = isTest ? "test" : "main";
    MessageModel txmm = MessageModel();

    switch (blockchain) {
      case "Bitcoin":
        txmm = await transferBtc(
          coinType, fromAddress, toAddress, value, path,
          maxValue: maxValue, isTest: networkStr,
        );

      case "Ethereum":
        txmm = await transferEth(
          isTest ? baseInfo['chainId_test'] : baseInfo['chainId'],
          coinType, fromAddress, toAddress, value,
          baseInfo['decimals'], path,
          contractAddress: contractAddress,
          tokenDecimals: tokenDecimals,
          isTest: isTest, maxValue: maxValue, message: message,
        );

      case "Solana":
        txmm = await transferSol(
          txChainMap, fromAddress, toAddress, value,
          baseInfo['decimals'], path,
          contractAddress: contractAddress,
          tokenDecimals: tokenDecimals, maxValue: maxValue,
        );

      case "Tron":
        txmm = await transferTrx(
          fromAddress, toAddress, value, baseInfo['decimals'], path,
          contractAddress: contractAddress,
          tokenDecimals: tokenDecimals, maxValue: maxValue,
        );

      case "Algorand":
        return await transferAlgo(
          fromAddress, toAddress, value, baseInfo['decimals'], path,
          maxValue: maxValue,
        );

      case "Tezos":
        return await transferXtz(
          fromAddress, toAddress, value, baseInfo['decimals'], path,
          maxValue: maxValue,
        );

      case "Ripple":
        return await transferXrp(
          fromAddress, toAddress, value, baseInfo['decimals'], path,
          maxValue: maxValue,
        );

      case "Cosmos":
        return await transferAtom(
          fromAddress, toAddress, value, baseInfo['decimals'], path,
          maxValue: maxValue,
        );
    }

    if (txmm.error == false) {
      _pushTransactionActivity(coinType, txmm.data['txHash'], networkStr);
    }
    return txmm;
  }

  /// 钱包转账使用，此方法无需检测币是否存在，也无需检测转账是否无误
  Future<MessageModel> transferWallet({
    TransationRecordModel? trModel,
    BtcTransactionRecodeModel? trModelBtc,
    String? privateKey,
    int pathIndex = 0,
  }) async {
    final String blockchain = trModel == null
        ? trModelBtc!.coin['blockchainType']
        : trModel.coin['blockchainType'];
    MessageModel txmm = MessageModel();
    String coinType = "";
    String network = "main";

    switch (blockchain) {
      case "Bitcoin":
        coinType = trModelBtc!.coin['coinType'];
        network = _networkStr(trModelBtc.isTest);
        txmm = await transferBtcSend(
          trModelBtc.coin['coinType'],
          trModelBtc.address,
          trModelBtc.to1,
          trModelBtc.price,
          _txPath(trModelBtc, pathIndex),
          trModelBtc.gas,
          trModelBtc.gasPrice,
          trModelBtc.inputModelsMap(),
          max: trModelBtc.max,
          privateKey: privateKey,
          isTest: network,
        );

      case "Ethereum":
        coinType = trModel!.coin['coinType'];
        network = _networkStr(trModel.isTest);
        final path = _txPath(trModel, pathIndex);
        final gasPrice2Double = toEther(
          trModel.gasPriceValue.toString(),
          trModel.coin['decimals'],
        ).toDouble() / 2;
        final BigInt gasPrice2 = ethToWeiString(
          Decimal.parse(gasPrice2Double.toString()).toString(),
          trModel.coin['decimals'],
        );
        final String? rpc = trModel.isTest == 0
            ? trModel.coin['service']
            : trModel.coin['service_test'];
        txmm = await transferEthSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          path,
          trModel.gasPriceValue,
          gasPrice2,
          trModel.gas,
          trModel.coin['coinType'],
          trModel.isTest == 0 ? trModel.coin['chainId'] : trModel.coin['chainId_test'],
          contractAddress: trModel.contract,
          isTest: network,
          privateKey: privateKey,
          nonce: trModel.nonce,
          message: trModel.message,
          erc721Or1155: trModel.erc721Or1155,
          returnSignHash: trModel.returnSignHash,
          rpc: rpc,
        );

      case "Solana":
        coinType = CoinType.SOL.name;
        network = _networkStr(trModel!.isTest);
        txmm = await transferSolSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          _txPath(trModel, pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          tokenDecimals: trModel.coin['decimals'],
          isTest: network,
          privateKey: privateKey,
        );

      case "Tron":
        coinType = CoinType.TRX.name;
        network = _networkStr(trModel!.isTest);
        txmm = await transferTrxSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          _txPath(trModel, pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          isTest: network,
          privateKey: privateKey,
        );

      case "Algorand":
        coinType = CoinType.ALGO.name;
        network = _networkStr(trModel!.isTest);
        String type = "ALGO";
        if (trModel.contract != "") type = "Asset";
        if (trModel.other != null) type = trModel.other.type;
        txmm = await transferAlgoSend(
          trModel.from1,
          trModel.to1,
          trModel.price.toString(),
          _txPath(trModel, pathIndex),
          isTest: network,
          privateKey: privateKey,
          contractAddress: trModel.contract,
          type: type,
        );

      case "Tezos":
        coinType = CoinType.XTZ.name;
        network = _networkStr(trModel!.isTest);
        txmm = await transferXtzSend(
          trModel.from1,
          trModel.to1,
          trModel.price.toInt(),
          _txPath(trModel, pathIndex),
          isTest: trModel.isTest != 0,
          privateKey: privateKey,
        );

      case "Ripple":
        coinType = CoinType.XRP.name;
        network = _networkStr(trModel!.isTest);
        txmm = await transferXrpSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          trModel.gasPrice,
          _txPath(trModel, pathIndex),
          trModel.other.sequence,
          isTest: trModel.isTest != 0,
          privateKey: privateKey,
          destinationTag: trModel.other.destinationTag,
        );

      case "Filecoin":
        coinType = CoinType.FIL.name;
        network = _networkStr(trModel!.isTest);
        txmm = await transferFilSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          trModel.gasPrice,
          _txPath(trModel, pathIndex),
          trModel.nonce ?? "0",
          trModel.gas.toString(),
          trModel.other.gasFeeCap,
          trModel.other.gasPremium,
          isTest: trModel.isTest != 0,
        );

      case "Cosmos":
        coinType = CoinType.ATOM.name;
        network = _networkStr(trModel!.isTest);
        txmm = await transferAtomSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          _txPath(trModel, pathIndex),
          trModel.gasPrice,
          contractAddress: trModel.contract,
          isTest: network,
          privateKey: privateKey,
        );

      case "Polkadot":
        coinType = trModel!.coin['coinType'];
        network = _networkStr(trModel.isTest);
        txmm = await transferDotSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          _txPath(trModel, pathIndex),
          trModel.gasPrice,
          coinType,
          contractAddress: trModel.contract,
          isTest: network,
          privateKey: privateKey,
          returnSignHash: trModel.returnSignHash,
        );

      case "Aptos":
        coinType = trModel!.coin['coinType'];
        network = _networkStr(trModel.isTest);
        txmm = await transferAptSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          _txPath(trModel, pathIndex),
          trModel.gas,
          trModel.gasPrice,
          coinType,
          trModel.coinId,
        );

      case "TheOpenNetwork":
        coinType = trModel!.coin['coinType'];
        network = _networkStr(trModel.isTest);
        txmm = await transferTonSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          _txPath(trModel, pathIndex),
          trModel.gas,
          trModel.gasPrice,
          coinType,
          isTest: network,
        );

      case "Zilliqa":
        coinType = trModel!.coin['coinType'];
        network = _networkStr(trModel.isTest);
        txmm = await transferZilSend(
          trModel.from1,
          trModel.to1,
          trModel.price,
          _txPath(trModel, pathIndex),
          trModel.gas,
          trModel.gasPrice,
          coinType,
          isTest: network,
          privateKey: privateKey,
        );
    }

    if (txmm.error == false) {
      _pushTransactionActivity(coinType, txmm.data, network);
    }
    return txmm;
  }
}
