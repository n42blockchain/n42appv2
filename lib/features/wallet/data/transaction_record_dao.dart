import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:sqflite/sqflite.dart';

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
    final db = await database;
    return db.update(
      "TransationRecord",
      trm.toMapDb(),
      where: 'txHash=?',
      whereArgs: [trm.txHash],
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
