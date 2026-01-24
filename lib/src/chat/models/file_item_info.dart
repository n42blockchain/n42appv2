class FileItemInfo{
  int? id;
  String? sUuid;
  String? rUuid;
  String? rEmail;
  String? sEmail;
  String? sAesSecret;
  String? rAesSecret;
  String? fileType;
  String? fileUri;
  String? fileName;
  String? fileDesc;
  int? sDel;
  int? rDel;
  int? created;
  int? updated;

  String? sName;
  String? sHeadUrl;
  String? rName;
  String? rHeadUrl;

  FileItemInfo(
      this.id,
      this.sUuid,
      this.rUuid,
      this.sAesSecret,
      this.rAesSecret,
      this.fileType,
      this.fileUri,
      this.fileName,
      this.fileDesc,
      this.sDel,
      this.rDel,
      this.rEmail,
      this.sEmail,
      this.created,
      this.updated,
      this.sHeadUrl,
      this.sName,
      this.rHeadUrl,
      this.rName,
      this.deCodeContent,
      );

  FileItemInfo.initNull();
  //解密后内容 text/nav path
  String? deCodeContent;
  //不同的类使用不同的mixin即可
  factory FileItemInfo.fromJson(Map<String, dynamic> map) =>FileItemInfo(
    map["id"] as int?,
    map["s_uuid"] as String?,
    map["r_uuid"] as String?,
    map["s_aes_secret"] as String?,
    map["r_aes_secret"] as String?,
    map["file_type"] as String?,
    map["file_uri"] as String?,
    map["file_name"] as String?,
    map["file_desc"] as String?,
    map["s_del"] as int?,
    map["r_del"] as int?,
    map["r_email"] as String?,
    map["s_email"] as String?,
    map["created"] as int?,
    map["updated"] as int?,
    map["s_head_url"] as String?,
    map["s_name"] as String?,
    map["r_head_url"] as String?,
    map["r_name"] as String?,
    map["deCodeContent"] as String?,
  );
  Map<String, dynamic> toJson() =>{
    "id":id,
    "s_uuid":sUuid,
    "r_uuid":rUuid,
    "s_aes_secret":sAesSecret,
    "r_aes_secret":rAesSecret,
    "file_type":fileType,
    "file_uri":fileUri,
    "file_name":fileName,
    "file_desc":fileDesc,
    "s_del":sDel,
    "r_del":rDel,
    "r_email":rEmail,
    "s_email":sEmail,
    "created":created,
    "updated":updated,
    "s_head_url":sHeadUrl,
    "s_name":sName,
    "r_head_url":rHeadUrl,
    "r_name":rName,
    "deCodeContent":deCodeContent,
  };
}
