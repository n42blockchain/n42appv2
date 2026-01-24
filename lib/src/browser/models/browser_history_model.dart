class BrowserHistoryModel{
  int? id;
  String? url;
  String? time;

  BrowserHistoryModel(String urlStr){
    url=urlStr;
    time=(DateTime.now().millisecondsSinceEpoch ~/1000).toString();
  }
  BrowserHistoryModel.fromJson(Map<String,dynamic> map){
    id=map["id"];
    url=map["url"];
    time=map["time"];
  }
  getMapDb(){
    return {
      "url":url,
      "time":time,
    };
  }
  getMap(){
    return {
      "id":id,
      "url":url,
      "time":time,
    };
  }
}