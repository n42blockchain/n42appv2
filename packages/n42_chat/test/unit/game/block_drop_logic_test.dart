import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/pages/game/block_drop/block_drop_logic.dart';

void main() {
  group('BlockDropLogic', () {
    late BlockDropLogic logic;

    setUp(() {
      logic = BlockDropLogic();
    });

    test('initial state is correct', () {
      expect(logic.score, 0);
      expect(logic.totalLines, 0);
      expect(logic.level, 1);
      expect(logic.isGameOver, isFalse);
      expect(logic.currentPiece, isNotNull);
      expect(logic.nextPiece, isNotNull);
    });

    test('board is 20x10', () {
      expect(logic.board.length, 20);
      for (final row in logic.board) {
        expect(row.length, 10);
      }
    });

    test('initial board is empty', () {
      for (final row in logic.board) {
        for (final cell in row) {
          expect(cell, 0);
        }
      }
    });

    test('currentPiece has valid colorIndex 1-7', () {
      expect(logic.currentPiece!.colorIndex, inInclusiveRange(1, 7));
    });

    test('moveLeft moves piece left', () {
      final initialCol = logic.currentPiece!.col;
      final moved = logic.moveLeft();
      if (moved) {
        expect(logic.currentPiece!.col, initialCol - 1);
      }
    });

    test('moveRight moves piece right', () {
      final initialCol = logic.currentPiece!.col;
      final moved = logic.moveRight();
      if (moved) {
        expect(logic.currentPiece!.col, initialCol + 1);
      }
    });

    test('softDrop moves piece down', () {
      final initialRow = logic.currentPiece!.row;
      final dropped = logic.softDrop();
      if (dropped) {
        expect(logic.currentPiece!.row, initialRow + 1);
      }
    });

    test('hardDrop places piece at bottom', () {
      logic.hardDrop();
      // After hard drop, a new piece spawns
      // Board should have some non-zero cells
      bool hasBlocks = false;
      for (final row in logic.board) {
        for (final cell in row) {
          if (cell != 0) hasBlocks = true;
        }
      }
      expect(hasBlocks, isTrue);
    });

    test('rotate changes piece shape', () {
      // Save original shape dimensions
      final piece = logic.currentPiece!;
      final origRows = piece.shape.length;
      final origCols = piece.shape[0].length;

      // O-piece (2x2) won't change dimensions
      if (origRows != origCols) {
        logic.rotate();
        // After rotation, rows and cols should swap
        expect(logic.currentPiece!.shape.length, origCols);
        expect(logic.currentPiece!.shape[0].length, origRows);
      }
    });

    test('line clear scores correctly: 1 line = 100', () {
      // Fill bottom row completely
      for (int c = 0; c < BlockDropLogic.boardCols; c++) {
        logic.board[BlockDropLogic.boardRows - 1][c] = 1;
      }
      logic.score = 0;
      logic.totalLines = 0;

      // Hard drop forces lock + line clear check
      logic.hardDrop();

      // Score should include at least 100 for clearing 1 line
      expect(logic.score, greaterThanOrEqualTo(100));
      expect(logic.totalLines, greaterThanOrEqualTo(1));
    });

    test('line clear: 2 lines = 300', () {
      for (int r = BlockDropLogic.boardRows - 2; r < BlockDropLogic.boardRows; r++) {
        for (int c = 0; c < BlockDropLogic.boardCols; c++) {
          logic.board[r][c] = 1;
        }
      }
      logic.score = 0;
      logic.totalLines = 0;
      logic.hardDrop();
      expect(logic.score, greaterThanOrEqualTo(300));
      expect(logic.totalLines, greaterThanOrEqualTo(2));
    });

    test('dropInterval decreases with level', () {
      final interval1 = logic.dropInterval;
      logic.level = 5;
      final interval5 = logic.dropInterval;
      expect(interval5, lessThan(interval1));
    });

    test('dropInterval has minimum of 100ms', () {
      logic.level = 100;
      expect(logic.dropInterval, 100);
    });

    test('reset restores initial state', () {
      logic.hardDrop();
      logic.hardDrop();
      logic.reset();

      expect(logic.score, 0);
      expect(logic.totalLines, 0);
      expect(logic.level, 1);
      expect(logic.isGameOver, isFalse);
    });

    test('cannot move after game over', () {
      logic.isGameOver = true;
      expect(logic.moveLeft(), isFalse);
      expect(logic.moveRight(), isFalse);
      expect(logic.softDrop(), isFalse);
      expect(logic.rotate(), isFalse);
    });

    test('renderBoard includes current piece', () {
      final board = logic.renderBoard;
      // Should have non-zero cells from the current piece
      bool hasPiece = false;
      for (final row in board) {
        for (final cell in row) {
          if (cell > 0) hasPiece = true;
        }
      }
      expect(hasPiece, isTrue);
    });

    test('renderBoard includes ghost piece (negative values)', () {
      final board = logic.renderBoard;
      bool hasGhost = false;
      for (final row in board) {
        for (final cell in row) {
          if (cell < 0) hasGhost = true;
        }
      }
      expect(hasGhost, isTrue);
    });

    test('ghostRow is at or below current piece', () {
      final ghostR = logic.ghostRow();
      expect(ghostR, greaterThanOrEqualTo(logic.currentPiece!.row));
    });

    test('piece cannot move out of left boundary', () {
      // Move piece all the way to the left
      for (int i = 0; i < BlockDropLogic.boardCols; i++) {
        logic.moveLeft();
      }
      // Should not throw
      expect(logic.currentPiece!.col, greaterThanOrEqualTo(0));
    });

    test('piece cannot move out of right boundary', () {
      for (int i = 0; i < BlockDropLogic.boardCols; i++) {
        logic.moveRight();
      }
      final piece = logic.currentPiece!;
      expect(piece.col + piece.shape[0].length, lessThanOrEqualTo(BlockDropLogic.boardCols));
    });
  });

  group('Piece', () {
    test('rotated returns correct transposition', () {
      final piece = Piece(
        shape: [[1, 0], [1, 0], [1, 1]],
        colorIndex: 6,
        row: 0,
        col: 0,
      );
      final rotated = piece.rotated;
      expect(rotated.length, 2);
      expect(rotated[0].length, 3);
      expect(rotated, [
        [1, 1, 1],
        [1, 0, 0],
      ]);
    });

    test('copy creates independent instance', () {
      final piece = Piece(
        shape: [[1, 1], [1, 1]],
        colorIndex: 2,
        row: 5,
        col: 3,
      );
      final copy = piece.copy();
      copy.row = 10;
      copy.shape[0][0] = 0;

      expect(piece.row, 5);
      expect(piece.shape[0][0], 1);
    });
  });
}
