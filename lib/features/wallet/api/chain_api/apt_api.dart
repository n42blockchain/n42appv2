import 'dart:typed_data';

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

typedef AptTransactionSubmit = Future<dynamic> Function(
  String url,
  Uint8List bytes, {
  required Map<String, dynamic> header,
  required bool enableRetry,
});

class AptApi {
  final String url;
  final AptTransactionSubmit? submit;
  final Future<dynamic> Function(String url)? read;

  Future<dynamic> _get(String endpoint) => read != null
      ? read!(endpoint)
      : BaseApi.requestEmptyH.get(endpoint, params: {});

  /// Preserve REST uint64 strings; never accept rounded floating-point values.
  static BigInt parseUint64(dynamic value) {
    if (value is! String && value is! int && value is! BigInt) {
      throw const FormatException('Invalid Aptos uint64');
    }
    final text = value.toString();
    final number = BigInt.tryParse(text);
    if (number == null ||
        number < BigInt.zero ||
        number >= (BigInt.one << 64) ||
        number.toString() != text) {
      throw const FormatException('Invalid Aptos uint64');
    }
    return number;
  }

  AptApi({bool isTest = false, this.submit, this.read})
    : url = RequestUrl().getUrl2(CoinType.APT.name, 'rpc', isTest: isTest);

  Future<MessageModel> getBalance(
    String address, {
    String contract = '',
    String tokenName = '',
  }) async {
    try {
      // This endpoint takes the asset itself, not its CoinStore resource tag.
      // Keep the legacy explicit Celer symbol path for existing callers.
      final assetType = contract.isEmpty
          ? '0x1::aptos_coin::AptosCoin'
          : tokenName.isNotEmpty && !contract.contains('::')
          ? '$contract::celer_coin_manager::$tokenName'
          : contract;
      final uri =
          '${url}accounts/${Uri.encodeComponent(address)}/balance/'
          '${Uri.encodeComponent(assetType)}';
      final data = await _get(uri);
      return MessageModel()..data = parseUint64(data);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getGasPrice() async {
    try {
      final data = await _get('${url}estimate_gas_price');
      return MessageModel()..data = parseUint64(data['gas_estimate']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getAccountInfo(String address) async {
    try {
      final data = await _get('${url}accounts/$address');
      return MessageModel()..data = parseUint64(data['sequence_number']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getServiceInfo() async {
    try {
      final data = await _get(url);
      return MessageModel()..data = parseUint64(data['ledger_timestamp']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  /// Native signers return hex; the REST BCS endpoint requires raw bytes.
  Future<MessageModel> sendTxHash(String signedHex) async {
    try {
      final hex = signedHex.startsWith('0x') || signedHex.startsWith('0X')
          ? signedHex.substring(2)
          : signedHex;
      if (hex.isEmpty ||
          hex.length.isOdd ||
          !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
        return MessageModel.error()..data = 'Invalid Aptos signed transaction';
      }
      final bytes = Uint8List(hex.length ~/ 2);
      for (var i = 0; i < bytes.length; i++) {
        bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
      }
      const header = <String, dynamic>{
        'content-type': 'application/x.aptos.signed_transaction+bcs',
      };
      final request = submit;
      final data = request != null
          ? await request(
              '${url}transactions',
              bytes,
              header: header,
              enableRetry: false,
            )
          : await BaseApi.requestEmptyH.post(
              '${url}transactions',
              params: {},
              data: bytes,
              header: header,
              enableRetry: false,
            );
      if (data is! Map ||
          data['hash'] is! String ||
          (data['hash'] as String).length != 66 ||
          !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(data['hash'] as String) ||
          (data.containsKey('success') && data['success'] != true)) {
        return MessageModel.error()
          ..data = 'Invalid or failed Aptos submission response';
      }
      // A hash acknowledges submission; it is not proof of final execution.
      return MessageModel()..data = data['hash'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
