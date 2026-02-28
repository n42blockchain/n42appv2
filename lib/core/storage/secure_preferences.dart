// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 安全存储偏好设置
///
/// 将敏感数据存储在 SecureStorage 中，非敏感数据存储在 SharedPreferences 中
/// 自动处理从 SharedPreferences 到 SecureStorage 的数据迁移
class SecurePreferences {
  static SecurePreferences? _instance;
  SharedPreferences? _prefs;

  /// 安全存储实例
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      sharedPreferencesName: 'n42_secure_prefs',
      preferencesKeyPrefix: 'sp_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'n42wallet_prefs',
    ),
  );

  SecurePreferences._();

  /// 获取单例实例
  static SecurePreferences get instance {
    _instance ??= SecurePreferences._();
    return _instance!;
  }

  /// 敏感数据键名列表（将存储在 SecureStorage 中）
  static const List<String> _sensitiveKeys = [
    'walletInfo',
    'security',
    'lockScreen',
    'userInfo',
  ];

  /// 初始化
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _migrateFromSharedPreferences();
  }

  /// 从 SharedPreferences 迁移敏感数据到 SecureStorage
  Future<void> _migrateFromSharedPreferences() async {
    for (final key in _sensitiveKeys) {
      try {
        final value = _prefs?.getString(key);
        if (value != null && value.isNotEmpty) {
          final secureValue = await _secureStorage.read(key: key);
          if (secureValue == null) {
            await _secureStorage.write(key: key, value: value);
            await _prefs?.remove(key);
            if (kDebugMode) {
              debugPrint('[SecurePreferences] Migrated key: $key');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SecurePreferences] Migration failed for key $key: $e');
        }
      }
    }
  }

  /// 从安全存储读取并解码 JSON 对象，失败时返回 null
  Future<Map<String, dynamic>?> _readSecureJson(String key) async {
    final data = await _secureStorage.read(key: key);
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecurePreferences] Failed to decode $key: $e');
      }
      return null;
    }
  }

  /// 读取安全存储中的 Map，更新指定 uuid 对应的值，再写回
  Future<void> _updateSecureMap(
    String key,
    String uuid,
    Map<String, dynamic> value,
  ) async {
    final allData = await _readSecureJson(key) ?? {};
    allData[uuid] = value;
    await _secureStorage.write(key: key, value: jsonEncode(allData));
  }

  // ==================== 钱包信息（敏感） ====================

  /// 保存钱包信息
  Future<void> setWalletInfo(Map<String, dynamic> map) async {
    await _secureStorage.write(key: 'walletInfo', value: jsonEncode(map));
  }

  /// 获取钱包信息
  Future<Map<String, dynamic>?> getWalletInfo() => _readSecureJson('walletInfo');

  /// 删除钱包信息
  Future<void> removeWalletInfo() async {
    await _secureStorage.delete(key: 'walletInfo');
  }

  // ==================== 安全设置（敏感） ====================

  /// 保存安全设置
  Future<void> setSecurity(Map<String, dynamic> value) async {
    await _secureStorage.write(key: 'security', value: jsonEncode(value));
  }

  /// 获取安全设置
  Future<Map<String, dynamic>?> getSecurity() => _readSecureJson('security');

  // ==================== 锁屏设置（敏感） ====================

  /// 保存锁屏设置
  Future<void> setLockScreen(String uuid, Map<String, dynamic> value) async {
    await _updateSecureMap('lockScreen', uuid, value);
  }

  /// 获取锁屏设置
  Future<Map<String, dynamic>?> getLockScreen(String uuid) async {
    final allData = await _readSecureJson('lockScreen');
    return allData?[uuid] as Map<String, dynamic>?;
  }

  // ==================== 用户信息（敏感） ====================

  /// 保存用户信息
  Future<void> setUserInfo(Map<String, dynamic>? value) async {
    if (value == null) {
      await _secureStorage.delete(key: 'userInfo');
    } else {
      await _secureStorage.write(key: 'userInfo', value: jsonEncode(value));
    }
  }

  /// 获取用户信息
  Future<Map<String, dynamic>?> getUserInfo() => _readSecureJson('userInfo');

  // ==================== 挖矿数据（敏感） ====================

  /// 保存挖矿数据
  Future<void> setMiningData(String uuid, Map<String, dynamic> value) async {
    await _updateSecureMap('miningData', uuid, value);
  }

  /// 获取挖矿数据
  Future<Map<String, dynamic>?> getMiningData(String uuid) async {
    final allData = await _readSecureJson('miningData');
    return allData?[uuid] as Map<String, dynamic>?;
  }

  // ==================== 非敏感数据（使用 SharedPreferences） ====================

  /// 获取主题模式
  Future<int?> getThemeMode() async {
    await init();
    return _prefs?.getInt('themeMode');
  }

  /// 设置主题模式
  Future<void> setThemeMode(int value) async {
    await init();
    await _prefs?.setInt('themeMode', value);
  }

  /// 获取系统语言
  Future<String?> getSysLang() async {
    await init();
    return _prefs?.getString('sysLang');
  }

  /// 设置系统语言
  Future<void> setSysLang(String value) async {
    await init();
    await _prefs?.setString('sysLang', value);
  }

  /// 获取浏览器设置
  Future<Map<String, dynamic>?> getBrowserSetting() async {
    await init();
    final data = _prefs?.getString('browserSetting');
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 设置浏览器设置
  Future<void> setBrowserSetting(Map<String, dynamic> value) async {
    await init();
    await _prefs?.setString('browserSetting', jsonEncode(value));
  }

  /// 获取是否阅读登录条款
  Future<bool> getReadLoginClause() async {
    await init();
    return _prefs?.getBool('readLoginClause') ?? false;
  }

  /// 设置是否阅读登录条款
  Future<void> setReadLoginClause(bool value) async {
    await init();
    await _prefs?.setBool('readLoginClause', value);
  }

  /// 获取是否接受聊天条款
  Future<bool> hasAcceptedChatTerms() async {
    await init();
    return _prefs?.getBool('hasAcceptedChatTerms') ?? false;
  }

  /// 设置是否接受聊天条款
  Future<void> setHasAcceptedChatTerms(bool value) async {
    await init();
    await _prefs?.setBool('hasAcceptedChatTerms', value);
  }

  /// 获取服务条款显示状态
  Future<bool> getShowTermsOfService() async {
    await init();
    return _prefs?.getBool('showTermsOfService') ?? false;
  }

  /// 设置服务条款显示状态
  Future<void> setShowTermsOfService(bool value) async {
    await init();
    await _prefs?.setBool('showTermsOfService', value);
  }

  /// 获取后台挖矿音乐设置
  Future<int?> getBackgroundMiningMusic() async {
    await init();
    return _prefs?.getInt('backgroundMiningMusic');
  }

  /// 设置后台挖矿音乐
  Future<void> setBackgroundMiningMusic(int value) async {
    await init();
    await _prefs?.setInt('backgroundMiningMusic', value);
  }

  // ==================== 清理方法 ====================

  /// 清除所有敏感数据
  Future<void> clearSensitiveData() async {
    for (final key in _sensitiveKeys) {
      await _secureStorage.delete(key: key);
    }
    await _secureStorage.delete(key: 'miningData');
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}
