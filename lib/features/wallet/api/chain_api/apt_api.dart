import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class AptApi {
  final String url;

  AptApi({bool isTest = false})
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

  Future<MessageModel> sendTxHash(String txHash) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${url}transactions',
        params: {},
        data: txHash,
        header: {'content-type': 'application/x.aptos.signed_transaction+bcs'},
      );
      return MessageModel()..data = data['hash'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }
}
