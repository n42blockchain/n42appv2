import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/pages/add_friend.dart';
import 'package:n42appv2/src/chat/pages/block_friends.dart';
import 'package:n42appv2/src/chat/pages/chat_detail_page.dart';
import 'package:n42appv2/src/chat/pages/new_friend_list_page.dart';
import 'package:n42appv2/src/chat/provider/chat_message_provider.dart';
import 'package:n42appv2/src/chat/utils/chat_sp_util.dart';
import 'package:n42appv2/src/chat/widgets/item_contact.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/detail_refresh_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  ChatApi? _chatApi;
  ChatApi get chatApi{
    _chatApi ??= ChatApi();
    return _chatApi!;
  }
  final controller = TextEditingController();
  //GlobalKey<NftBaseListState> appBaseListKey = GlobalKey();
  String? searchKey;

  List<FriendInfo> friendList = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getFriendList(isShowLoading: true);
  }

  Future<void> getFriendList({bool isShowLoading = false}) async {
    try {
      if (isShowLoading) {
        isLoading = true;
        setState(() {});
      }
      //先从缓存取出数据
      List<FriendInfo>? fList = await ChatSPUtil().getFriendList();
      setState(() {
        friendList = fList;
      });

      //再次请求网络异步更新数据
      updateFriendData();
    } finally {
      if (mounted) {
        isLoading = false;
        setState(() {});
      }
    }
  }

  Future<void> updateFriendData() async {
    final data = await chatApi.friendList();
    if (data != null && data["code"] == 200) {
      List<FriendInfo> list =
      (data["data"] as List).map((e) => FriendInfo.fromJson(e)).toList();
      // 返回列表中 把自己排除在外
      list.removeWhere((element) => element.uuid == AppGlobals.userInfo?.uuid);
      setState(() {
        friendList = list;
      });
      //本地缓存好友列表
      final flag = await ChatSPUtil().saveFriendsList(list);
      if (flag) {
        // debugPrint("---保存好友列表成功----");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_key_squad_k24,
        ),
        body: SafeArea(
          child: DetailRefreshWidget(
            callback: () async {
              await updateFriendData();
            },
            childWidget: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                //search bar
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddFriend()));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemBgColor6.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
                      padding:
                      EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24), vertical: ScreenUtil().setWidth(12)),
                      margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(24), horizontal: ScreenUtil().setWidth(40)),
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
                SizedBox(
                  height: ScreenUtil().setWidth(12),
                ),

                Container(
                  decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.itemBgColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: ScreenUtil().setWidth(40)),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const NewFriendListPage()));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: ScreenUtil().setWidth(14), horizontal: ScreenUtil().setWidth(24)),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Image.asset(
                                      "assets/chat/new_friends.png",
                                      width: ScreenUtil().setWidth(80),
                                      height: ScreenUtil().setWidth(80),
                                      fit: BoxFit.cover,
                                    ),
                                    Consumer(builder: (
                                        BuildContext context,
                                        ChatMessageProvider value,
                                        Widget? child,
                                        ) {
                                      if (value.haveNewFriend==0) {
                                        return const SizedBox();
                                      }
                                      return Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Color(0xffFC2E01),
                                              shape: BoxShape.circle),
                                          width: ScreenUtil().setWidth(14),
                                          height: ScreenUtil().setWidth(14),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(24),
                                ),
                                Text(
                                  //新的朋友
                                  S.of(context).g_chat_key_2,
                                  style: TextStyle(
                                      color: AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.mainBlueColor.name),
                                      // fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(32)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: ScreenUtil().setWidth(100),
                          ),
                          Expanded(
                            child: Divider(
                              height: 0.5,
                              indent: 1,
                              endIndent: 1,
                              color: AppThemeUtils.getColorByKey(
                                  context, AppThemeKeys.itemLineColor.name),
                            ),
                          )
                        ],
                      ),

                      /// 黑名单
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const BlockFriends()));
                            },
                            child: Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(14), horizontal: ScreenUtil().setWidth(24)),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/chat/blacklist_icon.png",
                                    width: ScreenUtil().setWidth(80),
                                    height: ScreenUtil().setWidth(80),
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setWidth(24),
                                  ),
                                  Text(
                                    S.of(context).g_chat_key_58,
                                    style: TextStyle(
                                        color: AppThemeUtils.getColorByKey(
                                            context, AppThemeKeys.mainBlueColor.name),
                                        // fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(32)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: ScreenUtil().setWidth(24),
                ),
                _buildFriendView()
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildFriendView() {
    if (isLoading) {
      return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const Center(child: Loading()));
    }
    if (friendList.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: ScreenUtil().setWidth(240),
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
      );
    }
    return Container(
      decoration: BoxDecoration(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16))),
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: ScreenUtil().setWidth(40)),
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
      child: SlidableAutoCloseBehavior(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
          itemBuilder: (BuildContext context, int index) {
            FriendInfo model = friendList[index];
            return  Slidable(
              key: ValueKey(index),
              groupTag: "friend_list_tag",
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.2,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      friendDelete(model);
                    },
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    //label: S.of(context).g_key_113,
                  ),
                ],
              ),
              child: ItemContact(
                faceUrl: model.image,
                name: (model.remarks??"")==""?model.name:model.remarks??"",
                email: model.email,
                showLine: index != friendList.length - 1,
                onTap: () async {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ChatDetailPage(
                    targetUuid: model.uuid!,
                    conversationType: 0,
                  ),),);
                },
              ),
            );
          },
          itemCount: friendList.length,
        ),
      ),
    );
  }
  Future<void> friendDelete(FriendInfo model)async{
    final res = await tipsDialog2(
      context,
      S.current.g_key_squad_k15(model.name??""),
    );
    if (res != null && res) {
      //删除好友
      await chatApi.deleteFriend(model.uuid ?? '');
      updateFriendData();
    }
  }
}