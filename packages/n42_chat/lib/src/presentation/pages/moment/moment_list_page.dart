import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/moment_entity.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/moment/moment_bloc.dart';
import '../../blocs/moment/moment_event.dart';
import '../../blocs/moment/moment_state.dart';
import '../../widgets/common/n42_avatar.dart';
import '../chat/viewers/video_player_page.dart';
import 'create_moment_page.dart';
import 'moment_forward_sheet.dart';
import '../../../core/utils/debug_log.dart';

/// 朋友圈列表页面
class MomentListPage extends StatelessWidget {
  /// 查看特定用户的朋友圈时传入
  final String? userId;
  final String? userName;
  final String? userAvatarUrl;

  const MomentListPage({
    super.key,
    this.userId,
    this.userName,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<MomentBloc>();
        if (userId != null) {
          bloc.add(LoadUserMoments(userId!));
        } else {
          bloc.add(const LoadMoments());
        }
        return bloc;
      },
      child: _MomentListView(
        userId: userId,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
      ),
    );
  }
}

class _MomentListView extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userAvatarUrl;

  const _MomentListView({this.userId, this.userName, this.userAvatarUrl});

  @override
  State<_MomentListView> createState() => _MomentListViewState();
}

class _MomentListViewState extends State<_MomentListView> {
  final ScrollController _scrollController = ScrollController();
  String? _myDisplayName;
  String? _myAvatarUrl;
  bool _isActionMenuVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (!_isUserMode) {
      _loadMyProfile();
    }
  }

  Future<void> _loadMyProfile() async {
    try {
      final client = MatrixClientManager.instance.client;
      if (client != null && client.isLogged()) {
        final userId = client.userID;
        if (userId != null) {
          final profile = await client.getUserProfile(userId);
          if (mounted) {
            setState(() {
              _myDisplayName = profile.displayname;
              _myAvatarUrl = profile.avatarUrl?.toString();
            });
          }
        }
      }
    } catch (e) {
      debugLog('Failed to load my profile for moments: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isUserMode => widget.userId != null;

  String _getCurrentUserId() {
    return MatrixClientManager.instance.client?.userID ?? '';
  }

  String _getCurrentUserName() {
    // 优先使用从 profile 获取的真实显示名
    if (_myDisplayName != null && _myDisplayName!.isNotEmpty) {
      return _myDisplayName!;
    }
    // 后备：从 userId 提取 localpart
    final client = MatrixClientManager.instance.client;
    if (client == null) return '';
    final userId = client.userID ?? '';
    return userId.startsWith('@')
        ? userId.substring(1).split(':').first
        : userId;
  }

  Set<String> _getFriendIds() {
    final contactBloc = context.read<ContactBloc?>();
    if (contactBloc == null) {
      return {};
    }
    try {
      final contactState = contactBloc.state;
      if (contactState.isLoaded) {
        return contactState.contacts.map((c) => c.userId).toSet();
      }
    } catch (e) {
      debugLog('Error: $e');
    }
    return {};
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MomentBloc>().add(LoadMoreMoments(userId: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 顶部封面和头像
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildCoverSection(context, isDark),
            ),
            title: Text(
              _isUserMode
                  ? (s?.momentUserMoments(widget.userName ?? '') ??
                        '${widget.userName}\'s Moments')
                  : (s?.commonMoments ?? 'Moments'),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            actions: [
              if (!_isUserMode)
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () => _openCreateMoment(context),
                ),
            ],
          ),

          // 动态列表
          BlocBuilder<MomentBloc, MomentState>(
            builder: (context, state) {
              if (state.isLoading && state.moments.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.moments.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s?.momentNoMomentsYet ?? 'No moments yet',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= state.moments.length) {
                    if (state.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  return _MomentTile(
                    moment: state.moments[index],
                    isDark: isDark,
                    friendIds: _getFriendIds(),
                    currentUserId: _getCurrentUserId(),
                    onActionMenuVisibilityChanged: _isUserMode
                        ? null
                        : (visible) {
                            if (!mounted || _isActionMenuVisible == visible) {
                              return;
                            }
                            setState(() {
                              _isActionMenuVisible = visible;
                            });
                          },
                  );
                }, childCount: state.moments.length + (state.hasMore ? 1 : 0)),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _isUserMode || _isActionMenuVisible
          ? null
          : FloatingActionButton(
              onPressed: () => _openCreateMoment(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildCoverSection(BuildContext context, bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 封面图片
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF2C3E50), const Color(0xFF1A252F)]
                  : [const Color(0xFF667eea), const Color(0xFF764ba2)],
            ),
          ),
        ),

        // 用户信息
        Positioned(
          right: 16,
          bottom: 50,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _isUserMode
                        ? (widget.userName ?? '')
                        : _getCurrentUserName(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: N42Avatar(
                  name: _isUserMode
                      ? (widget.userName ?? '')
                      : _getCurrentUserName(),
                  imageUrl: _isUserMode ? widget.userAvatarUrl : _myAvatarUrl,
                  size: 64,
                  borderRadius: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openCreateMoment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<MomentBloc>(),
          child: const CreateMomentPage(),
        ),
      ),
    );
  }
}

/// 单条动态组件
class _MomentTile extends StatelessWidget {
  final MomentEntity moment;
  final bool isDark;
  final Set<String> friendIds;
  final String currentUserId;
  final ValueChanged<bool>? onActionMenuVisibilityChanged;

  const _MomentTile({
    required this.moment,
    required this.isDark,
    required this.friendIds,
    required this.currentUserId,
    this.onActionMenuVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          N42Avatar(
            name: moment.userName,
            imageUrl: moment.userAvatarUrl,
            size: 44,
          ),

          const SizedBox(width: 12),

          // 内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名
                Text(
                  moment.userName,
                  style: TextStyle(
                    color: isDark ? Colors.blue[300] : Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                // 文字内容
                if (moment.hasContent) ...[
                  Text(
                    moment.content!,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // 媒体内容
                if (moment.hasMedia) ...[
                  _buildMediaGrid(context),
                  const SizedBox(height: 8),
                ],

                // 位置信息
                if (moment.hasLocation) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        moment.location!.displayText,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // 时间、可见性图标和操作
                Row(
                  children: [
                    Text(
                      moment.formattedTime,
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    // 自己的动态显示可见性状态（非公开时显示图标，微信风格）
                    if (moment.isFromMe &&
                        moment.visibility != MomentVisibility.public) ...[
                      const SizedBox(width: 4),
                      _buildVisibilityBadge(context),
                    ],
                    const Spacer(),
                    _buildInteractionBar(context),
                  ],
                ),

                // 点赞和评论（已在方法内部做可见性过滤）
                if (moment.likeCount > 0 || moment.commentCount > 0) ...[
                  const SizedBox(height: 8),
                  _buildLikesAndComments(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context) {
    final mediaCount = moment.media.length;

    // 微信风格：1张大图特殊处理
    if (mediaCount == 1) {
      return _buildSingleMedia(context, moment.media.first, 0);
    }

    // 微信风格网格：2/4 用 2 列，其他用 3 列
    final crossAxisCount = mediaCount <= 4 ? 2 : 3;
    final displayCount = mediaCount > 9 ? 9 : mediaCount;

    // 计算约束宽度（微信风格：不超过屏幕宽度的 2/3）
    final maxGridWidth = MediaQuery.of(context).size.width * 0.65;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxGridWidth),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: displayCount,
        itemBuilder: (context, index) {
          final media = moment.media[index];
          return GestureDetector(
            onTap: () => _openMediaViewer(context, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildMediaThumbnail(media),
                  if (media.isVideo)
                    const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ),
                  if (index == 8 && mediaCount > 9)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          '+${mediaCount - 9}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 单张图片/视频的特殊布局（微信风格：大图，宽度不超过 2/3 屏幕）
  Widget _buildSingleMedia(BuildContext context, MomentMedia media, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.65;
    final maxHeight = screenWidth * 0.65;

    // 计算合适的尺寸
    double width = maxWidth;
    double height = maxWidth;
    if (media.width != null && media.height != null && media.height! > 0) {
      final ratio = media.width! / media.height!;
      if (ratio > 1) {
        // 横图
        width = maxWidth;
        height = maxWidth / ratio;
      } else {
        // 竖图
        height = maxHeight;
        width = maxHeight * ratio;
      }
      width = width.clamp(100.0, maxWidth);
      height = height.clamp(100.0, maxHeight);
    }

    return GestureDetector(
      onTap: () => _openMediaViewer(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildMediaThumbnail(media),
              if (media.isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.white70,
                    size: 48,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建媒体缩略图（图片或视频缩略图）
  Widget _buildMediaThumbnail(MomentMedia media) {
    if (media.isVideo) {
      if (media.thumbnailUrl != null) {
        return CachedNetworkImage(
          imageUrl: media.thumbnailUrl!,
          fit: BoxFit.cover,
          httpHeaders: _getAuthHeaders(),
          placeholder: (_, _) =>
              Container(color: isDark ? Colors.grey[850] : Colors.grey[800]),
          errorWidget: (_, _, _) =>
              Container(color: isDark ? Colors.grey[850] : Colors.grey[800]),
        );
      }
      return Container(color: isDark ? Colors.grey[850] : Colors.grey[800]);
    }

    if (media.httpUrl != null) {
      return CachedNetworkImage(
        imageUrl: media.httpUrl!,
        fit: BoxFit.cover,
        httpHeaders: _getAuthHeaders(),
        placeholder: (_, _) =>
            Container(color: isDark ? Colors.grey[800] : Colors.grey[200]),
        errorWidget: (_, _, _) => const Icon(Icons.image),
      );
    }

    return const Icon(Icons.image);
  }

  /// 可见性角标（仅自己动态的非公开状态，微信风格）
  Widget _buildVisibilityBadge(BuildContext context) {
    final s = S.of(context);
    switch (moment.visibility) {
      case MomentVisibility.private:
        return Tooltip(
          message: s?.momentVisibilityPrivate ?? 'Private',
          child: Icon(
            Icons.lock_outline,
            size: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
        );
      case MomentVisibility.partial:
        return Tooltip(
          message: s?.momentVisibilityPartial ?? 'Selected Friends',
          child: Icon(
            Icons.group_outlined,
            size: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
        );
      case MomentVisibility.excluded:
        return Tooltip(
          message: s?.momentVisibilityExcluded ?? 'Exclude Some Friends',
          child: Icon(
            Icons.person_off_outlined,
            size: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[500],
          ),
        );
      case MomentVisibility.public:
        return const SizedBox.shrink();
    }
  }

  /// 交互栏（微信风格：点击 "..." 弹出操作面板）
  Widget _buildInteractionBar(BuildContext context) {
    return Builder(
      builder: (buttonContext) => GestureDetector(
        onTap: () => _showActionPopup(context, buttonContext),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.more_horiz,
            size: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  List<_MomentActionItem> _buildActionItems(
    BuildContext context,
    BuildContext dialogContext,
  ) {
    final items = <_MomentActionItem>[
      _MomentActionItem(
        icon: moment.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
        label: moment.isLikedByMe
            ? (S.of(context)?.momentUnlike ?? 'Unlike')
            : (S.of(context)?.momentLike ?? 'Like'),
        onTap: () {
          Navigator.pop(dialogContext);
          if (moment.isLikedByMe) {
            context.read<MomentBloc>().add(UnlikeMoment(moment.id));
          } else {
            context.read<MomentBloc>().add(LikeMoment(moment.id));
          }
        },
      ),
      _MomentActionItem(
        icon: Icons.chat_bubble_outline,
        label: S.of(context)?.momentComment ?? 'Comment',
        onTap: () {
          Navigator.pop(dialogContext);
          _showCommentDialog(context);
        },
      ),
      _MomentActionItem(
        icon: Icons.share_outlined,
        label: S.of(context)?.momentForward ?? 'Forward',
        onTap: () {
          Navigator.pop(dialogContext);
          MomentForwardSheet.show(context, moment);
        },
      ),
    ];

    if (moment.isFromMe) {
      items.add(
        _MomentActionItem(
          icon: Icons.delete_outline,
          label: S.of(context)?.momentDelete ?? 'Delete',
          onTap: () {
            Navigator.pop(dialogContext);
            _showDeleteConfirmation(context);
          },
        ),
      );
    }

    return items;
  }

  /// 微信风格的操作弹出栏
  void _showActionPopup(BuildContext context, BuildContext anchorContext) {
    final renderObject = anchorContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final position = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    final screenSize = MediaQuery.of(context).size;
    final topInset = MediaQuery.of(context).padding.top;
    final top = (position.dy + (size.height / 2) - 22.0)
        .clamp(topInset + 8.0, screenSize.height - 56.0)
        .toDouble();
    final right = (screenSize.width - position.dx - size.width)
        .clamp(12.0, screenSize.width - 12.0)
        .toDouble();
    final maxPopupWidth = (position.dx + size.width - 12.0)
        .clamp(180.0, screenSize.width - 24.0)
        .toDouble();

    onActionMenuVisibilityChanged?.call(true);
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        final actions = _buildActionItems(context, ctx);
        return Stack(
          children: [
            // 点击空白区域关闭
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(color: Colors.transparent),
              ),
            ),
            // 操作面板定位在 "..." 按钮左侧
            Positioned(
              right: right,
              top: top,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxPopupWidth),
                child: Material(
                  borderRadius: BorderRadius.circular(6),
                  color: isDark
                      ? const Color(0xFF4A4A4A)
                      : const Color(0xFF4C4C4C),
                  elevation: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < actions.length; i++) ...[
                        _buildPopupAction(
                          ctx,
                          icon: actions[i].icon,
                          label: actions[i].label,
                          onTap: actions[i].onTap,
                        ),
                        if (i != actions.length - 1)
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.white24,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      onActionMenuVisibilityChanged?.call(false);
    });
  }

  Widget _buildPopupAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikesAndComments(BuildContext context) {
    final visibleLikes = moment.getVisibleLikes(
      currentUserId: currentUserId,
      friendIds: friendIds,
    );
    final visibleComments = moment.getVisibleComments(
      currentUserId: currentUserId,
      friendIds: friendIds,
    );

    if (visibleLikes.isEmpty && visibleComments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 点赞列表
          if (visibleLikes.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 14,
                  color: isDark ? Colors.red[300] : Colors.red,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    visibleLikes.map((l) => l.userName).join(', '),
                    style: TextStyle(
                      color: isDark ? Colors.blue[300] : Colors.blue[700],
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (visibleComments.isNotEmpty)
              Divider(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                height: 16,
              ),
          ],

          // 评论列表
          ...visibleComments.map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: comment.userName,
                      style: TextStyle(
                        color: isDark ? Colors.blue[300] : Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (comment.isReply) ...[
                      TextSpan(
                        text: ' ${S.of(context)?.momentReply ?? 'reply'} ',
                      ),
                      TextSpan(
                        text: comment.replyToUserName,
                        style: TextStyle(
                          color: isDark ? Colors.blue[300] : Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    TextSpan(text: ': ${comment.content}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getAuthHeaders() {
    final accessToken = MatrixClientManager.instance.client?.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      return {'Authorization': 'Bearer $accessToken'};
    }
    return {};
  }

  void _openMediaViewer(BuildContext context, int index) {
    if (index >= moment.media.length) return;
    final media = moment.media[index];

    if (media.httpUrl == null) return;

    if (media.isVideo) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VideoPlayerPage(
            videoUrl: media.httpUrl!,
            thumbnailUrl: media.thumbnailUrl,
          ),
        ),
      );
    } else {
      // 收集所有图片 URL 用于多图浏览
      final imageUrls = <String>[];
      final indexMapping = <int, int>{};
      var mappedIndex = 0;
      for (var i = 0; i < moment.media.length; i++) {
        if (!moment.media[i].isVideo && moment.media[i].httpUrl != null) {
          imageUrls.add(moment.media[i].httpUrl!);
          indexMapping[i] = mappedIndex;
          mappedIndex++;
        }
      }

      final initialPage = indexMapping[index] ?? 0;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _MomentImageGalleryPage(
            imageUrls: imageUrls,
            initialIndex: initialPage,
            momentId: moment.id,
          ),
        ),
      );
    }
  }

  void _showCommentDialog(BuildContext context) {
    final momentBloc = context.read<MomentBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider<MomentBloc>.value(
        value: momentBloc,
        child: _MomentCommentDialog(momentId: moment.id),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final momentBloc = context.read<MomentBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider<MomentBloc>.value(
        value: momentBloc,
        child: _MomentDeleteDialog(momentId: moment.id),
      ),
    );
  }
}

class _MomentActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MomentActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _MomentCommentDialog extends StatefulWidget {
  final String momentId;

  const _MomentCommentDialog({required this.momentId});

  @override
  State<_MomentCommentDialog> createState() => _MomentCommentDialogState();
}

class _MomentCommentDialogState extends State<_MomentCommentDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    context.read<MomentBloc>().add(
      CommentMoment(momentId: widget.momentId, content: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<MomentBloc, MomentState>(
      listenWhen: (previous, current) =>
          _isSubmitting &&
          previous.commentSubmissionVersion != current.commentSubmissionVersion,
      listener: (context, state) {
        if (state.commentSubmissionMomentId != widget.momentId) {
          return;
        }
        if (state.commentSubmissionStatus ==
            MomentCommentSubmissionStatus.success) {
          setState(() {
            _isSubmitting = false;
          });
          Navigator.of(context).pop();
          return;
        }
        if (state.commentSubmissionStatus ==
            MomentCommentSubmissionStatus.failure) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? (s?.commonRetry ?? 'Retry')),
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(s?.momentComment ?? 'Comment'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 3,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: s?.momentWriteComment ?? 'Write a comment...',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text(s?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s?.commonSend ?? 'Send'),
          ),
        ],
      ),
    );
  }
}

class _MomentDeleteDialog extends StatefulWidget {
  final String momentId;

  const _MomentDeleteDialog({required this.momentId});

  @override
  State<_MomentDeleteDialog> createState() => _MomentDeleteDialogState();
}

class _MomentDeleteDialogState extends State<_MomentDeleteDialog> {
  bool _isDeleting = false;

  void _delete() {
    if (_isDeleting) {
      return;
    }
    setState(() {
      _isDeleting = true;
    });
    context.read<MomentBloc>().add(DeleteMoment(widget.momentId));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<MomentBloc, MomentState>(
      listenWhen: (previous, current) =>
          _isDeleting &&
          previous.deleteActionVersion != current.deleteActionVersion,
      listener: (context, state) {
        if (state.deleteActionMomentId != widget.momentId) {
          return;
        }
        if (state.deleteActionStatus == MomentDeleteActionStatus.success) {
          setState(() {
            _isDeleting = false;
          });
          Navigator.of(context).pop();
          return;
        }
        if (state.deleteActionStatus == MomentDeleteActionStatus.failure) {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? (s?.commonRetry ?? 'Retry')),
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(s?.momentDeleteMoment ?? 'Delete Moment'),
        content: Text(
          s?.momentDeleteConfirm ??
              'Are you sure you want to delete this moment?',
        ),
        actions: [
          TextButton(
            onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
            child: Text(s?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: _isDeleting ? null : _delete,
            child: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    s?.commonDelete ?? 'Delete',
                    style: const TextStyle(color: Colors.red),
                  ),
          ),
        ],
      ),
    );
  }
}

/// 朋友圈多图全屏浏览页面（微信风格：滑动切换）
class _MomentImageGalleryPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String momentId;

  const _MomentImageGalleryPage({
    required this.imageUrls,
    required this.initialIndex,
    required this.momentId,
  });

  @override
  State<_MomentImageGalleryPage> createState() =>
      _MomentImageGalleryPageState();
}

class _MomentImageGalleryPageState extends State<_MomentImageGalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, String> _getAuthHeaders() {
    final accessToken = MatrixClientManager.instance.client?.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      return {'Authorization': 'Bearer $accessToken'};
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: widget.imageUrls.length > 1
            ? Text(
                '${_currentIndex + 1}/${widget.imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : null,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: 'moment_media_${widget.momentId}_$index',
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                    httpHeaders: _getAuthHeaders(),
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: (_, _, _) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          S.of(context)?.momentFailedToLoad ??
                              'Failed to load image',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
