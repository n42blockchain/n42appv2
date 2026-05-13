// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:sqflite/sqflite.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';

import '../../../sqlite/app_database.dart';
import '../../pages/aa/session_key_models.dart';

/// SQLite-backed repository for [SessionKeyData].
///
/// All operations are scoped by [chainId] so that keys from different
/// networks do not interfere with each other.
class SessionKeyRepository {
  final AppDatabase _db;

  const SessionKeyRepository(this._db);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Load all session keys for [chainId], ordered by creation date descending.
  Future<List<SessionKeyData>> loadKeys(int chainId) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'aa_session_keys',
        where: 'chain_id = ?',
        whereArgs: [chainId],
        orderBy: 'created_at DESC',
      );
      return rows.map(SessionKeyData.fromDbMap).toList();
    } catch (e) {
      AppLogger.w('SessionKeyRepository', 'loadKeys error: $e');
      return [];
    }
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Persist a new [key]. Returns `true` on success.
  Future<bool> saveKey(SessionKeyData key) async {
    try {
      final db = await _db.database;
      await db.insert(
        'aa_session_keys',
        key.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      AppLogger.w('SessionKeyRepository', 'saveKey error: $e');
      return false;
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  /// Revoke the key identified by [keyAddress] on [chainId].
  ///
  /// Updates status to [SessionKeyStatus.revoked] in the local store.
  /// The caller is responsible for submitting the on-chain revocation
  /// transaction separately.
  Future<bool> revokeKey(String keyAddress, int chainId) async {
    try {
      final db = await _db.database;
      final count = await db.update(
        'aa_session_keys',
        {'status': SessionKeyStatus.revoked.name},
        where: 'key_address = ? AND chain_id = ?',
        whereArgs: [keyAddress, chainId],
      );
      return count > 0;
    } catch (e) {
      AppLogger.w('SessionKeyRepository', 'revokeKey error: $e');
      return false;
    }
  }

  /// Increment [transactionCount] and add [amountUsed] to [usedAmount]
  /// for the key identified by [keyAddress] on [chainId].
  Future<bool> recordUsage(
    String keyAddress,
    int chainId, {
    BigInt? amountUsed,
  }) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        'aa_session_keys',
        where: 'key_address = ? AND chain_id = ?',
        whereArgs: [keyAddress, chainId],
        limit: 1,
      );
      if (rows.isEmpty) return false;

      final existing = SessionKeyData.fromDbMap(rows.first);
      final newUsed = amountUsed == null
          ? existing.usedAmount
          : (existing.usedAmount ?? BigInt.zero) + amountUsed;
      final newCount = (existing.transactionCount ?? 0) + 1;

      final count = await db.update(
        'aa_session_keys',
        {
          'transaction_count': newCount,
          if (newUsed != null) 'used_amount': newUsed.toString(),
        },
        where: 'key_address = ? AND chain_id = ?',
        whereArgs: [keyAddress, chainId],
      );
      return count > 0;
    } catch (e) {
      AppLogger.w('SessionKeyRepository', 'recordUsage error: $e');
      return false;
    }
  }
}
