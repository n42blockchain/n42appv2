import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 应用本地 SQLite 数据库：连接管理 + schema（DDL/迁移）+ 通用查询辅助。
///
/// 本类**不认识任何 feature 的模型**——类型化 DAO 以 extension 形式放在
/// 各 feature 内（`features/browser/data/browser_dao.dart`、
/// `features/wallet/data/transaction_record_dao.dart`），依赖方向为
/// feature → sqlite，不反向。
///
/// schema 版本号跨 feature 全局有序，因此 DDL/迁移集中在此维护。
class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    _database ??= await getDatabaseInstance();
    return _database!;
  }

  // ─── 通用辅助方法 ──────────────────────────────────────────────────────────

  /// 通用查询：执行 query 后用 [fromMap] 映射每一行
  Future<List<T>> queryList<T>(
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
    final rows = await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return rows.map(fromMap).toList();
  }

  /// 给 where 子句追加 selectType 过滤条件
  /// selectType: 0=全部, 1=已完成(state=1), 2=未完成(state=0)
  static String appendStateFilter(String whereClause, int selectType) =>
      switch (selectType) {
        1 => '$whereClause and state=1',
        2 => '$whereClause and state=0',
        _ => whereClause,
      };
  Future<Database> getDatabaseInstance() async {
    final directory = await getDatabasesPath();
    // 文件名保留早期品牌字面量，向后兼容已发布版本上的用户数据；
    // 重命名 = 老用户钱包/交易/浏览历史等全部丢失，禁止修改。
    final path = join(directory, "astranet.db");
    return await openDatabase(
      path,
      version: 7, //v7: portfolio_trades for cost-basis P&L tracking
      onCreate: (Database db, int version) async {
        //交易记录
        await db.execute(
          "create table TransationRecord("
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
          "message TEXT" //消息
          ")",
        );
        //交易记录 btc
        await db.execute(
          "create table BtcTransactionRecord("
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
          "gasPrice int" //交易费
          ")",
        );

        /// address book
        await db.execute(
          "create table AddressBook("
          "id integer primary key autoincrement,"
          "coinIcon text," //coin Icon
          "coinName text," //coin name
          "address text," //address
          "name text," //name
          "desc text" //desc
          ")",
        );
        //浏览器收藏表
        await db.execute(
          "create table browserCollection ("
          "id integer primary key autoincrement,"
          "name text,"
          "url text,"
          "desc text,"
          "favicon text,"
          "createdAt integer"
          ")",
        );
        //浏览器浏览历史
        await db.execute(
          "create table browserHistory ("
          "id integer primary key autoincrement,"
          "url text,"
          "time text,"
          "title text"
          ")",
        );
        //浏览器搜索历史表
        await db.execute(
          "create table browserSearchHistory ("
          "id integer primary key autoincrement,"
          "search text," //搜索内容
          "searchCount int" //搜索次数
          ")",
        );
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
}
