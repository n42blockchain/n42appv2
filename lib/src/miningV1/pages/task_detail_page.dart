import 'package:n42_wallet/src/component/enums/coin_type.dart';
import 'package:n42_wallet/src/miningV1/api/mining_api.dart';
import 'package:n42_wallet/src/miningV1/widgets/nav_show_data_item.dart';
import 'package:n42_wallet/src/utils/data_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/utils/toast_utils.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/loading.dart';
import 'package:n42_wallet/src/widgets/round_refresh_icon.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskDetailPage extends StatefulWidget {
  final String astValue;
  final String blockNumber;
  const TaskDetailPage({required this.blockNumber, required this.astValue,super.key});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    if(_dataUtils==null){
      _dataUtils=DataUtils();
    }
    return _dataUtils!;
  }
  int status = 0;
  bool isLoading = true;
  Map? taskDetailResponse;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final data = await MiningApi.getTaskDetail(widget.blockNumber);
      taskDetailResponse = data["result"];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_mining_key15,
        actions: [
          Row(
            children: [
              RoundRefreshIcon(
                refreshData: () async {
                  await initData();
                },
              ),
              SizedBox(width: ScreenUtil().setWidth(24),)
            ],
          )
        ],
      ),
      body: isLoading
          ? const Loading()
          : Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(36)),
        child: Column(
          children: [
            SizedBox(
              height: ScreenUtil().setWidth(50),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.astValue,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(36)),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(12),
                ),
                Text(
                  CoinType.N.name,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(28)),
                ),
              ],
            ),

            SizedBox(
              height: ScreenUtil().setWidth(40),
            ),
            Divider(
              height: 1,
              endIndent: 1,
              indent: 1,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemLineColor.name),
            ),
            //展示数据
            NavShowDataItem("gasLimit",
                "${BigInt.tryParse("${taskDetailResponse?["gasLimit"] ?? ''}")}"),
            NavShowDataItem("gasUsed",
                "${BigInt.tryParse("${taskDetailResponse?["gasUsed"] ?? ''}")}"),

            Row(
              children: [
                Expanded(
                  child: NavShowDataItem(
                      "hash",
                      dataUtils.addressFarmat(
                          taskDetailResponse?["hash"] ?? '')),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text: "${taskDetailResponse?["hash"]}"));
                    //toast 已经复制
                    ToastUtils.show(S.of(context).copy);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                    width: ScreenUtil().setWidth(50),
                    height: ScreenUtil().setWidth(50),
                    child: Icon(
                      Icons.copy,
                      size: ScreenUtil().setWidth(36),
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
                  ),
                ),
              ],
            ),

            NavShowDataItem(
                "miner",
                dataUtils.addressFarmat(
                    taskDetailResponse?["miner"])),
            NavShowDataItem("block number",
                "${BigInt.tryParse(taskDetailResponse?["number"] ?? '')}"),
            NavShowDataItem(
                "timestamp",
                dataUtils.getTimeByTimeStamp(
                    "${BigInt.tryParse(taskDetailResponse?["timestamp"] ?? '')}")),
          ],
        ),
      ),
    );
  }
}
