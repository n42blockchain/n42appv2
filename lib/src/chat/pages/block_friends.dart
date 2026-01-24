import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/widgets/contact_empty.dart';
import 'package:n42appv2/src/chat/widgets/contact_image.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/detail_refresh_widget.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlockFriends extends StatefulWidget {
  const BlockFriends({super.key});

  @override
  State<BlockFriends> createState() => _BlockFriendsState();
}

class _BlockFriendsState extends State<BlockFriends> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  List<FriendInfo> blockFriends = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getBlockFriends();
  }

  getBlockFriends({bool showLoading = true}) async {
    try {
      if (showLoading) {
        setState(() {
          isLoading = true;
        });
      }
      final data = await chatApi.blockFriendList();
      if (data != null && data["code"] == 200) {
        if(data["data"]!=null){
          blockFriends =
              (data["data"] as List).map((e) => FriendInfo.fromJson(e)).toList();
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
        text: S.of(context).g_chat_key_58,
      ),
      body: SafeArea(
        child: DetailRefreshWidget(
            callback: () async {}, childWidget: _buildContent()),
      ),
    );
  }

  _buildContent() {
    if (isLoading) {
      return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const Center(child: Loading()));
    }
    if (blockFriends.isEmpty) {
      return SizedBox(
          height: MediaQuery.of(context).size.height, child: const Center(child: ContactEmpty(),));
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
      itemBuilder: (BuildContext context, int index) {
        FriendInfo model = blockFriends[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: ScreenUtil().setWidth(12),
            ),
            Row(
              children: [
                SizedBox(
                  width: ScreenUtil().setWidth(40),
                ),
                Expanded(
                    child: Row(
                      children: [
                        ContactImage(
                          faceUrl: model.image ?? '',
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(32),
                        ),
                        Column(
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
                              model.email ?? '',
                              style: TextStyle(
                                  color: Color(0xFFC2C0C9), fontSize: ScreenUtil().setSp(30)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      ],
                    )),
                GestureDetector(
                  onTap: () async {
                    //移除黑名单
                    final data =
                    await chatApi.removeBlockFriend(model.uuid ?? '');
                    //{code: 200, msg: OK, data: true}
                    if (data != null && data["code"] == 200 && data["data"]) {
                      blockFriends.remove(model);
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.mainBlueColor.name),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12))),
                    padding:
                    EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24), vertical: ScreenUtil().setWidth(12)),
                    child: Text(
                      S.of(context).g_chat_key_59,
                      style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(24)),
                    ),
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(40),
                ),
              ],
            ),
            SizedBox(
              height: ScreenUtil().setWidth(12),
            ),
            Divider(
              height: 0.5,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemLineColor.name),
            )
          ],
        );
      },
      itemCount: blockFriends.length,
    );
  }
}