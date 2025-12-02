import 'dart:convert';

import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/models/user_info.dart';

class UserInfoApi{
  late String url;
  late Map<String,String> header;
  UserInfoApi(){
    url=AppConfig.getApiUrl_online('userInfoHost');
    header={'content-type': 'application/json'
    //'application/x-www-form-urlencoded'
    };
  }

  /// 邮箱登陆
  Future login(String email, String password) async {
    Map params = {};
    params["email"] = email;
    params["pwd"] = password;
    params["source"] = "app";
    final data =
    await BaseApi.RequestEmpty_h.post('${url}/v1/user/loginEmail', params: {}, data: params,header: header);
    return data;
  }
  //获取支付验证码
  getEmailVerification()async{
    try{
      Map<String,dynamic> postMap={
        "uuid":Application.userInfo?.uuid??"",
        "source":"app",
        "token":Application.userInfo?.token??"",
      };
      MessageModel mm=MessageModel();
      final data=await BaseApi.RequestEmpty_h.post('${url}/v1/l/user/send/pay/email/code', params:{},data: postMap,header: header);
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
  checkEmailVerification(String code)async{
    try{
      Map<String,dynamic> postMap={
        "uuid":Application.userInfo?.uuid??"",
        "code":code,
        "source":"app",
        "token":Application.userInfo?.token??"",
      };
      MessageModel mm=MessageModel();
      final data=await BaseApi.RequestEmpty_h.post('${url}/v1/l/user/verify/pay/email/code', params:{},data: postMap,header: header);
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

  //获取邀请人code
  Future getInviterCode(
      String mobileModel, String mobileName, String os) async {
    Map<String, dynamic> params = {};
    params["mobile_model"] = mobileModel;
    params["mobile_name"] = mobileName;
    params["os"] = os;
    final data = await BaseApi.RequestEmpty_h.get(
        '${url}/v1/r/user/inviter/code',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data['data'];
    }
    return null;
  }
  ///用户注销时 发送email code
  Future sendUnRegisterEmailCode() async {
    Map params = {};
    params["uuid"] = Application.userInfo?.uuid??"";
    params["token"] = Application.userInfo?.token??"";
    params["source"] = "app";
    final data = await BaseApi.RequestEmpty_h.post(
        '${url}/v1/l/user/send/account/cancel/email/code',
        params: {},
        data: params,header: header);
    return data;
  }
  ///发送验证码
  /// type 必传 register 注册验 | resetPwd 重置密码
  Future sendEmailCode(String email, String type) async {
    Map params = {};
    params["email"] = email;
    params["type"] = type;
    final data = await BaseApi.RequestEmpty_h
        .post('${url}/v1/user/sendEmailCode', params: {}, data: params,header: header);
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
    final data = await BaseApi.RequestEmpty_h
        .post('${url}/v1/user/registerEmail', params: {}, data: params,header: header);
    return data;
  }
  ///邮箱重置密码
  Future emailResetPwd(
      String email, String password, String code) async {
    Map<String, dynamic> params = {};
    params["email"] = email;
    params["pwd"] = password;
    params["code"] = code;
    final data = await BaseApi.RequestEmpty_h
        .post('${url}/v1/user/emailResetPwd', params: {}, data: params,header: header);
    return data;
  }
  updateUserInfo(Map<String,dynamic> userInfo)async{
    try{
      userInfo['uuid']=Application.userInfo?.uuid??"";
      userInfo['source']="app";
      userInfo['token']=Application.userInfo?.token??"";
      MessageModel mm=MessageModel();
      final data=await BaseApi.RequestEmpty_h.post(
        '${url}/v1/l/user/info',
        params: {},
        data: userInfo,
        header: header,
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
  ///注销用户账号
  Future unRegisterAccount(String code) async {
    Map<String, dynamic> params = {};
    params["code"] = code;
    params["token"] = Application.userInfo?.token??"";
    params["uuid"] = Application.userInfo?.uuid??"";
    params["source"] = "app";
    final data = await BaseApi.RequestEmpty_h
        .post('${url}/v1/l/user/account/cancel', params: {}, data: params,header: header);
    return data;
  }
  //获取邀请用户，挖矿收益
  Future getInviteeMiningInfo(String uuid)async{
    Map<String, dynamic> params = {
      "uuid": uuid,
    };
    final data = await BaseApi.RequestEmpty_h.get(
        '${url}/v1/r/user/invitee/mining/fullnode',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data["data"];
    }
    return null;
  }
  Future getInviteeMiningCount(String uuid)async{
    Map<String, dynamic> params = {
      "uuid": uuid,
    };
    final data = await BaseApi.RequestEmpty_h.get(
        '${url}/v1/r/user/invitee/mining',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data["data"];
    }
    return null;
  }
  //获取邀请用户，下载app的数量
  Future getInviteeDownloadList(String uuid,
      {int pagenum= 1, int pagesize= 1}) async {
    Map<String, dynamic> params = {
      "uuid": uuid,
      "page_size": pagesize,
      "page_num": pagenum,
    };
    final data = await BaseApi.RequestEmpty_h.get(
        '${url}/v1/r/user/invitee/list/download',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data["data"];
    }
    return null;
  }
  //获取用户邀请的人数
  Future getInviteeList(String uuid) async {
    Map<String, dynamic> params = {};
    params["uuid"] = uuid;
    final data = await BaseApi.RequestEmpty_h.get(
        '${url}/v1/r/user/invitee/list',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      //success
      return data["data"];
    }
    return null;
  }
  //提交反馈信息,address钱包地址，content反馈内容，extra附件地址
  submitFeedback(String address,String content,String extra)async{
    try{
      String token=Application.userInfo?.token??"";
      String uuid=Application.userInfo?.uuid??"";
      MessageModel mm=MessageModel();
      Map<String,dynamic> dt={
        "uuid": uuid,
        "source": "app",
        "token": token,
        "wallet_addr":address,
        "content": content,
        "extra":extra,
      };

      mm.data=await BaseApi.RequestEmpty_h.post('${url}/v1/l/feedback',params: {},data:dt ,header: header,addUserInfo: true);
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
    final data = await BaseApi.RequestEmpty_h.get(
        '${url}/v1/r/user/getUserInfo',
        params: params,header: header
    );
    if (data["code"] == 200 && data["data"] != null) {
      return UserInfo.fronJson(data["data"]);
    }
    return null;
  }
  //获取用户信息，根据uuid
  getUserInfoWithUUID(String uuid,{String? chain})async{
    try{
      Map<String,dynamic> params={
        "uuid":uuid,
      };
      if(chain!=null){
        params['chain']=chain;
      }
      MessageModel mm=MessageModel();
      final data=await BaseApi.RequestEmpty_h.get('${url}/v1/r/user/info', params: params,header: header);
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
  //获取 消息列表
  getMsgNoticeList({int page=1,int pageSize=10,String msgType=""})async{
    try {
      MessageModel mm = MessageModel();
      final data =
      await BaseApi.RequestEmpty_h.get('${url}/v1/lr/get/msg/notice/list', params: {
        "uuid":Application.userInfo?.uuid??"",
        "page":page,
        "page_size":pageSize,
        "msg_type":msgType,
        "token":Application.userInfo?.token??"",
        "source":"app"
      },header: header);
      if (data['code'] == 200) {
        mm.data = data['data'];
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
  //绑定谷歌验证
  bindGoogle()async{
    try{
      Map<String,dynamic> postMap={
        "uuid":Application.userInfo?.uuid??"",
        "source":"app",
        "token":Application.userInfo?.token??"",
      };
      MessageModel mm=MessageModel();
      final data=await BaseApi.RequestEmpty_h.post('${url}/v1/l/user/bind/google/auth/code', params:{},data: postMap,header: header);
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
  checkGoogle(String code)async{
    try{
      Map<String,dynamic> postMap={
        "uuid":Application.userInfo?.uuid??"",
        "code":code,
        "token":Application.userInfo?.token??"",
        "source":"app",
      };
      MessageModel mm=MessageModel();
      final data=await BaseApi.RequestEmpty_h.post('${url}/v1/l/user/verify/google/auth/code', params:{},data: postMap,header: header);
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
  ///FCM推送绑定设备 token
  Future bindPushUserToken(String pushToken) async {
    Map params = {};
    params["firebase_token"] = pushToken;
    params["uuid"] = Application.userInfo?.uuid??"";
    params["token"] = Application.userInfo?.token??"";
    params["source"] = "app";
    final data = await BaseApi.RequestEmpty_h.post(
        '${url}/v1/l/file/bind/firebase/token',
        params: {},
        data: params,header: header
    );
    return data;
  }
}