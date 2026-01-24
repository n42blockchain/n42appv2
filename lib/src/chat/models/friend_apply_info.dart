class FriendApplyInfo {
  int? direction;
  String? uuid;
  String? email;
  String? image;
  String? name;
  String? reason;
  int? status;
  int? createTime;

  FriendApplyInfo(this.direction, this.uuid, this.email, this.image, this.name,
      this.reason, this.status, this.createTime);

  factory FriendApplyInfo.fromJson(Map<String, dynamic> json) =>
      FriendApplyInfo(
        json['direction'] as int?,
        json['uuid'] as String?,
        json['email'] as String?,
        json['image'] as String?,
        json['name'] as String?,
        json['reason'] as String?,
        json['status'] as int?,
        json['create_time'] as int?,
      );

  Map<String, dynamic> toJson() => {
    "direction":direction,
    "uuid":uuid,
    "email":email,
    "image":image,
    "name":name,
    "reason":reason,
    "status":status,
    "create_time":createTime,
  };


}
