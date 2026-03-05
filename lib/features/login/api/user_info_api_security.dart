part of 'user_info_api.dart';

extension UserInfoApiSecurity on UserInfoApi {
  Map<String, dynamic> get _authParams => {
        "uuid": AppGlobals.userInfo?.uuid ?? "",
        "source": "app",
        "token": AppGlobals.userInfo?.token ?? "",
      };

  Future<MessageModel> _postWithAuth(String path, {Map<String, dynamic>? extra, bool dataField = false}) async {
    try {
      final postMap = {..._authParams, if (extra != null) ...extra};
      final mm = MessageModel();
      final data = await BaseApi.requestEmptyH.post('$url$path', params: {}, data: postMap, header: header);
      if (data['code'] == 200) {
        mm.data = dataField ? data['data'] : true;
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

  Future<MessageModel> getEmailVerification() async {
    return _postWithAuth('/v1/l/user/send/pay/email/code');
  }

  Future<MessageModel> checkEmailVerification(String code) async {
    return _postWithAuth('/v1/l/user/verify/pay/email/code', extra: {"code": code});
  }

  Future<MessageModel> bindGoogle() async {
    return _postWithAuth('/v1/l/user/bind/google/auth/code', dataField: true);
  }

  Future<MessageModel> checkGoogle(String code) async {
    return _postWithAuth('/v1/l/user/verify/google/auth/code', extra: {"code": code});
  }

  Future<MessageModel> unbindGoogle(String code) async {
    return _postWithAuth('/v1/l/user/unbind/google/auth/code', extra: {"code": code});
  }
  Future<MessageModel> changeEmail(String newEmail, String code) async {
    return _postWithAuth('/v1/l/user/change/email', extra: {"new_email": newEmail, "code": code});
  }

  Future<MessageModel> changePassword(String oldPassword, String newPassword) async {
    return _postWithAuth('/v1/l/user/change/password', extra: {"old_pwd": oldPassword, "new_pwd": newPassword});
  }

  Future sendUnRegisterEmailCode() async {
    final formData = FormData.fromMap({
      'uuid': AppGlobals.userInfo?.uuid ?? "",
      'token': AppGlobals.userInfo?.token ?? "",
      'source': 'app',
    });
    const headerV2 = {'content-type': 'multipart/form-data'};
    return BaseApi.requestEmptyH.post(
      '$url/v1/l/user/send/account/cancel/email/code',
      params: {},
      data: formData,
      header: headerV2,
    );
  }

  Future unRegisterAccount(String code) async {
    return BaseApi.requestEmptyH.post(
      '$url/v1/l/user/account/cancel',
      params: {},
      data: {..._authParams, "code": code},
      header: header,
    );
  }
}
