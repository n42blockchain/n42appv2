import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../domain/repositories/message_repository.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_event.dart';
import '../../blocs/contact/contact_state.dart';
import '../../blocs/group/group_bloc.dart';
import '../../blocs/group/group_event.dart';
import '../../blocs/group/group_state.dart';
import '../../widgets/common/common_widgets.dart';
import '../chat/chat_page.dart';
import '../contact/chat_only_friends_page.dart';
import '../contact/enterprise_contacts_page.dart';
import '../contact/official_accounts_page.dart';
import '../contact/service_accounts_page.dart';
import '../contact/tags_management_page.dart';
import '../group/create_group_page.dart';
import '../../../n42_chat.dart';
import 'contact_tile.dart';
import '../../../core/utils/debug_log.dart';

/// 通讯录页面（仿微信）
class ContactListPage extends StatefulWidget {
  /// 是否显示 AppBar（嵌入到主框架时可设为 false）
  final bool showAppBar;

  const ContactListPage({super.key, this.showAppBar = true});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, GlobalKey> _letterKeys = {};

  late final GroupBloc _groupBloc;

  @override
  void initState() {
    super.initState();
    context.read<ContactBloc>().add(const LoadContacts());
    _groupBloc = getIt<GroupBloc>();
    // Load groups first, which will also load invites
    _groupBloc.add(const LoadGroups());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onLetterTap(String letter) {
    final key = _letterKeys[letter];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<ContactBloc>().add(const ClearSearch());
    } else {
      context.read<ContactBloc>().add(SearchContacts(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bgColor = context.pageBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.showAppBar
          ? N42AppBar(
              title: S.of(context)?.commonContacts ?? 'Contacts',
              showBackButton: false,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.person_add_outlined,
                    color: context.textPrimary,
                  ),
                  onPressed: _showAddContactDialog,
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // 搜索栏（始终显示）
          _buildSearchBar(isDark),

          // 联系人列表
          Expanded(
            child: BlocConsumer<ContactBloc, ContactState>(
              listener: (context, state) {
                if (ModalRoute.of(context)?.isCurrent != true) {
                  return;
                }
                if (state.status == ContactStatus.chatStarted) {
                  final roomId = state.startedChatRoomId;
                  if (roomId == null || roomId.isEmpty) {
                    return;
                  }
                  unawaited(N42Chat.openConversation(roomId, context: context));
                } else if (state.status == ContactStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage ?? '')),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const N42Loading();
                }

                if (state.status == ContactStatus.error) {
                  return N42EmptyState(
                    icon: Icons.error_outline,
                    title: S.of(context)?.commonLoadFailed ?? 'Load failed',
                    description: state.errorMessage,
                    buttonText: S.of(context)?.commonRetry ?? 'Retry',
                    onButtonPressed: () {
                      context.read<ContactBloc>().add(const LoadContacts());
                    },
                  );
                }

                if (state.isLoaded) {
                  return _buildContactList(state, isDark);
                }

                return N42EmptyState(
                  icon: Icons.contacts_outlined,
                  title: S.of(context)?.commonNoContacts ?? 'No contacts',
                  description:
                      S.of(context)?.contactAddFriendsToChat ??
                      'Add friends to start chatting',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.inputBgOf(isDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          cursorColor: AppColors.primary,
          style: TextStyle(
            fontSize: 15,
            height: 1.3,
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: S.of(context)?.commonSearch ?? 'Search',
            hintStyle: TextStyle(
              fontSize: 15,
              height: 1.3,
              color: context.textTertiary,
            ),
            prefixIcon: Icon(
              AppIcons.search,
              size: 20,
              color: context.textTertiary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _buildContactList(ContactState state, bool isDark) {
    // 搜索模式
    if (state.searchQuery.isNotEmpty) {
      return _buildSearchResults(state, isDark);
    }

    // 准备索引字母的GlobalKey
    _letterKeys.clear();
    for (final letter in state.indexLetters) {
      _letterKeys[letter] = GlobalKey();
    }

    // 完整的索引字母列表
    final fullIndexLetters = ['🔍', '☆', ...state.indexLetters, '#'];

    return Stack(
      children: [
        // 联系人列表
        RefreshIndicator(
          onRefresh: () async {
            context.read<ContactBloc>().add(const RefreshContacts());
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 功能入口
              SliverToBoxAdapter(child: _buildFunctionEntries(state, isDark)),

              // 按字母分组的联系人
              for (final letter in state.indexLetters) ...[
                // 字母标题
                SliverToBoxAdapter(
                  key: _letterKeys[letter],
                  child: _buildLetterHeader(letter, isDark),
                ),
                // 该字母下的联系人
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final contacts = state.groupedContacts[letter]!;
                    return Column(
                      children: [
                        ContactTile(
                          contact: contacts[index],
                          onTap: () => _onContactTap(contacts[index]),
                          onLongPress: () => _showContactMenu(contacts[index]),
                        ),
                        if (index < contacts.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 72),
                            child: Divider(
                              height: 1,
                              color: context.dividerColor,
                            ),
                          ),
                      ],
                    );
                  }, childCount: state.groupedContacts[letter]?.length ?? 0),
                ),
              ],

              // 底部统计
              SliverToBoxAdapter(
                child: _buildFooter(state.contacts.length, isDark),
              ),
            ],
          ),
        ),

        // 右侧字母索引条
        Positioned(
          right: 2,
          top: 0,
          bottom: 50,
          child: _WeChatIndexBar(
            letters: fullIndexLetters,
            onLetterTap: (letter) {
              if (letter == '🔍') {
                _searchController.clear();
                FocusScope.of(context).unfocus();
              } else if (letter == '☆') {
                // 滚动到顶部
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              } else {
                _onLetterTap(letter);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(ContactState state, bool isDark) {
    final localResults = state.filteredContacts;
    final globalResults = state.searchResults;

    if (localResults.isEmpty &&
        globalResults.isEmpty &&
        !state.isSearching &&
        !state.isGlobalSearching) {
      return N42EmptyState(
        icon: Icons.search_off,
        title: S.of(context)?.contactNotFound ?? 'Contact not found',
        description:
            S.of(context)?.contactTryOtherKeywords ??
            'Try other keywords or global search',
      );
    }

    return ListView(
      children: [
        // 本地搜索结果
        if (localResults.isNotEmpty) ...[
          _buildSectionHeader(
            S.of(context)?.commonContacts ?? 'Contacts',
            isDark,
          ),
          ...localResults.map(
            (contact) => ContactTile(
              contact: contact,
              onTap: () => _onContactTap(contact),
            ),
          ),
        ],

        // 正在搜索指示器
        if (state.isSearching || state.isGlobalSearching)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),

        // 全局搜索结果
        if (globalResults.isNotEmpty) ...[
          _buildSectionHeader(
            S.of(context)?.contactSearchResults ?? 'Search Results',
            isDark,
          ),
          ...globalResults.map(
            (contact) => ContactTile(
              contact: contact,
              showOnlineStatus: false,
              onTap: () => _onContactTap(contact),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFunctionEntries(ContactState state, bool isDark) {
    final surfaceColor = context.surfaceColor;

    return Container(
      color: surfaceColor,
      child: Column(
        children: [
          // 新的朋友
          _buildFunctionItem(
            isDark: isDark,
            icon: _NewFriendIcon(),
            title: S.of(context)?.contactNewFriends ?? 'New Friends',
            badgeCount: state.friendRequests.length,
            onTap: _showFriendRequestsPage,
          ),
          _buildItemDivider(isDark),

          // 仅聊天的朋友
          _buildFunctionItem(
            isDark: isDark,
            icon: _ChatOnlyFriendIcon(),
            title: S.of(context)?.contactChatOnlyFriends ?? 'Chat-only Friends',
            onTap: _openChatOnlyFriendsPage,
          ),

          const SizedBox(height: 8),
          Container(
            color: surfaceColor,
            child: Column(
              children: [
                // 群聊
                BlocBuilder<GroupBloc, GroupState>(
                  bloc: _groupBloc,
                  builder: (context, groupState) {
                    int inviteCount = 0;
                    if (groupState.status == GroupStatus.loaded) {
                      inviteCount = groupState.invites.length;
                    }
                    return _buildFunctionItem(
                      isDark: isDark,
                      icon: _GroupChatIcon(),
                      title: S.of(context)?.commonGroupChat ?? 'Group Chat',
                      badgeCount: inviteCount,
                      onTap: _showGroupsPage,
                    );
                  },
                ),
                _buildItemDivider(isDark),

                // 标签
                _buildFunctionItem(
                  isDark: isDark,
                  icon: _TagIcon(),
                  title: S.of(context)?.contactTags ?? 'Tags',
                  onTap: _openTagsManagementPage,
                ),
                _buildItemDivider(isDark),

                // 公众号
                _buildFunctionItem(
                  isDark: isDark,
                  icon: _OfficialAccountIcon(),
                  title:
                      S.of(context)?.contactOfficialAccounts ??
                      'Official Accounts',
                  onTap: _openOfficialAccountsPage,
                ),
                _buildItemDivider(isDark),

                // 服务号
                _buildFunctionItem(
                  isDark: isDark,
                  icon: _ServiceAccountIcon(),
                  title:
                      S.of(context)?.contactServiceAccounts ??
                      'Service Accounts',
                  onTap: _openServiceAccountsPage,
                ),
                _buildItemDivider(isDark),

                // 企业联系人
                _buildFunctionItem(
                  isDark: isDark,
                  icon: _EnterpriseContactIcon(),
                  title:
                      S.of(context)?.contactEnterpriseContacts ??
                      'Enterprise Contacts',
                  onTap: _openEnterpriseContactsPage,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFunctionItem({
    required bool isDark,
    required Widget icon,
    required String title,
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    final textColor = context.textPrimary;
    final bgColor = context.surfaceColor;

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 44, height: 44, child: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, height: 1.3, color: textColor),
                ),
              ),
              if (badgeCount > 0)
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
                    '$badgeCount',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
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

  Widget _buildItemDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: context.dividerColor,
      ),
    );
  }

  Widget _buildLetterHeader(String letter, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: context.pageBackground,
      child: Text(
        letter,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: context.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.pageBackground,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          height: 1.3,
          color: context.textSecondary,
        ),
      ),
    );
  }

  Widget _buildFooter(int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Text(
        S.of(context)?.contactCount(count) ?? '$count contacts',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          height: 1.3,
          color: context.textSecondary,
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context)?.commonFeatureComingSoon(feature) ??
              '$feature coming soon',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onContactTap(ContactEntity contact) {
    _startChatWithContact(contact);
  }

  void _openChatOnlyFriendsPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChatOnlyFriendsPage()),
    );
  }

  void _openTagsManagementPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const TagsManagementPage()));
  }

  void _openOfficialAccountsPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OfficialAccountsPage()),
    );
  }

  void _openServiceAccountsPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ServiceAccountsPage()),
    );
  }

  void _openEnterpriseContactsPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EnterpriseContactsPage()),
    );
  }

  /// 显示联系人操作菜单
  void _showContactMenu(ContactEntity contact) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 联系人信息头部
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    N42Avatar(
                      imageUrl: contact.avatarUrl,
                      name: contact.effectiveDisplayName,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.effectiveDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            contact.userId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.3,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 发消息
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(S.of(context)?.commonSendMessage ?? 'Message'),
                onTap: () {
                  Navigator.pop(context);
                  _startChatWithContact(contact);
                },
              ),
              // 推荐给朋友
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: Text(
                  S.of(context)?.contactRecommendToFriend ?? 'Share contact',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _recommendToFriend(contact);
                },
              ),
              // 添加到桌面
              ListTile(
                leading: const Icon(Icons.add_to_home_screen),
                title: Text(
                  S.of(context)?.contactAddToHomeScreen ?? 'Add to home screen',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon(
                    S.of(context)?.contactAddToHomeScreen ??
                        'Add to home screen',
                  );
                },
              ),
              // 设置备注
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(S.of(context)?.commonSetRemark ?? 'Set remark'),
                onTap: () {
                  Navigator.pop(context);
                  _setContactRemark(contact);
                },
              ),
              const SizedBox(height: 8),
              // 取消按钮
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(S.of(context)?.commonCancel ?? 'Cancel'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 推荐给朋友
  Future<void> _recommendToFriend(ContactEntity contact) async {
    final isDark = context.isDarkMode;

    final selectedContact = await showModalBottomSheet<ContactEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _RecommendContactSheet(excludeUserId: contact.userId, isDark: isDark),
    );

    if (selectedContact == null || !mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(S.of(context)?.contactSendingCard ?? 'Sending card...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      final contactRepository = getIt<IContactRepository>();
      final messageRepository = getIt<IMessageRepository>();
      final roomId = await contactRepository.startDirectChat(
        selectedContact.userId,
      );

      final eventId = await messageRepository.sendContactCard(
        roomId,
        userId: contact.userId,
        displayName: contact.effectiveDisplayName,
        avatarUrl: contact.avatarUrl,
      );
      if (eventId == null || eventId.isEmpty) {
        throw StateError('Failed to send contact card');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S
                      .of(context)
                      ?.contactRecommendedCardTo(
                        contact.effectiveDisplayName,
                        selectedContact.effectiveDisplayName,
                      ) ??
                  'Recommended ${contact.effectiveDisplayName}\'s card to ${selectedContact.effectiveDisplayName}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugLog('Recommend to friend error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.contactRecommendFailed(e.toString()) ??
                  'Recommend failed: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 设置联系人备注
  void _setContactRemark(ContactEntity contact) {
    final controller = TextEditingController(text: contact.remark);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.commonSetRemark ?? 'Set remark'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText:
                S.of(context)?.contactEnterRemarkName ?? 'Enter remark name',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => controller.clear(),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final remark = controller.text.trim();
              Navigator.pop(dialogContext);
              context.read<ContactBloc>().add(
                SetContactRemark(
                  contact.userId,
                  remark.isEmpty ? null : remark,
                ),
              );
            },
            child: Text(S.of(context)?.commonConfirm ?? 'OK'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  Future<void> _startChatWithContact(ContactEntity contact) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(S.of(context)?.contactOpeningChat ?? 'Opening chat...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      final contactRepository = getIt<IContactRepository>();
      final roomId = await contactRepository.startDirectChat(contact.userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final conversation = ConversationEntity(
        id: roomId,
        name: contact.effectiveDisplayName,
        avatarUrl: contact.avatarUrl,
        type: ConversationType.direct,
        lastMessage: null,
        lastMessageTime: null,
        unreadCount: 0,
      );

      final contactBloc = context.read<ContactBloc>();

      unawaited(
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (ctx) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<ChatBloc>()),
                BlocProvider.value(value: contactBloc),
              ],
              child: ChatPage(
                conversation: conversation,
                onBack: () => Navigator.of(ctx).pop(),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      debugLog('Start chat error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.contactOpenChatFailed(e.toString()) ??
                  'Open chat failed: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddContactDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.contactAddContact ?? 'Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: S.of(context)?.contactEnterUserId ?? 'Enter user ID',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  context.read<ContactBloc>().add(StartChat(value));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(S.of(context)?.commonScan ?? 'Scan'),
          ),
        ],
      ),
    );
  }

  void _showFriendRequestsPage() {
    final contactBloc = context.read<ContactBloc>();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (ctx) => BlocProvider.value(
          value: contactBloc,
          child: const _FriendRequestsPage(),
        ),
      ),
    );
  }

  void _showGroupsPage() {
    final contactBloc = context.read<ContactBloc>();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (ctx) => BlocProvider.value(
          value: contactBloc,
          child: const _GroupListPage(),
        ),
      ),
    );
  }
}

// ==================== 微信风格图标组件 ====================

/// 新的朋友图标 - 橙色背景，双人+号
class _NewFriendIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFA9D3B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(44, 44),
        painter: _NewFriendPainter(),
      ),
    );
  }
}

