import 'package:n42_wallet/features/component/enums/load.dart';

class SwapAstModel {
  int? id;
  String? name; // 全名
  String? desc;
  String? uri; // 图片
  int? amtNum;
  String? payChain; // 主链
  String? payCoin; // 代币缩写
  String? payCoinContract;
  int? payCoinDecimal;
  String? payUuid;
  String? payAddr;
  int? type;
  int? del;
  int? created;
  int? updated;

  double balance = 0;
  double price = 0;
  Load load = Load.finish;

  SwapAstModel(
    this.id,
    this.name,
    this.desc,
    this.uri,
    this.amtNum,
    this.payChain,
    this.payCoin,
    this.payCoinContract,
    this.payCoinDecimal,
    this.payUuid,
    this.payAddr,
    this.type,
    this.del,
    this.created,
    this.updated,
  );

  factory SwapAstModel.fromJson(Map<String, dynamic> json) => SwapAstModel(
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'desc': desc,
        'uri': uri,
        'amt_num': amtNum,
        'pay_chain': payChain,
        'pay_coin': payCoin,
        'pay_coin_contract': payCoinContract,
        'pay_coin_decimal': payCoinDecimal,
        'pay_uuid': payUuid,
        'pay_addr': payAddr,
        'type': type,
        'del': del,
        'created': created,
        'updated': updated,
      };
}
