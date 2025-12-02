import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/group_member_info.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomGroupMemberDialog extends StatefulWidget {
  final String groupId;
  final ValueChanged<GroupMemberInfo>? callBack;
  const BottomGroupMemberDialog({super.key, required this.groupId, this.callBack});

  @override
  State<BottomGroupMemberDialog> createState() =>
      _BottomGroupMemberDialogState();
}

class _BottomGroupMemberDialogState extends State<BottomGroupMemberDialog> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    if(_chatApi==null){
      _chatApi=ChatApi();
    }
    return _chatApi!;
  }
  List<GroupMemberInfo> groupMemberList = [];

  @override
  void initState() {
    super.initState();
    getGroupMembers();
  }

  getGroupMembers() async {
    try {
      List<GroupMemberInfo> groupList =
      await ChatSPUtil().getGroupMembersById(widget.groupId);
      if (groupList.isNotEmpty) {
        groupMemberList = groupList;
        // 返回列表中 把自己排除在外
        groupMemberList.removeWhere((element) => element.memberId == Application.userInfo?.uuid);
        setState(() {});
      }

      final data = await chatApi.groupMembers(
          widget.groupId, Application.userInfo?.uuid ?? '');
      if (data != null && data["code"] == 200) {
        final list = data["data"];
        if (list != null && list is List) {
          groupMemberList =
              list.map((e) => GroupMemberInfo.fromJson(e)).toList();
          // 添加群成员缓存
          ChatSPUtil().saveGroupMembers(widget.groupId, groupMemberList);
          groupMemberList.removeWhere((element) => element.memberId == Application.userInfo?.uuid);
          setState(() {});
        }
      }

    } catch (err) {
      debugPrint("err:${err.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20), horizontal: ScreenUtil().setWidth(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
              itemCount: groupMemberList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                GroupMemberInfo item = groupMemberList[index];
                return _buildITem(item);
              })
        ],
      ),
    );
  }

  _buildITem(GroupMemberInfo item) {
    return GestureDetector(
      onTap: () {
        if(widget.callBack != null){
          widget.callBack!(item);
        }
        Navigator.of(context).pop();
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(68),
              height: ScreenUtil().setWidth(68),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(68)),
              ),
              child: ImageNetWork(
                imageUrl: item.avatarUrl ?? "",
                width: ScreenUtil().setWidth(68),
                placeholder: "assets/img/person_def_1.png",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(22),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
                    child: Text(
                      item.displayName ?? '',
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontSize: ScreenUtil().setSp(32)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Divider(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemLineColor.name),
                    indent: 1,
                    endIndent: 1,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}