class SOLTransactionItem {
  String? id; // maps to '_id' in JSON
  String? src;
  String? dst;
  int? lamport;
  int? blockTime;
  int? slot;
  String? txHash;
  String? status;
  int? fee;
  int? decimals;
  int? txNumberSolTransfer;

  SOLTransactionItem(
    this.id,
    this.src,
    this.dst,
    this.lamport,
    this.blockTime,
    this.slot,
    this.txHash,
    this.status,
    this.fee,
    this.decimals,
    this.txNumberSolTransfer,
  );

  factory SOLTransactionItem.fromJson(Map<String, dynamic> map) =>
      SOLTransactionItem(
        map['_id'] as String?,
        map['src'] as String?,
        map['dst'] as String?,
        map['lamport'] as int?,
        map['blockTime'] as int?,
        map['slot'] as int?,
        map['txHash'] as String?,
        map['status'] as String?,
        map['fee'] as int?,
        map['decimals'] as int?,
        map['txNumberSolTransfer'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        '_id': id,
        'src': src,
        'dst': dst,
        'lamport': lamport,
        'blockTime': blockTime,
        'slot': slot,
        'txHash': txHash,
        'status': status,
        'fee': fee,
        'decimals': decimals,
        'txNumberSolTransfer': txNumberSolTransfer,
      };
}
