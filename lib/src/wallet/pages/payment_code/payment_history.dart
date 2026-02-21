import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/utils/browser_txhash.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  List<Map<String, dynamic>> dataList = [];
  String uuid = "";
  Load load = Load.finish;
  String errorMessage = "";
  final DateFormat _dateFmt = DateFormat("MM-dd HH:mm");

  @override
  void initState() {
    uuid = AppGlobals.userInfo?.uuid ?? "";
    loadHistory();
    super.initState();
  }

  Future<void> loadHistory() async {
    if (!mounted) return;
    setState(() {
      load = Load.loading;
      errorMessage = "";
    });
    try {
      MessageModel mm = await UserInfoApi().getPaymentHistory();
      if (!mounted) return;
      if (mm.error) {
        setState(() {
          load = Load.error;
          errorMessage = mm.data?.toString() ?? "加载失败";
        });
      } else {
        final raw = mm.data;
        List<Map<String, dynamic>> parsed = [];
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) {
              parsed.add(Map<String, dynamic>.from(item));
            }
          }
        }
        setState(() {
          dataList = parsed;
          load = Load.finish;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        load = Load.error;
        errorMessage = e.toString();
      });
    }
  }

  /// 将时间戳（秒或毫秒）格式化为可读字符串
  String _formatTime(dynamic txTime) {
    if (txTime == null) return "";
    try {
      int ts = int.parse(txTime.toString());
      // 秒级时间戳转毫秒
      if (ts < 9999999999) ts = ts * 1000;
      return _dateFmt.format(DateTime.fromMillisecondsSinceEpoch(ts));
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      appBar: AppBarWidget(
        text: "支付历史",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: "刷新",
            onPressed: loadHistory,
          ),
        ],
      ),
      body: _bodyWidget(),
    );
  }

  Widget _bodyWidget() {
    if (load == Load.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (load == Load.error) {
      return _errorWidget();
    }
    if (dataList.isEmpty) {
      return const Center(child: EmptyView());
    }
    return RefreshIndicator(
      onRefresh: loadHistory,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(15),
        ),
        itemCount: dataList.length,
        itemBuilder: (context, index) => _itemWidget(dataList[index]),
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.errorTextColor.name),
              fontSize: ScreenUtil().setSp(28),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setWidth(30)),
          InkWell(
            onTap: loadHistory,
            child: Container(
              height: ScreenUtil().setWidth(80),
              width: ScreenUtil().setWidth(80),
              padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
              child: Icon(
                Icons.refresh,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemWidget(Map<String, dynamic> data) {
    final bool isIncoming = data["toUuid"]?.toString() == uuid;
    final String timeStr = _formatTime(data['txTime']);

    final Widget dirIcon = Icon(
      isIncoming ? Icons.input_outlined : Icons.output_outlined,
      size: ScreenUtil().setWidth(40),
      color: AppThemeUtils.getColorByKey(
        context,
        isIncoming
            ? AppThemeKeys.rightTextColor.name
            : AppThemeKeys.textColorOrange.name,
      ),
    );
    final Widget dirLabel = Container(
      margin:
          EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Text(
        isIncoming ? "收入" : "支出",
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
            context,
            isIncoming
                ? AppThemeKeys.rightTextColor.name
                : AppThemeKeys.textColorOrange.name,
          ),
          fontSize: ScreenUtil().setSp(28),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          // 第一行：方向图标 + 交易哈希 + 时间
          Row(
            children: [
              dirIcon,
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    final String openUrl = getBrowserTxHash(
                      data['chainSymbol'] ?? "",
                      data['txHash'] ?? "",
                    );
                    if (openUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BrowserPage(openUrl)),
                      );
                    }
                  },
                  child: Text(
                    data['txHash'] ?? "",
                    style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                      fontSize: ScreenUtil().setSp(28),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (timeStr.isNotEmpty)
                Text(
                  timeStr,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name),
                    fontSize: ScreenUtil().setSp(24),
                  ),
                ),
            ],
          ),
          Divider(height: ScreenUtil().setWidth(16)),
          // 第二行：金额 + 方向标签
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin:
                      EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "\$ ${data['amount'] ?? ""}",
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if ((data['tokenAmount'] ?? "").toString().isNotEmpty)
                        Text(
                          "约 ${data['tokenAmount']}${data['token'] ?? ""}",
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.itemSubtitleTextColor.name),
                            fontSize: ScreenUtil().setSp(28),
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
              dirLabel,
            ],
          ),
          Divider(height: ScreenUtil().setWidth(16)),
          // 第三行：代币/链信息 + 价格
          Row(
            children: [
              Text(
                "${data['token'] ?? ""}(${data['chainSymbol'] ?? ""})",
                style: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemTextColor.name),
                  fontSize: ScreenUtil().setSp(28),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  (data['tokenPrice'] ?? "").toString().isNotEmpty
                      ? "\$ ${data['tokenPrice']}"
                      : "",
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemTextColor.name),
                    fontSize: ScreenUtil().setSp(28),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
