import 'dart:convert';
import 'dart:io';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/https/base_api.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class FileApi {
  late String url;
  late Map<String,String> header;
  FileApi(){
    url=AppConfig.getApiUrlOnline('ipfsHost');
    header={'content-type': 'multipart/form-data',
      //"Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDU2MkVGMjZjNENFZjQ3MWU2NUQ0MDY5QWQxRUYwNkQ1OUQ3MDI4QWUiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTY5ODIyMjI2OTUzOCwibmFtZSI6IkFtYXplV2FsbGV0In0.WC8LluNV06Burx-Uscv4ovQYgVOknUetAq718A4Xl1g",
    };
  }
  ///下载文件
  Future<dynamic> downLoadFile(String urlPath, String savePath,
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
      rethrow;
    }
  }

  /// -------使用ipfs文件上传-------------

  //ipfs文件上传
  Future<Map<String, dynamic>?> upLoadFileToIpfs(String filePath, ProgressCallback? sendProgress,
      {int type = 0, CancelToken? cancelToken}) async {
    try {
      MultipartFile f = await MultipartFile.fromFile(
        filePath,
      );
      //String fileName = f.filename!;
      FormData fd = FormData.fromMap({"path": f});
      var data = await BaseApi.requestEmptyH.post(
        "$url/ipfsapi/api/v0/add",
        //"${AppConfig.apiUrl['ipfsHost']}/upload",
        params: {},
        data: fd,
        //sendProgress: sendProgress,
        //cancelToken: cancelToken,
        header: header,
      );
      if(data["Hash"]!=null){
        Map<String, dynamic> rData = {
          "Hash": data['Hash'],
          "Name": data['Name'],
          "Size": data['size'],
        };
        return {"error":false,"data":rData};
      }else{
        return {"error":true,"data":"Error"};
      }
      /*
      if (data["ok"] == true) {
        Map<String, dynamic> rData = {
          "Hash": data['value']['cid'],
          "Name": fileName,
          "Size": data['value']['size'],
        };
        return rData;
      } else {
        return null;
      }*/
    } catch (e) {
      return null;
    }
  }

  String generateUrl(String ipfsHash, String fileName) {
    return "${AppConfig.apiUrl['ipfsAddress']}$ipfsHash";
  }

  //上传message 到ipfs
  Future<Map<String, dynamic>> uploadMessageToIpfs(Map<String, dynamic> map) async {
    try {
      MultipartFile f = MultipartFile.fromString(json.encode(map),
          filename: "squad_message.json");
      FormData fd = FormData.fromMap({"file": f});
      var data = await BaseApi.requestEmptyH.post(
        "$url/ipfsapi/api/v0/add",
        //"${getUrl('ipfs')}v0/add?stream-channels=false&progress=false",
        params: {}, data: fd,header: header,
      );
      if(data["Hash"]!=null){
        Map<String, dynamic> rData = {
          "Hash": data['Hash'],
          "Name": 'squad_message.json',
          "Size": data['size'],
        };
        return {"error":false,"data":rData};
      }else{
        return {"error":true,"data":"Error"};
      }
      /*if (data["ok"] == true) {
        Map<String, dynamic> rData = {
          "Hash": data['value']['cid'],
          "Name": 'squad_message.json',
          "Size": data['value']['size'],
        };
        return {"error": false, "data": rData};
      } else {
        return {"error": true, "data": data['error']['message']};
      }*/
    } on DioException catch (_) {
      throw "Network exception,send failed";
    } catch (e) {
      return {"error": true, "data": e};
    }
  }

  //根据 uri 获取上传到ipfs的信息
  Future<Map<String, dynamic>> getMessageByUriFromIpfs(String uri) async {
    try {
      var data = await BaseApi.requestEmptyH.get(uri, params: {});
      return {"error": false, "data": data};
    } on DioException catch (_) {
      throw "Network exception";
    } catch (e) {
      return {"error": true, "data": e};
    }
  }
}