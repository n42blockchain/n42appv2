//获取设备信息
import 'dart:io';

import 'package:n42appv2/src/utils/data_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtil{
  //手机名称、系统、手机型号
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try{
      Map<String,dynamic> rMap={};
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if(Platform.isAndroid){
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        rMap["mobileModel"]=androidInfo.version.release;//DataUtils.formatNum(double.parse(androidInfo.version.release), 1);
        rMap["mobileName"]=androidInfo.brand.toString().toLowerCase();
        rMap["os"]="android";
      }
      else{
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        rMap["mobileModel"]=DataUtils().formatNum(double.parse(iosInfo.systemVersion), 1);
        rMap["mobileName"]="Apple";
        rMap["os"]=iosInfo.systemName;
      }
      return rMap;
    }catch(e){
      return null;
    }
  }
}