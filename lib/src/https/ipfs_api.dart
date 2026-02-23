import 'dart:convert';

import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/src/https/base_api.dart';
import 'package:dio/dio.dart';

class IpfsApi{
  //ipfs上传图片type 0文件地址上传，1 List<int>上传
  Future<Map<String, dynamic>> uploadIPFSImage(dynamic file, String filename, dynamic sendProgress, {int type = 0, CancelToken? cancelToken}) async {
    try{
      FormData fd=FormData.fromMap({"path":type==0?
      MultipartFile.fromFile(file,filename: filename):
      MultipartFile.fromBytes(file,filename: filename)});
      String username = AppConfig.ipfsUsername;
      String password = AppConfig.ipfsPassword;
      if (username.isEmpty || password.isEmpty) {
        return {"error": true, "data": "IPFS credentials not configured"};
      }
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      var data=await BaseApi.requestEmptyH.post(
        "${AppConfig.apiUrl['ipfsHost']}/ipfsapi/api/v0/add",
        params: {},
        data: fd,
        sendProgress: sendProgress,
        cancelToken: cancelToken,
        header:{
          'content-type': 'multipart/form-data',
          'Authorization':basicAuth
        },
      );
      if(data["Hash"]!=null){
        Map<String, dynamic> rData = {
          "Hash": data['Hash'],
          "Name": data['Name'],
          "Size": data['Size'],
        };
        return {"error":false,"data":rData};
      }else{
        return {"error":true,"data":"Error"};
      }
    }
    catch(e){
      return {"error":true,"data":e.toString()};
    }
  }
}