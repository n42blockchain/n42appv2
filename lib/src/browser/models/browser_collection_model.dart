//浏览器收藏表
class BrowserCollectionModel{
  int? id;
  String? name;
  String? url;
  String? desc;

  BrowserCollectionModel(String urlStr,String nameStr,String descStr){
    url=urlStr;
    name=nameStr;
    desc=descStr;
  }
  BrowserCollectionModel.fromJson(Map<String,dynamic> map){
    id=map["id"];
    url=map["url"];
    name=map["name"];
    desc=map["desc"];
  }
  getMapDb(){
    return {
      "url":url,
      "name":name,
      "desc":desc,
    };
  }
  getMap(){
    return {
      "id":id,
      "url":url,
      "name":name,
      "desc":desc,
    };
  }

}