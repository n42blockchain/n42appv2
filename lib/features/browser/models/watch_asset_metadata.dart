import 'dart:convert';

import 'watch_asset_request.dart';

/// Contract metadata read from the selected network, never from DApp URLs.
class WatchAssetMetadata {
  final WatchAssetRequest request;
  final String symbol;
  final String name;
  final int decimals;

  const WatchAssetMetadata._(
    this.request,
    this.symbol,
    this.name,
    this.decimals,
  );

  static Future<WatchAssetMetadata> load({
    required WatchAssetRequest request,
    required Future<dynamic> Function(String, List<dynamic>) rpc,
    required void Function() validateRequest,
  }) async {
    Never invalid(String message) => throw {'code': -32602, 'message': message};
    Future<dynamic> read(String method, List<dynamic> params) async {
      validateRequest();
      final value = await rpc(
        method,
        params,
      ).timeout(const Duration(seconds: 15));
      validateRequest();
      return value;
    }

    final chain = await read('eth_chainId', []);
    if (chain is! String ||
        !RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(chain) ||
        BigInt.parse(chain.substring(2), radix: 16) !=
            BigInt.from(request.chainId)) {
      invalid('RPC network does not match the asset network');
    }
    final address = request.address.eip55With0x;
    final code = await read('eth_getCode', [address, 'latest']);
    if (code is! String ||
        code.length > 2097154 ||
        !RegExp(r'^0x(?:[0-9a-fA-F]{2})+$').hasMatch(code) ||
        !RegExp(r'[1-9a-fA-F]').hasMatch(code.substring(2))) {
      invalid('Token address has no valid contract code');
    }
    Future<dynamic> call(String selector) => read('eth_call', [
      {'to': address, 'data': selector},
      'latest',
    ]);
    final symbol = _decodeText(await call('0x95d89b41'));
    final rawDecimals = await call('0x313ce567');
    if (rawDecimals is! String ||
        !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(rawDecimals)) {
      invalid('Invalid contract decimals');
    }
    final decimals = BigInt.parse(rawDecimals.substring(2), radix: 16);
    if (decimals > BigInt.from(255)) invalid('Unsupported contract decimals');
    // ERC20 name() is optional; the verified symbol is a safe display fallback.
    final name = symbol;
    if ((request.suggestedSymbol != null &&
            request.suggestedSymbol != symbol) ||
        (request.suggestedDecimals != null &&
            request.suggestedDecimals != decimals.toInt())) {
      invalid('Suggested metadata does not match the token contract');
    }
    return WatchAssetMetadata._(request, symbol, name, decimals.toInt());
  }

  static String _decodeText(dynamic encoded) {
    Never invalid() =>
        throw {'code': -32602, 'message': 'Invalid token contract text'};
    if (encoded is! String ||
        encoded.length > 1154 ||
        !RegExp(r'^0x(?:[0-9a-fA-F]{2})+$').hasMatch(encoded)) {
      invalid();
    }
    final hex = encoded.substring(2);
    List<int> bytes;
    if (hex.length == 64) {
      bytes = _bytes(hex);
      final end = bytes.indexOf(0);
      if (end >= 0) {
        if (bytes.skip(end).any((b) => b != 0)) invalid();
        bytes = bytes.take(end).toList();
      }
    } else {
      if (hex.length < 128 ||
          hex.length % 64 != 0 ||
          BigInt.parse(hex.substring(0, 64), radix: 16) != BigInt.from(32)) {
        invalid();
      }
      final length = BigInt.parse(hex.substring(64, 128), radix: 16);
      if (length <= BigInt.zero || length > BigInt.from(256)) invalid();
      final count = length.toInt();
      final paddedLength = ((count + 31) ~/ 32) * 64;
      if (hex.length != 128 + paddedLength) invalid();
      bytes = _bytes(hex.substring(128, 128 + count * 2));
      if (_bytes(hex.substring(128 + count * 2)).any((b) => b != 0)) invalid();
    }
    String value;
    try {
      value = utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      invalid();
    }
    if (value.trim().isEmpty ||
        RegExp(r'[\x00-\x1f\x7f\u202a-\u202e\u2066-\u2069]').hasMatch(value)) {
      invalid();
    }
    return value;
  }

  static List<int> _bytes(String hex) => [
    for (var i = 0; i < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ];
}
