// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:n42_wallet/src/sqlite/app_database.dart';
import 'package:n42_wallet/src/wallet/widgets/aa/batch_operation_item.dart';

/// AA 批量交易模板数据模型
class BatchTemplate {
  final int? id;
  final String name;
  final String chainSymbol;
  final List<BatchOperation> operations;
  final DateTime createdAt;
  final DateTime updatedAt;

  BatchTemplate({
    this.id,
    required this.name,
    required this.chainSymbol,
    required this.operations,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'name': name,
        'chain_symbol': chainSymbol,
        'operations': jsonEncode(operations.map((o) => o.toJson()).toList()),
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory BatchTemplate.fromDbMap(Map<String, dynamic> map) {
    final opsJson = jsonDecode(map['operations'] as String) as List<dynamic>;
    return BatchTemplate(
      id: map['id'] as int?,
      name: map['name'] as String,
      chainSymbol: map['chain_symbol'] as String,
      operations: opsJson
          .map((o) => BatchOperation.fromJson(o as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  BatchTemplate copyWith({
    int? id,
    String? name,
    String? chainSymbol,
    List<BatchOperation>? operations,
    DateTime? updatedAt,
  }) =>
      BatchTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        chainSymbol: chainSymbol ?? this.chainSymbol,
        operations: operations ?? this.operations,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}

/// AA 批量交易模板 CRUD Provider
class BatchTemplateProvider extends ChangeNotifier {
  final AppDatabase _db;
  List<BatchTemplate> _templates = [];
  bool _isLoading = false;

  BatchTemplateProvider(this._db);

  List<BatchTemplate> get templates => List.unmodifiable(_templates);
  bool get isLoading => _isLoading;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// 加载指定链的所有模板
  Future<void> loadTemplates(String chainSymbol) async {
    _isLoading = true;
    notifyListeners();
    try {
      final db = await _db.database;
      final rows = await db.query(
        'aa_batch_templates',
        where: 'chain_symbol = ?',
        whereArgs: [chainSymbol],
        orderBy: 'updated_at DESC',
      );
      _templates = rows.map(BatchTemplate.fromDbMap).toList();
    } catch (e) {
      assert(() {
        debugPrint('[BatchTemplateProvider] loadTemplates error: $e');
        return true;
      }());
      _templates = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 保存新模板；返回插入后的完整模板（含 id）
  Future<BatchTemplate?> saveTemplate({
    required String name,
    required String chainSymbol,
    required List<BatchOperation> operations,
  }) async {
    if (name.trim().isEmpty || operations.isEmpty) return null;
    try {
      final now = DateTime.now();
      final template = BatchTemplate(
        name: name.trim(),
        chainSymbol: chainSymbol,
        operations: operations,
        createdAt: now,
        updatedAt: now,
      );
      final db = await _db.database;
      final id = await db.insert(
        'aa_batch_templates',
        template.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final saved = template.copyWith(id: id);
      _templates.insert(0, saved);
      notifyListeners();
      return saved;
    } catch (e) {
      assert(() {
        debugPrint('[BatchTemplateProvider] saveTemplate error: $e');
        return true;
      }());
      return null;
    }
  }

  /// 删除模板
  Future<bool> deleteTemplate(int id) async {
    try {
      final db = await _db.database;
      final count = await db.delete(
        'aa_batch_templates',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count > 0) {
        _templates.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      assert(() {
        debugPrint('[BatchTemplateProvider] deleteTemplate error: $e');
        return true;
      }());
      return false;
    }
  }

  /// 更新模板名称
  Future<bool> renameTemplate(int id, String newName) async {
    if (newName.trim().isEmpty) return false;
    try {
      final db = await _db.database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final count = await db.update(
        'aa_batch_templates',
        {'name': newName.trim(), 'updated_at': now},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count > 0) {
        final idx = _templates.indexWhere((t) => t.id == id);
        if (idx >= 0) {
          _templates[idx] = _templates[idx].copyWith(name: newName.trim());
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      assert(() {
        debugPrint('[BatchTemplateProvider] renameTemplate error: $e');
        return true;
      }());
      return false;
    }
  }
}
