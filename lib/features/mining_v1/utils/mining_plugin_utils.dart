import 'dart:convert';
import 'package:flutter_mining/flutter_mining.dart';

final _flutterMiningPlugin = FlutterMining();
class MiningPluginUtils{
  ///设置插件初始化数据
  static Future<Map<String, dynamic>?> initSetting(
      String astAddress, String appBasePath,String privateKey,String server) async {
    final params = {};
    params["type"] = "setting";
    params["val"] = {
      "app_base_path": appBasePath,
      "account": astAddress,
      "priv_key": privateKey,
      "server_uri": server,
      //debug环境下输出日志
      "log_level": ""//Application.isDebug ?"debug" : ""
    };
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }

  // test evm sdk
  static Future<Map<String, dynamic>?> test() async {
    final params = {};
    params["type"] = "test";
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }

  ///start evm
  static Future<Map<String, dynamic>?> start() async {
    final params = {};
    params["type"] = "start";
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }

  ///STOP evm
  static Future<Map<String, dynamic>?> stop() async {
    final params = {};
    params["type"] = "stop";
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }

  ///bls sign
  ///sdk 根据private key 推出公钥 进行加密
  static Future<Map<String, dynamic>?> blsSign(
      String privateKey, String msg) async {
    final params = {};
    params["type"] = "blssign";
    params["val"] = {"priv_key": privateKey, "msg": msg};
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }

  ///bls pubKey
  ///sdk 根据private key 推出公钥
  static Future<Map<String, dynamic>?> getPubKey(String privateKey) async {
    final params = {};
    params["type"] = "blspubk";
    params["val"] = {"priv_key": privateKey};
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }


  /// 设置新的RPC节点
  static Future<Map<String, dynamic>?> setRPCNodeAddress(String ipAddress) async {
    final params = {};
    params["type"] = "setting";
    params["val"] = {
      "server_uri": ipAddress
    };
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }

  ///evm work status
  ///	{
  // 		"code":0,
  // 		"message":"",
  // 		"data":"started",//started,stopped
  // 	}
  static Future<Map<String, dynamic>?> status() async {
    final params = {};
    params["type"] = "state";
    final evmRes = await _flutterMiningPlugin.emit(json.encode(params));
    return evmRes;
  }
}