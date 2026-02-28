import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/wallet/pages/face_matching/face_user_notice.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/app_home_top_bar.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';

/// 钱包页顶部导航栏
///
/// 包含：钱包名称标题（可点击切换钱包）、二维码菜单、WalletConnect 按钮、面部识别按钮。
class WalletTopBar extends ConsumerWidget {
  const WalletTopBar({
    super.key,
    required this.walletName,
    required this.isWatchOnly,
    required this.onTitleTap,
    required this.onMenuTap,
    required this.onWalletConnectTap,
    required this.onScanTap,
    required this.onReceiveTap,
  });

  final String walletName;
  final bool isWatchOnly;
  final VoidCallback onTitleTap;
  final VoidCallback onMenuTap;
  final VoidCallback onWalletConnectTap;
  final VoidCallback onScanTap;
  final VoidCallback onReceiveTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppHomeTopBar(
      titleChild: _WalletTitleButton(
        walletName: walletName,
        isWatchOnly: isWatchOnly,
        onTap: onTitleTap,
      ),
      onLeftImageClick: onMenuTap,
      onLeftImageUri: "assets/img/menu.png",
      actions: [
        _QrCodeMenu(
          onScanTap: onScanTap,
          onReceiveTap: onReceiveTap,
        ),
        _WalletConnectButton(onTap: onWalletConnectTap),
        _FacePortraitButton(),
      ],
    );
  }
}

// ── 钱包名称标题按钮 ─────────────────────────────────────────────────────────

class _WalletTitleButton extends StatelessWidget {
  const _WalletTitleButton({
    required this.walletName,
    required this.isWatchOnly,
    required this.onTap,
  });

  final String walletName;
  final bool isWatchOnly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final blueColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);
    final su = ScreenUtil();
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: su.setWidth(60),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWatchOnly)
              Padding(
                padding: EdgeInsets.only(right: su.setWidth(6)),
                child: Icon(
                  Icons.visibility_outlined,
                  color: blueColor,
                  size: su.setWidth(28),
                ),
              ),
            Text(
              walletName,
              style: TextStyle(
                color: blueColor,
                fontSize: su.setSp(30),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: su.setWidth(40),
              width: su.setWidth(40),
              child: Icon(
                Icons.arrow_drop_down,
                color: blueColor,
                size: su.setWidth(40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 二维码下拉菜单 ──────────────────────────────────────────────────────────

class _QrCodeMenu extends StatelessWidget {
  const _QrCodeMenu({
    required this.onScanTap,
    required this.onReceiveTap,
  });

  final VoidCallback onScanTap;
  final VoidCallback onReceiveTap;

  @override
  Widget build(BuildContext context) {
    final su = ScreenUtil();
    return PopupMenuButton<int>(
      icon: Icon(
        Icons.qr_code_rounded,
        size: su.setWidth(52.0),
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.mainBlueColor.name),
      ),
      offset: Offset(0, su.setWidth(80)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(su.setWidth(16)),
      ),
      color: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.itemBgColor.name),
      onSelected: (value) => switch (value) {
        0 => onScanTap(),
        1 => onReceiveTap(),
        _ => null,
      },
      itemBuilder: (context) => [
        _buildMenuItem(context, value: 0, icon: Icons.qr_code_scanner, label: S.of(context).g_key_4),
        _buildMenuItem(context, value: 1, icon: Icons.qr_code, label: S.of(context).g_key_33),
      ],
    );
  }

  PopupMenuItem<int> _buildMenuItem(
    BuildContext context, {
    required int value,
    required IconData icon,
    required String label,
  }) {
    final textColor =
        AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: ScreenUtil().setWidth(40), color: textColor),
          SizedBox(width: ScreenUtil().setWidth(20)),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ],
      ),
    );
  }
}

// ── WalletConnect 按钮（含会话数 badge）────────────────────────────────────

class _WalletConnectButton extends ConsumerWidget {
  const _WalletConnectButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wc = ref.watch(wcpBridgeProvider);
    final sessionCount = wc.getActiveSessions().length;
    final isConnected = wc.walletConnectState != WalletConnectState.disconnect &&
        wc.dAppTopic != null &&
        wc.metadata != null;
    final iconUrl = wc.metadata?.icons.firstOrNull ?? "";

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: ScreenUtil().setWidth(60.0),
        height: ScreenUtil().setWidth(60.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: isConnected
                  ? ImageNetWork(
                      imageUrl: iconUrl,
                      placeholder: "assets/img/list_default.png",
                    )
                  : Image.asset(
                      "assets/wallet/WalletConnect.png",
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainBlueColor.name),
                    ),
            ),
            if (sessionCount > 0)
              Positioned(
                right: -ScreenUtil().setWidth(8),
                top: -ScreenUtil().setWidth(8),
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(6)),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: ScreenUtil().setWidth(28),
                    minHeight: ScreenUtil().setWidth(28),
                  ),
                  child: Text(
                    '$sessionCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(18),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 面部识别入口按钮 ─────────────────────────────────────────────────────────

class _FacePortraitButton extends StatelessWidget {
  const _FacePortraitButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FaceUserNotice()),
        );
      },
      child: Container(
        width: ScreenUtil().setWidth(40.0),
        height: ScreenUtil().setWidth(40.0),
        margin: EdgeInsets.only(left: ScreenUtil().setWidth(20.0)),
        child: Image.asset(
          "assets/face/portrait.png",
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainBlueColor.name),
        ),
      ),
    );
  }
}
