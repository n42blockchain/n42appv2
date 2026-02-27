import 'package:dio/dio.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/data/models/user_info.dart';

part 'user_info_api_security.dart';
part 'user_info_api_social.dart';

class UserInfoApi{
  late String url;
  late Map<String,String> header;
  UserInfoApi(){
    url=AppConfig.getApiUrlOnline('userInfoHost');
    header={'content-type': 'application/json'
    //'application/x-www-form-urlencoded'
    };
  }

  /// 邮箱登陆
  Future login(String email, String password, {Map<String, dynamic>? deviceInfo}) async {
    Map<String, dynamic> params = {};
    params["email"] = email;
    params["pwd"] = password;
    params["source"] = "app";
    if (deviceInfo != null) {
      params.addAll(deviceInfo);
    }
    final data =
    await BaseApi.requestEmptyH.post('$url/v1/user/loginEmail', params: {}, data: params,header: header);
    return data;
  }

  ///发送验证码
  /// type 必传 register 注册验 | resetPwd 重置密码
  Future sendEmailCode(String email, String type) async {
    Map params = {};
    params["email"] = email;
    params["type"] = type;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/user/sendEmailCode', params: {}, data: params,header: header);
    return data;
  }
  /// 邮箱注册
  /// inviteCode 邀请码（可选）
  Future registerEmail(String email, String password, String code,
      {String? inviteCode}) async {
    Map<String, dynamic> params = {};
    params["email"] = email;
    params["pwd"] = password;
    params["code"] = code;
    //params["invite"] = inviteCode;
    params["invite_code"] = inviteCode;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/user/registerEmail', params: {}, data: params,header: header);
    return data;
  }
  ///邮箱重置密码
  Future emailResetPwd(
      String email, String password, String code) async {
    Map<String, dynamic> params = {};
    params["email"] = email;
    params["pwd"] = password;
    params["code"] = code;
    final data = await BaseApi.requestEmptyH
        .post('$url/v1/user/emailResetPwd', params: {}, data: params,header: header);
    return data;
  }
  Future<MessageModel> updateUserInfo(Map<String,dynamic> userInfo)async{
    try{
      userInfo['uuid']=AppGlobals.userInfo?.uuid??"";
      userInfo['source']="app";
      userInfo['token']=AppGlobals.userInfo?.token??"";
      final formData = FormData.fromMap(userInfo);
      Map<String,String> headerV2={'content-type': 'multipart/form-data'};
      MessageModel mm=MessageModel();
      final data=await BaseApi.requestEmptyH.post(
        '$url/v1/l/user/info',
        params: {},
        data: formData,
        header: headerV2,
        addUserInfo: true
      );
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
  ///获取用户登陆信息
  Future<UserInfo?> getUserInfo(
      String uuid, String token, String code) async {
    Map<String, dynamic> params = {};
    params["uuid"] = uuid;
    params["token"] = token;
    params["source"] = "app";
    final data = await BaseApi.requestEmptyH.get(
        '$url/v1/r/user/getUserInfo',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      return UserInfo.fromJson(data["data"]);
    }
    return null;
  }
  //获取用户信息，根据uuid
  Future<MessageModel> getUserInfoWithUUID(String uuid,{String? chain})async{
    try{
      Map<String,dynamic> params={
        "uuid":uuid,
      };
      if(chain!=null){
        params['chain']=chain;
      }
      MessageModel mm=MessageModel();
      final data=await BaseApi.requestEmptyH.get('$url/v1/r/user/info', params: params,header: header);
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
}
