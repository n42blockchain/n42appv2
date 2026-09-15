import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/features/mining_v1/pages/mining_task_list_utils.dart';
import 'package:n42_wallet/features/mining_v1/widgets/nav_show_data_item.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/loading.dart';
import 'package:n42_wallet/features/widgets/round_refresh_icon.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskDetailPage extends StatefulWidget {
  final String astValue;
  final String blockNumber;
  const TaskDetailPage({
    required this.blockNumber,
    required this.astValue,
    super.key,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late final DataUtils dataUtils = DataUtils();
  bool isLoading = true;
  Map? taskDetailResponse;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final data = await MiningApi.getTaskDetail(widget.blockNumber);
      if (!mounted) return;
      taskDetailResponse = data["result"];
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_mining_key_15,
        actions: [
          Row(
            children: [
              RoundRefreshIcon(refreshData: () => initData()),
              SizedBox(width: AppSpacing.space6),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Loading()
          : Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(36),
              ),
              child: Column(
                children: [
                  SizedBox(height: ScreenUtil().setWidth(50)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.astValue,
                        style: AppTypography.title.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.space4),
                      Text(
                        CoinType.N.name,
                        style: AppTypography.body.copyWith(
                          color: AppColorTokens.of(context).textPrimary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.space12),
                  Divider(
                    height: 1,
                    endIndent: 1,
                    indent: 1,
                    color: AppColorTokens.of(context).border,
                  ),
                  //展示数据
                  NavShowDataItem(
                    "gasLimit",
                    parseMiningNumericValue(
                          taskDetailResponse?["gasLimit"],
                        )?.toString() ??
                        '',
                  ),
                  NavShowDataItem(
                    "gasUsed",
                    parseMiningNumericValue(
                          taskDetailResponse?["gasUsed"],
                        )?.toString() ??
                        '',
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: NavShowDataItem(
                          "hash",
                          dataUtils.addressFarmat(
                            taskDetailResponse?["hash"] ?? '',
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: "${taskDetailResponse?["hash"]}",
                            ),
                          );
                          //toast 已经复制
                          ToastUtils.show(S.of(context).copy);
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: ScreenUtil().setWidth(20),
                          ),
                          width: ScreenUtil().setWidth(50),
                          height: ScreenUtil().setWidth(50),
                          child: Icon(
                            Icons.copy,
                            size: ScreenUtil().setWidth(36),
                            color: AppColorTokens.of(context).brand,
                          ),
                        ),
                      ),
                    ],
                  ),

                  NavShowDataItem(
                    "miner",
                    dataUtils.addressFarmat(taskDetailResponse?["miner"]),
                  ),
                  NavShowDataItem(
                    "block number",
                    parseMiningNumericValue(
                          taskDetailResponse?["number"],
                        )?.toString() ??
                        '',
                  ),
                  NavShowDataItem(
                    "timestamp",
                    dataUtils.getTimeByTimeStamp(
                      parseMiningNumericValue(
                            taskDetailResponse?["timestamp"],
                          )?.toString() ??
                          '',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
