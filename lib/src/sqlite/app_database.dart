import 'package:n42appv2/src/browser/models/browser_collection_model.dart';
import 'package:n42appv2/src/browser/models/browser_history_model.dart';
import 'package:n42appv2/src/browser/models/browser_search_history_model.dart';
import 'package:n42appv2/src/wallet/models/btc_transaction_recode_model.dart';
import 'package:n42appv2/src/wallet/models/transation_record_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase{
  late Database _database;
  Future<Database> get database async {
    _database = await getDatabaseInstance();
    return _database;
  }
  Future<Database> getDatabaseInstance() async {
    var directory = await getDatabasesPath();
    String path = join(directory, "astranet.db");
    return await openDatabase(
      path,
      version: 2, //Message 新增字段
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
            "userUuid test," //用户uuid
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
            "userUuid test," //用户uuid
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
            "desc text"
            ")");
        //浏览器浏览历史
        await db.execute("create table browserHistory ("
            "id integer primary key autoincrement,"
            "url text,"
            "time text"
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
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if(oldVersion==1){
          await db.execute('''
              ALTER TABLE BtcTransactionRecord
              ADD COLUMN gasPrice INTEGER
          ''');
        }
      },
    );
  }

  //查询btc交易记录
  Future<int> insertBtcTransactionRecord(BtcTransactionRecodeModel btcm) async {
    final db = await database;
    var raw = await db.insert("BtcTransactionRecord", btcm.toMapDb(),
        conflictAlgorithm: ConflictAlgorithm.rollback);
    return raw;
  }
  //查询交易记录，全部未完成的
  //type，查询类型，0：查询全部，1查询完成的，2查询未完成的
  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecord(
      String userUuid, String address, String coinKey, int selectType,
      {int pageSize = 10, int pageNum = 1}) async {
    final db = await database;
    String whereStr = "";
    if (selectType == 1) {
      whereStr = " and state=1";
    } else if (selectType == 2) {
      whereStr = " and state=0";
    }
    var response = await db.query("BtcTransactionRecord",
        where: 'coinMiniName="$coinKey" and address="$address" $whereStr',
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
    String whereStr = "";
    if (selectType == 1) {
      whereStr = " and state=1";
    } else if (selectType == 2) {
      whereStr = " and state=0";
    }
    var where = 'address="$address" and contract="${contract.toLowerCase()}" and isTest=$isTest and coinMiniName="$miniName"$whereStr';
    var response = await db.query("TransationRecord",
        where: where,
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
        where: "trId=${trm.trId}");
    return response;
  }
  Future<int> updateTransationRecordTxhash(TransationRecordModel trm) async {
    final db = await database;
    var response = await db.update("TransationRecord", trm.toMapDb(),
        where: 'txHash="${trm.txHash}"');
    return response;
  }
  //修改btc交易记录
  Future<int> updateBtcTransactionRecord(BtcTransactionRecodeModel btcm) async {
    final db = await database;
    var response = await db.update("BtcTransactionRecord", btcm.toMapDb(),
        where: "trId=${btcm.trId}");
    return response;
  }
  //查询交易记录，txhash交易hash
  Future<List<TransationRecordModel>> selectTransationRecordTxHash(
      String txHash,String address) async {
    final db = await database;
    var response =
    await db.query("TransationRecord", where: 'txHash="$txHash" and address="$address"');
    List<TransationRecordModel> list =
    response.map((c) => TransationRecordModel.fromMap(c)).toList();
    return list;
  }
  //查询交易记录，全部未完成的
  Future<List<TransationRecordModel>> selectTransationRecordUnDone(
      String userUuid) async {
    final db = await database;
    var response = await db.query("TransationRecord",
        where: 'state=0 and userUuid="$userUuid"',);
    List<TransationRecordModel> list =
    response.map((c) => TransationRecordModel.fromMap(c)).toList();
    return list;
  }
  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecordByUUID(
      String userUuid, int selectType) async {
    final db = await database;
    String whereStr = "";
    if (selectType == 1) {
      whereStr = " and state=1";
    } else if (selectType == 2) {
      whereStr = " and state=0";
    }
    var response = await db.query("BtcTransactionRecord",
        where: 'userUuid="$userUuid" $whereStr', orderBy: "trId desc");
    List<BtcTransactionRecodeModel> list =
    response.map((c) => BtcTransactionRecodeModel.fromMap(c)).toList();
    return list;
  }
  Future<List<BtcTransactionRecodeModel>> selectBtcTransationRecordTxHash(
      String txHash) async {
    final db = await database;
    var response = await db.query("BtcTransactionRecord",
        where: 'txHash="$txHash"',);
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
    var response = await db.update("browserCollection", map, where: "id=$id");
    return response;
  }

  //删除浏览器收藏表
  Future<void> deleteBrowserCollection(int id) async {
    final db = await database;
    await db.delete("browserCollection", where: "id=$id");
  }

  Future<int> deleteBrowserCollectionUrl(String url) async {
    final db = await database;
    return await db.delete("browserCollection", where: 'url="$url"');
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
    var response = await db.query("browserCollection", where: 'url="$url"');
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
        where: 'url like "%$urlStr%"',
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
        columns: ["search"],
        distinct: true,
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
      columns: ["search"],
      distinct: true,
      where: 'search="${map['search']}"',
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
      bshm.searchCount = bshm.searchCount! + 1;
      await db.update('browserSearchHistory', bshm.getMap(),
          where: 'id=${bshm.id}');
    }
    return null;
  }

  //删除搜索历史
  Future<int> deleteBrowserSearchHistory() async {
    final db = await database;
    var raw = await db.delete('browserSearchHistory');
    return raw;
  }
}