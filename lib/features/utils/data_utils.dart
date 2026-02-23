import 'dart:convert';
import 'dart:math';
import 'package:flustars_flutter3/flustars_flutter3.dart';

class DataUtils{
  //去掉十六进制前面的0x
  String strip0x(String hex) {
    if (hex.startsWith('0x')) return hex.substring(2);
    return hex;
  }

  //添加十六进制前面的0x
  String add0x(String hex) {
    hex = '0x$hex';
    return hex;
  }

  //十六进制转BigInt
  BigInt hexToBigInt(String hex) {
    String strip = strip0x(hex);
    if (strip == "") strip = "0";
    return BigInt.parse(strip, radix: 16);
  }

  //bigInt 转 十六进制
  //need0x是否需要加上0x前缀
  String bigIntToHex(BigInt value, {bool need0x = true,bool padToEvenLength = false,}) {
    String str = value.toRadixString(16);
    if (padToEvenLength && str.length % 2 != 0) {
      str = '0$str';
    }
    if (need0x) {
      return add0x(str);
    } else {
      return str;
    }
  }
  /// 打乱数组
  List shuffle(List arr) {
    List newArr = [];
    // newArr.shuffle(); 目前dart提供的有shuffle方法
    newArr.addAll(arr);
    for (var i = 1; i < newArr.length; i++) {
      var j = getRandomInt(0, i);
      var t = newArr[i];
      newArr[i] = newArr[j];
      newArr[j] = t;
    }
    return newArr;
  }
  int getRandomInt(int min, int max) {
    final random = Random();
    return random.nextInt((max - min).floor()) + min;
  }
  /// 比较2个集合是否完全一样
  bool sameList(List first, List second) {
    final firstJson = json.encode(first);
    final secondJson = json.encode(second);
    return firstJson == secondJson;
  }
  //地址处理
  String addressFarmat(String value){
    if(value==""){
      return "";
    }else{
      String rStr=value.substring(0,7);
      rStr="$rStr...${value.substring(value.length-9)}";
      return rStr;
    }
  }
  String formatNum(double num, int position) {
    if ((num.toString().length - num.toString().lastIndexOf(".") - 1) <
        position) {
      //小数点后有几位小数
      return num.toStringAsFixed(position)
          .substring(0, num.toString().lastIndexOf(".") + position + 1)
          .toString();
    } else {
      return num.toString()
          .substring(0, num.toString().lastIndexOf(".") + position + 1)
          .toString();
    }
  }
  String getTimeByTimeStamp(String timeStamp,
      {String? format = "dd/MM/yyyy HH:mm"}) {
    if (timeStamp.isEmpty) {
      return '';
    }
    int millisecondsSinceEpoch;
    if (timeStamp.length == 10) {
      millisecondsSinceEpoch = int.parse("${timeStamp}000");
    }else{
      millisecondsSinceEpoch = int.parse(timeStamp);
    }
    DateTime time = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String dateTimeStr = DateUtil.formatDate(time, format: format);
    return dateTimeStr;
  }

  /// 将 double 截断到指定小数位（不四舍五入）
  String doubleFixed(double num, int position) {
    if (position <= 0) return num.truncate().toString();
    final str = num.toStringAsFixed(position + 2);
    final dotIndex = str.lastIndexOf('.');
    if (dotIndex < 0) return str;
    final end = dotIndex + position + 1;
    if (end >= str.length) return str;
    return str.substring(0, end);
  }

  /// 将十六进制字符串转为 int（去掉 0x 前缀）
  int hexToInt(String hex) {
    return int.parse(strip0x(hex), radix: 16);
  }
}