class _NewFriendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // 主人形
    canvas.drawCircle(Offset(cx - 4, cy - 6), 6, paint);
    final bodyPath = Path()
      ..moveTo(cx - 12, cy + 12)
      ..quadraticBezierTo(cx - 4, cy + 2, cx + 4, cy + 12);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    paint.strokeCap = StrokeCap.round;
    canvas.drawPath(bodyPath, paint);

    // 加号
    paint.strokeWidth = 2.5;
    canvas.drawLine(Offset(cx + 10, cy - 2), Offset(cx + 10, cy + 10), paint);
    canvas.drawLine(Offset(cx + 4, cy + 4), Offset(cx + 16, cy + 4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 仅聊天的朋友图标 - 橙色背景，单人
class _ChatOnlyFriendIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFA9D3B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white, size: 26),
      ),
    );
  }
}

/// 群聊图标 - 绿色背景，双人
class _GroupChatIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF57BE6A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.group, color: Colors.white, size: 26),
      ),
    );
  }
}

/// 标签图标 - 蓝色背景，标签
class _TagIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3E7FE1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(size: const Size(44, 44), painter: _TagPainter()),
    );
  }
}

class _TagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // 标签形状
    final path = Path()
      ..moveTo(cx - 10, cy - 10)
      ..lineTo(cx + 6, cy - 10)
      ..lineTo(cx + 12, cy - 4)
      ..lineTo(cx + 12, cy + 12)
      ..lineTo(cx - 10, cy + 12)
      ..close();
    canvas.drawPath(path, paint);

    // 小圆孔
    paint.color = const Color(0xFF3E7FE1);
    canvas.drawCircle(Offset(cx - 4, cy - 4), 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 公众号图标 - 蓝色背景，文档
class _OfficialAccountIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF576B95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(44, 44),
        painter: _OfficialAccountPainter(),
      ),
    );
  }
}

