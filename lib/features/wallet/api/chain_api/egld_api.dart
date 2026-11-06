import 'package:n42_wallet/core/network/base_api.dart';

/// Read-only lookup on the same fixed network origins used by EgldSender.
class EgldApi {
  final Future<dynamic> Function(String url) _get;
  EgldApi({Future<dynamic> Function(String url)? get}) : _get = get ?? _request;

  static Future<dynamic> _request(String url) => BaseApi.requestEmptyH.get(
    url,
    params: {},
    defaultReturn: false,
    header: {'Content-Type': 'application/json'},
  );

  Future<dynamic> getTransaction(String hash, {required bool isTest}) {
    if (hash.length != 64 || !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash)) {
      throw const FormatException('Invalid MultiversX transaction hash');
    }
    final origin = isTest
        ? 'https://testnet-api.multiversx.com'
        : 'https://api.multiversx.com';
    return _get('$origin/transactions/${hash.toLowerCase()}');
  }
}
