import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'splash_variants.dart';

/// 启动页面
/// 
/// 显示应用 Logo 和加载动画，在后台完成初始化
class SplashPage extends StatefulWidget {
  final Future<void> Function()? onInit;
  final VoidCallback onComplete;

  const SplashPage({
    super.key,
    this.onInit,
    required this.onComplete,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
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
      // 确保动画至少播放 800ms（快速启动）
      final minDuration = Future.delayed(const Duration(milliseconds: 800));

      // 执行初始化
      if (widget.onInit != null) {
        if (mounted) {
          setState(() {
            _loadingText = 'Loading...';
          });
        }
        await widget.onInit!();
      }

      // 等待最小时间
      await minDuration;

      if (!mounted) return;

      setState(() {
        _loadingText = 'Ready';
        _isLoading = false;
      });

      // 短暂延迟后完成
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;
      widget.onComplete();
    } catch (e) {
      debugPrint('SplashPage: Initialize error: $e');
      // 即使出错也要完成启动
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
            colors: [
              Color(0xFF1A237E), // 深蓝色
              Color(0xFF0D1B2A), // 深色
            ],
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
                
                // Logo
                Container(
                  width: ScreenUtil().setWidth(200),
                  height: ScreenUtil().setWidth(200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3F7).withValues(alpha:0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 如果图片加载失败，显示文字 Logo
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(40)),
                          ),
                          child: Center(
                            child: Text(
                              'N42',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(60),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setWidth(40)),
                
                // 应用名称
                Text(
                  'N42 Wallet',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(48),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setWidth(20)),

                // 随机启动文字组（参考图样式）
                _SplashTagline(variant: _variant),
                
                const Spacer(flex: 2),
                
                // 加载指示器
                if (_isLoading) ...[
                  SizedBox(
                    width: ScreenUtil().setWidth(40),
                    height: ScreenUtil().setWidth(40),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(20)),
                ],
                
                // 加载文字
                Text(
                  _loadingText,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: Colors.white.withValues(alpha:0.6),
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setWidth(60)),
                
                // 版权信息
                Text(
                  '© 2021-2026 N42 Inc.',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Colors.white.withValues(alpha:0.4),
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setWidth(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 随机启动文字组件
// 布局参考设计稿：小标签 + 大主字 + 小标签 + 副标题（带字间距）
// ---------------------------------------------------------------------------

class _SplashTagline extends StatelessWidget {
  final SplashVariant variant;

  const _SplashTagline({required this.variant});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 上方小标签
        if (variant.topLabel != null) ...[
          Text(
            variant.topLabel!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(4)),
        ],

        // 主体大字
        Text(
          variant.mainText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(36),
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: variant.mainText == variant.mainText.toUpperCase()
                ? 2.0   // 全大写时加字间距（如 "OWNS"）
                : 0.5,
            height: 1.15,
          ),
        ),

        // 中间小标签（如 "Matters" / "Won't Forget"）
        if (variant.midLabel != null) ...[
          SizedBox(height: ScreenUtil().setWidth(4)),
          Text(
            variant.midLabel!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
        ],

        // 副标题（中/日/韩等表意文字加大字间距）
        if (variant.subText != null) ...[
          SizedBox(height: ScreenUtil().setWidth(10)),
          Text(
            variant.subText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: variant.subTextSpaced ? 4.0 : 0.5,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
