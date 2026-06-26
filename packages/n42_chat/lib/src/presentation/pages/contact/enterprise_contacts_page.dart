import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../widgets/common/common_widgets.dart';

/// 企业联系人列表页面
class EnterpriseContactsPage extends StatelessWidget {
  const EnterpriseContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.contactEnterpriseContacts ?? 'Enterprise Contacts',
      ),
      body: Column(
        children: [
          Container(
            color: context.surfaceColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7),
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
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.contactNoEnterpriseContacts ?? 'No enterprise contacts',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context)?.contactEnterpriseContactsDesc ??
                        'Enterprise contacts will appear here',
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
