import 'package:flutter/material.dart';

import 'minesweeper_logic.dart';

class MinesweeperBoard extends StatelessWidget {
  final MinesweeperLogic logic;
  final void Function(int r, int c) onTap;
  final void Function(int r, int c) onLongPress;

  const MinesweeperBoard({
    super.key,
    required this.logic,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth - 16;
        final maxH = constraints.maxHeight - 16;
        final cellW = maxW / logic.cols;
        final cellH = maxH / logic.rows;
        final cellSize = cellW < cellH ? cellW : cellH;

        return Center(
          child: SizedBox(
            width: cellSize * logic.cols,
            height: cellSize * logic.rows,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: logic.cols,
              ),
              itemCount: logic.rows * logic.cols,
              itemBuilder: (context, index) {
                final r = index ~/ logic.cols;
                final c = index % logic.cols;
                return _buildCell(r, c, cellSize);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(int r, int c, double cellSize) {
    final state = logic.states[r][c];
    final number = logic.numbers[r][c];

    return GestureDetector(
      onTap: () => onTap(r, c),
      onLongPress: () => onLongPress(r, c),
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: _cellColor(state, r, c),
          border: state != CellState.revealed
              ? Border(
                  top: const BorderSide(color: Colors.white, width: 1.5),
                  left: const BorderSide(color: Colors.white, width: 1.5),
                  bottom: BorderSide(color: Colors.grey[600]!, width: 1.5),
                  right: BorderSide(color: Colors.grey[600]!, width: 1.5),
                )
              : Border.all(color: Colors.grey[400]!, width: 0.5),
        ),
        child: Center(
          child: _cellContent(state, number, r, c, cellSize),
        ),
      ),
    );
  }

  Color _cellColor(CellState state, int r, int c) {
    if (state != CellState.revealed) {
      return Colors.grey[350]!;
    }
    if (logic.isMine(r, c)) {
      return Colors.red[300]!;
    }
    return Colors.grey[200]!;
  }

  Widget? _cellContent(CellState state, int number, int r, int c, double cellSize) {
    final fontSize = cellSize * 0.5;

    if (state == CellState.flagged) {
      return Text('🚩', style: TextStyle(fontSize: fontSize * 0.8));
    }

    if (state != CellState.revealed) return null;

    if (logic.isMine(r, c)) {
      return Text('💣', style: TextStyle(fontSize: fontSize * 0.8));
    }

    if (number == 0) return null;

    return Text(
      '$number',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: _numberColor(number),
      ),
    );
  }

  Color _numberColor(int n) {
    switch (n) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.purple;
      case 5: return Colors.brown;
      case 6: return Colors.teal;
      case 7: return Colors.black;
      case 8: return Colors.grey;
      default: return Colors.black;
    }
  }
}
