import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';

import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/utils/regular.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/eth_api.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/trx_api.dart';
import 'package:n42_wallet/features/wallet/api/gas_tracker_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/api/coin_wallet_ops.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/gas_estimate_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/send_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/services/recent_address_service.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_eip1559.dart';
import 'package:n42_wallet/features/wallet/utils/chain/eth_layer2_chains.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/decimal_amount.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/generated/l10n.dart';

bool shouldBlockGasEstimateForAmountError({
  required String amountErrorMessage,
  String? amountOverride,
}) => amountOverride == null && amountErrorMessage.isNotEmpty;

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

  String get _coinType => coinModel.config.coinType;
  String get _blockchainType => coinModel.config.blockchainType;
  bool get _isContract => coinModel.config.isContract;
  int get _decimals => (coinModel.coin['decimals'] as num?)?.toInt() ?? 18;

  bool _ensureChainConfig() {
    if (_coinType.isNotEmpty && _blockchainType.isNotEmpty) return true;
    errorMessage = 'Invalid coin configuration';
    ToastUtils.show(errorMessage);
    return false;
  }

  // Init

  Future<void> initData() async {
    if (!_ensureChainConfig()) {
      if (mounted) setState(() => load = Load.finish);
      return;
    }
    if (_isContract) {
      final wap = ref.read(wapBridgeProvider);
      final idx = wap.coinModels.indexWhere((e) {
        if (e.config.coinType != _coinType) return false;
        if (coinModel.privateKey != null) {
          return e.privateKey == coinModel.privateKey;
        }
        return true;
      });
      if (idx < 0) {
        errorMessage = 'Missing parent chain for $_coinType';
        ToastUtils.show(errorMessage);
        if (mounted) setState(() => load = Load.finish);
        return;
      }
      chainModel = wap.coinModels[idx];
      if (chainModel != null) await fetchCoinBalance(chainModel!, wap);
      if (!mounted) return;
      setState(() {});
    }
    gas = BigInt.from(getCoinGas(_coinType, contract: _isContract));
    await getBalance();
    await getGasPrice();
    if (getEthLayer2(_coinType)) {
      gasEth = BigInt.from(getCoinGas(CoinType.ETH.name));
      await getGasPriceLayer2();
    }
  }

  Future<void> getBalance() async {
    setState(() => load = Load.loading);
    final isOk = await fetchCoinBalance(
      coinModel,
      ref.read(wapBridgeProvider),
      getToken: false,
    );
    if (!mounted) return;
    if (isOk != false) return;
    errorMessage = S.current.g_key_t_44;
    ToastUtils.show(errorMessage);
    setState(() => load = Load.finish);
  }

  /// 解析当前 coinModel 的 RPC 地址。
  ///
  /// 对所有 EVM 链（不限于 custom）优先返回链自身的 service URL，避免
  /// 将 N42 API 不支持的 coinType（如 XDAI、PLUME 等）发送到后台而触发
  /// 5xx 错误，进而积累 circuit breaker 计数导致后续请求报 "Dio Error"。
  /// 合约代币无自身 service 时，回退到父链（chainModel）的 RPC。
  String? _resolveRpc() {
    if (_blockchainType == BlockchainType.Ethereum.name) {
      final source = (_isContract && chainModel != null)
          ? chainModel!.coin
          : coinModel.coin;
      final svc =
          (coinModel.isTest ? source['service_test'] : source['service'])
              as String?;
      if (svc != null && svc.isNotEmpty) return svc;
    }
    // 非 EVM 链 / service 为空时：自定义链返回配置 RPC，否则 null（走 N42 API）
    if (!coinModel.config.custom) return null;
    return coinModel.isTest
        ? coinModel.config.serviceTest
        : coinModel.config.service;
  }

  Future<void> getGasPrice() async {
    setState(() => load = Load.loading);
    if (!_ensureChainConfig()) {
      if (mounted) setState(() => load = Load.finish);
      return;
    }
    final isEthereum = _blockchainType == BlockchainType.Ethereum.name;

    if (isEthereum) {
      await _fetchAdvancedGasEstimate();
    }
    final mm =
        await tokenViewApi.getGasPrice(
          _blockchainType,
          _coinType,
          isTest: coinModel.isTest,
          rpc: _resolveRpc(),
        ) ??
        MessageModel.error();
    if (mm.error == false) {
      gasPrice = mm.data;
      if (get1559WithChainSymbol(_coinType) && isEthereum) {
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
    if (_coinType.isEmpty) return;
    final result = await GasTrackerApi().getGasEstimate(
      coinType: _coinType,
      isTest: coinModel.isTest,
      isContract: _isContract,
    );
    if (!result.error && result.data is GasEstimateModel) {
      gasEstimate = result.data as GasEstimateModel;
      useAdvancedGas = true;
    }
  }

  Future<void> getGasPriceLayer2() async {
    setState(() => load = Load.loading);
    final rpc =
        chainUrlMap[CoinType.ETH.name]?['baseInfo']?[coinModel.isTest
            ? 'service_test'
            : 'service'] ??
        '';
    final mm =
        await tokenViewApi.getGasPrice(
          _blockchainType,
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
        totalGasPrice +
        (BigInt.from(100) * gasPriceEth * BigInt.from(2100)) ~/ BigInt.from(16);
    load = Load.finish;
    setState(() {});
  }

  Future<dynamic> estimateGasEthLocal({
    bool checkAddress = true,
    String? amountOverride,
    bool dismissKeyboard = true,
  }) async {
    if (dismissKeyboard) closeKeyboard();
    if (gasLimitLoad == Load.loading) return;
    setState(() => gasLimitLoad = Load.loading);
    if (_blockchainType != BlockchainType.Ethereum.name &&
        _blockchainType != BlockchainType.Tron.name) {
      return;
    }
    try {
      String? toAddr;
      if (checkAddress) {
        // Max supplies its own zero-value estimate. An invalid value already
        // present in the input must not prevent it from calculating and
        // replacing that value with the transferable maximum.
        if (shouldBlockGasEstimateForAmountError(
          amountErrorMessage: amountErrorMessage,
          amountOverride: amountOverride,
        )) {
          return;
        }
        toAddr = await toAddressCheck(toTextEditingController.text.trim());
        if (toAddr == null) return;
      } else {
        toAddr = toTextEditingController.text.trim();
      }
      if (toErrorMessage != '') return;
      final price = amountOverride ?? valueTextEditingController.text;
      if (price.isEmpty) return;

      final gaslimit = BigInt.from(
        getCoinGas(_coinType, contract: _isContract),
      );

      final ethMessage = await _callGasEstimateApi(
        coinModel: coinModel,
        toAddr: toAddr,
        price: price,
        gasPrice: gasPrice,
        gaslimit: gaslimit,
      );

      if (ethMessage.error == false) {
        gas = ethMessage.data;
        if (_coinType == CoinType.BOBA.name || _coinType == CoinType.OP.name) {
          gas = gas * BigInt.from(3) ~/ BigInt.from(2);
        }
        if (_blockchainType == BlockchainType.Ethereum.name && !_isContract) {
          final note = noteTextEditingController.text.trim();
          if (note.isNotEmpty) {
            final noteHex = bytesToHex(utf8.encode(note));
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
      if (mounted) {
        setState(() => gasLimitLoad = Load.finish);
      }
    }
  }

  /// 使用 Decimal 精确校验金额，避免浮点精度问题。
  void amountCheck({String value = ''}) {
    if (value.isEmpty) value = valueTextEditingController.text;
    final int decimals = _decimals;
    final int minValue = decimals == 0 ? 1 : 0;

    // 格式校验
    if (value.isEmpty) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }
    final isValidNum = regular.regularNums(value);
    final isValidDec = regular.regularDouble(value);
    final isValidFormat = decimals == 0
        ? isValidNum
        : (isValidNum || isValidDec);
    if (!isValidFormat) {
      _setAmountError(S.of(context).g_key_134);
      return;
    }
    if (!hasAtMostDecimalPlaces(value, decimals)) {
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
    if (decimalValue < Decimal.fromInt(minValue) ||
        decimalValue == Decimal.zero) {
      _setAmountError(S.of(context).g_key_46(minValue));
      return;
    }

    // 余额校验
    final BigInt valueBi = ethToWeiString(value, decimals);
    if (_blockchainType == BlockchainType.Ripple.name) {
      final reserveAmount = ethToWeiString('10', decimals);
      if (valueBi + totalGasPrice > coinModel.balance - reserveAmount) {
        _setAmountError(S.of(context).g_key_47);
        return;
      }
    } else if (!_isContract) {
      if (valueBi + totalGasPrice > coinModel.balance) {
        _setAmountError(S.of(context).g_key_47);
        return;
      }
      transferValue = valueBi;
    } else {
      if (valueBi > coinModel.balance) {
        _setAmountError(S.of(context).g_key_47);
        return;
      }
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
    if (_isContract) {
      // 代币 Max 填入的就是整额余额，本身必然合法；不把它作为 amountOverride
      // 传入的话，输入框里残留的旧金额错误会挡掉这次 gas 估算。
      final maxAmount = bigIntToDecimalString(coinModel.balance, _decimals);
      valueTextEditingController.text = maxAmount;
      transferValue = coinModel.balance;
      estimateGasEthLocal(amountOverride: maxAmount);
    } else if (_blockchainType == BlockchainType.Ethereum.name ||
        _blockchainType == BlockchainType.Tron.name) {
      // 估算 MAX 的 gas 时不能先把余额全作为 value 发送给 RPC；部分节点会
      // 在 estimateGas 阶段就做余额检查，从而返回 insufficient funds，导致
      // 后续永远算不出 balance-fee。普通转账的 gas 与 value 无关，使用 0
      // 作为估算值即可，最终发送仍使用下方精确的 balance-fee。
      // Keep the amount field focused. A delayed Max calculation must not
      // overwrite text the user entered while the gas RPC request was pending.
      final amountBeforeEstimate = valueTextEditingController.text;
      final rOK = await estimateGasEthLocal(
        amountOverride: '0',
        dismissKeyboard: false,
      );
      if (rOK == true) {
        if (!mounted ||
            valueTextEditingController.text != amountBeforeEstimate) {
          return;
        }
        transferValue = maxTransferableAmount(
          balance: coinModel.balance,
          fee: totalGasPrice,
        );
        valueTextEditingController.text = bigIntToDecimalString(
          transferValue,
          _decimals,
        );
      }
    } else {
      final reserve = _blockchainType == BlockchainType.Ripple.name
          ? ethToWeiString('10', _decimals)
          : BigInt.zero;
      transferValue = maxTransferableAmount(
        balance: coinModel.balance,
        fee: totalGasPrice,
        reserve: reserve,
      );
      valueTextEditingController.text = toEther(
        transferValue.toString(),
        _decimals,
      ).toString();
    }
    amountCheck();
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
    if (!mounted) return;
    if (toAddr == null) return setState(() => load = Load.finish);

    await estimateGasEthLocal(checkAddress: false);
    if (!mounted) return;
    if (errorMessage != '') return setState(() => load = Load.finish);

    // The asynchronous estimate can raise the fee after the initial amount
    // check. Revalidate exact amount + refreshed fee before confirmation.
    amountCheck();
    if (amountErrorMessage != '') return setState(() => load = Load.finish);

    final uBalance = _isContract
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
        builder: (_) => buildWalletBaseSend(trModel, chainUnit),
      ),
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
      ..coinMiniName = _coinType
      ..walletIndex = ref.read(wapBridgeProvider).walletIndex
      ..contract = coinModel.isTest
          ? coinModel.config.contractTest
          : coinModel.config.contract
      ..isTest = coinModel.isTest ? 1 : 0
      ..gasPrice = totalGasPrice
      ..gas = gas.toInt()
      ..gasPriceValue = gasPrice
      ..price = transferValue;
    if (_blockchainType == BlockchainType.Ethereum.name) {
      trModel.message = noteTextEditingController.text.trim();
    }
    return trModel;
  }

  /// Implemented in host State to construct the confirmation screen.
  Widget buildWalletBaseSend(TransationRecordModel trModel, String chainUnit);

  Future<void> signTx(TransationRecordModel trModel) async {
    if (!signTxCheck()) {
      if (mounted) setState(() => load = Load.finish);
      return;
    }
    bool completedWithExit = false;
    try {
      final addrType = coinModel.addrType;
      final chainConfig = _isContract
          ? (chainModel?.coin ?? coinModel.coin)
          : coinModel.coin;
      final pathConfig = CoinConfigView(chainConfig);
      final basePath =
          pathConfig.pathForAddrType(addrType) ?? "m/44'/60'/0'/0/0";
      final path = getPathWithIndex(basePath, coinModel.pathIndex);
      final nativeDecimals = _isContract
          ? ((chainModel?.coin['decimals'] as num?)?.toInt() ?? 18)
          : _decimals;

      final result = await SenderFactory.instance
          .getSender(_coinType, chainConfig: chainConfig)
          .send(
            SendParams(
              coinType: _coinType,
              fromAddress: trModel.from1,
              toAddress: trModel.to1,
              amount: toEther(trModel.price.toString(), _decimals).toDouble(),
              decimals: nativeDecimals,
              path: path,
              sendMax: false,
              isTest: coinModel.isTest,
              contractAddress: trModel.contract,
              tokenDecimals: _isContract ? _decimals : 0,
              memo: trModel.message,
              privateKey: coinModel.privateKey,
              chainConfig: chainConfig,
              // 精确 wei 透传:trModel.price 是精确 BigInt,amount 经 double 往返
              // 会上浮、令 MAX 全额被误判余额不足(第三轮 P1)。native/合约分别走
              // valueWeiOverride / tokenValueWeiOverride。
              valueWeiOverride: _isContract ? null : trModel.price,
              tokenValueWeiOverride: _isContract ? trModel.price : null,
            ),
          );

      if (!mounted) return;
      if (result.success) {
        trModel.txHash = result.txHash ?? '';
        trModel.trId = await AppDatabase().insertTransationRecord(trModel);
        if (!mounted) return;
        ref.read(tripBridgeProvider).addUndoneTr(trModel, 1);
        await RecentAddressService.save(
          _coinType,
          toTextEditingController.text.trim(),
        );
        if (!mounted) return;
        ToastUtils.show(S.current.g_key_nft_41);
        completedWithExit = true;
        Navigator.pop(context);
      } else {
        errorMessage = result.error ?? '';
        ToastUtils.show(errorMessage);
      }
    } catch (e) {
      errorMessage = e.toString();
      ToastUtils.show(e.toString());
    } finally {
      load = Load.finish;
      if (mounted && !completedWithExit) setState(() {});
    }
  }

  bool signTxCheck() {
    final isEthContract =
        _blockchainType == BlockchainType.Ethereum.name && _isContract;
    if (!isEthContract) return true;
    final chainBalance = chainModel?.balance ?? BigInt.zero;
    if (chainBalance == BigInt.zero || totalGasPrice > chainBalance) {
      ToastUtils.show(S.current.g_key_t_29(chainModel?.config.coinType ?? ''));
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
  final coinType = coinModel.config.coinType;
  const noLatestChains = {'OKT', 'MTR', 'METIS', 'VIC', 'BOBA', 'OP', 'GO'};

  final decimals = (coinModel.coin['decimals'] as num?)?.toInt() ?? 18;
  final weiValue = ethToWeiString(price, decimals);
  final contract = coinModel.isTest
      ? coinModel.config.contractTest
      : coinModel.config.contract;
  final blockchainType = coinModel.config.blockchainType;
  if (coinType.isEmpty || blockchainType.isEmpty) {
    return MessageModel.error()..data = 'Invalid coin configuration';
  }

  if (blockchainType == BlockchainType.Tron.name) {
    return TrxApi().getGasEstimateTrx(
      coinModel.address,
      toAddr,
      gasPrice,
      weiValue,
      gaslimit,
      contract: contract,
      isTest: coinModel.isTest,
    );
  }

  final rpc = coinModel.isTest
      ? coinModel.config.serviceTest
      : coinModel.config.service;
  return EthAPI.init(null, rpc, null).getGasLimit(
    coinModel.address,
    toAddr,
    gasPrice,
    weiValue,
    gaslimit,
    contract: contract,
    isTest: coinModel.isTest,
    addLatest: !noLatestChains.contains(coinType),
  );
}
