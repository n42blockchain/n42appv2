import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/config/app_config.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/home/setting/about_app.dart';
import 'package:n42_wallet/features/home/setting/setting_home_page.dart';
import 'package:n42_wallet/features/profile/pages/profile_home_page.dart';
import 'package:n42_wallet/features/wallet/pages/address_book/address_book_list.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42_wallet/features/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42_wallet/features/widgets/image_network.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

part 'home_draw_page_widgets.dart';

/// Home Drawer Page - Migrated to Riverpod
///
/// Uses ConsumerStatefulWidget for unread count notifications
class HomeDrawPage extends ConsumerStatefulWidget {
  const HomeDrawPage({super.key});

  @override
  ConsumerState<HomeDrawPage> createState() => _HomeDrawPageState();
}

class _HomeDrawPageState extends ConsumerState<HomeDrawPage>
    with AutomaticKeepAliveClientMixin {
  /// Chat 用户信息（从流中更新）
  dynamic _chatUser;
  StreamSubscription? _chatUserSubscription;

  @override
  void initState() {
    super.initState();
    _chatUserSubscription = N42Chat.userStream.listen((user) {
      if (mounted) setState(() => _chatUser = user);
    });
    _chatUser = N42Chat.currentUser;
  }

  @override
  void dispose() {
    _chatUserSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentUser = ref.watch(currentUserProvider);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(ScreenUtil().setWidth(24)),
        bottomRight: Radius.circular(ScreenUtil().setWidth(24)),
      ),
      child: Container(
        color: AppColorTokens.of(context).bgBase,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部操作栏
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space2,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    Container(
                      width: ScreenUtil().setWidth(44),
                      height: ScreenUtil().setWidth(44),
                      decoration: BoxDecoration(
                        color: AppColorTokens.of(context).bgSurface,
                        borderRadius: BorderRadius.circular(
                          ScreenUtil().setWidth(22),
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Scaffold.of(context).closeDrawer();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          size: ScreenUtil().setWidth(24),
                          color: AppColorTokens.of(context).textSubtitle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.space4),
              buildUserAccount(currentUser),
              SizedBox(height: AppSpacing.space4),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
                  children: [
                    // 账户管理分组
                    _sectionTitle(S.of(context).g_home_key1),
                    _menuItem(
                      "assets/home/profile.png",
                      S.of(context).g_home_key1,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileHomePage(),
                          ),
                        );
                      },
                    ),
                    _menuItem(
                      "assets/home/manage_wallet.png",
                      S.of(context).g_key_wallet_manage,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WalletList()),
                        );
                      },
                    ),
                    _menuItem(
                      "assets/home/address_book.png",
                      S.of(context).g_key_108,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddressBookList()),
                        );
                      },
                    ),

                    SizedBox(height: AppSpacing.space4),
                    // 安全与设置分组
                    _sectionTitle(S.of(context).g_key_94),
                    _menuItem(
                      "assets/home/security.png",
                      S.of(context).s_key_11,
                      onTap: () {
                        Navigator.pushNamed(context, '/securitySetting');
                      },
                    ),
                    _menuItem(
                      "assets/home/settings.png",
                      S.of(context).g_key_94,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingHomePage(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: AppSpacing.space4),
                    // 其他分组
                    _sectionTitle(S.of(context).s_key_10),
                    _menuItem(
                      "assets/home/tabbar/news.png",
                      S.of(context).g_browser_key11,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return BrowserPage(
                                AppConfig.apiUrl['n42Browser'],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _menuItem(
                      "assets/home/about_app.png",
                      S.of(context).s_key_10,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AboutApp()),
                        );
                      },
                    ),

                    SizedBox(height: AppSpacing.space4),
                    // 登录/退出按钮
                    buildLoginLogoutButton(currentUser),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    String iconPath,
    String actionName, {
    Widget? rightWidget,
    GestureTapCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brMd,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space4,
          ),
          decoration: BoxDecoration(borderRadius: AppRadius.brMd),
          child: Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: AppColorTokens.of(
                    context,
                  ).brand.withValues(alpha: 0.1),
                  borderRadius: AppRadius.brMd,
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  iconPath,
                  width: ScreenUtil().setWidth(24),
                  height: ScreenUtil().setWidth(24),
                  fit: BoxFit.contain,
                  color: AppColorTokens.of(context).brand,
                ),
              ),
              SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Text(
                  actionName,
                  style: AppTypography.body.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (rightWidget != null)
                rightWidget
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: ScreenUtil().setWidth(24),
                  color: AppColorTokens.of(context).textSubtitle,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 分组标题
  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(32),
        top: ScreenUtil().setWidth(8),
        bottom: ScreenUtil().setWidth(8),
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.captionSm.copyWith(
          color: AppColorTokens.of(context).textSubtitle,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
