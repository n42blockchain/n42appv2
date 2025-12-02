class RedPocketClaimModel{
  int? create_time;
  int? seq;//红包序号
  int? status;//0：未处理 1：已上链 2:执行失败 3上链确认
  String? tx_hash;
  int? update_time;
  double? value;//领取金额
  String? avatar_url;//头像地址
  String? uuid;
  String? nickname;

  RedPocketClaimModel();
  RedPocketClaimModel.fromJson(Map<String,dynamic> map){
    create_time=map['create_time'] as int?;
    seq=map['seq'] as int?;
    status=map['status'] as int?;
    tx_hash=map['tx_hash'] as String?;
    update_time=map['update_time'] as int?;
    value=(map['value'] as num?)?.toDouble();
    avatar_url=map['avatar_url'] as String?;
    uuid=map['uuid'] as String?;
    nickname=map['nickname'] as String?;
  }
  Map<String,dynamic> toJson(){
    return {
      "create_time":create_time,
      "seq":seq,
      "status":status,
      "tx_hash":tx_hash,
      "update_time":update_time,
      "value":value,
      "avatar_url":avatar_url,
      "uuid":uuid,
      "nickname":nickname,
    };
  }
}