import 'dart:async';
import 'dart:convert';

import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/chat/api/chat_api.dart';
import 'package:n42appv2/src/chat/api/chat_db_api.dart';
import 'package:n42appv2/src/chat/api/squad_api.dart';
import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/pages/chat_detail_page.dart';
import 'package:n42appv2/src/chat/pages/chat_group_detail_page.dart';
import 'package:n42appv2/src/chat/pages/create_group_page.dart';
import 'package:n42appv2/src/chat/pages/friend_detail.dart';
import 'package:n42appv2/src/chat/pages/friends_list_page.dart';
import 'package:n42appv2/src/chat/pages/q_code_chat.dart';
import 'package:n42appv2/src/chat/provider/chat_message_provider.dart';
import 'package:n42appv2/src/chat/utils/cache_read_message_utils.dart';
import 'package:n42appv2/src/chat/utils/chat_util.dart';
import 'package:n42appv2/src/chat/utils/websocket_util.dart';
import 'package:n42appv2/src/chat/widgets/chat_services.dart';
import 'package:n42appv2/src/chat/widgets/item_conversation.dart';
import 'package:n42appv2/src/component/pages/scan_page.dart';
import 'package:n42appv2/src/login/pages/login_page.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/core/utils/event_bus.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/widgets/app_home_top_bar.dart';
import 'package:n42appv2/src/widgets/custom_popup_menu_wrap.dart';
import 'package:n42appv2/src/widgets/detail_refresh_widget.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42appv2/src/widgets/empty.dart';
import 'package:n42appv2/src/widgets/loading.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';

/// Chat Index Page - Migrated to Riverpod
/// 
/// Shows chat list or login/service terms pages based on state
class ChatIndexPage extends ConsumerStatefulWidget {
  const ChatIndexPage({super.key});

  @override
  ConsumerState<ChatIndexPage> createState() => _ChatIndexPageState();
}

class _ChatIndexPageState extends ConsumerState<ChatIndexPage> {
  // 是否已经阅读了服务条款
  bool isReadChatService = false;
  
  @override
  void initState() {
    super.initState();
    readChatService();
  }
  
