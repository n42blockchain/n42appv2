import 'dart:convert';
import 'package:flutter_mining/flutter_mining.dart';

final _flutterMiningPlugin = FlutterMining();

class MiningPluginUtils {
  ///设置插件初始化数据
  static Future<Map<String, dynamic>?> initSetting(
    String astAddress,
    String appBasePath,
    String privateKey,
    String server,
  ) async {
    final params = <String, dynamic>{
      "type": "setting",
      "val": {
        "app_base_path": appBasePath,
        "account": astAddress,
        "priv_key": privateKey,
        "server_uri": server,
        "log_level": "",
      },
    };
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }

  static Future<Map<String, dynamic>?> _emit(
    String type, {
    Map<String, dynamic>? val,
  }) async {
    final params = <String, dynamic>{"type": type};
    if (val != null) params["val"] = val;
    return await _flutterMiningPlugin.emit(json.encode(params));
  }

  // test evm sdk
  static Future<Map<String, dynamic>?> test() => _emit("test");

  ///start evm
  static Future<Map<String, dynamic>?> start() => _emit("start");

  ///STOP evm
  static Future<Map<String, dynamic>?> stop() => _emit("stop");

  ///bls sign
  ///sdk 根据private key 推出公钥 进行加密
  static Future<Map<String, dynamic>?> blsSign(String privateKey, String msg) =>
      _emit("blssign", val: {"priv_key": privateKey, "msg": msg});

  ///bls pubKey
  ///sdk 根据private key 推出公钥
  static Future<Map<String, dynamic>?> getPubKey(String privateKey) =>
      _emit("blspubk", val: {"priv_key": privateKey});

  /// 设置新的RPC节点
  static Future<Map<String, dynamic>?> setRPCNodeAddress(String ipAddress) =>
      _emit("setting", val: {"server_uri": ipAddress});

  ///evm work status
  static Future<Map<String, dynamic>?> status() => _emit("state");
}
