import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';

class ActivityApi {
  final String url = AppConfig.getApiUrlOnline('activiteHost');
  static const Map<String, String> _header = {'content-type': 'application/json'};

  // 将 POST 请求结果统一转换为 MessageModel，消除两个方法的重复逻辑
  Future<MessageModel> _post(String path, Map<String, dynamic> body) async {
    try {
      final data = await BaseApi.requestEmptyH.post(
        '$url$path',
        params: {},
        data: body,
        header: _header,
      );
      if (data['code'] == 200) {
        return MessageModel()..data = true;
      }
      return MessageModel()
        ..error = true
        ..data = data['err'];
    } catch (e) {
      return MessageModel.error()..data = e.toString();
    }
  }

  // 数据收集接口，发送推送
  Future<MessageModel> collectDelayPush(
    String nftData, {
    String event = 'create_nft',
  }) {
    return _post('/w/collect/delay/push', {'event': event, 'data': nftData});
  }

  // 数据收集接口，修改用户创建的 NFT
  Future<MessageModel> collectPushUpdate(Map<String, dynamic> nftData) {
    return _post('/w/collect/update', nftData);
  }
}
