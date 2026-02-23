// Copyright 2021-2026 N42 Inc. All rights reserved.

/// Gesture pattern strength level
enum PatternStrength { weak, medium, strong }

/// Evaluates the complexity of a gesture unlock pattern.
///
/// Algorithm:
///   score = (pointCount - 4) + directionChanges
///
///   Weak:   pointCount < 5  OR  score < 2
///   Medium: score ∈ [2, 4]
///   Strong: score ≥ 5
///
/// Grid layout (3×3, indices 0–8):
///   0 1 2
///   3 4 5
///   6 7 8
class GesturePatternStrength {
  GesturePatternStrength._();

  /// Evaluate strength from a comma-separated point string (e.g. "0,1,4,7,6").
  static PatternStrength evaluateString(String value) {
    if (value.isEmpty) return PatternStrength.weak;
    final pts = value.split(',').map(int.tryParse).whereType<int>().toList();
    return evaluate(pts);
  }

  /// Evaluate strength from a list of grid point indices (0–8).
  static PatternStrength evaluate(List<int> points) {
    final int n = points.length;
    if (n < 4) return PatternStrength.weak;

    final int changes = _countDirectionChanges(points);
    // Each extra point above minimum (4) adds 1; each direction change adds 1.
    final int score = (n - 4) + changes;

    if (n < 5 || score < 2) return PatternStrength.weak;
    if (score < 5) return PatternStrength.medium;
    return PatternStrength.strong;
  }

  /// Count the number of times the movement direction changes between
  /// consecutive point pairs.  Direction is normalised to its sign vector
  /// (dr.sign, dc.sign) to handle diagonal and long jumps uniformly.
  static int _countDirectionChanges(List<int> points) {
    if (points.length < 3) return 0;

    int changes = 0;
    int? prevDr, prevDc;

    for (int i = 1; i < points.length; i++) {
      final int r1 = points[i - 1] ~/ 3;
      final int c1 = points[i - 1] % 3;
      final int r2 = points[i] ~/ 3;
      final int c2 = points[i] % 3;

      final int dr = (r2 - r1).sign;
      final int dc = (c2 - c1).sign;

      if (prevDr != null && (dr != prevDr || dc != prevDc)) {
        changes++;
      }
      prevDr = dr;
      prevDc = dc;
    }
    return changes;
  }
}
