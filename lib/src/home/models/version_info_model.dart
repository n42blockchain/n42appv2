class VersionInfoModel{
  String? versionName;
  int? versionCode;
  String? updateTitle;
  String? updateContent;
  //是否强制更新
  bool? isForce;

  VersionInfoModel({this.versionName, this.versionCode, this.updateTitle,
    this.updateContent, this.isForce});
  VersionInfoModel.fromJson(Map<String,dynamic> map){
    versionName=map['versionName'] as String?;
    versionCode=map['versionCode'] as int?;
    updateTitle=map['updateTitle'] as String?;
    updateContent=map['updateContent'] as String?;
    isForce=map['isForce'] as bool?;
  }
  Map<String, dynamic> toJson(){
    return {
      "versionName":versionName,
      "versionCode":versionCode,
      "updateTitle":updateTitle,
      "updateContent":updateContent,
      "isForce":isForce,
    };
  }
}