// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 钱包数据迁移服务
///
/// 将敏感数据从 SharedPreferences 迁移到 SecureStorage
/// 这是一个一次性迁移，用于修复安全问题
///
/// 敏感数据包括:
/// - mnemonic (助记词)
/// - privateKey (私钥)
/// - password (密码)
class WalletDataMigration {
  final SecureStorage _secureStorage;
  final SPUtil _spUtil;

  static const String _migrationCompletedKey = 'wallet_migration_completed_v1';
  static const String _walletPasswordPrefix = 'wallet_password_';

  WalletDataMigration({
    required SecureStorage secureStorage,
    required SPUtil spUtil,
  }) : _secureStorage = secureStorage,
       _spUtil = spUtil;

  /// 检查是否需要迁移
  Future<bool> needsMigration() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_migrationCompletedKey) ?? false);
  }

  /// 执行迁移
  ///
  /// 返回迁移的钱包数量
  Future<int> migrate() async {
    if (!await needsMigration()) {
      _debugLog('[WalletDataMigration] Migration already completed');
      return 0;
    }

    _debugLog('[WalletDataMigration] Starting migration...');

    try {
      int migratedCount = 0;
      final walletAll = await _spUtil.getWalletInfo();

      if (walletAll == null) {
        await _markMigrationCompleted();
        return 0;
      }

      final sanitizedWalletAll = Map<String, dynamic>.from(walletAll);

      // 遍历所有用户的钱包
      for (final userEntry in sanitizedWalletAll.entries.toList()) {
        final userUuid = userEntry.key;
        final userData = userEntry.value;

        if (userData is! Map<String, dynamic>) continue;

        final mutableUserData = Map<String, dynamic>.from(userData);
        sanitizedWalletAll[userUuid] = mutableUserData;

        final rawWallets = mutableUserData['wallet'];
        if (rawWallets is! List) continue;
        final wallets = List<dynamic>.from(rawWallets);

        for (int i = 0; i < wallets.length; i++) {
          final wallet = _asWalletMap(wallets[i]);
          if (wallet == null) continue;

          final walletId = _getWalletId(wallet, userUuid, i);
          migratedCount += await _migrateWallet(wallet, walletId);
        }

        // 更新 SharedPreferences 中的数据，移除敏感信息
        mutableUserData['wallet'] = List<dynamic>.from(
          wallets.map(_sanitizeWalletEntry),
        );
      }

      // 保存清理后的数据
      await _spUtil.setWalletInfo(sanitizedWalletAll);

      await _markMigrationCompleted();
      _debugLog(
        '[WalletDataMigration] Migration completed: '
        '$migratedCount wallets migrated',
      );

      return migratedCount;
    } catch (e) {
      _debugLog('[WalletDataMigration] Migration failed: $e');
      rethrow;
    }
  }

  /// 获取钱包唯一标识
  String _getWalletId(Map<String, dynamic> wallet, String userUuid, int index) {
    // 优先使用钱包地址（最稳定的唯一标识）
    final address = wallet['address']?.toString().trim() ?? '';
    if (address.isNotEmpty) return '${userUuid}_$address';
    // 其次使用 timestamp
    final timestamp = wallet['timestamp']?.toString().trim() ?? '';
    if (timestamp.isNotEmpty) return '${userUuid}_$timestamp';
    // 最后 fallback 到 index（不稳定，但避免空 ID）
    return '${userUuid}_$index';
  }

  /// 迁移单个钱包的敏感数据
  Future<int> _migrateWallet(
    Map<String, dynamic> wallet,
    String walletId,
  ) async {
    int migratedFields = 0;

    // 迁移助记词
    final mnemonic = wallet['mnemonic'] as String?;
    if (mnemonic != null && mnemonic.isNotEmpty) {
      await _secureStorage.saveMnemonic(walletId: walletId, mnemonic: mnemonic);
      migratedFields++;
      _debugLog(
        '[WalletDataMigration] Migrated mnemonic for wallet: '
        '${_maskWalletId(walletId)}',
      );
    }

    // 迁移私钥
    final privateKey = wallet['privateKey'] as String?;
    if (privateKey != null && privateKey.isNotEmpty) {
      await _secureStorage.savePrivateKey(
        address: walletId,
        privateKey: privateKey,
      );
      migratedFields++;
      _debugLog(
        '[WalletDataMigration] Migrated privateKey for wallet: '
        '${_maskWalletId(walletId)}',
      );
    }

    // 迁移密码 (使用单独的前缀)
    final password = wallet['password'] as String?;
    if (password != null && password.isNotEmpty) {
      await _saveWalletPassword(walletId, password);
      migratedFields++;
      _debugLog(
        '[WalletDataMigration] Migrated password for wallet: '
        '${_maskWalletId(walletId)}',
      );
    }

    return migratedFields > 0 ? 1 : 0;
  }

  /// 清理钱包数据，移除敏感信息
  Map<String, dynamic> _sanitizeWalletData(Map<String, dynamic> wallet) {
    final sanitized = Map<String, dynamic>.from(wallet);
    // 完全移除敏感字段 key，而非设为 null（避免暴露数据结构）
    for (final field in ['mnemonic', 'privateKey', 'password']) {
      sanitized.remove(field);
    }
    return sanitized;
  }

  Object? _sanitizeWalletEntry(Object? wallet) {
    if (wallet is Map<String, dynamic>) {
      return _sanitizeWalletData(wallet);
    }
    if (wallet is Map) {
      return _sanitizeWalletData(Map<String, dynamic>.from(wallet));
    }
    return wallet;
  }

  Map<String, dynamic>? _asWalletMap(Object? wallet) {
    if (wallet is Map<String, dynamic>) {
      return wallet;
    }
    if (wallet is Map) {
      return Map<String, dynamic>.from(wallet);
    }
    return null;
  }

  /// 保存钱包密码到 SecureStorage
  Future<void> _saveWalletPassword(String walletId, String password) async {
    await _secureStorage.saveWalletCredentials(
      address: '$_walletPasswordPrefix$walletId',
      credentials: {'password': password},
    );
  }

  /// 获取钱包密码
  Future<String?> getWalletPassword(String walletId) async {
    final creds = await _secureStorage.getWalletCredentials(
      '$_walletPasswordPrefix$walletId',
    );
    return creds?['password'] as String?;
  }

  /// 标记迁移完成
  Future<void> _markMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationCompletedKey, true);
  }

  /// 重置迁移状态 (仅用于测试)
  @visibleForTesting
  Future<void> resetMigration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationCompletedKey);
  }

  static String _maskWalletId(String walletId) {
    if (walletId.length <= 8) return '***';
    return '${walletId.substring(0, 4)}***${walletId.substring(walletId.length - 4)}';
  }

  static void _debugLog(String message) {
    assert(() {
      debugPrint(message);
      return true;
    }());
  }
}

/// 扩展 SecureStorage 以支持钱包凭证访问
extension WalletCredentialsExtension on SecureStorage {
  /// 获取迁移后的助记词
  Future<String?> getWalletMnemonic(String walletId) => getMnemonic(walletId);

  /// 获取迁移后的私钥
  Future<String?> getWalletPrivateKey(String walletId) =>
      getPrivateKey(walletId);
}
