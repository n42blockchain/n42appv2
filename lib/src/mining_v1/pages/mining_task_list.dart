import 'package:n42_wallet/src/mining_v1/api/mining_api.dart';
import 'package:n42_wallet/src/mining_v1/pages/task_detail_page.dart';
import 'package:n42_wallet/src/mining_v1/widgets/task_item.dart';
import 'package:n42_wallet/src/mining_v1/widgets/task_value_bar.dart';
import 'package:n42_wallet/src/utils/data_utils.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/base_list.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiningTaskList extends StatefulWidget {
  final String address;

  const MiningTaskList({super.key, required this.address});

  @override
  State<MiningTaskList> createState() => _MiningTaskListState();
}

class _MiningTaskListState extends State<MiningTaskList> {
  DataUtils? _dataUtils;
  DataUtils get dataUtils{
    if(_dataUtils==null){
      _dataUtils=DataUtils();
    }
    return _dataUtils!;
  }

  //任务列表分页数据
  int pageSize = 20;
  bool isLoadingTaskList = true;
  String? fromBlockNum;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_mining_key31,
        ),
        body: Container(
          margin: EdgeInsets.only(
            left: ScreenUtil().setWidth(30),
            right: ScreenUtil().setWidth(30),
            bottom: ScreenUtil().setWidth(30),
            top: ScreenUtil().setWidth(30),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ScreenUtil().setWidth(16)),
              topRight: Radius.circular(ScreenUtil().setWidth(16)),
            ),
            color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TaskValueBar(),
              Expanded(
                  child: BaseList(
                    buildItem:
                        (BuildContext context, List<dynamic> results, int index) {
                      var item = results[index];
                      return GestureDetector(
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => TaskDetailPage(
                                blockNumber: "${item["blockNumber"]}",
                                astValue: dataUtils.formatNum(
                                    toEther(
                                        "${BigInt.tryParse(item["reward"])}",
                                        18).toDouble(),
                                    8),
                              )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          // //{blockNumber: 0x235, timestamp: 1671526039, reward: 0x1}
                          child: TaskItem(
                            taskId: "${BigInt.tryParse(item["blockNumber"])}",
                            astValue: dataUtils.formatNum(
                                toEther("${BigInt.tryParse(item["reward"])}", 18).toDouble(),
                                8),
                            time: dataUtils.getTimeByTimeStamp(
                                "${item["timestamp"]}",
                                format: "dd/MM HH:mm"),
                            status: "success",
                          ),
                        ),
                      );
                    },
                    getData: (int page, int pageSize) async {
                      try {
                        if(page==1){
                          fromBlockNum=null;
                        }
                        final data = await MiningApi.getMiningTaskList(
                            widget.address, fromBlockNum,
                            pageSize: pageSize);
                        debugPrint("task list data:$data");
                        if (data != null) {
                          //{blockNumber: 0x235, timestamp: 1671526039, reward: 0x1}
                          final taskList = data["result"]["minedBlocks"] ?? [];
                          if(taskList != null && taskList is List ){
                            if(taskList.length > 1){
                              fromBlockNum =
                              "0x${(int.parse((taskList[taskList.length - 1]["blockNumber"])) - 1).toRadixString(16)}";
                              // debugPrint("fromBlockNum : $fromBlockNum");
                            }
                            return taskList;
                          }
                        }
                      }catch (err){
                        // err
                      }
                      return [];
                    },
                    firstRefresh: true,
                    pageSize: 50,
                  ))
            ],
          ),
        ));
  }
}
