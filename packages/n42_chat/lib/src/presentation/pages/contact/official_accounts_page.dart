import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/common_widgets.dart';

/// 公众号列表页面
class OfficialAccountsPage extends StatelessWidget {
  const OfficialAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.contactOfficialAccounts ?? 'Official Accounts',
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            color: context.surfaceColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.inputBgOf(isDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 20,
                      color: context.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    S.of(context)?.commonSearch ?? 'Search',
                    style: TextStyle(
                      fontSize: 15,
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 空状态
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.contactNoOfficialAccounts ?? 'No official accounts',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context)?.contactFollowOfficialAccountsDesc ??
                        'Follow official accounts to receive updates',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
