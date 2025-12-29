// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared Preferences Utility
///
/// Provides a centralized interface for local storage operations.
/// Handles user preferences, settings, and cached data.
class SPUtil {
  SharedPreferences? prefs;

  Future<SharedPreferences> initPrefs() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    return prefs!;
  }

  // 是否阅读了登录、安全条款
  Future<void> setReadLoginClause(bool value) async {
    await initPrefs();
    prefs?.setBool(SPkey.readLoginClause.name, value);
  }

  Future<bool> getReadLoginClause() async {
    await initPrefs();
    bool? value = prefs?.getBool(SPkey.readLoginClause.name);
    return value ?? false;
  }

  // app主题模式0系统，1亮，2暗
  Future<void> setThemeMode(int value) async {
    await initPrefs();
    prefs?.setInt(SPkey.themeMode.name, value);
  }

  Future<int?> getThemeMode() async {
    await initPrefs();
    return prefs?.getInt(SPkey.themeMode.name);
  }

  // app系统语言,en,zh-CN
  Future<void> setSysLang(String value) async {
    await initPrefs();
    prefs?.setString(SPkey.sysLang.name, value);
  }

  Future<String?> getSysLang() async {
    await initPrefs();
    return prefs?.getString(SPkey.sysLang.name);
  }

  // 浏览器设置browserSetting
  Future<void> setBrowserSetting(Map<String, dynamic> value) async {
    await initPrefs();
    prefs?.setString(SPkey.browserSetting.name, json.encode(value));
  }

  Future<Map<String, dynamic>?> getBrowserSetting() async {
    await initPrefs();
    String? r = prefs?.getString(SPkey.browserSetting.name);
    if (r == null) {
      return null;
    }
    return json.decode(r);
  }

  // 保存钱包信息
  Future<void> setWalletInfo(Map<String, dynamic> map) async {
    await putObject(SPkey.walletInfo.name, map);
  }

  /// 获取钱包列表
  Future<Map<String, dynamic>?> getWalletInfo() async {
    await initPrefs();
    String? data = prefs?.getString(SPkey.walletInfo.name);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // 钱包安全验证配置
  Future<void> setSecurity(Map<String, dynamic> value) async {
    await initPrefs();
    prefs?.setString(SPkey.security.name, json.encode(value));
  }

  Future<Map<String, dynamic>?> getSecurity() async {
    await initPrefs();
    String? r = prefs?.getString(SPkey.security.name);
    if (r == null) {
      return null;
    }
    return json.decode(r);
  }

  // 保存用户信息
  Future<void> saveUserInfo(UserInfo? info) async {
    await putObject(SPkey.userInfo.name, info);
  }

  // 获取缓存的用户信息
  Future<Map<String, dynamic>?> getUserInfo() async {
    return await getObject(SPkey.userInfo.name);
  }

  // 设置后台挖矿音乐
  Future<void> setBackgroundMiningMusic(int value) async {
    await initPrefs();
    prefs?.setInt(SPkey.backgroundMiningMusic.name, value);
  }

  // 获取后台挖矿音乐
  Future<int?> getBackgroundMiningMusic() async {
    await initPrefs();
    return prefs?.getInt(SPkey.backgroundMiningMusic.name);
  }

  Future<bool> hasAcceptedTerms() async {
    await initPrefs();
    return prefs?.getBool(SPkey.hasAcceptedChatTerms.name) ?? false;
  }

  Future<void> setHasAcceptedTerms(bool value) async {
    await initPrefs();
    prefs?.setBool(SPkey.hasAcceptedChatTerms.name, value);
  }

  // 锁屏设置
  Future<void> setLockScreen(Map<String, dynamic> value) async {
    await initPrefs();
    String? r = prefs?.getString(SPkey.lockScreen.name);
    final userUuid = AppGlobals.userInfo?.uuid ?? "";
    
    if (r == null) {
      prefs?.setString(SPkey.lockScreen.name, json.encode({
        userUuid: value,
      }));
    } else {
      Map<String, dynamic> ls = json.decode(r);
      ls[userUuid] = value;
      prefs?.setString(SPkey.lockScreen.name, json.encode(ls));
    }
  }

  Future<Map<String, dynamic>?> getLockScreen() async {
    await initPrefs();
    String? r = prefs?.getString(SPkey.lockScreen.name);
    if (r == null) {
      return null;
    } else {
      Map<String, dynamic> ls = json.decode(r);
      return ls[AppGlobals.userInfo?.uuid ?? ""];
    }
  }

  // 服务条款
  Future<void> setShowTermsOfService(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.showTermsOfService.name, value);
  }

  Future<bool> getShowTermsOfService() async {
    await initPrefs();
    return prefs?.getBool(SPkey.showTermsOfService.name) ?? false;
  }

  // 临时存储，挖矿信息
  Future<void> setMiningData(Map<String, dynamic> value) async {
    await initPrefs();
    String? r = prefs?.getString(SPkey.miningData.name);
    final userUuid = AppGlobals.userInfo?.uuid ?? "";
    
    if (r == null) {
      prefs?.setString(SPkey.miningData.name, json.encode({
        userUuid: value,
      }));
    } else {
      Map<String, dynamic> ls = json.decode(r);
      ls[userUuid] = value;
      prefs?.setString(SPkey.miningData.name, json.encode(ls));
    }
  }

  Future<Map<String, dynamic>?> getMiningData() async {
    await initPrefs();
    String? r = prefs?.getString(SPkey.miningData.name);
    if (r == null) {
      return null;
    } else {
      Map<String, dynamic> ls = json.decode(r);
      return ls[AppGlobals.userInfo?.uuid ?? ""];
    }
  }

  /// put object.
  Future<bool> putObject(String key, Object? value) async {
    await initPrefs();
    return await prefs!.setString(key, value == null ? "" : json.encode(value));
  }

  /// get obj.
  Future<T> getObj<T>(
    String key,
    T Function(Map v) f, {
    required T defValue,
  }) async {
    Map? map = await getObject(key);
    return map == null ? defValue : f(map);
  }

  /// get object.
  Future<Map<String, dynamic>?> getObject(String key) async {
    await initPrefs();
    String? data = prefs?.getString(key);
    return (data == null || data.isEmpty) ? null : json.decode(data);
  }

  /// 保存bool值
  Future<bool?> setBoolValue(String key, bool value) async {
    await initPrefs();
    return await prefs?.setBool(key, value);
  }

  /// 获取 bool值
  /// 首次取不到 返回false
  Future<bool> getBoolValue(String key, {bool? defaultValue = false}) async {
    await initPrefs();
    return prefs?.getBool(key) ?? defaultValue ?? false;
  }

  /// get List object.
  Future<Object?> getListObject(String key) async {
    await initPrefs();
    String? data = prefs?.getString(key);
    return (data == null || data.isEmpty) ? null : json.decode(data);
  }
}

/// Storage Keys
enum SPkey {
  themeMode, // app主题模式0系统，1亮，2暗
  sysLang, // 系统语言en,zh-CN
  browserSetting, // 浏览器设置
  walletInfo, // 钱包信息
  security, // 安全设置
  userInfo,
  backgroundMiningMusic, // 后台挖矿音乐
  hasAcceptedChatTerms, // 是否阅读Chat 用户须知
  lockScreen, // 锁屏配置
  showTermsOfService, // 显示服务条款
  miningData, // 临时存储，挖矿信息
  readLoginClause,
}

