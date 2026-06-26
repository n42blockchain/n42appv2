import 'dart:math';

class Match3Logic {
  static const int rows = 8;
  static const int cols = 8;
  static const int gemTypes = 6;
  static const int gameDuration = 60; // seconds

  final Random _random = Random();

  late List<List<int>> board; // 0-5 gem types, -1 = empty
  int score = 0;
  int timeLeft = gameDuration;
  bool isGameOver = false;
  int? selectedRow;
  int? selectedCol;

  Match3Logic() {
    reset();
  }

  void reset() {
    score = 0;
    timeLeft = gameDuration;
    isGameOver = false;
    selectedRow = null;
    selectedCol = null;
    _generateBoard();
  }

  void _generateBoard() {
    board = List.generate(rows, (_) => List.generate(cols, (_) => _random.nextInt(gemTypes)));
    // Remove initial matches with iteration limit to prevent infinite loop
    var matches = _findMatches();
    int iterations = 0;
    while (matches.isNotEmpty && iterations < 100) {
      _removeMatches(matches);
      _applyGravity();
      _fillEmpty();
      matches = _findMatches();
      iterations++;
    }
  }

  bool select(int r, int c) {
    if (isGameOver) return false;

    if (selectedRow == null) {
      selectedRow = r;
      selectedCol = c;
      return true;
    }

    // Check if adjacent
    final dr = (r - selectedRow!).abs();
    final dc = (c - selectedCol!).abs();
    if ((dr == 1 && dc == 0) || (dr == 0 && dc == 1)) {
      return trySwap(selectedRow!, selectedCol!, r, c);
    }

    // Select new cell
    selectedRow = r;
    selectedCol = c;
    return true;
  }

  bool trySwap(int r1, int c1, int r2, int c2) {
    // Swap
    _swap(r1, c1, r2, c2);

    final matches = _findMatches();
    if (matches.isEmpty) {
      // Swap back - invalid move
      _swap(r1, c1, r2, c2);
      selectedRow = null;
      selectedCol = null;
      return false;
    }

    selectedRow = null;
    selectedCol = null;

    // Process chain reactions
    _processChain();
    return true;
  }

  void _processChain() {
    int chainCount = 0;

    while (true) {
      final matches = _findMatches();
      if (matches.isEmpty) break;

      for (final match in matches) {
        final baseScore = match.length == 3 ? 30 : (match.length == 4 ? 60 : 100);
        // Chain bonus: first match at 1x, subsequent chains at 1.5x
        final multiplier = chainCount == 0 ? 1.0 : 1.5 * chainCount;
        score += (baseScore * multiplier).round();
      }

      _removeMatches(matches);
      _applyGravity();
      _fillEmpty();
      chainCount++;
    }
  }

  void _swap(int r1, int c1, int r2, int c2) {
    final temp = board[r1][c1];
    board[r1][c1] = board[r2][c2];
    board[r2][c2] = temp;
  }

  List<List<List<int>>> _findMatches() {
    final matches = <List<List<int>>>[];
    final matched = List.generate(rows, (_) => List.filled(cols, false));

    // Horizontal
    for (int r = 0; r < rows; r++) {
      int start = 0;
      for (int c = 1; c <= cols; c++) {
        if (c < cols && board[r][c] == board[r][start] && board[r][c] >= 0) {
          continue;
        }
        if (c - start >= 3 && board[r][start] >= 0) {
          final match = <List<int>>[];
          for (int i = start; i < c; i++) {
            match.add([r, i]);
            matched[r][i] = true;
          }
          matches.add(match);
        }
        start = c;
      }
    }

    // Vertical
    for (int c = 0; c < cols; c++) {
      int start = 0;
      for (int r = 1; r <= rows; r++) {
        if (r < rows && board[r][c] == board[start][c] && board[r][c] >= 0) {
          continue;
        }
        if (r - start >= 3 && board[start][c] >= 0) {
          final match = <List<int>>[];
          for (int i = start; i < r; i++) {
            if (!matched[i][c]) {
              match.add([i, c]);
            }
          }
          if (match.isNotEmpty) matches.add(match);
        }
        start = r;
      }
    }

    return matches;
  }

  void _removeMatches(List<List<List<int>>> matches) {
    for (final match in matches) {
      for (final pos in match) {
        board[pos[0]][pos[1]] = -1;
      }
    }
  }

  void _applyGravity() {
    for (int c = 0; c < cols; c++) {
      int writeRow = rows - 1;
      for (int r = rows - 1; r >= 0; r--) {
        if (board[r][c] >= 0) {
          board[writeRow][c] = board[r][c];
          if (writeRow != r) {
            board[r][c] = -1;
          }
          writeRow--;
        }
      }
      for (int r = writeRow; r >= 0; r--) {
        board[r][c] = -1;
      }
    }
  }

  void _fillEmpty() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c] < 0) {
          board[r][c] = _random.nextInt(gemTypes);
        }
      }
    }
  }

  void tick() {
    if (isGameOver) return;
    timeLeft--;
    if (timeLeft <= 0) {
      timeLeft = 0;
      isGameOver = true;
    }
  }

  bool get hasValidMoves {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // Try swap right
        if (c < cols - 1) {
          _swap(r, c, r, c + 1);
          if (_findMatches().isNotEmpty) {
            _swap(r, c, r, c + 1);
            return true;
          }
          _swap(r, c, r, c + 1);
        }
        // Try swap down
        if (r < rows - 1) {
          _swap(r, c, r + 1, c);
          if (_findMatches().isNotEmpty) {
            _swap(r, c, r + 1, c);
            return true;
          }
          _swap(r, c, r + 1, c);
        }
      }
    }
    return false;
  }
}
