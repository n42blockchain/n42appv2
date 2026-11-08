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

import 'package:n42_wallet/core/utils/app_logger.dart';

abstract class SecureStore {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

class FlutterSecureStore implements SecureStore {
  FlutterSecureStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              // Import legacy sp_ values into an isolated, versioned namespace.
              storageNamespace: 'n42_secure_v11_preferences',
              resetOnError: false,
              preferencesKeyPrefix: 'sp_',
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
              accountName: 'n42wallet_prefs',
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

/// 安全存储偏好设置
///
/// 将敏感数据存储在 SecureStorage 中，非敏感数据存储在 SharedPreferences 中
/// 自动处理从 SharedPreferences 到 SecureStorage 的数据迁移
class SecurePreferences {
  static SecurePreferences? _instance;
  SharedPreferences? _prefs;
  final SecureStore _secureStorage;
  Future<void> _userInfoTail = Future<void>.value();

  // All SPUtil callers share this production singleton. Keep account reads,
  // writes and clears in invocation order, including failed operations.
  Future<T> _withUserInfo<T>(Future<T> Function() operation) {
    final result = _userInfoTail.then((_) => operation());
    _userInfoTail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<void>? _walletInfoTail;

  Future<T> _withWalletInfo<T>(Future<T> Function() operation) {
    final previous = _walletInfoTail;
    final result = previous == null
        ? Future<T>.sync(operation)
        : previous.then((_) => operation());
    late final Future<void> completion;
    void release() {
      if (identical(_walletInfoTail, completion)) _walletInfoTail = null;
    }

    completion = result.then<void>(
      (_) => release(),
      onError: (Object error, StackTrace stack) => release(),
    );
    _walletInfoTail = completion;
    return result;
  }

  SecurePreferences._({SecureStore? secureStorage})
    : _secureStorage = secureStorage ?? FlutterSecureStore();

  /// 获取单例实例
  static SecurePreferences get instance {
    _instance ??= SecurePreferences._();
    return _instance!;
  }

  @visibleForTesting
  factory SecurePreferences.test({
    required SharedPreferences prefs,
    required SecureStore secureStorage,
  }) {
    final instance = SecurePreferences._(secureStorage: secureStorage);
    instance._prefs = prefs;
    return instance;
  }

  /// 敏感数据键名列表（将存储在 SecureStorage 中）
  static const List<String> _sensitiveKeys = [
    'walletInfo',
    'security',
    'userInfo',
    'miningData',
  ];

  /// 初始化（使用缓存 Future 防止并发竞态）
  Future<void>? _initFuture;
  Future<void> init() => _initFuture ??= _doInit();

  Future<void> _doInit() async {
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
          if (secureValue == null || secureValue.isEmpty) {
            await _secureStorage.write(key: key, value: value);
          }
          await _prefs?.remove(key);
          AppLogger.d('SecurePreferences', 'migrated key: $key');
        }
      } catch (e) {
        AppLogger.w('SecurePreferences', 'migration failed for key $key: $e');
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
      AppLogger.w('SecurePreferences', 'failed to decode $key: $e');
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
  Future<void> setWalletInfo(Map<String, dynamic> map) {
    final encoded = jsonEncode(map);
    return _withWalletInfo(
      () => _secureStorage.write(key: 'walletInfo', value: encoded),
    );
  }

  /// Serialize one read/modify/write in the shared production storage instance.
  /// The synchronous mutation must not call another wallet-storage operation.
  /// Corrupt records fail before mutation; they are never replaced with {}.
  Future<T> updateWalletInfo<T>(T Function(Map<String, dynamic>) mutate) =>
      _withWalletInfo(() async {
        final encoded = await _secureStorage.read(key: 'walletInfo');
        Map<String, dynamic> data;
        try {
          final decoded = encoded == null || encoded.isEmpty
              ? <String, dynamic>{}
              : jsonDecode(encoded);
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException();
          }
          data = decoded;
        } on FormatException {
          // Decoder exceptions can contain secret record excerpts.
          throw StateError('Stored wallet data is invalid');
        }
        final result = mutate(data);
        if (result is Future) {
          throw ArgumentError('Wallet mutations must be synchronous');
        }
        await _secureStorage.write(key: 'walletInfo', value: jsonEncode(data));
        return result;
      });

  /// 获取钱包信息
  Future<Map<String, dynamic>?> getWalletInfo() =>
      _withWalletInfo(() => _readSecureJson('walletInfo'));

  /// 删除钱包信息
  Future<void> removeWalletInfo() =>
      _withWalletInfo(() => _secureStorage.delete(key: 'walletInfo'));

  // ==================== 安全设置（敏感） ====================

  /// 保存安全设置
  Future<void> setSecurity(Map<String, dynamic> value) async {
    await _secureStorage.write(key: 'security', value: jsonEncode(value));
  }

  /// 获取安全设置
  Future<Map<String, dynamic>?> getSecurity() => _readSecureJson('security');

  // ==================== 用户信息（敏感） ====================

  /// 保存用户信息
  Future<void> setUserInfo(Map<String, dynamic>? value) async {
    final encoded = value == null ? null : jsonEncode(value);
    return _withUserInfo(() async {
      await init();
      if (encoded == null) {
        await _secureStorage.delete(key: 'userInfo');
      } else {
        await _secureStorage.write(key: 'userInfo', value: encoded);
      }
      await _removeLegacyUserInfo();
    });
  }

  Future<void> _removeLegacyUserInfo() async {
    final prefs = _prefs;
    if (prefs != null && prefs.containsKey('userInfo')) {
      if (!await prefs.remove('userInfo')) {
        throw StateError('Failed to remove legacy account data');
      }
    }
  }

  /// 获取用户信息
  Future<Map<String, dynamic>?> getUserInfo() => _withUserInfo(() async {
    await init();
    return _readSecureJson('userInfo');
  });

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
  Future<void> clearSensitiveData() => _withUserInfo(
    () => _withWalletInfo(() async {
      await init();
      for (final key in _sensitiveKeys) {
        await _secureStorage.delete(key: key);
      }
      await _removeLegacyUserInfo();
    }),
  );

  /// 清除所有数据
  Future<void> clearAll() => _withUserInfo(
    () => _withWalletInfo(() async {
      await init();
      await _secureStorage.deleteAll();
      if (await _prefs?.clear() == false) {
        throw StateError('Failed to clear legacy preferences');
      }
    }),
  );
}
