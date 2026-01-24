import 'package:n42appv2/src/browser/models/browser_collection_model.dart';
import 'package:n42appv2/src/browser/models/browser_history_model.dart';
import 'package:n42appv2/src/browser/models/browser_search_history_model.dart';
import 'package:n42appv2/src/sqlite/app_database.dart';

class BrowserApi{
  AppDatabase? _db;
  AppDatabase get db{
    _db ??= AppDatabase();
    return _db!;
  }
  //将浏览历史，保存到浏览历史表
  insertBrowserHistory(String url){
    BrowserHistoryModel bhm=BrowserHistoryModel(url);
    db.insertBrowserHistory(bhm.getMap_db());
  }
  //模糊搜索 浏览历史表
  selectBrowserHistory_like(String url)async{
    return await db.selectBrowserHistory_like(url);
  }
  //添加浏览收藏表
  insertBrowserCollection(String name,String url,{String desc=""})async{
    BrowserCollectionModel bcm=BrowserCollectionModel(url, name, desc);
    db.insertBrowserCollection(bcm.getMap_db());
  }
  //修改浏览收藏表
  updateBrowsercollection(BrowserCollectionModel bcm)async{
    db.updateBrowserCollection(bcm.getMap_db(), bcm.id!);
  }
  //获取 浏览器收藏列表
  selectBrowserCollection({int pageSize=10,int pageNum=1})async{
    return await db.selectBrowserCollection(pageSize: pageSize,pageNum: pageNum);
  }
  //获取 浏览器收藏列表，条件 url
  selectBrowserCollection_url(String url)async{
    return await db.selectBrowserCollection_url(url);
  }
  //删除 浏览器收藏
  deleteBrowserCollection(int id)async{
    db.deleteBrowserCollection(id);
  }
  //删除 浏览器收藏 条件 url
  deleteBrowserCollection_url(String url)async{
    return await db.deleteBrowserCollection_url(url);
  }
  //获取 浏览器 搜索列表
  selectBrowserSearchHistory({int pageSize=10,int pageNum=1})async{
    return await db.selectBrowserSearchHistory(pageSize: pageSize,pageNum: pageNum);
  }
  //添加浏览器搜索列表
  insertBrowserSearchHistory(String search)async{
    BrowserSearchHistoryModel bshm=BrowserSearchHistoryModel(search);
    return await db.insertBrowserSearchHistory(bshm.getMap_db());
  }
  //删除浏览器搜索内容
  deleteBrowserSearchHistory()async{
    return await db.deleteBrowserSearchHistory();
  }

}