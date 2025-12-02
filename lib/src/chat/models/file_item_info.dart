class FileItemInfo{
  int? id;
  String? s_uuid;
  String? r_uuid;
  String? r_email;
  String? s_email;
  String? s_aes_secret;
  String? r_aes_secret;
  String? file_type;
  String? file_uri;
  String? file_name;
  String? file_desc;
  int? s_del;
  int? r_del;
  int? created;
  int? updated;

  String? s_name;
  String? s_head_url;
  String? r_name;
  String? r_head_url;

  FileItemInfo(
      this.id,
      this.s_uuid,
      this.r_uuid,
      this.s_aes_secret,
      this.r_aes_secret,
      this.file_type,
      this.file_uri,
      this.file_name,
      this.file_desc,
      this.s_del,
      this.r_del,
      this.r_email,
      this.s_email,
      this.created,
      this.updated,
      this.s_head_url,
      this.s_name,
      this.r_head_url,
      this.r_name,
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
    "s_uuid":s_uuid,
    "r_uuid":r_uuid,
    "s_aes_secret":s_aes_secret,
    "r_aes_secret":r_aes_secret,
    "file_type":file_type,
    "file_uri":file_uri,
    "file_name":file_name,
    "file_desc":file_desc,
    "s_del":s_del,
    "r_del":r_del,
    "r_email":r_email,
    "s_email":s_email,
    "created":created,
    "updated":updated,
    "s_head_url":s_head_url,
    "s_name":s_name,
    "r_head_url":r_head_url,
    "r_name":r_name,
    "deCodeContent":deCodeContent,
  };
}