part of 'home_draw_page.dart';

// ── Drawer widget components ─────────────────────────────────────────────────

extension on _HomeDrawPageState {
  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => N42Chat.chatWidget()),
    );
  }

  Widget buildUserAccount(dynamic currentUser) {
    final chatUser = _chatUser ?? N42Chat.currentUser;
    final userInfo = AppGlobals.userInfo;
    final isChatLoggedIn = N42Chat.isLoggedIn;
    final isWalletLoggedIn = currentUser != null || userInfo != null;
    final isChatOnlySession = isChatLoggedIn && !isWalletLoggedIn;

    final displayName =
        chatUser?.displayName ?? currentUser?.name ?? userInfo?.name;
    final displayAvatar =
        chatUser?.avatarUrl ?? currentUser?.image ?? userInfo?.image ?? '';
    final displayEmail =
        chatUser?.userId ?? currentUser?.email ?? userInfo?.email ?? '';
    final isLoggedIn = isChatLoggedIn || isWalletLoggedIn;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ).withValues(alpha: 0.1),
            AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.mainBlueColor.name,
            ).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainBlueColor.name,
          ).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _openChat,
                child: Container(
                  width: ScreenUtil().setWidth(72),
                  height: ScreenUtil().setWidth(72),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ScreenUtil().setWidth(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: ImageNetWork(
                    imageUrl: displayAvatar,
                    placeholder: "assets/img/person_def_1.png",
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(16)),
              Expanded(
                child: GestureDetector(
                  onTap: _openChat,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isLoggedIn
                                  ? (displayName ?? '-')
                                  : S.of(context).g_key_login,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainTextColor.name,
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenUtil().setSp(32),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (isChatOnlySession) ...[
                            SizedBox(width: ScreenUtil().setWidth(8)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(10),
                                vertical: ScreenUtil().setWidth(4),
                              ),
                              decoration: BoxDecoration(
                                color: AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainBlueColor.name,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(999),
                                ),
                              ),
                              child: Text(
                                S.of(context).g_key_squad,
                                style: TextStyle(
                                  color: AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.mainBlueColor.name,
                                  ),
                                  fontSize: ScreenUtil().setSp(18),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isLoggedIn) ...[
                        SizedBox(height: ScreenUtil().setWidth(6)),
                        Text(
                          displayEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name,
                            ),
                            fontSize: ScreenUtil().setSp(24),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          GestureDetector(
            onTap: _openChat,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20),
                vertical: ScreenUtil().setWidth(12),
              ),
              decoration: BoxDecoration(
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainBlueColor.name,
                ),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_add_rounded,
                    size: ScreenUtil().setWidth(20),
                    color: Colors.white,
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Flexible(
                    child: Text(
                      S.of(context).g_home_key9,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(24),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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

  /// 登录/退出按钮 - 使用 Chat 插件登录状态
  Widget buildLoginLogoutButton(dynamic currentUser) {
    final isChatLoggedIn = N42Chat.isLoggedIn;
    final isWalletLoggedIn = currentUser != null || AppGlobals.userInfo != null;
    final showWalletLogout = isWalletLoggedIn;
    final showChatEntry = !showWalletLogout && isChatLoggedIn;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (showWalletLogout) {
              final res = await tipsDialog2(
                context,
                S.of(context).g_key_logout_sure,
              );
              if (!mounted) return;
              if (res != null && res) {
                try {
                  await AppGlobals.logout();
                  if (!mounted) return;
                  Scaffold.of(context).closeDrawer();
                } catch (err) {
                  debugPrint("logout err: ${err.toString()}");
                }
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => N42Chat.chatWidget()),
              );
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
              color: showWalletLogout
                  ? AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.errorTextColor.name,
                    ).withValues(alpha: 0.1)
                  : AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              border: Border.all(
                color: showWalletLogout
                    ? AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.errorTextColor.name,
                      ).withValues(alpha: 0.3)
                    : AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showWalletLogout ? Icons.logout_rounded : Icons.chat_rounded,
                  size: ScreenUtil().setWidth(24),
                  color: showWalletLogout
                      ? AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.errorTextColor.name,
                        )
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),
                Flexible(
                  child: Text(
                    showWalletLogout
                        ? S.of(context).g_key_logout
                        : showChatEntry
                        ? S.of(context).g_key_squad
                        : S.of(context).g_key_login,
                    style: TextStyle(
                      color: showWalletLogout
                          ? AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.errorTextColor.name,
                            )
                          : AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainBlueColor.name,
                            ),
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
