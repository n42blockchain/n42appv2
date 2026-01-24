import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/providers/core_providers.dart';
import 'package:n42appv2/src/browser/pages/browser_page.dart';
import 'package:n42appv2/src/home/setting/about_app.dart';
import 'package:n42appv2/src/home/setting/personal_setting.dart';
import 'package:n42appv2/src/home/setting/setting_home_page.dart';
import 'package:n42appv2/src/home/setting/setting_share.dart';
import 'package:n42appv2/src/notification/pages/message_list.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/wallet/pages/address_book/address_book_list.dart';
import 'package:n42appv2/src/wallet/pages/wallet_manage/wallet_list.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_2.dart';
import 'package:n42appv2/src/widgets/dialog_widget/tips_dialog_6.dart';
import 'package:n42appv2/src/widgets/image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/core/config/app_config.dart';

/// Home Drawer Page - Migrated to Riverpod
/// 
/// Uses ConsumerStatefulWidget for unread count notifications
class HomeDrawPage extends ConsumerStatefulWidget {
  const HomeDrawPage({super.key});

  @override
  ConsumerState<HomeDrawPage> createState() => _HomeDrawPageState();
}

class _HomeDrawPageState extends ConsumerState<HomeDrawPage> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Watch user state from Riverpod - triggers rebuild on login/logout
    final currentUser = ref.watch(currentUserProvider);
    
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(ScreenUtil().setWidth(24)),
          bottomRight: Radius.circular(ScreenUtil().setWidth(24)),
        ),
        child: Container(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部操作栏
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16),
                    vertical: ScreenUtil().setWidth(8),
                  ),
                  child: Row(
                    children: [
                      _buildNotificationButton(),
                      const Spacer(),
                      Container(
                        width: ScreenUtil().setWidth(44),
                        height: ScreenUtil().setWidth(44),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(22)),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Scaffold.of(context).closeDrawer();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: ScreenUtil().setWidth(24),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(16)),
                _userAccount(currentUser),
                SizedBox(height: ScreenUtil().setWidth(16)),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(20)),
                    children: [
                      // 账户管理分组
                      _sectionTitle(S.of(context).g_home_key1),
                      _menuItem(
                        "assets/home/profile.png",
                        S.of(context).g_home_key1,
                        onTap: () async {
                          if (AppGlobals.userInfo != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PersonalSetting()),
                            );
                          } else {
                            final loginNeededTitle = S.of(context).login_need_login;
                            final flag = await tipsDialog6(context, title: loginNeededTitle);
                            if (!context.mounted) return;
                            if (flag != null && flag) {
                              await Navigator.pushNamed(context, "/LoginPage");
                              if (!context.mounted) return;
                              Navigator.popUntil(context, ModalRoute.withName("/"));
                            }
                          }
                        },
                      ),
                      _menuItem(
                        "assets/home/manage_wallet.png", 
                        S.of(context).s_key_1,
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletList()));
                        },
                      ),
                      _menuItem(
                        "assets/home/address_book.png", 
                        S.of(context).g_key_108,
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddressBookList()));
                        },
                      ),
                      
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      // 安全与设置分组
                      _sectionTitle(S.of(context).g_key_94),
                      _menuItem(
                        "assets/home/security.png",
                        S.of(context).s_key_11,
                        onTap: () async {
                          if (AppGlobals.userInfo == null) {
                            final loginNeededTitle = S.of(context).login_need_login;
                            final flag = await tipsDialog6(context, title: loginNeededTitle);
                            if (!context.mounted) return;
                            if (flag != null && flag) {
                              await Navigator.pushNamed(context, "/LoginPage");
                              if (!context.mounted) return;
                              Navigator.popUntil(context, ModalRoute.withName("/"));
                            }
                          } else {
                            Navigator.pushNamed(context, '/securitySetting');
                          }
                        },
                      ),
                      _menuItem(
                        "assets/home/settings.png", 
                        S.of(context).g_key_94,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingHomePage()),
                          );
                        },
                      ),
                      
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      // 其他分组
                      _sectionTitle(S.of(context).s_key_10),
                      _menuItem(
                        "assets/home/tabbar/news.png", 
                        S.of(context).g_browser_key11,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return BrowserPage(AppConfig.apiUrl['walletamazeBrowser']);
                          }));
                        },
                      ),
                      _menuItem(
                        "assets/home/about_app.png", 
                        S.of(context).s_key_10,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutApp()));
                        },
                      ),
                      
                      SizedBox(height: ScreenUtil().setWidth(20)),
                      // 登录/退出按钮
                      _buildLoginLogoutButton(currentUser),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),);


  }

  Widget _userAccount(dynamic currentUser) {
    // 使用 Riverpod currentUser 响应登录状态变化
    final userInfo = AppGlobals.userInfo;
    final isLoggedIn = currentUser != null || userInfo != null;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.1),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 头像
              Container(
                width: ScreenUtil().setWidth(72),
                height: ScreenUtil().setWidth(72),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(36)),
                  /*border: Border.all(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    width: 2,
                  ),*/
                  boxShadow: [
                    BoxShadow(
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: ImageNetWork(
                  imageUrl: currentUser?.image ?? userInfo?.image ?? '',
                  placeholder: "assets/img/person_def_1.png",
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? (currentUser?.name ?? userInfo?.name ?? '-') : S.of(context).g_key_login,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        fontWeight: FontWeight.w600,
                        fontSize: ScreenUtil().setSp(32),
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (isLoggedIn) ...[
                      SizedBox(height: ScreenUtil().setWidth(6)),
                      Text(
                        currentUser?.email ?? userInfo?.email ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                          fontSize: ScreenUtil().setSp(24),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          // 分享按钮
          GestureDetector(
            onTap: () async {
              if (AppGlobals.userInfo == null) {
                final loginNeededTitle = S.of(context).login_need_login;
                final flag = await tipsDialog6(context, title: loginNeededTitle);
                if (!mounted) return;
                if (flag != null && flag) {
                  await Navigator.pushNamed(context, "/LoginPage");
                  if (!mounted) return;
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                }
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingShare()),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
                vertical: ScreenUtil().setWidth(12),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.share_rounded,
                    size: ScreenUtil().setWidth(20),
                    color: Colors.white,
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    S.of(context).g_home_key9,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w500,
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

  Widget _menuItem(String iconPath, String actionName,
      {Widget? rightWidget, GestureTapCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(16),
            vertical: ScreenUtil().setWidth(4),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(16),
            vertical: ScreenUtil().setWidth(16),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          ),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: ScreenUtil().setWidth(44),
                height: ScreenUtil().setWidth(44),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  iconPath,
                  width: ScreenUtil().setWidth(24),
                  height: ScreenUtil().setWidth(24),
                  fit: BoxFit.contain,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              // 文字
              Expanded(
                child: Text(
                  actionName,
                  style: TextStyle(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // 右侧箭头
              if (rightWidget != null) 
                rightWidget
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: ScreenUtil().setWidth(24),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Notification button with unread count badge
  Widget _buildNotificationButton() {
    // Watch unread count from Riverpod
    final messageNotReadCount = ref.watch(unreadCountProvider);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessageList()),
          );
        },
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(22)),
        child: Container(
          width: ScreenUtil().setWidth(44),
          height: ScreenUtil().setWidth(44),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(22)),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.notifications_outlined,
                  size: ScreenUtil().setWidth(24),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
              ),
              if (messageNotReadCount != 0)
                Positioned(
                  top: ScreenUtil().setWidth(4),
                  right: ScreenUtil().setWidth(4),
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: ScreenUtil().setWidth(18),
                      minHeight: ScreenUtil().setWidth(18),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(4)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${messageNotReadCount > 99 ? '99+' : messageNotReadCount}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(12),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
        style: TextStyle(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
          fontSize: ScreenUtil().setSp(20),
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// 登录/退出按钮
  Widget _buildLoginLogoutButton(dynamic currentUser) {
    final isLoggedIn = currentUser != null;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (isLoggedIn) {
              final res = await tipsDialog2(context, S.of(context).g_key_logout_sure);
              if (!mounted) return;
              if (res != null && res) {
                try {
                  await AppGlobals.logout();
                  if (!mounted) return;
                  Scaffold.of(context).closeDrawer();
                } catch (err) {
                  debugPrint("logout err：${err.toString()}");
                }
              }
            } else {
              Navigator.pushNamed(context, "/LoginPage");
              Scaffold.of(context).closeDrawer();
            }
          },
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: ScreenUtil().setWidth(16),
              horizontal: ScreenUtil().setWidth(20),
            ),
            decoration: BoxDecoration(
              color: isLoggedIn 
                  ? AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name).withValues(alpha:0.1)
                  : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              border: Border.all(
                color: isLoggedIn
                    ? AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name).withValues(alpha:0.3)
                    : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withValues(alpha:0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                  size: ScreenUtil().setWidth(24),
                  color: isLoggedIn
                      ? AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name)
                      : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Text(
                  isLoggedIn ? S.of(context).g_key_logout : S.of(context).g_key_login,
                  style: TextStyle(
                    color: isLoggedIn
                        ? AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name)
                        : AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
