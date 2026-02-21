import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

class DexSwapApi {
  late final String _base;
  late final Map<String, String> _header;

  DexSwapApi() {
    _base = AppConfig.getApiUrlOnline('exchangeHost');
    _header = {'content-type': 'application/json'};
  }

  /// GET /v1/dex/tokens?chain=ETH[&q=usdc]
  ///
  /// [q] 可选搜索词，后端按 symbol/name/address 模糊过滤。
  /// 传入完整合约地址时可精确查找未预加载的代币。
  Future<MessageModel> getTokens(String chain, {String? q}) async {
    final params = <String, dynamic>{'chain': chain};
    if (q != null && q.isNotEmpty) params['q'] = q;
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$_base/v1/dex/tokens',
        params: params,
        header: _header,
      );
      final mm = MessageModel();
      mm.data = data['data'];
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// POST /v1/dex/quote
  Future<MessageModel> getQuote({
    required String chain,
    required String tokenIn,
    required String tokenOut,
    required String amountIn,
    required String userAddr,
    int slippageBps = 50,
  }) async {
    final body = {
      'chain': chain,
      'token_in': tokenIn,
      'token_out': tokenOut,
      'amount_in': amountIn,
      'user_addr': userAddr,
      'slippage_bps': slippageBps,
    };
    try {
      final data = await BaseApi.requestEmptyH.post(
        '$_base/v1/dex/quote',
        params: {},
        data: body,
        header: _header,
      );
      final mm = MessageModel();
      if (data['code'] == 200) {
        mm.data = data['data'];
      } else {
        mm.error = true;
        mm.data = data['msg'] ?? data['err'] ?? 'Quote failed';
      }
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// POST /v1/dex/commit
  Future<MessageModel> commit(
      String uuid, String orderId, String txHash) async {
    final body = {
      'uuid': uuid,
      'order_id': orderId,
      'tx_hash': txHash,
    };
    try {
      await BaseApi.requestEmptyH.post(
        '$_base/v1/dex/commit',
        params: {},
        data: body,
        header: _header,
      );
      final mm = MessageModel();
      mm.data = true;
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// GET /v1/dex/history?user={uuid}&page=&size=
  Future<MessageModel> getHistory(String uuid,
      {int page = 1, int size = 20}) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$_base/v1/dex/history',
        params: {'user': uuid, 'page': page, 'size': size},
        header: _header,
      );
      final mm = MessageModel();
      mm.data = data['data']['list'];
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
