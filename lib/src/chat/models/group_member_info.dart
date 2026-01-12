class GroupMemberInfo {
  String? memberId;
  String? displayName;
  String? avatarUrl;
  int? type;
  int? updateDt;
  String? email;

  GroupMemberInfo.initNull();

  //本地选择联系人
  bool isSelected = false;

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'type': type,
      'updateDt': updateDt,
      'email': email,
    };
  }

  GroupMemberInfo.fromJson(Map<String, dynamic> map)
      : memberId = map['member_id'] ?? map['memberId'],
        displayName = map['display_name'] ?? map['displayName'],
        avatarUrl = map['avatar_url'] ?? map['avatarUrl'],
        type = map['type'],
        updateDt = map['update_dt'] ?? map['updateDt'],
        email = map['email'];

}