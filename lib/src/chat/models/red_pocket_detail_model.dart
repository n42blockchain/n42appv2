import 'package:n42appv2/src/chat/models/red_pocket_claim_model.dart';

class RedPocketDetailModel{
  int? claimed;//用户是否领取
  int? count;//红包个数
  int? createTime;
  String? description;//红包金额
  int? remainCount;//红包剩余数量
  double? remainValue;//剩余金额
  int? status;//状态，0：未处理 1：已上链 2:执行失败 3上链确认 4:红包领取完毕
  String? txHash;//交易哈希
  int? type;//红包类型 1.普通红包，2随机
  int? updateTime;
  double? value;//红包金额
  List<RedPocketClaimModel>? redClaim;
  RedPocketDetailModel.fromJson(Map<String,dynamic> map){
    claimed=map['claimed'] as int?;
    count=map['count'] as int?;
    createTime=map['create_time'] as int?;
    description=map['description'] as String?;
    remainCount=map['remain_count'] as int?;
    remainValue=(map['remain_value'] as num?)?.toDouble();
    status=map['status'] as int?;
    txHash=map['tx_hash'] as String?;
    type=map['type'] as int?;
    updateTime=map['update_time'] as int?;
    value=(map['value'] as num?)?.toDouble();
    List<dynamic> rc=map['red_claim']??[];
    redClaim=rc.map((e) => RedPocketClaimModel.fromJson(e)).toList();
  }
  toJson(){
    return {
      "claimed":claimed,
      "count":count,
      "create_time":createTime,
      "description":description,
      "remain_count":remainCount,
      "remain_value":remainValue,
      "status":status,
      "tx_hash":txHash,
      "type":type,
      "update_time":updateTime,
      "value":value,
      "red_claim":redClaim,
    };
  }
}
