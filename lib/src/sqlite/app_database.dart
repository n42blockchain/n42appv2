import 'package:n42appv2/src/browser/models/browser_collection_model.dart';
import 'package:n42appv2/src/browser/models/browser_history_model.dart';
import 'package:n42appv2/src/browser/models/browser_search_history_model.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase{
  Database? _database;
  Future<Database> get database async {
    _database ??= await getDatabaseInstance();
    return _database!;
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
    var raw = await db.insert("BtcTransactionRecord", btcm.toMapDb(),
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }
  //查询btc交易记录
  //type，查询类型，0：查询全部，1查询完成的，2查询未完成的
  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecord(
      String userUuid, String address, String coinKey, int selectType,
      {int pageSize = 10, int pageNum = 1}) async {
    final db = await database;
    String whereClause = 'coinMiniName=? and address=?';
    List<dynamic> whereArgs = [coinKey, address];
    if (selectType == 1) {
      whereClause += ' and state=1';
    } else if (selectType == 2) {
      whereClause += ' and state=0';
    }
    var response = await db.query("BtcTransactionRecord",
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: "txTime desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
    List<BtcTransactionRecodeModel> list =
    response.map((c) => BtcTransactionRecodeModel.fromMap(c)).toList();
    return list;
  }
  //查询交易记录,contract合约地址，主链币没有合约地址，默认为空字符串
  Future<List<TransationRecordModel>> selectTransationRecordMiniName(
      String address, String miniName, int selectType,
      {String contract = "",
        int pageSize = 10,
        int pageNum = 1,
        int isTest = 0}) async {
    final db = await database;
    String whereClause = 'address=? and contract=? and isTest=? and coinMiniName=?';
    List<dynamic> whereArgs = [address, contract.toLowerCase(), isTest, miniName];
    if (selectType == 1) {
      whereClause += ' and state=1';
    } else if (selectType == 2) {
      whereClause += ' and state=0';
    }
    var response = await db.query("TransationRecord",
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: "txTime desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
    List<TransationRecordModel> list =
    response.map((c) => TransationRecordModel.fromMap(c)).toList();
    return list;
  }
  //创建一个交易记录
  Future<int> insertTransationRecord(TransationRecordModel trm) async {
    final db = await database;
    var raw = await db.insert("TransationRecord", trm.toMapDb(),
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }
  //修改交易记录
  Future<int> updateTransationRecord(TransationRecordModel trm) async {
    final db = await database;
    var response = await db.update("TransationRecord", trm.toMapDb(),
        where: "trId=?", whereArgs: [trm.trId]);
    return response;
  }
  Future<int> updateTransationRecordTxhash(TransationRecordModel trm) async {
    final db = await database;
    var response = await db.update("TransationRecord", trm.toMapDb(),
        where: 'txHash=?', whereArgs: [trm.txHash]);
    return response;
  }
  //修改btc交易记录
  Future<int> updateBtcTransactionRecord(BtcTransactionRecodeModel btcm) async {
    final db = await database;
    var response = await db.update("BtcTransactionRecord", btcm.toMapDb(),
        where: "trId=?", whereArgs: [btcm.trId]);
    return response;
  }
  //查询交易记录，txhash交易hash
  Future<List<TransationRecordModel>> selectTransationRecordTxHash(
      String txHash,String address) async {
    final db = await database;
    var response =
    await db.query("TransationRecord", where: 'txHash=? and address=?', whereArgs: [txHash, address]);
    List<TransationRecordModel> list =
    response.map((c) => TransationRecordModel.fromMap(c)).toList();
    return list;
  }
  //查询交易记录，全部未完成的
  Future<List<TransationRecordModel>> selectTransationRecordUnDone(
      String userUuid) async {
    final db = await database;
    var response = await db.query("TransationRecord",
        where: 'state=0 and userUuid=?', whereArgs: [userUuid]);
    List<TransationRecordModel> list =
    response.map((c) => TransationRecordModel.fromMap(c)).toList();
    return list;
  }
  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecordByUUID(
      String userUuid, int selectType) async {
    final db = await database;
    String whereClause = 'userUuid=?';
    List<dynamic> whereArgs = [userUuid];
    if (selectType == 1) {
      whereClause += ' and state=1';
    } else if (selectType == 2) {
      whereClause += ' and state=0';
    }
    var response = await db.query("BtcTransactionRecord",
        where: whereClause, whereArgs: whereArgs, orderBy: "trId desc");
    List<BtcTransactionRecodeModel> list =
    response.map((c) => BtcTransactionRecodeModel.fromMap(c)).toList();
    return list;
  }
  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecordTxHash(
      String txHash) async {
    final db = await database;
    var response = await db.query("BtcTransactionRecord",
        where: 'txHash=?', whereArgs: [txHash]);
    List<BtcTransactionRecodeModel> list =
    response.map((c) => BtcTransactionRecodeModel.fromMap(c)).toList();
    return list;
  }

  //添加浏览器收藏表
  Future<int> insertBrowserCollection(Map<String, dynamic> map) async {
    final db = await database;
    var raw = await db.insert("browserCollection", map,
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }

  //修改浏览器收藏表
  Future<int> updateBrowserCollection(Map<String, dynamic> map, int id) async {
    final db = await database;
    var response = await db.update("browserCollection", map,
        where: "id=?", whereArgs: [id]);
    return response;
  }

  //删除浏览器收藏表
  Future<void> deleteBrowserCollection(int id) async {
    final db = await database;
    await db.delete("browserCollection", where: "id=?", whereArgs: [id]);
  }

  Future<int> deleteBrowserCollectionUrl(String url) async {
    final db = await database;
    return await db.delete("browserCollection", where: 'url=?', whereArgs: [url]);
  }

  Future<List<BrowserCollectionModel>> selectBrowserCollection({int pageSize = 10, int pageNum = 1}) async {
    final db = await database;
    var response = await db.query("browserCollection",
        orderBy: "id desc", limit: pageSize, offset: (pageNum - 1) * pageSize);
    List<BrowserCollectionModel> list =
    response.map((c) => BrowserCollectionModel.fromJson(c)).toList();
    return list;
  }

  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(String url) async {
    final db = await database;
    var response = await db.query("browserCollection", where: 'url=?', whereArgs: [url]);
    List<BrowserCollectionModel> list =
    response.map((c) => BrowserCollectionModel.fromJson(c)).toList();
    return list;
  }

  //添加浏览器浏览历史
  Future<int> insertBrowserHistory(Map<String, dynamic> map) async {
    final db = await database;
    var raw = await db.insert("browserHistory", map,
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }
  //查询 浏览器历史
  Future<List<BrowserHistoryModel>> selectBrowserHistoryLike(String urlStr,
      {int pageSize = 10, int pageNum = 1}) async {
    final db = await database;
    var response = await db.query("browserHistory",
        columns: ["url"],
        distinct: true,
        where: 'url like ?',
        whereArgs: ['%$urlStr%'],
        orderBy: "id desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
    List<BrowserHistoryModel> list =
    response.map((c) => BrowserHistoryModel.fromJson(c)).toList();
    return list;
  }

  //查询搜索历史
  Future<List<BrowserSearchHistoryModel>> selectBrowserSearchHistory({int pageSize = 10, int pageNum = 1}) async {
    final db = await database;
    var response = await db.query("browserSearchHistory",
        orderBy: "searchCount desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
    List<BrowserSearchHistoryModel> list =
    response.map((c) => BrowserSearchHistoryModel.fromJson(c)).toList();
    return list;
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
    var raw = await db.delete('browserSearchHistory');
    return raw;
  }

  //分页查询浏览历史（按时间降序）
  Future<List<BrowserHistoryModel>> selectBrowserHistory(
      {int pageSize = 20, int pageNum = 1}) async {
    final db = await database;
    var response = await db.query("browserHistory",
        orderBy: "time desc",
        limit: pageSize,
        offset: (pageNum - 1) * pageSize);
    List<BrowserHistoryModel> list =
        response.map((c) => BrowserHistoryModel.fromJson(c)).toList();
    return list;
  }

  //删除单条浏览历史
  Future<void> deleteBrowserHistoryById(int id) async {
    final db = await database;
    await db.delete("browserHistory", where: "id=?", whereArgs: [id]);
  }

  //清空浏览历史
  Future<int> clearBrowserHistory() async {
    final db = await database;
    return await db.delete("browserHistory");
  }
}