import 'dart:convert';
import 'dart:io';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/home/models/version_info_model.dart';
import 'package:n42_wallet/src/https/base_api.dart';

class VersionApi {
  final String url;
  final Map<String, String> header;

  VersionApi()
      : url = AppConfig.getApiUrlOnline('userInfoHost'),
        header = const {'content-type': 'application/json'};

  /// 最新版本信息
  Future<VersionInfoModel?> getVersionInfo() async {
    final params = {
      'source': 'app',
      'app': Platform.isIOS ? 'ios' : 'android',
    };
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$url/v1/r/static/app/version',
        params: params,
        header: header,
      );
      if (data['code'] == 200 && data['data'] != null) {
        final raw = data['data'];
        // 兼容两种后端返回格式：
        //   1) data['data'] 已是 Map（Dio 自动反序列化）
        //   2) data['data'] 是 JSON 字符串（后端将 JSON 包在字符串里）
        final Map<String, dynamic> map = raw is String
            ? json.decode(raw) as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        return VersionInfoModel.fromJson(map);
      }
    } catch (_) {
      // 版本检查失败不应影响 App 正常使用
    }
    return null;
  }
}
