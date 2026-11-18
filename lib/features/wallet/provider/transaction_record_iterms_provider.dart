import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/services/apt_submission_journal.dart';
import 'package:n42_wallet/generated/l10n.dart';

class TransactionRecordItemProvider with ChangeNotifier {
  AppDatabase? _db;
  AppDatabase get db {
    _db ??= AppDatabase();
    return _db!;
  }

  final TransactionStateResolver _resolver;
  final String Function() _userUuid;
  final Object? Function() _sessionIdentity;
  final Future<int> Function(TransationRecordModel) _aptSettler;
  bool _disposed = false;
  int _loadGeneration = 0;

  TransactionRecordItemProvider({
    AppDatabase? database,
    TransactionStateResolver? resolver,
    String Function()? userUuid,
    Object? Function()? sessionIdentity,
    Future<int> Function(TransationRecordModel)? aptSettler,
  }) : _db = database,
       _aptSettler = aptSettler ?? _settleAptRecord,
       _resolver = resolver ?? TransactionStateResolver(),
       _userUuid = userUuid ?? (() => AppGlobals.userInfo?.uuid ?? ''),
       _sessionIdentity = sessionIdentity ?? _currentSession;

  static Object _currentSession() {
    Object? wallet;
    try {
      wallet = (globalWapAdapter.walletIndex, globalWapAdapter.walletInfo);
    } catch (_) {
      // The account provider can load history before the wallet adapter exists.
    }
    return (AppGlobals.userInfo, AppGlobals.walletStorageUuid, wallet);
  }

  /// Aptos history is closed through its durable submission journal: the
  /// receipt (by hash) or the sequence/expiry proof saves the result and then
  /// clears the journal, so a confirmed transfer no longer blocks the next
  /// send. Returns 1/2 for a terminal result of [trm], -1 otherwise.
  static Future<int> _settleAptRecord(TransationRecordModel trm) async {
    try {
      final receipt = await AptSubmissionJournal().settle(
        chainId: trm.coinId,
        sender: trm.from1,
        hash: trm.txHash,
        api: AptApi(isTest: trm.isTest == 1),
        saveResult: AppDatabase().completeAptFromReceipt,
      );
      return switch (receipt?.status) {
        AptTransactionStatus.succeeded => 1,
        AptTransactionStatus.failed || AptTransactionStatus.expired => 2,
        _ => -1,
      };
    } catch (_) {
      return -1;
    }
  }

  Future<(int, String?)> _resolve(TransationRecordModel trm) async =>
      trm.coinMiniName == 'APT'
      ? (await _aptSettler(trm), null)
      : _resolver.resolveStateWithReason(trm);

  Object get _session => (_userUuid(), _sessionIdentity(), _loadGeneration);
  bool _isCurrent(Object session) => !_disposed && _session == session;

  // 未完成的 EVM/Solana 等交易列表
  List<TransationRecordModel> _unDoneTrModelList = [];
  List<TransationRecordModel> get unDoneTrModelList => _unDoneTrModelList;

  // 比特币类 未完成列表
  List<BtcTransactionRecodeModel> _trUndoneList = [];
  List<BtcTransactionRecodeModel> get trUndoneList => _trUndoneList;

  Timer? _timer;
  Timer? _timerBtc;

  @override
  void dispose() {
    _disposed = true;
    _loadGeneration++;
    _timer?.cancel();
    _timer = null;
    _timerBtc?.cancel();
    _timerBtc = null;
    super.dispose();
  }

  // 查询未完成的交易（启动时调用）
  Future<void> selectUndoneTr() async {
    if (_disposed) return;
    _loadGeneration++;
    final session = _session;
    final user = _userUuid();
    _unDoneTrModelList = [];
    _trUndoneList = [];
    checkUndoneList();
    notifyListeners();
    final transactions = await db.selectTransationRecordUnDone(user);
    if (!_isCurrent(session)) return;
    final btc = await db.selectBtcTransationRecordByUUID(user, 2);
    if (!_isCurrent(session)) return;
    _unDoneTrModelList = transactions;
    _trUndoneList = btc;
    if (_unDoneTrModelList.isNotEmpty) timerStart();
    if (_trUndoneList.isNotEmpty) timerStartBtc();
    notifyListeners();
  }

