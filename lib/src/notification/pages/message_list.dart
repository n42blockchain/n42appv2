import 'dart:convert';

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/home/setting/about_app.dart';
import 'package:n42appv2/src/home/setting/personal_setting.dart';
import 'package:n42appv2/src/home/setting/setting_share.dart';
import 'package:n42appv2/src/login/api/user_info_api.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/news/news_page.dart';
import 'package:n42appv2/src/notification/pages/message_info.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/utils/browser_txhash.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/base_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:n42appv2/generated/l10n.dart';

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
          if (coin == CoinType.N.name) {
            coin = CoinType.N.name;
          }
          String msg_type = map['msg_type'] ?? "";
          switch (msg_type) {
            case "tokens_received":
              String content =
                  "Transaction hash ${txContent['hash']}, ${txContent['from']} to you ${txContent['num']}$coin";
              return transferItemWidget(title, content, createTime, "transfer",
                    () {
                  String? isTestStr=txContent['network'];
                  bool? isTest;
                  if(isTestStr !=null){
                    isTest=isTestStr=="test"?true:false;
                  }
                  String bUri = getBrowser_txHash(
                      txContent['coin'], txContent['hash'] ?? "",isTest: isTest);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BrowserPage(bUri,
                            //"Transaction"
                          )));
                },map["showDate"],showData2,);
            case "tokens_sent":
              String content =
                  "Transaction hash ${txContent['hash']}, you sent ${txContent['num']}$coin to ${txContent['to']} ";
              return transferItemWidget(title, content, createTime, "transfer",
                    () {
                  String? isTestStr=txContent['network'];
                  bool? isTest;
                  if(isTestStr !=null){
                    isTest=isTestStr=="test"?true:false;
                  }
                  String bUri = getBrowser_txHash(
                      txContent['coin'], txContent['hash'] ?? "",isTest: isTest);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BrowserPage(bUri,
                            //"Transaction"
                          )));
                },map["showDate"],showData2,);
            case "normal_transaction_failed":
              String content =
                  "Your pending transaction ${txContent['hash']} failed.";
              return transferItemWidget(title, content, createTime, "transfer",
                    () {
                  String? isTestStr=txContent['network'];
                  bool? isTest;
                  if(isTestStr !=null){
                    isTest=isTestStr=="test"?true:false;
                  }
                  String bUri = getBrowser_txHash(
                      txContent['coin'], txContent['hash'] ?? "",isTest: isTest);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BrowserPage(bUri,
                            //"Transaction"
                          )));
                },map["showDate"],showData2,);
            case "market_nft_sell_to_consumer":
              return SizedBox();
              /*Map<String, dynamic>? nftInfo = txContent['nft_info'];
              String nftName = "";
              String? imgUrl;
              NftModel? nftModel;
              if (nftInfo != null) {
                nftModel = NftModel.fromJson(nftInfo);
                nftModel.price =
                    (txContent['nft_market_info']['price'] ?? 0).toDouble();
                nftName = nftModel.uriData.name ?? "";
                imgUrl = nftModel.uriData.imageMini;
              }
              String content = "Received; ${nftName} has been received. ";
              return transferItemWidget(
                title,
                content,
                createTime,
                "nft",
                    () {
                  if (nftModel == null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NftBuyHistoryPage()
                          //MyApp(bUri, "Transaction")
                        ));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MyNftInfo(
                              nftModel!,
                              4,
                              false,
                              showRemaining: true,
                              loadNftDetail: true,
                            )
                          //MyApp(bUri, "Transaction")
                        ));
                  }
                },map["showDate"],showData2,
                imgUrl: imgUrl,
              );*/
            case "market_nft_sell_to_owner":
              return SizedBox();
              /*Map<String, dynamic>? nftInfo = txContent['nft_info'];
              String nftName = "";
              String? imgUrl;
              NftModel? nftModel;
              if (nftInfo != null) {
                nftModel = NftModel.fromJson(nftInfo);
                nftModel.price =
                    (txContent['nft_market_info']['price'] ?? 0).toDouble();
                nftName = nftModel.uriData.name ?? "";
                imgUrl = nftModel.uriData.imageMini;
              }
              String content =
                  "Nice! You sold ${nftName} for ${txContent['num']}${coin}.";
              return transferItemWidget(title, content, createTime, "nft", () {
                if (nftModel == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NftOnSalePage(1)
                        //MyApp(bUri, "Transaction")
                      ));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyNftInfo(
                            nftModel!,
                            0,
                            false,
                            showRemaining: true,
                            loadNftDetail: true,
                          )));
                }
              },map["showDate"],showData2, imgUrl: imgUrl);
              */
            case "auction_nft_sell_to_consumer":
              return SizedBox();
              /*Map<String, dynamic>? nftInfo = txContent['nft_info'];
              String nftName = "";
              String? imgUrl;
              NftModel? nftModel;
              if (nftInfo != null) {
                nftModel = NftModel.fromJson(nftInfo);
                nftModel.price =
                    (txContent['nft_auction_info']['price'] ?? 0).toDouble();
                nftName = nftModel.uriData.name ?? "";
                imgUrl = nftModel.uriData.imageMini;
              }
              //
              String content = "Received; ${nftName} has been received. ";
              return transferItemWidget(title, content, createTime, "nft", () {
                if (nftModel == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NftBuyHistoryPage()
                        //MyApp(bUri, "Transaction")
                      ));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MyNftInfo(
                            nftModel!,
                            0,
                            false,
                            showRemaining: true,
                            loadNftDetail: true,
                          )));
                }
              },map["showDate"],showData2, imgUrl: imgUrl);
              */
            case "auction_nft_sell_to_owner":
              return SizedBox();
              /*Map<String, dynamic>? nftInfo = txContent['nft_info'];
              String nftName = "";
              String? imgUrl;
              NftModel? nftModel;
              if (nftInfo != null) {
                nftModel = NftModel.fromJson(nftInfo);
                nftModel.price =
                    (txContent['nft_auction_info']['price'] ?? 0).toDouble();
                nftName = nftModel.uriData.name ?? "";
                imgUrl = nftModel.uriData.imageMini;
              }
              String content =
                  "Nice! You sold ${nftName} for ${txContent['num']}${coin}.";
              return transferItemWidget(title, content, createTime, "nft", () {
                if (nftModel == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NftOnSalePage(1)
                        //MyApp(bUri, "Transaction")
                      ));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyNftInfo(
                            nftModel!,
                            0,
                            false,
                            showRemaining: true,
                            loadNftDetail: true,
                          )));
                }
              },map["showDate"],showData2, imgUrl: imgUrl);
              */
            case "auction_nft_bid_to_owner":
              return SizedBox();
              /*Map<String, dynamic>? nftInfo = txContent['nft_info'];
              String nftName = "";
              String? imgUrl;
              NftModel? nftModel;
              if (nftInfo != null) {
                nftModel = NftModel.fromJson(nftInfo);
                nftModel.price =
                    (txContent['nft_auction_info']['price'] ?? 0).toDouble();
                nftName = nftModel.uriData.name ?? "";
                imgUrl = nftModel.uriData.imageMini;
              }
              String content =
                  "You received a new bid of ${txContent['num']}${coin} on ${nftName}.";
              return transferItemWidget(title, content, createTime, "nft", () {
                if (nftModel == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NftOnSalePage(1)
                        //MyApp(bUri, "Transaction")
                      ));
                } else {
                  AuctionModel auctionModel =
                  AuctionModel.fromJson(txContent['nft_auction_info']);
                  auctionModel.nft = nftModel;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => NFTAuctionInfo(auctionModel:auctionModel)
                        //MyNftInfo(nftModel!,0,showRemaining: true,loadNftDetail: true,)
                        //MyApp(bUri, "Transaction")
                      ));
                }
              },map["showDate"],showData2, imgUrl: imgUrl);
              */
            case "auction_nft_bid_to_consumer":
              return SizedBox();
              /*Map<String, dynamic>? nftInfo = txContent['nft_info'];
              String nftName = "";
              String? imgUrl;
              NftModel? nftModel;
              if (nftInfo != null) {
                nftModel = NftModel.fromJson(nftInfo);
                nftModel.price =
                    (txContent['nft_auction_info']['price'] ?? 0).toDouble();
                nftName = nftModel.uriData.name ?? "";
                imgUrl = nftModel.uriData.imageMini;
              }
              String content =
                  "Your ${txContent['num']}${coin} bid on ${nftName} was accepted.";
              return transferItemWidget(title, content, createTime, "nft", () {
                if (nftModel == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NftBuyHistoryPage()
                        //MyApp(bUri, "Transaction")
                      ));
                } else {
                  AuctionModel auctionModel =
                  AuctionModel.fromJson(txContent['nft_auction_info']);
                  auctionModel.nft = nftModel;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => NFTAuctionInfo(auctionModel:auctionModel)
                        //MyNftInfo(nftModel!,0,showRemaining: true,loadNftDetail: true,)
                        //MyApp(bUri, "Transaction")
                      ));
                }
              },map["showDate"],showData2, imgUrl: imgUrl);
              */
            case "trade_limit":
              return SizedBox();
              /*String content =
                  "Your ${txContent['num']} limit order on [Asset Name] has been filled. ";
              return transferItemWidget(title, content, createTime, "nft", () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NftBuyHistoryPage()
                      //MyApp(bUri, "Transaction")
                    ));
              },map["showDate"],showData2,);
              */
            case "normal_price_changed":
            //percentage,chain
            // over 10% change in the price of BTC, ETH or AsT within 24 hours.
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
                      MaterialPageRoute(builder: (_) => MessageInfo(infoMap)
                        //MyApp(bUri, "Transaction")
                      ));
                },map["showDate"],showData2,
              );
            case "normal_followed":
              return SizedBox();
              /*String username = txContent['follow_name'] ?? "";
              String content = "${username} has followed you!";
              return transferItemWidget(
                title,
                content,
                createTime,
                "info",
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => NftUserHome(
                            user_uuid: txContent['follow_uuid'] ?? "",
                            getUserInfo: true,
                          )
                        //MyApp(bUri, "Transaction")
                      ));
                },map["showDate"],showData2,
              );*/
            case "normal_trending":
              return SizedBox();
              /*String content =
                  "Check out these NFTs trending on our marketplace.";
              return transferItemWidget(
                title,
                content,
                createTime,
                "info",
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              NftSearch(searchMap: {'specify_24h_like': true})
                        //MyApp(bUri, "Transaction")
                      ));
                },map["showDate"],showData2,
              );
              */
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
              /*return transferItemWidget(title, "", createTime, "info",
                    () {
                  ProviderUtil.publicProvider().setSelectIndex(2);
                  Navigator.pop(context);
                },map["showDate"],showData2,);
              break;*/
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

  transferItemWidget(String title, String content, String createTime,
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
