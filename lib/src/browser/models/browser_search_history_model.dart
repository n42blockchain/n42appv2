class BrowserSearchHistoryModel{
  int? id;
  String? search;
  int? searchCount;

  BrowserSearchHistoryModel(String searchStr){
    search=searchStr;
    searchCount=1;
  }
  BrowserSearchHistoryModel.fromJson(Map<String,dynamic> map){
    id=map["id"];
    search=map["search"];
    searchCount=map["searchCount"];
  }
  getMap_db(){
    return {
      "search":search,
      "searchCount":searchCount,
    };
  }
  getMap(){
    return {
      "id":id,
      "search":search,
      "searchCount":searchCount,
    };
  }
}