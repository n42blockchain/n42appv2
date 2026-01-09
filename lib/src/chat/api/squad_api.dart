import 'package:dio/dio.dart';
import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';

class SquadApi {
  late String url;
  late Map<String,String> header;
  SquadApi(){
    url=AppConfig.getApiUrl_online('userInfoHost');
    header={'content-type': 'application/json'};
    //header={'content-type': 'application/x-www-form-urlencoded'};
  }
  //根据用户email获取pub key
  Future<MessageModel> getUserPubKey(String email) async{
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['email'] = email;
    final rData=await BaseApi.RequestEmpty_h.get('${url}/v1/lr/file/getPubKeyByEmail', params: params,header: header);
    MessageModel mm=MessageModel();
    if(rData !=null){
      if (rData["code"] == 200) {
        mm.data=rData["data"];
      }else if(rData["code"] == -1403){
        mm.data=rData['err'];
        mm.type=MessageErrorType.E1403;
        mm.error=true;
      }else{
        mm.data=rData['err'];
        mm.error=true;
      }
    }else{
      mm.error=true;
      mm.data="Error";
    }
    return mm;
  }

  //绑定用户公钥
  Future bindPubKey(String pubKey) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String,dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['pub_key'] = pubKey;
    final formData = FormData.fromMap(params);
    MessageModel mm=MessageModel();

    try {
      final rData = await BaseApi.RequestEmpty_h
          .post('${url}/v1/l/file/bindPubKey', params: {}, data: formData,header: header,addUserInfo: true);
      if(rData !=null){
        if (rData["code"] == 200) {
          mm.data="True";
        }else if(rData["code"] == -1403){
          mm.data=rData['err'];
          mm.type=MessageErrorType.E1403;
          mm.error=true;
        }else{
          mm.data=rData['err'];
          mm.error=true;
        }
      }else{
        mm.error=true;
        mm.data="Error";
      }
    } catch (err) {
      mm.error=true;
      mm.data=err.toString();
    }
    return mm;
  }

  //向其他用户发送文件
  Future sendFile(
      {required String pubKey,
        required String r_email,
        required String s_aes_secret,
        required String r_aes_secret,
        required String file_type,
        required String file_uri,
        required String file_name,
        required String file_desc}) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String,dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['r_email'] = r_email; //接收者邮箱
    params['s_aes_secret'] = s_aes_secret; //发送着秘文
    params['r_aes_secret'] = r_aes_secret; //接收者秘文
    params['file_type'] = file_type; //文件类型
    params['file_uri'] = file_uri; //文件地址
    params['file_name'] = file_name;
    params['file_desc'] = file_desc;
    try {
      final res =
      await BaseApi.RequestEmpty_h.post('${url}/v1/l/file/send', params: {}, data: params,header: header);
      return res;
    } catch (err) {
    }
    return null;
  }

//获取用户发送列表
  Future sendFileList(
      {required int pageIndex, required int pageSize}) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['page'] = pageIndex;
    params['page'] = pageIndex;
    params['page_size'] = pageSize;
    try {
      final res = await BaseApi.RequestEmpty_h.get(
          '${url}/v1/lr/file/getSendList',
          params: params,header: header
      );
      // debugPrint("sendFileList res: $res");
      return res;
    } catch (err) {
    }
    return null;
  }

  //获取用户接收列表
  Future receiveFileList(
      {required int pageIndex, required int pageSize}) async {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['page'] = pageIndex;
    params['page'] = pageIndex;
    params['page_size'] = pageSize;
    try {
      final res = await BaseApi.RequestEmpty_h.get(
          '${url}/v1/lr/file/getRecvList',
          params: params,header: header
      );
      // debugPrint("receiveFileList res: $res");
      return res;
    } catch (err) {
    }
    return null;
  }

  //文件删除
  Future deleteFile(String fileId) {
    final userId = AppGlobals.userInfo?.uuid;
    final token = AppGlobals.userInfo?.token;
    Map<String, dynamic> params = {};
    params['uuid'] = userId;
    params['token'] = token;
    params['source'] = 'app';
    params['id'] = fileId;
    return BaseApi.RequestEmpty_h.post('${url}/v1/l/file/del', params: {}, data: params,header: header);
  }
}