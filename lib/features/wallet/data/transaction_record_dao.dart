import 'package:fast_base58/fast_base58.dart';

import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/apt_api.dart';
import 'package:n42_wallet/features/wallet/services/apt_submission_journal.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:sqflite/sqflite.dart';

bool _validMemoHash(Object? chain, String hash) {
  if (chain == 'NEAR') {
    if (hash.length < 32 || hash.length > 44) return false;
    try {
      final bytes = Base58Decode(hash);
      return bytes.length == 32 && Base58Encode(bytes) == hash;
    } catch (_) {
      return false;
    }
  }
  return hash.length == 64 && RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash);
}

/// An unresolved submission already reserves this account/sender/network.
class PendingMemoTransactionException implements Exception {
  const PendingMemoTransactionException();
}

/// Dispatch phase of a pending ADA/XLM/EGLD/NEAR row whose outcome could not
/// be determined and which the user chose to stop waiting for. The row keeps
/// state=0 (its outcome is still unknown and it is still polled), but it no
/// longer reserves the sender.
const memoPhaseDismissed = 'dismissed';

const _blockingMemoWhere =
    "userUuid=? AND coinMiniName=? AND from1=? AND isTest=? AND state=0 AND (memoDispatchPhase IS NULL OR memoDispatchPhase<>'$memoPhaseDismissed')";

