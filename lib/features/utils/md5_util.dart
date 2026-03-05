import 'dart:convert';
import 'package:crypto/crypto.dart';

class Md5Util {
  String generateMd5(String data) {
    return md5.convert(utf8.encode(data)).toString();
  }
}