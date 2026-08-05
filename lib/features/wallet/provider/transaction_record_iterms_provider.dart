import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_record_dao.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_state_resolver.dart';
import 'package:n42_wallet/generated/l10n.dart';

class TransactionRecordItemProvider with ChangeNotifier {
  AppDatabase? _db;
  AppDatabase get db {
    _db ??= AppDatabase();
    return _db!;
  }

  final TransactionStateResolver _resolver = TransactionStateResolver();

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
    _timer?.cancel();
    _timer = null;
    _timerBtc?.cancel();
    _timerBtc = null;
    super.dispose();
  }

  // 查询未完成的交易（启动时调用）
  Future<void> selectUndoneTr() async {
    _unDoneTrModelList = await db.selectTransationRecordUnDone(
      AppGlobals.userInfo?.uuid ?? '',
    );
    _trUndoneList = await db.selectBtcTransationRecordByUUID(
      AppGlobals.userInfo?.uuid ?? '',
      2,
    );
    if (_unDoneTrModelList.isNotEmpty) timerStart();
    if (_trUndoneList.isNotEmpty) timerStartBtc();
    notifyListeners();
  }

  // 添加未完成的交易；type：0=比特币类，1=其它类型
  void addUndoneTr(dynamic trm, int type) {
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
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        if (_unDoneTrModelList.isEmpty) {
          timer.cancel();
          _timer = null;
          return;
        }
        // Snapshot list to avoid concurrent modification during async iteration
        final pending = List<TransationRecordModel>.of(_unDoneTrModelList);
        for (final trm in pending) {
          await checkUndoneTr(trm);
        }
      } on Exception catch (e) {
        AppLogger.w('TxRecordItems', 'timerStart callback error: $e');
      }
    });
  }

  void timerStartBtc() {
    if (_timerBtc != null && _timerBtc!.isActive) return;
    // callback 必须 async：否则 checkUndoneTrBtc 是 fire-and-forget，
    // 空列表检查会在异步完成前执行，定时器永远无法停止
    _timerBtc = Timer.periodic(const Duration(seconds: 180), (timer) async {
      try {
        if (_trUndoneList.isEmpty) {
          timer.cancel();
          _timerBtc = null;
          return;
        }
        for (final trm in List<BtcTransactionRecodeModel>.of(_trUndoneList)) {
          await checkUndoneTrBtc(trm);
        }
      } on Exception catch (e) {
        AppLogger.w('TxRecordItems', 'timerStartBtc callback error: $e');
      }
    });
  }

  // 检查未完成的交易（有副作用：数据库更新 + Toast + 事件）
  Future<void> checkUndoneTr(TransationRecordModel trm) async {
    final int resolved = await _resolver.resolveState(trm);

    // -1 = RPC 错误，无法判断状态，跳过本次
    if (resolved == -1 || resolved == 0) return;

    trm.state = resolved;
    await db.updateTransationRecord(trm);

    if (resolved == 1) {
      ToastUtils.show(S.current.g_key_140);
      if (!AppGlobals.appContext.mounted) return;
      globalWapAdapter.refreshCoinBalance(
        trm.coin['coinType'],
        contract: trm.contract,
      );
      eventBus.fire(EventPublic(EventPublicType.transferOk));
    } else if (resolved == 2) {
      ToastUtils.show(S.current.g_key_175);
    }

    _removeFromUndoneList(trm.txHash);
    checkUndoneList();
    notifyListeners();
  }

  // 检查未完成的交易并返回更新后的对象（无 Toast/事件副作用）
  Future<TransationRecordModel?> checkUndoneTrReturn(
    TransationRecordModel trm,
  ) async {
    final int resolved = await _resolver.resolveState(trm);

    // -1 = RPC 错误，无法判断状态
    if (resolved == -1) return null;
    if (resolved == 0) {
      await db.updateTransationRecordTxhash(trm);
      return trm;
    }

    trm.state = resolved;
    await db.updateTransationRecordTxhash(trm);
    return trm;
  }

  // 检查未完成的 BTC 类交易（有副作用）
  Future<void> checkUndoneTrBtc(BtcTransactionRecodeModel trm) async {
    final int confirmations = await _resolver.resolveBtcConfirmations(trm);
    if (confirmations < 0) return; // 查询失败

    // 主网记录实际确认数；测试网只需判断是否达标（resolveBtc 已返回 0 或 6）
    if (trm.isTest != 1) trm.confirmations = confirmations;
    if (confirmations >= 6) trm.state = 1;
    await db.updateBtcTransactionRecord(trm);

    // 未达标则本轮保留在列表继续轮询
    if (trm.state != 1) return;

    // 修复：原代码在 isTest==1 分支 state==1 后 return、以及 unmount 时 return，
    // 都不从列表移除也不停定时器，导致测试网 / 后台场景下 BTC 定时器永不停止。
    // 刷新余额/发事件只在 mounted 时做，但移除+停表+通知无论如何都执行。
    if (AppGlobals.appContext.mounted) {
      await globalWapAdapter.refreshCoinBalance(
        trm.coin['coinType'],
        contract: '',
      );
      eventBus.fire(EventPublic(EventPublicType.transferOk));
    }
    _trUndoneList.removeWhere((v) => v.txHash == trm.txHash);
    checkUndoneList();
    notifyListeners();
  }

  // 检查未完成的 BTC 类交易并返回更新后的对象
  Future<BtcTransactionRecodeModel?> checkUndoneTrBtcReturn(
    BtcTransactionRecodeModel trm,
  ) async {
    final int confirmations = await _resolver.resolveBtcConfirmations(trm);
    if (confirmations < 0) return null; // 查询失败

    if (trm.isTest == 1) {
      if (confirmations >= 6) {
        trm.state = 1;
        await db.updateBtcTransactionRecord(trm);
      }
      return trm;
    }

    trm.confirmations = confirmations;
    if (trm.confirmations >= 6) {
      trm.state = 1;
    }
    await db.updateBtcTransactionRecord(trm);
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

  // ---------- private helpers ----------

  void _removeFromUndoneList(String txHash) {
    final int index = _unDoneTrModelList.indexWhere((v) => v.txHash == txHash);
    if (index >= 0) {
      _unDoneTrModelList.removeAt(index);
    }
  }
}
