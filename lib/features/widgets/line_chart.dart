import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math';

class LineChart extends StatefulWidget {
  final List<dynamic> values; //折线图数据
  final double height; //控件高度
  final double bottomMargin; //绘制折线图时，距离最底边的距离
  final double maxValue; //折线图点 最大值
  final double minValue; //折线图点 最小值
  final bool isUp; //是涨还是跌，涨绿色图，跌红色图

  final double difference; //最大值和最小值之间的差值

  static double _calcMaxValue(List<dynamic> values) {
    // 空列表保持现状语义：返回 0.0
    if (values.isEmpty) return 0.0;
    // 以首元素为起始值，避免 0.0 起始污染全负数序列（曾错误返回 0）
    double maxVal = values[0] * 1.0;
    for (int i = 1; i < values.length; i++) {
      if (maxVal < values[i]) {
        maxVal = values[i] * 1.0;
      }
    }
    return maxVal;
  }

  static double _calcMinValue(List<dynamic> values) {
    // 空列表保持现状语义：返回 0.0
    if (values.isEmpty) return 0.0;
    // 与 _calcMaxValue 对称：以首元素起始
    double minVal = values[0] * 1.0;
    for (int i = 1; i < values.length; i++) {
      if (minVal > values[i]) {
        minVal = values[i] * 1.0;
      }
    }
    return minVal;
  }

  LineChart(this.values, this.isUp, this.height, this.bottomMargin, {super.key})
    : maxValue = _calcMaxValue(values),
      minValue = _calcMinValue(values),
      difference = _calcMaxValue(values) - _calcMinValue(values);
  @override
  LineChartState createState() => LineChartState();
}

class LineChartState extends State<LineChart> with TickerProviderStateMixin {
  GlobalKey<State<StatefulWidget>> anchorKey = GlobalKey();
  late DrawLineChart drawLineChart;
  @override
  Widget build(BuildContext context) {
    drawLineChart = DrawLineChart(
      Theme.of(context),
      widget.values,
      widget.maxValue,
      widget.isUp,
      widget.difference,
      widget.minValue,
      widget.bottomMargin,
    );
    return Container(
      color: Color(0xFF9E9E9E),
      key: anchorKey,
      height: widget.height,
      width: double.infinity,
      child: CustomPaint(painter: drawLineChart),
    );
  }
}

class DrawLineChart extends CustomPainter {
  late ThemeData theme;
  List<dynamic> values; //点数据
  double difference = 0; //最大值和最小值的差值
  double dianValue = 0; //每隔点代表的值
  bool isUp; //是涨还是跌
  double bottomMargin = 0;

  /// 最大值
  double maxValue = 100;
  //最小值
  double minValue = 0;

  DrawLineChart(
    this.theme,
    this.values,
    this.maxValue,
    this.isUp,
    this.difference,
    this.minValue,
    this.bottomMargin,
  );

  ///画笔
  Paint painter = Paint()
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  /// 线段数量
  int lineNum = 5;

  /// 整体宽度
  late double width;

  ///整体高度
  late double height;

  /// x轴坐标单元间距
  late double unitWidth;

  @override
  void paint(Canvas canvas, Size size) {
    ///基本区域剪切
    Rect rect = Offset.zero & size;
    canvas.clipRect(rect);
    painter.color = theme.brightness == Brightness.light
        ? Colors.white
        : Color(0xFF222222);
    painter.style = PaintingStyle.fill;
    canvas.drawRect(rect, painter);

    width = size.width;
    height = size.height;
    // 全等值/单元素序列 difference 为 0：置 0 防除零，getY 中画中位平线
    dianValue = difference == 0 ? 0 : (height - bottomMargin * 2) / difference;
    // 少于 2 个点无法构成折线（unitWidth 也会除零），只保留背景不画线
    if (values.length < 2) return;
    unitWidth = width / (values.length - 1);

    painter.style = PaintingStyle.stroke;
    painter.strokeWidth = 1.5;
    painter.color = isUp ? Color(0xFF44A677) : Color(0xFFD9445A);
    drawValueLine(canvas);

    painter.style = PaintingStyle.fill;
    painter.shader = ui.Gradient.linear(
      Offset(width, height / 2),
      Offset(0, height / 2),
      isUp
          ? [
              Color.fromRGBO(68, 166, 119, 0.14),
              Color.fromRGBO(68, 166, 119, 0.0),
            ]
          : [
              Color.fromRGBO(217, 68, 90, 0.14),
              Color.fromRGBO(217, 68, 90, 0.0),
            ],
    );
    painter.color = Color(0xFF000000);
    drawValueLineFill(canvas);
    painter.shader = null;
  }

  /// 画线
  void drawValueLine(Canvas canvas) {
    Path path = Path();
    for (int i = 0; i < values.length - 1; i++) {
      double v1 = values[i] * 1.0;
      double v2 = values[i + 1] * 1.0;
      if (i == 0) {
        path.moveTo(getX(i.toDouble()), getY(v1));
      }
      path = getCurvePath(v1, v2, i, path);
    }
    canvas.drawPath(path, painter);
    path.close();
  }

  /// 画填充区域
  void drawValueLineFill(Canvas canvas) {
    Path path = Path();
    path.moveTo(0, height);
    for (int i = 0; i < values.length - 1; i++) {
      double v1 = values[i] * 1.0;
      double v2 = values[i + 1] * 1.0;
      path = getCurvePath(v1, v2, i, path);
    }
    path.lineTo(width, height);
    canvas.drawPath(path, painter);
    path.close();
  }

  /// 获取曲线路径
  /// [v1] 第一个Y轴值 [v2] 第二个Y轴值
  /// [index] X轴坐标位置
  Path getCurvePath(double v1, double v2, int index, Path path) {
    int clipNum = 30;
    double temp = 1 / clipNum;
    bool isNegativeNumber;
    double diff = (v1 - v2).abs();
    isNegativeNumber = (v1 - v2) < 0;
    for (int i = 0; i < clipNum; i++) {
      path.lineTo(
        getX(temp * i + index.toDouble()),
        getY(
          (cos((isNegativeNumber ? pi : 0) + pi * temp * i) + 1) * diff / 2 +
              (isNegativeNumber ? v1 : v2),
        ),
      );
    }
    return path;
  }

  /// 获取Y轴坐标
  double getY(double value) {
    // 全等值序列（difference==0）没有纵向缩放比例，统一画在垂直居中位置
    if (difference == 0) return height / 2;
    return height - (((value - minValue) * dianValue) + bottomMargin);
  }

  /// 获取X轴坐标
  double getX(double index) => index * unitWidth;

  @override
  bool shouldRepaint(covariant DrawLineChart oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.isUp != isUp ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.minValue != minValue ||
        oldDelegate.theme.brightness != theme.brightness;
  }
}
