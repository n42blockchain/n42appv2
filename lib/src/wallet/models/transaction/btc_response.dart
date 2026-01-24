class BtcResponse{
  final String address; //自己的
  final int totalReceived;
  final int totalSent;
  final int balance; //余额
  final int unconfirmedBalance;
  final List<Txref> txrefs;

  BtcResponse(this.address, this.totalReceived, this.totalSent, this.balance,
      this.unconfirmedBalance, this.txrefs);

  factory BtcResponse.fromJson(Map<String, dynamic> json) =>BtcResponse(
    json['address'] as String,
    json['total_received'] as int,
    json['total_sent'] as int,
    json['balance'] as int,
    json['unconfirmed_balance'] as int,
    (json['txrefs'] as List<dynamic>)
        .map((e) => Txref.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'address': address,
    'total_received': totalReceived,
    'total_sent': totalSent,
    'balance': balance,
    'unconfirmed_balance': unconfirmedBalance,
    'txrefs': txrefs,
  };
}
class Txref {
  final String txHash;
  final int blockHeight;
  final int value;
  final int refBalance;
  final int confirmations;
  final int txInputN;
  final int txOutputN;
  final String confirmed;

  Txref(this.txHash, this.blockHeight, this.value, this.refBalance, this.confirmations,this.txInputN,this.txOutputN,this.confirmed);

  factory Txref.fromJson(Map<String, dynamic> json) => Txref(
    json['tx_hash'] as String,
    json['block_height'] as int,
    json['value'] as int,
    json['ref_balance'] as int,
    json['confirmations'] as int,
    json['tx_input_n'] as int,
    json['tx_output_n'] as int,
    json['confirmed'] as String,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tx_hash':txHash,
    'block_height': blockHeight,
    'value': value,
    'ref_balance': refBalance,
    'confirmations': confirmations,
    'tx_input_n':txInputN,
    'tx_output_n':txOutputN,
    'confirmed':confirmed,
  };
}
