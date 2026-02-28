import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';

import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/api/gas_tracker_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/eth_layer2_chains.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Business logic mixin for _WalletChainSendState.
///
/// Handles Gas estimation, balance fetching, amount validation, and the
/// full send/sign transaction flow.
mixin SendLogicMixin<T extends StatefulWidget> on State<T> {
  // Abstract requirements that the host State must satisfy.
  CoinModel get coinModel;
  CoinModel? get chainModel;
  set chainModel(CoinModel? v);

  // ref is provided by ConsumerState as a late final field.
  WidgetRef get ref;
  Regular get regular;
  TokenViewApi get tokenViewApi;

  // Gas & balance state
  BigInt totalGasPrice = BigInt.zero;
  BigInt gasPrice = BigInt.zero;
  BigInt gasPriceEth = BigInt.zero;
  BigInt gas = BigInt.zero;
  BigInt gasEth = BigInt.zero;
  BigInt transferValue = BigInt.zero;

  GasEstimateModel? gasEstimate;
  bool useAdvancedGas = false;

  Load load = Load.loading;
  Load gasLimitLoad = Load.finish;

  // Error messages
  String toErrorMessage = '';
  String noteErrorMessage = '';
  String amountErrorMessage = '';
  String errorMessage = '';

  // Controllers provided by host
  TextEditingController get toTextEditingController;
  TextEditingController get valueTextEditingController;
  TextEditingController get noteTextEditingController;

  // Helpers provided by host
  Future<String?> toAddressCheck(String addr);
  void closeKeyboard();

  // Init

  Future<void> initData() async {
    if (coinModel.coin['isContract'] as bool? ?? false) {
      final wap = ref.read(wapBridgeProvider);
      final coinType = coinModel.coin['coinType'];
      final idx = wap.coinModels.indexWhere((e) {
        if (e.coin['coinType'] != coinType) return false;
        if (coinModel.privateKey != null) {
          return e.privateKey == coinModel.privateKey;
        }
        return true;
      });
      chainModel = wap.coinModels[idx];
      await chainModel?.getBalance();
      setState(() {});
    }
    gas = BigInt.from(getCoinGas(
      coinModel.coin['coinType'],
      contract: coinModel.coin['isContract'],
    ));
    await getBalance();
    await getGasPrice();
    if (getEthLayer2(coinModel.coin['coinType'])) {
      gasEth = BigInt.from(getCoinGas(CoinType.ETH.name));
      await getGasPriceLayer2();
    }
  }

  Future<void> getBalance() async {
    setState(() => load = Load.loading);
    final isOk = await coinModel.getBalance(getToken: false);
    if (isOk != false) return;
    errorMessage = S.current.g_key_t_44;
    ToastUtils.show(errorMessage);
    setState(() => load = Load.finish);
  }

  /// 解析当前 coinModel 的 RPC 地址（自定义链返回对应 service，否则 null）
  String? _resolveRpc() {
    if (coinModel.coin['custom'] != true) return null;
    return coinModel.isTest
        ? coinModel.coin['service_test']
        : coinModel.coin['service'];
  }

  Future<void> getGasPrice() async {
    setState(() => load = Load.loading);
    final blockchainType = coinModel.coin['blockchainType'] as String;
    final coinType = coinModel.coin['coinType'] as String;
    final isEthereum = blockchainType == BlockchainType.Ethereum.name;

    if (isEthereum) {
      await _fetchAdvancedGasEstimate();
    }
    final mm = await tokenViewApi.getGasPrice(
          blockchainType,
          coinType,
          isTest: coinModel.isTest,
          rpc: _resolveRpc(),
        ) ??
        MessageModel.error();
    if (mm.error == false) {
      gasPrice = mm.data;
      if (get1559WithChainSymbol(coinType) && isEthereum) {
        gasPrice = gasPrice * BigInt.from(2);
      }
    } else {
      errorMessage = mm.data.toString();
      ToastUtils.show(errorMessage);
    }
    if (gasEstimate != null && useAdvancedGas) {
      totalGasPrice = gasEstimate!.currentTotalFee;
      gasPrice = gasEstimate!.currentOption.effectiveGasPrice;
      gas = gasEstimate!.gasLimit;
    } else {
      totalGasPrice = gasPrice * gas;
    }
    load = Load.finish;
    setState(() {});
  }

  Future<void> _fetchAdvancedGasEstimate() async {
    final result = await GasTrackerApi().getGasEstimate(
      coinType: coinModel.coin['coinType'],
      isTest: coinModel.isTest,
      isContract: coinModel.coin['isContract'] ?? false,
    );
    if (!result.error && result.data is GasEstimateModel) {
      gasEstimate = result.data as GasEstimateModel;
      useAdvancedGas = true;
    }
  }

  Future<void> getGasPriceLayer2() async {
    setState(() => load = Load.loading);
    final rpc = chainUrlMap[CoinType.ETH.name]?['baseInfo']
            ?[coinModel.isTest ? 'service_test' : 'service'] ??
        '';
    final mm = await tokenViewApi.getGasPrice(
          coinModel.coin['blockchainType'],
          CoinType.ETH.name,
          isTest: false,
          rpc: rpc,
        ) ??
        MessageModel.error();
    if (mm.error == false) {
      gasPriceEth = mm.data;
    } else {
      errorMessage = mm.data.toString();
      ToastUtils.show(errorMessage);
    }
    totalGasPrice =
        totalGasPrice + BigInt.from((100 * gasPriceEth.toInt() * 2100) / 16);
    load = Load.finish;
    setState(() {});
  }

  Future<dynamic> estimateGasEthLocal({bool checkAddress = true}) async {
    closeKeyboard();
    if (gasLimitLoad == Load.loading) return;
    setState(() => gasLimitLoad = Load.loading);
    final blockchainType = coinModel.coin['blockchainType'] as String;
    if (blockchainType != BlockchainType.Ethereum.name &&
        blockchainType != BlockchainType.Tron.name) {
      return;
    }
    try {
      String? toAddr;
      if (checkAddress) {
        if (amountErrorMessage != '') return;
        toAddr = await toAddressCheck(toTextEditingController.text.trim());
        if (toAddr == null) return;
      } else {
        toAddr = toTextEditingController.text.trim();
      }
      if (toErrorMessage != '') return;
      final price = valueTextEditingController.text;
      if (price.isEmpty) return;

      final coinType = coinModel.coin['coinType'] as String;
      final gaslimit = BigInt.from(getCoinGas(
        coinType,
        contract: coinModel.coin['isContract'],
      ));

      final ethMessage = await _callGasEstimateApi(
        coinModel: coinModel,
        toAddr: toAddr,
        price: price,
        gasPrice: gasPrice,
        gaslimit: gaslimit,
      );

      if (ethMessage.error == false) {
        gas = ethMessage.data;
        if (coinType == CoinType.BOBA.name || coinType == CoinType.OP.name) {
          gas = BigInt.from(gas.toInt() * 1.5);
        }
        if (blockchainType == BlockchainType.Ethereum.name &&
            coinModel.coin['isContract'] == false) {
          final note = noteTextEditingController.text.trim();
          if (note.isNotEmpty) {
            final noteHex = bytesToHex(note.codeUnits);
            gas = gas + BigInt.from(noteHex.length * 8);
          }
        }
        totalGasPrice = gasPrice * gas;
        errorMessage = '';
        return true;
      } else {
        errorMessage = ethMessage.data;
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      setState(() => gasLimitLoad = Load.finish);
    }
  }

  /// 使用 Decimal 精确校验金额，避免浮点精度问题。
  void amountCheck({String value = ''}) {
    if (value.isEmpty) value = valueTextEditingController.text;
    final int decimals = coinModel.coin['decimals'] ?? 18;
    final int minValue = decimals == 0 ? 1 : 0;

    // 格式校验
    if (value.isEmpty) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }
    final isValidNum = regular.regularNums(value);
    final isValidDec = regular.regularDouble(value);
    final isValidFormat = decimals == 0 ? isValidNum : (isValidNum || isValidDec);
    if (!isValidFormat) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }

    final Decimal decimalValue;
    try {
      decimalValue = Decimal.parse(value);
    } catch (_) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }
    if (decimalValue < Decimal.fromInt(minValue) || decimalValue == Decimal.zero) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }

    // 余额校验
    final BigInt valueBi = ethToWeiString(value, decimals);
    final blockchainType = coinModel.coin['blockchainType'] as String;
    if (blockchainType == BlockchainType.Ripple.name) {
      final reserveAmount = ethToWeiString('10', decimals);
      if (valueBi + totalGasPrice > coinModel.balance - reserveAmount) {
        _setAmountError(S.of(context).g_key_47);
        return;
      }
    } else if (coinModel.coin['isContract'] == false) {
      if (valueBi + totalGasPrice > coinModel.balance) {
        _setAmountError(S.of(context).g_key_47);
        return;
      }
      transferValue = valueBi;
    } else {
      transferValue = valueBi;
    }
    amountErrorMessage = '';
    setState(() {});
  }

  void _setAmountError(String msg) {
    amountErrorMessage = msg;
    setState(() {});
  }

  Future<void> maxTag() async {
    if (gasLimitLoad == Load.loading) return;
    if (coinModel.coin['isContract']) {
      valueTextEditingController.text = coinModel.balanceStringAll();
      transferValue = coinModel.balance;
      estimateGasEthLocal();
    } else if (coinModel.coin['blockchainType'] ==
            BlockchainType.Ethereum.name ||
        coinModel.coin['blockchainType'] == BlockchainType.Tron.name) {
      valueTextEditingController.text = coinModel.balanceStringAll();
      final rOK = await estimateGasEthLocal();
      if (rOK == true) {
        transferValue = coinModel.balance - totalGasPrice;
        valueTextEditingController.text = regular.formartNum(
          toEther(transferValue.toString(), coinModel.coin['decimals'])
              .toDouble(),
          14,
          isCrop: true,
          isFill0: false,
        );
      }
    } else {
      transferValue = coinModel.balance - totalGasPrice;
      valueTextEditingController.text =
          toEther(transferValue.toString(), coinModel.coin['decimals'])
              .toString();
    }
    amountErrorMessage = '';
    setState(() {});
  }

  Future<void> sendTransaction() async {
    if (load == Load.loading) {
      ToastUtils.show('loading');
      return;
    }
    if (amountErrorMessage != '') return;
    closeKeyboard();
    amountCheck();
    if (amountErrorMessage != '') return;

    setState(() => load = Load.loading);

    final toAddr = await toAddressCheck(toTextEditingController.text.trim());
    if (toAddr == null) return setState(() => load = Load.finish);

    await estimateGasEthLocal(checkAddress: false);
    if (errorMessage != '') return setState(() => load = Load.finish);

    final uBalance = coinModel.coin['isContract']
        ? (chainModel?.balance ?? BigInt.zero)
        : coinModel.balance;
    if (totalGasPrice > uBalance || coinModel.balance == BigInt.zero) {
      return setState(() => load = Load.finish);
    }
    if (!mounted) return;

    final trModel = _buildTransactionRecord(toAddr);
    final chainUnit = (chainModel?.coin['unit'] ?? coinModel.coin['unit'])
        .toString()
        .toUpperCase();
    final check = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => buildWalletBaseSend(trModel, chainUnit)),
    );
    if (!mounted) return;
    if (check == true) {
      signTx(trModel);
    } else {
      setState(() => load = Load.finish);
    }
  }

  TransationRecordModel _buildTransactionRecord(String toAddr) {
    final trModel = TransationRecordModel()
      ..address = coinModel.address.toString()
      ..from1 = coinModel.address.toString()
      ..to1 = toAddr
      ..addrType = coinModel.addrType
      ..coin = coinModel.coin
      ..coinMiniName = coinModel.coin['coinType']
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = coinModel.isTest
          ? coinModel.coin['contract_test']
          : coinModel.coin['contract']
      ..isTest = coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = gasPrice
      ..price = transferValue;
    if (coinModel.coin['blockchainType'] == BlockchainType.Ethereum.name) {
      trModel.message = noteTextEditingController.text.trim();
    }
    return trModel;
  }

  /// Implemented in host State to construct the confirmation screen.
  Widget buildWalletBaseSend(TransationRecordModel trModel, String chainUnit);

  Future<void> signTx(TransationRecordModel trModel) async {
    if (!signTxCheck()) return;
    try {
      final mm = await TransferApi().transferWallet(
        trModel: trModel,
        privateKey: coinModel.privateKey,
        pathIndex: coinModel.pathIndex,
      );
      if (!mounted) return;
      if (mm.error) {
        errorMessage = mm.data;
      } else {
        trModel.txHash = mm.data;
        trModel.trId = await AppDatabase().insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(
          coinModel.coin['coinType'] ?? '',
          toTextEditingController.text.trim(),
        );
        if (!mounted) return;
        ToastUtils.show(S.current.g_key_nft_41);
        Navigator.pop(context);
      }
    } catch (e) {
      errorMessage = e.toString();
      ToastUtils.show(e.toString());
    } finally {
      load = Load.finish;
      setState(() {});
    }
  }

  bool signTxCheck() {
    final isEthContract =
        coinModel.coin['blockchainType'] == BlockchainType.Ethereum.name &&
        (coinModel.coin['isContract'] as bool? ?? false);
    if (!isEthContract) return true;
    final chainBalance = chainModel?.balance ?? BigInt.zero;
    if (chainBalance == BigInt.zero || totalGasPrice > chainBalance) {
      ToastUtils.show(
          S.current.g_key_t_29(chainModel?.coin['coinType'] ?? ''));
      return false;
    }
    return true;
  }
}

