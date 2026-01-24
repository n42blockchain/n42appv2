import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_member_info.dart';
import 'package:n42appv2/src/chat/widgets/contact_image.dart';
import 'package:n42appv2/src/component/enums/load.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class DeleteGroupMemberPage extends StatefulWidget {
  final String groupId;
  final List<GroupMemberInfo> groupMemberList;

  const DeleteGroupMemberPage(
      {super.key, required this.groupId, required this.groupMemberList});

  @override
  State<DeleteGroupMemberPage> createState() => _DeleteGroupMemberPageState();
}

class _DeleteGroupMemberPageState extends State<DeleteGroupMemberPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  List<FriendInfo> friendList = [];
  List<GroupMemberInfo> selectedList = [];

  final List<GroupMemberInfo> _groupMemberList = [];

  Load load=Load.finish;

  //群密码
  String? groupPwd;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    try {
      for (var element in widget.groupMemberList) {
        // 跳过特殊类型的元素（添加按钮和删除按钮）
        if (element.type == -0x100 || element.type == -0x200) {
          continue;
        }
        //深度拷贝
        _groupMemberList.add(GroupMemberInfo.fromJson(element.toJson()));
      }
      // 返回列表中 把自己排除在外
      _groupMemberList.removeWhere(
              (element) => element.memberId == AppGlobals.userInfo?.uuid);
      setState(() {});
    } catch (err) {
      //err
      debugPrint("initData err${err.toString()}");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_chat_key_35,
      ),
      body: SafeArea(
        child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(40), horizontal: ScreenUtil().setWidth(32)),
                    child: Text(
                      S.of(context).g_chat_key_12,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(30)),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemLineColor.name),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    GroupMemberInfo model = _groupMemberList[index];
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          model.isSelected = !model.isSelected;
                          if (model.isSelected) {
                            selectedList.add(model);
                          } else {
                            selectedList.remove(model);
                          }
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            SizedBox(
                              height: ScreenUtil().setWidth(24),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: ScreenUtil().setWidth(24),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(48),
                                  height: ScreenUtil().setWidth(48),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: model.isSelected
                                        ? const Color(0xff32D74B)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: model.isSelected
                                          ? Colors.transparent
                                          : AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.ff888888.name),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: model.isSelected
                                      ? Icon(
                                    Icons.check,
                                    size: ScreenUtil().setWidth(40),
                                    color: Colors.white,
                                  )
                                      : null,
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(24),
                                ),
                                Expanded(
                                    child: Row(
                                      children: [
                                        ContactImage(
                                          faceUrl: model.avatarUrl ?? '',
                                        ),
                                        SizedBox(
                                          width: ScreenUtil().setWidth(32),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              // name
                                              Text(
                                                model.displayName ?? '',
                                                style: TextStyle(
                                                    color:
                                                    AppThemeUtils.getColorByKey(
                                                        context,
                                                        AppThemeKeys
                                                            .mainTextColor.name),
                                                    // fontWeight: FontWeight.bold,
                                                    fontSize: ScreenUtil().setSp(30)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                height: ScreenUtil().setWidth(20),
                                              ),
                                              //email
                                              Row(
                                                children: [
                                                  Text(
                                                    'E-mail: ',
                                                    style: TextStyle(
                                                        color: Color(0xFFC1C0C9),
                                                        fontSize: ScreenUtil().setSp(30)),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      model.email ?? '',
                                                      style: TextStyle(
                                                          color: Color(0xFFC1C0C9),
                                                          fontSize: ScreenUtil().setWidth(30)),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setWidth(24),
                            ),
                            Divider(
                              height: 0.5,
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemLineColor.name),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: _groupMemberList.length,
                ),
              ),
              Container(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemBgColor.name),
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(24)),
                width: double.infinity,
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () async {
                    try {
                      if(load==Load.loading)return;
                      if (selectedList.isEmpty) {
                        return;
                      }
                      setState(() {
                        load=Load.loading;
                      });
                      List<String?> groupMemberIds =
                      selectedList.map((e) => e.memberId).toList();
                      final data = await chatApi.deleteGroupMembers(
                          widget.groupId, groupMemberIds);

                      if (!mounted) return;
                      if (data != null && data["code"] == 200) {
                        //更新会话列表
                        eventBus.fire(EventPublic(
                            EventPublicType.updateChatConversationList));
                        Navigator.of(this.context).pop(true);
                      }
                    } catch (err) {
                      debugPrint("err : ${err.toString()}");
                    } finally {
                      setState(() {
                        load=Load.finish;
                      });
                    }
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12), horizontal: ScreenUtil().setWidth(24)),
                    decoration: BoxDecoration(
                        color: selectedList.isEmpty
                            ? AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name)
                            : Colors.green,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "${S.of(context).g_key_113}(${selectedList.length})",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
        ),
      ),
    );
  }
}