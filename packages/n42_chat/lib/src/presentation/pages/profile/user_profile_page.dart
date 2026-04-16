import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/contact/contact_state.dart';
import '../../widgets/common/common_widgets.dart';

typedef UserProfileChatStartedCallback =
    Future<void> Function(String roomId, BuildContext context);

/// 用户资料页面
class UserProfilePage extends StatefulWidget {
  final String userId;
  final UserProfileChatStartedCallback? onChatStarted;

  const UserProfilePage({super.key, required this.userId, this.onChatStarted});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  ContactEntity? _contact;
  bool _isLoading = true;
  bool _isSavingRemark = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 从BLoC状态中获取联系人信息，或者直接从仓库加载
      final bloc = context.read<ContactBloc>();
      final state = bloc.state;

      if (state.isLoaded) {
        // 首先从本地联系人中查找
        final contact = state.contacts.cast<ContactEntity?>().firstWhere(
          (c) => c?.userId == widget.userId,
          orElse: () => null,
        );

        if (contact != null) {
          if (!mounted) return;
          setState(() {
            _contact = contact;
            _isLoading = false;
          });
          return;
        }
      }

      final repository = getIt<IContactRepository>();
      final remoteContact = await repository.getContactById(widget.userId);
      if (!mounted) return;

      setState(() {
        _contact =
            remoteContact ??
            ContactEntity(
              userId: widget.userId,
              displayName: widget.userId.split(':').first.replaceFirst('@', ''),
            );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state.status == ContactStatus.chatStarted &&
              state.startedChatUserId == widget.userId) {
            final roomId = state.startedChatRoomId;
            if (roomId == null || roomId.isEmpty) {
              return;
            }

            if (widget.onChatStarted != null) {
              widget.onChatStarted!(roomId, context);
              return;
            }

            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(roomId);
            }
          } else if (state.status == ContactStatus.remarkUpdated &&
              state.updatedRemarkUserId == widget.userId) {
            final updatedRemark = state.updatedRemark;
            setState(() {
              _isSavingRemark = false;
              _contact = _contact?.copyWith(remark: updatedRemark);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  updatedRemark == null || updatedRemark.isEmpty
                      ? (S.of(context)?.profileRemarkCleared ??
                            'Remark cleared')
                      : (S.of(context)?.profileRemarkSaved ?? 'Remark saved'),
                ),
              ),
            );
          } else if (state.status == ContactStatus.error) {
            if (_isSavingRemark) {
              setState(() {
                _isSavingRemark = false;
              });
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage ?? '')));
          }
        },
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            N42Button(
              text: S.of(context)?.commonRetry ?? 'Retry',
              onPressed: _loadUserProfile,
            ),
          ],
        ),
      );
    }

    if (_contact == null) {
      return Center(
        child: Text(
          S.of(context)?.profileUserNotExist ?? 'User does not exist',
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // 个人资料头部
        SliverToBoxAdapter(child: _buildProfileHeader(isDark)),

        // 信息区块
        SliverToBoxAdapter(child: _buildInfoSection(isDark)),

        // 操作按钮
        SliverToBoxAdapter(child: _buildActionButtons(isDark)),

        // 更多选项
        SliverToBoxAdapter(child: _buildMoreOptions(isDark)),
      ],
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    final contact = _contact!;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Column(
        children: [
          // 顶部返回栏
          SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    onPressed: _showMoreOptions,
                  ),
                ],
              ),
            ),
          ),

          // 头像和基本信息
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 大头像
                Stack(
                  children: [
                    N42Avatar(
                      imageUrl: contact.avatarUrl,
                      name: contact.effectiveDisplayName,
                      size: 64,
                    ),
                    if (contact.isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // 名称和用户名
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.effectiveDisplayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: contact.userId),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                S.of(context)?.profileUserIdCopied ??
                                    'User ID copied',
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                contact.userId,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.copy,
                              size: 14,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    final contact = _contact!;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态消息
          if (contact.statusMessage?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context)?.profileBio ?? 'Bio',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contact.statusMessage!,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

          // 在线状态
          _buildInfoTile(
            S.of(context)?.profileStatus ?? 'Status',
            contact.isOnline
                ? (S.of(context)?.profileOnline ?? 'Online')
                : (contact.formattedLastActive.isNotEmpty
                      ? contact.formattedLastActive
                      : (S.of(context)?.profileOffline ?? 'Offline')),
            isDark,
            statusColor: contact.isOnline ? AppColors.success : null,
          ),

          // 服务器
          _buildInfoTile(
            S.of(context)?.profileHomeServer ?? 'Server',
            contact.server,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    bool isDark, {
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (statusColor != null)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Row(
        children: [
          // 发消息按钮
          Expanded(
            child: N42Button(
              text: S.of(context)?.commonSendMessage ?? 'Message',
              onPressed: _startChat,
              icon: Icons.chat_bubble_outline,
            ),
          ),

          const SizedBox(width: 16),

          // 语音/视频通话按钮（可选）
          Expanded(
            child: N42Button(
              text: S.of(context)?.commonVoiceCall ?? 'Voice Call',
              type: N42ButtonType.secondary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.profileVoiceCallFeatureInDev ??
                          'Voice call feature in development...',
                    ),
                  ),
                );
              },
              icon: Icons.call_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOptions(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Column(
        children: [
          // 设置备注
          ListTile(
            title: Text(S.of(context)?.commonSetRemark ?? 'Set remark'),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            onTap: _setRemark,
          ),

          Divider(
            height: 1,
            indent: 16,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),

          // 加入黑名单
          ListTile(
            title: Text(
              context.read<ContactBloc>().state.contacts.any(
                    (c) => c.userId == widget.userId && c.isBlocked,
                  )
                  ? (S.of(context)?.profileRemoveFromBlacklist ??
                        'Remove from Blacklist')
                  : (S.of(context)?.profileAddToBlacklist ??
                        'Add to Blacklist'),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            onTap: _toggleBlock,
          ),

          Divider(
            height: 1,
            indent: 16,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),

          // 举报
          ListTile(
            title: Text(S.of(context)?.commonReport ?? 'Report'),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            onTap: _report,
          ),
        ],
      ),
    );
  }

  void _startChat() {
    context.read<ContactBloc>().add(StartChat(widget.userId));
  }

  void _setRemark() {
    final controller = TextEditingController(text: _contact?.remark);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(S.of(context)?.commonSetRemark ?? 'Set remark'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: S.of(context)?.profileEnterRemark ?? 'Enter remark',
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                final remark = controller.text.trim();
                Navigator.pop(dialogContext);

                setState(() {
                  _isSavingRemark = true;
                });
                context.read<ContactBloc>().add(
                  SetContactRemark(
                    widget.userId,
                    remark.isEmpty ? null : remark,
                  ),
                );
              },
              child: Text(S.of(context)?.commonConfirm ?? 'Confirm'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _toggleBlock() {
    final isBlocked = context.read<ContactBloc>().state.contacts.any(
      (c) => c.userId == widget.userId && c.isBlocked,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isBlocked
              ? (S.of(context)?.profileRemoveFromBlacklist ??
                    'Remove from Blacklist')
              : (S.of(context)?.profileAddToBlacklist ?? 'Add to Blacklist'),
        ),
        content: Text(
          isBlocked
              ? (S.of(context)?.profileConfirmRemoveBlacklist ??
                    'Are you sure you want to remove this user from blacklist?')
              : (S.of(context)?.profileConfirmAddBlacklist ??
                    'Are you sure you want to add this user to blacklist? You will not receive messages from them.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (isBlocked) {
                context.read<ContactBloc>().add(UnignoreUser(widget.userId));
              } else {
                context.read<ContactBloc>().add(IgnoreUser(widget.userId));
              }
            },
            child: Text(
              isBlocked
                  ? (S.of(context)?.commonRemove ?? 'Remove')
                  : (S.of(context)?.commonAdd ?? 'Add'),
            ),
          ),
        ],
      ),
    );
  }

  void _report() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context)?.profileReportFeatureInDev ??
              'Report feature in development...',
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(
                S.of(context)?.profileShareContactCard ?? 'Share Contact Card',
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.profileShareFeatureInDev ??
                          'Share feature in development...',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(S.of(context)?.profileQrCode ?? 'QR Code'),
              onTap: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.profileQrCodeFeatureInDev ??
                          'QR code feature in development...',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
