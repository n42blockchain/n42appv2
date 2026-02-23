class WCEthSignTransaction {
  String? from;
  String? to;
  String? nonce;
  String? gasPrice;
  String? maxFeePerGas;
  String? maxPriorityFeePerGas;
  String? gas;
  String? gasLimit;
  String? value;
  String? data;

  WCEthSignTransaction({
    required this.from,
    this.to,
    this.nonce,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    this.gas,
    this.gasLimit,
    this.value,
    this.data,
  });
  WCEthSignTransaction.fromJson(Map<String,dynamic> json){
    from= json['from'] as String?;
    to= json['to'] as String?;
    nonce= json['nonce'] as String?;
    gasPrice= json['gasPrice'] as String?;
    maxFeePerGas= json['maxFeePerGas'] as String?;
    maxPriorityFeePerGas= json['maxPriorityFeePerGas'] as String?;
    gas= json['gas'] as String?;
    gasLimit= json['gasLimit'] as String?;
    value= json['value'] as String?;
    data= json['data'] as String?;
  }
}