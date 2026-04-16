import 'dart:math';

class Piece {
  final List<List<int>> shape;
  final int colorIndex;
  int row;
  int col;

  Piece({
    required this.shape,
    required this.colorIndex,
    required this.row,
    required this.col,
  });

  Piece copy() => Piece(
        shape: shape.map((r) => List<int>.from(r)).toList(),
        colorIndex: colorIndex,
        row: row,
        col: col,
      );

  List<List<int>> get rotated {
    final rows = shape.length;
    final cols = shape[0].length;
    return List.generate(cols, (c) => List.generate(rows, (r) => shape[rows - 1 - r][c]));
  }
}

class BlockDropLogic {
  static const int boardRows = 20;
  static const int boardCols = 10;

  final Random _random = Random();

  // Board: 0 = empty, 1-7 = piece color
  late List<List<int>> board;
  Piece? currentPiece;
  Piece? nextPiece;
  int score = 0;
  int totalLines = 0;
  int level = 1;
  bool isGameOver = false;

  // Standard 7 pieces: I, O, T, S, Z, L, J
  static final List<List<List<int>>> _shapes = [
    // I - cyan (1)
    [[1, 1, 1, 1]],
    // O - yellow (2)
    [[1, 1], [1, 1]],
    // T - purple (3)
    [[0, 1, 0], [1, 1, 1]],
    // S - green (4)
    [[0, 1, 1], [1, 1, 0]],
    // Z - red (5)
    [[1, 1, 0], [0, 1, 1]],
    // L - orange (6)
    [[1, 0], [1, 0], [1, 1]],
    // J - blue (7)
    [[0, 1], [0, 1], [1, 1]],
  ];

  BlockDropLogic() {
    reset();
  }

  int get dropInterval => max(100, 800 - (level - 1) * 70);

  void reset() {
    board = List.generate(boardRows, (_) => List.filled(boardCols, 0));
    score = 0;
    totalLines = 0;
    level = 1;
    isGameOver = false;
    nextPiece = _randomPiece();
    _spawnPiece();
  }

  Piece _randomPiece() {
    final idx = _random.nextInt(_shapes.length);
    final shape = _shapes[idx].map((r) => List<int>.from(r)).toList();
    return Piece(
      shape: shape,
      colorIndex: idx + 1,
      row: 0,
      col: (boardCols - shape[0].length) ~/ 2,
    );
  }

  void _spawnPiece() {
    currentPiece = nextPiece;
    nextPiece = _randomPiece();

    if (currentPiece != null && !_isValid(currentPiece!)) {
      isGameOver = true;
    }
  }

  bool _isValid(Piece piece) {
    for (int r = 0; r < piece.shape.length; r++) {
      for (int c = 0; c < piece.shape[r].length; c++) {
        if (piece.shape[r][c] == 0) continue;
        final br = piece.row + r;
        final bc = piece.col + c;
        if (br < 0 || br >= boardRows || bc < 0 || bc >= boardCols) return false;
        if (board[br][bc] != 0) return false;
      }
    }
    return true;
  }

  bool moveLeft() {
    if (currentPiece == null || isGameOver) return false;
    currentPiece!.col--;
    if (!_isValid(currentPiece!)) {
      currentPiece!.col++;
      return false;
    }
    return true;
  }

  bool moveRight() {
    if (currentPiece == null || isGameOver) return false;
    currentPiece!.col++;
    if (!_isValid(currentPiece!)) {
      currentPiece!.col--;
      return false;
    }
    return true;
  }

  bool softDrop() {
    if (currentPiece == null || isGameOver) return false;
    currentPiece!.row++;
    if (!_isValid(currentPiece!)) {
      currentPiece!.row--;
      _lockPiece();
      return false;
    }
    return true;
  }

  void hardDrop() {
    if (currentPiece == null || isGameOver) return;
    while (_isValid(currentPiece!)) {
      currentPiece!.row++;
    }
    currentPiece!.row--;
    _lockPiece();
  }

  bool rotate() {
    if (currentPiece == null || isGameOver) return false;
    final piece = currentPiece!;
    final oldShape = piece.shape.map((r) => List<int>.from(r)).toList();
    final newShape = piece.rotated;

    piece.shape
      ..clear()
      ..addAll(newShape);

    // Wall kick: try original, then left/right shifts
    if (_isValid(piece)) return true;

    piece.col--;
    if (_isValid(piece)) return true;
    piece.col += 2;
    if (_isValid(piece)) return true;
    piece.col--;

    // Restore
    piece.shape
      ..clear()
      ..addAll(oldShape);
    return false;
  }

  void _lockPiece() {
    if (currentPiece == null) return;
    final piece = currentPiece!;
    for (int r = 0; r < piece.shape.length; r++) {
      for (int c = 0; c < piece.shape[r].length; c++) {
        if (piece.shape[r][c] == 0) continue;
        final br = piece.row + r;
        final bc = piece.col + c;
        if (br >= 0 && br < boardRows && bc >= 0 && bc < boardCols) {
          board[br][bc] = piece.colorIndex;
        }
      }
    }
    _clearLines();
    _spawnPiece();
  }

  void _clearLines() {
    int cleared = 0;
    for (int r = boardRows - 1; r >= 0; r--) {
      if (board[r].every((cell) => cell != 0)) {
        board.removeAt(r);
        board.insert(0, List.filled(boardCols, 0));
        cleared++;
        r++; // Re-check this row
      }
    }
    if (cleared > 0) {
      switch (cleared) {
        case 1: score += 100;
        case 2: score += 300;
        case 3: score += 500;
        default: score += 800;
      }
      totalLines += cleared;
      level = totalLines ~/ 10 + 1;
    }
  }

  int ghostRow() {
    if (currentPiece == null) return 0;
    final saved = currentPiece!.row;
    while (_isValid(currentPiece!)) {
      currentPiece!.row++;
    }
    final ghost = currentPiece!.row - 1;
    currentPiece!.row = saved;
    return ghost;
  }

  // Get full board including current piece (for rendering)
  List<List<int>> get renderBoard {
    final rendered = board.map((r) => List<int>.from(r)).toList();
    if (currentPiece == null) return rendered;

    final piece = currentPiece!;
    // Ghost piece
    final gr = ghostRow();
    for (int r = 0; r < piece.shape.length; r++) {
      for (int c = 0; c < piece.shape[r].length; c++) {
        if (piece.shape[r][c] == 0) continue;
        final br = gr + r;
        final bc = piece.col + c;
        if (br >= 0 && br < boardRows && bc >= 0 && bc < boardCols && rendered[br][bc] == 0) {
          rendered[br][bc] = -(piece.colorIndex); // Negative = ghost
        }
      }
    }

    // Current piece
    for (int r = 0; r < piece.shape.length; r++) {
      for (int c = 0; c < piece.shape[r].length; c++) {
        if (piece.shape[r][c] == 0) continue;
        final br = piece.row + r;
        final bc = piece.col + c;
        if (br >= 0 && br < boardRows && bc >= 0 && bc < boardCols) {
          rendered[br][bc] = piece.colorIndex;
        }
      }
    }

    return rendered;
  }
}
