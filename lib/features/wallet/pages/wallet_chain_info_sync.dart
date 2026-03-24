import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/component/enums/load.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/tokenview_enhanced_api.dart';
import 'package:n42_wallet/features/wallet/api/transaction_api.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_sync_utils.dart';
import 'package:n42_wallet/features/wallet/models/transaction/btc_tran_detail.dart';
import 'package:n42_wallet/features/wallet/models/transaction/common_response_item_model.dart';
import 'package:n42_wallet/features/wallet/models/transaction/explorer_response_utils.dart';
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

      final isBtc =
          coinModel.coin['blockchainType'] == BlockchainType.Bitcoin.name;
      final List<dynamic> txList = isBtc
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

      final results = txList;
      if (loadType == Load.refresh) transactionList.clear();
      transactionList.addAll(results);
      if (results.length < pageSize) lastPage = true;
    } finally {
      if (mounted) {
        setState(() {
          load = Load.finish;
        });
      }
    }
  }

  Future<void> getTransactionDataNetwork(Load loadType) async {
    final coinModel = getCoinModel();
    final addr = coinModel.address.toString();
    final coinKey = coinModel.coin['coinType'];
    final contract = coinModel.coin['contract'];

    final api = TransactionApi();
    final MessageModel mm = contract == ''
        ? await api.getTransactionList(coinKey, addr, isTest: coinModel.isTest)
        : await api.getContractTransactionList(
            coinKey,
            addr,
            contract,
            isTest: coinModel.isTest,
          );

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

    // Fetch mempool pending transactions for supported chains
    await _fetchMempoolTxs(coinModel);
  }

  /// Mempool 支持的链 → TokenView chain 参数映射
  static const _mempoolChainMap = {
    'ETH': 'eth',
    'BNB': 'bnb',
    'BASE': 'base',
    'TRX': 'trx',
    'BTC': 'btc',
    'SOL': 'sol',
  };

  Future<void> _fetchMempoolTxs(dynamic coinModel) async {
    final coinType = coinModel.coin['coinType']?.toString() ?? '';
    final tvChain = _mempoolChainMap[coinType.toUpperCase()];
    if (tvChain == null) return;

    final addr = coinModel.address?.toString() ?? '';
    if (addr.isEmpty) return;

    try {
      final mempoolTxs = await const TokenViewEnhancedApi().getPendingTxs(
        tvChain,
        addr,
      );
      if (mempoolTxs.isEmpty || !mounted) return;

      final existingHashes = <String>{
        for (final tx in transactionList)
          if (tx is TransationRecordModel)
            tx.txHash
          else if (tx is BtcTransactionRecodeModel)
            tx.txHash,
      };

      final newMempoolTxs = mempoolTxs
          .where(
            (tx) => tx.txHash.isNotEmpty && !existingHashes.contains(tx.txHash),
          )
          .toList();

      if (newMempoolTxs.isNotEmpty) {
        setState(() {
          transactionList.insertAll(0, newMempoolTxs);
        });
      }
    } catch (_) {
      // Mempool fetch is best-effort, silently ignore errors
    }
  }

  Future<void> getTransactionDataNetworkEth(
    List<CommonResponseItemModel>? cril,
  ) async {
    await _syncCommonTxRecords(cril, isEth: true);
  }

  Future<void> getTransactionDataNetworkTrx(
    List<CommonResponseItemModel>? cril,
  ) async {
    await _syncCommonTxRecords(cril, isEth: false);
  }

  Future<void> _syncCommonTxRecords(
    List<CommonResponseItemModel>? cril, {
    required bool isEth,
  }) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];

      // TRX: skip records whose contract doesn't match
      if (!isEth &&
          coinModel.coin['contract'].toString().toUpperCase() !=
              (cri.contractAddress ?? '').toUpperCase()) {
        continue;
      }

      final rtrm = await db.selectTransationRecordTxHash(
        cri.hash ?? '0x',
        coinModel.address,
      );
      if (!mounted) return;

      if (rtrm.isEmpty) {
        final hash = cri.hash ?? '';
        final trm = _buildTxRecord(coinModel, cri, hash);
        trm.nonce = cri.nonce;

        // ETH: decode input data as message for native transfers
        if (isEth && trm.contract == '') {
          trm.message = _decodeEthMessageInput(cri.input);
        }

        await db.insertTransationRecord(trm);
        isEdit = true;
      } else {
        final existing = rtrm[0];
        if (_syncExistingTxRecord(existing, coinModel, cri, isEth: isEth)) {
          await db.updateTransationRecord(existing);
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }

  Future<void> getTransactionDataNetworkBtc(List<BtcTranDetail>? cril) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final rtrm = await db.selectBtcTransationRecordTxHash(cri.hash);
      if (!mounted) return;

      if (rtrm.isEmpty) {
        final trm = BtcTransactionRecodeModel();
        trm.addrType = coinModel.addrType;
        trm.coin = coinModel.coin;
        trm.address = coinModel.address ?? '';
        trm.to1 = '';
        trm.walletIndex = ref.read(wapBridgeProvider).walletIndex;
        trm.txHash = cri.hash;
        trm.coinMiniName = coinModel.coin['coinType'];
        trm.isTest = coinModel.isTest ? 1 : 0;
        syncBtcRecordFromDetail(trm, cri);
        await db.insertBtcTransactionRecord(trm);
        isEdit = true;
      } else {
        final trm = rtrm[0];
        if (syncBtcRecordFromDetail(trm, cri)) {
          await db.updateBtcTransactionRecord(trm);
          isEdit = true;
        }
      }
    }
    if (isEdit) getTransactionData(Load.refresh);
  }

  Future<void> getTransactionDataNetworkSol(
    List<SOLTransactionItem>? cril,
  ) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final hash = cri.txHash ?? '';
      if (hash.isEmpty) continue;
      final rtrm = await db.selectTransationRecordTxHash(
        hash,
        coinModel.address,
      );
      if (!mounted) return;

      if (rtrm.isEmpty) {
        final trm = TransationRecordModel();
        trm.coinId =
            (coinModel.isTest
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

  Future<void> getTransactionDataNetworkGeneric(
    List<CommonResponseItemModel>? cril,
  ) async {
    if (cril == null) return;
    final coinModel = getCoinModel();
    bool isEdit = false;

    for (int i = cril.length - 1; i >= 0; i--) {
      final cri = cril[i];
      final hash = cri.hash ?? '';
      if (hash.isEmpty) continue;
      final rtrm = await db.selectTransationRecordTxHash(
        hash,
        coinModel.address,
      );
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
    TransationRecordModel transationRecordModel,
  ) async {
    final rtrm =
        await ref
            .read(tripBridgeProvider)
            .checkUndoneTrReturn(transationRecordModel) ??
        transationRecordModel;
    if (!mounted) return;
    transactionList.firstWhere((element) {
      final trm = element as TransationRecordModel;
      if (trm.txHash == rtrm.txHash) {
        trm.state = rtrm.state;
        return true;
      }
      return false;
    }, orElse: () => rtrm);
    setState(() {});
  }

  Future<void> getTxInfoNetworkBtc(
    BtcTransactionRecodeModel transationRecordModel,
  ) async {
    final rtrm =
        await ref
            .read(tripBridgeProvider)
            .checkUndoneTrBtcReturn(transationRecordModel) ??
        transationRecordModel;
    if (!mounted) return;
    transactionList.firstWhere((element) {
      final trm = element as TransationRecordModel;
      if (trm.txHash == rtrm.txHash) {
        trm.state = rtrm.state;
        return true;
      }
      return false;
    }, orElse: () => rtrm);
    setState(() {});
  }

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
    trm.price = parseExplorerAmount(
      cri.value,
      coinModel.coin['decimals'] as int? ?? 18,
    );
    trm.contract = (coinModel.coin['contract'] ?? '').toLowerCase();
    trm.walletIndex = ref.read(wapBridgeProvider).walletIndex;
    trm.txHash = hash;
    trm.gasPrice = BigInt.tryParse(cri.gasPrice ?? '0') ?? BigInt.zero;
    trm.gas = int.tryParse(cri.gas ?? '0') ?? 0;
    trm.txTime = cri.timeStamp ?? '0';
    trm.state = cri.normalizedState;
    trm.coinMiniName = coinModel.coin['coinType'];
    trm.isTest = coinModel.isTest ? 1 : 0;
    return trm;
  }

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

  bool _syncExistingTxRecord(
    TransationRecordModel trm,
    dynamic coinModel,
    CommonResponseItemModel cri, {
    required bool isEth,
  }) {
    var changed = false;

    final from = (cri.from ?? '').toLowerCase();
    if (trm.from1 != from) {
      trm.from1 = from;
      changed = true;
    }

    final to = (cri.to ?? '').toLowerCase();
    if (trm.to1 != to) {
      trm.to1 = to;
      changed = true;
    }

    final price = parseExplorerAmount(
      cri.value,
      coinModel.coin['decimals'] as int? ?? 18,
    );
    if (trm.price != price) {
      trm.price = price;
      changed = true;
    }

    final gasPrice = BigInt.tryParse(cri.gasPrice ?? '0') ?? BigInt.zero;
    if (trm.gasPrice != gasPrice) {
      trm.gasPrice = gasPrice;
      changed = true;
    }

    final gas = int.tryParse(cri.gas ?? '0') ?? 0;
    if (trm.gas != gas) {
      trm.gas = gas;
      changed = true;
    }

    final state = cri.normalizedState;
    if (trm.state != state) {
      trm.state = state;
      changed = true;
    }

    final time = cri.timeStamp ?? '0';
    if (trm.txTime != time) {
      trm.txTime = time;
      changed = true;
    }

    if (trm.nonce != cri.nonce) {
      trm.nonce = cri.nonce;
      changed = true;
    }

    if (isEth && trm.contract.isEmpty) {
      final message = _decodeEthMessageInput(cri.input);
      if (trm.message != message) {
        trm.message = message;
        changed = true;
      }
    }

    return changed;
  }

  String _decodeEthMessageInput(String? rawInput) {
    String input = rawInput ?? '0x';
    if (input == '0x') {
      return '';
    }
    try {
      return utf8.decode(hexToBytes(input));
    } catch (_) {
      return '';
    }
  }

  dynamic getCoinModel();
}
