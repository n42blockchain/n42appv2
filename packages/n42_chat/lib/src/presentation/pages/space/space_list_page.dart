import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/space_entity.dart';
import '../../blocs/space/space_bloc.dart';
import '../../blocs/space/space_event.dart';
import '../../blocs/space/space_state.dart';
import '../../widgets/common/common_widgets.dart';
import 'space_create_page.dart';
import 'space_detail_page.dart';

/// 社区/Space 列表页面
///
/// 自主加载数据（不依赖外部参数），通过 [SpaceBloc] 管理状态。
/// 展示用户已加入的所有 Space（社区）和可发现的公共 Space。
class SpaceListPage extends StatelessWidget {
  const SpaceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpaceBloc>(
      create: (_) => GetIt.I<SpaceBloc>()
        ..add(const LoadJoinedSpaces())
        ..add(const DiscoverPublicSpaces()),
      child: const _SpaceListView(),
    );
  }
}

class _SpaceListView extends StatefulWidget {
  const _SpaceListView();

  @override
  State<_SpaceListView> createState() => _SpaceListViewState();
}

class _SpaceListViewState extends State<_SpaceListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // 切换到 Discover 标签时，如果还没有结果，触发加载
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      final bloc = context.read<SpaceBloc>();
      if (bloc.state.publicSpaces.isEmpty && !bloc.state.isDiscovering) {
        bloc.add(const DiscoverPublicSpaces());
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpaceBloc, SpaceState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null && prev.errorMessage != curr.errorMessage ||
          curr.operationSuccess != null &&
              prev.operationSuccess != curr.operationSuccess,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<SpaceBloc>().add(const ClearSpaceError());
        }
        if (state.operationSuccess != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.operationSuccess!)),
          );
          context.read<SpaceBloc>().add(const ClearSpaceError());
        }
      },
      child: Scaffold(
        backgroundColor: context.pageBackground,
        appBar: N42AppBar(
          title: S.of(context)?.spacesTitle ?? 'Communities',
          showBackButton: true,
          onBackPressed: () => Navigator.pop(context),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: S.of(context)?.spacesCreate ?? 'Create Community',
              onPressed: () => _showCreateSpacePage(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: context.surfaceColor,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: context.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: S.of(context)?.spacesJoined ?? 'Joined'),
                  Tab(text: S.of(context)?.spacesDiscover ?? 'Discover'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _JoinedSpacesTab(
                    onExplore: () => _tabController.animateTo(1),
                  ),
                  _DiscoverSpacesTab(
                    searchController: _searchController,
                    onSearch: (query) {
                      context.read<SpaceBloc>().add(
                            DiscoverPublicSpaces(
                                searchQuery: query.isEmpty ? null : query),
                          );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSpacePage(BuildContext context) {
    final bloc = context.read<SpaceBloc>();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const SpaceCreatePage(),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 已加入 Space 列表标签
// ──────────────────────────────────────────────────────────────

class _JoinedSpacesTab extends StatelessWidget {
  final VoidCallback onExplore;

  const _JoinedSpacesTab({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceBloc, SpaceState>(
      buildWhen: (prev, curr) =>
          prev.joinedSpaces != curr.joinedSpaces ||
          prev.status != curr.status,
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.joinedSpaces.isEmpty) {
          return _EmptySpaceView(
            icon: Icons.groups_outlined,
            message:
                S.of(context)?.spacesNoJoined ?? 'No communities joined yet',
            actionLabel:
                S.of(context)?.spacesExplore ?? 'Explore Communities',
            onAction: onExplore,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<SpaceBloc>().add(const LoadJoinedSpaces());
          },
          child: ListView.builder(
            itemCount: state.joinedSpaces.length,
            itemBuilder: (context, index) => _SpaceListItem(
              space: state.joinedSpaces[index],
              showJoinButton: false,
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 发现 Space 列表标签
// ──────────────────────────────────────────────────────────────

class _DiscoverSpacesTab extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  const _DiscoverSpacesTab({
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceBloc, SpaceState>(
      buildWhen: (prev, curr) =>
          prev.publicSpaces != curr.publicSpaces ||
          prev.isDiscovering != curr.isDiscovering,
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: searchController,
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  hintText:
                      S.of(context)?.spacesSearch ?? 'Search communities...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            onSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.isDiscovering
                  ? const Center(child: CircularProgressIndicator())
                  : state.publicSpaces.isEmpty
                      ? _EmptySpaceView(
                          icon: Icons.explore_outlined,
                          message: S.of(context)?.spacesNoPublic ??
                              'No public communities found',
                        )
                      : ListView.builder(
                          itemCount: state.publicSpaces.length,
                          itemBuilder: (context, index) => _SpaceListItem(
                            space: state.publicSpaces[index],
                            showJoinButton: true,
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Space 列表项
// ──────────────────────────────────────────────────────────────

class _SpaceListItem extends StatelessWidget {
  final SpaceEntity space;
  final bool showJoinButton;

  const _SpaceListItem({
    required this.space,
    required this.showJoinButton,
  });

  @override
  Widget build(BuildContext context) {
    final accessToken = MatrixClientManager.instance.client?.accessToken;
    final headers = <String, String>{};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColorPalettes.getAvatarColor(space.name),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: space.avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: space.avatarUrl!,
                fit: BoxFit.cover,
                httpHeaders: headers,
                errorWidget: (_, _, _) => _buildInitialIcon(),
              )
            : _buildInitialIcon(),
      ),
      title: Text(
        space.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (space.description != null)
            Text(
              space.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
              ),
            ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.people_outline,
                  size: 14,
                  color: context.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${space.memberCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.tag,
                  size: 14,
                  color: context.textTertiary),
              const SizedBox(width: 4),
              Text(
                S.of(context)?.spacesChannelsCount(space.channelCount) ??
                    '${space.channelCount} channels',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: showJoinButton && !space.isJoined
          ? BlocBuilder<SpaceBloc, SpaceState>(
              buildWhen: (p, c) => p.isOperating != c.isOperating,
              builder: (context, state) => TextButton(
                onPressed: state.isOperating
                    ? null
                    : () => context
                        .read<SpaceBloc>()
                        .add(JoinSpace(space.id)),
                child: Text(S.of(context)?.spacesJoin ?? 'Join'),
              ),
            )
          : Icon(
              AppIcons.chevron,
              color: context.textSecondary,
            ),
      onTap: () {
        final bloc = context.read<SpaceBloc>();
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: SpaceDetailPage(spaceId: space.id),
            ),
          ),
        ).then((_) {
          // 返回后刷新列表
          if (context.mounted) {
            context.read<SpaceBloc>().add(const LoadJoinedSpaces());
          }
        });
      },
    );
  }

  Widget _buildInitialIcon() {
    return Center(
      child: Text(
        space.name.isNotEmpty ? space.name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// 空状态视图
// ──────────────────────────────────────────────────────────────

class _EmptySpaceView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptySpaceView({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 64,
              color: context.dividerColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: context.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.explore),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
