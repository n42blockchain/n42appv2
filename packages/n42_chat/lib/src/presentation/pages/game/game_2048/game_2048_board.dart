import 'package:flutter/material.dart';

import 'game_2048_logic.dart';

class Game2048Board extends StatelessWidget {
  final Game2048Logic logic;
  final void Function(Direction) onSwipe;

  const Game2048Board({
    super.key,
    required this.logic,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final cellSize = (boardSize - 40) / 4;
        const spacing = 6.0;

        return Center(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! > 0) {
                onSwipe(Direction.right);
              } else {
                onSwipe(Direction.left);
              }
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! > 0) {
                onSwipe(Direction.down);
              } else {
                onSwipe(Direction.up);
              }
            },
            child: Container(
              width: boardSize - 16,
              height: boardSize - 16,
              padding: const EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: const Color(0xFFBBADA0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (r) {
                  return Expanded(
                    child: Row(
                      children: List.generate(4, (c) {
                        final value = logic.board[r][c];
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(spacing / 2),
                            decoration: BoxDecoration(
                              color: _tileColor(value),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                value == 0 ? '' : '$value',
                                style: TextStyle(
                                  fontSize: _fontSize(value, cellSize),
                                  fontWeight: FontWeight.bold,
                                  color: value <= 4
                                      ? const Color(0xFF776E65)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  double _fontSize(int value, double cellSize) {
    if (value >= 1024) return cellSize * 0.25;
    if (value >= 100) return cellSize * 0.32;
    return cellSize * 0.4;
  }

  Color _tileColor(int value) {
    switch (value) {
      case 0:
        return const Color(0xFFCDC1B4);
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0xFF3C3A32);
    }
  }
}
