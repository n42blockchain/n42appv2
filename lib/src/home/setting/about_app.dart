import 'package:n42appv2/core/config/app_config.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/home/api/version_api.dart';
import 'package:n42appv2/src/home/models/version_info_model.dart';
import 'package:n42appv2/src/home/widgets/check_version_alert.dart';
import 'package:n42appv2/src/home/widgets/nav_setting_item.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
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
    _initData();
  }

  Future<void> _initData() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });

    if (AppConfig.isOpenAppUpdate) {
      _checkAppLastVersion(packageInfo);
    }
  }

  Future<void> _checkAppLastVersion(PackageInfo packageInfo) async {
    versionInfo = await VersionApi().getVersionInfo();
    if (versionInfo == null) return;

    final serverCode = versionInfo!.versionCode;
    final localCode = int.tryParse(packageInfo.buildNumber) ?? 0;
    if (serverCode != null && serverCode > localCode) {
      findNewVersion = true;
      if (mounted) setState(() {});
    }
  }

  void _openBrowser(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BrowserPage(url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).s_key_10,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
          child: Column(
            children: [
              _buildVersion(),
              SizedBox(height: ScreenUtil().setWidth(20.0)),
              _buildWebsiteSection(),
              SizedBox(height: ScreenUtil().setWidth(30.0)),
              _buildSocialSection(),
              SizedBox(height: ScreenUtil().setWidth(30.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavContainer({required List<Widget> children}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(10.0)),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(ScreenUtil().setWidth(16.0))),
        color:
            AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildWebsiteSection() {
    return _buildNavContainer(
      children: [
        NavSettingItem(
          path: "assets/home/about/w.png",
          action: S.of(context).g_key_m_9,
          callback: () =>
              _openBrowser(AppConfig.apiUrl['walletamazeBrowser']!),
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    return _buildNavContainer(
      children: [
        NavSettingItem(
          path: "assets/home/about/twitter.png",
          action: S.of(context).g_key_m_11,
          callback: () => _openBrowser("https://x.com/N42Blockchain"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/telegram.png",
          action: S.of(context).g_key_m_16,
          callback: () => _openBrowser("https://t.me/N42Blockchain"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/discord.png",
          action: S.of(context).g_key_m_17,
          callback: () => _openBrowser("https://discord.gg/yjDsEnDTdt"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/youtube.png",
          action: S.of(context).g_key_m_18,
          callback: () =>
              _openBrowser("https://www.youtube.com/@N42Blockchain"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/reddit.png",
          action: S.of(context).g_key_m_14,
          callback: () =>
              _openBrowser("https://www.reddit.com/r/N42Blockchain"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/ins.png",
          action: S.of(context).g_key_m_19,
          callback: () =>
              _openBrowser("https://www.instagram.com/n42blockchain"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/tiktok.png",
          action: "TikTok",
          callback: () =>
              _openBrowser("https://www.tiktok.com/@n42blockchain"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/snapchat.png",
          action: "snapchat",
          callback: () =>
              _openBrowser("https://www.snapchat.com/t/JMpRe83U"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/linkedin.png",
          action: "linkedin",
          callback: () => _openBrowser(
              "https://www.linkedin.com/company/n42blockchain/about/"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/whatsapp.png",
          action: "whatsapp",
          callback: () => _openBrowser(
              "https://whatsapp.com/channel/0029Var1z8S8KMqr4FVk1K0e"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/medium.png",
          action: "medium",
          callback: () =>
              _openBrowser("https://medium.com/p/publications/create"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/line.png",
          action: "line",
          callback: () => _openBrowser("https://line.me/ti/p/d-KryNwume"),
          imgColor: blueColor,
        ),
        NavSettingItem(
          path: "assets/home/about/bsky.png",
          action: "bsky",
          callback: () => _openBrowser(
              "https://bsky.app/profile/n42blockchain.bsky.social"),
          imgColor: blueColor,
        ),
      ],
    );
  }

  Widget _buildVersion() {
    return Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0),
        bottom: ScreenUtil().setWidth(40.0),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/home/about/about_logo.png",
            width: ScreenUtil().setWidth(102.0),
            fit: BoxFit.cover,
          ),
          SizedBox(width: ScreenUtil().setWidth(16.0)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConfig.apiUrl['walletamazeBrowser'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(6.0)),
              Text(
                "v ${appVersion ?? ""}",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28.0),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.ff888888.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(6.0)),
              _buildNewVersionIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewVersionIndicator() {
    if (!findNewVersion) {
      return Text(
        S.of(context).g_key_v_k4,
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.ff888888.name),
          fontSize: ScreenUtil().setSp(26),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => CheckVersionAlert(
            newVersion: versionInfo!.versionName ?? "",
            updateTitle: versionInfo!.updateTitle ?? '',
            introduction: versionInfo!.updateContent ?? '',
            isForce: versionInfo!.isForce == true ? 1 : 0,
            downloadUrl: versionInfo!.downloadUrl,
          ),
        );
      },
      child: Row(
        children: [
          Text(
            "${S.of(context).g_key_v_k3}(v${versionInfo!.versionName})",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: ScreenUtil().setSp(26),
            ),
          ),
        ],
      ),
    );
  }
}
