import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/chat_lock_service.dart';
import '../../../core/services/remark_service.dart';
import '../../../core/services/vault_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/story_entity.dart';
import '../../helpers/story_interaction_helper.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_state.dart';
import '../../blocs/conversation/conversation_bloc.dart';
import '../../blocs/conversation/conversation_event.dart';
import '../../blocs/conversation/conversation_state.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/on_chain_notification/on_chain_notification_bloc.dart';
import '../../blocs/on_chain_notification/on_chain_notification_event.dart';
import '../../blocs/on_chain_notification/on_chain_notification_state.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/story/story_bloc.dart';
import '../../blocs/story/story_event.dart';
import '../../blocs/story/story_state.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/sync_progress_overlay.dart';
import '../../widgets/settings/recovery_key_reminder_dialog.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/story/story_bar.dart';
import '../contact/add_friend_page.dart';
import '../group/create_group_page.dart';
import '../notification/on_chain_notifications_page.dart';
import '../vault/vault_list_page.dart';
import '../qrcode/scan_qr_page.dart';
import '../transfer/receive_page.dart';
import '../search/global_search_page.dart';
import '../story/create_story_page.dart';
import '../story/story_viewer_page.dart';
import 'conversation_tile.dart';

/// 会话列表页面（仿微信）
class ConversationListPage extends StatefulWidget {
  /// 点击会话回调
  final void Function(ConversationEntity conversation)? onConversationTap;

  /// 添加按钮点击回调
  final VoidCallback? onAddPressed;

  /// 搜索点击回调
  final VoidCallback? onSearchTap;

  /// 是否显示 AppBar（嵌入到主框架时可设为 false）
  final bool showAppBar;

  /// 当前选中的会话 ID（iPad 分屏模式下高亮显示）
  final String? selectedConversationId;

  const ConversationListPage({
    super.key,
    this.onConversationTap,
    this.onAddPressed,
    this.onSearchTap,
    this.showAppBar = true,
    this.selectedConversationId,
  });

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  // 备注更新订阅
  StreamSubscription<RemarkUpdateEvent>? _remarkSubscription;
  // 保存 Bloc 引用，避免在 dispose 中访问 context
  late ConversationBloc _conversationBloc;
  // StoryBloc 引用
  StoryBloc? _storyBloc;
  // 锁定的聊天 ID 集合
  Set<String> _lockedChatIds = {};
  // 金库会话 ID 集合（在主列表中隐藏）
  Set<String> _vaultRoomIds = {};
  StreamSubscription<Set<String>>? _vaultSubscription;

