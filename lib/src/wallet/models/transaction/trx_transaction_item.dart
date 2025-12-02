class TRXTransactionItem {
  final int? block;
  final String? hash;
  final int? timestamp;
  final String? ownerAddress;
  final String? toAddress;
  final String? amount;
  //合约类型 1 时为合约交易
  final int? contractType;
  final Cost? cost;

  ContractData contractData;

  TRXTransactionItem(this.block, this.hash, this.timestamp, this.ownerAddress,
      this.toAddress, this.amount, this.cost, this.contractType,this.contractData);

  factory TRXTransactionItem.fromJson(Map<String, dynamic> json) =>TRXTransactionItem(
    json['block'] as int?,
    json['hash'] as String?,
    json['timestamp'] as int?,
    json['ownerAddress'] as String?,
    json['toAddress'] as String?,
    json['amount'] as String?,
    json['cost'] == null
        ? null
        : Cost.fromJson(json['cost'] as Map<String, dynamic>),
    json['contractType'] as int?,
    ContractData.fromJson(json['contractData'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'block': block,
    'hash': hash,
    'timestamp': timestamp,
    'ownerAddress': ownerAddress,
    'toAddress': toAddress,
    'amount': amount,
    'contractType': contractType,
    'cost': cost,
    'contractData': contractData,
  };
}

class ContractData {
  int? amount;
  String? owner_address;
  String? to_address;

  ContractData(this.amount, this.owner_address, this.to_address);

  factory ContractData.fromJson(Map<String, dynamic> json) =>ContractData(
    json['amount'] as int?,
    json['owner_address'] as String?,
    json['to_address'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'amount': amount,
    'owner_address': owner_address,
    'to_address': to_address,
  };

}

class Cost {
  final int? net_fee;
  final int? fee;
  final int? net_usage;

  Cost(this.net_fee, this.fee, this.net_usage);

  factory Cost.fromJson(Map<String, dynamic> json) => Cost(
    json['net_fee'] as int?,
    json['fee'] as int?,
    json['net_usage'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'net_fee': net_fee,
    'fee': fee,
    'net_usage': net_usage,
  };
}