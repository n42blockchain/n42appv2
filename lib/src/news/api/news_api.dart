import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:flutter/foundation.dart';

///@author zhc 2023/2/13 11:21
///@description: 新闻api

class NewsApi {
  static const Map<String, String> _header = {'content-type': 'application/json'};

  /// 获取新闻列表
  Future<dynamic> newsList({
    required int skip,
    required int limit,
  }) async {
    final Map<String, dynamic> params = {
      "skip": skip * limit,
      "limit": limit,
    };
    try {
      final data = await BaseApi.requestEmptyH.post(
        '${AppConfig.apiUrl['newsHostUrl']}/newsList',
        params: {},
        data: params,
        header: _header,
      );
      return data;
    } catch (e) {
      debugPrint("NewsApi.newsList error: $e");
      return null;
    }
  }
}