  readChatService() async {
    isReadChatService = await SPUtil().hasAcceptedTerms();
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Watch wallet list state from Riverpod
    final walletListAsync = ref.watch(walletListProvider);
    final selectedWalletIndex = ref.watch(selectedWalletIndexProvider);
    
    // Watch user state from Riverpod - this will trigger rebuild when user logs in
    final currentUser = ref.watch(currentUserProvider);
    
    // Check if wallet is ready
    if (selectedWalletIndex == -1 || walletListAsync.isLoading) {
      return Loading();
    }
    
    // Use Riverpod state for user check instead of AppGlobals
    if (currentUser == null || AppGlobals.userInfo == null) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: ScreenUtil().setWidth(120),
        ),
        child: LoginPage(type: 1),
      );
    }
    
    if (isReadChatService == false) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: ScreenUtil().setWidth(120),
        ),
        child: ChatServices(
          '${AppConfig.apiUrl['walletamazeBrowser']}/static/chat_policy.html?theme=${Theme.of(context).brightness == Brightness.dark ? "dark" : ""}',
          agreeCallBack: () {
            SPUtil().setHasAcceptedTerms(true);
            isReadChatService = true;
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );
    }
    return ChatList();
  }
}

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> with AutomaticKeepAliveClientMixin{
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
  ChatUtil? _chatUtil;
  ChatUtil get chatUtil{
    _chatUtil ??= ChatUtil();
    return _chatUtil!;
  }
  final CustomPopupMenuController _popupMenuController =
  CustomPopupMenuController();

  Timer? _timer;
  bool isLoading = false;
  List _unReadMessageUUIDs = [];
  String? mPrivateKey;


  StreamSubscription? eventBusFn;
  @override
  void initState() {
    super.initState();
    WebSocketUtil.instance.connect();
    //监听事件 更新会话列表
    eventBusFn=eventBus.on().listen((event) {
      if (event is EventPublic &&
          event.type == EventPublicType.updateChatConversationList) {
        startRefreshTimer(getChatConversationList);
      }

      //用户切换钱包时 重新绑定用户的公钥匙
      if (event is EventPublic && event.type == EventPublicType.selectWallet) {
        if(event.stringValue=="mainwallet"){
          bindUserPubKey();
        }
      }
    });

    initData();
  }

  //绑定用户的钱包公钥匙
  bindUserPubKey() async {
    SquadApi squadApi=SquadApi();
    mPrivateKey = await chatUtil.getAstPrivateKey();
    final pubKey = await chatUtil.getAstPubKey();
    MessageModel data = await squadApi.bindPubKey(pubKey!);
    if(data.error){
      if(data.type==MessageErrorType.E1403){
        AppGlobals.logout();
      }
    }
  }

  initData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await bindUserPubKey();
      if (!mounted) return;
      //先处理完离线消息
      ChatMessageProvider cmp=legacy_provider.Provider.of<ChatMessageProvider>(context,listen: false);
      await cmp.initData();


      await cmp.getChatConversationList();
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    checkUnReadMessage();
  }

  checkUnReadMessage() async {
    // final list = await SPUtils.getListObject("message_read_list");
    final list = await CacheMessageIsReadUtils().getUnReadIds();
    if (list != null && list is List) {
      _unReadMessageUUIDs = list;
      if (mounted) {
        setState(() {});
      }
    }
  }

  //收到消息延迟2s更新ui 2s内接收到刷新通知 不在更新
  void startRefreshTimer(Function refreshFunction) {
    _cancelTimer();
    _timer = Timer(const Duration(seconds: 2), () {
      refreshFunction();
      _timer = null;
    });
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  getChatConversationList() async {
    await legacy_provider.Provider.of<ChatMessageProvider>(context,listen: false).getChatConversationList();

    //会话列表更新完成之后 更新未读消息
    checkUnReadMessage();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelTimer();
    eventBusFn.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      child: Container(
        height: double.infinity,//MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
        ),
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        child: Column(
          children: [
            AppHomeTopBar(
              title: S.of(context).g_home_key5,
              onLeftImageClick: () {
                Scaffold.of(context).openDrawer();
              },
              onLeftImageUri: "assets/wallet/menu.png",
              actions: [
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(24.0)),
                    child: Icon(
                      Icons.qr_code_rounded,
                      size: ScreenUtil().setWidth(52.0),
                    ),
                  ),
                  onTap: () async {
                    List params = [
                      AppGlobals.userInfo?.image,
                      AppGlobals.userInfo?.name,
                      AppGlobals.userInfo?.email,
                      AppGlobals.userInfo?.uuid,
                    ];
                    String qrContent =
                    json.encode({"chat_message": params});
                    // debugPrint("qr code content: ${qrContent.toString()}");
                    SheetBottom(
                        context,
                        "",
                        QCodeChat(
                          content: qrContent,
                        ));
                  },
                ),
                CustomPopupMenuWrap(
                    defView: Stack(
                      children: [
                        Image.asset(
                          "assets/chat/add-circle.png",
                          width: ScreenUtil().setWidth(52.0),
                          fit: BoxFit.cover,
                        ),
                        //是否有未处理的消息
                        legacy_provider.Consumer<ChatMessageProvider>(builder: (
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
                            child: Transform.translate(
                              offset: Offset(ScreenUtil().setWidth(10.0), ScreenUtil().setWidth(10.0) * -1),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Color(0xffFC2E01),
                                    shape: BoxShape.circle),
                                width: ScreenUtil().setWidth(30.0),
                                height: ScreenUtil().setWidth(30.0),
                                alignment: Alignment.center,
                                child:Text(
                                  "${value.haveNewFriend}",
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(20.0),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                          );
                        })
                      ],
                    ),
                    controller: _popupMenuController,
                    menuItemView: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0),),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainBlueColor.name),
                          border:
                          Border.all(color: Colors.blueAccent)),
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(24.0), horizontal: ScreenUtil().setWidth(24.0),),
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      children: [
                                        Image.asset(
                                          "assets/chat/add_contacts.png",
                                          width: ScreenUtil().setWidth(48.0),
                                          fit: BoxFit.cover,
                                          color: Colors.white,
                                        ),
                                        legacy_provider.Consumer<ChatMessageProvider>(builder: (
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
                                            child: Transform.translate(
                                              offset: Offset(ScreenUtil().setWidth(10.0), ScreenUtil().setWidth(10.0) * -1),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Color(0xffFC2E01),
                                                    shape: BoxShape.circle),
                                                width: ScreenUtil().setWidth(30.0),
                                                height: ScreenUtil().setWidth(30.0),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "${value.haveNewFriend}",
                                                  style: TextStyle(
                                                    fontSize: ScreenUtil().setSp(20.0),
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                      ],
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(24.0),
                                    ),
                                    Text(
                                      S.of(context).g_chat_key_41,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil().setSp(30.0)),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () async {
                                _popupMenuController.hideMenu();
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const FriendsListPage()));
                              },
                            ),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24.0),),
                              child: Divider(
                                color: Colors.white54,
                                endIndent: 1,
                                indent: 1,
                              ),
                            ),
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(16.0),),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/chat/start_chat.png",
                                      width: ScreenUtil().setWidth(48.0),
                                      fit: BoxFit.cover,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(24.0),
                                    ),
                                    Text(
                                      S.of(context).g_chat_key_42,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil().setSp(30.0)),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () async {
                                _popupMenuController.hideMenu();
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const CreateGroupPage()));
                              },
                            ),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24.0),),
                              child: Divider(
                                color: Colors.white54,
                                endIndent: 1,
                                indent: 1,
                              ),
                            ),
                            GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setWidth(16.0),),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/wallet/scan.png",
                                      width: ScreenUtil().setWidth(48.0),
                                      color: Colors.white,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(24.0),
                                    ),
                                    Text(
                                      S.of(context).g_chat_key_43,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil().setSp(30.0)),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () async {
                                _popupMenuController.hideMenu();
                                String? scanValue =
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScanPage(),
                                  ),
                                );
                                // debugPrint("scanValue:$scanValue");
                                // scanValue =
                                //     '{"chat_message":["https://bafybeibfrqt6xpcwiowk3rxltpsowtt34pj6sm3cxf6wsdnkyiy4cdiaz4.ipfs.nftstorage.link/aImage.png","youran","zhcandroi1212121d@163.com","3478c642-6b69-4fc8-954f-ebe660b710c3"]}';
                                if (scanValue == null) return;
                                final map = json.decode(scanValue);
                                debugPrint(
                                    "map_message ; ${map["chat_message"]}");
                                if (map["chat_message"] != null &&
                                    map["chat_message"] is List) {
                                  String? uuid =
                                  map["chat_message"][3];

                                  final friendData =
                                  await chatApi.getUserInfo(
                                      uuid ?? '');
                                  if (!mounted) return;
                                  if (friendData != null &&
                                      friendData["code"] == 200) {
                                    FriendInfo fInfo =
                                    FriendInfo.fromJson(
                                        friendData["data"]);
                                    await Navigator.of(this.context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (_) => FriendDetail(
                                          info: fInfo,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    arrowColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                )
              ],
            ),
            buildContent()
          ],
        ),
      ),
    );
  }

  buildContent() {
    return Expanded(
      child: isLoading ? Loading(): legacy_provider.Consumer<ChatMessageProvider>(
        builder: (BuildContext context, ChatMessageProvider value, Widget? child) {
            return DetailRefreshWidget(
              callback: () async {
                //先处理完离线消息
                ChatMessageProvider cmp=legacy_provider.Provider.of<ChatMessageProvider>(context,listen: false);
                await cmp.initData();
                await cmp.getChatConversationList();
              },
              childWidget: value.chatConversationList.isEmpty?
              SizedBox(
                height: ScreenUtil().screenHeight-240,
                child: EmptyView(),
              ) :
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SlidableAutoCloseBehavior(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(0),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: value.chatConversationList.length,
                      itemBuilder: (context, index) {
                        ChatMessageModel cm =
                        value.chatConversationList[index];
                        return Slidable(
                          key: ValueKey(index),
                          groupTag: "chat_group_tag",
                          closeOnScroll: true,
                          enabled: true,
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.2,
                            // dismissible: DismissiblePane(onDismissed: () {}),
                            children: [
                              SlidableAction(
                                onPressed: (slidableContext) async {
                                  await chatDBApi
                                      .deleteMessageByTargetId(
                                      cm.getTargetId());
                                  if (!context.mounted) return;
                                  await legacy_provider.Provider.of<ChatMessageProvider>(context,listen: false)
                                      .getChatConversationList();
                                },
                                backgroundColor:
                                const Color(0xffFE3B30),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                //label: S.of(context).g_key_113,
                                autoClose: true,
                              ),
                            ],
                          ),
                          child: ItemConversation(
                            item: cm,
                            mPrivateKey: mPrivateKey ?? '',
                            isRead: !_unReadMessageUUIDs
                                .contains(cm.targetId),
                            onTap: () async {
                              if (cm.conversationType == 0) {
                                await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (_) => ChatDetailPage(
                                    targetUuid: cm.targetId,
                                    conversationType:
                                    cm.conversationType,
                                  ),
                                ));
                              } else {
                                await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (_) => ChatGroupDetailPage(
                                    targetUuid: cm.targetId,
                                    conversationType:
                                    cm.conversationType,
                                  ),
                                ));
                              }
                              if (!context.mounted) return;
                              //更新未读消息
                              checkUnReadMessage();
                              legacy_provider.Provider.of<ChatMessageProvider>(context,listen: false).updateUnReadMessNum();
                            },
                            onLongPress: () async {
                              //长按弹出删除对话框
                              final flagResult = await TipsDialog2(
                                context,
                                S.current.g_chat_key_34,
                              );
                              if (!context.mounted) return;
                              if (flagResult != null && flagResult) {
                                await chatDBApi
                                    .deleteMessageByTargetId(
                                    cm.getTargetId());
                                // //更新列表
                                // await ProviderUtil
                                //         .chatMessageProvider()
                                //     .initData();
                                if (!context.mounted) return;
                                await legacy_provider.Provider.of<ChatMessageProvider>(context,listen: false)
                                    .getChatConversationList();
                              }
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context,int index){
                        return Divider(
                          height: 1,
                          indent: ScreenUtil().setWidth(110.0),
                          endIndent: 0,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemLineColor.name),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setWidth(120.0),
                  )
                ],
              ),
            );
          },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
