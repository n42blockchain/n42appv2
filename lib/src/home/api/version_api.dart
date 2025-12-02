import 'dart:convert';
import 'dart:io';

import 'package:n42appv2/app_config.dart';
import 'package:n42appv2/src/home/models/version_info_model.dart';
import 'package:n42appv2/src/https/base_api.dart';

class VersionApi{
  late String url;
  late Map<String,String> header;
  CheckVersionApi(){
    url=AppConfig.getApiUrl_online('userInfoHost');
    header={'content-type': 'application/x-www-form-urlencoded'};
  }
  // 最新版本信息
  Future<VersionInfoModel?> getVersionInfo() async {
    Map<String, dynamic> params = {};
    params["source"] = "app";
    params["app"] = Platform.isIOS ? "ios" : "android";
    final data = await BaseApi.RequestEmpty_h.get(
        '/v1/r/static/app/version',
        params: params,header: header
    );
    if(data["code"] == 200){
      return VersionInfoModel.fromJson(json.decode(data['data']));
    }
    return null;
  }
}