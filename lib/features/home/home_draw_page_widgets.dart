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
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorTokens.of(context).brand.withValues(alpha: 0.1),
            AppColorTokens.of(context).brand.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.brMd,
        border: Border.all(
          color: AppColorTokens.of(context).brand.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _openChat,
                  child: Container(
                    width: ScreenUtil().setWidth(88),
                    height: ScreenUtil().setWidth(88),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ScreenUtil().setWidth(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColorTokens.of(
                            context,
                          ).brand.withValues(alpha: 0.2),
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
              ),
              SizedBox(width: AppSpacing.space4),
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
                              style: AppTypography.headline.copyWith(
                                color: AppColorTokens.of(context).textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (isChatOnlySession) ...[
                            SizedBox(width: AppSpacing.space2),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.space2,
                                vertical: AppSpacing.space2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColorTokens.of(
                                  context,
                                ).brand.withValues(alpha: 0.12),
                                borderRadius: AppRadius.brPill,
                              ),
                              child: Text(
                                S.of(context).g_key_squad,
                                style: AppTypography.captionSm.copyWith(
                                  color: AppColorTokens.of(context).brand,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isLoggedIn) ...[
                        SizedBox(height: AppSpacing.space2),
                        Text(
                          displayEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColorTokens.of(context).textSubtitle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space4),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openChat,
              borderRadius: AppRadius.brXl,
              child: Container(
                // >=88.w（44dp 触控红线，§2.1 按钮标准）
                constraints: BoxConstraints(
                  minHeight: ScreenUtil().setWidth(88),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
                decoration: BoxDecoration(
                  color: AppColorTokens.of(context).brand,
                  borderRadius: AppRadius.brXl,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      size: ScreenUtil().setWidth(20),
                      color: Colors.white,
                    ),
                    SizedBox(width: AppSpacing.space2),
                    Flexible(
                      child: Text(
                        S.of(context).g_home_key9,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
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
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.space6),
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
                  AppLogger.w('HomeDraw', 'logout err: $err');
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
          borderRadius: AppRadius.brMd,
          child: Container(
            constraints: BoxConstraints(minHeight: ScreenUtil().setWidth(88)),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: showWalletLogout
                  ? AppColorTokens.of(context).danger.withValues(alpha: 0.1)
                  : AppColorTokens.of(context).brand.withValues(alpha: 0.1),
              borderRadius: AppRadius.brMd,
              border: Border.all(
                color: showWalletLogout
                    ? AppColorTokens.of(context).danger.withValues(alpha: 0.3)
                    : AppColorTokens.of(context).brand.withValues(alpha: 0.3),
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
                      ? AppColorTokens.of(context).danger
                      : AppColorTokens.of(context).brand,
                ),
                SizedBox(width: AppSpacing.space4),
                Flexible(
                  child: Text(
                    showWalletLogout
                        ? S.of(context).g_key_logout
                        : showChatEntry
                        ? S.of(context).g_key_squad
                        : S.of(context).g_key_login,
                    style: AppTypography.bodyStrong.copyWith(
                      color: showWalletLogout
                          ? AppColorTokens.of(context).danger
                          : AppColorTokens.of(context).brand,
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