// File-level helper: dispatches to Tron or Ethereum gas estimation API.
Future<MessageModel> _callGasEstimateApi({
  required CoinModel coinModel,
  required String toAddr,
  required String price,
  required BigInt gasPrice,
  required BigInt gaslimit,
}) async {
  final coinType = coinModel.coin['coinType'] as String;
  const noLatestChains = {'OKT', 'MTR', 'METIS', 'VIC', 'BOBA', 'OP', 'GO'};

  final weiValue = ethToWeiString(price, coinModel.coin['decimals']);
  final contract = coinModel.isTest
      ? coinModel.coin['contract_test']
      : coinModel.coin['contract'];
  final blockchainType = coinModel.coin['blockchainType'] as String;

  if (blockchainType == BlockchainType.Tron.name) {
    return TrxApi().getGasEstimateTrx(
      coinModel.address, toAddr, gasPrice, weiValue, gaslimit,
      contract: contract, isTest: coinModel.isTest,
    );
  }

  final rpc = coinModel.isTest
      ? coinModel.coin['service_test']
      : coinModel.coin['service'];
  return EthAPI.init(null, rpc, null).getGasLimit(
    coinModel.address, toAddr, gasPrice, weiValue, gaslimit,
    contract: contract, isTest: coinModel.isTest,
    addLatest: !noLatestChains.contains(coinType),
  );
}
