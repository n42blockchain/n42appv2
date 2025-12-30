import 'package:n42appv2/src/component/enums/load.dart';

class SwapAstModel{
  int? id;
  String? name;// 全名
  String? desc;
  String? uri;// 图片
  int? amt_num;
  String? pay_chain;// 主链
  String? pay_coin;// 代币缩写
  String? pay_coin_contract;
  int? pay_coin_decimal;
  String? pay_uuid;
  String? pay_addr;
  int? type;
  int? del;
  int? created;
  int? updated;

  double balance=0;
  double price=0;
  Load load=Load.finish;

  SwapAstModel(
      this.id,
      this.name,
      this.desc,
      this.uri,
      this.amt_num,
      this.pay_chain,
      this.pay_coin,
      this.pay_coin_contract,
      this.pay_coin_decimal,
      this.pay_uuid,
      this.pay_addr,
      this.type,
      this.del,
      this.created,
      this.updated);
  factory SwapAstModel.fromJson(Map<String,dynamic> json)=> SwapAstModel(
    json['id'] as int?,
    json['name'] as String?,
    json['desc'] as String?,
    json['uri'] as String?,
    json['amt_num'] as int?,
    json['pay_chain'] as String?,
    json['pay_coin'] as String?,
    json['pay_coin_contract'] as String?,
    json['pay_coin_decimal'] as int?,
    json['pay_uuid'] as String?,
    json['pay_addr'] as String?,
    json['type'] as int?,
    json['del'] as int?,
    json['created'] as int?,
    json['updated'] as int?,
  );

  Map<String,dynamic> toJson()=> <String, dynamic>{
    'id': id,
    'name': name,
    'desc': desc,
    'uri': uri,
    'amt_num': amt_num,
    'pay_chain': pay_chain,
    'pay_coin': pay_coin,
    'pay_coin_contract': pay_coin_contract,
    'pay_coin_decimal': pay_coin_decimal,
    'pay_uuid': pay_uuid,
    'pay_addr': pay_addr,
    'type': type,
    'del': del,
    'created': created,
    'updated': updated,
  };
}
