import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/src/browser/pages/browser_page.dart';
import 'package:n42_wallet/src/home/setting/about_app.dart';
import 'package:n42_wallet/src/home/setting/personal_setting.dart';
import 'package:n42_wallet/src/home/setting/setting_share.dart';
import 'package:n42_wallet/src/login/api/user_info_api.dart';
import 'package:n42_wallet/src/models/message_model.dart';
import 'package:n42_wallet/src/news/news_page.dart';
import 'package:n42_wallet/src/notification/pages/message_info.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/wallet/utils/browser_txhash.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/base_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/generated/l10n.dart';

/// Message List Page - Migrated to Riverpod
/// 
/// Displays user notifications and messages
class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key});

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  UserInfoApi? _userInfoApi;
  UserInfoApi get userInfoApi {
    _userInfoApi ??= UserInfoApi();
    return _userInfoApi!;
  }
  
  @override
  void initState() {
    super.initState();
    // Clear unread count when opening message list - using Riverpod
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unreadCountProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_notification_key_1,
      ),
      body: BaseList(
        crossAxisSpacing: ScreenUtil().setWidth(20.0),
        mainAxisSpacing: ScreenUtil().setWidth(20.0),
        buildItem: (BuildContext context, List<dynamic> results, int index) {
          //market_nft_received
          Map<String, dynamic> map = results[index];
          String title = map['subject'];
          int created = (map['created'] ?? 0) as int;
          DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm");
          String createTime = dateFormat
              .format(DateTime.fromMicrosecondsSinceEpoch(created * 1000));
          dateFormat = DateFormat("dd-MM-yyyy");
          map["showDate"]=dateFormat
              .format(DateTime.fromMicrosecondsSinceEpoch(created * 1000));
          String nowDate=dateFormat
              .format(DateTime.now());
          if(nowDate==map["showDate"]){
            map["showDate"]=S.of(context).g_chat_key_61;
          }
          String showData2="";
          if(index !=0){
            showData2=results[index-1]['showDate'];
          }
          Map<String, dynamic> txContent = {};
          try {
            txContent = json.decode(map['content']);
          } catch (e) {
            debugPrint("json err:${e.toString()}");
          }
          String coin = txContent['coin'] ?? "";
          String msgType = map['msg_type'] ?? "";
          switch (msgType) {
            case "tokens_received":
              String content =
                  "Transaction hash ${txContent['hash']}, ${txContent['from']} to you ${txContent['num']}$coin";
              return transferItemWidget(title, content, createTime, "transfer",
                    () => _navigateToTxBrowser(txContent),
                map["showDate"],showData2,);
            case "tokens_sent":
              String content =
                  "Transaction hash ${txContent['hash']}, you sent ${txContent['num']}$coin to ${txContent['to']} ";
              return transferItemWidget(title, content, createTime, "transfer",
                    () => _navigateToTxBrowser(txContent),
                map["showDate"],showData2,);
            case "normal_transaction_failed":
              String content =
                  "Your pending transaction ${txContent['hash']} failed.";
              return transferItemWidget(title, content, createTime, "transfer",
                    () => _navigateToTxBrowser(txContent),
                map["showDate"],showData2,);
            // NFT 相关消息类型（功能已下线，保留 case 返回空组件）
            case "market_nft_sell_to_consumer":
            case "market_nft_sell_to_owner":
            case "auction_nft_sell_to_consumer":
            case "auction_nft_sell_to_owner":
            case "auction_nft_bid_to_owner":
            case "auction_nft_bid_to_consumer":
            case "trade_limit":
            case "normal_followed":
            case "normal_trending":
              return SizedBox();
            case "normal_price_changed":
              double percentage = double.parse((txContent['percentage'] ?? 0).toString());
              String chain = txContent['chain'] ?? "";
              String content =
                  "Over $percentage% change in the price of ${chain.toUpperCase()} within 24 hours. ";
              return transferItemWidget(
                title,
                content,
                createTime,
                "info",
                    () {
                  Map<String, dynamic> infoMap = {
                    "title": title,
                    "content": content,
                    "created": createTime,
                  };
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MessageInfo(infoMap)));
                },map["showDate"],showData2,
              );
            case "tell_friends":
              return transferItemWidget(title, "", createTime, "transfer",
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SettingShare()));},map["showDate"],showData2,);
            case "Tell Friends #1_normal":
            case "Tell Friends #2_normal":
            //跳转分享页
              return transferItemWidget(title, "", createTime, "info",
                    () {
                  Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => SettingShare(),));
                },map["showDate"],showData2,);
            case "NFTHome #1_normal":
            case "NFTHome #2_normal":
              return SizedBox();
            case "ChatHome #1_normal":
            case "ChatHome #2_normal":
              return transferItemWidget(title, "", createTime, "info",
                    () {
                ref.read(mainTabSelectIndexProvider.notifier).state = 2;
                  Navigator.pop(context);
                },map["showDate"],showData2,);
            case "News_normal":
              return transferItemWidget(title, "", createTime, "info",
                    () {
                  Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => NewsPage(),));
                },map["showDate"],showData2,);
            case "Login_normal":
              return transferItemWidget(title, "", createTime, "info",
                    () {
                  ref.read(mainTabSelectIndexProvider.notifier).state = 0;
                  Navigator.pop(context);
                },map["showDate"],showData2,);

            case "AboutSettings_normal":
            //跳转关于我们页面
              return transferItemWidget(title, "", createTime, "info",
                    () {
                  Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => AboutApp(),));
                },map["showDate"],showData2,);
            case "WalletHome #1_normal":
            case "WalletHome #2_normal":
              return transferItemWidget(title, "", createTime, "info",
                    () {
                  ref.read(mainTabSelectIndexProvider.notifier).state = 0;
                  Navigator.pop(context);
                },map["showDate"],showData2,);
            case "SettingsProfile_normal":
            //跳转设置个人信息页面
              return transferItemWidget(title, "", createTime, "info",
                    () {
                  if(AppGlobals.userInfo !=null){
                    Navigator.push(context,
                        MaterialPageRoute(
                          builder: (_) => PersonalSetting(),));
                  }
                },map["showDate"],showData2,);
            case "Homepage_normal":
              return transferItemWidget(title, "", createTime, "info",
                    () {
                      ref.read(mainTabSelectIndexProvider.notifier).state = 0;
                  Navigator.pop(context);
                },map["showDate"],showData2,);
            default:
              return Container();
          }
        },
        getData: (int page, int pageSize) async {
          //调用接口
          //获取消息列表
          MessageModel marketData = await userInfoApi.getMsgNoticeList(
            page: page,
            pageSize: pageSize,
            //msgType: ""
          );
          if (marketData.error == false) {
            if (marketData.data != null) {
              return (marketData.data['list'] as List);
            }
          }
          return Future.value([]);
        },
        isGridview: false,
        //childAspectRatio: 1,
        firstRefresh: true,
        pageIndex: 1,
        pageSize: 100,
      ),
    );
  }

  /// 导航到交易浏览器页面（提取自重复的 tokens_received/tokens_sent/normal_transaction_failed 逻辑）
  void _navigateToTxBrowser(Map<String, dynamic> txContent) {
    final String? isTestStr = txContent['network'];
    bool? isTest;
    if (isTestStr != null) {
      isTest = isTestStr == "test";
    }
    final String bUri = getBrowserTxHash(
        txContent['coin'], txContent['hash'] ?? "", isTest: isTest);
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => BrowserPage(bUri)));
  }

  Widget transferItemWidget(String title, String content, String createTime,
      String mType, dynamic onTap,String showDate1,String showDate2,
      {String? imgUrl}) {
    Widget item= InkWell(
        onTap: () {
          onTap();
        },
        child: Container(
          margin: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(15.0), horizontal: ScreenUtil().setWidth(30.0)),
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24.0))),
          padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemTextColor.name),
                          fontSize: ScreenUtil().setSp(28.0),
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(16.0),
                    ),
                    Text(
                      content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: ScreenUtil().setSp(24.0),
                      ),

                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(32.0),
                    ),
                    Text(
                      createTime,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(
                            context, AppThemeKeys.itemSubtitleTextColor.name),
                        fontSize: ScreenUtil().setSp(20.0),
                      ),
                    ),
                  ],
                ),
              ),
              if (imgUrl != null)
                CachedNetworkImage(
                  imageUrl: imgUrl,
                  width: ScreenUtil().setWidth(100),
                  height: ScreenUtil().setWidth(100),
                  fit: BoxFit.cover,
                  placeholder: (context, String url) {
                    return Image.asset("assets/img/default_img.png");
                  },
                  errorWidget: (context, String url, dynamic error) {
                    return Image.asset("assets/img/default_img.png");
                  },
                ),
            ],
          ),
        ));
    if(showDate1==showDate2){
      return item;
    }else{
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15.0)),
            child: Text(
              showDate1,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                fontSize: ScreenUtil().setSp(24.0),
              ),
            ),
          ),
          item,
        ],
      );
    }
  }
}
