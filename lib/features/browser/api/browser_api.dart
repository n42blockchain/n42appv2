import 'package:n42_wallet/features/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/features/browser/models/browser_history_model.dart';
import 'package:n42_wallet/features/browser/models/browser_search_history_model.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';

class BrowserApi {
  late final AppDatabase db = AppDatabase();

  Future<int> insertBrowserHistory(String url, {String? title}) async {
    final bhm = BrowserHistoryModel(url, titleStr: title);
    return await db.insertBrowserHistory(bhm.getMapDb());
  }

  Future<List<BrowserHistoryModel>> selectBrowserHistoryLike(String url) async {
    return db.selectBrowserHistoryLike(url);
  }

  Future<List<BrowserHistoryModel>> selectBrowserHistory({
    int pageSize = 20,
    int pageNum = 1,
  }) async {
    return db.selectBrowserHistory(pageSize: pageSize, pageNum: pageNum);
  }

  Future<void> deleteBrowserHistoryById(int id) async {
    await db.deleteBrowserHistoryById(id);
  }

  Future<int> clearBrowserHistory() async {
    return db.clearBrowserHistory();
  }

  Future<void> insertBrowserCollection(
    String name,
    String url, {
    String desc = "",
    String? favicon,
  }) async {
    final bcm = BrowserCollectionModel(url, name, desc, faviconStr: favicon);
    await db.insertBrowserCollection(bcm.getMapDb());
  }

  Future<void> updateBrowsercollection(BrowserCollectionModel bcm) async {
    await db.updateBrowserCollection(bcm.getMapDb(), bcm.id!);
  }

  Future<List<BrowserCollectionModel>> selectBrowserCollection({
    int pageSize = 10,
    int pageNum = 1,
  }) async {
    return db.selectBrowserCollection(pageSize: pageSize, pageNum: pageNum);
  }

  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(
    String url,
  ) async {
    return db.selectBrowserCollectionUrl(url);
  }

  Future<void> deleteBrowserCollection(int id) async {
    await db.deleteBrowserCollection(id);
  }

  Future<int> deleteBrowserCollectionUrl(String url) async {
    return db.deleteBrowserCollectionUrl(url);
  }

  Future<List<BrowserSearchHistoryModel>> selectBrowserSearchHistory({
    int pageSize = 10,
    int pageNum = 1,
  }) async {
    return db.selectBrowserSearchHistory(pageSize: pageSize, pageNum: pageNum);
  }

  Future<int?> insertBrowserSearchHistory(String search) async {
    final bshm = BrowserSearchHistoryModel(search);
    return db.insertBrowserSearchHistory(bshm.getMapDb());
  }

  Future<int> deleteBrowserSearchHistory() async {
    return db.deleteBrowserSearchHistory();
  }
}