/// 本地交易记录（含 BTC UTXO 记录）的类型化 DAO。
///
/// 以 extension 挂在 [AppDatabase] 上：表 schema 归 sqlite 模块集中管理，
/// 模型映射归 wallet feature 自有，sqlite 模块不反向依赖 feature 模型。
extension TransactionRecordDao on AppDatabase {
  //插入btc交易记录
  Future<int> insertBtcTransactionRecord(BtcTransactionRecodeModel btcm) async {
    final db = await database;
    return db.insert(
      "BtcTransactionRecord",
      btcm.toMapDb(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  //查询btc交易记录
  //type，查询类型，0：查询全部，1查询完成的，2查询未完成的
  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecord(
    String userUuid,
    String address,
    String coinKey,
    int selectType, {
    int pageSize = 10,
    int pageNum = 1,
  }) async {
    final whereClause = AppDatabase.appendStateFilter(
      'coinMiniName=? and address=?',
      selectType,
    );
    return queryList(
      "BtcTransactionRecord",
      BtcTransactionRecodeModel.fromMap,
      where: whereClause,
      whereArgs: [coinKey, address],
      orderBy: "txTime desc",
      limit: pageSize,
      offset: (pageNum - 1) * pageSize,
    );
  }

  //查询交易记录,contract合约地址，主链币没有合约地址，默认为空字符串
  Future<List<TransationRecordModel>> selectTransationRecordMiniName(
    String address,
    String miniName,
    int selectType, {
    String contract = "",
    int pageSize = 10,
    int pageNum = 1,
    int isTest = 0,
  }) async {
    final whereClause = AppDatabase.appendStateFilter(
      'address=? and contract=? and isTest=? and coinMiniName=?',
      selectType,
    );
    return queryList(
      "TransationRecord",
      TransationRecordModel.fromMap,
      where: whereClause,
      whereArgs: [address, contract.toLowerCase(), isTest, miniName],
      orderBy: "txTime desc",
      limit: pageSize,
      offset: (pageNum - 1) * pageSize,
    );
  }

  //创建一个交易记录
  Future<int> insertTransationRecord(TransationRecordModel trm) async {
    final db = await database;
    return db.insert(
      "TransationRecord",
      trm.toMapDb(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  /// Atomically reserve ADA/XLM/EGLD/NEAR history before any broadcast. A new page or
  /// process must not bypass an existing unresolved submission. Even an equal
  /// hash is rejected: it may already have been broadcast by the other caller.
  Future<int> reserveMemoTransaction(
    TransationRecordModel record, {
    bool trackDispatch = false,
  }) async {
    final values = Map<String, Object?>.from(record.toMapDb());
    final hash = values['txHash'] as String;
    if (!{'ADA', 'XLM', 'EGLD', 'NEAR'}.contains(values['coinMiniName']) ||
        !_validMemoHash(values['coinMiniName'], hash) ||
        (values['from1'] as String).isEmpty ||
        ![0, 1].contains(values['isTest']) ||
        values['state'] != 0) {
      throw ArgumentError('Invalid memo transaction reservation');
    }
    final db = await database;
    return db.transaction((txn) async {
      if (trackDispatch) {
        // Only callers wired to markMemoTransactionDispatch may create this
        // phase. A concurrent old caller cannot broadcast after removal: its
        // exact-row dispatch transition will fail.
        await txn.delete(
          'TransationRecord',
          where: 'userUuid=? AND coinMiniName=? AND from1=? AND isTest=? AND state=0 AND memoDispatchPhase=?',
          whereArgs: [
            values['userUuid'],
            values['coinMiniName'],
            values['from1'],
            values['isTest'],
            'reserved',
          ],
        );
        values['memoDispatchPhase'] = 'reserved';
      }
      final expiry = record.memoExpiry;
      if (expiry != null && expiry.isNotEmpty) values['memoExpiry'] = expiry;
      // A row the user explicitly dismissed stays pending history (it is
      // still polled and may still resolve) but no longer blocks a send.
      final pending = await txn.query(
        'TransationRecord',
        columns: ['trId'],
        where: _blockingMemoWhere,
        whereArgs: [
          values['userUuid'],
          values['coinMiniName'],
          values['from1'],
          values['isTest'],
        ],
        limit: 1,
      );
      if (pending.isNotEmpty) throw const PendingMemoTransactionException();
      return txn.insert(
        'TransationRecord',
        values,
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
    });
  }

  /// Pending rows that currently reserve this sender (oldest first). Used to
  /// show the user what is blocking a new send.
  Future<List<TransationRecordModel>> selectBlockingMemoTransactions({
    required String userUuid,
    required String coinMiniName,
    required String from,
    required int isTest,
  }) {
    return queryList(
      'TransationRecord',
      TransationRecordModel.fromMap,
      where: _blockingMemoWhere,
      whereArgs: [userUuid, coinMiniName, from, isTest],
      orderBy: 'trId asc',
    );
  }

  /// The user confirmed, after a warning that the original may still land,
  /// that the unresolved rows reserving this sender should stop blocking new
  /// sends. Their state stays 0, so a later chain result still updates them;
  /// nothing is reported as failed.
  Future<int> dismissPendingMemoTransactions({
    required String userUuid,
    required String coinMiniName,
    required String from,
    required int isTest,
  }) async {
    if (!{'ADA', 'XLM', 'EGLD', 'NEAR'}.contains(coinMiniName) ||
        userUuid.isEmpty ||
        from.isEmpty ||
        ![0, 1].contains(isTest)) {
      throw ArgumentError('Invalid memo transaction dismissal');
    }
    final db = await database;
    return db.update(
      'TransationRecord',
      {'memoDispatchPhase': memoPhaseDismissed},
      // A 'reserved' row never reached the broadcast API and is replaced by
      // the next tracked reservation; it is left to that path.
      where:
          "userUuid=? AND coinMiniName=? AND from1=? AND isTest=? AND state=0 AND (memoDispatchPhase IS NULL OR memoDispatchPhase='dispatching')",
      whereArgs: [userUuid, coinMiniName, from, isTest],
    );
  }

  /// Persist possible dispatch before invoking the network. Failure or a lost
  /// acknowledgement must abort that invocation; an unknown phase is not safe.
  Future<bool> markMemoTransactionDispatch(TransationRecordModel record) async {
    final values = Map<String, Object?>.from(record.toMapDb());
    final id = record.trId;
    if (id <= 0 ||
        !{'ADA', 'XLM', 'EGLD', 'NEAR'}.contains(values['coinMiniName'])) {
      return false;
    }
    final db = await database;
    return await db.update(
          'TransationRecord',
          {'memoDispatchPhase': 'dispatching'},
          where: 'trId=? AND txHash=? AND userUuid=? AND walletIndex=? AND coinMiniName=? AND coinId=? AND from1=? AND to1=? AND price=? AND contract=? AND isTest=? AND state=0 AND memoDispatchPhase=?',
          whereArgs: [
            id,
            values['txHash'],
            values['userUuid'],
            values['walletIndex'],
            values['coinMiniName'],
            values['coinId'],
            values['from1'],
            values['to1'],
            values['price'],
            values['contract'],
            values['isTest'],
            'reserved',
          ],
        ) ==
        1;
  }

  /// Close the exact pending row as failed after the submission API explicitly
  /// refused that signed transaction (SendResult.rejected). The row is kept
  /// as failed history. Timeout/not-found is never sufficient for this call.
  Future<bool> markMemoTransactionRejected(
    TransationRecordModel record,
    String reason,
  ) async {
    final values = Map<String, Object?>.from(record.toMapDb());
    final id = record.trId;
    final hash = values['txHash'] as String;
    if (id <= 0 ||
        !{'ADA', 'XLM', 'EGLD', 'NEAR'}.contains(values['coinMiniName']) ||
        !_validMemoHash(values['coinMiniName'], hash)) {
      return false;
    }
    final db = await database;
    final updated = await db.update(
      'TransationRecord',
      {'state': 2, 'errorMessage': reason},
      where: 'trId=? AND txHash=? AND userUuid=? AND walletIndex=? AND coinMiniName=? AND coinId=? AND from1=? AND to1=? AND price=? AND contract=? AND isTest=? AND state=0',
      whereArgs: [
        id,
        hash,
        values['userUuid'],
        values['walletIndex'],
        values['coinMiniName'],
        values['coinId'],
        values['from1'],
        values['to1'],
        values['price'],
        values['contract'],
        values['isTest'],
      ],
    );
    return updated == 1;
  }

  /// Release only the exact pending row after a sender proves no broadcast API
  /// was invoked. Timeout/not-found is never sufficient evidence for this call.
  Future<bool> releaseUnsubmittedMemoTransaction(
    TransationRecordModel record,
  ) async {
    final values = Map<String, Object?>.from(record.toMapDb());
    final id = record.trId;
    final hash = values['txHash'] as String;
    if (id <= 0 ||
        !{'ADA', 'XLM', 'EGLD', 'NEAR'}.contains(values['coinMiniName']) ||
        !_validMemoHash(values['coinMiniName'], hash)) {
      return false;
    }
    final db = await database;
    final removed = await db.delete(
      'TransationRecord',
      where: 'trId=? AND txHash=? AND userUuid=? AND walletIndex=? AND coinMiniName=? AND coinId=? AND from1=? AND to1=? AND price=? AND contract=? AND isTest=? AND state=0',
      whereArgs: [
        id,
        hash,
        values['userUuid'],
        values['walletIndex'],
        values['coinMiniName'],
        values['coinId'],
        values['from1'],
        values['to1'],
        values['price'],
        values['contract'],
        values['isTest'],
      ],
    );
    return removed == 1;
  }

  /// Idempotent Aptos history persistence for submission/recovery retries.
  /// Snapshot caller-owned state before opening the database asynchronously.
  Future<int> saveAptTransactionRecord(TransationRecordModel record) async {
    final values = Map<String, Object?>.from(record.toMapDb());
    final hash = record.txHash.toLowerCase();
    final sender = record.from1;
    if (record.coinMiniName != 'APT' ||
        record.coinId < 1 ||
        record.coinId > 255 ||
        ![0, 1, 2].contains(record.state) ||
        !RegExp(r'^0x[0-9a-f]{64}$').hasMatch(hash) ||
        hash.length != 66 ||
        !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(sender) ||
        sender.contains(RegExp(r'\s'))) {
      throw ArgumentError('Invalid Aptos history record');
    }
    values['txHash'] = hash;
    values['from1'] = '0x${sender.substring(2).toLowerCase().padLeft(64, '0')}';
    const where =
        'userUuid=? AND walletIndex=? AND coinMiniName=? AND coinId=? AND from1=? AND txHash=?';
    final args = [
      values['userUuid'],
      values['walletIndex'],
      'APT',
      values['coinId'],
      values['from1'],
      hash,
    ];
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        'TransationRecord',
        where: where,
        whereArgs: args,
      );
      if (rows.length > 1) throw StateError('Ambiguous Aptos history record');
      if (rows.isEmpty) return txn.insert('TransationRecord', values);
      final previous = rows.single;
      // A stale acknowledgement must not regress a recovered terminal result.
      final oldState = previous['state'];
      if (oldState == 1 || oldState == 2) {
        if (values['state'] != 0 && values['state'] != oldState) {
          throw StateError('Conflicting Aptos execution result');
        }
        return previous['trId'] as int;
      }
      // Keep the original payment details; recovery only changes outcome fields.
      await txn.update(
        'TransationRecord',
        {'state': values['state'], 'errorMessage': values['errorMessage']},
        where: 'trId=?',
        whereArgs: [previous['trId']],
      );
      return previous['trId'] as int;
    });
  }

  /// Journal reconciliation writer shared by the send page, the sender and
  /// the history poller.
  Future<void> completeAptFromReceipt(
    AptPendingSubmission pending,
    AptTransactionReceipt receipt,
  ) => completeAptTransactionRecord(
    chainId: pending.chainId,
    sender: pending.sender,
    hash: pending.hash,
    success: receipt.status == AptTransactionStatus.succeeded,
    neverSubmitted:
        !pending.submissionAttempted &&
        receipt.status == AptTransactionStatus.notSubmitted,
  );

  /// Complete existing records; never invent a payment on recovery.
  /// A proven unsubmitted reservation removes only local pending history so
  /// a later retry with identical signed bytes cannot inherit a failed state.
  Future<void> completeAptTransactionRecord({
    required int chainId,
    required String sender,
    required String hash,
    required bool success,
    bool neverSubmitted = false,
  }) async {
    if ((neverSubmitted && success) ||
        chainId < 1 ||
        chainId > 255 ||
        !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(sender) ||
        sender.contains(RegExp(r'\s')) ||
        !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(hash) ||
        hash.length != 66) {
      throw ArgumentError('Invalid Aptos recovery identity');
    }
    final canonical = '0x${sender.substring(2).toLowerCase().padLeft(64, '0')}';
    const where = 'coinMiniName=? AND coinId=? AND from1=? AND txHash=?';
    final args = ['APT', chainId, canonical, hash.toLowerCase()];
    final state = success ? 1 : 2;
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'TransationRecord',
        where: where,
        whereArgs: args,
      );
      if (rows.isEmpty) {
        // A prepared journal can survive a crash before the history insert.
        if (neverSubmitted) return;
        throw StateError('Original Aptos transaction record is missing');
      }
      if (neverSubmitted) {
        if (rows.any((row) => row['state'] != 0)) {
          throw StateError(
            'Unsubmitted Aptos reservation has terminal history',
          );
        }
        await txn.delete('TransationRecord', where: where, whereArgs: args);
        return;
      }
      if (rows.any((row) => row['state'] != 0 && row['state'] != state)) {
        throw StateError('Conflicting Aptos execution result');
      }
      await txn.update(
        'TransationRecord',
        {'state': state},
        where: where,
        whereArgs: args,
      );
    });
  }

  //修改交易记录
  Future<int> updateTransationRecord(TransationRecordModel trm) async {
    final db = await database;
    return db.update(
      "TransationRecord",
      trm.toMapDb(),
      where: "trId=?",
      whereArgs: [trm.trId],
    );
  }

  Future<int> updateTransationRecordTxhash(TransationRecordModel trm) async {
    // A chain hash can appear in several users' histories. Never overwrite
    // another owner's record merely because it describes the same transaction.
    final values = Map<String, Object?>.from(trm.toMapDb());
    final recordId = trm.trId;
    final state = values['state'];
    if (![0, 1, 2].contains(state)) return 0;
    // Background and explicit refresh may finish out of order. A pending or
    // conflicting response must not downgrade an already persisted terminal
    // result. Same-terminal refreshes remain idempotent for queue cleanup.

    final where =
        'txHash=? AND userUuid=? AND walletIndex=? AND coinMiniName=? '
        'AND coinId=? AND from1=? AND isTest=? AND contract=? '
        'AND (state=0 OR state=?)';
    final args = <Object?>[
      values['txHash'],
      values['userUuid'],
      values['walletIndex'],
      values['coinMiniName'],
      values['coinId'],
      values['from1'],
      values['isTest'],
      values['contract'],
      state,
    ];
    final db = await database;
    return db.update(
      "TransationRecord",
      values,
      where: recordId > 0 ? '$where AND trId=?' : where,
      whereArgs: recordId > 0 ? [...args, recordId] : args,
    );
  }

  //修改btc交易记录
  Future<int> updateBtcTransactionRecord(BtcTransactionRecodeModel btcm) async {
    final db = await database;
    return db.update(
      "BtcTransactionRecord",
      btcm.toMapDb(),
      where: "trId=?",
      whereArgs: [btcm.trId],
    );
  }

  //查询交易记录，txhash交易hash
  Future<List<TransationRecordModel>> selectTransationRecordTxHash(
    String txHash,
    String address,
  ) async {
    return queryList(
      "TransationRecord",
      TransationRecordModel.fromMap,
      where: 'txHash=? and address=?',
      whereArgs: [txHash, address],
    );
  }

  //查询交易记录，全部未完成的
  Future<List<TransationRecordModel>> selectTransationRecordUnDone(
    String userUuid,
  ) async {
    return queryList(
      "TransationRecord",
      TransationRecordModel.fromMap,
      where: 'state=0 and userUuid=?',
      whereArgs: [userUuid],
    );
  }

  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecordByUUID(
    String userUuid,
    int selectType,
  ) async {
    final whereClause = AppDatabase.appendStateFilter('userUuid=?', selectType);
    return queryList(
      "BtcTransactionRecord",
      BtcTransactionRecodeModel.fromMap,
      where: whereClause,
      whereArgs: [userUuid],
      orderBy: "trId desc",
    );
  }

  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecordTxHash(
    String txHash,
  ) async {
    return queryList(
      "BtcTransactionRecord",
      BtcTransactionRecodeModel.fromMap,
      where: 'txHash=?',
      whereArgs: [txHash],
    );
  }
}
