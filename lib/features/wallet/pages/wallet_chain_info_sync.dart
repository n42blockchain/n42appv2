import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/transaction_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42_wallet/features/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/sol_transaction_item.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:web3dart/web3dart.dart';

/// Transaction data sync mixin for WalletChainInfo.
/// Handles local DB reads and remote API sync for all blockchain types.
mixin WalletChainInfoSyncMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  AppDatabase get db;
  int get pageSize;
  int get page;
  set page(int v);
  bool get lastPage;
  set lastPage(bool v);
  List<dynamic> get transactionList;
  Load get load;
  set load(Load v);

  /// Fetch transactions from local DB. Supports paging and refresh.
  Future<void> getTransactionData(Load loadType) async {
    if (load != Load.finish) return;
    if (loadType == Load.nextPage && lastPage) return;

    if (loadType == Load.refresh) {
      page = 1;
      lastPage = false;
    } else {
      page += 1;
    }

    load = loadType;
    try {
      final coinModel = getCoinModel();
      final addr = coinModel.address?.toString() ?? '';
      final coinKey = coinModel.coin['coinType'];
      final contract = coinModel.coin['contract'];

      final isBtc = coinModel.coin['blockchainType'] == BlockchainType.Bitcoin.name;
      final List<dynamic>? txList = isBtc
          ? await db.selectBtcTransationRecord(
              AppGlobals.userInfo?.uuid ?? '',
              addr,
              coinKey,
              0,
              pageSize: pageSize,
              pageNum: page,
            )
          : await db.selectTransationRecordMiniName(
              addr,
              coinKey,
              0,
              contract: contract,
              pageSize: pageSize,
              pageNum: page,
              isTest: coinModel.isTest ? 1 : 0,
            );

      final results = txList ?? [];
      if (loadType == Load.refresh) transactionList.clear();
      transactionList.addAll(results);
      if (results.length < pageSize) lastPage = true;
    } finally {
      setState(() {
        load = Load.finish;
      });
    }
  }

  /// Fetch and sync transactions from remote API for all blockchain types.
  Future<void> getTransactionDataNetwork(Load loadType) async {
    final coinModel = getCoinModel();
    final addr = coinModel.address.toString();
    final coinKey = coinModel.coin['coinType'];
    final contract = coinModel.coin['contract'];

    final api = TransactionApi();
    final MessageModel mm = contract == ''
        ? await api.getTransactionList(coinKey, addr, isTest: coinModel.isTest)
        : await api.getContractTransactionList(coinKey, addr, contract,
            isTest: coinModel.isTest);

    if (mm.error == false) {
      final blockchainType = coinModel.coin['blockchainType'];
      switch (blockchainType) {
        case 'Ethereum':
          await getTransactionDataNetworkEth(mm.data);
        case 'Bitcoin':
          await getTransactionDataNetworkBtc(mm.data);
        case 'Tron':
          await getTransactionDataNetworkTrx(mm.data);
        case 'Solana':
          await getTransactionDataNetworkSol(mm.data);
        case 'Polkadot':
        case 'Aptos':
        case 'TheOpenNetwork':
          await getTransactionDataNetworkGeneric(mm.data);
      }
    }
  }

  Future<void> getTransactionDataNetworkEth(
      List<CommonResponseItemModel>? cril) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final rtrm = await db.selectTransationRecordTxHash(
          cri.hash ?? '0x', coinModel.address);
      if (!mounted) return;

      if (rtrm.isEmpty) {
        final hash = cri.hash ?? '';
        final trm = _buildTxRecord(coinModel, cri, hash);
        trm.nonce = cri.nonce;

        if (trm.contract == '') {
          String input = cri.input ?? '0x';
          if (input == '0x') {
            input = '';
          } else {
            try {
              input = utf8.decode(hexToBytes(input));
            } catch (e) {
              input = '';
            }
          }
          trm.message = input;
        }
        await db.insertTransationRecord(trm);
        isEdit = true;
      } else {
        if (await _updateTxTimeIfChanged(rtrm[0], cri.timeStamp ?? '0')) {
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }

  Future<void> getTransactionDataNetworkTrx(
      List<CommonResponseItemModel>? cril) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      if (coinModel.coin['contract'].toString().toUpperCase() !=
          (cri.contractAddress ?? '').toUpperCase()) {
        continue;
      }
      final rtrm = await db.selectTransationRecordTxHash(
          cri.hash ?? '0x', coinModel.address);
      if (!mounted) return;

      if (rtrm.isEmpty) {
        final hash = cri.hash ?? '';
        final trm = _buildTxRecord(coinModel, cri, hash);
        trm.nonce = cri.nonce;
        await db.insertTransationRecord(trm);
        isEdit = true;
      } else {
        if (await _updateTxTimeIfChanged(rtrm[0], cri.timeStamp ?? '0')) {
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }

  Future<void> getTransactionDataNetworkBtc(
      List<BtcTranDetail>? cril) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final rtrm = await db.selectBtcTransationRecordTxHash(cri.hash);
      if (!mounted) return;
      final cDate = _parseBtcTimestamp(cri.confirmed);

      if (rtrm.isEmpty) {
        final trm = BtcTransactionRecodeModel();
        trm.addrType = coinModel.addrType;
        trm.coin = coinModel.coin;
        trm.address = coinModel.address ?? '';
        trm.price = cri.total;
        trm.gasPrice = cri.fees;
        trm.to1 = '';
        trm.walletIndex = ref.read(wapBridgeProvider).walletIndex;
        trm.txHash = cri.hash;
        trm.txTime = cDate;
        trm.state = cri.confirmations >= 6 ? 1 : 0;
        trm.coinMiniName = coinModel.coin['coinType'];
        trm.isTest = coinModel.isTest ? 1 : 0;

        bool isIn = false;
        trm.inputModels = _buildBtcInputModels(cri.inputs);
        if (trm.inputModels != null) {
          final addrUpper = trm.address.toUpperCase();
          isIn = trm.inputModels!.every(
            (im) => im.address.every((a) => a.toUpperCase() != addrUpper),
          );
        }
        trm.outputModels = _buildBtcOutputModels(cri.outputs);
        if (trm.outputModels != null) {
          final addrUpper = trm.address.toUpperCase();
          int outputPrice = 0;
          for (final om in trm.outputModels!) {
            final hasAddr = om.address.any((a) => a.toUpperCase() == addrUpper);
            if (isIn ? hasAddr : !hasAddr) outputPrice += om.price;
          }
          trm.price = outputPrice;
        }
        await db.insertBtcTransactionRecord(trm);
        isEdit = true;
      } else {
        final trm = rtrm[0];
        if (trm.inputsAddressList.isEmpty) {
          trm.inputModels = _buildBtcInputModels(cri.inputs);
          trm.outputModels = _buildBtcOutputModels(cri.outputs);
          trm.txTime = cDate;
          await db.updateBtcTransactionRecord(trm);
          isEdit = true;
        }
        if (trm.txTime != cDate) {
          trm.txTime = cDate;
          await db.updateBtcTransactionRecord(trm);
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }

  /// Parse BTC confirmed timestamp to epoch seconds string.
  String _parseBtcTimestamp(String? confirmed) {
    return (DateTime.parse(confirmed ?? '').millisecondsSinceEpoch ~/ 1000)
        .toString();
  }

  /// Build InputModel list from BTC transaction inputs.
  List<InputModel>? _buildBtcInputModels(List<dynamic>? inputs) {
    if (inputs == null) return null;
    return [
      for (final input in inputs)
        InputModel()
          ..vout = input.outputValue
          ..txid = input.prevHash
          ..script = input.script ?? ''
          ..address = input.addresses,
    ];
  }

  /// Build OutputModel list from BTC transaction outputs.
  List<OutputModel>? _buildBtcOutputModels(List<dynamic>? outputs) {
    if (outputs == null) return null;
    return [
      for (final output in outputs)
        OutputModel()
          ..price = output.value
          ..script = output.script ?? ''
          ..address = output.addresses ?? [],
    ];
  }

  /// Solana transaction sync — maps SOLTransactionItem to local DB.
  Future<void> getTransactionDataNetworkSol(
      List<SOLTransactionItem>? cril) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final hash = cri.txHash ?? '';
      if (hash.isEmpty) continue;
      final rtrm =
          await db.selectTransationRecordTxHash(hash, coinModel.address);
      if (!mounted) return;

      if (rtrm.isEmpty) {
        final trm = TransationRecordModel();
        trm.coinId = (coinModel.isTest
                ? coinModel.coin['chainId_test']
                : coinModel.coin['chainId']) ??
            0;
        trm.coin = coinModel.coin;
        trm.address = coinModel.address ?? '';
        trm.from1 = (cri.src ?? '').toLowerCase();
        trm.to1 = (cri.dst ?? '').toLowerCase();
        trm.price = BigInt.from(cri.lamport ?? 0);
        trm.contract = (coinModel.coin['contract'] ?? '').toLowerCase();
        trm.walletIndex = ref.read(wapBridgeProvider).walletIndex;
        trm.txHash = hash;
        trm.gasPrice = BigInt.from(cri.fee ?? 0);
        trm.gas = 0;
        trm.txTime = (cri.blockTime ?? 0).toString();
        trm.state = (cri.status == 'Success') ? 1 : 0;
        trm.coinMiniName = coinModel.coin['coinType'];
        trm.isTest = coinModel.isTest ? 1 : 0;
        await db.insertTransationRecord(trm);
        isEdit = true;
      } else {
        final newTime = (cri.blockTime ?? 0).toString();
        if (await _updateTxTimeIfChanged(rtrm[0], newTime)) {
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }

  /// Generic transaction sync for DOT / APT / TON — reuses CommonResponseItemModel.
  Future<void> getTransactionDataNetworkGeneric(
      List<CommonResponseItemModel>? cril) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final hash = cri.hash ?? '';
      if (hash.isEmpty) continue;
      final rtrm =
          await db.selectTransationRecordTxHash(hash, coinModel.address);
      if (!mounted) return;

      if (rtrm.isEmpty) {
        final trm = _buildTxRecord(coinModel, cri, hash);
        await db.insertTransationRecord(trm);
        isEdit = true;
      } else {
        if (await _updateTxTimeIfChanged(rtrm[0], cri.timeStamp ?? '0')) {
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }

  Future<void> getTxInfoNetwork(
      TransationRecordModel transationRecordModel) async {
    final rtrm =
        await ref.read(tripBridgeProvider).checkUndoneTrReturn(transationRecordModel) ??
            transationRecordModel;
    transactionList.firstWhere((element) {
      final trm = element as TransationRecordModel;
      if (trm.txHash == rtrm.txHash) {
        trm.state = rtrm.state;
        return true;
      }
      return false;
    });
    setState(() {});
  }

  Future<void> getTxInfoNetworkBtc(
      BtcTransactionRecodeModel transationRecordModel) async {
    final rtrm =
        await ref.read(tripBridgeProvider).checkUndoneTrBtcReturn(transationRecordModel) ??
            transationRecordModel;
    transactionList.firstWhere((element) {
      final trm = element as TransationRecordModel;
      if (trm.txHash == rtrm.txHash) {
        trm.state = rtrm.state;
        return true;
      }
      return false;
    });
    setState(() {});
  }

  // ── 辅助方法 ─────────────────────────────────────────────────────────────

  /// 构建通用的 TransationRecordModel（ETH / TRX / Generic 共用字段填充）
  TransationRecordModel _buildTxRecord(
    dynamic coinModel,
    CommonResponseItemModel cri,
    String hash,
  ) {
    final trm = TransationRecordModel();
    trm.coinId = coinModel.isTest
        ? coinModel.coin['chainId_test']
        : coinModel.coin['chainId'];
    trm.coin = coinModel.coin;
    trm.address = coinModel.address ?? '';
    trm.from1 = (cri.from ?? '').toLowerCase();
    trm.to1 = (cri.to ?? '').toLowerCase();
    trm.price = BigInt.tryParse(cri.value ?? '0') ?? BigInt.zero;
    trm.contract = (coinModel.coin['contract'] ?? '').toLowerCase();
    trm.walletIndex = ref.read(wapBridgeProvider).walletIndex;
    trm.txHash = hash;
    trm.gasPrice = BigInt.tryParse(cri.gasPrice ?? '0') ?? BigInt.zero;
    trm.gas = int.tryParse(cri.gas ?? '0') ?? 0;
    trm.txTime = cri.timeStamp ?? '0';
    trm.state = int.tryParse(cri.txreceiptStatus ?? '0') ?? 0;
    trm.coinMiniName = coinModel.coin['coinType'];
    trm.isTest = coinModel.isTest ? 1 : 0;
    return trm;
  }

  /// 更新已有交易记录的时间戳（如果不同）
  Future<bool> _updateTxTimeIfChanged(
    TransationRecordModel trm,
    String newTime,
  ) async {
    if (trm.txTime != newTime) {
      trm.txTime = newTime;
      await db.updateTransationRecord(trm);
      return true;
    }
    return false;
  }

  /// Subclasses must provide access to the current CoinModel.
  dynamic getCoinModel();
}
