class ChainBrowserUrlModel{
  String? api;
  String? testApi;
  String? documentUrl;
  ChainBrowserUrlModel({this.api,this.testApi,this.documentUrl});
  ChainBrowserUrlModel.fromJson(Map<String,dynamic> map){
    api=map['api'] as String?;
    testApi=map['testApi'] as String?;
    documentUrl=map['documentUrl'] as String?;
  }
  toJson(){
    return {
      "api":api,
      "testApi":testApi,
      "documentUrl":documentUrl,
    };
  }
}
