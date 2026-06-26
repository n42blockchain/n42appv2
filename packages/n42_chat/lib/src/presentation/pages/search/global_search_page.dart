import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/search_result_entity.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/search/search_event.dart';
import '../../blocs/search/search_state.dart';
import '../../widgets/common/common_widgets.dart';
import 'search_result_tile.dart';
import 'search_message_filter_sheet.dart';
import '../../../n42_chat.dart';

/// 全局搜索页面
class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  MessageSearchFilter? _messageFilter;

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(const LoadSearchHistory());
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<SearchBloc>().add(
      PerformSearch(query, filter: _messageFilter),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const ClearSearch());
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
      _onSearch(query);
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
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchLoaded) {
            return _buildSearchResults(state);
          }

          if (state is SearchError) {
            return Center(
              child: N42EmptyState(
                icon: Icons.error_outline,
                title: S.of(context)?.searchError ?? 'Search Error',
                description: state.message,
              ),
            );
          }

          // SearchInitial
          if (state is SearchInitial) {
            return _buildSearchHistory(state);
          }

          return const SizedBox.shrink();
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
          // 返回按钮
          IconButton(
            icon: Icon(
              AppIcons.back,
              color: context.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // 搜索框
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
                  hintText:
                      S.of(context)?.searchPlaceholder ??
                      'Search contacts, groups, messages',
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
                onChanged: _onSearch,
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

  Widget _buildSearchHistory(SearchInitial state) {
    if (state.recentSearches.isEmpty) {
      return Center(
        child: N42EmptyState(
          icon: Icons.search,
          title:
              S.of(context)?.searchContactsGroupsMessages ??
              'Search contacts, groups and messages',
          description:
              S.of(context)?.searchEnterKeywordToSearch ??
              'Enter keyword to start searching',
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context)?.searchHistory ?? 'Search History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<SearchBloc>().add(const ClearSearchHistory());
              },
              child: Text(S.of(context)?.searchClearHistory ?? 'Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.recentSearches.map((query) {
            return GestureDetector(
              onTap: () {
                _searchController.text = query;
                _onSearch(query);
              },
              child: Chip(
                label: Text(query),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  context.read<SearchBloc>().add(
                    DeleteSearchHistoryItem(query),
                  );
                },
                backgroundColor: context.surfaceColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults(SearchLoaded state) {
    if (state.results.isEmpty) {
      return Center(
        child: N42EmptyState.noSearchResult(
          description:
              S.of(context)?.searchNoResultsForQuery(state.results.query) ??
              'No results found for "${state.results.query}"',
        ),
      );
    }

    return Column(
      children: [
        // 类型选择器
        _buildTypeSelector(state),
        if (state.results.messageFilter != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Message filters active: ${state.results.messageFilter!.activeCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            ),
          ),

        // 结果列表
        Expanded(child: _buildResultList(state)),
      ],
    );
  }

  Widget _buildTypeSelector(SearchLoaded state) {
    return Container(
      height: 44,
      color: context.surfaceColor,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTypeChip(
            S.of(context)?.searchAllResults ?? 'All',
            SearchResultType.all,
            state.selectedType,
            state.results.totalCount,
          ),
          _buildTypeChip(
            S.of(context)?.commonContacts ?? 'Contacts',
            SearchResultType.contact,
            state.selectedType,
            state.results.contacts.length,
          ),
          _buildTypeChip(
            S.of(context)?.searchGroups ?? 'Groups',
            SearchResultType.group,
            state.selectedType,
            state.results.groups.length,
          ),
          _buildTypeChip(
            S.of(context)?.commonMessages ?? 'Messages',
            SearchResultType.message,
            state.selectedType,
            state.results.messages.length,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    String label,
    SearchResultType type,
    SearchResultType selectedType,
    int count,
  ) {
    final isSelected = type == selectedType;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: GestureDetector(
        onTap: () {
          context.read<SearchBloc>().add(ChangeSearchType(type));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : context.pageBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : context.textPrimary,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '($count)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : context.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultList(SearchLoaded state) {
    final results = state.filteredResults;

    if (results.isEmpty) {
      return Center(
        child: N42EmptyState(
          icon: Icons.search_off,
          title: S.of(context)?.searchNoResults ?? 'No Results',
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return SearchResultTile(item: item, onTap: () => _onResultTap(item));
      },
    );
  }

  void _onResultTap(SearchResultItem item) {
    switch (item.type) {
      case SearchResultType.contact:
        N42Chat.openUserProfile(item.id, context: context);
        break;
      case SearchResultType.group:
      case SearchResultType.conversation:
        N42Chat.openConversation(item.roomId ?? item.id, context: context);
        break;
      case SearchResultType.message:
        if (item.roomId != null) {
          N42Chat.openConversation(
            item.roomId!,
            context: context,
            targetMessageId: item.id,
          );
        }
        break;
      case SearchResultType.all:
        break;
    }
  }
}
