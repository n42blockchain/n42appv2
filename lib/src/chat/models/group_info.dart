class GroupInfo{
  String g_uuid;
  String name;
  String avatar_url;
  String introduction;
  int user_num;
  String extra;
  int avisible_to_nm;
  int last_seq_before_visible;
  int created;
  int updated;
  // member_type 0=退群 1=群主 2=普通成员
  int? member_type;

  GroupInfo(
      this.g_uuid,
      this.name,
      this.avatar_url,
      this.introduction,
      this.user_num,
      this.extra,
      this.avisible_to_nm,
      this.last_seq_before_visible,
      this.created,
      this.updated,
      this.member_type);
  factory GroupInfo.fromJson(Map<String, dynamic> json)=>
      GroupInfo(
        json['g_uuid'] as String,
        json['name'] as String,
        json['avatar_url'] as String,
        json['introduction'] as String,
        json['user_num'] as int,
        json['extra'] as String,
        json['avisible_to_nm'] as int,
        json['last_seq_before_visible'] as int,
        json['created'] as int,
        json['updated'] as int,
        json['member_type'] as int,
      );
  Map<String, dynamic> toJson() =>{
    "g_uuid":g_uuid,
    "name":name,
    "avatar_url":avatar_url,
    "introduction":introduction,
    "user_num":user_num,
    "extra":extra,
    "avisible_to_nm":avisible_to_nm,
    "last_seq_before_visible":last_seq_before_visible,
    "created":created,
    "updated":updated,
    "member_type":member_type,
  };
}