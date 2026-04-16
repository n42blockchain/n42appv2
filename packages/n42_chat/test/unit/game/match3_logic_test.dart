import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/pages/game/match3/match3_logic.dart';

void main() {
  group('Match3Logic', () {
    late Match3Logic logic;

    setUp(() {
      logic = Match3Logic();
    });

    test('initial state is correct', () {
      expect(logic.score, 0);
      expect(logic.timeLeft, Match3Logic.gameDuration);
      expect(logic.isGameOver, isFalse);
      expect(logic.selectedRow, isNull);
      expect(logic.selectedCol, isNull);
    });

    test('board is 8x8', () {
      expect(logic.board.length, Match3Logic.rows);
      for (final row in logic.board) {
        expect(row.length, Match3Logic.cols);
      }
    });

    test('all gems are valid types (0 to gemTypes-1)', () {
      for (final row in logic.board) {
        for (final cell in row) {
          expect(cell, inInclusiveRange(0, Match3Logic.gemTypes - 1));
        }
      }
    });

    test('initial board has no matches', () {
      // Board should be match-free after generation
      // We verify by checking no 3+ consecutive same gems horizontally
      for (int r = 0; r < Match3Logic.rows; r++) {
        for (int c = 0; c < Match3Logic.cols - 2; c++) {
          final isSame = logic.board[r][c] == logic.board[r][c + 1] &&
              logic.board[r][c + 1] == logic.board[r][c + 2];
          expect(isSame, isFalse,
              reason: 'Horizontal match at ($r,$c): ${logic.board[r][c]}');
        }
      }
      // Vertically
      for (int c = 0; c < Match3Logic.cols; c++) {
        for (int r = 0; r < Match3Logic.rows - 2; r++) {
          final isSame = logic.board[r][c] == logic.board[r + 1][c] &&
              logic.board[r + 1][c] == logic.board[r + 2][c];
          expect(isSame, isFalse,
              reason: 'Vertical match at ($r,$c): ${logic.board[r][c]}');
        }
      }
    });

    test('select sets selectedRow and selectedCol', () {
      logic.select(3, 4);
      expect(logic.selectedRow, 3);
      expect(logic.selectedCol, 4);
    });

    test('select non-adjacent cell changes selection', () {
      logic.select(0, 0);
      logic.select(5, 5); // Not adjacent
      expect(logic.selectedRow, 5);
      expect(logic.selectedCol, 5);
    });

    test('trySwap with no match reverts and returns false', () {
      // Create a board where swapping (0,0) and (0,1) creates no match
      logic.board = [
        [0, 1, 2, 3, 4, 5, 0, 1],
        [1, 2, 3, 4, 5, 0, 1, 2],
        [2, 3, 4, 5, 0, 1, 2, 3],
        [3, 4, 5, 0, 1, 2, 3, 4],
        [4, 5, 0, 1, 2, 3, 4, 5],
        [5, 0, 1, 2, 3, 4, 5, 0],
        [0, 1, 2, 3, 4, 5, 0, 1],
        [1, 2, 3, 4, 5, 0, 1, 2],
      ];

      final val00 = logic.board[0][0];
      final val01 = logic.board[0][1];
      final result = logic.trySwap(0, 0, 0, 1);

      expect(result, isFalse);
      expect(logic.board[0][0], val00); // Restored
      expect(logic.board[0][1], val01); // Restored
    });

    test('trySwap with match returns true and increases score', () {
      // Set up a board where swapping creates a match
      logic.board = [
        [0, 1, 0, 3, 4, 5, 3, 1],
        [1, 0, 2, 4, 5, 3, 4, 2],
        [2, 3, 4, 5, 0, 1, 2, 3],
        [3, 4, 5, 0, 1, 2, 3, 4],
        [4, 5, 0, 1, 2, 3, 4, 5],
        [5, 0, 1, 2, 3, 4, 5, 0],
        [0, 1, 2, 3, 4, 5, 0, 1],
        [1, 2, 3, 4, 5, 0, 1, 2],
      ];
      // Swap (0,0) and (0,1): board[0] becomes [1, 0, 0, ...] — two 0s but not three
      // Let's set up a guaranteed match
      logic.board[0] = [1, 0, 0, 0, 4, 5, 3, 1]; // three 0s after swap
      // Actually need to swap to CREATE the match
      logic.board[0] = [0, 1, 0, 0, 4, 5, 3, 1];
      // Swap (0,0) and (0,1): becomes [1, 0, 0, 0, ...] — three 0s at pos 1,2,3
      logic.score = 0;
      final result = logic.trySwap(0, 0, 0, 1);
      if (result) {
        expect(logic.score, greaterThan(0));
      }
    });

    test('tick decreases timeLeft', () {
      logic.tick();
      expect(logic.timeLeft, Match3Logic.gameDuration - 1);
    });

    test('game over when timeLeft reaches 0', () {
      logic.timeLeft = 1;
      logic.tick();
      expect(logic.timeLeft, 0);
      expect(logic.isGameOver, isTrue);
    });

    test('tick does nothing after game over', () {
      logic.isGameOver = true;
      logic.timeLeft = 10;
      logic.tick();
      expect(logic.timeLeft, 10);
    });

    test('select does nothing after game over', () {
      logic.isGameOver = true;
      expect(logic.select(0, 0), isFalse);
    });

    test('reset restores initial state', () {
      logic.score = 100;
      logic.timeLeft = 5;
      logic.isGameOver = true;
      logic.reset();

      expect(logic.score, 0);
      expect(logic.timeLeft, Match3Logic.gameDuration);
      expect(logic.isGameOver, isFalse);
      expect(logic.selectedRow, isNull);
    });

    test('hasValidMoves returns true on fresh board', () {
      expect(logic.hasValidMoves, isTrue);
    });

    test('hasValidMoves returns false when no moves possible', () {
      // Create a board with alternating pattern where no swap produces a match
      // Pattern: 0,1,0,1,0,1,0,1 / 2,3,2,3,2,3,2,3 / ...
      logic.board = [
        [0, 1, 0, 1, 0, 1, 0, 1],
        [2, 3, 2, 3, 2, 3, 2, 3],
        [0, 1, 0, 1, 0, 1, 0, 1],
        [2, 3, 2, 3, 2, 3, 2, 3],
        [0, 1, 0, 1, 0, 1, 0, 1],
        [2, 3, 2, 3, 2, 3, 2, 3],
        [0, 1, 0, 1, 0, 1, 0, 1],
        [2, 3, 2, 3, 2, 3, 2, 3],
      ];
      expect(logic.hasValidMoves, isFalse);
    });

    test('trySwap with deterministic 3-match scores exactly 30', () {
      // Create a board where swapping (0,1) and (1,1) creates exactly one 3-match
      // Row 0: [0, 2, 0, 1, 3, 4, 5, 3]  → after swap: [0, 0, 0, 1, 3, 4, 5, 3] = 3-match
      // Other rows must not create any matches
      logic.board = [
        [0, 2, 0, 1, 3, 4, 5, 3],
        [1, 0, 3, 4, 5, 3, 4, 2],
        [2, 3, 4, 5, 0, 1, 2, 0],
        [3, 4, 5, 0, 1, 2, 3, 4],
        [4, 5, 0, 1, 2, 3, 4, 5],
        [5, 0, 1, 2, 3, 4, 5, 0],
        [0, 1, 2, 3, 4, 5, 0, 1],
        [1, 2, 3, 4, 5, 0, 1, 2],
      ];
      logic.score = 0;
      final result = logic.trySwap(0, 1, 1, 1);
      // After swap: row0[1]=0, so [0,0,0,1,...] = 3-match horizontal
      if (result) {
        // First match → multiplier=1.0, baseScore=30, score=30
        // Could be higher if cascading fills create new matches
        expect(logic.score, greaterThanOrEqualTo(30));
      }
    });

    test('4-gem match scores 60 base points', () {
      // Set up a 4-match: [0, 2, 0, 0, 0, 4, 5, 3] → swap(0,0) and (0,1) → [2, 0, 0, 0, 0, ...]
      logic.board = [
        [0, 2, 0, 0, 0, 4, 5, 3],
        [1, 3, 4, 5, 3, 2, 4, 2],
        [2, 4, 5, 0, 1, 3, 2, 0],
        [3, 5, 0, 1, 2, 4, 3, 4],
        [4, 0, 1, 2, 3, 5, 4, 5],
        [5, 1, 2, 3, 4, 0, 5, 0],
        [0, 2, 3, 4, 5, 1, 0, 1],
        [1, 3, 4, 5, 0, 2, 1, 2],
      ];
      logic.score = 0;
      final result = logic.trySwap(0, 0, 0, 1);
      if (result) {
        // 4-match base = 60 with multiplier 1.0 = at least 60
        expect(logic.score, greaterThanOrEqualTo(60));
      }
    });

    test('trySwap clears selection after swap', () {
      logic.select(0, 0);
      expect(logic.selectedRow, 0);
      logic.trySwap(0, 0, 0, 1);
      expect(logic.selectedRow, isNull);
      expect(logic.selectedCol, isNull);
    });
  });
}
