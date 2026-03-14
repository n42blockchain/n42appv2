import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/home/setting/about_app.dart';
import 'package:n42_wallet/features/home/setting/personal_setting.dart';
import 'package:n42_wallet/features/home/setting/setting_share.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/news/news_page.dart';
import 'package:n42_wallet/features/notification/pages/message_info.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/features/widgets/base_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_chat/n42_chat.dart';

/// Message List Page - Migrated to Riverpod
///
/// Displays user notifications and messages
class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key});

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  late final UserInfoApi userInfoApi = UserInfoApi();

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
      appBar: AppBarWidget(text: S.of(context).g_notification_key_1),
      body: BaseList(
        crossAxisSpacing: 20.0.w,
        mainAxisSpacing: 20.0.w,
        buildItem: (BuildContext context, List<dynamic> results, int index) {
          Map<String, dynamic> map = results[index];
          String title = map['subject'];
          int created = (map['created'] ?? 0) as int;
          final createdDt = DateTime.fromMicrosecondsSinceEpoch(created * 1000);
          final createTime = DateFormat("dd-MM-yyyy HH:mm").format(createdDt);
          final dateFmt = DateFormat("dd-MM-yyyy");
          map["showDate"] = dateFmt.format(createdDt);
          if (dateFmt.format(DateTime.now()) == map["showDate"]) {
            map["showDate"] = S.of(context).g_chat_key_61;
          }
          final showData2 = index != 0
              ? results[index - 1]['showDate'] as String
              : "";
          Map<String, dynamic> txContent = {};
          try {
            txContent = json.decode(map['content']);
          } catch (e) {
            debugPrint("json err:${e.toString()}");
          }
          final coin = txContent['coin'] as String? ?? "";
          final msgType = map['msg_type'] as String? ?? "";
          switch (msgType) {
            case "tokens_received":
            case "tokens_sent":
            case "normal_transaction_failed":
              String content;
              if (msgType == "tokens_received") {
                content =
                    "Transaction hash ${txContent['hash']}, ${txContent['from']} to you ${txContent['num']}$coin";
              } else if (msgType == "tokens_sent") {
                content =
                    "Transaction hash ${txContent['hash']}, you sent ${txContent['num']}$coin to ${txContent['to']} ";
              } else {
                content =
                    "Your pending transaction ${txContent['hash']} failed.";
              }
              return transferItemWidget(
                title,
                content,
                createTime,
                "transfer",
                () => _navigateToTxBrowser(txContent),
                map["showDate"],
                showData2,
              );
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
            case "NFTHome #1_normal":
            case "NFTHome #2_normal":
              return const SizedBox();
            case "normal_price_changed":
              double percentage = double.parse(
                (txContent['percentage'] ?? 0).toString(),
              );
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
                    MaterialPageRoute(builder: (_) => MessageInfo(infoMap)),
                  );
                },
                map["showDate"],
                showData2,
              );
            case "tell_friends":
              return transferItemWidget(
                title,
                "",
                createTime,
                "transfer",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingShare()),
                  );
                },
                map["showDate"],
                showData2,
              );
            case "Tell Friends #1_normal":
            case "Tell Friends #2_normal":
              //跳转分享页
              return transferItemWidget(
                title,
                "",
                createTime,
                "info",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingShare()),
                  );
                },
                map["showDate"],
                showData2,
              );
            case "chat":
            case "ChatHome #1_normal":
            case "ChatHome #2_normal":
              return transferItemWidget(
                title,
                "",
                createTime,
                "info",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => N42Chat.chatWidget()),
                  );
                },
                map["showDate"],
                showData2,
              );
            case "News_normal":
              return transferItemWidget(
                title,
                "",
                createTime,
                "info",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewsPage()),
                  );
                },
                map["showDate"],
                showData2,
              );
            case "Login_normal":
            case "WalletHome #1_normal":
            case "WalletHome #2_normal":
            case "Homepage_normal":
              return transferItemWidget(
                title,
                "",
                createTime,
                "info",
                () {
                  ref.read(mainTabSelectIndexProvider.notifier).state = 0;
                  Navigator.pop(context);
                },
                map["showDate"],
                showData2,
              );
            case "AboutSettings_normal":
              //跳转关于我们页面
              return transferItemWidget(
                title,
                "",
                createTime,
                "info",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AboutApp()),
                  );
                },
                map["showDate"],
                showData2,
              );
            case "SettingsProfile_normal":
              //跳转设置个人信息页面
              return transferItemWidget(
                title,
                "",
                createTime,
                "info",
                () {
                  if (AppGlobals.userInfo != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PersonalSetting()),
                    );
                  }
                },
                map["showDate"],
                showData2,
              );
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
          );
          if (!marketData.error && marketData.data != null) {
            return (marketData.data['list'] as List);
          }
          return [];
        },
        isGridview: false,
        firstRefresh: true,
        pageIndex: 1,
        pageSize: 100,
      ),
    );
  }

  /// 导航到交易浏览器页面（提取自重复的 tokens_received/tokens_sent/normal_transaction_failed 逻辑）
  void _navigateToTxBrowser(Map<String, dynamic> txContent) {
    final String? isTestStr = txContent['network'];
    final bool? isTest = isTestStr != null ? isTestStr == "test" : null;
    final String bUri = getBrowserTxHash(
      txContent['coin'],
      txContent['hash'] ?? "",
      isTest: isTest,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrowserPage(bUri)),
    );
  }

  Widget transferItemWidget(
    String title,
    String content,
    String createTime,
    String mType,
    VoidCallback onTap,
    String showDate1,
    String showDate2, {
    String? imgUrl,
  }) {
    final itemTextColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemTextColor.name,
    );
    final subtitleColor = AppThemeUtils.getColorByKey(
      context,
      AppThemeKeys.itemSubtitleTextColor.name,
    );

    Widget item = InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15.0.w, horizontal: 30.0.w),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemBgColor.name,
          ),
          borderRadius: BorderRadius.circular(24.0.w),
        ),
        padding: EdgeInsets.all(30.0.w),
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
                      color: itemTextColor,
                      fontSize: 28.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.0.w),
                  Text(
                    content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: subtitleColor, fontSize: 24.0.sp),
                  ),
                  SizedBox(height: 32.0.w),
                  Text(
                    createTime,
                    style: TextStyle(color: subtitleColor, fontSize: 20.0.sp),
                  ),
                ],
              ),
            ),
            if (imgUrl != null)
              CachedNetworkImage(
                imageUrl: imgUrl,
                width: 100.w,
                height: 100.w,
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
      ),
    );
    if (showDate1 == showDate2) {
      return item;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0.w),
          child: Text(
            showDate1,
            style: TextStyle(color: subtitleColor, fontSize: 24.0.sp),
          ),
        ),
        item,
      ],
    );
  }
}
