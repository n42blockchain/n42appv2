import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/home/widgets/share_list.dart';
import 'package:n42_wallet/features/login/api/user_info_api.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/core/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/button_widget.dart';
import 'package:n42_wallet/features/widgets/prompt_widget.dart';
import 'package:n42_wallet/features/widgets/sheet_bottom.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class SettingShare extends StatefulWidget {
  const SettingShare({super.key});

  @override
  State<SettingShare> createState() => _SettingShareState();
}

class _SettingShareState extends State<SettingShare> {
  final GlobalKey previewContainer = GlobalKey();

  String linkStr = "";
  int inviteeTotalDown = 0;
  int inviteeTotal = 0;
  int miningTotal = 0;
  double rewardTotal = 0;
  UserInfoApi? _loginApi;

  UserInfoApi get loginApi {
    _loginApi ??= UserInfoApi();
    return _loginApi!;
  }

  String? get _uuid => AppGlobals.userInfo?.uuid;

  @override
  void initState() {
    super.initState();
    linkStr =
        '${AppConfig.apiUrl['walletamazeBrowser']!}/download?uuid=${_uuid ?? ""}&code=${AppGlobals.userInfo?.inviteCode ?? ""}';
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    if (_uuid == null) return;
    await Future.wait([
      _loadInviteeDownloadCount(),
      _loadInviteeCount(),
      _loadMiningCount(),
      _loadMiningReward(),
    ]);
  }

  Future<void> _loadMiningReward() async {
    final data = await loginApi.getInviteeMiningInfo(_uuid ?? '');
    if (data != null) {
      rewardTotal = double.parse((data['total_reward'] ?? "0.0").toString());
      setState(() {});
    }
  }

  Future<void> _loadMiningCount() async {
    final data = await loginApi.getInviteeMiningCount(_uuid ?? '');
    if (data != null) {
      miningTotal = int.parse((data['total'] ?? 0).toString());
      setState(() {});
    }
  }

  Future<void> _loadInviteeDownloadCount() async {
    final data = await loginApi.getInviteeDownloadList(_uuid ?? '');
    if (data != null) {
      inviteeTotalDown = int.parse(data['total'].toString());
      setState(() {});
    }
  }

  Future<void> _loadInviteeCount() async {
    final data = await loginApi.getInviteeList(_uuid ?? '');
    if (data != null) {
      inviteeTotal = int.parse(data['total'].toString());
      setState(() {});
    }
  }

  /// 截图并分享（内存直接分享）
  Future<void> _shareScreenshot() async {
    try {
      RenderRepaintBoundary boundary = previewContainer.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              pngBytes,
              name: "invite.png",
              mimeType: "image/png",
            ),
          ],
          text:
              "${S.of(context).g_share_v3_key_3} ${S.of(context).g_share_v3_key_4} 25 ${S.of(context).g_share_v3_key_5}",
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      debugPrint("分享截图失败: $e");
    }
  }

  void _share() {
    sheetBottom(
      context,
      "",
      ShareList(callBack: (int shareType) {
        if (shareType == 0) {
          _shareScreenshot();
        } else {
          SharePlus.instance.share(
            ShareParams(
              text:
                  "${S.of(context).g_share_v3_key_3} ${S.of(context).g_share_v3_key_4} 25 ${S.of(context).g_share_v3_key_5} ${S.of(context).g_share_v3_key_7}: $linkStr",
              subject: AppConfig.apiUrl['walletamazeBrowser'],
            ),
          );
        }
      }),
    );
  }

  void _copyToClipboard(String text) {
    ToastUtils.init(context);
    Clipboard.setData(ClipboardData(text: text));
    ToastUtils.showFtToast(
      child: successViewV1(S.of(context).copy),
      duration: 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: ScreenUtil().setWidth(100.0),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).g_share_v3_key_2,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(44.0),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                    ),
                    _buildStatsRow(context),
                    _buildShareContent(),
                    SizedBox(height: ScreenUtil().setWidth(148.0)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 0,
              height: ScreenUtil().setWidth(100.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Divider(height: ScreenUtil().setWidth(1)),
                  Container(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
                    height: ScreenUtil().setWidth(148.0),
                    child: buttonStyle2(
                      context,
                      _share,
                      S.of(context).g_share_v2_key_5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30.0),
        vertical: ScreenUtil().setWidth(12.0),
      ),
      padding: EdgeInsets.symmetric(
        vertical: ScreenUtil().setWidth(24.0),
        horizontal: ScreenUtil().setWidth(8.0),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
      ),
      child: Row(
        children: [
          _buildStatsCell(context, S.of(context).g_referral_invited,
              inviteeTotal.toString()),
          _buildStatsCell(context, S.of(context).g_referral_downloaded,
              inviteeTotalDown.toString()),
          _buildStatsCell(context, S.of(context).g_referral_mining,
              miningTotal.toString()),
          _buildStatsCell(context, S.of(context).g_referral_reward,
              rewardTotal.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Widget _buildStatsCell(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(36.0),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(4.0)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableRow(String label, String value) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30.0)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(30.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16.0)),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26.0),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemTextColor.name),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26.0),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemTextColor.name),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16.0)),
          InkWell(
            onTap: () => _copyToClipboard(value),
            child: Icon(
              Icons.copy,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              size: ScreenUtil().setWidth(32.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareContent() {
    return RepaintBoundary(
      key: previewContainer,
      child: Container(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.backGroundColor.name),
        child: Column(
          children: [
            SizedBox(height: ScreenUtil().setWidth(30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/ast.png",
                  width: ScreenUtil().setWidth(60),
                  height: ScreenUtil().setWidth(60),
                ),
                SizedBox(width: ScreenUtil().setWidth(20)),
                Text(
                  AppConfig.apiUrl['walletamazeBrowser'],
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(40.0),
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(30.0),
                vertical: ScreenUtil().setWidth(30.0),
              ),
              child: Text(
                S.of(context).g_share_v3_key_6,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30.0),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ),
            _buildCopyableRow(S.of(context).g_share_v3_key_7, linkStr),
            SizedBox(height: ScreenUtil().setWidth(30.0)),
            _buildCopyableRow(
              S.of(context).g_share_v3_key_8,
              AppGlobals.userInfo?.inviteCode ?? "",
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(70)),
              alignment: Alignment.center,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemLineColor.name),
                  ),
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(40.0)),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainWhiteColor.name),
                ),
                clipBehavior: Clip.hardEdge,
                child: QrImageView(
                  padding: const EdgeInsets.all(20.0),
                  backgroundColor: Colors.white,
                  data: linkStr,
                  version: QrVersions.min + 7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
