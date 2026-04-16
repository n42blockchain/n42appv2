import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// N42豆页面（类似微信豆）
class N42BeanPage extends StatefulWidget {
  const N42BeanPage({super.key});

  @override
  State<N42BeanPage> createState() => _N42BeanPageState();
}

class _N42BeanPageState extends State<N42BeanPage> {
  final int _beanCount = 0; // N42豆数量

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Column(
        children: [
          // 顶部绿色区域
          _buildTopSection(isDark),
          
          // 底部说明区域
          Expanded(
            child: _buildBottomSection(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(bool isDark) {
    final s = S.of(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2B5E3F),
            Color(0xFF3A7A52),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶部导航栏
            _buildAppBar(),

            // N42豆展示区域
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  // 豆子图标
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // N42豆文字
                  Text(
                    s?.profileN42BeanTitle ?? 'N42 Bean',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 豆数量
                  Text(
                    _beanCount > 0 ? '$_beanCount' : (s?.profileNoN42Bean ?? 'No N42 Bean'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
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

  Widget _buildAppBar() {
    final s = S.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          TextButton(
            onPressed: _showBeanDetail,
            child: Text(
              s?.profileN42BeanDetails ?? 'N42 Bean Details',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool isDark) {
    final s = S.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明标题
            Text(
              s?.profileN42BeanDescription ?? 'N42 Bean is a token used to redeem virtual items and services in N42. Currently available for:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // 功能列表
            _buildFeatureItem('· ${s?.profileN42BeanFeature1 ?? 'Exclusive member stickers and themes'}'),
            _buildFeatureItem('· ${s?.profileN42BeanFeature2 ?? 'Chat bubble customization'}'),
            _buildFeatureItem('· ${s?.profileN42BeanFeature3 ?? 'Red packet cover customization'}'),
            _buildFeatureItem('· ${s?.profileN42BeanFeature4 ?? 'Exclusive nickname badge'}'),
            _buildFeatureItem('· ${s?.profileN42BeanFeature5 ?? 'Group chat privileges'}'),
            _buildFeatureItem('· ${s?.profileN42BeanFeature6 ?? 'Cloud storage expansion'}'),
            _buildFeatureItem('· ${s?.profileN42BeanFeature7 ?? 'Video call beauty filters'}'),
            _buildFeatureItem('· ${s?.profileN42BeanFeature8 ?? 'Moments background customization'}'),
            _buildFeatureItem('· ${s?.profileN42BeanFeature9 ?? 'VIP customer service priority'}'),

            const SizedBox(height: 40),

            // 我知道了按钮
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.surfaceDark.withValues(alpha: 0.5)
                        : const Color(0xFFF5F5F5),
                    foregroundColor: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    s?.profileGotIt ?? 'Got it',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  void _showBeanDetail() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BeanDetailSheet(),
    );
  }
}

/// N42豆明细页面
class _BeanDetailSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final s = S.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  s?.profileN42BeanDetails ?? 'N42 Bean Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),

          // 空状态
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s?.profileNoN42BeanRecords ?? 'No N42 Bean records',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
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

