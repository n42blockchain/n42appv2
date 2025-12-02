class FriendInfo{
  String? uuid;
  String? email;
  String? name;
  String? remarks;
  String? portrait;
  int? updateDt;
  String? image;
  String? public_key;

  //本地选择联系人
  bool isSelected = false;
  //是否可以选择
  bool? isCanSelected;

  FriendInfo(this.uuid, this.email, this.name,this.remarks, this.portrait, this.updateDt,this.image,this.public_key);
  factory FriendInfo.fromJson(Map<String, dynamic> json) =>
      FriendInfo(
        json['uuid'] as String?,
        json['email'] as String?,
        json['name'] as String?,
        json['remarks'] as String?,
        json['portrait'] as String?,
        json['updateDt'] as int?,
        json['image'] as String?,
        json['public_key'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'email': email,
    'name': name,
    'remarks': remarks,
    'portrait': portrait,
    'updateDt': updateDt,
    'image':image,
    'public_key': public_key,
    'isSelected': isSelected,
    'isCanSelected': isCanSelected,
  };
}