  // 添加未完成的交易；type：0=比特币类，1=其它类型
  void addUndoneTr(dynamic trm, int type) {
    if (_disposed || trm.userUuid != _userUuid()) return;
    if (type == 1) {
      _unDoneTrModelList.add(trm);
      timerStart();
    } else {
      _trUndoneList.add(trm);
      timerStartBtc();
    }
    notifyListeners();
  }

  void timerStart() {
    if (_disposed || (_timer != null && _timer!.isActive)) return;
    // Keep this latch local to the timer: a replaced timer must not unlock or
    // block its successor when an old request eventually returns.
    var running = false;
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (running || _disposed || !identical(timer, _timer)) return;
      running = true;
      final session = _session;
      try {
        if (_unDoneTrModelList.isEmpty) {
          timer.cancel();
          _timer = null;
          return;
        }
        final pending = List<TransationRecordModel>.of(_unDoneTrModelList);
        for (final trm in pending) {
          if (!_isCurrent(session) || !identical(timer, _timer)) break;
          if (!_unDoneTrModelList.contains(trm)) continue;
          try {
            await checkUndoneTr(trm);
          } catch (_) {
            // A malformed record must not starve the rest of this queue.
            AppLogger.w('TxRecordItems', 'Pending transaction check failed');
          }
        }
      } finally {
        running = false;
      }
    });
  }

  void timerStartBtc() {
    if (_disposed || (_timerBtc != null && _timerBtc!.isActive)) return;
    var running = false;
    _timerBtc = Timer.periodic(const Duration(seconds: 180), (timer) async {
      if (running || _disposed || !identical(timer, _timerBtc)) return;
      running = true;
      final session = _session;
      try {
        if (_trUndoneList.isEmpty) {
          timer.cancel();
          _timerBtc = null;
          return;
        }
        for (final trm in List<BtcTransactionRecodeModel>.of(_trUndoneList)) {
          if (!_isCurrent(session) || !identical(timer, _timerBtc)) break;
          if (!_trUndoneList.contains(trm)) continue;
          try {
            await checkUndoneTrBtc(trm);
          } catch (_) {
            AppLogger.w(
              'TxRecordItems',
              'Pending BTC transaction check failed',
            );
          }
        }
      } finally {
        running = false;
      }
    });
  }

  // 检查未完成的交易（有副作用：数据库更新 + Toast + 事件）
  Future<void> checkUndoneTr(TransationRecordModel trm) async {
    final session = _session;
    if (!_isCurrent(session) || trm.userUuid != _userUuid()) return;
    final (resolved, reason) = await _resolve(trm);
    if (!_isCurrent(session) || trm.userUuid != _userUuid()) return;

    // -1 = RPC 错误，无法判断状态，跳过本次
    if (resolved == -1 || resolved == 0) return;

    final candidate = TransationRecordModel.fromMap(trm.toMap())
      ..state = resolved;
    // Keep the chain's own failure reason with a failed record.
    if (resolved == 2 && reason != null) candidate.errorMessage = reason;
    final updated = await db.updateTransationRecordTxhash(candidate);
    if (!_isCurrent(session) || updated == 0) return;
    trm.state = resolved;
    if (resolved == 2 && reason != null) trm.errorMessage = reason;

    if (resolved == 1) {
      ToastUtils.show(S.current.g_key_140);
      if (AppGlobals.appContext.mounted &&
          globalWapAdapter.walletIndex == trm.walletIndex) {
        globalWapAdapter.refreshCoinBalance(
          trm.coin['coinType'],
          contract: trm.contract,
        );
        eventBus.fire(EventPublic(EventPublicType.transferOk));
      }
    } else if (resolved == 2) {
      ToastUtils.show(S.current.g_key_175);
    }

    _unDoneTrModelList.remove(trm);
    checkUndoneList();
    notifyListeners();
  }

  // 检查未完成的交易并返回更新后的对象（无 Toast/事件副作用）
  Future<TransationRecordModel?> checkUndoneTrReturn(
    TransationRecordModel trm,
  ) async {
    final session = _session;
    if (!_isCurrent(session) || trm.userUuid != _userUuid()) return null;
    final (resolved, reason) = await _resolve(trm);
    if (!_isCurrent(session) || trm.userUuid != _userUuid()) return null;

    if (![0, 1, 2].contains(resolved)) return null;
    final candidate = TransationRecordModel.fromMap(trm.toMap())
      ..state = resolved;
    // Keep the chain's own failure reason with a failed record.
    if (resolved == 2 && reason != null) candidate.errorMessage = reason;
    final updated = await db.updateTransationRecordTxhash(candidate);
    if (!_isCurrent(session) || updated == 0) return null;
    trm.state = resolved;
    if (resolved == 2 && reason != null) trm.errorMessage = reason;
    return trm;
  }

  // 检查未完成的 BTC 类交易（有副作用）
  Future<void> checkUndoneTrBtc(BtcTransactionRecodeModel trm) async {
    final session = _session;
    if (!_isCurrent(session) || trm.userUuid != _userUuid()) return;
    final int confirmations = await _resolver.resolveBtcConfirmations(trm);
    if (!_isCurrent(session) || trm.userUuid != _userUuid()) return;
    if (confirmations < 0) return; // 查询失败

    // 主网记录实际确认数；测试网只需判断是否达标（resolveBtc 已返回 0 或 6）
    if (trm.isTest != 1) trm.confirmations = confirmations;
    if (confirmations >= 6) trm.state = 1;
    await db.updateBtcTransactionRecord(trm);
    if (!_isCurrent(session)) return;

    // 未达标则本轮保留在列表继续轮询
    if (trm.state != 1) return;

    // 修复：原代码在 isTest==1 分支 state==1 后 return、以及 unmount 时 return，
    // 都不从列表移除也不停定时器，导致测试网 / 后台场景下 BTC 定时器永不停止。
    // 刷新余额/发事件只在 mounted 时做，但移除+停表+通知无论如何都执行。
    if (AppGlobals.appContext.mounted &&
        globalWapAdapter.walletIndex == trm.walletIndex) {
      await globalWapAdapter.refreshCoinBalance(
        trm.coin['coinType'],
        contract: '',
      );
      if (!_isCurrent(session)) return;
      eventBus.fire(EventPublic(EventPublicType.transferOk));
    }
    _trUndoneList.remove(trm);
    checkUndoneList();
    notifyListeners();
  }

  // 检查未完成的 BTC 类交易并返回更新后的对象
  Future<BtcTransactionRecodeModel?> checkUndoneTrBtcReturn(
    BtcTransactionRecodeModel trm,
  ) async {
    final session = _session;
    if (!_isCurrent(session) || trm.userUuid != _userUuid()) return null;
    final int confirmations = await _resolver.resolveBtcConfirmations(trm);
    if (!_isCurrent(session) || trm.userUuid != _userUuid()) return null;
    if (confirmations < 0) return null; // 查询失败

    if (trm.isTest == 1) {
      if (confirmations >= 6) {
        trm.state = 1;
        await db.updateBtcTransactionRecord(trm);
        if (!_isCurrent(session)) return null;
      }
      return trm;
    }

    trm.confirmations = confirmations;
    if (trm.confirmations >= 6) {
      trm.state = 1;
    }
    await db.updateBtcTransactionRecord(trm);
    if (!_isCurrent(session)) return null;
    return trm;
  }

  void checkUndoneList() {
    if (_trUndoneList.isEmpty && _timerBtc != null) {
      _timerBtc!.cancel();
      _timerBtc = null;
    }
    if (_unDoneTrModelList.isEmpty && _timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
}
