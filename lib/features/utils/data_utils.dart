import 'dart:convert';
import 'dart:math';
import 'package:flustars_flutter3/flustars_flutter3.dart';

class DataUtils {
  String strip0x(String hex) {
    if (hex.startsWith('0x')) return hex.substring(2);
    return hex;
  }

  String add0x(String hex) => '0x$hex';

  BigInt hexToBigInt(String hex) {
    final strip = strip0x(hex);
    return BigInt.parse(strip.isEmpty ? "0" : strip, radix: 16);
  }

  String bigIntToHex(BigInt value, {bool need0x = true, bool padToEvenLength = false}) {
    var str = value.toRadixString(16);
    if (padToEvenLength && str.length % 2 != 0) {
      str = '0$str';
    }
    return need0x ? add0x(str) : str;
  }

  List shuffle(List arr) {
    final newArr = List.from(arr)..shuffle();
    return newArr;
  }

  int getRandomInt(int min, int max) => Random().nextInt(max - min) + min;

  bool sameList(List first, List second) =>
      json.encode(first) == json.encode(second);

  String addressFarmat(String value) {
    if (value.isEmpty) return "";
    return '${value.substring(0, 7)}...${value.substring(value.length - 9)}';
  }

  String formatNum(double num, int position) {
    final dotIndex = num.toString().lastIndexOf(".");
    final decimals = num.toString().length - dotIndex - 1;
    if (decimals < position) {
      return num.toStringAsFixed(position).substring(0, dotIndex + position + 1);
    }
    return num.toString().substring(0, dotIndex + position + 1);
  }

  String getTimeByTimeStamp(String timeStamp, {String? format = "dd/MM/yyyy HH:mm"}) {
    if (timeStamp.isEmpty) return '';
    final ms = timeStamp.length == 10
        ? int.parse("${timeStamp}000")
        : int.parse(timeStamp);
    return DateUtil.formatDate(
      DateTime.fromMillisecondsSinceEpoch(ms),
      format: format,
    );
  }

  String doubleFixed(double num, int position) {
    if (position <= 0) return num.truncate().toString();
    final str = num.toStringAsFixed(position + 2);
    final dotIndex = str.lastIndexOf('.');
    if (dotIndex < 0) return str;
    final end = dotIndex + position + 1;
    if (end >= str.length) return str;
    return str.substring(0, end);
  }

  int hexToInt(String hex) => int.parse(strip0x(hex), radix: 16);
}
