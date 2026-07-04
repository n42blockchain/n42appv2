import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:matrix/matrix.dart' as matrix;

import '../../../core/utils/debug_log.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../widgets/chat/whiteboard/whiteboard_controller.dart';

/// 白板 / 涂鸦页（仿微信「涂鸦」、对标 iMessage Digital Touch / Apple Freeform）。
///
/// 单人绘制 → 栅格化为 PNG → `Navigator.pop` 返回字节，由聊天页走既有图片
/// 发送链路上传发送。
///
/// **实时共绘**：传入 [roomId] 即启用——本端每完成一笔（抬笔）以
/// `n42.whiteboard.stroke` 自定义 Matrix 事件广播（0-1 归一化坐标，跨设备
/// 尺寸无关）；同时监听房间内其他成员的笔画/清空事件实时上板。双方在同一
/// 会话打开白板即共绘（v1 不回放进入前的历史笔画）。
///
/// ⚠️ E2EE 房已知限制:每笔画=一条加密房间事件,会触发对端未读+1 与推送
/// (服务端只见密文 m.room.encrypted,无法按自定义类型过滤推送——同实时字幕
/// 的架构缺口)。当前缓解=收到远端笔画即回已读压未读;推送风暴的治本需改用
/// to-device/EDU 传输,列入后续。建议 E2EE 群暂按小范围/测试使用。
class WhiteboardPage extends StatefulWidget {
  /// 启用实时共绘的房间；null = 纯单人涂鸦。
  final String? roomId;

  const WhiteboardPage({super.key, this.roomId});

  @override
  State<WhiteboardPage> createState() => _WhiteboardPageState();
}

class _WhiteboardPageState extends State<WhiteboardPage> {
  static const String strokeEventType = 'n42.whiteboard.stroke';
  static const String clearEventType = 'n42.whiteboard.clear';

  final WhiteboardController _controller = WhiteboardController();
  final GlobalKey _canvasKey = GlobalKey();
  bool _exporting = false;

  matrix.Room? _room;
  StreamSubscription<matrix.Event>? _remoteSub;
  int _peerStrokeCount = 0;

  @override
  void initState() {
    super.initState();
    _initCollaboration();
  }

  /// 共绘模式：解析房间 + 订阅远端笔画/清空事件。
  void _initCollaboration() {
    final roomId = widget.roomId;
    if (roomId == null) return;
    try {
      final client = GetIt.instance<MatrixClientManager>().client;
      _room = client?.getRoomById(roomId);
      if (client == null || _room == null) return;
      _remoteSub = client.onTimelineEvent.stream
          .where(
            (e) =>
                e.room.id == roomId &&
                e.senderId != client.userID &&
                (e.type == strokeEventType || e.type == clearEventType),
          )
          .listen(_onRemoteEvent);
    } catch (e) {
      debugLog('WhiteboardPage: collaboration init failed: $e');
    }
  }

  void _onRemoteEvent(matrix.Event event) {
    if (!mounted) return;
    if (event.type == clearEventType) {
      _controller.clear();
      return;
    }
    final size = _canvasSize();
    if (size == null) return;
    final stroke = WhiteboardStroke.fromJson(
      Map<String, dynamic>.from(event.content),
      size,
    );
    if (stroke == null) return;
    _controller.addRemoteStroke(stroke);
    setState(() => _peerStrokeCount++);
    // E2EE 房里自定义笔画事件会计未读+推送(架构限制:服务端只见密文
    // m.room.encrypted,无法按类型过滤;治本需 to-device/EDU 重构)。
    // 缓解:双方都在白板页时,收到一笔即回已读压掉未读徽章。
    unawaited(
      _room
          ?.setReadMarker(event.eventId, mRead: event.eventId)
          .catchError((Object _) {}),
    );
  }

  Size? _canvasSize() {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final size = box?.size;
    if (size == null || size.isEmpty) return null;
    return size;
  }

  /// 抬笔：把刚完成的一笔广播给共绘者（fire-and-forget，失败不影响本地）。
  void _broadcastLastStroke() {
    final room = _room;
    if (room == null) return;
    final strokes = _controller.strokes;
    if (strokes.isEmpty || strokes.last.isEmpty) return;
    final size = _canvasSize();
    if (size == null) return;
    final payload = strokes.last.toJson(size);
    unawaited(
      room.sendEvent(payload, type: strokeEventType).catchError((Object e) {
        debugLog('WhiteboardPage: stroke broadcast failed: $e');
        return null;
      }),
    );
  }

  void _clearBoard() {
    _controller.clear();
    final room = _room;
    if (room == null) return;
    unawaited(
      room.sendEvent(<String, dynamic>{}, type: clearEventType).catchError((
        Object e,
      ) {
        debugLog('WhiteboardPage: clear broadcast failed: $e');
        return null;
      }),
    );
  }

  static const List<Color> _palette = [
    Color(0xFF222222),
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFFFFFFF),
  ];

  @override
  void dispose() {
    _remoteSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    if (_controller.isEmpty || _exporting) return;
    setState(() => _exporting = true);
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _exporting = false);
        return;
      }
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: dpr);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!mounted) return;
      final bytes = byteData?.buffer.asUint8List();
      Navigator.of(context).pop<Uint8List>(bytes);
    } catch (e) {
      debugLog('WhiteboardPage export failed: $e');
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _room != null
              ? 'Whiteboard · Live${_peerStrokeCount > 0 ? ' ✏️' : ''}'
              : 'Whiteboard',
        ),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Semantics(
              button: true,
              label: 'Send',
              child: TextButton(
                onPressed: _controller.isNotEmpty && !_exporting
                    ? _export
                    : null,
                child: Text(
                  'Send',
                  style: TextStyle(
                    color: _controller.isNotEmpty
                        ? Colors.lightBlueAccent
                        : Colors.white38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _canvasKey,
              child: Container(
                color: const Color(0xFF1A1A1A),
                child: GestureDetector(
                  onPanStart: (d) => _controller.startStroke(d.localPosition),
                  onPanUpdate: (d) => _controller.addPoint(d.localPosition),
                  onPanEnd: (_) {
                    _broadcastLastStroke();
                    _controller.endLocalStroke();
                  },
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => CustomPaint(
                      painter: _WhiteboardPainter(_controller.strokes),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Undo',
              child: IconButton(
                icon: const Icon(Icons.undo, color: Colors.white),
                onPressed: _controller.undo,
              ),
            ),
            Semantics(
              button: true,
              label: 'Clear',
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: _clearBoard,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (final color in _palette) _buildColorDot(color),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    final selected = _controller.color == color;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Color',
      child: GestureDetector(
        onTap: () => _controller.color = color,
        child: Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.lightBlueAccent : Colors.white24,
              width: selected ? 2.5 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<WhiteboardStroke> strokes;

  _WhiteboardPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        // 单点：画一个圆点
        canvas.drawCircle(
          stroke.points.first,
          stroke.width / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}
