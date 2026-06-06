class BrowserSearchHistoryModel {
  int? id;
  String? search;
  int? searchCount;

  BrowserSearchHistoryModel(String searchStr)
    : search = searchStr,
      searchCount = 1;

  BrowserSearchHistoryModel.fromJson(Map<String, dynamic> map)
    : id = map["id"],
      search = map["search"],
      searchCount = map["searchCount"];

  Map<String, dynamic> getMapDb() => {
    "search": search,
    "searchCount": searchCount,
  };

  Map<String, dynamic> getMap() => {
    "id": id,
    "search": search,
    "searchCount": searchCount,
  };
}
