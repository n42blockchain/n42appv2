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
      : memberId = map['memberId'],
        displayName = map['displayName'],
        avatarUrl = map['avatarUrl'],
        type = map['type'],
        updateDt = map['updateDt'],
        email = map['email'];

}