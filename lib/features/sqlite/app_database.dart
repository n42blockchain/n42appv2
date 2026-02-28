import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/models/browser_history_model.dart';
import 'package:n42_wallet/features/browser/models/browser_search_history_model.dart';
import 'package:n42_wallet/features/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    _database ??= await getDatabaseInstance();
    return _database!;
  }

  // ─── 通用辅助方法 ──────────────────────────────────────────────────────────

  /// 通用查询：执行 query 后用 [fromMap] 映射每一行
  Future<List<T>> _queryList<T>(
    String table,
    T Function(Map<String, dynamic>) fromMap, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final rows = await db.query(table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
    return rows.map(fromMap).toList();
  }

  /// 给 where 子句追加 selectType 过滤条件
  /// selectType: 0=全部, 1=已完成(state=1), 2=未完成(state=0)
  static String appendStateFilter(String whereClause, int selectType) {
    if (selectType == 1) return '$whereClause and state=1';
    if (selectType == 2) return '$whereClause and state=0';
    return whereClause;
  }
  Future<Database> getDatabaseInstance() async {
    var directory = await getDatabasesPath();
    String path = join(directory, "astranet.db");
    return await openDatabase(
      path,
      version: 7, //v7: portfolio_trades for cost-basis P&L tracking
      onCreate: (Database db, int version) async {
        //交易记录
        await db.execute("create table TransationRecord("
            "trId integer primary key autoincrement,"
            "address text," //钱包地址
            "coinId int," //币id
            "from1 text,"
            "to1 text,"
            "price text,"
            "txHash text,"
            "state int," //0未成功，1成功，2失败
            "txTime text," //交易时间
            "errorMessage text," //交易失败原因
            "coinMiniName text," //币名字缩写
            "contract text," //合约地址
            "coin text,"
            "isTest int," //是否是测试网
            "testnetUri text," //测试网地址
            "userUuid text," //用户uuid
            "walletIndex int," //钱包id
            "message TEXT"//消息
            ")");
        //交易记录 btc
        await db.execute("create table BtcTransactionRecord("
            "trId integer primary key autoincrement,"
            "address text," //钱包地址
            "to1 text," //转账地址
            "price text," //转账btc数量
            "gas text," //旷工费btc数量
            "input text," //未花费交易
            "output text," //转账地址
            "txHash text,"
            "confirmations int," //确认数
            "state int," //0未完成，1完成，2失败
            "txTime text," //交易时间
            "errorMessage text," //交易失败原因
            "coinMiniName text," //币名字缩写
            "contract text," //合约地址
            "coin text,"
            "isTest int," //是否是测试网
            "testnetUri text," //测试网地址
            "userUuid text," //用户uuid
            "walletIndex int," //钱包id
            "gasPrice int"//交易费
            ")");

        /// address book
        await db.execute("create table AddressBook("
            "id integer primary key autoincrement,"
            "coinIcon text," //coin Icon
            "coinName text," //coin name
            "address text," //address
            "name text," //name
            "desc text" //desc
            ")");
        //浏览器收藏表
        await db.execute("create table browserCollection ("
            "id integer primary key autoincrement,"
            "name text,"
            "url text,"
            "desc text,"
            "favicon text,"
            "createdAt integer"
            ")");
        //浏览器浏览历史
        await db.execute("create table browserHistory ("
            "id integer primary key autoincrement,"
            "url text,"
            "time text,"
            "title text"
            ")");
        //浏览器搜索历史表
        await db.execute("create table browserSearchHistory ("
            "id integer primary key autoincrement,"
            "search text," //搜索内容
            "searchCount int" //搜索次数
            ")");
        //chat message
        await db.execute('''
          CREATE TABLE Messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            conversationType INTEGER,
            direction INTEGER,
            fromUser TEXT,
            line INTEGER,
            messageId INTEGER,
            sMessageId INTEGER,
            status INTEGER,
            target TEXT,
            timestamp INTEGER,
            content TEXT,
            user_id TEXT,
            targetId TEXT,
            decryptionMessageContent TEXT,
            reply_id INTEGER,
            is_mentioned INTEGER,
            mentioned_user_ids TEXT
          )
    ''');
        // AA 批量交易模板表
        await db.execute('''
          CREATE TABLE aa_batch_templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            chain_symbol TEXT NOT NULL,
            operations TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        // 投资组合盈亏 — 买入成本追踪表
        await db.execute('''
          CREATE TABLE portfolio_trades (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            coin_id TEXT NOT NULL,
            symbol TEXT NOT NULL,
            name TEXT NOT NULL,
            quantity REAL NOT NULL,
            buy_price_usd REAL NOT NULL,
            buy_time_ms INTEGER NOT NULL
          )
        ''');
        // AA Session Key 表
        await db.execute('''
          CREATE TABLE aa_session_keys (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key_address TEXT NOT NULL,
            label TEXT NOT NULL,
            permission TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            expires_at INTEGER NOT NULL,
            dapp_name TEXT,
            allowed_contracts TEXT,
            spending_limit TEXT,
            spending_token TEXT,
            used_amount TEXT,
            transaction_count INTEGER,
            chain_id INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
              ALTER TABLE BtcTransactionRecord
              ADD COLUMN gasPrice INTEGER
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE aa_batch_templates (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              chain_symbol TEXT NOT NULL,
              operations TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE aa_session_keys (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              key_address TEXT NOT NULL,
              label TEXT NOT NULL,
              permission TEXT NOT NULL,
              status TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              expires_at INTEGER NOT NULL,
              dapp_name TEXT,
              allowed_contracts TEXT,
              spending_limit TEXT,
              spending_token TEXT,
              used_amount TEXT,
              transaction_count INTEGER,
              chain_id INTEGER NOT NULL
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            ALTER TABLE browserHistory ADD COLUMN title TEXT
          ''');
        }
        if (oldVersion < 6) {
          await db.execute('''
            ALTER TABLE browserCollection ADD COLUMN favicon TEXT
          ''');
          await db.execute('''
            ALTER TABLE browserCollection ADD COLUMN createdAt INTEGER
          ''');
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE portfolio_trades (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              coin_id TEXT NOT NULL,
              symbol TEXT NOT NULL,
              name TEXT NOT NULL,
              quantity REAL NOT NULL,
              buy_price_usd REAL NOT NULL,
              buy_time_ms INTEGER NOT NULL
            )
          ''');
        }
      },
    );
  }

  //插入btc交易记录
  Future<int> insertBtcTransactionRecord(BtcTransactionRecodeModel btcm) async {
    final db = await database;
    return db.insert("BtcTransactionRecord", btcm.toMapDb(),
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  //查询btc交易记录
  //type，查询类型，0：查询全部，1查询完成的，2查询未完成的
  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecord(
      String userUuid, String address, String coinKey, int selectType,
      {int pageSize = 10, int pageNum = 1}) async {
    final whereClause =
        appendStateFilter('coinMiniName=? and address=?', selectType);
    return _queryList("BtcTransactionRecord", BtcTransactionRecodeModel.fromMap,
        where: whereClause,
        whereArgs: [coinKey, address],
        orderBy: "txTime desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
  }
  //查询交易记录,contract合约地址，主链币没有合约地址，默认为空字符串
  Future<List<TransationRecordModel>> selectTransationRecordMiniName(
      String address, String miniName, int selectType,
      {String contract = "",
        int pageSize = 10,
        int pageNum = 1,
        int isTest = 0}) async {
    final whereClause = appendStateFilter(
        'address=? and contract=? and isTest=? and coinMiniName=?', selectType);
    return _queryList("TransationRecord", TransationRecordModel.fromMap,
        where: whereClause,
        whereArgs: [address, contract.toLowerCase(), isTest, miniName],
        orderBy: "txTime desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
  }
  //创建一个交易记录
  Future<int> insertTransationRecord(TransationRecordModel trm) async {
    final db = await database;
    return db.insert("TransationRecord", trm.toMapDb(),
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  //修改交易记录
  Future<int> updateTransationRecord(TransationRecordModel trm) async {
    final db = await database;
    return db.update("TransationRecord", trm.toMapDb(),
        where: "trId=?", whereArgs: [trm.trId]);
  }

  Future<int> updateTransationRecordTxhash(TransationRecordModel trm) async {
    final db = await database;
    return db.update("TransationRecord", trm.toMapDb(),
        where: 'txHash=?', whereArgs: [trm.txHash]);
  }

  //修改btc交易记录
  Future<int> updateBtcTransactionRecord(BtcTransactionRecodeModel btcm) async {
    final db = await database;
    return db.update("BtcTransactionRecord", btcm.toMapDb(),
        where: "trId=?", whereArgs: [btcm.trId]);
  }

  //查询交易记录，txhash交易hash
  Future<List<TransationRecordModel>> selectTransationRecordTxHash(
      String txHash, String address) async {
    return _queryList("TransationRecord", TransationRecordModel.fromMap,
        where: 'txHash=? and address=?', whereArgs: [txHash, address]);
  }

  //查询交易记录，全部未完成的
  Future<List<TransationRecordModel>> selectTransationRecordUnDone(
      String userUuid) async {
    return _queryList("TransationRecord", TransationRecordModel.fromMap,
        where: 'state=0 and userUuid=?', whereArgs: [userUuid]);
  }

  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecordByUUID(
      String userUuid, int selectType) async {
    final whereClause = appendStateFilter('userUuid=?', selectType);
    return _queryList(
        "BtcTransactionRecord", BtcTransactionRecodeModel.fromMap,
        where: whereClause, whereArgs: [userUuid], orderBy: "trId desc");
  }

  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecordTxHash(
      String txHash) async {
    return _queryList(
        "BtcTransactionRecord", BtcTransactionRecodeModel.fromMap,
        where: 'txHash=?', whereArgs: [txHash]);
  }

  //添加浏览器收藏表
  Future<int> insertBrowserCollection(Map<String, dynamic> map) async {
    final db = await database;
    return db.insert("browserCollection", map,
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  //修改浏览器收藏表
  Future<int> updateBrowserCollection(Map<String, dynamic> map, int id) async {
    final db = await database;
    return db.update("browserCollection", map,
        where: "id=?", whereArgs: [id]);
  }

  //删除浏览器收藏表
  Future<void> deleteBrowserCollection(int id) async {
    final db = await database;
    await db.delete("browserCollection", where: "id=?", whereArgs: [id]);
  }

  Future<int> deleteBrowserCollectionUrl(String url) async {
    final db = await database;
    return db.delete("browserCollection", where: 'url=?', whereArgs: [url]);
  }

  Future<List<BrowserCollectionModel>> selectBrowserCollection(
      {int pageSize = 10, int pageNum = 1}) async {
    return _queryList("browserCollection", BrowserCollectionModel.fromJson,
        orderBy: "id desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
  }

  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(
      String url) async {
    return _queryList("browserCollection", BrowserCollectionModel.fromJson,
        where: 'url=?', whereArgs: [url]);
  }

  //添加浏览器浏览历史
  Future<int> insertBrowserHistory(Map<String, dynamic> map) async {
    final db = await database;
    return db.insert("browserHistory", map,
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  //查询 浏览器历史
  Future<List<BrowserHistoryModel>> selectBrowserHistoryLike(String urlStr,
      {int pageSize = 10, int pageNum = 1}) async {
    return _queryList("browserHistory", BrowserHistoryModel.fromJson,
        columns: ["url"],
        distinct: true,
        where: 'url like ?',
        whereArgs: ['%$urlStr%'],
        orderBy: "id desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
  }

  //查询搜索历史
  Future<List<BrowserSearchHistoryModel>> selectBrowserSearchHistory(
      {int pageSize = 10, int pageNum = 1}) async {
    return _queryList(
        "browserSearchHistory", BrowserSearchHistoryModel.fromJson,
        orderBy: "searchCount desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
  }
  //添加搜索历史
  Future<int?> insertBrowserSearchHistory(Map<String, dynamic> map) async {
    final db = await database;
    var response = await db.query(
      "browserSearchHistory",
      where: 'search=?',
      whereArgs: [map['search']],
      orderBy: "searchCount desc",
    );
    List<BrowserSearchHistoryModel> list =
    response.map((c) => BrowserSearchHistoryModel.fromJson(c)).toList();
    if (list.isEmpty) {
      var raw = await db.insert("browserSearchHistory", map,
          conflictAlgorithm: ConflictAlgorithm.rollback);
      return raw;
    } else {
      BrowserSearchHistoryModel bshm = list[0];
      bshm.searchCount = (bshm.searchCount ?? 0) + 1;
      await db.update('browserSearchHistory', bshm.getMap(),
          where: 'id=?', whereArgs: [bshm.id]);
    }
    return null;
  }

  //删除搜索历史
  Future<int> deleteBrowserSearchHistory() async {
    final db = await database;
    return db.delete('browserSearchHistory');
  }

  //分页查询浏览历史（按时间降序）
  Future<List<BrowserHistoryModel>> selectBrowserHistory(
      {int pageSize = 20, int pageNum = 1}) async {
    return _queryList("browserHistory", BrowserHistoryModel.fromJson,
        orderBy: "time desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
  }

  //删除单条浏览历史
  Future<void> deleteBrowserHistoryById(int id) async {
    final db = await database;
    await db.delete("browserHistory", where: "id=?", whereArgs: [id]);
  }

  //清空浏览历史
  Future<int> clearBrowserHistory() async {
    final db = await database;
    return db.delete("browserHistory");
  }
}