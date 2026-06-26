import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/search_result_entity.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/search/search_event.dart';
import '../../blocs/search/search_state.dart';
import '../../widgets/common/common_widgets.dart';
import 'search_message_filter_sheet.dart';
import '../../../n42_chat.dart';

/// 房间内搜索页面
class ChatSearchPage extends StatefulWidget {
  final String roomId;
  final String initialQuery;
  final bool returnSelectedMessageId;

  const ChatSearchPage({
    super.key,
    required this.roomId,
    this.initialQuery = '',
    this.returnSelectedMessageId = false,
  });

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  MessageSearchFilter? _messageFilter;

  @override
  void initState() {
    super.initState();
    final initialQuery = widget.initialQuery.trim();
    if (initialQuery.isNotEmpty) {
      _searchController.text = initialQuery;
      _searchController.selection = TextSelection.collapsed(
        offset: initialQuery.length,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNode.requestFocus();
      if (initialQuery.isNotEmpty) {
        _onSearchChanged(initialQuery);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<SearchBloc>().add(
      SearchInChat(widget.roomId, query, filter: _messageFilter),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
    context.read<SearchBloc>().add(SearchInChat(widget.roomId, ''));
    _focusNode.requestFocus();
  }

  Future<void> _showFilters() async {
    final nextFilter = await showMessageSearchFilterSheet(
      context,
      currentFilter: _messageFilter ?? const MessageSearchFilter(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _messageFilter = nextFilter);
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _onSearchChanged(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(child: _buildSearchBar()),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchError) {
            return Center(
              child: N42EmptyState(
                icon: Icons.error_outline,
                title: S.of(context)?.searchError ?? 'Search Error',
                description: state.message,
              ),
            );
          }

          if (state is ChatSearchState) {
            return _buildResults(state);
          }

          return _buildInitialState();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: context.surfaceColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              AppIcons.back,
              color: context.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: context.pageBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: S.of(context)?.chatSearchHint ?? 'Search messages',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: context.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: context.textPrimary,
                ),
                onChanged: (value) {
                  setState(() {});
                  _onSearchChanged(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.tune,
                  color: _messageFilter == null
                      ? context.textPrimary
                      : AppColors.primary,
                ),
                if (_messageFilter != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: N42EmptyState(
        icon: Icons.search,
        title: S.of(context)?.searchMessageLabel ?? 'Search Messages',
        description:
            S.of(context)?.searchEnterKeywordToSearch ??
            'Enter keyword to start searching',
      ),
    );
  }

  Widget _buildResults(ChatSearchState state) {
    final results = state.results;
    if (results.query.isEmpty) {
      return _buildInitialState();
    }

    if (results.isEmpty && !state.isSearching) {
      return Center(
        child: N42EmptyState.noSearchResult(
          title: S.of(context)?.searchNoResults ?? 'No results',
          description: 'Try different keywords',
        ),
      );
    }

    return Column(
      children: [
        if (state.isSearching) const LinearProgressIndicator(minHeight: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: context.surfaceColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${results.totalCount} ${S.of(context)?.searchMessageLabel ?? 'messages'}',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
              if (results.filter != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Filters active: ${results.filter!.activeCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: results.messages.length + (results.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => Divider(
              height: 1,
              indent: 72,
              color: context.dividerColor,
            ),
            itemBuilder: (context, index) {
              if (index >= results.messages.length) {
                return ListTile(
                  title: const Text(
                    'Load more',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.primary),
                  ),
                  onTap: state.isSearching
                      ? null
                      : () {
                          context.read<SearchBloc>().add(
                            const LoadMoreChatResults(),
                          );
                        },
                );
              }

              final message = results.messages[index];
              return _buildMessageTile(message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageTile(MessageEntity message) {
    final preview = _messagePreview(message);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      title: Row(
        children: [
          Expanded(
            child: Text(
              message.senderName.isNotEmpty
                  ? message.senderName
                  : message.senderId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat('MM-dd HH:mm').format(message.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          preview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: context.textSecondary,
          ),
        ),
      ),
      onTap: () {
        if (widget.returnSelectedMessageId) {
          Navigator.pop(context, message.id);
          return;
        }
        N42Chat.openConversation(
          widget.roomId,
          context: context,
          targetMessageId: message.id,
        );
      },
    );
  }

  String _messagePreview(MessageEntity message) {
    if (message.content.trim().isNotEmpty) {
      return message.content;
    }

    switch (message.type) {
      case MessageType.image:
        return '[Image]';
      case MessageType.video:
        return '[Video]';
      case MessageType.voice:
      case MessageType.audio:
        return '[Voice]';
      case MessageType.file:
        return '[File]';
      case MessageType.location:
        return '[Location]';
      default:
        return '[${message.type.name}]';
    }
  }
}
