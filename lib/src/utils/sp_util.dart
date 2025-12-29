import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPUtil{
  SharedPreferences? prefs;
  Future<SharedPreferences> initPrefs()async{
    if(prefs==null){
      prefs=await SharedPreferences.getInstance();
    }
    return prefs!;
  }
  //是否阅读了登录、安全条款
  setReadLoginClause(bool value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    prefs?.setBool(SPkey.readLoginClause.name, value);
  }

  getReadLoginClause() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    bool? value = await prefs?.getBool(SPkey.readLoginClause.name);
    if (value == null) {
      return false;
    } else {
      return value;
    }
  }

  //app主题模式0系统，1亮，2暗
  setThemeMode(int value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    prefs?.setInt(SPkey.themeMode.name, value);
  }

  getThemeMode() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    var r = await prefs?.get(SPkey.themeMode.name);
    return r;
  }
  //app系统语言,en,zh-CN
  setSysLang(String value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    prefs?.setString(SPkey.sysLang.name, value);
  }

  getSysLang() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    var r = await prefs?.get(SPkey.sysLang.name);
    return r;
  }
  //浏览器设置browserSetting
  setBrowserSetting(Map<String, dynamic> value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    prefs?.setString(SPkey.browserSetting.name, json.encode(value));
  }

  getBrowserSetting() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    String? r = await prefs?.getString(SPkey.browserSetting.name);
    if (r == null) {
      return null;
    }
    return json.decode(r);
  }

  //保存钱包信息
  setWalletInfo(Map<String, dynamic> map) async {
    await putObject(SPkey.walletInfo.name, map);
  }

  /// 获取钱包列表
  Future<Map<String, dynamic>?> getWallsetInfo() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    String? data = await prefs?.getString(SPkey.walletInfo.name);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }
  //钱包安全验证配置
  setSecurity(Map<String, dynamic> value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    prefs?.setString(SPkey.security.name, json.encode(value));
  }

  getSecurity() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    String? r = await prefs?.getString(SPkey.security.name);
    if (r == null) {
      return null;
    }
    return json.decode(r);
  }
  //保存用户信息
  saveUserInfo(UserInfo? info) async {
    await putObject(SPkey.userInfo.name, info);
  }

  //获取缓存的用户信息
  Future getUserInfo() async {
    return await getObject(SPkey.userInfo.name);
  }

  //设置后台挖矿音乐
  Future setBackgroundMiningMusic(int value) async {
    await initPrefs();
    prefs?.setInt(SPkey.backgroundMiningMusic.name, value);
  }
  //获取后台挖矿音乐
  Future getBackgroundMiningMusic() async {
    await initPrefs();
    return await prefs?.getInt(SPkey.backgroundMiningMusic.name);
  }

  Future<bool> hasAcceptedTerms() async {
    await initPrefs();
    return await prefs?.getBool(SPkey.hasAcceptedChatTerms.name) ?? false;
  }

  Future<void> setHasAcceptedTerms(bool value) async {
    await initPrefs();
    prefs?.setBool(SPkey.hasAcceptedChatTerms.name, value);
  }
  //锁屏设置
  setLockScreen(Map<String, dynamic> value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    String? r = await prefs?.getString(SPkey.lockScreen.name);
    if(r==null){
      prefs?.setString(SPkey.lockScreen.name, json.encode({
        "${AppGlobals.userInfo?.uuid??""}":value,
      }));
    }else{
      Map<String,dynamic> ls=json.decode(r);
      ls["${AppGlobals.userInfo?.uuid??""}"]=value;
      prefs?.setString(SPkey.lockScreen.name, json.encode(ls));
    }

  }

  getLockScreen() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    String? r = await prefs?.getString(SPkey.lockScreen.name);
    if (r == null) {
      return null;
    }else{
      Map<String,dynamic> ls=json.decode(r);
      return ls[AppGlobals.userInfo?.uuid??""];
    }
  }

  //服务条款
  setShowTermsOfService(bool value)async{
    await initPrefs();
    await prefs?.setBool(SPkey.showTermsOfService.name,value);
  }
  getShowTermsOfService()async{
    await initPrefs();
    return await prefs?.getBool(SPkey.showTermsOfService.name) ?? false;
  }
  //临时存储，挖矿信息
  setMiningData(Map<String, dynamic> value) async{
    await initPrefs();
    String? r = await prefs?.getString(SPkey.miningData.name);
    if(r==null){
      prefs?.setString(SPkey.miningData.name, json.encode({
        "${AppGlobals.userInfo?.uuid??""}":value,
      }));
    }else{
      Map<String,dynamic> ls=json.decode(r);
      ls["${AppGlobals.userInfo?.uuid??""}"]=value;
      prefs?.setString(SPkey.miningData.name, json.encode(ls));
    }
  }
  getMiningData() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    String? r = await prefs?.getString(SPkey.miningData.name);
    if (r == null) {
      return null;
    }else{
      Map<String,dynamic> ls=json.decode(r);
      return ls[AppGlobals.userInfo?.uuid??""];
    }
  }
  /// put object.
  Future<bool> putObject(String key, Object? value) async {
    await initPrefs();
    return await prefs!.setString(key, value == null ? "" : json.encode(value));
  }


  /// get obj.
  Future<T> getObj<T>(String key, T Function(Map v) f,
      {required T defValue}) async {
    Map? map = await getObject(key);
    return map == null ? defValue : f(map);
  }
  /// get object.
  Future<Map?> getObject(String key) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    String? _data = await prefs?.getString(key);
    return (_data == null || _data.isEmpty) ? null : json.decode(_data);
  }
  ///保存bool值
  setBoolValue(String key, bool value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    return await prefs?.setBool(key, value);
  }

  /// 获取 bool值
  /// 首次取不到 返回false
  getBoolValue(String key,{bool? defaultValue = false}) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    return await prefs?.getBool(key) ?? defaultValue;
  }
  /// get List object.
  Future<Object?> getListObject(String key) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await initPrefs();
    String? _data = await prefs?.getString(key);
    return (_data == null || _data.isEmpty) ? null : json.decode(_data);
  }
}
enum SPkey{
  themeMode,//app主题模式0系统，1亮，2暗
  sysLang,//系统语言en,zh-CN
  browserSetting,//浏览器设置
  walletInfo,//钱包信息
  security,//安全设置
  userInfo,
  backgroundMiningMusic,//后台挖矿音乐
  hasAcceptedChatTerms,//是否阅读Chat 用户须知
  lockScreen,//锁屏配置
  showTermsOfService,//显示服务条款
  miningData,//临时存储，挖矿信息
  readLoginClause,
}