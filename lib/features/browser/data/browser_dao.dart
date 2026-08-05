import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/models/browser_history_model.dart';
import 'package:n42_wallet/features/browser/models/browser_search_history_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:sqflite/sqflite.dart';

/// 浏览器收藏/历史/搜索历史的类型化 DAO。
///
/// 以 extension 挂在 [AppDatabase] 上：表 schema 归 sqlite 模块集中管理，
/// 模型映射归 browser feature 自有，sqlite 模块不反向依赖 feature 模型。
extension BrowserDao on AppDatabase {
  //添加浏览器收藏表
  Future<int> insertBrowserCollection(Map<String, dynamic> map) async {
    final db = await database;
    return db.insert(
      "browserCollection",
      map,
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  //修改浏览器收藏表
  Future<int> updateBrowserCollection(Map<String, dynamic> map, int id) async {
    final db = await database;
    return db.update("browserCollection", map, where: "id=?", whereArgs: [id]);
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

  Future<List<BrowserCollectionModel>> selectBrowserCollection({
    int pageSize = 10,
    int pageNum = 1,
  }) async {
    return queryList(
      "browserCollection",
      BrowserCollectionModel.fromJson,
      orderBy: "id desc",
      limit: pageSize,
      offset: (pageNum - 1) * pageSize,
    );
  }

  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(
    String url,
  ) async {
    return queryList(
      "browserCollection",
      BrowserCollectionModel.fromJson,
      where: 'url=?',
      whereArgs: [url],
    );
  }

  //添加浏览器浏览历史
  Future<int> insertBrowserHistory(Map<String, dynamic> map) async {
    final db = await database;
    return db.insert(
      "browserHistory",
      map,
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
  }

  //查询 浏览器历史
  Future<List<BrowserHistoryModel>> selectBrowserHistoryLike(
    String urlStr, {
    int pageSize = 10,
    int pageNum = 1,
  }) async {
    return queryList(
      "browserHistory",
      BrowserHistoryModel.fromJson,
      columns: ["url"],
      distinct: true,
      where: 'url like ?',
      whereArgs: ['%$urlStr%'],
      orderBy: "id desc",
      limit: pageSize,
      offset: (pageNum - 1) * pageSize,
    );
  }

  //查询搜索历史
  Future<List<BrowserSearchHistoryModel>> selectBrowserSearchHistory({
    int pageSize = 10,
    int pageNum = 1,
  }) async {
    return queryList(
      "browserSearchHistory",
      BrowserSearchHistoryModel.fromJson,
      orderBy: "searchCount desc",
      limit: pageSize,
      offset: (pageNum - 1) * pageSize,
    );
  }

  //添加搜索历史
  Future<int?> insertBrowserSearchHistory(Map<String, dynamic> map) async {
    final db = await database;
    final existing = await queryList(
      "browserSearchHistory",
      BrowserSearchHistoryModel.fromJson,
      where: 'search=?',
      whereArgs: [map['search']],
      orderBy: "searchCount desc",
    );
    if (existing.isEmpty) {
      return db.insert(
        "browserSearchHistory",
        map,
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
    }
    final bshm = existing[0];
    bshm.searchCount = (bshm.searchCount ?? 0) + 1;
    await db.update(
      'browserSearchHistory',
      bshm.getMap(),
      where: 'id=?',
      whereArgs: [bshm.id],
    );
    return null;
  }

  //删除搜索历史
  Future<int> deleteBrowserSearchHistory() async {
    final db = await database;
    return db.delete('browserSearchHistory');
  }

  //分页查询浏览历史（按时间降序）
  Future<List<BrowserHistoryModel>> selectBrowserHistory({
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    return queryList(
      "browserHistory",
      BrowserHistoryModel.fromJson,
      orderBy: "time desc",
      limit: pageSize,
      offset: (pageNum - 1) * pageSize,
    );
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
