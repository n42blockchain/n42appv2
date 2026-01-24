import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:n42appv2/generated/l10n.dart';

class ChartHistogram extends StatefulWidget {
  final TitleModel titleModel; //标题，主标题、副标题如果没有可以不传，
  final List<AlertMessageGroup>? alertMessageGroups; //长按柱状条，弹出的内容提示
  final BottomTitle bottomTitle; //底部标签
  final BarChartModel barChartModel; //柱状图数据
  final bool isLoading;

  const ChartHistogram(
      {required this.titleModel,
        required this.barChartModel,
        required this.bottomTitle,
        this.alertMessageGroups,
        this.isLoading = false,
        super.key});

  @override
  State<StatefulWidget> createState() => _ChartHistogramState();
}

class _ChartHistogramState extends State<ChartHistogram> {
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
        AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius:
        BorderRadius.circular(ScreenUtil().setWidth(16)),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(32),
              right: ScreenUtil().setWidth(32),
              top: ScreenUtil().setWidth(20),
            ),
            child: Text(
              S.of(context).g_mining_key_86,
              style: TextStyle(
                color:AppThemeUtils.getColorByKey(context,AppThemeKeys.itemTextColor.name),
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          AspectRatio(
            // aspectRatio: 1.5,
            aspectRatio: 2,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setWidth(32),bottom: ScreenUtil().setWidth(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (widget.titleModel.title != null)
                        Text(
                          widget.titleModel.title!,
                          style: widget.titleModel.titleStyle,
                        ),
                      if (widget.titleModel.title != null)
                        SizedBox(
                          height: widget.titleModel.tsSpace,
                        ),
                      if (widget.titleModel.subtitle != null)
                        Text(
                          widget.titleModel.subtitle!,
                          style: widget.titleModel.subtitleStyle,
                        ),
                      if (widget.titleModel.subtitle != null ||
                          widget.titleModel.title != null)
                        SizedBox(
                          height: widget.titleModel.bottomSpace,
                        ),
                      Expanded(
                        child: BarChart(
                          mainBarData(),
                          swapAnimationDuration: animDuration,
                        ),
                      ),
                    ],
                  ),
                ),

                if(widget.isLoading)
                  Center(child: Padding(
                    padding:  EdgeInsets.only(bottom: ScreenUtil().setWidth(24)),
                    child:  CupertinoActivityIndicator(animating: true, radius: ScreenUtil().setWidth(24)),
                  ))

              ],
            ),
          ),
        ],
      ),

    );
  }

  BarChartGroupData makeGroupData(
      int x,
      double y,
      Color barColor,
      Color barColor_fg,
      double width, {
        bool isTouched = false,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isTouched ? widget.barChartModel.touchColor : barColor_fg,
          width: width,
          borderSide: isTouched
              ? BorderSide(
              color: widget.barChartModel.touchColor.withAlpha((0.5 * 255).round()))
              : BorderSide(color: widget.barChartModel.touchColor, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: widget.barChartModel.maxValue,
            color: barColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() =>
      List.generate(widget.barChartModel.values.length, (int i) {
        double value = widget.barChartModel.values[i];
        Color fg = widget.barChartModel.fgColor;
        if (value == widget.barChartModel.maxValue) {
          if (widget.barChartModel.fgColor_max != null) {
            fg = widget.barChartModel.fgColor_max!;
          }
        }
        return makeGroupData(
          i,
          value,
          widget.barChartModel.bgColor,
          fg,
          widget.barChartModel.width,
          isTouched: i == touchedIndex,
        );
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          // tooltipBgColor: Colors.white,
          //tooltipBgColor: const Color(0xffEDEFF2),
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            if(widget.alertMessageGroups == null || widget.alertMessageGroups!.isEmpty) return null;
            AlertMessageGroup? amg = widget.alertMessageGroups?[group.x];
            if (amg != null) {
              List<TextSpan> spans = [];
              for (int i = 1; i < amg.titles.length; i++) {
                String text = amg.titles[i];
                if (i != amg.titles.length - 1) {
                  text = "$text\n";
                }
                spans.add(
                  TextSpan(
                    text: text,
                    style: amg.styles[i],
                  ),
                );
              }
              return BarTooltipItem('${amg.titles[0]}\n', amg.styles[0],
                  children: spans);
            }
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    //value = index
    Widget text;
    if (value.toInt() == widget.bottomTitle.specialIndex) {
      text = Text(widget.bottomTitle.titles[value.toInt()],
          style: widget.bottomTitle.specialStyle ?? widget.bottomTitle.style);
    } else {
      text = Text(widget.bottomTitle.titles[value.toInt()],
          style: widget.bottomTitle.style);
    }
    return SideTitleWidget(
      meta: meta,
      space: widget.bottomTitle.space,
      child: text,
    );
  }
}

class AlertMessageGroup {
  List<String> titles;
  List<TextStyle> styles;

  AlertMessageGroup({required this.titles, required this.styles});
}

class BottomTitle {
  List<String> titles;
  TextStyle style;
  int specialIndex; //特殊标题索引
  TextStyle? specialStyle; //特殊标题样式
  double space; //标题与柱状图的间隔
  BottomTitle(
      {required this.titles,
        required this.style,
        this.specialIndex = -1,
        this.specialStyle,
        this.space = 15});
}

class BarChartModel {
  Color bgColor; //柱状图背景色
  Color fgColor; //柱状图前景色
  Color? fgColor_max; //柱状图前景色 最大值
  Color touchColor; //长按前景色
  double width; //宽度
  double maxValue;
  List<double> values;

  BarChartModel({
    required this.bgColor,
    required this.fgColor,
    this.fgColor_max,
    required this.touchColor,
    required this.width,
    this.maxValue = -1,
    required this.values,
  }) {
    if (maxValue == -1) {
      double maxNumber = values[0];
      for (int i = 1; i < values.length; i++) {
        if (values[i] > maxNumber) {
          maxNumber = values[i];
        }
      }
      maxValue = maxNumber;
      if(maxValue==0){
        maxValue=1;
      }
    }
  }
}

class TitleModel {
  String? title;
  String? subtitle;
  TextStyle? titleStyle;
  TextStyle? subtitleStyle;
  double tsSpace; //主标题和副标题之间的间隔
  double bottomSpace; //副标题和图标之间的间隔
  TitleModel(
      {this.title,
        this.subtitle,
        this.titleStyle,
        this.subtitleStyle,
        this.tsSpace = 4,
        this.bottomSpace = 30});
}