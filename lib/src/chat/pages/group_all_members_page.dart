import 'package:n42appv2/src/chat/models/group_member_info.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';

class GroupAllMembersPage extends StatefulWidget {
  final List<GroupMemberInfo> groupMemberList;

  const GroupAllMembersPage({super.key, required this.groupMemberList});

  @override
  State<GroupAllMembersPage> createState() => _GroupAllMembersPageState();
}

class _GroupAllMembersPageState extends State<GroupAllMembersPage> {
  late List<GroupMemberInfo> _groupMemberList;

  @override
  void initState() {
    super.initState();
    _groupMemberList = widget.groupMemberList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_chat_key_32(_groupMemberList.length),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 一行展示5列
            ),
            itemCount: _groupMemberList.length,
            itemBuilder: (BuildContext context, int index) {
              GroupMemberInfo? item = _groupMemberList[index];
              if (item.memberId == null) {
                return const SizedBox();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
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
                                context, AppThemeKeys.itemLineColor.name))),
                    child: ImageNetWork(
                      imageUrl: item.avatarUrl ?? '',
                      width: ScreenUtil().setWidth(40),
                      placeholder: "assets/img/person_def_1.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(12),
                  ),
                  Text(
                    item.displayName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.ff888888.name),
                        fontSize: ScreenUtil().setSp(26)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}