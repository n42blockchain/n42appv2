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

  AptApi({bool isTest = false, this.submit})
    : url = RequestUrl().getUrl2(CoinType.APT.name, 'rpc', isTest: isTest);

  Future<MessageModel> getBalance(
    String address, {
    String contract = '',
    String tokenName = '',
  }) async {
    try {
      final coinType = contract == ''
          ? '0x1::aptos_coin::AptosCoin'
          : '$contract::celer_coin_manager::$tokenName';
      final uri =
          '${url}accounts/$address/balance/0x1::coin::CoinStore<$coinType>';
      final data = await BaseApi.requestEmptyH.get(uri, params: {});
      return MessageModel()..data = BigInt.from(data);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getGasPrice() async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${url}estimate_gas_price',
        params: {},
      );
      return MessageModel()..data = BigInt.from(data['gas_estimate']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getAccountInfo(String address) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${url}accounts/$address',
        params: {},
      );
      return MessageModel()..data = int.parse(data['sequence_number']);
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  Future<MessageModel> getServiceInfo() async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${url}ledger/info',
        params: {},
      );
      return MessageModel()..data = int.parse(data['ledger_timestamp']);
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
