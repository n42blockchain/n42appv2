import 'package:n42_wallet/features/wallet/models/transaction/explorer_response_utils.dart';

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

  int get normalizedState {
    final status = _normalizedFlag(txreceiptStatus);
    if (status == '1') return 1;
    if (status == '0') return 2;

    final error = _normalizedFlag(isError);
    if (error == '1') return 2;
    if (error == '0') return 1;

    final confirmed = int.tryParse(confirmations ?? '');
    if (confirmed != null && confirmed > 0) return 1;

    return 0;
  }

  factory CommonResponseItemModel.fromJson(Map<String, dynamic> map) {
    return CommonResponseItemModel()
      ..blockNumber = explorerString(map, const ['blockNumber', 'block_no'])
      ..timeStamp = explorerString(map, const ['timeStamp', 'time'])
      ..hash = explorerString(map, const ['hash', 'txid'])
      ..nonce = explorerString(map, const ['nonce'])
      ..blockHash = explorerString(map, const ['blockHash'])
      ..transactionIndex = explorerString(map, const ['transactionIndex', 'index'])
      ..from = explorerString(map, const ['from'])
      ..to = explorerString(map, const ['to'])
      ..value = explorerString(map, const ['value', 'tokenValue'])
      ..gas = explorerString(map, const ['gas', 'gasLimit', 'gaslimit'])
      ..gasPrice = explorerString(map, const ['gasPrice', 'gas_price'])
      ..isError = explorerString(map, const ['isError', 'error'])
      ..txreceiptStatus = explorerString(map, const ['txreceipt_status', 'status'])
      ..input = explorerString(map, const ['input'])
      ..contractAddress = explorerString(map, const ['contractAddress', 'tokenAddr', 'token'])
      ..cumulativeGasUsed = explorerString(map, const ['cumulativeGasUsed'])
      ..gasUsed = explorerString(map, const ['gasUsed', 'gasused'])
      ..confirmations = explorerString(map, const ['confirmations']);
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

  static String? _normalizedFlag(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case '1':
      case '0x1':
      case 'true':
      case 'success':
        return '1';
      case '0':
      case '0x0':
      case 'false':
      case 'failed':
      case 'failure':
      case 'error':
        return '0';
      default:
        return null;
    }
  }
}
