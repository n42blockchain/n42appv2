import 'package:n42_wallet/features/wallet/models/transaction/explorer_response_utils.dart';

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

  factory SOLTransactionItem.fromExplorerJson(Map<String, dynamic> map) =>
      SOLTransactionItem(
        explorerString(map, const ['_id', 'id']),
        explorerString(map, const ['src', 'from']),
        explorerString(map, const ['dst', 'to']),
        _parseExplorerInt(map, const ['lamport', 'value'], decimals: 9),
        _parseExplorerInt(map, const ['blockTime', 'time', 'timeStamp']),
        _parseExplorerInt(map, const ['slot']),
        explorerString(map, const ['txHash', 'txid', 'hash']),
        _normalizeStatus(explorerString(map, const ['status'])),
        _parseExplorerInt(map, const [
          'fee',
          'gasPrice',
          'gas_price',
        ], decimals: 9),
        _parseExplorerInt(map, const ['decimals']),
        _parseExplorerInt(map, const ['txNumberSolTransfer']),
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

  static int? _parseExplorerInt(
    Map<String, dynamic> map,
    Iterable<String> keys, {
    int? decimals,
  }) {
    final raw = explorerString(map, keys);
    if (raw == null || raw.isEmpty) return null;
    if (decimals != null) {
      return parseExplorerAmount(raw, decimals).toInt();
    }
    return int.tryParse(raw);
  }

  static String? _normalizeStatus(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case '1':
      case '0x1':
      case 'success':
      case 'successful':
      case 'confirmed':
      case 'ok':
        return 'Success';
      case '0':
      case '0x0':
      case 'fail':
      case 'failed':
      case 'error':
        return 'Failed';
      case 'pending':
        return 'Pending';
      default:
        return raw;
    }
  }
}
