import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/base_http.dart';

/// Read-only lookup on the same fixed network origins used by EgldSender.
class EgldApi {
  final Future<dynamic> Function(String url) _get;
  final Future<HttpStatusResult> Function(String url)? _lookup;
  EgldApi({
    Future<dynamic> Function(String url)? get,
    Future<HttpStatusResult> Function(String url)? lookup,
  }) : _get = get ?? _request,
       _lookup = lookup;

  static const _header = {'Content-Type': 'application/json'};

  static Future<dynamic> _request(String url) => BaseApi.requestEmptyH.get(
    url,
    params: {},
    defaultReturn: false,
    header: _header,
  );

  static String _origin(bool isTest) => isTest
      ? 'https://testnet-api.multiversx.com'
      : 'https://api.multiversx.com';

  Future<dynamic> getTransaction(String hash, {required bool isTest}) {
    if (hash.length != 64 || !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hash)) {
      throw const FormatException('Invalid MultiversX transaction hash');
    }
    return _get('${_origin(isTest)}/transactions/${hash.toLowerCase()}');
  }

  /// Single GET that exposes the HTTP status (no retry, no error mapping) so
  /// a definite 404 can be told apart from a transport failure.
  Future<HttpStatusResult> lookup(String path, {required bool isTest}) {
    final url = '${_origin(isTest)}$path';
    if (_lookup != null) return _lookup(url);
    return BaseApi.requestEmptyH.requestWithStatus(
      url,
      method: 'GET',
      header: _header,
      timeout: const Duration(seconds: 15),
    );
  }
}
