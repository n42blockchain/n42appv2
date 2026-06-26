import 'package:flutter/material.dart';

import 'match3_logic.dart';

class Match3Board extends StatelessWidget {
  final Match3Logic logic;
  final void Function(int r, int c) onTap;
  final void Function(int r, int c, int r2, int c2)? onSwipe;

  const Match3Board({
    super.key,
    required this.logic,
    required this.onTap,
    this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth - 16;
        final maxH = constraints.maxHeight - 16;
        final cellW = maxW / Match3Logic.cols;
        final cellH = maxH / Match3Logic.rows;
        final cellSize = cellW < cellH ? cellW : cellH;

        return Center(
          child: SizedBox(
            width: cellSize * Match3Logic.cols,
            height: cellSize * Match3Logic.rows,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Match3Logic.cols,
              ),
              itemCount: Match3Logic.rows * Match3Logic.cols,
              itemBuilder: (context, index) {
                final r = index ~/ Match3Logic.cols;
                final c = index % Match3Logic.cols;
                return _buildGem(r, c, cellSize);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGem(int r, int c, double cellSize) {
    final gem = logic.board[r][c];
    final isSelected = logic.selectedRow == r && logic.selectedCol == c;

    return GestureDetector(
      onTap: () => onTap(r, c),
      onHorizontalDragEnd: (d) {
        if (d.primaryVelocity == null || onSwipe == null) return;
        if (d.primaryVelocity! > 0 && c < Match3Logic.cols - 1) {
          onSwipe!(r, c, r, c + 1);
        } else if (d.primaryVelocity! < 0 && c > 0) {
          onSwipe!(r, c, r, c - 1);
        }
      },
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity == null || onSwipe == null) return;
        if (d.primaryVelocity! > 0 && r < Match3Logic.rows - 1) {
          onSwipe!(r, c, r + 1, c);
        } else if (d.primaryVelocity! < 0 && r > 0) {
          onSwipe!(r, c, r - 1, c);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(isSelected ? 1 : 2),
        decoration: BoxDecoration(
          color: _gemColor(gem),
          borderRadius: BorderRadius.circular(cellSize * 0.2),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 6)]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              _gemEmoji(gem),
              style: TextStyle(fontSize: cellSize * 0.45),
            ),
          ),
        ),
      ),
    );
  }

  Color _gemColor(int gem) {
    switch (gem) {
      case 0: return Colors.red[400]!;
      case 1: return Colors.blue[400]!;
      case 2: return Colors.green[400]!;
      case 3: return Colors.amber[400]!;
      case 4: return Colors.purple[400]!;
      case 5: return Colors.orange[400]!;
      default: return Colors.grey[300]!;
    }
  }

  String _gemEmoji(int gem) {
    switch (gem) {
      case 0: return '❤️';
      case 1: return '💎';
      case 2: return '🟢';
      case 3: return '⭐';
      case 4: return '🔮';
      case 5: return '🔶';
      default: return '?';
    }
  }
}
