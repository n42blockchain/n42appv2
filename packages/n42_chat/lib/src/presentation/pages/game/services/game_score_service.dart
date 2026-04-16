import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_score.dart';
import '../../../../core/utils/debug_log.dart';

class GameScoreService {
  static const String _keyPrefix = 'game_scores_';
  static const int _maxStoredScores = 50;

  Future<void> saveScore(String gameId, int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$gameId';
      final existing = prefs.getStringList(key) ?? [];

      final newScore = GameScore(
        gameId: gameId,
        score: score,
        playedAt: DateTime.now(),
      );

      existing.add(jsonEncode(newScore.toJson()));

      // Trim to prevent unbounded growth
      if (existing.length > _maxStoredScores) {
        existing.removeRange(0, existing.length - _maxStoredScores);
      }

      await prefs.setStringList(key, existing);
    } catch (e) {
      // Score persistence is non-critical; silently ignore storage failures
      debugLog('Error: $e');
    }
  }

  Future<List<GameScore>> getTopScores(String gameId, {int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$gameId';
      final stored = prefs.getStringList(key) ?? [];

      final scores = <GameScore>[];
      for (final s in stored) {
        try {
          scores.add(GameScore.fromJson(jsonDecode(s) as Map<String, dynamic>));
        } catch (e) {
          // Skip corrupted entries
          debugLog('Error: $e');
        }
      }

      // For minesweeper, lower score (time) is better
      if (gameId == 'minesweeper') {
        scores.sort((a, b) => a.score.compareTo(b.score));
      } else {
        scores.sort((a, b) => b.score.compareTo(a.score));
      }

      return scores.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int?> getHighScore(String gameId) async {
    final scores = await getTopScores(gameId, limit: 1);
    return scores.isEmpty ? null : scores.first.score;
  }
}
