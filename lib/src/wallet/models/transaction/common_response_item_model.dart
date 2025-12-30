class CommonResponseItemModel{
  // "blockNumber":"10475175",
  // "timeStamp":"1630314219",
  // "hash":"0x9c12ea64ffe659114e1404509ae82d52ca8b785851ef99405d31a6b65fb4d0a2",
  // "nonce":"851069",
  // "blockHash":"0x52754e796549fe9ab7a4550e0f7d8286fdc8efcac185aad7e7c63ff7c0fb1e5a",
  // "transactionIndex":"22",
  // "from":"0x161ba15a5f335c9f06bb5bbb0a9ce14076fbb645",
  // "to":"0xf426a8d0a94bf039a35cee66dbf0227a7a12d11e",
  // "value":"90541060000000000",
  // "gas":"207128",
  // "gasPrice":"10000000000",
  // "isError":"0",
  // "txreceipt_status":"1",
  // "input":"0x",
  // "contractAddress":"",
  // "cumulativeGasUsed":"894108",
  // "gasUsed":"21000",
  // "confirmations":"2362"


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
  String? txreceipt_status;
  String? input;
  String? contractAddress;
  String? cumulativeGasUsed;
  String? gasUsed;
  String? confirmations;

  CommonResponseItemModel();
  CommonResponseItemModel.fromJson(Map<String, dynamic> map){
    blockNumber=map['blockNumber'] as String?;
    timeStamp=map['timeStamp'] as String?;
    hash=map['hash'] as String?;
    nonce=map['nonce'] as String?;
    blockHash=map['blockHash'] as String?;
    transactionIndex=map['transactionIndex'] as String?;
    from=map['from'] as String?;
    to=map['to'] as String?;
    value=map['value'] as String?;
    gas=map['gas'] as String?;
    gasPrice=map['gasPrice'] as String?;
    isError=map['isError'] as String?;
    txreceipt_status=map['txreceipt_status'] as String?;
    input=map['input'] as String?;
    contractAddress=map['contractAddress'] as String?;
    cumulativeGasUsed=map['cumulativeGasUsed'] as String?;
    gasUsed=map['gasUsed'] as String?;
    confirmations=map['confirmations'] as String?;
  }
  toJson(){
    return {
      "blockNumber":blockNumber,
      "timeStamp":timeStamp,
      "hash":hash,
      "nonce":nonce,
      "blockHash":blockHash,
      "transactionIndex":transactionIndex,
      "from":from,
      "to":to,
      "value":value,
      "gas":gas,
      "gasPrice":gasPrice,
      "isError":isError,
      "txreceipt_status":txreceipt_status,
      "input":input,
      "contractAddress":contractAddress,
      "cumulativeGasUsed":cumulativeGasUsed,
      "gasUsed":gasUsed,
      "confirmations":confirmations,
    };
  }

}
