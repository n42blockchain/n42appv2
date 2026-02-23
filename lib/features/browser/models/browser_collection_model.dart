//浏览器收藏表
class BrowserCollectionModel{
  int? id;
  String? name;
  String? url;
  String? desc;
  String? favicon;
  int? createdAt;

  BrowserCollectionModel(String urlStr,String nameStr,String descStr,{String? faviconStr, int? createdAtMs}){
    url=urlStr;
    name=nameStr;
    desc=descStr;
    favicon=faviconStr;
    createdAt=createdAtMs ?? DateTime.now().millisecondsSinceEpoch;
  }
  BrowserCollectionModel.fromJson(Map<String,dynamic> map){
    id=map["id"];
    url=map["url"];
    name=map["name"];
    desc=map["desc"];
    favicon=map["favicon"];
    createdAt=map["createdAt"];
  }
  Map<String, dynamic> getMapDb(){
    return {
      "url":url,
      "name":name,
      "desc":desc,
      "favicon":favicon,
      "createdAt":createdAt,
    };
  }
  Map<String, dynamic> getMap(){
    return {
      "id":id,
      "url":url,
      "name":name,
      "desc":desc,
      "favicon":favicon,
      "createdAt":createdAt,
    };
  }

}
