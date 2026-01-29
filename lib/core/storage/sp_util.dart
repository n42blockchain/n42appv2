// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/storage/secure_preferences.dart';
import 'package:n42appv2/data/models/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared Preferences Utility
///
/// Provides a centralized interface for local storage operations.
/// Handles user preferences, settings, and cached data.
/// Sensitive data (wallet, security, user info, lock screen) uses SecureStorage.
/// Non-sensitive data uses SharedPreferences.
class SPUtil {
  SharedPreferences? prefs;
  final SecurePreferences _securePrefs = SecurePreferences.instance;

  Future<SharedPreferences> initPrefs() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
      await _securePrefs.init();
    }
    return prefs!;
  }

  // ==================== 非敏感设置 ====================

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

  // ==================== 敏感数据（使用 SecurePreferences） ====================

  // 保存钱包信息（安全存储）
  Future<void> setWalletInfo(Map<String, dynamic> map) async {
    await _securePrefs.setWalletInfo(map);
  }

  /// 获取钱包列表（安全存储）
  Future<Map<String, dynamic>?> getWalletInfo() async {
    return await _securePrefs.getWalletInfo();
  }

  // 钱包安全验证配置（安全存储）
  Future<void> setSecurity(Map<String, dynamic> value) async {
    await _securePrefs.setSecurity(value);
  }

  Future<Map<String, dynamic>?> getSecurity() async {
    return await _securePrefs.getSecurity();
  }

  // 保存用户信息（安全存储）
  Future<void> saveUserInfo(UserInfo? info) async {
    if (info == null) {
      await _securePrefs.setUserInfo(null);
    } else {
      await _securePrefs.setUserInfo(info.toJson());
    }
  }

  // 保存用户信息 (JSON format for SharedUserInfo)（安全存储）
  Future<void> saveUserInfoJson(Map<String, dynamic> info) async {
    await _securePrefs.setUserInfo(info);
  }

  // 获取缓存的用户信息（安全存储）
  Future<Map<String, dynamic>?> getUserInfo() async {
    return await _securePrefs.getUserInfo();
  }

  // 锁屏设置（安全存储）
  Future<void> setLockScreen(Map<String, dynamic> value) async {
    final uuid = AppGlobals.userInfo?.uuid ?? "";
    await _securePrefs.setLockScreen(uuid, value);
  }

  Future<Map<String, dynamic>?> getLockScreen() async {
    final uuid = AppGlobals.userInfo?.uuid ?? "";
    return await _securePrefs.getLockScreen(uuid);
  }

  // 挖矿数据（安全存储）
  Future<void> setMiningData(Map<String, dynamic> value) async {
    final uuid = AppGlobals.userInfo?.uuid ?? "";
    await _securePrefs.setMiningData(uuid, value);
  }

  Future<Map<String, dynamic>?> getMiningData() async {
    final uuid = AppGlobals.userInfo?.uuid ?? "";
    return await _securePrefs.getMiningData(uuid);
  }

  // ==================== 非敏感设置（继续使用 SharedPreferences） ====================

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

  // 服务条款
  Future<void> setShowTermsOfService(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.showTermsOfService.name, value);
  }

  Future<bool> getShowTermsOfService() async {
    await initPrefs();
    return prefs?.getBool(SPkey.showTermsOfService.name) ?? false;
  }

  // 是否使用新聊天模块 (N42 Chat)
  Future<void> setUseNewChat(bool value) async {
    await initPrefs();
    await prefs?.setBool(SPkey.useNewChat.name, value);
  }

  Future<bool> getUseNewChat() async {
    await initPrefs();
    return prefs?.getBool(SPkey.useNewChat.name) ?? true;
  }

  // ==================== 通用方法 ====================

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
  walletInfo, // 钱包信息（已迁移到 SecureStorage）
  security, // 安全设置（已迁移到 SecureStorage）
  userInfo, // 用户信息（已迁移到 SecureStorage）
  backgroundMiningMusic, // 后台挖矿音乐
  hasAcceptedChatTerms, // 是否阅读Chat 用户须知
  lockScreen, // 锁屏配置（已迁移到 SecureStorage）
  showTermsOfService, // 显示服务条款
  miningData, // 挖矿数据（已迁移到 SecureStorage）
  readLoginClause, // 是否阅读登录条款
  useNewChat, // 是否使用新聊天模块
}

