import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';
import 'package:n42appv2/src/chat/models/group_member_info.dart';
import 'package:n42appv2/src/chat/pages/add_group_member_page.dart';
import 'package:n42appv2/src/chat/pages/delete_group_member_page.dart';
import 'package:n42appv2/src/chat/pages/group_all_members_page.dart';
import 'package:n42appv2/src/chat/pages/group_edit_page.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class GroupDetailPage extends StatefulWidget {
  final GroupInfo info;

  const GroupDetailPage({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    if(_chatApi==null){
      _chatApi=ChatApi();
    }
    return _chatApi!;
  }
  List<GroupMemberInfo> groupMemberList = [];
  List<GroupMemberInfo> showGroupMemberList = [];

  bool isLoading = false;

  //判断当前用户是否是群主
  bool isGroupOwner = false;

  //是否还在群里
  bool isGroupMember = false;

  bool bottomButtonCanOnClick = true;

  bool isShowMoreGroupMember = false;

  late GroupInfo _info;

  @override
  void initState() {
    super.initState();
    _info = widget.info;
    initData();
  }

  initData() async {
    getGroupMembers();
  }

  getGroupMembers() async {
    try {
      setState(() {
        isLoading = true;
      });
      final data = await chatApi.groupMembers(
          widget.info.g_uuid, AppGlobals.userInfo?.uuid ?? '');
      if (data != null && data["code"] == 200) {
        final list = data["data"];
        if (list != null && list is List) {
          groupMemberList =
              list.map((e) => GroupMemberInfo.fromJson(e)).toList();
          // 添加群成员缓存
          ChatSPUtil().saveGroupMembers(widget.info.g_uuid, groupMemberList);
          handleData();
        }
      }
    } catch (err) {
      debugPrint("err:${err.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  handleData() async {
    //判断是群成员还是群主
    for (var element in groupMemberList) {
      if (element.memberId == AppGlobals.userInfo?.uuid) {
        isGroupMember = true;
        if (element.type == 1) {
          isGroupOwner = true;
        }
        break;
      }
    }

    // 计算需要预留的按钮位置数量（+ 按钮和 - 按钮）
    int buttonCount = 0;
    if (isGroupMember) buttonCount++; // + 按钮
    if (isGroupOwner) buttonCount++;  // - 按钮

    // 一行5个，最多显示3行（15个位置），减去按钮位置后的最大成员数
    int maxMemberDisplay = 15 - buttonCount;

    //判断群成员数量是否超过最大显示数
    if (groupMemberList.isNotEmpty && groupMemberList.length > maxMemberDisplay) {
      showGroupMemberList = groupMemberList.sublist(0, maxMemberDisplay);
      isShowMoreGroupMember = true;
    } else {
      showGroupMemberList = List.from(groupMemberList);
      isShowMoreGroupMember = false;
    }

    //群成员都可以邀请其他人进群
    if (isGroupMember) {
      GroupMemberInfo item = GroupMemberInfo.initNull();
      item.type = -0x100;
      showGroupMemberList.add(item);
    }

    //如果是群主 展示移除群成员按钮
    if (isGroupOwner) {
      GroupMemberInfo item = GroupMemberInfo.initNull();
      item.type = -0x200;
      showGroupMemberList.add(item);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_chat_key_17,
      ),
      body: SafeArea(
        child: Container(
          child: isLoading
              ? const Loading()
              : Column(
            children: [
              Container(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                padding: EdgeInsets.all(ScreenUtil().setWidth(30),),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, // 一行展示5列
                      ),
                      itemCount: showGroupMemberList.length,
                      itemBuilder: (BuildContext context, int index) {
                        GroupMemberInfo? item = showGroupMemberList[index];

                        /// 邀请好友进群
                        if (item.type == -0x100) {
                          return GestureDetector(
                            onTap: () async {
                              final flag = await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                  builder: (_) => AddGroupMemberPage(
                                    groupId: _info.g_uuid,
                                    groupMemberList:
                                    groupMemberList,
                                  )));

                              if (flag != null && flag) {
                                getGroupMembers();
                              }
                            },
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                                child: Image.asset(
                                  "assets/chat/add_member.png",
                                  width: ScreenUtil().setWidth(80),
                                  height: ScreenUtil().setWidth(80),
                                  fit: BoxFit.cover,
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.ff888888.name),
                                ),
                              ),
                            ),
                          );
                        }

                        ///移除群成员
                        if (item.type == -0x200) {
                          return GestureDetector(
                              onTap: () async {
                                final flag = await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                    builder: (_) =>
                                        DeleteGroupMemberPage(
                                          groupId: _info.g_uuid,
                                          groupMemberList:
                                          groupMemberList,
                                        )));

                                if (flag != null && flag) {
                                  getGroupMembers();
                                }
                              },
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                                  child: Center(
                                    child: Image.asset(
                                      "assets/chat/remove_member.png",
                                      width: ScreenUtil().setWidth(80),
                                      height: ScreenUtil().setWidth(80),
                                      fit: BoxFit.cover,
                                      color: AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.ff888888.name),
                                    ),
                                  ),
                                ),
                              ));
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: ScreenUtil().setWidth(80),
                              height: ScreenUtil().setWidth(80),
                              //超出部分，可裁剪
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(40)),
                                  border: Border.all(
                                      width: 0.5,
                                      color: AppThemeUtils.getColorByKey(
                                          context,
                                          AppThemeKeys.itemLineColor.name))),
                              child: ImageNetWork(
                                imageUrl: item.avatarUrl ?? '',
                                width: ScreenUtil().setWidth(40),
                                placeholder:
                                "assets/chat/user_def_icon.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              item.displayName ?? '',
                              style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                      context, AppThemeKeys.ff888888.name),
                                  fontSize: ScreenUtil().setSp(26)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                    //查看更多群成员
                    if (isShowMoreGroupMember)
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => GroupAllMembersPage(
                                  groupMemberList: groupMemberList)));
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: ScreenUtil().setWidth(40)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                S.of(context).g_chat_key_18,
                                style: TextStyle(
                                    color: AppThemeUtils.getColorByKey(
                                        context, AppThemeKeys.ff888888.name),
                                    fontSize: ScreenUtil().setSp(30)),
                              ),
                              SizedBox(
                                width: ScreenUtil().setWidth(16),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: ScreenUtil().setWidth(32),
                                color: AppThemeUtils.getColorByKey(
                                    context, AppThemeKeys.ff888888.name),
                              )
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(60),
              ),
              GestureDetector(
                onTap: () async {
                  if (isGroupOwner) {
                    final flag =
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => GroupEditPage(
                        info: widget.info,
                      ),
                    ));

                    if (flag != null && flag) {
                      //更新name
                      GroupInfo? item =
                      await ChatSPUtil().getGroupInfoById(_info.g_uuid);
                      if (item != null) {
                        _info = item;
                        setState(() {});
                      }
                    }
                  }
                },
                child: Container(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
                  padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                  child: Row(
                    children: [
                      Text(
                        S.of(context).g_chat_key_19,
                        style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                            fontSize: ScreenUtil().setSp(32)),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(24),
                      ),
                      Expanded(
                        child: Text(
                          _info.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.ff888888.name),
                              fontSize: ScreenUtil().setSp(32)),
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(24),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: ScreenUtil().setWidth(36),
                        color: isGroupOwner
                            ? AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainTextColor.name)
                            : AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name),
                      )
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if(isGroupMember)
                Divider(
                  height: ScreenUtil().setWidth(1),
                  endIndent: 0,
                  indent: 0,
                ),
              if(isGroupMember)
                Container(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemBgColor.name),
                  width: double.infinity,
                  height: ScreenUtil().setWidth(88),
                  margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  child: ButtonStyle2(context, () async {
                    final flag =
                    await TipsDialog2(
                        context,
                        isGroupOwner
                            ? S.of(context).g_chat_key_20
                            : S.of(context).g_chat_key_21);
                    if (flag == null || !flag) return;

                    if (isGroupOwner) {
                      //解散群
                      final data = await chatApi.groupDisband(
                          widget.info.g_uuid,
                          AppGlobals.userInfo?.uuid ?? '');
                      //{code: 200, msg: OK, data: true}
                      if (data != null && data["code"] == 200) {
                        if (data["data"] != null && data["data"]) {
                          bottomButtonCanOnClick = false;
                          widget.info.member_type = 0;
                          //更新群缓存
                          await ChatSPUtil().saveOrUpdateGroupInfo(
                              widget.info);
                          //更新群聊天ui的底部按钮
                          eventBus.fire(EventPublic(
                              EventPublicType.updateGroupInfo));
                          setState(() {});
                          Navigator.pop(context);
                        }
                      }
                    }
                    else {
                      //退出群
                      final data = await chatApi.leaveGroup(
                          widget.info.g_uuid,
                          AppGlobals.userInfo?.uuid ?? '');
                      //{code: 400, msg: Bad Request, data: {l_uuid: l_uuid is a required field}}
                      //{code: 200, msg: OK, data: true}
                      if (data != null && data["code"] == 200) {
                        if (data["data"] != null && data["data"]) {
                          //成功退出
                          bottomButtonCanOnClick = false;
                          widget.info.member_type = 0;
                          //更新群缓存
                          await ChatSPUtil().saveOrUpdateGroupInfo(
                              widget.info);
                          //更新群聊天ui的底部按钮
                          eventBus.fire(EventPublic(
                              EventPublicType.updateGroupInfo));
                          setState(() {});
                          Navigator.pop(context);
                        }
                      }
                    }
                  }, isGroupOwner
                      ? S.of(context).g_chat_key_22
                      : S.of(context).g_chat_key_23,),
                ),
            ],
          ),
        ),
      ),
    );
  }
}