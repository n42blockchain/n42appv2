import 'package:n42_wallet/src/browser/models/browser_collection_model.dart';
import 'package:n42_wallet/src/browser/models/browser_history_model.dart';
import 'package:n42_wallet/src/browser/models/browser_search_history_model.dart';
import 'package:n42_wallet/src/sqlite/app_database.dart';

class BrowserApi{
  AppDatabase? _db;
  AppDatabase get db{
    _db ??= AppDatabase();
    return _db!;
  }
  //将浏览历史，保存到浏览历史表
  void insertBrowserHistory(String url, {String? title}){
    BrowserHistoryModel bhm=BrowserHistoryModel(url, titleStr: title);
    db.insertBrowserHistory(bhm.getMapDb());
  }
  //模糊搜索 浏览历史表
  Future<List<BrowserHistoryModel>> selectBrowserHistoryLike(String url)async{
    return await db.selectBrowserHistoryLike(url);
  }
  //分页查询浏览历史
  Future<List<BrowserHistoryModel>> selectBrowserHistory({int pageSize=20, int pageNum=1})async{
    return await db.selectBrowserHistory(pageSize: pageSize, pageNum: pageNum);
  }
  //删除单条浏览历史
  Future<void> deleteBrowserHistoryById(int id)async{
    await db.deleteBrowserHistoryById(id);
  }
  //清空浏览历史
  Future<int> clearBrowserHistory()async{
    return await db.clearBrowserHistory();
  }
  //添加浏览收藏表
  Future<void> insertBrowserCollection(String name,String url,{String desc="",String? favicon})async{
    BrowserCollectionModel bcm=BrowserCollectionModel(url, name, desc, faviconStr: favicon);
    db.insertBrowserCollection(bcm.getMapDb());
  }
  //修改浏览收藏表
  Future<void> updateBrowsercollection(BrowserCollectionModel bcm)async{
    db.updateBrowserCollection(bcm.getMapDb(), bcm.id!);
  }
  //获取 浏览器收藏列表
  Future<List<BrowserCollectionModel>> selectBrowserCollection({int pageSize=10,int pageNum=1})async{
    return await db.selectBrowserCollection(pageSize: pageSize,pageNum: pageNum);
  }
  //获取 浏览器收藏列表，条件 url
  Future<List<BrowserCollectionModel>> selectBrowserCollectionUrl(String url)async{
    return await db.selectBrowserCollectionUrl(url);
  }
  //删除 浏览器收藏
  Future<void> deleteBrowserCollection(int id)async{
    db.deleteBrowserCollection(id);
  }
  //删除 浏览器收藏 条件 url
  Future<int> deleteBrowserCollectionUrl(String url)async{
    return await db.deleteBrowserCollectionUrl(url);
  }
  //获取 浏览器 搜索列表
  Future<List<BrowserSearchHistoryModel>> selectBrowserSearchHistory({int pageSize=10,int pageNum=1})async{
    return await db.selectBrowserSearchHistory(pageSize: pageSize,pageNum: pageNum);
  }
  //添加浏览器搜索列表
  Future<int?> insertBrowserSearchHistory(String search)async{
    BrowserSearchHistoryModel bshm=BrowserSearchHistoryModel(search);
    return await db.insertBrowserSearchHistory(bshm.getMapDb());
  }
  //删除浏览器搜索内容
  Future<int> deleteBrowserSearchHistory()async{
    return await db.deleteBrowserSearchHistory();
  }

}
