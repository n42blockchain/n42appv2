import 'dart:convert';
import 'package:crypto/crypto.dart';  // 需要添加 crypto 依赖
String CreateUrl(String coinType,String address,String url,String mode) {
  const String secretKeyTest = 'sk_test_CyXDuhzlQ5wwn5xdAOKfI063r0yGF6H'; // 使用你的密钥
  const String secretKeyProd='sk_live_ibtPjcK0JIL8sO7e3kbeBLxrvEVCL8uR';
  String secretKey;
  if(mode=="prod"){
    secretKey=secretKeyProd;
  }else{
    secretKey=secretKeyTest;
  }
  Uri uri = Uri.parse(url);
  String queryString = uri.query;

  // 计算 HMAC-SHA256 签名
  var hmac = Hmac(sha256, utf8.encode(secretKey));
  var digest = hmac.convert(utf8.encode('?$queryString'));
  String signature = base64Encode(digest.bytes);
  return signature;
  // 生成带签名的 URL
  /*Uri signedUri = uri.replace(queryParameters: {
    ...uri.queryParameters,
    'signature': signature,
  });*/
  //return signedUri.toString();
}