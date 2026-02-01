import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';
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

  //int 转 十六进制
  String intToHex(int value, {bool need0x = true}) {
    String str = value.toRadixString(16);
    return add0x(str);
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
  ///hex 转 String
  String toStringFromHex(String hex) {
    Uint8List bArr = hexToBytes(hex);
    return String.fromCharCodes(bArr);
  }
  //保留小数位 不四舍五入
  double doubleFixed(double num, int position) {
    var newNum = num.toStringAsFixed(position + 1);
    return double.parse(
        newNum.substring(0, newNum.lastIndexOf(".") + position + 1));
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
}