  @override
  void initState() {
    super.initState();
    // 保存 Bloc 引用
    _conversationBloc = context.read<ConversationBloc>();
    // 加载并订阅会话列表
    _conversationBloc
      ..add(const LoadConversations())
      ..add(const SubscribeConversations());

    // 加载锁定状态
    _loadLockedChats();

    // 订阅金库列表（用于主列表过滤）
    if (getIt.isRegistered<VaultService>()) {
      final vault = getIt<VaultService>();
      _vaultSubscription = vault.watchVaultRoomIds().listen((ids) {
        if (mounted) setState(() => _vaultRoomIds = ids);
      });
    }

    // 初始化 StoryBloc
    _storyBloc = getIt<StoryBloc>()
      ..add(const LoadStories())
      ..add(const SubscribeStories());

    // 监听备注更新
    _remarkSubscription = RemarkService.instance.onRemarkUpdated.listen((
      event,
    ) {
      // 当备注更新时刷新列表
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadLockedChats() async {
    final lockService = ChatLockService();
    final ids = await lockService.getLockedChatIds();
    if (mounted) {
      setState(() => _lockedChatIds = ids.toSet());
    }
  }

  /// 金库切换：加入 / 移出。加入需先启用金库并通过生物识别。
  Future<void> _toggleVault(ConversationEntity conversation) async {
    final vault = getIt<VaultService>();
    final inVault = await vault.isInVault(conversation.id);

    if (!mounted) return;
    if (inVault) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('移出金库'),
          content: const Text('会话将回到主列表。是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('确认'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      await vault.removeFromVault(conversation.id);
      return;
    }

    // 首次使用：启用金库功能
    final enabled = await vault.isVaultEnabled();
    if (!mounted) return;
    if (!enabled) {
      final go = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('启用消息金库'),
          content: const Text(
            '启用后金库中的会话将从主列表隐藏，仅在金库页可见，'
            '且需生物识别 / 聊天锁 PIN 验证。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('启用'),
            ),
          ],
        ),
      );
      if (go != true) return;
      await vault.enableVault();
    }

    // 验证身份后再加入
    final ok = await vault.unlock(reason: 'Verify to move chat into vault');
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('身份验证失败')),
      );
      return;
    }
    await vault.moveToVault(conversation.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已加入金库')),
      );
    }
  }

  /// 打开金库（需身份验证通过）。
  Future<void> openVault() async {
    final vault = getIt<VaultService>();
    final enabled = await vault.isVaultEnabled();
    if (!enabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('尚未启用金库：长按任意会话选择「加入金库」')),
        );
      }
      return;
    }
    final ok = await vault.unlock();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('身份验证失败')),
        );
      }
      return;
    }
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => VaultListPage(onConversationTap: widget.onConversationTap),
      ),
    );
  }

  @override
  void dispose() {
    // 取消备注更新订阅
    _remarkSubscription?.cancel();
    _vaultSubscription?.cancel();
    // 取消会话订阅（使用保存的引用）
    _conversationBloc.add(const UnsubscribeConversations());
    // 取消 Story 订阅并关闭 bloc
    _storyBloc?.add(const UnsubscribeStories());
    _storyBloc?.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<ConversationBloc>().add(const RefreshConversations());
    unawaited(_loadLockedChats());
    // 等待刷新完成
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  void _onConversationTap(ConversationEntity conversation) {
    // 标记已读
    context.read<ConversationBloc>().add(
      MarkConversationAsRead(conversation.id),
    );

    widget.onConversationTap?.call(conversation);
  }

  void _onConversationLongPress(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    _showConversationMenu(context, conversation);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;

    // 检查 ContactBloc 是否可用
    final hasContactBloc = context.read<ContactBloc?>() != null;

    final scaffold = Scaffold(
      backgroundColor: bgColor,
      appBar: widget.showAppBar ? _buildAppBar(isDark) : null,
      body: Stack(
        children: [
          _storyBloc != null
              ? BlocProvider<StoryBloc>.value(
                  value: _storyBloc!,
                  child: _buildBody(isDark),
                )
              : _buildBody(isDark),
          // P0.5: 恢复密钥提醒 Banner（底部固定）
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RecoveryKeyReminderBanner(),
          ),
          // P0.5: 首次同步进度覆盖层
          const SyncProgressOverlay(),
        ],
      ),
    );

    // 用 BlocProvider 包装提供链上通知 Bloc（用于铃铛 Badge）
    final result = BlocProvider<OnChainNotificationBloc>(
      create: (_) =>
          getIt<OnChainNotificationBloc>()
            ..add(const LoadOnChainNotifications()),
      child: scaffold,
    );

    // 如果有 ContactBloc，用 BlocListener 包装来监听备注更新
    if (hasContactBloc) {
      return BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          // 当联系人备注更新时，刷新界面显示备注名
          if (state.status == ContactStatus.remarkUpdated ||
              state.status == ContactStatus.loaded) {
            if (mounted) setState(() {});
          }
        },
        child: result,
      );
    }

    return result;
  }

  /// 构建页面主体
  Widget _buildBody(bool isDark) {
    return Column(
      children: [
        // 搜索栏（微信风格）
        _buildSearchBar(isDark),

        // Story 栏
        if (_storyBloc != null) _buildStoryBar(isDark),

        // 会话列表
        Expanded(
          child: BlocConsumer<ConversationBloc, ConversationState>(
            listenWhen: (previous, current) =>
                previous.newConversationId != current.newConversationId ||
                previous.error != current.error,
            listener: (context, state) {
              // 处理新建会话导航
              if (state.newConversationId != null) {
                ConversationEntity? conversation;
                for (final item in state.conversations) {
                  if (item.id == state.newConversationId) {
                    conversation = item;
                    break;
                  }
                }
                context.read<ConversationBloc>().add(
                  const ClearNewConversationNavigation(),
                );
                if (conversation != null) {
                  widget.onConversationTap?.call(conversation);
                }
              }

              // 显示错误
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.isLoading) {
                return N42Loading(
                  message: S.of(context)?.commonLoading ?? 'Loading...',
                );
              }

              if (state.isEmpty) {
                return N42EmptyState.noData(
                  title:
                      S.of(context)?.conversationNoConversations ??
                      'No conversations',
                  description:
                      S.of(context)?.conversationTapToChat ??
                      'Tap the top right to start chatting',
                );
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: _buildConversationList(state, isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建 Story 栏
  Widget _buildStoryBar(bool isDark) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, state) {
        // 获取当前用户信息
        final clientManager = MatrixClientManager.instance;
        final myUserId = clientManager.userId;
        final myDisplayName = clientManager.displayName;
        // 头像 URL 需要从 state.myStories 中获取，或者异步获取
        String? myAvatarUrl;
        if (state.myStories.isNotEmpty) {
          myAvatarUrl = state.myStories.first.userAvatarUrl;
        }

        // 构建我的 Story
        UserStories? myStory;
        if (state.myStories.isNotEmpty && myUserId != null) {
          myStory = UserStories(
            userId: myUserId,
            userName: myDisplayName ?? myUserId,
            avatarUrl: myAvatarUrl,
            stories: state.myStories,
            lastUpdated: state.myStories.first.createdAt,
          );
        }

        return StoryBar(
          userStories: state.userStories,
          myStory: myStory,
          myAvatarUrl: myAvatarUrl,
          myName: myDisplayName,
          onMyStoryTap: () => _onMyStoryTap(myStory),
          onUserStoryTap: (userStory) => _onUserStoryTap(userStory, state),
          onAddStory: _onAddStory,
        );
      },
    );
  }

  /// 点击我的 Story
  void _onMyStoryTap(UserStories? myStory) {
    final currentUserId = MatrixClientManager.instance.client?.userID;

    if (myStory != null && myStory.stories.isNotEmpty) {
      // 查看我的 Stories
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StoryViewerPage(
            allUserStories: [myStory],
            initialUserIndex: 0,
            currentUserId: currentUserId,
            onStoryViewed: (_) {
              // 自己的 Story 不需要记录查看
            },
            onDeleteStory: _handleStoryDelete,
          ),
        ),
      );
    } else {
      // 没有 Story，跳转到创建页面
      _onAddStory();
    }
  }

  /// 点击用户 Story
  void _onUserStoryTap(UserStories userStory, StoryState state) {
    // 找到该用户在列表中的索引
    final userIndex = state.userStories.indexOf(userStory);
    if (userIndex < 0) return;

    final currentUserId = MatrixClientManager.instance.client?.userID;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(
          allUserStories: state.userStories,
          initialUserIndex: userIndex,
          currentUserId: currentUserId,
          onStoryViewed: (story) {
            _storyBloc?.add(ViewStory(story.id));
          },
          onDeleteStory: _handleStoryDelete,
          onReply: (userId, storyId, message) {
            return _handleStoryReply(userId, storyId, message);
          },
        ),
      ),
    );
  }

  /// 处理 Story 回复
  Future<bool> _handleStoryReply(
    String userId,
    String storyId,
    String message,
  ) async {
    return StoryInteractionHelper.replyToStory(
      context,
      userId: userId,
      storyId: storyId,
      message: message,
    );
  }

  Future<bool> _handleStoryDelete(StoryEntity story) async {
    final storyBloc = _storyBloc;
    if (storyBloc == null) {
      return false;
    }
    return StoryInteractionHelper.deleteStory(
      storyBloc: storyBloc,
      story: story,
    );
  }

  /// 添加新 Story
  void _onAddStory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<StoryBloc>.value(
          value: _storyBloc!,
          child: const CreateStoryPage(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context)?.commonMessages ?? 'Messages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        actions: [
          // 链上通知铃铛（带未读 Badge）
          BlocBuilder<OnChainNotificationBloc, OnChainNotificationState>(
            builder: (context, notifState) {
              final unread = notifState.unreadCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    tooltip:
                        S.of(context)?.onChainNotificationsTitle ??
                        'Notifications',
                    onPressed: () {
                      final bloc = context.read<OnChainNotificationBloc>();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              BlocProvider<OnChainNotificationBloc>.value(
                                value: bloc,
                                child: const OnChainNotificationsPage(),
                              ),
                        ),
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: widget.onAddPressed ?? _showAddMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: widget.onSearchTap ?? _navigateToSearch,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 18,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(width: 6),
              Text(
                S.of(context)?.commonSearch ?? 'Search',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<SearchBloc>(),
          child: const GlobalSearchPage(),
        ),
      ),
    );
  }

  Widget _buildConversationList(ConversationState state, bool isDark) {
    final pinned = _vaultRoomIds.isEmpty
        ? state.pinnedConversations
        : state.pinnedConversations
            .where((c) => !_vaultRoomIds.contains(c.id))
            .toList();
    final normal = _vaultRoomIds.isEmpty
        ? state.normalConversations
        : state.normalConversations
            .where((c) => !_vaultRoomIds.contains(c.id))
            .toList();
    return CustomScrollView(
      slivers: [
        // 置顶会话
        if (pinned.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              child: Column(
                children: pinned.asMap().entries.map((
                  entry,
                ) {
                  return ListItemAnimation(
                    index: entry.key,
                    child: ConversationTile(
                      conversation: entry.value,
                      isSelected:
                          widget.selectedConversationId == entry.value.id,
                      isLocked: _lockedChatIds.contains(entry.value.id),
                      onTap: () => _onConversationTap(entry.value),
                      onLongPress: () =>
                          _onConversationLongPress(context, entry.value),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 分隔
          SliverToBoxAdapter(
            child: Container(
              height: 8,
              color: isDark ? AppColors.backgroundDark : AppColors.background,
            ),
          ),
        ],

        // 普通会话
        SliverToBoxAdapter(
          child: Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: Column(
              children: normal.asMap().entries.map((entry) {
                return ListItemAnimation(
                  index: entry.key,
                  child: ConversationTile(
                    conversation: entry.value,
                    isSelected: widget.selectedConversationId == entry.value.id,
                    isLocked: _lockedChatIds.contains(entry.value.id),
                    onTap: () => _onConversationTap(entry.value),
                    onLongPress: () =>
                        _onConversationLongPress(context, entry.value),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddMenu() {
    final isDark = context.isDarkMode;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: MediaQuery.of(context).size.width >= 600
          ? const BoxConstraints(maxWidth: 400)
          : null,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖动指示器
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 发起群聊
              _buildAddMenuItem(
                ctx,
                icon: Icons.group_add,
                iconColor: const Color(0xFF57BE6A),
                title:
                    S.of(context)?.conversationStartGroup ?? 'Start Group Chat',
                onTap: () => _navigateToCreateGroup(ctx),
              ),

              // 添加朋友
              _buildAddMenuItem(
                ctx,
                icon: Icons.person_add,
                iconColor: const Color(0xFF576B95),
                title: S.of(context)?.commonAddFriend ?? 'Add Friend',
                onTap: () => _navigateToAddFriend(ctx),
              ),

              // 钱包地址发消息
              _buildAddMenuItem(
                ctx,
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFFFF9500),
                title: S.of(context)?.sendToAddress ?? 'Send to Address',
                onTap: () => _navigateToAddFriend(ctx),
              ),

              // 扫一扫
              _buildAddMenuItem(
                ctx,
                icon: Icons.qr_code_scanner,
                iconColor: const Color(0xFF10AEFF),
                title: S.of(context)?.commonScan ?? 'Scan',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ScanQRPage()),
                  );
                },
              ),

              // 收付款 → 复用个人中心已有的收款二维码页面
              _buildAddMenuItem(
                ctx,
                icon: Icons.payment,
                iconColor: const Color(0xFF09BB07),
                title: S.of(context)?.commonPayment ?? 'Payment',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReceivePage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddMenuItem(
    BuildContext ctx, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateToCreateGroup(BuildContext sheetContext) {
    Navigator.pop(sheetContext);

    Navigator.of(context)
        .push<String?>(
          MaterialPageRoute<String?>(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<GroupBloc>()),
                BlocProvider(create: (_) => getIt<ContactBloc>()),
              ],
              child: const CreateGroupPage(),
            ),
          ),
        )
        .then((roomId) {
          if (roomId != null && mounted) {
            // 刷新会话列表
            context.read<ConversationBloc>().add(const RefreshConversations());
          }
        });
  }

  void _navigateToAddFriend(BuildContext sheetContext) {
    Navigator.pop(sheetContext);

    Navigator.of(context)
        .push<String?>(
          MaterialPageRoute<String?>(builder: (_) => const AddFriendPage()),
        )
        .then((roomId) {
          if (roomId != null && mounted) {
            // 刷新会话列表
            context.read<ConversationBloc>().add(const RefreshConversations());
          }
        });
  }

  void _showConversationMenu(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    final isDark = context.isDarkMode;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: MediaQuery.of(context).size.width >= 600
          ? const BoxConstraints(maxWidth: 400)
          : null,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖动指示器
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 标记已读
              if (conversation.unreadCount > 0)
                _buildMenuTile(
                  ctx,
                  icon: Icons.done_all,
                  title:
                      S.of(context)?.conversationMarkAsRead ?? 'Mark as read',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<ConversationBloc>().add(
                      MarkConversationAsRead(conversation.id),
                    );
                  },
                ),

              // 免打扰
              _buildMenuTile(
                ctx,
                icon: conversation.isMuted
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                title: conversation.isMuted
                    ? (S.of(context)?.commonUnmute ?? 'Unmute')
                    : (S.of(context)?.commonMute ?? 'Mute'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<ConversationBloc>().add(
                    SetConversationMuted(
                      conversationId: conversation.id,
                      muted: !conversation.isMuted,
                    ),
                  );
                },
              ),

              // 置顶
              _buildMenuTile(
                ctx,
                icon: conversation.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin,
                title: conversation.isPinned
                    ? (S.of(context)?.conversationUnpin ?? 'Unpin')
                    : (S.of(context)?.conversationPin ?? 'Pin'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<ConversationBloc>().add(
                    SetConversationPinned(
                      conversationId: conversation.id,
                      pinned: !conversation.isPinned,
                    ),
                  );
                },
              ),

              // 隐藏
              _buildMenuTile(
                ctx,
                icon: Icons.visibility_off_outlined,
                title: S.of(context)?.conversationHideChat ?? 'Hide',
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<ConversationBloc>().add(
                    SetConversationHidden(
                      conversationId: conversation.id,
                      hidden: true,
                    ),
                  );
                },
              ),

              // 金库（加入 / 移出）
              if (getIt.isRegistered<VaultService>())
                _buildMenuTile(
                  ctx,
                  icon: _vaultRoomIds.contains(conversation.id)
                      ? Icons.lock_open_outlined
                      : Icons.shield_outlined,
                  title: _vaultRoomIds.contains(conversation.id)
                      ? '移出金库'
                      : '加入金库',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _toggleVault(conversation);
                  },
                ),

              // 删除
              _buildMenuTile(
                ctx,
                icon: Icons.delete_outline,
                title:
                    S.of(context)?.conversationDeleteConversation ??
                    'Delete Conversation',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteConversation(conversation);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;
    final textColor = isDestructive
        ? AppColors.error
        : (isDark ? Colors.white : Colors.black);
    final iconColor = isDestructive
        ? AppColors.error
        : (isDark ? Colors.white54 : Colors.black54);

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  void _confirmDeleteConversation(ConversationEntity conversation) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          S.of(context)?.conversationDeleteConversation ??
              'Delete Conversation',
        ),
        content: Text(
          S
                  .of(context)
                  ?.conversationDeleteConversationConfirm(conversation.name) ??
              'Are you sure you want to delete the conversation with "${conversation.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ConversationBloc>().add(
                DeleteConversation(conversation.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(S.of(context)?.commonDelete ?? 'Delete'),
          ),
        ],
      ),
    );
  }
}
