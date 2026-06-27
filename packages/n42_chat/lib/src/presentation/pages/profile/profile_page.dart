import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/encryption/e2ee_manager.dart';
import '../../../core/encryption/key_backup_service.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../domain/entities/avatar_decoration_preset.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../n42_chat.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../widgets/common/common_widgets.dart';
import '../favorite/favorite_list_page.dart';
import '../subscription/subscription_page.dart';
import '../fiat_ramp/fiat_ramp_page.dart';
import '../settings/local_llm_settings_page.dart';
import '../qrcode/my_qrcode_page.dart';
import '../settings/change_email_page.dart';
import '../settings/account_switch_page.dart';
import '../settings/appearance_settings_page.dart';
import '../settings/change_password_page.dart';
import '../settings/language_settings_page.dart';
import '../settings/notification_settings_page.dart';
import '../settings/privacy_settings_page.dart';
import '../settings/security_settings_page.dart';
import '../settings/settings_page.dart';
import 'avatar_studio_page.dart';
import 'orders_and_cards_page.dart';
import 'profile_edit_page.dart';
import 'services_page.dart';
import 'status_page.dart';
import '../moment/moment_list_page.dart';
import '../sticker/sticker_store_page.dart';
import '../../../core/utils/debug_log.dart';

/// 我的页面
class ProfilePage extends StatefulWidget {
  /// 是否显示 AppBar（嵌入到主框架时可设为 false）
  final bool showAppBar;

