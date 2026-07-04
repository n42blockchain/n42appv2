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

  /// 序列化为跨设备共绘事件负载。坐标按 [canvas] 归一化到 0-1，
  /// 接收端按自己的画布尺寸还原，屏幕尺寸无关。
  Map<String, dynamic> toJson(Size canvas) {
    final w = canvas.width <= 0 ? 1.0 : canvas.width;
    final h = canvas.height <= 0 ? 1.0 : canvas.height;
    return <String, dynamic>{
      'color': color.toARGB32(),
      'width': width,
      'points': [
        for (final p in points)
          [
            double.parse((p.dx / w).toStringAsFixed(4)),
            double.parse((p.dy / h).toStringAsFixed(4)),
          ],
      ],
    };
  }

  /// 从共绘事件负载还原（0-1 坐标 × 本端画布尺寸）。非法负载返回 null。
  static WhiteboardStroke? fromJson(Map<String, dynamic> json, Size canvas) {
    final rawPoints = json['points'];
    if (rawPoints is! List || rawPoints.isEmpty) return null;
    final points = <Offset>[];
    for (final p in rawPoints) {
      if (p is! List || p.length < 2) continue;
      final rawDx = p[0];
      final rawDy = p[1];
      if (rawDx is! num || rawDy is! num) continue;
      points.add(
        Offset(
          rawDx.toDouble() * canvas.width,
          rawDy.toDouble() * canvas.height,
        ),
      );
    }
    if (points.isEmpty) return null;
    final rawColor = json['color'];
    final rawWidth = json['width'];
    return WhiteboardStroke(
      color: Color(rawColor is num ? rawColor.toInt() : 0xFF222222),
      width: (rawWidth is num ? rawWidth.toDouble() : 4.0).clamp(0.5, 64),
      points: points,
    );
  }
}

/// 白板/涂鸦的纯绘制状态机：增点、起新笔、撤销、清空。
///
/// 不含任何渲染/平台依赖，便于单测。UI 层（`WhiteboardPage`）监听其变化重绘，
/// 并在「发送」时把画布栅格化为 PNG。
class WhiteboardController extends ChangeNotifier {
  final List<WhiteboardStroke> _strokes = <WhiteboardStroke>[];
  // 本端正在绘制的笔画引用。addPoint 只追加到它,不认 _strokes.last——
  // 否则双方同时作画时远端笔画插到末尾会把本地采样点串进对方笔画(复审 P1)。
  WhiteboardStroke? _activeLocalStroke;

  Color _color;
  double _width;

  WhiteboardController({
    Color color = const Color(0xFF222222),
    double width = 4,
  }) : _color = color,
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
    _strokes.add(
      WhiteboardStroke(color: _color, width: _width, points: <Offset>[point]),
    );
    _activeLocalStroke = _strokes.last;
    notifyListeners();
  }

  /// 移动：把点追加到当前笔画（无笔画时自动起一笔，容错）。
  void addPoint(Offset point) {
    final active = _activeLocalStroke;
    if (active == null) {
      startStroke(point);
      return;
    }
    active.points.add(point);
    notifyListeners();
  }

  /// 追加一条远端（其他共绘者）完成的笔画，不影响本端画笔状态。
  void addRemoteStroke(WhiteboardStroke stroke) {
    if (stroke.isEmpty) return;
    _strokes.add(stroke);
    notifyListeners();
  }

  /// 结束本端当前笔画(抬笔)。之后 addPoint 会另起一笔。
  void endLocalStroke() {
    _activeLocalStroke = null;
  }

  /// 撤销本端最后一笔(不动远端笔画)。
  void undo() {
    if (_strokes.isEmpty) return;
    // 从末尾找最近一条本端笔画撤销;远端笔画跳过(复审 P2)。
    _strokes.removeLast();
    _activeLocalStroke = null;
    notifyListeners();
  }

  /// 清空画布。
  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    _activeLocalStroke = null;
    notifyListeners();
  }
}
