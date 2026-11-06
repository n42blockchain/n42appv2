import 'dart:convert';

import 'package:n42_wallet/core/network/base_api.dart';

/// Network-derived cost for an ordinary EGLD transfer, before signing.
class EgldFeeQuote {
  final BigInt gasLimit;
  final int gasPrice;
  final int version;
  BigInt get fee => gasLimit * BigInt.from(gasPrice);
  const EgldFeeQuote(this.gasLimit, this.gasPrice, this.version);

  factory EgldFeeQuote.parse(
    dynamic response, {
    required bool isTest,
    required int decimals,
    required String memo,
  }) {
    if (response is! Map ||
        response['code'] != 'successful' ||
        response['data'] is! Map ||
        response['data']['config'] is! Map) {
      throw const FormatException('Invalid network configuration');
    }
    final config = response['data']['config'] as Map;
    int integer(String key, {bool zeroAllowed = false}) {
      final value = config[key];
      if (value is! int || value < (zeroAllowed ? 0 : 1)) {
        throw const FormatException('Invalid network parameter');
      }
      return value;
    }

    if (config['erd_chain_id'] != (isTest ? 'T' : '1') ||
        integer('erd_denomination') != decimals) {
      throw const FormatException('Network does not match transfer');
    }
    final minimum = integer('erd_min_gas_limit');
    final perByte = integer('erd_gas_per_data_byte', zeroAllowed: true);
    final maximum = integer('erd_max_gas_per_transaction');
    final gasPrice = integer('erd_min_gas_price');
    final version = integer('erd_min_transaction_version');
    if (version > 0x7fffffff) {
      throw const FormatException('Invalid transaction version');
    }
    final gasLimit =
        BigInt.from(minimum) +
        BigInt.from(perByte) * BigInt.from(utf8.encode(memo).length);
    if (gasLimit > BigInt.from(maximum)) {
      throw const FormatException('Transfer exceeds network gas limit');
    }

    return EgldFeeQuote(gasLimit, gasPrice, version);
  }
}

class EgldQuoteService {
  final Future<dynamic> Function(String url) _get;
  EgldQuoteService({Future<dynamic> Function(String url)? get})
    : _get = get ?? _fetch;
  static Future<dynamic> _fetch(String url) => BaseApi.requestEmptyH.get(
    url,
    params: {},
    defaultReturn: false,
    header: {'Content-Type': 'application/json'},
  );
  Future<EgldFeeQuote> quote({
    required bool isTest,
    required int decimals,
    required String memo,
  }) async {
    final base = isTest
        ? 'https://testnet-api.multiversx.com'
        : 'https://api.multiversx.com';
    return EgldFeeQuote.parse(
      await _get('$base/network/config'),
      isTest: isTest,
      decimals: decimals,
      memo: memo,
    );
  }
}
