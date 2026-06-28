import 'package:flutter/widgets.dart';

/// 一笔（一条连续笔画）：颜色、粗细、采样点序列。
class WhiteboardStroke {
  final Color color;
  final double width;
  final List<Offset> points;

  WhiteboardStroke({
    required this.color,
    required this.width,
    List<Offset>? points,
  }) : points = points ?? <Offset>[];

  bool get isEmpty => points.isEmpty;
}

/// 白板/涂鸦的纯绘制状态机：增点、起新笔、撤销、清空。
///
/// 不含任何渲染/平台依赖，便于单测。UI 层（`WhiteboardPage`）监听其变化重绘，
/// 并在「发送」时把画布栅格化为 PNG。
class WhiteboardController extends ChangeNotifier {
  final List<WhiteboardStroke> _strokes = <WhiteboardStroke>[];

  Color _color;
  double _width;

  WhiteboardController({
    Color color = const Color(0xFF222222),
    double width = 4,
  })  : _color = color,
        _width = width;

  List<WhiteboardStroke> get strokes => List.unmodifiable(_strokes);
  Color get color => _color;
  double get width => _width;

  /// 画布上是否有任何可见内容（用于 gating「发送」按钮）。
  bool get isEmpty => _strokes.every((s) => s.isEmpty);
  bool get isNotEmpty => !isEmpty;

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    notifyListeners();
  }

  set width(double value) {
    if (_width == value) return;
    _width = value;
    notifyListeners();
  }

  /// 落笔：开一条新笔画。
  void startStroke(Offset point) {
    _strokes.add(WhiteboardStroke(
      color: _color,
      width: _width,
      points: <Offset>[point],
    ));
    notifyListeners();
  }

  /// 移动：把点追加到当前笔画（无笔画时自动起一笔，容错）。
  void addPoint(Offset point) {
    if (_strokes.isEmpty) {
      startStroke(point);
      return;
    }
    _strokes.last.points.add(point);
    notifyListeners();
  }

  /// 撤销最后一笔。
  void undo() {
    if (_strokes.isEmpty) return;
    _strokes.removeLast();
    notifyListeners();
  }

  /// 清空画布。
  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    notifyListeners();
  }
}
