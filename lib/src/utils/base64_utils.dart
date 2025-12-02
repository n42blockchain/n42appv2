import 'dart:convert';

class Base64Utils {
  /*
  * Base64加密
  */
  String encodeBase64(String data) {
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }

/*
  * Base64解密
  */
  String decodeBase64(String data) {
    return utf8.decode(base64Decode(data));
  }

}