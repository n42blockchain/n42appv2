class BtcResponse{
  final String address; //自己的
  final int total_received;
  final int total_sent;
  final int balance; //余额
  final int unconfirmed_balance;
  final List<Txref> txrefs;

  BtcResponse(this.address, this.total_received, this.total_sent, this.balance,
      this.unconfirmed_balance, this.txrefs);

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
    'total_received': total_received,
    'total_sent': total_sent,
    'balance': balance,
    'unconfirmed_balance': unconfirmed_balance,
    'txrefs': txrefs,
  };
}
class Txref {
  final String tx_hash;
  final int block_height;
  final int value;
  final int ref_balance;
  final int confirmations;
  final int tx_input_n;
  final int tx_output_n;
  final String confirmed;

  Txref(this.tx_hash, this.block_height, this.value, this.ref_balance, this.confirmations,this.tx_input_n,this.tx_output_n,this.confirmed);

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
    'tx_hash':tx_hash,
    'block_height': block_height,
    'value': value,
    'ref_balance': ref_balance,
    'confirmations': confirmations,
    'tx_input_n':tx_input_n,
    'tx_output_n':tx_output_n,
    'confirmed':confirmed,
  };
}