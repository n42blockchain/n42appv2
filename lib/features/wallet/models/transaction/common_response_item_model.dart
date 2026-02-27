/// EVM-compatible transaction record from block explorer APIs
/// (e.g. Etherscan-compatible endpoints).
class CommonResponseItemModel {
  String? blockNumber;
  String? timeStamp;
  String? hash;
  String? nonce;
  String? blockHash;
  String? transactionIndex;
  String? from;
  String? to;
  String? value;
  String? gas;
  String? gasPrice;
  String? isError;
  String? txreceiptStatus;
  String? input;
  String? contractAddress;
  String? cumulativeGasUsed;
  String? gasUsed;
  String? confirmations;

  CommonResponseItemModel();

  factory CommonResponseItemModel.fromJson(Map<String, dynamic> map) {
    return CommonResponseItemModel()
      ..blockNumber = map['blockNumber'] as String?
      ..timeStamp = map['timeStamp'] as String?
      ..hash = map['hash'] as String?
      ..nonce = map['nonce'] as String?
      ..blockHash = map['blockHash'] as String?
      ..transactionIndex = map['transactionIndex'] as String?
      ..from = map['from'] as String?
      ..to = map['to'] as String?
      ..value = map['value'] as String?
      ..gas = map['gas'] as String?
      ..gasPrice = map['gasPrice'] as String?
      ..isError = map['isError'] as String?
      ..txreceiptStatus = map['txreceipt_status'] as String?
      ..input = map['input'] as String?
      ..contractAddress = map['contractAddress'] as String?
      ..cumulativeGasUsed = map['cumulativeGasUsed'] as String?
      ..gasUsed = map['gasUsed'] as String?
      ..confirmations = map['confirmations'] as String?;
  }

  Map<String, dynamic> toJson() => {
        'blockNumber': blockNumber,
        'timeStamp': timeStamp,
        'hash': hash,
        'nonce': nonce,
        'blockHash': blockHash,
        'transactionIndex': transactionIndex,
        'from': from,
        'to': to,
        'value': value,
        'gas': gas,
        'gasPrice': gasPrice,
        'isError': isError,
        'txreceipt_status': txreceiptStatus,
        'input': input,
        'contractAddress': contractAddress,
        'cumulativeGasUsed': cumulativeGasUsed,
        'gasUsed': gasUsed,
        'confirmations': confirmations,
      };
}
