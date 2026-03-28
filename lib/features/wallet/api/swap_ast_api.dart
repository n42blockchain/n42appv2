import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

class SwapAstApi {
  final String _url;
  final Map<String, String> _header;

  SwapAstApi()
      : _url = AppConfig.getApiUrlOnline('nftHost'),
        _header = const {'content-type': 'application/json'};

  // ── 私有辅助 ──────────────────────────────────────────────────────────────

  MessageModel _ok(dynamic data) => MessageModel()..data = data;
  MessageModel _err(Object e) => MessageModel.error()..data = e.toString();

  // ── Public API ────────────────────────────────────────────────────────────

  // 获取商品列表（type: 1=nft, 2=ast）
  Future<MessageModel> getNftOrAstList(int type) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$_url/v1/nft-amt/list',
        params: {'type': type},
        header: _header,
      );
      return _ok(data['data']);
    } catch (e) {
      return _err(e);
    }
  }

  // 获取订单详情
  Future<MessageModel> getNftOrAstDetail(int orderId) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$_url/v1/nft-amt/order/detail',
        params: {'order_id': orderId},
        header: _header,
      );
      return _ok(data['data']);
    } catch (e) {
      return _err(e);
    }
  }

  // 获取订单列表（type: 1=nft, 2=ast）
  Future<MessageModel> getNftOrAstOrderList(
    int type,
    String uuid, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$_url/v1/nft-amt/order/list',
        params: {'type': type, 'uuid': uuid, 'page': page, 'page_size': pageSize},
        header: _header,
      );
      return _ok(data['data']['list']);
    } catch (e) {
      return _err(e);
    }
  }

  // 新增订单
  Future<MessageModel> postNftOrAstAddOrder(
    String bAddr,
    String bUuid,
    int astId,
    int type,
    double orderNumber,
  ) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '$_url/v1/nft-amt/add/order/v2',
        params: {},
        data: {
          'b_addr': bAddr,
          'b_uuid': bUuid,
          'nft_amt_id': astId,
          'type': type,
          'order_num': orderNumber,
        },
        header: _header,
      );
      if (data['code'] == 200) return _ok(data['data']);
      return MessageModel.error()..data = data['err'];
    } catch (e) {
      return _err(e);
    }
  }

  // 取消订单
  Future<MessageModel> postNftOrAstCancelOrder(
      String bUuid, int orderId) async {
    try {
      await BaseApi.requestEmptyH.post(
        '$_url/v1/nft-amt/cancel/order',
        params: {},
        data: {'b_uuid': bUuid, 'nft_amt_order_id': orderId},
        header: _header,
      );
      return _ok(true);
    } catch (e) {
      return _err(e);
    }
  }

  // 提交支付哈希
  Future<MessageModel> postNftOrAstCommitPay(
    String bUuid,
    int orderId,
    String txHash,
  ) async {
    try {
      await BaseApi.requestEmptyH.post(
        '$_url/v1/nft-amt/commit/pay/tx',
        params: {},
        data: {'b_uuid': bUuid, 'nft_amt_order_id': orderId, 'tx': txHash},
        header: _header,
      );
      return _ok(true);
    } catch (e) {
      return _err(e);
    }
  }
}
