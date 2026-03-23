import 'package:dio/dio.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/data/models/user_info.dart';

part 'user_info_api_security.dart';
part 'user_info_api_social.dart';

class UserInfoApi {
  late final String url = AppConfig.getApiUrlOnline('userInfoHost');
  final Map<String, String> header = const {'content-type': 'application/json'};

  Future login(String email, String password, {Map<String, dynamic>? deviceInfo}) async {
    final Map<String, dynamic> params = {
      "email": email,
      "pwd": password,
      "source": "app",
    };
    if (deviceInfo != null) params.addAll(deviceInfo);
    return BaseApi.requestEmptyH.post('$url/v1/user/loginEmail', params: {}, data: params, header: header);
  }

  Future sendEmailCode(String email, String type) async {
    return BaseApi.requestEmptyH.post(
      '$url/v1/user/sendEmailCode',
      params: {},
      data: {"email": email, "type": type},
      header: header,
    );
  }

  Future registerEmail(String email, String password, String code, {String? inviteCode}) async {
    return BaseApi.requestEmptyH.post(
      '$url/v1/user/registerEmail',
      params: {},
      data: {"email": email, "pwd": password, "code": code, "invite_code": inviteCode},
      header: header,
    );
  }

  Future emailResetPwd(String email, String password, String code) async {
    return BaseApi.requestEmptyH.post(
      '$url/v1/user/emailResetPwd',
      params: {},
      data: {"email": email, "pwd": password, "code": code},
      header: header,
    );
  }
  Future<MessageModel> updateUserInfo(Map<String, dynamic> userInfo) async {
    try {
      userInfo['uuid'] = AppGlobals.userInfo?.uuid ?? "";
      userInfo['source'] = "app";
      userInfo['token'] = AppGlobals.userInfo?.token ?? "";
      final formData = FormData.fromMap(userInfo);
      const headerV2 = {'content-type': 'multipart/form-data'};
      final mm = MessageModel();
      final data = await BaseApi.requestEmptyH.post(
        '$url/v1/l/user/info',
        params: {},
        data: formData,
        header: headerV2,
        addUserInfo: true,
      );
      if (data['code'] == 200) {
        mm.data = true;
      } else {
        mm.error = true;
        mm.data = data['err'];
      }
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  Future<UserInfo?> getUserInfo(String uuid, String token, String code) async {
    final data = await BaseApi.requestEmptyH.get(
      '$url/v1/r/user/getUserInfo',
      params: {"uuid": uuid, "token": token, "source": "app"},
      header: header,
    );
    if (data["code"] == 200 && data["data"] != null) {
      return UserInfo.fromJson(data["data"]);
    }
    return null;
  }

  Future<MessageModel> getUserInfoWithUUID(String uuid, {String? chain}) async {
    try {
      final Map<String, dynamic> params = {"uuid": uuid};
      if (chain != null) params['chain'] = chain;
      final mm = MessageModel();
      final data = await BaseApi.requestEmptyH.get('$url/v1/r/user/info', params: params, header: header);
      if (data['code'] == 200) {
        mm.data = data['data'];
      } else {
        mm.error = true;
        mm.data = data['err'];
      }
      return mm;
    } catch (e) {
      final mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
}
