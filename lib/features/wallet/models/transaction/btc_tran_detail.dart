class BtcTranDetail{
  final String? blockHash;
  final int blockIndex;
  final String hash;
  final List<String>? addresses;
  final int total;
  final int fees;
  final String? confirmed;///确认时间
  final int confirmations;//确认 大于 26 成功
  final List<Input>? inputs;
  final List<Output>? outputs;

  BtcTranDetail(this.blockHash, this.blockIndex, this.hash, this.addresses, this.total, this.fees, this.confirmed, this.confirmations, this.inputs, this.outputs);


  factory BtcTranDetail.fromJson(Map<String, dynamic> json) =>BtcTranDetail(
    json['block_hash'] as String?,
    json['block_index'] as int,
    json['hash'] as String,
    (json['addresses'] as List<dynamic>?)?.map((e) => e as String).toList(),
    json['total'] as int,
    json['fees'] as int,
    json['confirmed'] as String?,
    json['confirmations'] as int,
    (json['inputs'] as List<dynamic>?)
        ?.map((e) => Input.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['outputs'] as List<dynamic>?)
        ?.map((e) => Output.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'block_hash': blockHash,
    'block_index': blockIndex,
    'hash': hash,
    'addresses': addresses,
    'total': total,
    'fees': fees,
    'confirmed': confirmed,
    'confirmations': confirmations,
    'inputs': inputs,
    'outputs': outputs,
  };
}
class Input {
  final String prevHash;
  final int outputIndex;
  final String? script;
  final int outputValue;
  final List<String> addresses;

  Input(this.prevHash, this.outputIndex, this.script, this.outputValue, this.addresses);


  factory Input.fromJson(Map<String, dynamic> json) =>Input(
    json['prev_hash'] as String,
    json['output_index'] as int,
    json['script'] as String?,
    json['output_value'] as int,
    (json['addresses'] as List<dynamic>).map((e) => e as String).toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'prev_hash': prevHash,
    'output_index': outputIndex,
    'script': script,
    'output_value': outputValue,
    'addresses': addresses,
  };


}

class Output {
  final int value;
  final String? script;
  final List<String>? addresses;

  Output(this.value, this.script, this.addresses);


  factory Output.fromJson(Map<String, dynamic> json) =>Output(
    json['value'] as int,
    json['script'] as String?,
    (json['addresses'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'value': value,
    'script': script,
    'addresses': addresses,
  };


}
