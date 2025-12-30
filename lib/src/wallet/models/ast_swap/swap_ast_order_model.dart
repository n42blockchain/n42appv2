class SwapAstOrderModel{
  int? id;
  int? nft_amt_id;
  String? b_uuid;
  String? b_addr;
  double? order_num;
  double? order_price;//ast兑换价格
  double? pay_num;//支付金额
  String? pay_tx;//交易哈希
  int? pay_state;//支付日期
  int? order_state;//订单状态
  String? order_tx;//订单支付哈希
  int? expire;//失效日期
  int? type;//订单类型
  int? created;//穿件日期
  int? updated;//修改时间
  String? name;
  String? desc;
  String? uri;//币图标
  String? pay_chain;
  String? pay_coin;

  SwapAstOrderModel();
  SwapAstOrderModel.fromJson(Map<String,dynamic> js){
    id=js['id'] as int?;
    nft_amt_id=js['nft_amt_id'] as int?;
    b_uuid=js['b_uuid'] as String?;
    b_addr=js['b_addr'] as String?;
    order_num=(js['order_num'] as num?)?.toDouble();
    order_price=(js['order_price'] as num?)?.toDouble();//ast兑换价格
    pay_num=(js['pay_num'] as num?)?.toDouble();//支付金额? pay_tx=js[''];//交易哈希
    pay_state=js['pay_state'] as int?;//支付日期
    order_state=js['order_state'] as int?;//订单状态
    order_tx=js['order_tx'] as String?;//订单支付哈希
    expire=js['expire'] as int?;//失效日期
    type=js['type'] as int?;//订单类型
    created=js['created'] as int?;//穿件日期
    updated=js['updated'] as int?;//修改时间
    name=js['name'] as String?;
    desc=js['desc'] as String?;
    uri=js['uri'] as String?;
    pay_chain=js['pay_chain'] as String?;
    pay_coin=js['pay_coin'] as String?;
  }
}
