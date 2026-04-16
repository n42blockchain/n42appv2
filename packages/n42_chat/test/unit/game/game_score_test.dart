import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/pages/game/models/game_score.dart';

void main() {
  group('GameScore', () {
    test('constructor sets all fields', () {
      final now = DateTime(2025, 1, 15, 10, 30);
      final score = GameScore(gameId: 'test', score: 100, playedAt: now);

      expect(score.gameId, 'test');
      expect(score.score, 100);
      expect(score.playedAt, now);
    });

    test('toJson produces correct map', () {
      final now = DateTime(2025, 1, 15, 10, 30);
      final score = GameScore(gameId: 'game_2048', score: 5000, playedAt: now);
      final json = score.toJson();

      expect(json['gameId'], 'game_2048');
      expect(json['score'], 5000);
      expect(json['playedAt'], now.toIso8601String());
    });

    test('fromJson parses correctly', () {
      final json = {
        'gameId': 'minesweeper',
        'score': 42,
        'playedAt': '2025-01-15T10:30:00.000',
      };
      final score = GameScore.fromJson(json);

      expect(score.gameId, 'minesweeper');
      expect(score.score, 42);
      expect(score.playedAt, DateTime(2025, 1, 15, 10, 30));
    });

    test('roundtrip toJson/fromJson preserves data', () {
      final original = GameScore(
        gameId: 'block_drop',
        score: 9999,
        playedAt: DateTime(2025, 6, 20, 14, 15, 30),
      );
      final restored = GameScore.fromJson(original.toJson());

      expect(restored.gameId, original.gameId);
      expect(restored.score, original.score);
      expect(restored.playedAt.year, original.playedAt.year);
      expect(restored.playedAt.month, original.playedAt.month);
      expect(restored.playedAt.day, original.playedAt.day);
    });

    test('fromJson handles zero score', () {
      final json = {
        'gameId': 'test',
        'score': 0,
        'playedAt': '2025-01-01T00:00:00.000',
      };
      final score = GameScore.fromJson(json);
      expect(score.score, 0);
    });

    test('fromJson handles large score', () {
      final json = {
        'gameId': 'test',
        'score': 999999999,
        'playedAt': '2025-01-01T00:00:00.000',
      };
      final score = GameScore.fromJson(json);
      expect(score.score, 999999999);
    });
  });
}
