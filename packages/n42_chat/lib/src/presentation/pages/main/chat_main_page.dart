import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/chat_lock_service.dart';
import '../../../core/services/on_chain_notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/conversation/conversation_bloc.dart';
import '../../blocs/conversation/conversation_event.dart';
import '../../blocs/conversation/conversation_state.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/moment/moment_bloc.dart';
import '../../blocs/moment/moment_event.dart';
import '../../blocs/transfer/transfer_bloc.dart';
import '../chat/chat_lock_page.dart';
import '../chat/chat_page.dart';
import '../contact/add_friend_page.dart';
import '../contact/contact_list_page.dart';
import '../conversation/conversation_list_page.dart';
import '../discover/discover_page.dart';
import '../group/create_group_page.dart';
import '../profile/profile_page.dart';
import '../qrcode/scan_qr_page.dart';
import '../transfer/receive_page.dart';
import '../../../core/utils/debug_log.dart';

/// 聊天模块主框架页面
///
/// 底部 Tab 导航，包含：
/// - 消息（消息列表）
/// - 通讯录
/// - 发现
/// - 我
///
/// iPad / 宽屏（>= 600）时使用分屏布局：
/// 左侧为会话列表（含 Tab 切换），右侧为聊天内容。
class ChatMainPage extends StatefulWidget {
  /// 返回主应用的回调
  final VoidCallback? onBackToMain;

  const ChatMainPage({super.key, this.onBackToMain});

  @override
  State<ChatMainPage> createState() => _ChatMainPageState();
}

class _ChatMainPageState extends State<ChatMainPage> {
  int _currentIndex = 0;

  // 使用 PageController 保持页面状态
  late PageController _pageController;

  // 各页面的 Bloc
  late ConversationBloc _conversationBloc;
  late ContactBloc _contactBloc;

  // iPad 分屏模式：当前选中的会话（右侧面板内容）
  ConversationEntity? _selectedConversation;
  // 为分屏模式下的右侧 ChatPage 创建独立 ChatBloc
  ChatBloc? _splitChatBloc;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _conversationBloc = getIt<ConversationBloc>();
    _contactBloc = getIt<ContactBloc>();

