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
  })  : _secureStorage = secureStorage,
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
      debugPrint('[WalletDataMigration] Migration already completed');
      return 0;
    }

    debugPrint('[WalletDataMigration] Starting migration...');

    try {
      int migratedCount = 0;
      final walletAll = await _spUtil.getWalletInfo();

      if (walletAll == null) {
        await _markMigrationCompleted();
        return 0;
      }

      // 遍历所有用户的钱包
      for (final userEntry in walletAll.entries) {
        final userUuid = userEntry.key;
        final userData = userEntry.value;

        if (userData is! Map<String, dynamic>) continue;

        final wallets = userData['wallet'] as List<dynamic>?;
        if (wallets == null) continue;

        for (int i = 0; i < wallets.length; i++) {
          final wallet = wallets[i] as Map<String, dynamic>?;
          if (wallet == null) continue;

          final walletId = _getWalletId(wallet, userUuid, i);
          migratedCount += await _migrateWallet(wallet, walletId);
        }

        // 更新 SharedPreferences 中的数据，移除敏感信息
        userData['wallet'] = wallets
            .map((w) => _sanitizeWalletData(w as Map<String, dynamic>))
            .toList();
      }

      // 保存清理后的数据
      await _spUtil.setWalletInfo(walletAll);

      await _markMigrationCompleted();
      debugPrint('[WalletDataMigration] Migration completed: $migratedCount wallets migrated');

      return migratedCount;
    } catch (e) {
      debugPrint('[WalletDataMigration] Migration failed: $e');
      rethrow;
    }
  }

  /// 获取钱包唯一标识
  String _getWalletId(Map<String, dynamic> wallet, String userUuid, int index) {
    // 优先使用 timestamp，否则使用 userUuid + index
    final timestamp = wallet['timestamp'] as String?;
    return timestamp ?? '${userUuid}_$index';
  }

  /// 迁移单个钱包的敏感数据
  Future<int> _migrateWallet(Map<String, dynamic> wallet, String walletId) async {
    int migratedFields = 0;

    // 迁移助记词
    final mnemonic = wallet['mnemonic'] as String?;
    if (mnemonic != null && mnemonic.isNotEmpty) {
      await _secureStorage.saveMnemonic(
        walletId: walletId,
        mnemonic: mnemonic,
      );
      migratedFields++;
      debugPrint('[WalletDataMigration] Migrated mnemonic for wallet: $walletId');
    }

    // 迁移私钥
    final privateKey = wallet['privateKey'] as String?;
    if (privateKey != null && privateKey.isNotEmpty) {
      await _secureStorage.savePrivateKey(
        address: walletId,
        privateKey: privateKey,
      );
      migratedFields++;
      debugPrint('[WalletDataMigration] Migrated privateKey for wallet: $walletId');
    }

    // 迁移密码 (使用单独的前缀)
    final password = wallet['password'] as String?;
    if (password != null && password.isNotEmpty) {
      await _saveWalletPassword(walletId, password);
      migratedFields++;
      debugPrint('[WalletDataMigration] Migrated password for wallet: $walletId');
    }

    return migratedFields > 0 ? 1 : 0;
  }

  /// 清理钱包数据，移除敏感信息
  Map<String, dynamic> _sanitizeWalletData(Map<String, dynamic> wallet) {
    final sanitized = Map<String, dynamic>.from(wallet);

    // 移除敏感字段，用占位符替代以保持向后兼容
    if (sanitized.containsKey('mnemonic')) {
      sanitized['mnemonic'] = null; // 标记为已迁移
    }
    if (sanitized.containsKey('privateKey')) {
      sanitized['privateKey'] = null;
    }
    if (sanitized.containsKey('password')) {
      sanitized['password'] = null;
    }

    return sanitized;
  }

  /// 保存钱包密码到 SecureStorage
  Future<void> _saveWalletPassword(String walletId, String password) async {
    // 使用 saveWalletCredentials 方法存储密码
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
}

/// 扩展 SecureStorage 以支持钱包凭证访问
extension WalletCredentialsExtension on SecureStorage {
  /// 获取迁移后的助记词
  Future<String?> getWalletMnemonic(String walletId) async {
    return getMnemonic(walletId);
  }

  /// 获取迁移后的私钥
  Future<String?> getWalletPrivateKey(String walletId) async {
    return getPrivateKey(walletId);
  }
}
