import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:n42_wallet/core/utils/app_logger.dart';

import 'splash_variants.dart';

/// 启动页面
///
/// 显示应用 Logo 和加载动画，在后台完成初始化
class SplashPage extends StatefulWidget {
  final Future<void> Function()? onInit;
  final VoidCallback onComplete;

  const SplashPage({super.key, this.onInit, required this.onComplete});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;
  String _loadingText = 'Starting...';

  // 每次启动随机选一条文字变体
  final SplashVariant _variant = pickRandomVariant();

  @override
  void initState() {
    super.initState();

    // 设置动画 - 快速启动
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // 开始动画
    _animationController.forward();

    // 执行初始化
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final minDuration = Future.delayed(const Duration(milliseconds: 800));

      if (widget.onInit != null) {
        if (mounted) setState(() => _loadingText = 'Loading...');
        await widget.onInit!();
      }

      await minDuration;
      if (!mounted) return;

      setState(() {
        _loadingText = 'Ready';
        _isLoading = false;
      });

      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      widget.onComplete();
    } catch (e) {
      AppLogger.w('SplashPage', 'initialize error: $e');
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF101828)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                SizedBox(height: AppSpacing.space12),
                _buildTitle(),
                SizedBox(height: AppSpacing.space4),
                _SplashTagline(variant: _variant),
                const Spacer(flex: 2),
                _buildLoadingIndicator(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final logoRadius = BorderRadius.circular(ScreenUtil().setWidth(40));
    final logoSize = ScreenUtil().setWidth(200);

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: logoRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: logoRadius,
        child: Image.asset(
          'assets/logo/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7),
                borderRadius: logoRadius,
              ),
              child: Center(
                child: Text(
                  'N42',
                  style: AppTypography.displayLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'N42 Wallet',
      style: AppTypography.displayLg.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_isLoading) return const SizedBox.shrink();
    final indicatorSize = ScreenUtil().setWidth(40);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
          ),
        ),
        SizedBox(height: AppSpacing.space4),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _loadingText,
          style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.6)),
        ),
        SizedBox(height: AppSpacing.space16),
        Text(
          '\u00a9 2021-2026 N42 Inc.',
          style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.4)),
        ),
        SizedBox(height: AppSpacing.space12),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 随机启动文字组件（单语言，不混排）
// ---------------------------------------------------------------------------

class _SplashTagline extends StatelessWidget {
  final SplashVariant variant;

  const _SplashTagline({required this.variant});

  @override
  Widget build(BuildContext context) {
    final taglineStyle = AppTypography.titleLg.copyWith(
      fontWeight: FontWeight.w600,
      color: const Color(0xFF80DEEA),
      letterSpacing: 1.0,
    );

    final labelSpans = <InlineSpan>[
      if (variant.topLabel != null)
        TextSpan(text: '${variant.topLabel} ', style: taglineStyle),
      TextSpan(text: variant.mainText, style: taglineStyle),
      if (variant.midLabel != null)
        TextSpan(text: ' ${variant.midLabel}', style: taglineStyle),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.space12),
      child: Text.rich(
        TextSpan(children: labelSpans),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}
