import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_apply_info.dart';
import 'package:n42appv2/src/chat/pages/add_friend.dart';
import 'package:n42appv2/src/chat/provider/chat_message_provider.dart';
import 'package:n42appv2/src/chat/provider/message_content_type.dart';
import 'package:n42appv2/src/chat/utils/chat_data_util.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/detail_refresh_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_5.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';

class NewFriendListPage extends StatefulWidget {
  const NewFriendListPage({super.key});

  @override
  State<NewFriendListPage> createState() => _NewFriendListPageState();
}

class _NewFriendListPageState extends State<NewFriendListPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  ChatDBApi? _chatDBApi;
  ChatDBApi get chatDBApi{
    _chatDBApi ??= ChatDBApi();
    return _chatDBApi!;
  }

  List<FriendApplyInfo> friendList = [];

  //3天内
  List<FriendApplyInfo> threeDayFriendList = [];

  //3天前的申请
  List<FriendApplyInfo> threeDayAgoFriendList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getNewFriendList();
  }

  Future<void> getNewFriendList({bool showLoading = true}) async {
    try {
      if (showLoading) {
        setState(() {
          isLoading = true;
        });
      }
      final data = await chatApi.friendApplyList();
      if (data != null && data["code"] == 200) {
        friendList = (data["data"] as List)
            .map((e) => FriendApplyInfo.fromJson(e))
            .toList();

        if (friendList.isNotEmpty) {
          //筛选出3天内的数据
          DateTime currentDateTime = DateTime.now();
          DateTime threeDaysAgo =
          currentDateTime.subtract(const Duration(days: 3));
          threeDayFriendList = [];
          threeDayAgoFriendList = [];
          for (FriendApplyInfo friendInfo in friendList) {
            DateTime friendCreateTime =
            DateTime.fromMillisecondsSinceEpoch(friendInfo.createTime!);
            if (friendCreateTime.isAfter(threeDaysAgo)) {
              threeDayFriendList.add(friendInfo);
            } else {
              threeDayAgoFriendList.add(friendInfo);
            }
          }
        }
      }
    } finally {
      if (mounted) {
        isLoading = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_chat_key_2,
      ),
      body:SafeArea(
        child: isLoading
            ? SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const Center(child: Loading()),
        ):Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(36)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AddFriend()));
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemBgColor6.name),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(24), vertical: ScreenUtil().setWidth(12)),
                    margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor8.name),
                        ),
                        Text(
                          S.of(context).g_key_squad_k25,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.mainTextColor8.name),
                              fontSize: ScreenUtil().setSp(32)),
                        ),
                      ],
                    )),
              ),
              Expanded(
                flex: 1,
                child: DetailRefreshWidget(
                  callback: () async {
                    await getNewFriendList(showLoading: false);
                  },
                  childWidget:_buildContent(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (friendList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: ScreenUtil().setWidth(480),
            ),
            Image.asset(
              "assets/chat/no_frame.png",
              width: ScreenUtil().setWidth(120),
              fit: BoxFit.cover,
            ),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Text(
              // "No contact yet",
              S.of(context).g_chat_key_60,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                fontSize: ScreenUtil().setSp(32),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (threeDayFriendList.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
                child: Text(
                  S.of(context).g_chat_key_61,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(32)),
                ),
              ),
              listView(context, threeDayFriendList)
            ],
          ),
        if (threeDayAgoFriendList.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
                child: Text(
                  S.of(context).g_chat_key_62,
                  style: TextStyle(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                      fontSize: ScreenUtil().setSp(32)),
                ),
              ),
              listView(context, threeDayAgoFriendList)
            ],
          )
      ],
    );
  }

  Widget listView(BuildContext context, List list) {
    return Container(
      decoration: BoxDecoration(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          FriendApplyInfo model = list[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24),vertical: ScreenUtil().setWidth(14)),
            child: Row(
              children: [
                Container(
                  width: ScreenUtil().setWidth(80),
                  height: ScreenUtil().setWidth(80),
                  //超出部分，可裁剪
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          ScreenUtil().setWidth(48)),
                      border: Border.all(
                          width: 0.5,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemLineColor.name))),
                  child: ImageNetWork(
                    imageUrl: model.image ?? '',
                    width: ScreenUtil().setWidth(40),
                    placeholder: "assets/chat/user_def_icon.png",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(24),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child:Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model.name ?? '',
                                    style: TextStyle(
                                        color: AppThemeUtils.getColorByKey(
                                            context, AppThemeKeys.mainTextColor.name),
                                        fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(30)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setWidth(12),
                                  ),
                                  Text(
                                    model.reason ?? '',
                                    style: TextStyle(
                                        color: Color(0xff5C616D), fontSize: ScreenUtil().setSp(24)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )),
                          //我添加别人是展示发出icon
                          if (model.direction == 1)
                            Padding(
                              padding: EdgeInsets.only(right: ScreenUtil().setWidth(12)),
                              child: Image.asset(
                                "assets/chat/arrow_outward.png",
                                width: ScreenUtil().setWidth(32),
                                fit: BoxFit.cover,
                                color: const Color(0xff5C616D),
                              ),
                            ),
                          GestureDetector(
                            onTap: () async {
                              handleFriendRequest(context, model);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                //状态未完成时 展示绿色
                                  color: model.status == 0
                                      ? const Color(0xff32D74B)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12))),
                              padding: model.status == 0
                                  ? EdgeInsets.symmetric(
                                  horizontal: ScreenUtil().setWidth(24), vertical: ScreenUtil().setWidth(10))
                                  : EdgeInsets.symmetric(
                                  horizontal: 0, vertical: ScreenUtil().setWidth(10)),
                              child: Text(
                                requestBtnMessage(model),
                                style: TextStyle(
                                    color: model.status == 0
                                        ? Colors.white
                                        : const Color(0xff5C616D),
                                    fontSize: ScreenUtil().setWidth(24)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ScreenUtil().setWidth(12),
                      ),
                      if (index != list.length - 1)
                        Divider(
                          height: 0.5,
                          indent: 1,
                          endIndent: 1,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemLineColor.name),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: list.length,
      ),
    );
  }

  //状态判定
  // direction为0表示别人申请添加”我“为好友的记录，应查询用户user_id的信息;
  // direction为1表示”我“申请添加别人为好友的记录，应查询用户friend_id的信息
  // 别人申请添加”我“为好友的记录，在前端显示包括3种状态：接受、已过期、已添加
  // ”我“申请添加别人为好友的记录，在前端显示包括3种状态：待验证、已过期、已添加
  String? requestBtnMessage(FriendApplyInfo model) {
    if (model.status == 1) {
      // return "已添加";
      return S.of(context).g_chat_key_3;
    } else if (model.status == 3) {
      // return "已过期";
      return S.of(context).g_chat_key_4;
    } else if (model.status == 0) {
      if (model.direction == 0) {
        // return "接受";
        return S.of(context).g_chat_key_31;
      } else {
        // return "待验证";
        return S.of(context).g_chat_key_5;
      }
    }
  }

  //同意好友申请
  Future<void> handleFriendRequest(BuildContext context, FriendApplyInfo model) async {
    if (model.direction == 0 && model.status == 0) {
      //弹出备注昵称ui
      final textEditController = TextEditingController();
      final flag = await tipsDialog5(context,
          controller: textEditController,
          title: S.of(context).g_chat_key_6(model.name ?? ''));
      if (flag != null && flag) {
        final remarks = textEditController.text.trim();
        final data = await chatApi.friendAccept(
            model.uuid ?? '', AppGlobals.userInfo?.uuid ?? '', remarks);
        //{code: 200, msg: OK, data: true}
        if (data != null && data["code"] == 200 && data["data"]) {
          model.status = 1;
          setState(() {});
          ChatDataUtil chatDataUtils=ChatDataUtil();
          // 发送2条打招呼消息
          if (model.reason != null && model.reason!.isNotEmpty) {
            Map<String, dynamic> content = chatDataUtils.generateSendData(
                contentType: MessageContentType.Text,
                fromID: model.uuid!,
                receiveId: AppGlobals.userInfo?.uuid ?? '',
                conversationType: 0,
                direction: 0,
                //这条消息不加密
                decryptionMessageContent: model.reason!,
                msg: model.reason!);

            ChatMessageModel cm = ChatMessageModel.fromMap(content);
            await chatDBApi.saveMessage(cm);

            await chatApi.sendMessage(
              fromUUID: model.uuid!,
              receiveId: AppGlobals.userInfo?.uuid ?? '',
              content: json.encode(content),
            );
          }

          Map<String, dynamic> content2 = chatDataUtils.generateSendData(
              contentType: MessageContentType.Tip_Notification,
              fromID: model.uuid!,
              receiveId: AppGlobals.userInfo?.uuid ?? '',
              conversationType: 0,
              direction: 0,
              // msg: "you are now friends and can start chatting");
              msg:
              "Be careful opening external links. Never share your password, private key, or recovery phrase.");

          ChatMessageModel cm = ChatMessageModel.fromMap(content2);
          await chatDBApi.saveMessage(cm);

          final data2 = await chatApi.sendMessage(
            fromUUID: model.uuid!,
            receiveId: AppGlobals.userInfo?.uuid ?? '',
            content: json.encode(content2),
          );

          if (data2 != null && data2["code"] == 200) {}

          ///更新一下全局的红点提示
          if (!mounted) return;
          Provider.of<ChatMessageProvider>(this.context,listen: false).updateNewFriendStatus();
        } else {
          ToastUtils.show(data["msg"]);
        }
      }
    }
  }
}