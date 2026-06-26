import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/remark_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/contact/contact_state.dart';
import '../../widgets/common/n42_avatar.dart';
import '../moment/moment_list_page.dart';
import 'common_groups_page.dart';
import 'contact_permissions_page.dart';
import 'contact_settings_page.dart';
import 'tags_management_page.dart';
import '../../../core/utils/debug_log.dart';

/// 联系人详情页面（仿微信）
class ContactDetailPage extends StatefulWidget {
  /// 联系人用户ID
  final String userId;

  /// 联系人显示名称
  final String displayName;

  /// 联系人头像URL
  final String? avatarUrl;

  /// 发消息回调
  final VoidCallback? onSendMessage;

  /// 音视频通话回调
  final VoidCallback? onVideoCall;

  const ContactDetailPage({
    super.key,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.onSendMessage,
    this.onVideoCall,
  });

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  ContactEntity? _contact;
  bool _isStarred = false;
  bool _isFriend = false;
  bool _isAddingFriend = false;
  StreamSubscription<RemarkUpdateEvent>? _remarkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadContact();
    });
    _remarkSubscription = RemarkService.instance.onRemarkUpdated.listen(
      _handleRemarkUpdate,
    );
  }

  void _loadContact() {
    if (!mounted) return;
    final contactBloc = _maybeContactBloc();
    if (contactBloc == null) return;

    final contactState = contactBloc.state;
    if (contactState.isLoaded) {
      final contact = contactState.contacts
          .where((ContactEntity c) => c.userId == widget.userId)
          .firstOrNull;
      if (mounted) {
        final nextContact = _mergeRemarkIntoContact(contact);
        final nextIsFriend = nextContact != null;
        if (_contact != nextContact || _isFriend != nextIsFriend) {
          setState(() {
            _contact = nextContact;
            _isFriend = nextIsFriend;
          });
        }
      }
    }
  }

  ContactBloc? _maybeContactBloc() {
    return context.read<ContactBloc?>();
  }

  ContactEntity? _mergeRemarkIntoContact(ContactEntity? contact) {
    if (contact == null) return null;
    final cachedRemark = RemarkService.instance.getRemark(widget.userId);
    if (cachedRemark == contact.remark) {
      return contact;
    }
    return _copyContactWithRemark(contact, cachedRemark);
  }

  ContactEntity _copyContactWithRemark(ContactEntity contact, String? remark) {
    return ContactEntity(
      userId: contact.userId,
      displayName: contact.displayName,
      avatarUrl: contact.avatarUrl,
      presence: contact.presence,
      lastActiveTime: contact.lastActiveTime,
      statusMessage: contact.statusMessage,
      remark: remark,
      isBlocked: contact.isBlocked,
      isFriend: contact.isFriend,
      directRoomId: contact.directRoomId,
      tags: contact.tags,
      n42Username: contact.n42Username,
      walletAddress: contact.walletAddress,
      ensName: contact.ensName,
    );
  }

  void _handleRemarkUpdate(RemarkUpdateEvent event) {
    if (!mounted || event.userId != widget.userId) return;
    setState(() {
      final baseContact =
          _contact ??
          ContactEntity(
            userId: widget.userId,
            displayName: widget.displayName,
            avatarUrl: widget.avatarUrl,
          );
      _contact = _copyContactWithRemark(baseContact, event.remark);
    });
  }

  @override
  void dispose() {
    _remarkSubscription?.cancel();
    super.dispose();
  }

  String get _effectiveDisplayName {
    // 优先从 RemarkService 获取
    final remark = RemarkService.instance.getRemark(widget.userId);
    if (remark != null && remark.isNotEmpty) {
      return remark;
    }
    // 其次从 _contact 获取
    if (_contact?.remark != null && _contact!.remark!.isNotEmpty) {
      return _contact!.remark!;
    }
    return widget.displayName;
  }

  String get _n42Id {
    // 从 userId 提取 N42 ID
    if (widget.userId.startsWith('@')) {
      final colonIndex = widget.userId.indexOf(':');
      if (colonIndex > 1) {
        return widget.userId.substring(1, colonIndex);
      }
      return widget.userId.substring(1);
    }
    return widget.userId;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.pageBackground;
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;
    final dividerColor = context.dividerThin;

    // 检查 ContactBloc 是否可用
    final hasContactBloc = _maybeContactBloc() != null;

    final Widget scaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: textColor),
            onPressed: () => _openSettings(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 用户信息卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像
                  N42Avatar(
                    imageUrl: widget.avatarUrl,
                    name: _effectiveDisplayName,
                    size: 64,
                    borderRadius: 8,
                  ),
                  const SizedBox(width: 16),

                  // 名称和ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _effectiveDisplayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          S.of(context)?.contactN42Id(_n42Id) ??
                              'N42 ID: $_n42Id',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 星标
                  if (_isStarred)
                    const Icon(Icons.star, color: Color(0xFFFFD700), size: 24),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 朋友资料
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                _buildMenuItem(
                  title: S.of(context)?.contactFriendInfo ?? 'Friend Info',
                  subtitle:
                      S.of(context)?.contactFriendInfoDesc ??
                      'Add friend\'s remark, phone, tags, notes, photos and set permissions.',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _openFriendInfo(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 朋友圈
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                _buildMenuItem(
                  title: S.of(context)?.commonMoments ?? 'Moments',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MomentListPage(
                          userId: widget.userId,
                          userName: _effectiveDisplayName,
                          userAvatarUrl: widget.avatarUrl,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 视频号
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [_buildVideoSection(textColor, secondaryTextColor)],
            ),

            const SizedBox(height: 32),

            // 根据是否是好友显示不同按钮
            if (_isFriend) ...[
              // 好友：显示发消息和音视频通话按钮
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: S.of(context)?.commonSendMessage ?? 'Message',
                onTap:
                    widget.onSendMessage ?? () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: 12),

              _buildActionButton(
                icon: Icons.phone_outlined,
                label:
                    S.of(context)?.contactAudioVideoCall ?? 'Audio/Video Call',
                onTap: widget.onVideoCall ?? () {},
              ),
            ] else ...[
              // 非好友：显示添加好友按钮
              _buildAddFriendButton(),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    // 如果有 ContactBloc，用 BlocListener 包装
    if (hasContactBloc) {
      return BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state.status == ContactStatus.remarkUpdated &&
              state.updatedRemarkUserId == widget.userId) {
            _handleRemarkUpdate(
              RemarkUpdateEvent(
                userId: widget.userId,
                remark: state.updatedRemark,
              ),
            );
          } else if (state.status == ContactStatus.loaded) {
            _loadContact();
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }

  Widget _buildMenuSection({
    required Color cardColor,
    required Color dividerColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          top: BorderSide(color: dividerColor, width: 0.5),
          bottom: BorderSide(color: dividerColor, width: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required String title,
    String? subtitle,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, height: 1.3, color: textColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, height: 1.3, color: secondaryTextColor),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              AppIcons.chevron,
              color: secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection(Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.of(context)?.contactVideoChannel ?? 'Video Channel',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, height: 1.3, color: textColor),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  _effectiveDisplayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, height: 1.3, color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 视频缩略图列表
          SizedBox(
            height: 80,
            child: Row(
              children: [
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white54,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  AppIcons.chevron,
                  color: secondaryTextColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final borderColor = context.dividerThin;
    final iconColor = context.textSecondary;
    final textColor = context.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: borderColor, width: 0.5),
              bottom: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, height: 1.3, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建添加好友按钮
  Widget _buildAddFriendButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _isAddingFriend ? null : _addFriend,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isAddingFriend)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const Icon(Icons.person_add, size: 20),
            const SizedBox(width: 8),
            Text(
              _isAddingFriend
                  ? (S.of(context)?.contactAddingToContacts ?? 'Adding...')
                  : (S.of(context)?.contactAddToContacts ?? 'Add to Contacts'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加好友
  Future<void> _addFriend() async {
    setState(() {
      _isAddingFriend = true;
    });

    try {
      // 通过 StartChat 事件创建私聊（这会自动将对方添加到联系人）
      final contactBloc = context.read<ContactBloc>();
      contactBloc.add(StartChat(widget.userId));

      // 等待一小段时间让操作完成
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // 重新加载联系人信息
      _loadContact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.contactAddedToContacts ?? 'Added to contacts',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.contactAddFailedWithError(e.toString()) ??
                  'Add failed: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingFriend = false;
        });
      }
    }
  }

  void _openSettings() {
    // 获取当前的 ContactBloc
    final contactBloc = _maybeContactBloc();

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (ctx) {
              final page = ContactSettingsPage(
                userId: widget.userId,
                displayName: _effectiveDisplayName,
                isStarred: _isStarred,
                onStarChanged: (starred) {
                  setState(() {
                    _isStarred = starred;
                  });
                },
              );

              if (contactBloc != null) {
                return BlocProvider.value(value: contactBloc, child: page);
              }
              return page;
            },
          ),
        )
        .then((_) {
          // 返回时刷新联系人信息
          if (!mounted) return;
          _loadContact();
        });
  }

  void _openFriendInfo() {
    // 获取当前的 ContactBloc
    final contactBloc = _maybeContactBloc();

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (ctx) {
              final page = FriendInfoPage(
                userId: widget.userId,
                displayName: widget.displayName,
                avatarUrl: widget.avatarUrl,
                remark:
                    RemarkService.instance.getRemark(widget.userId) ??
                    _contact?.remark,
              );

              if (contactBloc != null) {
                return BlocProvider.value(value: contactBloc, child: page);
              }
              return page;
            },
          ),
        )
        .then((_) {
          if (!mounted) return;
          _loadContact();
        });
  }
}

/// 朋友资料页面（图三）
class FriendInfoPage extends StatefulWidget {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? remark;

  const FriendInfoPage({
    super.key,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.remark,
  });

  @override
  State<FriendInfoPage> createState() => _FriendInfoPageState();
}

class _FriendInfoPageState extends State<FriendInfoPage> {
  String? _currentRemark;
  StreamSubscription<RemarkUpdateEvent>? _remarkSubscription;

  @override
  void initState() {
    super.initState();
    _currentRemark = widget.remark;
    _loadRemark();
    _remarkSubscription = RemarkService.instance.onRemarkUpdated.listen(
      _handleRemarkUpdate,
    );
  }

  @override
  void dispose() {
    _remarkSubscription?.cancel();
    super.dispose();
  }

  void _loadRemark() {
    // 优先从 RemarkService 获取（全局本地缓存）
    final remark = RemarkService.instance.getRemark(widget.userId);
    if (remark != null && remark.isNotEmpty && mounted) {
      setState(() {
        _currentRemark = remark;
      });
      return;
    }

    // 备用：从 ContactBloc 获取
    final contactBloc = _maybeContactBloc();
    if (contactBloc == null) return;

    final contactState = contactBloc.state;
    if (contactState.isLoaded) {
      final contact = contactState.contacts
          .where((ContactEntity c) => c.userId == widget.userId)
          .firstOrNull;
      if (contact != null && mounted) {
        setState(() {
          _currentRemark = contact.remark;
        });
      }
    }
  }

  ContactBloc? _maybeContactBloc() {
    return context.read<ContactBloc?>();
  }

  void _handleRemarkUpdate(RemarkUpdateEvent event) {
    if (!mounted || event.userId != widget.userId) return;
    setState(() {
      _currentRemark = event.remark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.pageBackground;
    final cardColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final secondaryTextColor = context.textSecondary;
    final labelColor = context.textTertiary;
    final dividerColor = context.dividerThin;

    // 检查 ContactBloc 是否可用
    final hasContactBloc = _maybeContactBloc() != null;

    final Widget scaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            color: textColor,
            size: 20,
          ),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context)?.contactFriendInfo ?? 'Friend Info',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 备注分组
            _buildSectionLabel(
              S.of(context)?.contactRemark ?? 'Remark',
              labelColor,
            ),
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                _buildMenuItem(
                  title: S.of(context)?.contactRemarkName ?? 'Remark Name',
                  value: _currentRemark ?? widget.displayName,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _openEditRemark(),
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: S.of(context)?.contactPhone ?? 'Phone',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () {},
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: S.of(context)?.contactTags ?? 'Tags',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _openTagsManagement(),
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: S.of(context)?.contactNotes ?? 'Notes',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _showNotesDialog(),
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: S.of(context)?.contactPhotos ?? 'Photos',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _showPhotosDialog(),
                ),
              ],
            ),

            // 权限分组
            _buildSectionLabel(
              S.of(context)?.contactPermissions ?? 'Permissions',
              labelColor,
            ),
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                _buildMenuItem(
                  title: S.of(context)?.contactPermissions ?? 'Permissions',
                  value:
                      S.of(context)?.contactChatMomentsEtc ??
                      'Chat, Moments, Sports, etc.',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _openPermissions(),
                ),
              ],
            ),

            // 更多信息分组
            _buildSectionLabel(
              S.of(context)?.contactMoreInfo ?? 'More Info',
              labelColor,
            ),
            _buildMenuSection(
              cardColor: cardColor,
              dividerColor: dividerColor,
              children: [
                _buildMenuItem(
                  title:
                      S.of(context)?.contactCommonGroups ?? 'Groups in common',
                  value: S.of(context)?.contactGroupCountLabel(0) ?? '0 groups',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () => _openCommonGroups(),
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: S.of(context)?.contactSource ?? 'Source',
                  value:
                      S.of(context)?.contactAddedViaSearch ??
                      'Added via search',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () {},
                  showArrow: false,
                ),
                _buildDivider(dividerColor),
                _buildMenuItem(
                  title: S.of(context)?.contactAddTime ?? 'Add time',
                  value: S.of(context)?.commonUnknownMember ?? 'Unknown',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () {},
                  showArrow: false,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    // 如果有 ContactBloc，用 BlocListener 包装
    if (hasContactBloc) {
      return BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state.status == ContactStatus.remarkUpdated &&
              state.updatedRemarkUserId == widget.userId) {
            _handleRemarkUpdate(
              RemarkUpdateEvent(
                userId: widget.userId,
                remark: state.updatedRemark,
              ),
            );
          } else if (state.status == ContactStatus.loaded) {
            _loadRemark();
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, height: 1.3, color: color),
      ),
    );
  }

  Widget _buildMenuSection({
    required Color cardColor,
    required Color dividerColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          top: BorderSide(color: dividerColor, width: 0.5),
          bottom: BorderSide(color: dividerColor, width: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required String title,
    String? value,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 左侧标题
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, height: 1.3, color: textColor),
            ),
            // 中间弹性空间
            Expanded(
              child: value != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.3,
                          color: secondaryTextColor,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // 右侧箭头
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(
                AppIcons.chevron,
                color: secondaryTextColor,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 0.5, thickness: 0.5, color: color),
    );
  }

  void _openTagsManagement() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const TagsManagementPage(selectMode: true),
      ),
    );
  }

  void _openPermissions() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContactPermissionsPage(
          userId: widget.userId,
          displayName: widget.displayName,
        ),
      ),
    );
  }

  void _openCommonGroups() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommonGroupsPage(
          userId: widget.userId,
          displayName: widget.displayName,
        ),
      ),
    );
  }

  void _showNotesDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text(
          S.of(context)?.contactNotes ?? 'Notes',
          style: TextStyle(
            color: context.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: TextStyle(
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.contactNotesHint ??
                'Add notes about this contact',
            hintStyle: TextStyle(
              color: context.textSecondary,
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context)?.commonSave ?? 'Saved'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Text(S.of(context)?.commonSave ?? 'Save'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showPhotosDialog() {
    _openContactMoments();
  }

  void _openContactMoments() {
    final displayName = (_currentRemark?.isNotEmpty ?? false)
        ? _currentRemark!
        : widget.displayName;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MomentListPage(
          userId: widget.userId,
          userName: displayName,
          userAvatarUrl: widget.avatarUrl,
        ),
      ),
    );
  }

  void _openEditRemark() {
    Navigator.of(context)
        .push<String?>(
          MaterialPageRoute<String?>(
            builder: (ctx) {
              // 传递 ContactBloc
              ContactBloc? contactBloc;
              try {
                contactBloc = context.read<ContactBloc>();
              } catch (e) {
                // ContactBloc 可能不可用
                debugLog('Error: $e');
              }

              final page = EditRemarkPage(
                userId: widget.userId,
                currentRemark: _currentRemark,
                displayName: widget.displayName,
              );

              if (contactBloc != null) {
                return BlocProvider.value(value: contactBloc, child: page);
              }
              return page;
            },
          ),
        )
        .then((newRemark) {
          if (!mounted) return;
          // 如果有返回值，直接更新显示
          if (newRemark != null || newRemark == '') {
            setState(() {
              _currentRemark = newRemark?.isEmpty == true ? null : newRemark;
            });
          }
          // 同时尝试从 ContactBloc 刷新
          _loadRemark();
        });
  }
}

/// 编辑备注页面（图四）
class EditRemarkPage extends StatefulWidget {
  final String userId;
  final String? currentRemark;
  final String displayName;

  const EditRemarkPage({
    super.key,
    required this.userId,
    this.currentRemark,
    required this.displayName,
  });

  @override
  State<EditRemarkPage> createState() => _EditRemarkPageState();
}

class _EditRemarkPageState extends State<EditRemarkPage> {
  late TextEditingController _remarkController;
  late TextEditingController _phoneController;
  late TextEditingController _memoController;
  bool _isSaving = false;
  String? _pendingRemarkToSave;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(
      text: widget.currentRemark ?? widget.displayName,
    );
    _phoneController = TextEditingController();
    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _phoneController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _showAddPhoneDialog() {
    final phoneController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text(
          S.of(context)?.contactPhone ?? 'Phone',
          style: TextStyle(
            color: context.textPrimary,
          ),
        ),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText:
                S.of(context)?.contactAddPhoneHint ?? 'Enter phone number',
            hintStyle: TextStyle(
              color: context.textSecondary,
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final phone = phoneController.text.trim();
              Navigator.pop(ctx);
              if (phone.isNotEmpty) {
                _phoneController.text = phone;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context)?.commonSave ?? 'Saved'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Text(S.of(context)?.commonSave ?? 'Save'),
          ),
        ],
      ),
    ).whenComplete(phoneController.dispose);
  }

  void _save() async {
    if (_isSaving) return;

    final remark = _remarkController.text.trim();
    final remarkToSave = remark.isEmpty ? null : remark;

    debugLog(
      'EditRemarkPage: Saving remark for userId=${widget.userId}, remark=$remark',
    );

    if (!mounted) return;
    try {
      setState(() {
        _isSaving = true;
        _pendingRemarkToSave = remarkToSave;
      });
      context.read<ContactBloc>().add(
        SetContactRemark(widget.userId, remarkToSave),
      );
      debugLog('EditRemarkPage: ContactBloc notified');
    } catch (e) {
      debugLog('EditRemarkPage: ContactBloc not available: $e');
      await RemarkService.instance.setRemark(widget.userId, remarkToSave);
      debugLog('EditRemarkPage: Remark saved to RemarkService fallback');
      if (mounted) {
        setState(() {
          _isSaving = false;
          _pendingRemarkToSave = null;
        });
        Navigator.of(context).pop(remarkToSave);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = context.pageBackground;
    final cardColor = isDark
        ? AppColors.surfaceDark
        : AppColors.inputBackground;
    final textColor = context.textPrimary;
    final hintColor = context.textTertiary;
    final labelColor = context.textSecondary;

    final scaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leadingWidth: 70,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                S.of(context)?.commonCancel ?? 'Cancel',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          ),
        ),
        title: Text(
          S.of(context)?.contactEditRemark ?? 'Edit Remark',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _isSaving ? null : _save,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        S.of(context)?.contactDoneButton ?? 'Done',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 备注名
            Text(
              S.of(context)?.contactRemarkName ?? 'Remark Name',
              style: TextStyle(fontSize: 13, color: labelColor),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _remarkController,
                style: TextStyle(fontSize: 16, color: textColor),
                decoration: InputDecoration(
                  hintText: widget.displayName,
                  hintStyle: TextStyle(color: hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 电话
            Text(
              S.of(context)?.contactPhone ?? 'Phone',
              style: TextStyle(fontSize: 13, color: labelColor),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => _showAddPhoneDialog(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: hintColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context)?.contactAddPhone ?? 'Add phone',
                        style: TextStyle(fontSize: 16, color: hintColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 标签
            Text(
              S.of(context)?.contactTags ?? 'Tags',
              style: TextStyle(fontSize: 13, color: labelColor),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const TagsManagementPage(selectMode: true),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Text(
                        S.of(context)?.contactAddTag ?? 'Add tags',
                        style: TextStyle(fontSize: 16, color: hintColor),
                      ),
                      const Spacer(),
                      Icon(
                        AppIcons.chevron,
                        color: hintColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 备忘
            Text(
              S.of(context)?.contactNotes ?? 'Notes',
              style: TextStyle(fontSize: 13, color: labelColor),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _memoController,
                style: TextStyle(fontSize: 16, color: textColor),
                decoration: InputDecoration(
                  hintText: S.of(context)?.contactAddText ?? 'Add text',
                  hintStyle: TextStyle(color: hintColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 照片
            Text(
              S.of(context)?.contactPhotos ?? 'Photos',
              style: TextStyle(fontSize: 13, color: labelColor),
            ),
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MomentListPage(
                        userId: widget.userId,
                        userName: widget.displayName,
                        userAvatarUrl: null,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: hintColor, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      S.of(context)?.contactAddPhoto ?? 'Add photo',
                      style: TextStyle(fontSize: 12, color: hintColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (context.read<ContactBloc?>() == null) {
      return scaffold;
    }

    return BlocListener<ContactBloc, ContactState>(
      listenWhen: (previous, current) =>
          _isSaving &&
          (previous.status != current.status ||
              previous.updatedRemarkUserId != current.updatedRemarkUserId ||
              previous.errorMessage != current.errorMessage),
      listener: (context, state) {
        if (state.status == ContactStatus.remarkUpdated &&
            state.updatedRemarkUserId == widget.userId) {
          final savedRemark = _pendingRemarkToSave;
          setState(() {
            _isSaving = false;
            _pendingRemarkToSave = null;
          });
          Navigator.of(context).pop(savedRemark);
        } else if (state.status == ContactStatus.error) {
          final errorMessage = state.errorMessage ?? 'Failed to save remark';
          setState(() {
            _isSaving = false;
            _pendingRemarkToSave = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: scaffold,
    );
  }
}
