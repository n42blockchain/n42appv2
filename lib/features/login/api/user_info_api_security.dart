part of 'user_info_api.dart';

/// UserInfoApi 安全设置相关扩展
/// 包含：邮箱验证码、Google 2FA、修改邮箱/密码、注销账号
extension UserInfoApiSecurity on UserInfoApi {
  //获取支付验证码
  Future<MessageModel> getEmailVerification()async{
    try{
      Map<String,dynamic> postMap={
        "uuid":AppGlobals.userInfo?.uuid??"",
        "source":"app",
        "token":AppGlobals.userInfo?.token??"",
      };
      MessageModel mm=MessageModel();
      final data=await BaseApi.requestEmptyH.post('$url/v1/l/user/send/pay/email/code', params:{},data: postMap,header: header);
      if(data['code']==200){
        mm.data=true;
      }else{
        mm.error=true;
        mm.data=data['err'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //验证邮箱验证码
  Future<MessageModel> checkEmailVerification(String code)async{
    try{
      Map<String,dynamic> postMap={
        "uuid":AppGlobals.userInfo?.uuid??"",
        "code":code,
        "source":"app",
        "token":AppGlobals.userInfo?.token??"",
      };
      MessageModel mm=MessageModel();
      final data=await BaseApi.requestEmptyH.post('$url/v1/l/user/verify/pay/email/code', params:{},data: postMap,header: header);
      if(data['code']==200){
        mm.data=true;
      }else{
        mm.error=true;
        mm.data=data['err'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //绑定谷歌验证
  Future<MessageModel> bindGoogle()async{
    try{
      Map<String,dynamic> postMap={
        "uuid":AppGlobals.userInfo?.uuid??"",
        "source":"app",
        "token":AppGlobals.userInfo?.token??"",
      };
      MessageModel mm=MessageModel();
      final data=await BaseApi.requestEmptyH.post('$url/v1/l/user/bind/google/auth/code', params:{},data: postMap,header: header);
      if(data['code']==200){
        mm.data=data['data'];
      }else{
        mm.error=true;
        mm.data=data['err'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //验证谷歌验证
  Future<MessageModel> checkGoogle(String code)async{
    try{
      Map<String,dynamic> postMap={
        "uuid":AppGlobals.userInfo?.uuid??"",
        "code":code,
        "token":AppGlobals.userInfo?.token??"",
        "source":"app",
      };
      MessageModel mm=MessageModel();
      final data=await BaseApi.requestEmptyH.post('$url/v1/l/user/verify/google/auth/code', params:{},data: postMap,header: header);
      if(data['code']==200){
        mm.data=true;
      }else{
        mm.error=true;
        mm.data=data['err'];
      }
      return mm;
    }catch(e){
      MessageModel mm=MessageModel.error();
      mm.data=e.toString();
      return mm;
    }
  }
  //解绑谷歌验证（需要当前 TOTP 码验证身份）
  Future<MessageModel> unbindGoogle(String code) async {
    try {
      Map<String, dynamic> postMap = {
        "uuid": AppGlobals.userInfo?.uuid ?? "",
        "code": code,
        "token": AppGlobals.userInfo?.token ?? "",
        "source": "app",
      };
      MessageModel mm = MessageModel();
      final data = await BaseApi.requestEmptyH.post(
        '$url/v1/l/user/unbind/google/auth/code',
        params: {},
        data: postMap,
        header: header,
      );
      if (data['code'] == 200) {
        mm.data = true;
      } else {
        mm.error = true;
        mm.data = data['err'];
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }
  /// 修改邮箱（已登录用户）
  /// [newEmail] 新邮箱地址
  /// [code]     发送到新邮箱的 6 位验证码
  Future<MessageModel> changeEmail(String newEmail, String code) async {
    try {
      final Map<String, dynamic> params = {
        "uuid": AppGlobals.userInfo?.uuid ?? "",
        "token": AppGlobals.userInfo?.token ?? "",
        "source": "app",
        "new_email": newEmail,
        "code": code,
      };
      MessageModel mm = MessageModel();
      final data = await BaseApi.requestEmptyH.post(
        '$url/v1/l/user/change/email',
        params: {},
        data: params,
        header: header,
      );
      if (data['code'] == 200) {
        mm.data = true;
      } else {
        mm.error = true;
        mm.data = data['err'] ?? 'Change email failed';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  /// 修改密码（已登录用户，需要原密码）
  /// oldPassword: 原密码（MD5 哈希后）
  /// newPassword: 新密码（MD5 哈希后）
  Future<MessageModel> changePassword(String oldPassword, String newPassword) async {
    try {
      Map<String, dynamic> params = {
        "uuid": AppGlobals.userInfo?.uuid ?? "",
        "token": AppGlobals.userInfo?.token ?? "",
        "source": "app",
        "old_pwd": oldPassword,
        "new_pwd": newPassword,
      };
      MessageModel mm = MessageModel();
      final data = await BaseApi.requestEmptyH.post(
        '$url/v1/l/user/change/password',
        params: {},
        data: params,
        header: header,
      );
      if (data['code'] == 200) {
        mm.data = true;
      } else {
        mm.error = true;
        mm.data = data['err'] ?? 'Change password failed';
      }
      return mm;
    } catch (e) {
      MessageModel mm = MessageModel.error();
      mm.data = e.toString();
      return mm;
    }
  }

  ///用户注销时 发送email code
  Future sendUnRegisterEmailCode() async {
    final formData = FormData.fromMap({
      'uuid': AppGlobals.userInfo?.uuid??"",
      'token': AppGlobals.userInfo?.token??"",
      'source': 'app',
    });
    Map<String,String> headerV2={'content-type': 'multipart/form-data'};
    final data = await BaseApi.requestEmptyH.post(
        '$url/v1/l/user/send/account/cancel/email/code',
        params: {},
        data: formData,header: headerV2);
    return data;
  }
  ///注销用户账号
  Future unRegisterAccount(String code) async {
    Map<String, dynamic> params = {};
    params["code"] = code;
    params["token"] = AppGlobals.userInfo?.token??"";
    params["uuid"] = AppGlobals.userInfo?.uuid??"";
    params["source"] = "app";
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/l/user/account/cancel', params: {}, data: params,header: header);
    return data;
  }
}
