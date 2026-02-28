// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/import/import_cloud_backup.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/add_watch_wallet_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/import_keystore.dart';

class CreateWalletButton extends StatefulWidget {
  final dynamic onTapBack;
  const CreateWalletButton({this.onTapBack, super.key});

  @override
  State<CreateWalletButton> createState() => _CreateWalletButtonState();
}

class _CreateWalletButtonState extends State<CreateWalletButton> {
  /// 导航到目标页面，返回后关闭当前页并回调
  Future<void> _navigateAndCallback(Future<dynamic> navigation) async {
    final result = await navigation;
    if (!mounted) return;
    Navigator.of(context).pop();
    // 观察钱包页面返回 bool，只在 true 时回调
    if (result is bool && !result) return;
    widget.onTapBack?.call();
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name);
    final mainText = AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name);
    final subtitleText = AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name);
    final dividerColor = AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name);
    final s = S.of(context);

    final fullDivider = Divider(
      height: ScreenUtil().setWidth(1),
      indent: 0,
      endIndent: 0,
      color: dividerColor,
    );
    final indentedDivider = Divider(
      height: ScreenUtil().setWidth(1),
      indent: ScreenUtil().setWidth(30),
      endIndent: ScreenUtil().setWidth(30),
      color: dividerColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Container(
          height: ScreenUtil().setWidth(80),
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: Text(
            s.g_key_wallet_c32,
            style: TextStyle(
              color: mainText,
              fontSize: ScreenUtil().setSp(36.0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        fullDivider,

        // 创建钱包
        _buildMenuItem(
          icon: Icons.create_new_folder_outlined,
          title: s.g_key_7,
          subtitle: s.g_key_wallet_c33,
          blueColor: blueColor,
          subtitleColor: subtitleText,
          onTap: () => _navigateAndCallback(
            Navigator.pushNamed(context, '/CreateOne'),
          ),
        ),
        indentedDivider,

        // 导入助记词
        _buildMenuItem(
          icon: Icons.import_contacts,
          title: s.g_token_m_key_9,
          subtitle: s.w_key_8,
          blueColor: blueColor,
          subtitleColor: subtitleText,
          onTap: () => _navigateAndCallback(
            Navigator.pushNamed(context, '/ImportOne'),
          ),
        ),
        indentedDivider,

        // 导入 Keystore
        _buildMenuItem(
          icon: Icons.key,
          title: s.g_key_keystore_22,
          subtitle: s.g_key_ex_keystore_15,
          blueColor: blueColor,
          subtitleColor: subtitleText,
          onTap: () => _navigateAndCallback(
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ImportKeystore()),
            ),
          ),
        ),
        indentedDivider,

        // iCloud / Google Drive 加密备份导入
        _buildMenuItem(
          icon: Icons.cloud_download_outlined,
          title: 'Cloud Backup',
          subtitle: 'Import from iCloud / Google Drive',
          blueColor: blueColor,
          subtitleColor: subtitleText,
          onTap: () => _navigateAndCallback(
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ImportCloudBackup()),
            ),
          ),
        ),
        indentedDivider,

        // 观察钱包
        _buildMenuItem(
          icon: Icons.visibility_outlined,
          title: s.g_key_watch_wallet,
          subtitle: s.g_key_watch_wallet_desc,
          blueColor: blueColor,
          subtitleColor: subtitleText,
          onTap: () => _navigateAndCallback(
            Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const AddWatchWalletPage()),
            ),
          ),
        ),
        indentedDivider,

        // 导入私钥
        _buildMenuItem(
          icon: Icons.key,
          title: s.g_key_209,
          subtitle: s.g_key_209,
          blueColor: blueColor,
          subtitleColor: subtitleText,
          onTap: () => _navigateAndCallback(
            Navigator.pushNamed(context, '/ImportPrivatekey'),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color blueColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(30),
          vertical: ScreenUtil().setWidth(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: blueColor,
              size: ScreenUtil().setWidth(50),
            ),
            SizedBox(width: ScreenUtil().setWidth(20)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: blueColor,
                      fontSize: ScreenUtil().setSp(36),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: ScreenUtil().setSp(26),
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
}