class _OfficialAccountPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // 文档外框
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 22, height: 26),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);

    // 横线
    canvas.drawLine(Offset(cx - 6, cy - 6), Offset(cx + 6, cy - 6), paint);
    canvas.drawLine(Offset(cx - 6, cy), Offset(cx + 6, cy), paint);
    canvas.drawLine(Offset(cx - 6, cy + 6), Offset(cx + 2, cy + 6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 服务号图标 - 红色背景，信封
class _ServiceAccountIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE64340),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(44, 44),
        painter: _ServiceAccountPainter(),
      ),
    );
  }
}

class _ServiceAccountPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // 信封外框
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 24, height: 18),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);

    // 信封V形
    final path = Path()
      ..moveTo(cx - 11, cy - 7)
      ..lineTo(cx, cy + 2)
      ..lineTo(cx + 11, cy - 7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 企业微信联系人图标 - 蓝色背景，对话框
class _EnterpriseContactIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3E7FE1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(44, 44),
        painter: _EnterpriseContactPainter(),
      ),
    );
  }
}

class _EnterpriseContactPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // 左对话框
    final leftPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 14, cy - 9, 14, 12),
          const Radius.circular(3),
        ),
      );
    canvas.drawPath(leftPath, paint);

    // 右对话框
    final rightPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + 2, cy - 3, 12, 10),
          const Radius.circular(3),
        ),
      );
    canvas.drawPath(rightPath, paint);

    // 箭头
    canvas.drawLine(Offset(cx - 6, cy + 3), Offset(cx - 6, cy + 9), paint);
    canvas.drawLine(Offset(cx + 6, cy + 7), Offset(cx + 6, cy + 11), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 微信风格字母索引条
class _WeChatIndexBar extends StatefulWidget {
  final List<String> letters;
  final ValueChanged<String> onLetterTap;

  const _WeChatIndexBar({required this.letters, required this.onLetterTap});

  @override
  State<_WeChatIndexBar> createState() => _WeChatIndexBarState();
}

class _WeChatIndexBarState extends State<_WeChatIndexBar> {
  String? _currentLetter;
  bool _isDragging = false;

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _updateLetter(details.localPosition);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _updateLetter(details.localPosition);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _currentLetter = null;
    });
  }

  void _updateLetter(Offset position) {
    if (widget.letters.isEmpty) return;

    final box = context.findRenderObject() as RenderBox;
    final itemHeight = box.size.height / widget.letters.length;
    final index = (position.dy / itemHeight).floor();

    if (index >= 0 && index < widget.letters.length) {
      final letter = widget.letters[index];
      if (letter != _currentLetter) {
        setState(() {
          _currentLetter = letter;
        });
        widget.onLetterTap(letter);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (widget.letters.isEmpty) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 字母指示器气泡
        if (_isDragging && _currentLetter != null)
          Positioned(
            right: 40,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _currentLetter!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // 索引条
        GestureDetector(
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Container(
            width: 20,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _isDragging
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.letters.map((letter) {
                final isActive = letter == _currentLetter;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onLetterTap(letter),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== 子页面组件 ====================

/// 新的朋友（好友请求）页面
class _FriendRequestsPage extends StatefulWidget {
  const _FriendRequestsPage();

  @override
  State<_FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<_FriendRequestsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)?.contactNewFriends ?? 'New Friends'),
        backgroundColor: AppColors.bgOf(isDark),
        foregroundColor: context.textPrimary,
        elevation: 0.5,
      ),
      body: BlocBuilder<ContactBloc, ContactState>(
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = state.friendRequests;

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_disabled_rounded,
                    size: 64,
                    color: context.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.contactNoFriendRequests ??
                        'No friend requests',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: requests.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              indent: 72,
              color: context.dividerColor,
            ),
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestItem(request, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestItem(FriendRequest request, bool isDark) {
    // Use userId for consistent color generation, userName for display
    final colorSource = request.userId.isNotEmpty
        ? request.userId
        : request.userName;
    final displayName = request.userName == 'Unknown User'
        ? (S.of(context)?.commonUnknownUser ?? 'Unknown User')
        : request.userName;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: _getColorFromName(colorSource),
        backgroundImage:
            request.userAvatarUrl != null && request.userAvatarUrl!.isNotEmpty
            ? NetworkImage(request.userAvatarUrl!)
            : null,
        child: request.userAvatarUrl == null || request.userAvatarUrl!.isEmpty
            ? Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          height: 1.3,
          color: context.textPrimary,
        ),
      ),
      subtitle: Text(
        request.userId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          height: 1.3,
          color: context.textSecondary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => _acceptRequest(request),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(S.of(context)?.commonAccept ?? 'Accept'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _rejectRequest(request),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.inputBgOf(isDark),
              foregroundColor: context.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(S.of(context)?.commonReject ?? 'Reject'),
          ),
        ],
      ),
    );
  }

  void _acceptRequest(FriendRequest request) {
    context.read<ContactBloc>().add(AcceptFriendRequest(request.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context)?.contactAcceptedFriendRequest(request.userName) ??
              'Accepted ${request.userName}\'s friend request',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _rejectRequest(FriendRequest request) {
    context.read<ContactBloc>().add(RejectFriendRequest(request.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context)?.contactRejectedFriendRequest(request.userName) ??
              'Rejected ${request.userName}\'s friend request',
        ),
      ),
    );
  }

  Color _getColorFromName(String name) {
    return AppColorPalettes.getAvatarColor(name);
  }
}

/// 群聊列表页面
class _GroupListPage extends StatefulWidget {
  const _GroupListPage();

  @override
  State<_GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<_GroupListPage> {
  late final GroupBloc _groupBloc;

  @override
  void initState() {
    super.initState();
    _groupBloc = getIt<GroupBloc>();
    _groupBloc.add(const LoadGroups());
  }

  @override
  void dispose() {
    _groupBloc.close();
    super.dispose();
  }

  void _navigateToCreateGroup() async {
    final contactBloc = context.read<ContactBloc>();

    final roomId = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (ctx) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _groupBloc),
            BlocProvider.value(value: contactBloc),
          ],
          child: const CreateGroupPage(),
        ),
      ),
    );

    if (roomId != null && roomId.isNotEmpty && mounted) {
      // 创建成功后，跳转到聊天页面
      _navigateToChat(roomId);
    }
  }

  void _navigateToChat(String roomId) {
    // 获取 ChatBloc
    ChatBloc? chatBloc;
    try {
      chatBloc = context.read<ChatBloc>();
    } catch (e) {
      chatBloc = getIt<ChatBloc>();
    }

    // 构建会话实体
    final conversation = ConversationEntity(
      id: roomId,
      name: '',
      type: ConversationType.group,
    );

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (ctx) => BlocProvider.value(
          value: chatBloc!,
          child: ChatPage(conversation: conversation),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: Text(S.of(context)?.commonGroupChat ?? 'Group Chat'),
        backgroundColor: AppColors.bgOf(isDark),
        foregroundColor: context.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateGroup,
          ),
        ],
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        bloc: _groupBloc,
        listener: (context, state) {
          if (state.status == GroupStatus.error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          } else if (state.status == GroupStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == GroupStatus.loaded) {
            return _buildGroupList(state, isDark);
          }

          // 初始状态或其他状态显示空状态
          return _buildEmptyState(isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: context.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context)?.commonNoGroups ?? 'No groups',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              height: 1.3,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateGroup,
            icon: const Icon(Icons.add),
            label: Text(S.of(context)?.commonCreateGroup ?? 'Create Group'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(GroupState state, bool isDark) {
    if (state.groups.isEmpty && state.invites.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _groupBloc.add(const RefreshGroups());
      },
      child: ListView(
        children: [
          // 群邀请
          if (state.invites.isNotEmpty) ...[
            _buildSectionHeader(
              S.of(context)?.commonGroupInvites ?? 'Group Invites',
              isDark,
            ),
            ...state.invites.map((invite) => _buildInviteTile(invite, isDark)),
          ],

          // 我的群聊
          if (state.groups.isNotEmpty) ...[
            _buildSectionHeader(
              '${S.of(context)?.commonMyGroups ?? "My Groups"} (${state.groups.length})',
              isDark,
            ),
            ...state.groups.map((group) => _buildGroupTile(group, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.pageBackground,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: context.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGroupTile(GroupEntity group, bool isDark) {
    return Material(
      color: context.surfaceColor,
      child: ListTile(
        leading: N42Avatar(
          imageUrl: group.avatarUrl,
          name: group.name,
          size: 48,
        ),
        title: Text(
          group.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
        subtitle: Text(
          S.of(context)?.commonMemberCount(group.memberCount) ??
              '${group.memberCount} members',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            height: 1.3,
            color: context.textSecondary,
          ),
        ),
        trailing: group.isEncrypted
            ? Icon(
                Icons.lock,
                size: 16,
                color: context.textSecondary,
              )
            : null,
        onTap: () => _navigateToChat(group.roomId),
        onLongPress: () => _showGroupOptions(group),
      ),
    );
  }

  Widget _buildInviteTile(GroupEntity group, bool isDark) {
    return Material(
      color: context.surfaceColor,
      child: ListTile(
        leading: N42Avatar(
          imageUrl: group.avatarUrl,
          name: group.name,
          size: 48,
        ),
        title: Text(
          group.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
        ),
        subtitle: Text(
          S.of(context)?.commonInvitedToJoinGroup ?? 'Invited to join group',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, height: 1.3, color: AppColors.primary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                _groupBloc.add(RejectGroupInvite(group.roomId));
              },
              child: Text(S.of(context)?.commonReject ?? 'Reject'),
            ),
            TextButton(
              onPressed: () {
                _groupBloc.add(AcceptGroupInvite(group.roomId));
              },
              child: Text(S.of(context)?.commonAccept ?? 'Accept'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupOptions(GroupEntity group) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.surfaceColor,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(S.of(context)?.commonSendMessage ?? 'Send Message'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToChat(group.roomId);
              },
            ),
            if (group.isOwner)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(
                  S.of(context)?.commonDissolveGroup ?? 'Dissolve Group',
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteGroup(group);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: AppColors.error),
                title: Text(
                  S.of(context)?.commonLeaveGroup ?? 'Leave Group',
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmLeaveGroup(group);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmLeaveGroup(GroupEntity group) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.commonLeaveGroup ?? 'Leave Group'),
        content: Text(
          '${S.of(context)?.commonConfirmLeaveGroup ?? "Are you sure you want to leave"} "${group.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _groupBloc.add(LeaveGroup(group.roomId));
            },
            child: Text(
              S.of(context)?.commonLeave ?? 'Leave',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(GroupEntity group) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.commonDissolveGroup ?? 'Dissolve Group'),
        content: Text(
          '${S.of(context)?.commonConfirmDissolveGroup ?? "Are you sure you want to dissolve"} "${group.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _groupBloc.add(DeleteGroup(group.roomId));
            },
            child: Text(
              S.of(context)?.commonDissolve ?? 'Dissolve',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 推荐联系人选择弹窗
class _RecommendContactSheet extends StatefulWidget {
  final String excludeUserId;
  final bool isDark;

  const _RecommendContactSheet({
    required this.excludeUserId,
    required this.isDark,
  });

  @override
  State<_RecommendContactSheet> createState() => _RecommendContactSheetState();
}

class _RecommendContactSheetState extends State<_RecommendContactSheet> {
  String _searchQuery = '';
  List<ContactEntity> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contactRepository = getIt<IContactRepository>();
      final contacts = await contactRepository.getContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts
              .where((c) => c.userId != widget.excludeUserId)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugLog('Failed to load contacts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ContactEntity> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    return _contacts
        .where(
          (c) =>
              c.effectiveDisplayName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              c.userId.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 顶部标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.dividerOf(widget.isDark),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context)?.contactSelectFriendToRecommend ??
                        'Select friend to recommend',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    AppIcons.close,
                    size: 22,
                    color: context.textPrimary,
                  ),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText:
                    S.of(context)?.commonSearchContacts ?? 'Search contacts',
                prefixIcon: const Icon(AppIcons.search),
                filled: true,
                fillColor: AppColors.inputBgOf(widget.isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // 联系人列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                ? Center(
                    child: Text(
                      S.of(context)?.contactNoContactsFound ??
                          'No contacts found',
                      style: TextStyle(
                        color: context.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return ListTile(
                        leading: N42Avatar(
                          imageUrl: contact.avatarUrl,
                          name: contact.effectiveDisplayName,
                          size: 44,
                        ),
                        title: Text(
                          contact.effectiveDisplayName,
                          style: TextStyle(
                            color: context.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          contact.userId,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiaryOf(widget.isDark),
                          ),
                        ),
                        onTap: () => Navigator.pop(context, contact),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
