import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fast_base58/fast_base58.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:n42_wallet/features/wallet/models/aggregated_token.dart';

/// Read-only balances. Transport/shape failures must never become zero balances.
class AggregatedBalanceReader {
  AggregatedBalanceReader({http.Client Function()? clientFactory})
    : _clientFactory = clientFactory ?? http.Client.new;
  final http.Client Function() _clientFactory;

  static String _tronParameter(String address) {
    final bytes = Base58Decode(address);
    if (bytes.length != 25 || bytes.first != 0x41) {
      throw const FormatException('Invalid TRON address');
    }
    final payload = bytes.sublist(0, 21);
    final checksum = crypto.sha256
        .convert(crypto.sha256.convert(payload).bytes)
        .bytes;
    for (var i = 0; i < 4; i++) {
      if (bytes[21 + i] != checksum[i]) {
        throw const FormatException('Invalid TRON checksum');
      }
    }
    return payload
        .sublist(1)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .padLeft(64, '0');
  }

  Future<BigInt> read(ChainTokenConfig config, String address) async {
    final client = _clientFactory();
    try {
      if (config.rules == 'TRC20') {
        final parameter = _tronParameter(address);
        _tronParameter(config.contract);
        final base = config.rpcUrl.replaceFirst(RegExp(r'/$'), '');
        final response = await client
            .post(
              Uri.parse('$base/wallet/triggerconstantcontract'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'owner_address': address,
                'contract_address': config.contract,
                'visible': true,
                'function_selector': 'balanceOf(address)',
                'parameter': parameter,
              }),
            )
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) {
          throw const FormatException('TRC20 HTTP request failed');
        }
        final data = jsonDecode(response.body);
        if (data is! Map ||
            data['result'] is! Map ||
            data['result']['result'] != true ||
            data['constant_result'] is! List ||
            (data['constant_result'] as List).length != 1) {
          throw const FormatException('TRC20 balance unavailable');
        }
        final value = data['constant_result'][0];
        if (value is! String || !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(value)) {
          throw const FormatException('Invalid TRC20 balance');
        }
        return BigInt.parse(value, radix: 16);
      }
      final isSolana = config.rules == 'SPL';
      if (!isSolana &&
          (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address) ||
              !RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(config.contract))) {
        throw const FormatException('Invalid ERC20 address');
      }
      final response = await client
          .post(
            Uri.parse(config.rpcUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'method': isSolana ? 'getTokenAccountsByOwner' : 'eth_call',
              'params': isSolana
                  ? [
                      address,
                      {'mint': config.contract},
                      {'encoding': 'jsonParsed', 'commitment': 'confirmed'},
                    ]
                  : [
                      {
                        'to': config.contract,
                        'data':
                            '0x70a08231${address.substring(2).padLeft(64, '0')}',
                      },
                      'latest',
                    ],
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw const FormatException('Balance HTTP request failed');
      }
      final data = jsonDecode(response.body);
      if (data is! Map || data['error'] != null) {
        throw const FormatException('Balance RPC request failed');
      }
      if (!isSolana) {
        final value = data['result'];
        if (value is! String ||
            !RegExp(r'^0x[0-9a-fA-F]{1,64}$').hasMatch(value)) {
          throw const FormatException('Invalid ERC20 balance response');
        }
        return BigInt.parse(value.substring(2), radix: 16);
      }
      final result = data['result'];
      if (result is! Map || result['value'] is! List) {
        throw const FormatException('Invalid SPL balance response');
      }
      var total = BigInt.zero;
      final accounts = <String>{};
      for (final row in result['value'] as List) {
        final info = row?['account']?['data']?['parsed']?['info'];
        final amount = info?['tokenAmount'];
        final account = row?['pubkey'];
        if (account is! String ||
            account.isEmpty ||
            !accounts.add(account) ||
            info?['mint'] != config.contract ||
            info?['owner'] != address ||
            amount?['decimals'] != config.decimals ||
            amount?['amount'] is! String ||
            !RegExp(r'^\d+$').hasMatch(amount['amount'] as String)) {
          throw const FormatException('Invalid SPL token account');
        }
        total += BigInt.parse(amount['amount'] as String);
      }
      return total;
    } finally {
      client.close();
    }
  }
}
