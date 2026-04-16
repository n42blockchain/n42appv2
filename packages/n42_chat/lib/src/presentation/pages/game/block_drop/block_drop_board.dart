import 'package:flutter/material.dart';

import 'block_drop_logic.dart';

Color pieceColor(int index) {
  switch (index) {
    case 1: return Colors.cyan;     // I
    case 2: return Colors.yellow;   // O
    case 3: return Colors.purple;   // T
    case 4: return Colors.green;    // S
    case 5: return Colors.red;      // Z
    case 6: return Colors.orange;   // L
    case 7: return Colors.blue;     // J
    default: return Colors.white;
  }
}

class BlockDropBoard extends StatelessWidget {
  final BlockDropLogic logic;

  const BlockDropBoard({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final maxW = constraints.maxWidth;
        final cellH = maxH / BlockDropLogic.boardRows;
        final cellW = maxW / BlockDropLogic.boardCols;
        final cellSize = cellW < cellH ? cellW : cellH;
        final boardW = cellSize * BlockDropLogic.boardCols;
        final boardH = cellSize * BlockDropLogic.boardRows;

        final renderBoard = logic.renderBoard;

        return Center(
          child: Container(
            width: boardW,
            height: boardH,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[700]!, width: 1),
              color: Colors.grey[900],
            ),
            child: CustomPaint(
              size: Size(boardW, boardH),
              painter: _BoardPainter(renderBoard, cellSize),
            ),
          ),
        );
      },
    );
  }
}

class _BoardPainter extends CustomPainter {
  final List<List<int>> board;
  final double cellSize;

  _BoardPainter(this.board, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    for (int r = 0; r <= BlockDropLogic.boardRows; r++) {
      canvas.drawLine(
        Offset(0, r * cellSize),
        Offset(size.width, r * cellSize),
        gridPaint,
      );
    }
    for (int c = 0; c <= BlockDropLogic.boardCols; c++) {
      canvas.drawLine(
        Offset(c * cellSize, 0),
        Offset(c * cellSize, size.height),
        gridPaint,
      );
    }

    // Draw cells
    for (int r = 0; r < BlockDropLogic.boardRows; r++) {
      for (int c = 0; c < BlockDropLogic.boardCols; c++) {
        final val = board[r][c];
        if (val == 0) continue;

        final isGhost = val < 0;
        final colorIdx = val.abs();
        final color = pieceColor(colorIdx);

        final rect = Rect.fromLTWH(
          c * cellSize + 0.5,
          r * cellSize + 0.5,
          cellSize - 1,
          cellSize - 1,
        );

        final paint = Paint()
          ..color = isGhost ? color.withValues(alpha: 0.25) : color
          ..style = PaintingStyle.fill;
        canvas.drawRect(rect, paint);

        if (!isGhost) {
          // Highlight border
          final borderPaint = Paint()
            ..color = color.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawRect(rect, borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    if (oldDelegate.cellSize != cellSize) return true;
    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board[r].length; c++) {
        if (oldDelegate.board[r][c] != board[r][c]) return true;
      }
    }
    return false;
  }
}

class NextPieceWidget extends StatelessWidget {
  final Piece? piece;

  const NextPieceWidget({super.key, this.piece});

  @override
  Widget build(BuildContext context) {
    if (piece == null) return const SizedBox.shrink();

    final shape = piece!.shape;
    final rows = shape.length;
    final cols = shape[0].length;

    return SizedBox(
      width: cols * 16.0,
      height: rows * 16.0,
      child: CustomPaint(
        painter: _MiniPiecePainter(shape, piece!.colorIndex),
      ),
    );
  }
}

class _MiniPiecePainter extends CustomPainter {
  final List<List<int>> shape;
  final int colorIndex;

  _MiniPiecePainter(this.shape, this.colorIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / shape[0].length;
    final cellH = size.height / shape.length;

    final color = pieceColor(colorIndex);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int r = 0; r < shape.length; r++) {
      for (int c = 0; c < shape[r].length; c++) {
        if (shape[r][c] == 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(c * cellW + 0.5, r * cellH + 0.5, cellW - 1, cellH - 1),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
