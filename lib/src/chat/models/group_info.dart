class GroupInfo{
  String gUuid;
  String name;
  String avatarUrl;
  String introduction;
  int userNum;
  String extra;
  int avisibleToNm;
  int lastSeqBeforeVisible;
  int created;
  int updated;
  // member_type 0=退群 1=群主 2=普通成员
  int? memberType;

  GroupInfo(
      this.gUuid,
      this.name,
      this.avatarUrl,
      this.introduction,
      this.userNum,
      this.extra,
      this.avisibleToNm,
      this.lastSeqBeforeVisible,
      this.created,
      this.updated,
      this.memberType);
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
    "g_uuid":gUuid,
    "name":name,
    "avatar_url":avatarUrl,
    "introduction":introduction,
    "user_num":userNum,
    "extra":extra,
    "avisible_to_nm":avisibleToNm,
    "last_seq_before_visible":lastSeqBeforeVisible,
    "created":created,
    "updated":updated,
    "member_type":memberType,
  };
}
