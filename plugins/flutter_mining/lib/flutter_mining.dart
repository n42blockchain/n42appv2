
import 'flutter_mining_platform_interface.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
class FlutterMining {
  Future<String?> getPlatformVersion() {
    return FlutterMiningPlatform.instance.getPlatformVersion();
  }

  ///Response:
  ///{
  ///     "code":0, //相应码，非0时发生异常
  ///     "message":"",//相应文本，code非0时显示异常内容
  ///     "data":[],//data:{} 响应数据
  /// }
  Future<Map<String, dynamic>?> emit(String params) async {
    try {
      final res = await FlutterMiningPlatform.instance.emit(params);
      if (res != null) {
        return json.decode(res);
      }
    } catch (err) {
      debugPrint("emit err: ${err.toString()}");
    }
    return null;
  }


  /// 解密
  Future<String?> cryptographyMessage(String message) async{
    try {
      final res = await FlutterMiningPlatform.instance.emit(message);
      if (res != null) {
        return json.decode(res);
      }
    } catch (err) {
      debugPrint("emit err: ${err.toString()}");
    }
    return null;
  }

  /// 解密
  Future<String?> dCodeMessage(String message) async{
    try {
      final res = await FlutterMiningPlatform.instance.emit(message);
      if (res != null) {
        return json.decode(res);
      }
    } catch (err) {
      debugPrint("emit err: ${err.toString()}");
    }
    return null;
  }
  /// ---------------- EVM SDK 特定方法 ----------------
  //生成12381keypart
  Future<String?> generateBls12381Keypair() async {
    try{
      final res = await FlutterMiningPlatform.instance.generateBls12381Keypair();
      return res;
    } catch(err) {
      debugPrint("createDepositUnsignedTx err: ${err.toString()}");
      return null;
    }
  }
  /// 生成存款交易
  Future<String?> createDepositUnsignedTx({
    required String depositContractAddress,
    required String validatorPrivateKey,
    required String withdrawalAddress,
    required String depositValueWeiInHex,
  }) async {
    try {
      final res = await FlutterMiningPlatform.instance.createDepositUnsignedTx(
        {
          "depositContractAddress": depositContractAddress,
          "validatorPrivateKey": validatorPrivateKey,
          "withdrawalAddress": withdrawalAddress,
          "depositValueWeiInHex": depositValueWeiInHex,
        },
      );
      return res;
    } catch (err) {
      debugPrint("createDepositUnsignedTx err: ${err.toString()}");
      return null;
    }
  }
  //生成退款交易费用
  Future<String?> createGetExitFeeUnsignedTx() async {
    try{
      final res = await FlutterMiningPlatform.instance.createGetExitFeeUnsignedTx();
      return res;
    } catch(err) {
      debugPrint("createDepositUnsignedTx err: ${err.toString()}");
      return null;
    }
  }
  /// 生成退出交易
  Future<String?> createExitUnsignedTx({
    required String validatorPublicKey,
    required String feeWeiInHex,
  }) async {
    try {
      final res = await FlutterMiningPlatform.instance.createExitUnsignedTx(
        {
          "validatorPublicKey": validatorPublicKey,
          "feeWeiInHex": feeWeiInHex,
        },
      );
      return res;
    } catch (err) {
      debugPrint("createExitUnsignedTx err: ${err.toString()}");
      return null;
    }
  }

  /// 启动异步客户端
  Future<String?> runClient({
    required String wsUrl,
    required String validatorPrivateKey,
  }) async {
    try {
      final res = await FlutterMiningPlatform.instance.runClient(
        {
          "wsUrl": wsUrl,
          "validatorPrivateKey": validatorPrivateKey,
        },
      );
      return res;
    } catch (err) {
      debugPrint("runClient err: ${err.toString()}");
      return null;
    }
  }
}