    // 启动链上事件推送轮询服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (getIt.isRegistered<OnChainNotificationService>()) {
        getIt<OnChainNotificationService>().start(context);
      }
    });
  }

  @override
  void dispose() {
    // 停止链上事件推送轮询服务
    if (getIt.isRegistered<OnChainNotificationService>()) {
      getIt<OnChainNotificationService>().stop();
    }
    _pageController.dispose();
    _conversationBloc.close();
    _contactBloc.close();
    _splitChatBloc?.close();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _openScanQR() {
    Navigator.of(context)
        .push<Map<String, dynamic>?>(
          MaterialPageRoute<Map<String, dynamic>?>(
            builder: (_) => const ScanQRPage(),
          ),
        )
        .then((result) {
          if (!mounted) return;
          if (result != null) {
            final roomId = result['roomId'];
            if (roomId != null) {
              _conversationBloc.add(const RefreshConversations());
            }
          }
        });
  }

  /// 显示微信风格的 "+" 弹出菜单
  void _showAddMenu(BuildContext context) {
    final isDark = context.isDarkMode;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          Offset(button.size.width - 160, 50),
          ancestor: overlay,
        ),
        button.localToGlobal(Offset(button.size.width, 50), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: isDark ? const Color(0xFF4C4C4C) : Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
        _buildPopupMenuItem(
          value: 'group',
          icon: Icons.chat_bubble_outline,
          text: S.of(context)?.mainStartGroupChat ?? 'Start Group Chat',
          isDark: isDark,
        ),
        _buildPopupMenuItem(
          value: 'add_friend',
          icon: Icons.person_add_outlined,
          text: S.of(context)?.mainAddFriends ?? 'Add Friends',
          isDark: isDark,
        ),
        _buildPopupMenuItem(
          value: 'scan',
          icon: Icons.qr_code_scanner,
          text: S.of(context)?.commonScan ?? 'Scan',
          isDark: isDark,
        ),
        _buildPopupMenuItem(
          value: 'payment',
          icon: Icons.payment_outlined,
          text: S.of(context)?.mainPaymentAndCollection ?? 'Payment',
          isDark: isDark,
        ),
      ],
    ).then((value) {
      if (!mounted) return;
      if (value == null) return;
      switch (value) {
        case 'group':
          _navigateToCreateGroup();
          break;
        case 'add_friend':
          _navigateToAddFriend();
          break;
        case 'scan':
          _openScanQR();
          break;
        case 'payment':
          _navigateToPayment();
          break;
      }
    });
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateGroup() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) =>
                      getIt<ContactBloc>()..add(const LoadContacts()),
                ),
                BlocProvider(create: (_) => getIt<GroupBloc>()),
              ],
              child: const CreateGroupPage(),
            ),
          ),
        )
        .then((_) {
          if (!mounted) return;
          _conversationBloc.add(const RefreshConversations());
        });
  }

  void _navigateToAddFriend() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const AddFriendPage()))
        .then((_) {
          if (!mounted) return;
          _conversationBloc.add(const RefreshConversations());
        });
  }

  void _navigateToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<TransferBloc>(),
          child: const ReceivePage(),
        ),
      ),
    );
  }

  void _handleBack() {
    if (widget.onBackToMain != null) {
      widget.onBackToMain!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  /// iPad 分屏模式下，选择会话后更新右侧面板
  void _onConversationSelectedForSplit(ConversationEntity conversation) async {
    // Check if chat is locked
    final lockService = ChatLockService();
    final isLocked = await lockService.isChatLocked(conversation.id);

    if (isLocked && mounted) {
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ChatLockPage(
            roomId: conversation.id,
            chatName: conversation.name,
          ),
        ),
      );
      if (verified != true || !mounted) return;
    }

    if (!mounted) return;

    setState(() {
      _selectedConversation = conversation;
      // 每次切换会话都创建新的 ChatBloc
      _splitChatBloc?.close();
      _splitChatBloc = getIt<ChatBloc>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final useSplit = ResponsiveUtils.useSplitLayout(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _conversationBloc),
        BlocProvider.value(value: _contactBloc),
      ],
      child: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, conversationState) {
          final totalUnread = conversationState.totalUnreadCount;

          final l10n = S.of(context);
          String currentTitle;
          switch (_currentIndex) {
            case 0:
              currentTitle = totalUnread > 0
                  ? (l10n?.mainMessagesWithCount(totalUnread) ??
                        'Messages($totalUnread)')
                  : (l10n?.commonMessages ?? 'Messages');
              break;
            case 1:
              currentTitle = l10n?.commonContacts ?? 'Contacts';
              break;
            case 2:
              currentTitle = l10n?.commonDiscover ?? 'Discover';
              break;
            case 3:
              currentTitle = l10n?.commonMe ?? 'Me';
              break;
            default:
              currentTitle = l10n?.commonMessages ?? 'Messages';
          }

          if (useSplit) {
            // === iPad / 宽屏分屏模式 ===
            return _buildSplitLayout(
              isDark: isDark,
              bgColor: bgColor,
              textColor: textColor,
              totalUnread: totalUnread,
              currentTitle: currentTitle,
            );
          }

          // === 手机模式：保持原有布局 ===
          return Scaffold(
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.background,
            appBar: AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
                onPressed: _handleBack,
              ),
              title: Text(
                currentTitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: [
                if (_currentIndex == 0) ...[
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: textColor,
                        size: 22,
                      ),
                      onPressed: () => _showAddMenu(ctx),
                    ),
                  ),
                ],
                if (_currentIndex == 1)
                  IconButton(
                    icon: Icon(
                      Icons.person_add_outlined,
                      color: textColor,
                      size: 22,
                    ),
                    onPressed: _navigateToAddFriend,
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ChatTabContent(
                  conversationBloc: _conversationBloc,
                  contactBloc: _contactBloc,
                ),
                const _ContactTabContent(),
                const _DiscoverTabContent(),
                const _ProfileTabContent(),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(isDark, totalUnread),
          );
        },
      ),
    );
  }

  /// iPad 分屏布局
  Widget _buildSplitLayout({
    required bool isDark,
    required Color bgColor,
    required Color textColor,
    required int totalUnread,
    required String currentTitle,
  }) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Row(
        children: [
          // --- 左侧面板：会话列表 + Tab 切换 ---
          SizedBox(
            width: ResponsiveUtils.getChatListWidth(context),
            child: Column(
              children: [
                // 左侧面板的 AppBar
                AppBar(
                  backgroundColor: bgColor,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: textColor,
                      size: 20,
                    ),
                    onPressed: _handleBack,
                  ),
                  title: Text(
                    currentTitle,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    if (_currentIndex == 0)
                      Builder(
                        builder: (ctx) => IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: textColor,
                            size: 20,
                          ),
                          onPressed: () => _showAddMenu(ctx),
                        ),
                      ),
                    if (_currentIndex == 1)
                      IconButton(
                        icon: Icon(
                          Icons.person_add_outlined,
                          color: textColor,
                          size: 20,
                        ),
                        onPressed: _navigateToAddFriend,
                      ),
                    const SizedBox(width: 4),
                  ],
                ),
                // 左侧面板内容
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _ChatTabContentSplit(
                        conversationBloc: _conversationBloc,
                        contactBloc: _contactBloc,
                        selectedConversation: _selectedConversation,
                        onConversationTap: _onConversationSelectedForSplit,
                      ),
                      const _ContactTabContent(),
                      const _DiscoverTabContent(),
                      const _ProfileTabContent(),
                    ],
                  ),
                ),
                // 底部导航栏
                _buildBottomNavigationBar(isDark, totalUnread),
              ],
            ),
          ),
          // 分隔线
          VerticalDivider(
            width: 1,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          // --- 右侧面板：聊天内容或空状态 ---
          Expanded(child: _buildRightPanel(isDark)),
        ],
      ),
    );
  }

  /// 右侧面板：如果有选中会话则显示 ChatPage，否则显示占位
  Widget _buildRightPanel(bool isDark) {
    if (_selectedConversation == null || _splitChatBloc == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context)?.commonMessages ?? 'Select a conversation',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _splitChatBloc!),
        BlocProvider.value(value: _contactBloc),
      ],
      child: ChatPage(
        key: ValueKey(_selectedConversation!.id),
        conversation: _selectedConversation!,
        // 分屏模式下不需要返回按钮
        onBack: null,
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark, int totalUnread) {
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    const selectedColor = Color(0xFF07C160);
    final unselectedColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.dividerDark : AppColors.divider)
                .withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Builder(
            builder: (ctx) {
              final l10n = S.of(ctx);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabItem(
                    index: 0,
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: l10n?.commonMessages ?? 'Messages',
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                    badge: totalUnread,
                  ),
                  _buildTabItem(
                    index: 1,
                    icon: Icons.contacts_outlined,
                    activeIcon: Icons.contacts,
                    label: l10n?.commonContacts ?? 'Contacts',
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  _buildTabItem(
                    index: 2,
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                    label: l10n?.commonDiscover ?? 'Discover',
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  _buildTabItem(
                    index: 3,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: l10n?.commonMe ?? 'Me',
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color selectedColor,
    required Color unselectedColor,
    int badge = 0,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? selectedColor : unselectedColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 动画选中背景胶囊
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: isSelected ? 44 : 0,
                  height: isSelected ? 28 : 0,
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                // 图标 + badge 叠加
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? activeIcon : icon,
                      color: color,
                      size: 24,
                    ),
                    if (badge > 0)
                      Positioned(
                        right: -10,
                        top: -6,
                        child: _buildBadge(badge),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建未读徽章（微信风格：无白边）
  Widget _buildBadge(int count) {
    String displayText;
    if (count > 999) {
      displayText = '...';
    } else if (count > 99) {
      displayText = '99+';
    } else {
      displayText = '$count';
    }

    double minWidth;
    if (displayText.length > 2) {
      minWidth = 24;
    } else if (displayText.length > 1) {
      minWidth = 20;
    } else {
      minWidth = 16;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      constraints: BoxConstraints(minWidth: minWidth, minHeight: 16),
      decoration: BoxDecoration(
        color: AppColors.badge,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          displayText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================
// 各 Tab 的内容 Widget（不带 AppBar）
// ============================================

/// 聊天 Tab 内容 — 手机模式（点击 push 到 ChatPage）
class _ChatTabContent extends StatelessWidget {
  final ConversationBloc conversationBloc;
  final ContactBloc contactBloc;

  const _ChatTabContent({
    required this.conversationBloc,
    required this.contactBloc,
  });

  void _navigateToChat(
    BuildContext context,
    ConversationEntity conversation,
  ) async {
    // Check if chat is locked
    final lockService = ChatLockService();
    final isLocked = await lockService.isChatLocked(conversation.id);

    if (isLocked && context.mounted) {
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ChatLockPage(
            roomId: conversation.id,
            chatName: conversation.name,
          ),
        ),
      );
      if (verified != true || !context.mounted) return;
    }

    if (!context.mounted) return;

    unawaited(
      Navigator.of(context)
          .push(
            MaterialPageRoute<void>(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => getIt<ChatBloc>()),
                  BlocProvider.value(value: contactBloc),
                ],
                child: ChatPage(
                  conversation: conversation,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          )
          .then((_) {
            if (!context.mounted) return;
            conversationBloc.add(const RefreshConversations());
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: conversationBloc,
      child: ConversationListPage(
        onConversationTap: (conversation) =>
            _navigateToChat(context, conversation),
        onSearchTap: () {
          debugLog('Open search');
        },
        showAppBar: false,
      ),
    );
  }
}

/// 聊天 Tab 内容 — iPad 分屏模式（点击更新右侧面板）
class _ChatTabContentSplit extends StatelessWidget {
  final ConversationBloc conversationBloc;
  final ContactBloc contactBloc;
  final ConversationEntity? selectedConversation;
  final void Function(ConversationEntity) onConversationTap;

  const _ChatTabContentSplit({
    required this.conversationBloc,
    required this.contactBloc,
    required this.selectedConversation,
    required this.onConversationTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: conversationBloc,
      child: ConversationListPage(
        onConversationTap: onConversationTap,
        selectedConversationId: selectedConversation?.id,
        onSearchTap: () {
          debugLog('Open search');
        },
        showAppBar: false,
      ),
    );
  }
}

/// 通讯录 Tab 内容
class _ContactTabContent extends StatelessWidget {
  const _ContactTabContent();

  @override
  Widget build(BuildContext context) {
    return const ContactListPage(showAppBar: false);
  }
}

/// 发现 Tab 内容
class _DiscoverTabContent extends StatelessWidget {
  const _DiscoverTabContent();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MomentBloc>()..add(const LoadMoments(limit: 1)),
      child: const DiscoverPage(showAppBar: false),
    );
  }
}

/// 我 Tab 内容
class _ProfileTabContent extends StatelessWidget {
  const _ProfileTabContent();

  @override
  Widget build(BuildContext context) {
    return const ProfilePage(showAppBar: false);
  }
}
