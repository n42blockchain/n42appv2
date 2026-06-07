import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class ShareMining extends StatefulWidget {
  final int fromType;
  final int? astValue;
  final String? groupName;
  final String? groupId;

  const ShareMining({
    super.key,
    this.fromType = 0,
    this.astValue,
    this.groupName,
    this.groupId,
  });

  @override
  State<ShareMining> createState() => _ShareMiningState();
}

class _ShareMiningState extends State<ShareMining>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _generateTipsContent() {
    if (widget.fromType == 0 || widget.fromType == 1) {
      return S.of(context).g_mining_key60;
    }
    final topS = switch (widget.astValue) {
      50 => S.of(context).g_mining_key_67,
      100 => S.of(context).g_mining_key_66,
      _ => S.of(context).g_mining_key_68,
    };
    return S.of(context).g_mining_key63(topS);
  }

  String generateShareText() {
    if (widget.fromType == 0 || widget.fromType == 1) {
      final shareUrl =
          "${AppConfig.apiUrl['n42Browser']}?type=group_mining&id=${widget.groupId}";
      return "${S.of(context).g_mining_key73(widget.groupName ?? '')} $shareUrl";
    }
    final shareUrl = "${AppConfig.apiUrl['n42Browser']}?type=full_node";
    return "${S.of(context).g_mining_key74} $shareUrl";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space12,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: AppSpacing.space12),
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    width: ScreenUtil().setWidth(200),
                                    height: ScreenUtil().setWidth(200),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFFFFD700,
                                          ).withValues(alpha: 0.2),
                                          const Color(
                                            0xFFFFA500,
                                          ).withValues(alpha: 0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFFFD700,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        "assets/mining/medal_star.png",
                                        width: ScreenUtil().setWidth(120),
                                        fit: BoxFit.contain,
                                        color: isDark
                                            ? Colors.white
                                            : AppColorTokens.of(
                                                context,
                                              ).textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: ScreenUtil().setWidth(50)),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              "Congratulations!",
                              style: TextStyle(
                                color: AppColorTokens.of(context).textPrimary,
                                fontSize: ScreenUtil().setSp(44),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.space8),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.space8,
                                vertical: AppSpacing.space4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: AppRadius.brMd,
                              ),
                              child: Text(
                                _generateTipsContent(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColorTokens.of(
                                    context,
                                  ).textSubtitle,
                                  height: 1.5,
                                  fontSize: ScreenUtil().setSp(28),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.space16),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: GestureDetector(
                              onTap: () {
                                SharePlus.instance.share(
                                  ShareParams(
                                    text: generateShareText(),
                                    subject: AppConfig.apiUrl['n42Browser'],
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.space12,
                                  vertical: AppSpacing.space4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorTokens.of(
                                    context,
                                  ).brand.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.brXl,
                                  border: Border.all(
                                    color: AppColorTokens.of(
                                      context,
                                    ).brand.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.share_outlined,
                                      color: AppColorTokens.of(context).brand,
                                      size: ScreenUtil().setWidth(36),
                                    ),
                                    SizedBox(width: AppSpacing.space4),
                                    Flexible(
                                      child: Text(
                                        S.of(context).g_mining_key61,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColorTokens.of(
                                            context,
                                          ).brand,
                                          fontSize: ScreenUtil().setSp(28),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.space8),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: S.of(context).g_mining_key62,
                      onPressed: () {
                        eventBus.fire(
                          EventPublic(EventPublicType.refreshMiningData),
                        );
                        eventBus.fire(
                          EventPublic(EventPublicType.selectMiningplansPop),
                        );
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
