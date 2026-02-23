// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42appv2/src/sqlite/app_database.dart';
import 'package:n42appv2/src/wallet/models/portfolio_trade.dart';

/// CRUD operations for the local `portfolio_trades` table.
///
/// All methods are static; they resolve the singleton [AppDatabase] lazily.
class PortfolioTradeService {
  static const _table = 'portfolio_trades';

  /// Insert a new trade record. Returns the row id.
  static Future<int> insertTrade(PortfolioTrade trade) async {
    final db = await AppDatabase().database;
    return db.insert(_table, trade.toMapDb());
  }

  /// All trades for a given [coinId], ordered by buy-time ascending.
  static Future<List<PortfolioTrade>> getTradesForCoin(
      String coinId) async {
    if (coinId.isEmpty) return [];
    final db = await AppDatabase().database;
    final rows = await db.query(
      _table,
      where: 'coin_id = ?',
      whereArgs: [coinId],
      orderBy: 'buy_time_ms ASC',
    );
    return rows.map(PortfolioTrade.fromDb).toList();
  }

  /// Delete a trade by primary key.
  static Future<void> deleteTrade(int id) async {
    final db = await AppDatabase().database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// All trades across all coins, newest first.
  static Future<List<PortfolioTrade>> getAllTrades() async {
    final db = await AppDatabase().database;
    final rows =
        await db.query(_table, orderBy: 'buy_time_ms DESC');
    return rows.map(PortfolioTrade.fromDb).toList();
  }
}
