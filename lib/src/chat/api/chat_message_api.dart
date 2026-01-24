import 'package:flutter/foundation.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/https/base_api.dart';

class ChatMessageApi {
  late String url;
  late Map<String, String> header;

  ChatMessageApi() {
    url = AppConfig.getApiUrl_online('userInfoHost');
    header = {'content-type': 'application/x-www-form-urlencoded'};
  }

  /// 根据用户email获取pub key
  Future getUserPubKey(String email) {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['email'] = email;
    return BaseApi.RequestEmpty_h
        .get('$url/v1/lr/file/getPubKeyByEmail', params: params, header: header);
  }

  /// 绑定用户公钥
  Future bindPubKey(String pubKey) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['pub_key'] = pubKey;
    try {
      final res = await BaseApi.RequestEmpty_h.post(
        '$url/v1/l/file/bindPubKey',
        params: {},
        data: params,
        header: header,
      );
      return res;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[ChatMessageApi] bindPubKey error: $err');
      }
      return null;
    }
  }

  /// 向其他用户发送文件
  Future sendFile({
    required String pubKey,
    required String r_email,
    required String s_aes_secret,
    required String r_aes_secret,
    required String file_type,
    required String file_uri,
    required String file_name,
    required String file_desc,
  }) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['r_email'] = r_email; // 接收者邮箱
    params['s_aes_secret'] = s_aes_secret; // 发送者秘文
    params['r_aes_secret'] = r_aes_secret; // 接收者秘文
    params['file_type'] = file_type; // 文件类型
    params['file_uri'] = file_uri; // 文件地址
    params['file_name'] = file_name;
    params['file_desc'] = file_desc;
    try {
      final res = await BaseApi.RequestEmpty_h.post(
        '$url/v1/l/file/send',
        params: {},
        data: params,
        header: header,
      );
      return res;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[ChatMessageApi] sendFile error: $err');
      }
      return null;
    }
  }

  /// 获取聊天列表
  Future getChatList({
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
      final res = await BaseApi.RequestEmpty_h.get(
        '$url/v1/lr/file/get/user/msg/index',
        params: params,
        header: header,
      );
      return res;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[ChatMessageApi] getChatList error: $err');
      }
      return null;
    }
  }

  /// 获取和某个人的聊天记录
  Future getChatMessageByUserEmail({
    required String otherUUID,
    required int pageIndex,
    required int pageSize,
  }) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['r_uid'] = otherUUID;
    params['s_uid'] = userId;
    params['source'] = 'app';
    params['uuid'] = userId;
    params['token'] = token;
    params['page'] = pageIndex;
    params['page_size'] = pageSize;
    try {
      final res = await BaseApi.RequestEmpty_h.get(
        '$url/v1/lr/file/get/user/msg/detail',
        params: params,
        header: header,
      );
      return res;
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[ChatMessageApi] getChatMessageByUserEmail error: $err');
      }
      return null;
    }
  }
}
