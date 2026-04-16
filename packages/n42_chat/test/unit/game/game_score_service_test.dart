import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_chat/src/presentation/pages/game/services/game_score_service.dart';

void main() {
  group('GameScoreService', () {
    late GameScoreService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = GameScoreService();
    });

    test('saveScore and getHighScore returns saved score', () async {
      await service.saveScore('test_game', 100);
      final high = await service.getHighScore('test_game');
      expect(high, 100);
    });

    test('getHighScore returns null when no scores exist', () async {
      final high = await service.getHighScore('nonexistent');
      expect(high, isNull);
    });

    test('getHighScore returns highest score for normal games', () async {
      await service.saveScore('game_2048', 50);
      await service.saveScore('game_2048', 200);
      await service.saveScore('game_2048', 100);
      final high = await service.getHighScore('game_2048');
      expect(high, 200);
    });

    test('getHighScore returns lowest score for minesweeper', () async {
      await service.saveScore('minesweeper', 50);
      await service.saveScore('minesweeper', 200);
      await service.saveScore('minesweeper', 30);
      final high = await service.getHighScore('minesweeper');
      expect(high, 30);
    });

    test('getTopScores returns scores sorted descending for normal games', () async {
      await service.saveScore('match3', 30);
      await service.saveScore('match3', 100);
      await service.saveScore('match3', 50);
      final scores = await service.getTopScores('match3');
      expect(scores.length, 3);
      expect(scores[0].score, 100);
      expect(scores[1].score, 50);
      expect(scores[2].score, 30);
    });

    test('getTopScores returns scores sorted ascending for minesweeper', () async {
      await service.saveScore('minesweeper', 100);
      await service.saveScore('minesweeper', 30);
      await service.saveScore('minesweeper', 50);
      final scores = await service.getTopScores('minesweeper');
      expect(scores.length, 3);
      expect(scores[0].score, 30);
      expect(scores[1].score, 50);
      expect(scores[2].score, 100);
    });

    test('getTopScores respects limit parameter', () async {
      for (int i = 0; i < 15; i++) {
        await service.saveScore('test_game', i * 10);
      }
      final scores = await service.getTopScores('test_game', limit: 5);
      expect(scores.length, 5);
    });

    test('getTopScores returns empty list when no scores', () async {
      final scores = await service.getTopScores('empty_game');
      expect(scores, isEmpty);
    });

    test('saveScore trims old entries beyond max limit', () async {
      // Save 55 scores (max is 50)
      for (int i = 0; i < 55; i++) {
        await service.saveScore('trim_test', i);
      }
      final scores = await service.getTopScores('trim_test', limit: 100);
      expect(scores.length, lessThanOrEqualTo(50));
    });

    test('scores persist correct gameId and playedAt', () async {
      await service.saveScore('block_drop', 500);
      final scores = await service.getTopScores('block_drop');
      expect(scores.length, 1);
      expect(scores.first.gameId, 'block_drop');
      expect(scores.first.score, 500);
      expect(scores.first.playedAt.year, DateTime.now().year);
    });

    test('different gameIds store independently', () async {
      await service.saveScore('game_a', 100);
      await service.saveScore('game_b', 200);
      final scoresA = await service.getTopScores('game_a');
      final scoresB = await service.getTopScores('game_b');
      expect(scoresA.length, 1);
      expect(scoresB.length, 1);
      expect(scoresA.first.score, 100);
      expect(scoresB.first.score, 200);
    });
  });
}
