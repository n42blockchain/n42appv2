import 'dart:math';

enum CellState { hidden, revealed, flagged }

enum Difficulty {
  easy(9, 9, 10),
  medium(16, 16, 40);

  final int rows;
  final int cols;
  final int mines;
  const Difficulty(this.rows, this.cols, this.mines);
}

class MinesweeperLogic {
  final Random _random = Random();

  late Difficulty difficulty;
  late List<List<bool>> _mines;
  late List<List<CellState>> states;
  late List<List<int>> numbers;
  int flagCount = 0;
  int elapsedSeconds = 0;
  bool isGameOver = false;
  bool isWin = false;
  bool _firstClick = true;

  MinesweeperLogic({this.difficulty = Difficulty.easy}) {
    reset();
  }

  int get rows => difficulty.rows;
  int get cols => difficulty.cols;
  int get totalMines => difficulty.mines;
  int get remainingMines => totalMines - flagCount;

  void reset() {
    _mines = List.generate(rows, (_) => List.filled(cols, false));
    states = List.generate(rows, (_) => List.filled(cols, CellState.hidden));
    numbers = List.generate(rows, (_) => List.filled(cols, 0));
    flagCount = 0;
    elapsedSeconds = 0;
    isGameOver = false;
    isWin = false;
    _firstClick = true;
  }

  void changeDifficulty(Difficulty d) {
    difficulty = d;
    reset();
  }

  void _generateMines(int safeR, int safeC) {
    final safeZone = <String>{};
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        safeZone.add('${safeR + dr},${safeC + dc}');
      }
    }

    final availableCells = rows * cols - safeZone.length;
    final minesToPlace = totalMines > availableCells ? availableCells : totalMines;

    int placed = 0;
    int attempts = 0;
    final maxAttempts = rows * cols * 10;
    while (placed < minesToPlace && attempts < maxAttempts) {
      final r = _random.nextInt(rows);
      final c = _random.nextInt(cols);
      if (!_mines[r][c] && !safeZone.contains('$r,$c')) {
        _mines[r][c] = true;
        placed++;
      }
      attempts++;
    }

    // Calculate numbers
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (_mines[r][c]) {
          numbers[r][c] = -1;
          continue;
        }
        int count = 0;
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = r + dr;
            final nc = c + dc;
            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && _mines[nr][nc]) {
              count++;
            }
          }
        }
        numbers[r][c] = count;
      }
    }
  }

  bool reveal(int r, int c) {
    if (isGameOver || states[r][c] != CellState.hidden) return false;

    if (_firstClick) {
      _firstClick = false;
      _generateMines(r, c);
    }

    if (_mines[r][c]) {
      // Game over - reveal all mines
      isGameOver = true;
      isWin = false;
      _revealAllMines();
      return true;
    }

    _floodReveal(r, c);
    _checkWin();
    return true;
  }

  void _floodReveal(int startR, int startC) {
    final stack = <(int, int)>[(startR, startC)];

    while (stack.isNotEmpty) {
      final (r, c) = stack.removeLast();
      if (r < 0 || r >= rows || c < 0 || c >= cols) continue;
      if (states[r][c] != CellState.hidden) continue;

      states[r][c] = CellState.revealed;

      if (numbers[r][c] == 0) {
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            stack.add((r + dr, c + dc));
          }
        }
      }
    }
  }

  bool toggleFlag(int r, int c) {
    if (isGameOver || states[r][c] == CellState.revealed) return false;

    if (states[r][c] == CellState.flagged) {
      states[r][c] = CellState.hidden;
      flagCount--;
    } else {
      states[r][c] = CellState.flagged;
      flagCount++;
    }
    return true;
  }

  void _checkWin() {
    int hiddenCount = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (states[r][c] != CellState.revealed) {
          hiddenCount++;
        }
      }
    }
    if (hiddenCount == totalMines) {
      isGameOver = true;
      isWin = true;
    }
  }

  void _revealAllMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (_mines[r][c]) {
          states[r][c] = CellState.revealed;
        }
      }
    }
  }

  bool isMine(int r, int c) => _mines[r][c];
}