  const ProfilePage({super.key, this.showAppBar = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userId;
  String? _displayName;
  String? _avatarUrl;
  String? _statusText; // 当前状态
  String? _boundEmail;
  String? _boundPhoneNumber;
  bool _isNftAvatar = false; // 头像是否来自 NFT
  AvatarDecorationPreset _avatarDecorationPreset = AvatarDecorationPreset.none;
  StreamSubscription<UserEntity?>? _userSubscription;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _userSubscription = N42Chat.userStream.listen(_handleUserChanged);
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  void _handleUserChanged(UserEntity? user) {
    if (!mounted) return;
    if (user == null) {
      _loadVersion++;
      setState(() {
        _userId = null;
        _displayName = null;
        _avatarUrl = null;
        _statusText = null;
        _boundEmail = null;
        _boundPhoneNumber = null;
        _isNftAvatar = false;
        _avatarDecorationPreset = AvatarDecorationPreset.none;
      });
      return;
    }
    unawaited(_loadUserInfo());
  }

  Future<void> _loadUserInfo() async {
    if (!mounted) return;
    final loadVersion = ++_loadVersion;
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client != null && client.isLogged()) {
        if (!mounted || loadVersion != _loadVersion) return;
        setState(() {
          _userId = client.userID;
          _displayName =
              client.userID?.split(':').first.replaceFirst('@', '') ?? 'User';
        });

        try {
          final authRepository = getIt<IAuthRepository>();
          final contactRepository = getIt<IContactRepository>();
          final results = await Future.wait<Object?>([
            contactRepository.getMyStatus(),
            authRepository.getBoundEmail(),
            authRepository.getBoundPhone(),
            authRepository.getCurrentUserProfile(),
          ]);
          final status = results[0] as String?;
          final email = results[1] as String?;
          final phoneNumber = results[2] as String?;
          final profile = results[3] as UserEntity?;
          if (mounted && loadVersion == _loadVersion) {
            setState(() {
              _statusText = status;
              _boundEmail = email;
              _boundPhoneNumber = phoneNumber;
              _displayName = profile?.displayName ?? _displayName;
              _avatarUrl = profile?.avatarUrl ?? _avatarUrl;
              _isNftAvatar = profile?.hasNftAvatar ?? false;
              _avatarDecorationPreset =
                  profile?.avatarDecorationPreset ??
                  AvatarDecorationPreset.none;
            });
          }
        } catch (e) {
          debugLog('Failed to get my status: $e');
        }
      } else if (mounted && loadVersion == _loadVersion) {
        setState(() {
          _userId = null;
          _displayName = null;
          _avatarUrl = null;
          _statusText = null;
          _boundEmail = null;
          _boundPhoneNumber = null;
          _isNftAvatar = false;
          _avatarDecorationPreset = AvatarDecorationPreset.none;
        });
      }
    } catch (e) {
      debugLog('Failed to load user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = context.pageBackground;
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.showAppBar
          ? N42AppBar(
              title: S.of(context)?.commonMe ?? 'Me',
              showBackButton: false,
            )
          : null,
      body: ListView(
        children: [
          // 个人资料卡片
          _buildProfileCard(
            context,
            isDark,
            cardColor,
            textColor,
            subtitleColor,
          ),

          const SizedBox(height: 8),

          // 服务
          _buildGroupCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.verified_outlined,
                iconColor: AppColors.primary,
                title: S.of(context)?.profileServices ?? 'Services',
                onTap: () => _openServices(context),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 收藏、朋友圈、订单与卡包、表情
          _buildGroupCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.inventory_2_outlined,
                iconColor: const Color(0xFFFF9F0A),
                title: S.of(context)?.commonFavorites ?? 'Favorites',
                onTap: () => _openFavorites(context),
              ),
              _buildDivider(context),
              _buildMenuItem(
                context,
                icon: Icons.photo_library_outlined,
                iconColor: const Color(0xFF007AFF),
                title: S.of(context)?.commonMoments ?? 'Moments',
                onTap: () => _openMoments(context),
              ),
              _buildDivider(context),
              _buildMenuItem(
                context,
                icon: Icons.card_giftcard_outlined,
                iconColor: const Color(0xFFFF6B6B),
                title: S.of(context)?.profileOrdersAndCards ?? 'Orders & Cards',
                onTap: () => _openOrdersAndCards(context),
              ),
              _buildDivider(context),
              _buildMenuItem(
                context,
                icon: Icons.emoji_emotions_outlined,
                iconColor: const Color(0xFFFFCC00),
                title: S.of(context)?.profileStickers ?? 'Stickers',
                onTap: () => _openStickers(context),
              ),
              _buildDivider(context),
              _buildMenuItem(
                context,
                icon: Icons.workspace_premium_outlined,
                iconColor: const Color(0xFF9B59B6),
                title: 'Subscriptions',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SubscriptionPage(),
                  ),
                ),
              ),
              _buildDivider(context),
              _buildMenuItem(
                context,
                icon: Icons.account_balance_outlined,
                iconColor: const Color(0xFF2ECC71),
                title: 'Buy / Sell crypto',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FiatRampPage(),
                  ),
                ),
              ),
              _buildDivider(context),
              _buildMenuItem(
                context,
                icon: Icons.memory,
                iconColor: const Color(0xFF34A853),
                title: 'On-device AI',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LocalLlmSettingsPage(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 设置
          _buildGroupCard(
            context,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                iconColor: const Color(0xFF5E97F6),
                title: S.of(context)?.commonSettings ?? 'Settings',
                onTap: () => _openSettings(context),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final n42Id = _userId?.split(':').first.replaceFirst('@', '') ?? '--';

    return Container(
      color: cardColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openEditProfile(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像 - 单独可点击，触发头像操作菜单
                GestureDetector(
                  onTap: () => _showAvatarOptions(context),
                  child: N42Avatar(
                    imageUrl: _avatarUrl,
                    name: _displayName,
                    size: 64,
                    borderRadius: 14,
                    isNftAvatar: _isNftAvatar,
                    decorationPreset: _avatarDecorationPreset,
                  ),
                ),
                const SizedBox(width: 16),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户名
                      Text(
                        _displayName ??
                            (S.of(context)?.profileNotLoggedIn ??
                                'Not Logged In'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // N42号
                      Text(
                        S.of(context)?.profileN42IdLabel(n42Id) ??
                            'N42 ID: $n42Id',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 状态和好友
                      Row(
                        children: [
                          // + 状态 按钮
                          GestureDetector(
                            onTap: () => _showStatusPicker(context, isDark),
                            onLongPress: _statusText != null
                                ? () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(
                                          S.of(context)?.profileClearStatus ??
                                              'Clear Status',
                                        ),
                                        content: Text(
                                          S
                                                  .of(context)
                                                  ?.profileClearStatusConfirm ??
                                              'Are you sure you want to clear your status?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text(
                                              S.of(context)?.commonCancel ??
                                                  'Cancel',
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final messenger =
                                                  ScaffoldMessenger.of(context);
                                              final clearedText =
                                                  S
                                                      .of(context)
                                                      ?.profileStatusCleared ??
                                                  'Status cleared';
                                              Navigator.pop(ctx);
                                              await _clearStatus();
                                              if (!mounted) return;
                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(clearedText),
                                                  duration: const Duration(
                                                    seconds: 1,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              S.of(context)?.commonClear ??
                                                  'Clear',
                                              style: const TextStyle(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_statusText == null) ...[
                                    Icon(
                                      Icons.add,
                                      size: 14,
                                      color: subtitleColor,
                                    ),
                                    const SizedBox(width: 2),
                                  ],
                                  Flexible(
                                    child: Text(
                                      _statusText ??
                                          (S.of(context)?.profileStatus ??
                                              'Status'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.3,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 右侧二维码图标和箭头
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _openMyQRCode(context),
                      child: Icon(
                        Icons.qr_code_2,
                        size: 20,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Icon(AppIcons.chevron, color: subtitleColor, size: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      color: context.surfaceColor,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? badge,
    VoidCallback? onTap,
  }) {
    final textColor = context.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 透明背景的图标
              SizedBox(
                width: 28,
                height: 28,
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    color: textColor,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Icon(
                AppIcons.chevron,
                color: context.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 58),
      child: Divider(
        height: 1,
        color: context.dividerColor,
      ),
    );
  }

  /// 显示状态选择器
  void _showStatusPicker(BuildContext context, bool isDark) async {
    final l10n = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => StatusPage(currentStatus: _statusText),
      ),
    );

    if (result != null && mounted) {
      final previousStatus = _statusText;
      final saveFailedMessage = l10n?.commonSaveFailed ?? 'Save failed';
      setState(() {
        _statusText = result;
      });

      // 同步状态到服务器
      try {
        final contactRepository = getIt<IContactRepository>();
        await contactRepository.setMyStatus(
          result,
          expiresIn: const Duration(hours: 24),
        );
      } catch (e) {
        debugLog('Failed to sync status: $e');
        if (mounted) {
          setState(() {
            _statusText = previousStatus;
          });
          messenger.showSnackBar(
            SnackBar(
              content: Text(saveFailedMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.profileStatusSetTo(result) ?? 'Status set to: $result',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _clearStatus() async {
    final previousStatus = _statusText;
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _statusText = null;
    });

    try {
      final contactRepository = getIt<IContactRepository>();
      await contactRepository.setMyStatus(null);
    } catch (e) {
      debugLog('Failed to clear status: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _statusText = previousStatus;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// 显示头像操作菜单：更换头像 / Avatar Studio
  void _showAvatarOptions(BuildContext context) {
    final l10n = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽条
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: Text(l10n?.profileChangeAvatar ?? 'Change Avatar'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openEditProfile(context);
                },
              ),
              Divider(
                height: 1,
                indent: 56,
                color: context.dividerColor,
              ),
              ListTile(
                leading: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFFFD700),
                ),
                title: const Text('Avatar Studio'),
                subtitle: Text(
                  'NFT Avatar / Decorations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: context.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _openAvatarStudio(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    // 获取当前的 AuthBloc
    final authBloc = context.read<AuthBloc>();

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: authBloc,
              child: const ProfileEditPage(),
            ),
          ),
        )
        .then((_) {
          // 返回后刷新用户信息
          if (!mounted) return;
          _loadUserInfo();
        });
  }

  void _openAvatarStudio(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: authBloc,
              child: const AvatarStudioPage(),
            ),
          ),
        )
        .then((_) {
          if (!mounted) return;
          _loadUserInfo();
        });
  }

  void _openMyQRCode(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MyQRCodePage()));
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          profile: _buildSettingsProfile(),
          onNotification: () => _openNotificationSettings(context),
          onPrivacy: () => _openPrivacySettings(context),
          onAppearance: () => _openAppearanceSettings(context),
          onSecurity: () {
            final client = MatrixClientManager.instance.client;
            if (client == null) return;

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SecuritySettingsPage(
                  e2eeManager: E2EEManager(client),
                  keyBackupService: KeyBackupService(client),
                ),
              ),
            );
          },
          onChangePassword: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: N42Chat.authBloc,
                  child: const ChangePasswordPage(),
                ),
              ),
            );
          },
          onChangeEmail: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: N42Chat.authBloc,
                  child: const ChangeEmailPage(),
                ),
              ),
            );
          },
          onLanguage: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LanguageSettingsPage(),
              ),
            );
          },
          onAccounts: () => _openAccountSwitchPage(context),
          onLogout: () {
            Navigator.of(context).pop();
            context.read<AuthBloc>().add(const AuthLogoutRequested());
          },
        ),
      ),
    );
  }

  UserProfileEntity? _buildSettingsProfile() {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    return UserProfileEntity(
      userId: userId,
      displayName: _displayName,
      avatarUrl: _avatarUrl,
      statusMessage: _statusText,
      email: _boundEmail,
      phoneNumber: _boundPhoneNumber,
      avatarDecorationPreset: _avatarDecorationPreset,
    );
  }

  Future<void> _openPrivacySettings(BuildContext context) async {
    final settings = await getIt<PreferencesDataSource>()
        .getPrivacySettingsModel();
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PrivacySettingsPage(settings: settings),
      ),
    );
  }

  Future<void> _openAppearanceSettings(BuildContext context) async {
    final settings = await N42Chat.getSavedAppearanceSettings();
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppearanceSettingsPage(
          settings: settings,
          onSave: (newSettings) {
            unawaited(N42Chat.applyAppearanceSettings(newSettings));
          },
        ),
      ),
    );
  }

  Future<void> _openNotificationSettings(BuildContext context) async {
    final settings = await N42Chat.getSavedNotificationSettings();
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationSettingsPage(
          settings: settings,
          onSave: (newSettings) {
            unawaited(N42Chat.applyNotificationSettings(newSettings));
          },
        ),
      ),
    );
  }

  Future<void> _openAccountSwitchPage(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AccountSwitchPage()));
  }

  void _openFavorites(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const FavoriteListPage()));
  }

  void _openServices(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ServicesPage()));
  }

  void _openMoments(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MomentListPage()));
  }

  void _openOrdersAndCards(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const OrdersAndCardsPage()));
  }

  void _openStickers(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const StickerStorePage()));
  }
}
