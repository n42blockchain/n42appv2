import 'dart:isolate';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';

class FileAesCryptUtils {
  ///文件异步加密 -- 不开启线程的方式
  static Future<String?> encryptFile(String path, String password) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    crypt.setPassword(password);
    String? encFilepath;
    try {
      encFilepath = await crypt.encryptFile(path);
    } on AesCryptExceptionType {
      // AES 加密类型异常安全忽略，返回 null 表示加密失败
    } catch (_) {
      // 加密过程中的其他错误安全忽略，返回 null 表示加密失败
    }
    return encFilepath;
  }

  ///文件异步加密 -- 开启线程的方式
  ///使用 isolate 开启线程 对文件进行加密 解决ui卡顿问题
  Future<dynamic> isolateCryptFile(String path, String password) async {
    final response = ReceivePort();
    await Isolate.spawn(cryptFile, response.sendPort);
    final sendPort = await response.first;
    final answer = ReceivePort();
    sendPort.send([answer.sendPort, path, password]);
    return answer.first;
  }

  static void cryptFile(SendPort port) {
    final rPort = ReceivePort();
    port.send(rPort.sendPort);
    rPort.listen((message) async {
      final send = message[0] as SendPort;
      final path = message[1] as String;
      final password = message[2] as String;
      final data = await encryptFile(path, password);
      send.send(data);
    });
  }

  ///文件解密 --不开启线程的方式
  static Future<String?> decryptFile(String path, String password) async {
    AesCrypt crypt = AesCrypt();
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    crypt.setPassword(password);
    String? decFilepath;
    try {
      decFilepath = await crypt.decryptFile(path,'');

    } catch (_) {
      // 解密过程中的错误安全忽略，返回 null 表示解密失败
    }
    return decFilepath;
  }

  ///文件解密 -- 开启线程的方式
  ///使用 isolate 开启线程 对文件进行加密 解决ui卡顿问题
  Future<dynamic> isolateDecryptFile(
      String path, String password) async {
    final response = ReceivePort();
    await Isolate.spawn(isoDecryptFile, response.sendPort);
    final sendPort = await response.first;
    final answer = ReceivePort();
    sendPort.send([answer.sendPort, path, password]);
    return answer.first;
  }

  static void isoDecryptFile(SendPort port) {
    final rPort = ReceivePort();
    port.send(rPort.sendPort);
    rPort.listen((message) async {
      final send = message[0] as SendPort;
      final path = message[1] as String;
      final password = message[2] as String;
      final data = await decryptFile(path, password);
      send.send(data);
    });
  }
}