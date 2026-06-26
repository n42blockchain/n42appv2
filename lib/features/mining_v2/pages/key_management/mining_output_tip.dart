import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/features/mining_v2/pages/key_management/mining_output_pk.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

class MiningOutputTip extends StatelessWidget {
  final Map<String, dynamic>? value;
  const MiningOutputTip({this.value, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        appBar: AppBarWidget(text: S.of(context).g_mining_key_89),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: ScreenUtil().setWidth(120),
                  height: ScreenUtil().setWidth(120),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColorTokens.of(
                          context,
                        ).warning.withValues(alpha: 0.2),
                        AppColorTokens.of(
                          context,
                        ).warning.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shield_outlined,
                      size: ScreenUtil().setWidth(56),
                      color: AppColorTokens.of(context).warning,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.space12),
              Text(
                S.of(context).g_mining_key_90,
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColorTokens.of(context).textPrimary,
                  height: 1.3,
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(36)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.space6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : AppColorTokens.of(
                          context,
                        ).textTertiary.withValues(alpha: 0.04),
                  borderRadius: AppRadius.brMd,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTipItem(
                      context,
                      Icons.key,
                      S.of(context).g_mining_key_91,
                      const Color(0xFF5C6BC0),
                    ),
                    SizedBox(height: AppSpacing.space4),
                    _buildTipItem(
                      context,
                      Icons.folder_special_outlined,
                      S.of(context).g_mining_key_92,
                      const Color(0xFF26A69A),
                    ),
                    SizedBox(height: AppSpacing.space4),
                    _buildTipItem(
                      context,
                      Icons.no_photography_outlined,
                      S.of(context).g_mining_key_93,
                      const Color(0xFFFF7043),
                    ),
                    SizedBox(height: AppSpacing.space4),
                    _buildTipItem(
                      context,
                      Icons.warning_amber_rounded,
                      S.of(context).g_mining_key_94,
                      AppColorTokens.of(context).danger,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: EdgeInsets.all(AppSpacing.space8),
            child: AppButton(
              label: S.of(context).g_mining_key_95,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MiningOutputPk(value: value),
                  ),
                );
                if (context.mounted) {
                  Navigator.of(context).pop(result);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: ScreenUtil().setWidth(44),
          height: ScreenUtil().setWidth(44),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.brSm,
          ),
          child: Center(
            child: Icon(icon, size: ScreenUtil().setWidth(24), color: color),
          ),
        ),
        SizedBox(width: AppSpacing.space4),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body.copyWith(
              height: 1.5,
              color: AppColorTokens.of(context).textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
