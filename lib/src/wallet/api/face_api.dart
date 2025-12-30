import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:dio/dio.dart';

class FaceApi{
  late String url;
  late Map<String,String> header;
  FaceApi(){
    url=AppConfig.apiUrl['face'];//'http://192.168.31.119:2000';
    header={'content-type': 'application/x-www-form-urlencoded'};
  }
  binding(String address,var file,String filename,{int type=0})async{
    try{
      MessageModel mm = MessageModel();
      MultipartFile f;
      if(type==0){
        f=await MultipartFile.fromFile(file,filename: filename);
      }else{
        f=await MultipartFile.fromBytes(file,filename: filename);
      }
      FormData fd=FormData.fromMap({"face":f,"address":address,});
      var data=await BaseApi.RequestEmpty_h.post(
        '${url}/address_upload_face',
        params: {},
        data: fd,
        header:header,
        addUserInfo: true,
      );
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel rmm=MessageModel.error();
      rmm.data=e.toString();
      return rmm;
    }
  }
  match(var file,String filename,{int type=0})async{
    try{
      MessageModel mm = MessageModel();
      MultipartFile f;
      if(type==0){
        f=await MultipartFile.fromFile(file,filename: filename);
      }else{
        f=await MultipartFile.fromBytes(file,filename: filename);
      }
      FormData fd=FormData.fromMap({"face":f});
      var data=await BaseApi.RequestEmpty_h.post(
        '${url}/detect_face',
        params: {},
        data: fd,
        header:header,
        addUserInfo: true,
      );
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel rmm=MessageModel.error();
      rmm.data=e.toString();
      return rmm;
    }
  }
  deleteBinding(String address)async{
    try{
      MessageModel mm = MessageModel();
      var data=await BaseApi.RequestEmpty_h.delete(
        '${url}/delete_face',
        params: {
          "address":address
        },
        data: {
          "address":address
        },
        header:header,
        addUserInfo: true,
      );
      mm.data=data;
      return mm;
    }catch(e){
      MessageModel rmm=MessageModel.error();
      rmm.data=e.toString();
      return rmm;
    }
  }
}
