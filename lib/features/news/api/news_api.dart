import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:flutter/foundation.dart';

class NewsApi {
  static const Map<String, String> _header = {
    'content-type': 'application/json',
  };

  Future<dynamic> newsList({
    required int skip,
    required int limit,
  }) async {
    try {
      return await BaseApi.requestEmptyH.post(
        '${AppConfig.apiUrl['newsHostUrl']}/newsList',
        params: {},
        data: {"skip": skip * limit, "limit": limit},
        header: _header,
      );
    } catch (e) {
      debugPrint("NewsApi.newsList error: $e");
      return null;
    }
  }
}
