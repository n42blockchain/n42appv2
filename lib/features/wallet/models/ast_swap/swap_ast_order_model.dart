class SwapAstOrderModel {
  int? id;
  int? nftAmtId;
  String? bUuid;
  String? bAddr;
  double? orderNum;
  double? orderPrice; // ast兑换价格
  double? payNum; // 支付金额
  String? payTx; // 交易哈希
  int? payState; // 支付日期
  int? orderState; // 订单状态
  String? orderTx; // 订单支付哈希
  int? expire; // 失效日期
  int? type; // 订单类型
  int? created; // 创建日期
  int? updated; // 修改时间
  String? name;
  String? desc;
  String? uri; // 币图标
  String? payChain;
  String? payCoin;

  SwapAstOrderModel();

  factory SwapAstOrderModel.fromJson(Map<String, dynamic> js) {
    return SwapAstOrderModel()
      ..id = js['id'] as int?
      ..nftAmtId = js['nft_amt_id'] as int?
      ..bUuid = js['b_uuid'] as String?
      ..bAddr = js['b_addr'] as String?
      ..orderNum = (js['order_num'] as num?)?.toDouble()
      ..orderPrice = (js['order_price'] as num?)?.toDouble()
      ..payNum = (js['pay_num'] as num?)?.toDouble()
      ..payTx = js['pay_tx'] as String?
      ..payState = js['pay_state'] as int?
      ..orderState = js['order_state'] as int?
      ..orderTx = js['order_tx'] as String?
      ..expire = js['expire'] as int?
      ..type = js['type'] as int?
      ..created = js['created'] as int?
      ..updated = js['updated'] as int?
      ..name = js['name'] as String?
      ..desc = js['desc'] as String?
      ..uri = js['uri'] as String?
      ..payChain = js['pay_chain'] as String?
      ..payCoin = js['pay_coin'] as String?;
  }
}
