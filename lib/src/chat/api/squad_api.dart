import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

class SquadApi {
  late String url;
  late Map<String, String> header;

  SquadApi() {
    url = AppConfig.getApiUrlOnline('userInfoHost');
    header = {'content-type': 'application/json'};
  }

  /// 根据用户email获取pub key
  Future<MessageModel> getUserPubKey(String email) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['email'] = email;
    final rData = await BaseApi.requestEmptyH.get(
      '$url/v1/lr/file/getPubKeyByEmail',
      params: params,
      header: header,
    );
    MessageModel mm = MessageModel();
    if (rData != null) {
      if (rData["code"] == 200) {
        mm.data = rData["data"];
      } else if (rData["code"] == -1403) {
        mm.data = rData['err'];
        mm.type = MessageErrorType.E1403;
        mm.error = true;
      } else {
        mm.data = rData['err'];
        mm.error = true;
      }
    } else {
      mm.error = true;
      mm.data = "Error";
    }
    return mm;
  }

  /// 绑定用户公钥
  Future<MessageModel> bindPubKey(String pubKey) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['pub_key'] = pubKey;
    final formData = FormData.fromMap(params);
    MessageModel mm = MessageModel();

    try {
      final rData = await BaseApi.requestEmptyH.post(
        '$url/v1/l/file/bindPubKey',
        params: {},
        data: formData,
        header: header,
        addUserInfo: true,
      );
      if (rData != null) {
        if (rData["code"] == 200) {
          mm.data = "True";
        } else if (rData["code"] == -1403) {
          mm.data = rData['err'];
          mm.type = MessageErrorType.E1403;
          mm.error = true;
        } else {
          mm.data = rData['err'];
          mm.error = true;
        }
      } else {
        mm.error = true;
        mm.data = "Error";
      }
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[SquadApi] bindPubKey error: $err');
      }
      mm.error = true;
      mm.data = err.toString();
    }
    return mm;
  }

  /// 向其他用户发送文件
  Future<dynamic> sendFile({
    required String pubKey,
    required String rEmail,
    required String sAesSecret,
    required String rAesSecret,
    required String fileType,
    required String fileUri,
    required String fileName,
    required String fileDesc,
  }) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['r_email'] = rEmail; // 接收者邮箱
    params['s_aes_secret'] = sAesSecret; // 发送者秘文
    params['r_aes_secret'] = rAesSecret; // 接收者秘文
    params['file_type'] = fileType; // 文件类型
    params['file_uri'] = fileUri; // 文件地址
    params['file_name'] = fileName;
    params['file_desc'] = fileDesc;
    try {
      final res = await BaseApi.requestEmptyH.post(
        '$url/v1/l/file/send',
        params: {},
        data: params,
        header: header,
      );
      return res;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[SquadApi] sendFile error: $err');
      }
      return null;
    }
  }

  /// 获取用户发送列表
  Future<dynamic> sendFileList({
    required int pageIndex,
    required int pageSize,
  }) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['page'] = pageIndex;
    params['page_size'] = pageSize;
    try {
      final res = await BaseApi.requestEmptyH.get(
        '$url/v1/lr/file/getSendList',
        params: params,
        header: header,
      );
      return res;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[SquadApi] sendFileList error: $err');
      }
      return null;
    }
  }

  /// 获取用户接收列表
  Future<dynamic> receiveFileList({
    required int pageIndex,
    required int pageSize,
  }) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['page'] = pageIndex;
    params['page_size'] = pageSize;
    try {
      final res = await BaseApi.requestEmptyH.get(
        '$url/v1/lr/file/getRecvList',
        params: params,
        header: header,
      );
      return res;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[SquadApi] receiveFileList error: $err');
      }
      return null;
    }
  }

  /// 文件删除
  Future<dynamic> deleteFile(String fileId) {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['id'] = fileId;
    return BaseApi.requestEmptyH.post(
      '$url/v1/l/file/del',
      params: {},
      data: params,
      header: header,
    );
  }
}
