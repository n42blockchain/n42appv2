import 'dart:convert';
import 'dart:io';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class IpfsApi{
  late Map<String,String> header;
  IpfsApi(){
    header={
      'content-type': 'multipart/form-data',
      //"Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDU2MkVGMjZjNENFZjQ3MWU2NUQ0MDY5QWQxRUYwNkQ1OUQ3MDI4QWUiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTY5ODIyMjI2OTUzOCwibmFtZSI6IkFtYXplV2FsbGV0In0.WC8LluNV06Burx-Uscv4ovQYgVOknUetAq718A4Xl1g",
    };
  }
  //获取ipfs图片信息
  getIPFSImageInfo(String uri)async{
    try{
      var data=await BaseApi.RequestEmpty_h.get(uri, params: {});
      return {"error":false,"data":data};
    }
    catch(e){
      return {"error":true,"data":e};
    }
  }
  getIPFSImage(String uri)async{
    try{
      Dio d=Dio();
      Response r=await d.get(uri);
      if (r.statusCode == 200 || r.statusCode == 201 || r.statusCode == 202){
        return {"error":false,"data":true};
      }else{
        return {"error":true,"data":"statusCode:${r.statusCode}"};
      }

    }catch(e){
      return {"error":true,"data":e.toString()};
    }

  }
  //ipfs上传图片type 0文件地址上传，1 List<int>上传
  uploadIPFSImage(var file,String filename,dynamic sendProgress,{int type=0,var cancelToken})async{
    try{
      FormData fd=FormData.fromMap({"path":type==0?
      MultipartFile.fromFile(file,filename: filename):
      MultipartFile.fromBytes(file,filename: filename)});
      String username = 'n42';
      String password = 'Z,p7=f#|q5JkmeyL';
      String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      var data=await BaseApi.RequestEmpty_h.post(
        //"${AppConfig.apiUrl['ipfsHost']}/upload",///ipfs/api/v0/add
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
      /*
      if(data["ok"]==true){
        return {"error":false,"data":data['value']['cid']};
      }else{
        return {"error":true,"data":data['error']['message']};
      }*/
    }
    catch(e){
      return {"error":true,"data":e.toString()};
    }
  }
  //上传图片信息
  uploadIPFSImageInfo(Map<String,dynamic> map,String filename)async{
    try{
      MultipartFile f=MultipartFile.fromString(json.encode(map),filename: filename);
      FormData fd=FormData.fromMap({"file":f});
      var data=await BaseApi.RequestEmpty_h.post(
        "${AppConfig.apiUrl['ipfsHost']}/upload",
        //"${getUrl('ipfs')}v0/add?stream-channels=false&progress=false",
        params: {},data: fd,
        header:header,
      );
      if(data["ok"]==true){
        return {"error":false,"data":data['value']['cid']};
      }else{
        return {"error":true,"data":data['error']['message']};
      }
    }
    catch(e){
      return {"error":true,"data":e.toString()};
    }
  }

  ///下载文件
  Future downLoadFile(String urlPath, String savePath,
      {bool showError = false, ProgressCallback? receiveProgress}) async {
    try {
      var dio = Dio(BaseOptions(
        connectTimeout: Duration(milliseconds: 10000),
        receiveTimeout: Duration(milliseconds: 5000),
      ));
      // 配置 HttpClientAdapter 来忽略 SSL 证书验证
      dio.httpClientAdapter = IOHttpClientAdapter()..createHttpClient=(){
        HttpClient client=HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true; // // 总是返回 true，表示信任所有证书
        return client;
      };
      var response = await dio.download(urlPath, savePath,
          onReceiveProgress: receiveProgress);
      var data = response.data;
      if (data != null && data.statusCode == 200) {
        return true;
      } else {
        throw '文件下载失败';
      }
    } catch (error) {
      //const errorInfo = '文件下载失败';
      rethrow;
    }
  }
}