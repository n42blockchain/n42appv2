import 'dart:math';

enum Direction { up, down, left, right }

class Game2048Logic {
  static const int size = 4;
  final Random _random = Random();

  List<List<int>> board = List.generate(size, (_) => List.filled(size, 0));
  int score = 0;
  bool _moved = false;

  Game2048Logic() {
    reset();
  }

  void reset() {
    board = List.generate(size, (_) => List.filled(size, 0));
    score = 0;
    _addRandomTile();
    _addRandomTile();
  }

  bool swipe(Direction dir) {
    _moved = false;
    switch (dir) {
      case Direction.left:
        for (int r = 0; r < size; r++) {
          board[r] = _merge(board[r]);
        }
      case Direction.right:
        for (int r = 0; r < size; r++) {
          board[r] = _merge(board[r].reversed.toList()).reversed.toList();
        }
      case Direction.up:
        for (int c = 0; c < size; c++) {
          final col = List.generate(size, (r) => board[r][c]);
          final merged = _merge(col);
          for (int r = 0; r < size; r++) {
            board[r][c] = merged[r];
          }
        }
      case Direction.down:
        for (int c = 0; c < size; c++) {
          final col = List.generate(size, (r) => board[r][c]).reversed.toList();
          final merged = _merge(col).reversed.toList();
          for (int r = 0; r < size; r++) {
            board[r][c] = merged[r];
          }
        }
    }

    if (_moved) {
      _addRandomTile();
    }
    return _moved;
  }

  List<int> _merge(List<int> row) {
    final original = List<int>.from(row);

    // Compact: remove zeros
    final nonZero = row.where((e) => e != 0).toList();
    // Merge adjacent equal
    for (int i = 0; i < nonZero.length - 1; i++) {
      if (nonZero[i] == nonZero[i + 1]) {
        nonZero[i] *= 2;
        score += nonZero[i];
        nonZero[i + 1] = 0;
      }
    }
    // Compact again
    final result = nonZero.where((e) => e != 0).toList();
    while (result.length < size) {
      result.add(0);
    }

    if (!_listEquals(original, result)) {
      _moved = true;
    }
    return result;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _addRandomTile() {
    final empty = <List<int>>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == 0) {
          empty.add([r, c]);
        }
      }
    }
    if (empty.isEmpty) return;

    final pos = empty[_random.nextInt(empty.length)];
    board[pos[0]][pos[1]] = _random.nextDouble() < 0.9 ? 2 : 4;
  }

  bool get isGameOver {
    // Check for empty cells
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == 0) return false;
      }
    }
    // Check for possible merges
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final val = board[r][c];
        if (r < size - 1 && board[r + 1][c] == val) return false;
        if (c < size - 1 && board[r][c + 1] == val) return false;
      }
    }
    return true;
  }

  bool get hasWon {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] >= 2048) return true;
      }
    }
    return false;
  }
}
