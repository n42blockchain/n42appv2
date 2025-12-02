import 'package:n42appv2/src/chat/models/red_pocket_claim_model.dart';

class RedPocketDetailModel{
  int? claimed;//用户是否领取
  int? count;//红包个数
  int? create_time;
  String? description;//红包金额
  int? remain_count;//红包剩余数量
  double? remain_value;//剩余金额
  int? status;//状态，0：未处理 1：已上链 2:执行失败 3上链确认 4:红包领取完毕
  String? tx_hash;//交易哈希
  int? type;//红包类型 1.普通红包，2随机
  int? update_time;
  double? value;//红包金额
  List<RedPocketClaimModel>? red_claim;
  RedPocketDetailModel.fromJson(Map<String,dynamic> map){
    claimed=map['claimed'] as int?;
    count=map['count'] as int?;
    create_time=map['create_time'] as int?;
    description=map['description'] as String?;
    remain_count=map['remain_count'] as int?;
    remain_value=(map['remain_value'] as num?)?.toDouble();
    status=map['status'] as int?;
    tx_hash=map['tx_hash'] as String?;
    type=map['type'] as int?;
    update_time=map['update_time'] as int?;
    value=(map['value'] as num?)?.toDouble();
    List<dynamic> rc=map['red_claim']??[];
    red_claim=rc.map((e) => RedPocketClaimModel.fromJson(e)).toList();
  }
  toJson(){
    return {
      "claimed":claimed,
      "count":count,
      "create_time":create_time,
      "description":description,
      "remain_count":remain_count,
      "remain_value":remain_value,
      "status":status,
      "tx_hash":tx_hash,
      "type":type,
      "update_time":update_time,
      "value":value,
      "red_claim":red_claim,
    };
  }
}