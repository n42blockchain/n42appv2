import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/request_url.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:http/http.dart' as http;

class BtcApi {
  final String? uri;
  final bool isTest;

  BtcApi({bool test = false})
      : isTest = test,
        uri = RequestUrl().getUrl2(CoinType.BTC.name, 'api', isTest: test);

  Future<MessageModel> getGasfee() async {
    try {
      final data = await BaseApi.requestEmptyH.get('${uri}v1/fees/recommended', params: {});
      return MessageModel()..data = data['economyFee'];
    } catch (e) {
      // 获取 gas 费失败时返回默认值 2
      return MessageModel()..data = 2;
    }
  }

  Future<MessageModel> getUtxos(String address) async {
    try {
      final data = await BaseApi.requestEmptyH.get('${uri}address/$address/utxo', params: {});
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  Future<MessageModel> getUTXOTxid(String txid) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${uri}tx/$txid',
        params: {},
        defaultReturn: false,
        header: {'Content-Type': 'application/json'},
      );
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  Future<MessageModel> getBalance(String address) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${uri}address/$address',
        params: {},
        defaultReturn: false,
        header: {'Content-Type': 'application/json'},
      );
      final mm = MessageModel();
      if (data['chain_stats'] != null) {
        final int fundedTxoSum = data['chain_stats']['funded_txo_sum'];
        final int spentTxoSum = data['chain_stats']['spent_txo_sum'];
        mm.data = BigInt.from(fundedTxoSum - spentTxoSum);
      } else {
        mm.data = BigInt.zero;
      }
      return mm;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  Future<MessageModel> sendTxHttp(String signHase) async {
    final url = '${uri}tx';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'text/plain'},
        body: signHase,
      );
      if (response.statusCode == 200) {
        return MessageModel()..data = response.body;
      } else {
        return MessageModel.error()..data = 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return MessageModel.error()..data = 'Request failed: $e';
    }
  }

  Future<MessageModel> sendTx(String signHase) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${uri}tx',
        params: {},
        defaultReturn: false,
        header: {'Content-Type': 'text/plain'},
        data: signHase,
      );
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }

  Future<MessageModel> getTxState(String txId) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '${uri}tx/$txId/status',
        params: {},
        defaultReturn: false,
        header: {'Content-Type': 'application/json'},
      );
      return MessageModel()..data = data;
    } catch (e) {
      return MessageModel.error()..data = e;
    }
  }
}
