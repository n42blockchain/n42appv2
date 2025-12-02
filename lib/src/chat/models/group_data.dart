class GroupData{
  String groupId;
  String groupPwd;

  GroupData(this.groupId, this.groupPwd);

  // 将数据转换为Map以便保存到Shared Preferences
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupPwd': groupPwd,
    };
  }

  // 从Map中恢复数据
  factory GroupData.fromMap(Map<String, dynamic> map) {
    return GroupData(
      map['groupId'] as String,
      map['groupPwd'] as String,
    );
  }
}