class RedPocketClaimModel{
  int? createTime;
  int? seq;//红包序号
  int? status;//0：未处理 1：已上链 2:执行失败 3上链确认
  String? txHash;
  int? updateTime;
  double? value;//领取金额
  String? avatarUrl;//头像地址
  String? uuid;
  String? nickname;

  RedPocketClaimModel();
  RedPocketClaimModel.fromJson(Map<String,dynamic> map){
    createTime=map['create_time'] as int?;
    seq=map['seq'] as int?;
    status=map['status'] as int?;
    txHash=map['tx_hash'] as String?;
    updateTime=map['update_time'] as int?;
    value=(map['value'] as num?)?.toDouble();
    avatarUrl=map['avatar_url'] as String?;
    uuid=map['uuid'] as String?;
    nickname=map['nickname'] as String?;
  }
  Map<String,dynamic> toJson(){
    return {
      "create_time":createTime,
      "seq":seq,
      "status":status,
      "tx_hash":txHash,
      "update_time":updateTime,
      "value":value,
      "avatar_url":avatarUrl,
      "uuid":uuid,
      "nickname":nickname,
    };
  }
}
