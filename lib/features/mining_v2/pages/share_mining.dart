import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/utils/event_bus.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

class ShareMining extends StatefulWidget {
  final int fromType;
  final int? astValue;
  final String? groupName;
  final String? groupId;

  const ShareMining(
      {super.key,
        this.fromType = 0,
        this.astValue,
        this.groupName,
        this.groupId});

  @override
  State<ShareMining> createState() => _ShareMiningState();
}

class _ShareMiningState extends State<ShareMining> with SingleTickerProviderStateMixin {
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
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: ScreenUtil().setWidth(40)),
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
                                          const Color(0xFFFFD700).withValues(alpha:0.2),
                                          const Color(0xFFFFA500).withValues(alpha:0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700).withValues(alpha:0.3),
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
                                        color: isDark ? Colors.white : AppThemeUtils.getColorByKey(
                                            context, AppThemeKeys.mainTextColor.name),
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
                                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                                fontSize: ScreenUtil().setSp(44),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: ScreenUtil().setWidth(30)),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(30),
                                vertical: ScreenUtil().setWidth(20),
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha:0.06)
                                    : Colors.black.withValues(alpha:0.03),
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                              ),
                              child: Text(
                                _generateTipsContent(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                                  height: 1.5,
                                  fontSize: ScreenUtil().setSp(28),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: ScreenUtil().setWidth(60)),
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
                                  horizontal: ScreenUtil().setWidth(40),
                                  vertical: ScreenUtil().setWidth(20),
                                ),
                                decoration: BoxDecoration(
                                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
                                  border: Border.all(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.share_outlined,
                                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                                      size: ScreenUtil().setWidth(36),
                                    ),
                                    SizedBox(width: ScreenUtil().setWidth(12)),
                                    Flexible(
                                      child: Text(
                                        S.of(context).g_mining_key61,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
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
                      ? Colors.white.withValues(alpha:0.08)
                      : Colors.black.withValues(alpha:0.06),
                ),
                Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        eventBus.fire(EventPublic(EventPublicType.refreshMiningData));
                        eventBus.fire(EventPublic(EventPublicType.selectMiningplansPop));
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                        ),
                      ),
                      child: Text(
                        S.of(context).g_mining_key62,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
