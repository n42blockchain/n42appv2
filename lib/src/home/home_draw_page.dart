import 'dart:ui';

import 'package:n42appv2/application.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/home/setting/about_app.dart';
import 'package:n42appv2/src/home/setting/personal_setting.dart';
import 'package:n42appv2/src/home/setting/setting_home_page.dart';
import 'package:n42appv2/src/home/setting/setting_share.dart';
import 'package:n42appv2/src/notification/pages/message_list.dart';
import 'package:n42appv2/src/state/public_provider.dart';
import 'package:n42appv2/src/utils/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/address_book/address_book_List.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_6.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/app_config.dart';

class HomeDrawPage extends StatefulWidget {
  const HomeDrawPage({super.key});

  @override
  State<HomeDrawPage> createState() => _HomeDrawPageState();
}

class _HomeDrawPageState extends State<HomeDrawPage> with AutomaticKeepAliveClientMixin{

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipRRect(
        borderRadius:BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        child: Container(
          color:
          AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Consumer<PublicProvider>(
                      builder: (context, value, child) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MessageList()));
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: ScreenUtil().setWidth(20.0)),
                              width: ScreenUtil().setWidth(60.0),
                              height: ScreenUtil().setWidth(60.0),
                              // margin: EdgeInsets.only(right: scr.setWidth(30.0)),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: ScreenUtil().setWidth(10),
                                    left: ScreenUtil().setWidth(10),
                                    right: ScreenUtil().setWidth(10),
                                    bottom: ScreenUtil().setWidth(10),
                                    child: Image.asset(
                                      "assets/home/notification.png",
                                      width: ScreenUtil().setWidth(40),
                                      color: AppThemeUtils.getColorByKey(
                                          context, AppThemeKeys.mainBlueColor.name),
                                    ),
                                  ),
                                  if (value.messageNotReadCount != 0)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: ScreenUtil().setWidth(30),
                                        height: ScreenUtil().setWidth(30),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              ScreenUtil().setWidth(30)),
                                          color: AppThemeUtils.getColorByKey(
                                              context,
                                              AppThemeKeys.errorTextColor.name),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${value.messageNotReadCount > 99 ? 99 : value.messageNotReadCount}",
                                          style: TextStyle(
                                            color: AppThemeUtils.getColorByKey(
                                                context,
                                                AppThemeKeys.mainWhiteColor.name),
                                            fontSize: ScreenUtil().setSp(14),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              )),
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          Scaffold.of(context).closeDrawer();
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                _userAccount(),
                Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      children: [
                        _menuItem(
                            "assets/home/profile.png", S.of(context).g_home_key1,
                            onTap: () async{
                              if (Application.userInfo !=null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const PersonalSetting(),
                                  ),
                                );
                              }else{
                                final flag = await TipsDialog6(context, title:S.of(context).login_need_login,);
                                if (flag != null && flag) {
                                  await Navigator.pushNamed(context, "/LoginPage",);
                                  Navigator.popUntil(context, ModalRoute.withName("/"));
                                }
                              }
                            }),
                        _menuItem(
                            "assets/home/manage_wallet.png", S.of(context).s_key_1,
                            onTap: () async{
                              ///wallet manage
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const WalletList()));
                            }),
                        _menuItem(
                            "assets/home/address_book.png", S.of(context).g_key_108,
                            onTap: () async{
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AddressBookList()));
                            }),
                        _menuItem("assets/home/security.png", S.of(context).s_key_11,
                            onTap: () async{
                              if(Application.userInfo ==null){
                                final flag = await TipsDialog6(context, title:S.of(context).login_need_login,);
                                if (flag != null && flag) {
                                  await Navigator.pushNamed(context, "/LoginPage",);
                                  Navigator.popUntil(context, ModalRoute.withName("/"));
                                }
                              }else{
                                Navigator.pushNamed(context, '/securitySetting');
                              }
                            }),
                        /*_menuItem("assets/face/portrait.png", S.of(context).g_face_match_key6,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => FaceBinding(1)));
                            }),*/
                        /*_menuItem(
                      "assets/setting/nav_img_12.png", S.of(context).g_identity_key1,
                      onTap: () {
                        if (ProviderUtil.publicProvider().isLogin == false) {
                          ToastUtils.show(S.of(context).login_need_login);
                          return;
                        }

                        if (!ProviderUtil.walletActionProvider().existWallet) {
                          ToastUtils.show("Please create a wallet first");
                          eventBus.fire(EventPublic(EventPublicType.selectTable,
                              intValue: 1));
                          return;
                        }
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => IdentityAuthenticationMain()));
                      }),*/
                        _menuItem(
                            "assets/home/tabbar/news.png", S.of(context).g_browser_key11,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return BrowserPage(AppConfig.apiUrl['walletamazeBrowser']);
                                  }));
                            }),
                        /*_menuItem(
                              "assets/home/Learn.png", S.of(context).g_home_key6,
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return BrowserPage('https://astrawallet.com/learn/');
                                    }));
                              }),*/
                        _menuItem("assets/home/settings.png", S.of(context).g_key_94,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingHomePage(),
                                ),
                              );
                            }),
                        _menuItem("assets/home/about_app.png", S.of(context).s_key_10,
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const AboutApp()));
                            }),
                        /*_menuItem("assets/home/about_app.png", "Face Matching",
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => FaceBinding(2)));
                      }),
                  _menuItem("assets/home/about_app.png", "Face Matching（Phone gallery）",
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => FaceMatch(1)));
                      }),
                  _menuItem("assets/face/portrait.png", "Face Matching（Camera）",
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => FaceMatch(2)));
                      }),*/
                        Divider(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.dividerColor.name),
                          endIndent: 0,
                          indent: 0,
                          height: ScreenUtil().setWidth(1),
                        ),
                        SizedBox(
                          height: ScreenUtil().setWidth(30.0),
                        ),
                        _menuItem(
                            "assets/home/logout.png",
                            Application.userInfo !=null
                                ? S.of(context).g_key_logout
                                : S.of(context).g_key_login, onTap: () async {
                          if (Application.userInfo !=null) {
                            final res = await TipsDialog2(
                                context, S.of(context).g_key_logout_sure);
                            if (res != null && res) {
                              try {
                                //退出登陆
                                await Application.logout();
                                Scaffold.of(context).closeDrawer();
                                //退出第3方登录
                                //await FireBaseUtils.signOut();
                                // Scaffold.of(context).closeDrawer();
                                //WebSocketUtils.instance.userLogOut();
                                //重置埋点数据
                                //AmplitudeUtils.logOut();

                                /*Navigator.pushAndRemoveUntil(
                                      Application.navigatorKey.currentContext!,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                          const GuidePage()),
                                          (route) => false);*/
                              } catch (err) {
                                debugPrint("logout err：${err.toString()}");
                              }
                            }
                          }
                          else {
                            //登录
                            Navigator.pushNamed(context, "/LoginPage");
                            Scaffold.of(context).closeDrawer();
                          }
                        }),
                      ],
                    ))
              ],
            ),
          ),
        ),);


  }

  _userAccount() {
    return Consumer(builder: (
        BuildContext context,
        PublicProvider value,
        Widget? child,
        ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: ScreenUtil().setWidth(30),
              ),
              Stack(
                children: [
                  Container(
                    width: ScreenUtil().setWidth(140.0),
                    height: ScreenUtil().setWidth(140.0),
                    //超出部分，可裁剪
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ScreenUtil().setWidth(70.0),
                      ),
                    ),
                    child: ImageNetWork(
                      imageUrl: value.userInfo?.image ?? '',
                      placeholder: "assets/img/person_def_1.png",
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Image.asset(
                      "assets/img/ast.png",
                      width: ScreenUtil().setWidth(36),
                      height: ScreenUtil().setWidth(36),
                    ),
                  )
                ],
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.userInfo?.name ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(30)),
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(12.0),
                    ),
                    Text(
                      value.userInfo?.email ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.ff888888.name),
                          fontSize: ScreenUtil().setSp(22)),
                    )
                  ],
                ),
              ),
            ],
          ),
          Divider(
            height: ScreenUtil().setWidth(60),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
            endIndent: 0,
            indent: 0,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if(Application.userInfo ==null){
                    final flag = await TipsDialog6(context, title:S.of(context).login_need_login,);
                    if (flag != null && flag) {
                      await Navigator.pushNamed(context, "/LoginPage",);
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    }else{
                      return;
                    }
                  }
                  /*String shareUrl = AppConfig.apiUrl['walletamazeBrowser']!;
              shareUrl += "download?uuid=${Application.userInfo!.uuid}";*/
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingShare(
                        //shareUri: shareUrl,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30),vertical: ScreenUtil().setWidth(20),),
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(30),),
                  decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainButtonBgColor.name),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30))),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/img/heart.png",
                        width: ScreenUtil().setWidth(24),
                        fit: BoxFit.cover,
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(12),
                      ),
                      Text(
                        S.of(context).g_home_key9,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
                          fontSize: ScreenUtil().setSp(26),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
            endIndent: 0,
            indent: ScreenUtil().setWidth(30),
            height: ScreenUtil().setWidth(60),
          ),
        ],
      );
    });
  }

  _menuItem(String iconPath, String actionName,
      {Widget? rightWidget, GestureTapCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  iconPath,
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setWidth(48),
                  fit: BoxFit.cover,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainBlueColor.name),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(40),
                ),
                Text(
                  actionName,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    // fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil().setSp(30.0),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
                if (rightWidget != null) rightWidget,
              ],
            ),
            SizedBox(
              height: ScreenUtil().setWidth(48.0),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
