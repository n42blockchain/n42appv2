import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/pages/game/game_2048/game_2048_logic.dart';

void main() {
  group('Game2048Logic', () {
    late Game2048Logic logic;

    setUp(() {
      logic = Game2048Logic();
    });

    test('initial board has exactly 2 tiles', () {
      int count = 0;
      for (final row in logic.board) {
        for (final cell in row) {
          if (cell != 0) count++;
        }
      }
      expect(count, 2);
    });

    test('initial tiles are 2 or 4', () {
      for (final row in logic.board) {
        for (final cell in row) {
          if (cell != 0) {
            expect(cell == 2 || cell == 4, isTrue);
          }
        }
      }
    });

    test('initial score is 0', () {
      expect(logic.score, 0);
    });

    test('reset clears board and score', () {
      // Make some moves
      logic.swipe(Direction.left);
      logic.swipe(Direction.down);
      final oldScore = logic.score;

      logic.reset();

      expect(logic.score, 0);
      int count = 0;
      for (final row in logic.board) {
        for (final cell in row) {
          if (cell != 0) count++;
        }
      }
      expect(count, 2);
    });

    test('swipe left merges tiles correctly', () {
      // Set up a known board
      logic.board = [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      logic.score = 0;

      logic.swipe(Direction.left);

      expect(logic.board[0][0], 4);
      expect(logic.score, 4);
    });

    test('swipe right merges tiles correctly', () {
      logic.board = [
        [0, 0, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      logic.score = 0;

      logic.swipe(Direction.right);

      expect(logic.board[0][3], 4);
      expect(logic.score, 4);
    });

    test('swipe up merges tiles correctly', () {
      logic.board = [
        [2, 0, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      logic.score = 0;

      logic.swipe(Direction.up);

      expect(logic.board[0][0], 4);
      expect(logic.score, 4);
    });

    test('swipe down merges tiles correctly', () {
      logic.board = [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [2, 0, 0, 0],
        [2, 0, 0, 0],
      ];
      logic.score = 0;

      logic.swipe(Direction.down);

      expect(logic.board[3][0], 4);
      expect(logic.score, 4);
    });

    test('merge does not cascade in single swipe: [2,2,2,2] => [4,4,0,0]', () {
      logic.board = [
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      logic.score = 0;

      logic.swipe(Direction.left);

      expect(logic.board[0][0], 4);
      expect(logic.board[0][1], 4);
      expect(logic.score, 8);
    });

    test('merge [2,2,4] left => [4,4,0]', () {
      logic.board = [
        [2, 2, 4, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      logic.score = 0;

      logic.swipe(Direction.left);

      expect(logic.board[0][0], 4);
      expect(logic.board[0][1], 4);
      expect(logic.score, 4);
    });

    test('no-op swipe does not add tile', () {
      // All tiles in leftmost column
      logic.board = [
        [2, 0, 0, 0],
        [4, 0, 0, 0],
        [8, 0, 0, 0],
        [16, 0, 0, 0],
      ];

      const int tilesBefore = 4;
      logic.swipe(Direction.left); // Should not move

      int tilesAfter = 0;
      for (final row in logic.board) {
        for (final cell in row) {
          if (cell != 0) tilesAfter++;
        }
      }
      expect(tilesAfter, tilesBefore); // No new tile added
    });

    test('isGameOver detects full board with no merges', () {
      logic.board = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ];
      expect(logic.isGameOver, isTrue);
    });

    test('isGameOver false when merge possible', () {
      logic.board = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 4], // last two can merge
      ];
      expect(logic.isGameOver, isFalse);
    });

    test('isGameOver false when empty cell exists', () {
      logic.board = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 0],
      ];
      expect(logic.isGameOver, isFalse);
    });

    test('hasWon detects 2048 tile', () {
      logic.board = [
        [2048, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      expect(logic.hasWon, isTrue);
    });

    test('hasWon false when no 2048', () {
      logic.board = [
        [1024, 512, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      expect(logic.hasWon, isFalse);
    });

    test('score accumulates correctly over multiple merges', () {
      logic.board = [
        [2, 2, 4, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      logic.score = 0;

      logic.swipe(Direction.left);
      // 2+2=4 (score +4), 4+4=8 (score +8) = total 12
      expect(logic.score, 12);
    });

    test('swipe returns true when board changes', () {
      logic.board = [
        [0, 0, 0, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      expect(logic.swipe(Direction.left), isTrue);
    });

    test('swipe returns false when board does not change', () {
      logic.board = [
        [2, 0, 0, 0],
        [4, 0, 0, 0],
        [8, 0, 0, 0],
        [16, 0, 0, 0],
      ];
      expect(logic.swipe(Direction.left), isFalse);
    });
  });
}
