import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/network/base_api.dart';

class IpfsApi {
  // ipfs 上传图片：type 0 = 文件路径上传，1 = List<int> 字节上传
  Future<Map<String, dynamic>> uploadIPFSImage(
    dynamic file,
    String filename,
    dynamic sendProgress, {
    int type = 0,
    CancelToken? cancelToken,
  }) async {
    try {
      final String username = AppConfig.ipfsUsername;
      final String password = AppConfig.ipfsPassword;
      if (username.isEmpty || password.isEmpty) {
        return {'error': true, 'data': 'IPFS credentials not configured'};
      }

      final MultipartFile part = type == 0
          ? await MultipartFile.fromFile(file, filename: filename)
          : MultipartFile.fromBytes(file, filename: filename);

      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final data = await BaseApi.requestEmptyH.post(
        '${AppConfig.apiUrl['ipfsHost']}/ipfsapi/api/v0/add',
        params: {},
        data: FormData.fromMap({'path': part}),
        sendProgress: sendProgress,
        cancelToken: cancelToken,
        header: {
          'content-type': 'multipart/form-data',
          'Authorization': basicAuth,
        },
      );

      if (data['Hash'] != null) {
        return {
          'error': false,
          'data': {
            'Hash': data['Hash'],
            'Name': data['Name'],
            'Size': data['Size'],
          },
        };
      }
      return {'error': true, 'data': 'Error'};
    } catch (e) {
      return {'error': true, 'data': e.toString()};
    }
  }
}
