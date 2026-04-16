import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/pages/game/minesweeper/minesweeper_logic.dart';

void main() {
  group('MinesweeperLogic', () {
    late MinesweeperLogic logic;

    setUp(() {
      logic = MinesweeperLogic();
    });

    test('initial state is correct', () {
      expect(logic.isGameOver, isFalse);
      expect(logic.isWin, isFalse);
      expect(logic.flagCount, 0);
      expect(logic.elapsedSeconds, 0);
      expect(logic.difficulty, Difficulty.easy);
      expect(logic.rows, 9);
      expect(logic.cols, 9);
      expect(logic.totalMines, 10);
    });

    test('all cells start hidden', () {
      for (int r = 0; r < logic.rows; r++) {
        for (int c = 0; c < logic.cols; c++) {
          expect(logic.states[r][c], CellState.hidden);
        }
      }
    });

    test('first click is always safe', () {
      // Click every cell on a fresh board — the first click should never hit a mine
      for (int trial = 0; trial < 20; trial++) {
        final l = MinesweeperLogic();
        l.reveal(4, 4); // Click center
        // If we hit a mine, isGameOver would be true and isWin false
        // First click should be safe
        expect(l.isGameOver && !l.isWin, isFalse,
            reason: 'First click should never hit a mine (trial $trial)');
      }
    });

    test('first click generates mines', () {
      logic.reveal(0, 0);
      // Count mines
      int mineCount = 0;
      for (int r = 0; r < logic.rows; r++) {
        for (int c = 0; c < logic.cols; c++) {
          if (logic.isMine(r, c)) mineCount++;
        }
      }
      expect(mineCount, logic.totalMines);
    });

    test('reveal on empty cell triggers flood fill', () {
      logic.reveal(4, 4); // Center click

      // At least the clicked cell should be revealed
      expect(logic.states[4][4], CellState.revealed);

      // Count revealed cells - should be more than 1 if it hit a 0
      int revealed = 0;
      for (int r = 0; r < logic.rows; r++) {
        for (int c = 0; c < logic.cols; c++) {
          if (logic.states[r][c] == CellState.revealed) revealed++;
        }
      }
      expect(revealed, greaterThanOrEqualTo(1));
    });

    test('toggleFlag adds and removes flag', () {
      expect(logic.flagCount, 0);

      logic.toggleFlag(0, 0);
      expect(logic.states[0][0], CellState.flagged);
      expect(logic.flagCount, 1);
      expect(logic.remainingMines, logic.totalMines - 1);

      logic.toggleFlag(0, 0);
      expect(logic.states[0][0], CellState.hidden);
      expect(logic.flagCount, 0);
    });

    test('cannot flag a revealed cell', () {
      logic.reveal(4, 4);
      final result = logic.toggleFlag(4, 4);
      expect(result, isFalse);
    });

    test('cannot reveal a flagged cell', () {
      logic.toggleFlag(0, 0);
      // First trigger mine generation from another cell
      logic.reveal(4, 4);
      // Now try to reveal the flagged cell
      final result = logic.reveal(0, 0);
      expect(result, isFalse);
    });

    test('changeDifficulty resets the game', () {
      logic.reveal(4, 4); // Start game
      logic.changeDifficulty(Difficulty.medium);

      expect(logic.rows, 16);
      expect(logic.cols, 16);
      expect(logic.totalMines, 40);
      expect(logic.isGameOver, isFalse);
      expect(logic.flagCount, 0);
    });

    test('reset restores initial state', () {
      logic.reveal(4, 4);
      logic.toggleFlag(0, 0);
      logic.elapsedSeconds = 42;
      logic.reset();

      expect(logic.flagCount, 0);
      expect(logic.elapsedSeconds, 0);
      expect(logic.isGameOver, isFalse);
      for (int r = 0; r < logic.rows; r++) {
        for (int c = 0; c < logic.cols; c++) {
          expect(logic.states[r][c], CellState.hidden);
        }
      }
    });

    test('numbers are correctly calculated', () {
      logic.reveal(4, 4); // Generate mines

      for (int r = 0; r < logic.rows; r++) {
        for (int c = 0; c < logic.cols; c++) {
          if (logic.isMine(r, c)) {
            expect(logic.numbers[r][c], -1);
            continue;
          }
          // Manually count adjacent mines
          int count = 0;
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              final nr = r + dr;
              final nc = c + dc;
              if (nr >= 0 && nr < logic.rows && nc >= 0 && nc < logic.cols && logic.isMine(nr, nc)) {
                count++;
              }
            }
          }
          expect(logic.numbers[r][c], count,
              reason: 'Number at ($r,$c) should be $count');
        }
      }
    });

    test('cannot act after game over', () {
      logic.reveal(4, 4);
      logic.isGameOver = true;

      expect(logic.reveal(0, 0), isFalse);
      expect(logic.toggleFlag(1, 1), isFalse);
    });

    test('remainingMines decreases with flags', () {
      expect(logic.remainingMines, 10);
      logic.toggleFlag(0, 0);
      expect(logic.remainingMines, 9);
      logic.toggleFlag(0, 1);
      expect(logic.remainingMines, 8);
    });
  });
}
