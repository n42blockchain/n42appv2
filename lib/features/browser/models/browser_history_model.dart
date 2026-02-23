class BrowserHistoryModel{
  int? id;
  String? url;
  String? time;
  String? title;

  BrowserHistoryModel(String urlStr, {String? titleStr}){
    url=urlStr;
    title=titleStr;
    time=(DateTime.now().millisecondsSinceEpoch ~/1000).toString();
  }
  BrowserHistoryModel.fromJson(Map<String,dynamic> map){
    id=map["id"];
    url=map["url"];
    time=map["time"];
    title=map["title"];
  }
  Map<String, dynamic> getMapDb(){
    return {
      "url":url,
      "time":time,
      "title":title,
    };
  }
  Map<String, dynamic> getMap(){
    return {
      "id":id,
      "url":url,
      "time":time,
      "title":title,
    };
  }
}
