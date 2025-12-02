import 'package:encrypt/encrypt.dart' as Encrypt;
class AesUtils{
  String _iv = '2624b9a9c447e587';
  ///aes加密函数
  String aesEncode(String content, String passWord) {
    //加密key
    final key = Encrypt.Key.fromUtf8(passWord);
    //偏移量
    final iv = Encrypt.IV.fromUtf8(_iv);
    //设置cbc模式
    final encrypter = Encrypt.Encrypter(
        Encrypt.AES(key, mode: Encrypt.AESMode.cbc, padding: 'PKCS7'));
    //加密
    final encrypted = encrypter.encrypt(content, iv: iv);
    return encrypted.base64;
  }

  /// 解密函数
  String aesDecrypted(String data, String passWord) {
    //加密key
    final key = Encrypt.Key.fromUtf8(passWord);
    //偏移量
    final iv = Encrypt.IV.fromUtf8(_iv);
    //设置cbc模式
    final encrypter = Encrypt.Encrypter(
        Encrypt.AES(key, mode: Encrypt.AESMode.cbc, padding: 'PKCS7'));
    return encrypter.decrypt(Encrypt.Encrypted.fromBase64(data), iv: iv);
  }

}