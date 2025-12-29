import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/home/api/version_api.dart';
import 'package:n42appv2/src/home/models/version_info_model.dart';
import 'package:n42appv2/src/home/setting/feedback.dart' as fb;
import 'package:n42appv2/src/home/widgets/check_version_alert.dart';
import 'package:n42appv2/src/home/widgets/nav_setting_item.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/core/utils/toast_utils.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:n42appv2/generated/l10n.dart';

class AboutApp extends StatefulWidget {
  const AboutApp({super.key});

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  String? appVersion;
  int developerModeClickNum = 0;
  bool findNewVersion = false;
  VersionInfoModel? versionInfo;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });

    ///是否启用了检查更新
    if (AppConfig.isOpenAppUpdate) {
      checkAppLastVersion();
    }
  }

  ///检查更新
  checkAppLastVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionInfo = await VersionApi().getVersionInfo();
    if (versionInfo != null) {
      if (versionInfo!.versionCode! > int.parse(packageInfo.buildNumber)) {
        findNewVersion = true;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_10,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
        child: Column(
          children: [
            _buildVersion(),
            SizedBox(
              height: ScreenUtil().setWidth(20.0),
            ),
            _buildNavEnter1(),
            SizedBox(
              height: ScreenUtil().setWidth(30.0),
            ),
            _buildNavEnter2(),
            /*SizedBox(
              height: ScreenUtil().setWidth(30.0),
            ),
            _buildNavEnter3(),*/
            SizedBox(
              height: ScreenUtil().setWidth(30.0),
            ),
          ],
        ),
      ),
      ),
    );
  }

  _buildNavEnter1() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(10.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil().setWidth(16.0))),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
      child: Column(
        children: [
          NavSettingItem(
            path: "assets/home/about/w.png",
            action: S.of(context).g_key_m_9,
            callback: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage(AppConfig.apiUrl['walletamazeBrowser']!,);
                //return Browser(AppConfig.walletamazeBrowser, "Amaze Wallet");
              }));
            },
          ),
        ],
      ),
    );
  }

  _buildNavEnter2() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(10.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil().setWidth(16.0))),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
      child: Column(
        children: [
          NavSettingItem(
            path: "assets/home/about/twitter.png",
            action: S.of(context).g_key_m_11,
            callback: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                //https://www.facebook.com/astraWalletApp
                return BrowserPage( "https://x.com/N42Blockchain");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/telegram.png",
            action: S.of(context).g_key_m_16,
            callback: () {
              //https://twitter.com/astraWallet
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage( "https://t.me/N42Blockchain");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          // Discord
          NavSettingItem(
            path: "assets/home/about/discord.png",
            action: S.of(context).g_key_m_17,
            callback: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage( "https://discord.gg/yjDsEnDTdt");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/youtube.png",
            action: S.of(context).g_key_m_18,
            callback: () {
              // www.linkedin.com/in/nft-wallet
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                //https://www.linkedin.com/company/astrawallet
                return BrowserPage(
                    "https://www.youtube.com/@N42Blockchain");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/reddit.png",
            action: S.of(context).g_key_m_14,
            callback: () {
              // www.linkedin.com/in/nft-wallet
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                //https://www.linkedin.com/company/astrawallet
                return BrowserPage(
                    "https://www.reddit.com/r/N42Blockchain");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/ins.png",
            action: S.of(context).g_key_m_19,
            callback: () {
              // www.linkedin.com/in/nft-wallet
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                //https://www.linkedin.com/company/astrawallet
                return BrowserPage(
                    "https://www.instagram.com/n42blockchain");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/tiktok.png",
            action: "TikTok",
            callback: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage(
                    "https://www.tiktok.com/@n42blockchain");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/snapchat.png",
            action: "snapchat",
            callback: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage(
                    "https://www.snapchat.com/t/JMpRe83U");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/linkedin.png",
            action: "linkedin",
            callback: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage(
                    "https://www.linkedin.com/company/n42blockchain/about/");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/whatsapp.png",
            action: "whatsapp",
            callback: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage(
                    "https://whatsapp.com/channel/0029Var1z8S8KMqr4FVk1K0e");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/medium.png",
            action: "medium",
            callback: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage(
                    "https://medium.com/p/publications/create");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/line.png",
            action: "line",
            callback: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage(
                    "https://line.me/ti/p/d-KryNwume");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
          NavSettingItem(
            path: "assets/home/about/bsky.png",
            action: "bsky",
            callback: (){
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return BrowserPage(
                    "https://bsky.app/profile/n42blockchain.bsky.social");
              }));
            },
            imgColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          ),
        ],
      ),
    );
  }

  _buildNavEnter3() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(10.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil().setWidth(16.0))),
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),

      ),
      child: Column(
        children: [
          NavSettingItem(
            path: "assets/home/about/feedback.png",
            action: S.of(context).g_key_feedback,
            callback: () {
              if (AppGlobals.userInfo == null) {
                ToastUtils.show(S.of(context).g_key_feedback_9);
                return;
              }
              /*if (ProviderUtil.walletActionProvider().existWallet == false) {
                ToastUtils.show(S.of(context).g_key_feedback_10);
                return;
              }*/
              Navigator.push(context,MaterialPageRoute(builder: (context) {
                return fb.Feedback();
              }));
            },
          ),
        ],
      ),
    );
  }

  _buildVersion() {
    return Container(
      padding:
      EdgeInsets.only(top: ScreenUtil().setWidth(20.0), bottom: ScreenUtil().setWidth(40.0)),
      child: Row(
        children: [
        Image.asset(
          "assets/home/about/about_logo.png",
          width: ScreenUtil().setWidth(102.0),
          fit: BoxFit.cover,
        ),
          SizedBox(
            width: ScreenUtil().setWidth(16.0),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConfig.apiUrl['walletamazeBrowser'],
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(32.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name)),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(6.0),
              ),
              Text(
                "v ${appVersion ?? ""}",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(28.0),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.ff888888.name)),
              ),
              SizedBox(
                height: ScreenUtil().setWidth(6.0),
              ),
              buildNewVersion(context)
            ],
          )
        ],
      ),
    );
  }

  buildNewVersion(BuildContext context) {
    if (findNewVersion) {
      return GestureDetector(
        child: Row(
          children: [
            Text(
              "${S.of(context).g_key_v_k3}(v${versionInfo!.versionName})",
              style: TextStyle(color: Colors.blueAccent, fontSize: ScreenUtil().setSp(26)),
            ),
          ],
        ),
        onTap: () {
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return CheckVersionAlert(
                newVersion: versionInfo!.versionName ?? "",
                introduction: versionInfo!.updateContent ?? '',
                isForce: 0,
              );
            },
          );
        },
      );
    }
    return Text(
      S.of(context).g_key_v_k4,
      style: TextStyle(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.ff888888.name),
          fontSize: ScreenUtil().setSp(26)),
    );
  }
}
