import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/moment_entity.dart';
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/moment/moment_bloc.dart';
import '../../blocs/moment/moment_event.dart';
import '../../blocs/moment/moment_state.dart';
import '../../widgets/common/n42_avatar.dart';
import 'moment_forward_sheet.dart';
import '../../../core/utils/debug_log.dart';

/// 动态详情页面
class MomentDetailPage extends StatefulWidget {
  final MomentEntity moment;

  const MomentDetailPage({
    super.key,
    required this.moment,
  });

  @override
  State<MomentDetailPage> createState() => _MomentDetailPageState();
}

class _MomentDetailPageState extends State<MomentDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  String? _replyToCommentId;
  String? _replyToUserId;
  String? _replyToUserName;
  bool _isSubmittingComment = false;

  String get _currentUserId =>
      MatrixClientManager.instance.client?.userID ?? '';

  /// 从 Bloc 状态中获取最新的 moment（实时响应点赞/评论）
  MomentEntity _getLatestMoment(BuildContext context) {
    try {
      final state = context.read<MomentBloc>().state;
      final found = state.moments.where((m) => m.id == widget.moment.id).firstOrNull;
      if (found != null) return found;
    } catch (e) {
      debugLog('Error: $e');
    }
    return widget.moment;
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

  Map<String, String> _getAuthHeaders() {
    final accessToken = MatrixClientManager.instance.client?.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      return {'Authorization': 'Bearer $accessToken'};
    }
    return {};
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);

    return BlocConsumer<MomentBloc, MomentState>(
      listenWhen: (previous, current) =>
          _isSubmittingComment &&
          previous.commentSubmissionVersion != current.commentSubmissionVersion,
      listener: (context, state) {
        if (state.commentSubmissionMomentId != widget.moment.id) {
          return;
        }
        if (state.commentSubmissionStatus ==
            MomentCommentSubmissionStatus.success) {
          setState(() {
            _isSubmittingComment = false;
            _commentController.clear();
            _replyToCommentId = null;
            _replyToUserId = null;
            _replyToUserName = null;
          });
          return;
        }
        if (state.commentSubmissionStatus ==
            MomentCommentSubmissionStatus.failure) {
          setState(() {
            _isSubmittingComment = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? (s?.commonRetry ?? 'Retry')),
            ),
          );
        }
      },
      builder: (context, state) {
        // 始终从 Bloc 获取最新 moment 数据（响应点赞/评论变化）
        final moment = _getLatestMoment(context);

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
          appBar: AppBar(
            title: Text(s?.momentMoment ?? 'Moment'),
            backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => MomentForwardSheet.show(context, moment),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 动态内容
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 用户信息
                            Row(
                              children: [
                                N42Avatar(
                                  name: moment.userName,
                                  imageUrl: moment.userAvatarUrl,
                                  size: 48,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        moment.userName,
                                        style: TextStyle(
                                          color: isDark ? Colors.blue[300] : Colors.blue[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        moment.formattedTime,
                                        style: TextStyle(
                                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // 文字内容
                            if (moment.hasContent) ...[
                              const SizedBox(height: 12),
                              Text(
                                moment.content!,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ],

                            // 媒体内容
                            if (moment.hasMedia) ...[
                              const SizedBox(height: 12),
                              _buildMediaSection(isDark),
                            ],

                            // 位置信息
                            if (moment.hasLocation) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    moment.location!.displayText,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 点赞区域（可见性过滤）
                      Builder(builder: (context) {
                        final visibleLikes = moment.getVisibleLikes(
                          currentUserId: _currentUserId,
                          friendIds: _getFriendIds(),
                        );
                        if (visibleLikes.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(16),
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 18,
                                    color: isDark ? Colors.red[300] : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    s?.momentLikesCount(visibleLikes.length) ?? '${visibleLikes.length} likes',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: visibleLikes.map((like) {
                                  return Chip(
                                    avatar: N42Avatar(
                                      name: like.userName,
                                      imageUrl: like.userAvatarUrl,
                                      size: 24,
                                    ),
                                    label: Text(
                                      like.userName,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // 评论区域（可见性过滤）
                      Builder(builder: (context) {
                        final visibleComments = moment.getVisibleComments(
                          currentUserId: _currentUserId,
                          friendIds: _getFriendIds(),
                        );
                        return Container(
                          padding: const EdgeInsets.all(16),
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment,
                                    size: 18,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    s?.momentCommentsCount(visibleComments.length) ?? '${visibleComments.length} comments',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (visibleComments.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      s?.momentNoComments ?? 'No comments yet',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...visibleComments.map((comment) => _buildCommentItem(comment, isDark)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // 评论输入框
              _buildCommentInput(isDark, s, moment),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaSection(bool isDark) {
    final mediaCount = widget.moment.media.length;

    if (mediaCount == 1) {
      final media = widget.moment.media.first;
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: media.aspectRatio ?? 1.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (media.isVideo)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    if (media.thumbnailUrl != null)
                      CachedNetworkImage(
                        imageUrl: media.thumbnailUrl!,
                        fit: BoxFit.cover,
                        httpHeaders: _getAuthHeaders(),
                        placeholder: (_, _) => Container(
                          color: isDark ? Colors.grey[850] : Colors.grey[800],
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: isDark ? Colors.grey[850] : Colors.grey[800],
                        ),
                      )
                    else
                      Container(
                        color: isDark ? Colors.grey[850] : Colors.grey[800],
                      ),
                    const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white70,
                        size: 64,
                      ),
                    ),
                  ],
                )
              else if (media.httpUrl != null)
                CachedNetworkImage(
                  imageUrl: media.httpUrl!,
                  fit: BoxFit.cover,
                  httpHeaders: _getAuthHeaders(),
                  errorWidget: (_, _, _) => Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: const Icon(Icons.image, size: 48),
                  ),
                )
              else
                Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(Icons.image, size: 48),
                ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mediaCount <= 4 ? 2 : 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: mediaCount,
      itemBuilder: (context, index) {
        final media = widget.moment.media[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (media.isVideo)
                Stack(
                  fit: StackFit.expand,
                  children: [
                    if (media.thumbnailUrl != null)
                      CachedNetworkImage(
                        imageUrl: media.thumbnailUrl!,
                        fit: BoxFit.cover,
                        httpHeaders: _getAuthHeaders(),
                        placeholder: (_, _) => Container(
                          color: isDark ? Colors.grey[850] : Colors.grey[800],
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: isDark ? Colors.grey[850] : Colors.grey[800],
                        ),
                      )
                    else
                      Container(
                        color: isDark ? Colors.grey[850] : Colors.grey[800],
                      ),
                    const Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ),
                  ],
                )
              else if (media.httpUrl != null)
                CachedNetworkImage(
                  imageUrl: media.httpUrl!,
                  fit: BoxFit.cover,
                  httpHeaders: _getAuthHeaders(),
                  errorWidget: (_, _, _) => Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                )
              else
                Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  child: const Icon(Icons.image),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(MomentComment comment, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          N42Avatar(
            name: comment.userName,
            imageUrl: comment.userAvatarUrl,
            size: 36,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _setReplyTarget(comment),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.userName,
                        style: TextStyle(
                          color: isDark ? Colors.blue[300] : Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (comment.isReply) ...[
                        const Text(' ▸ '),
                        Text(
                          comment.replyToUserName ?? '',
                          style: TextStyle(
                            color: isDark ? Colors.blue[300] : Colors.blue[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comment.content,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCommentTime(comment.timestamp),
                    style: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isDark, S? s, MomentEntity moment) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          // 点赞按钮
          IconButton(
            onPressed: () {
              final bloc = context.read<MomentBloc>();
              if (moment.isLikedByMe) {
                bloc.add(UnlikeMoment(moment.id));
              } else {
                bloc.add(LikeMoment(moment.id));
              }
            },
            icon: Icon(
              moment.isLikedByMe ? Icons.favorite : Icons.favorite_border,
              color: moment.isLikedByMe ? Colors.red : null,
            ),
          ),

          // 评论输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _replyToUserName != null
                            ? (s?.momentReplyTo(_replyToUserName!) ?? 'Reply to $_replyToUserName...')
                            : (s?.momentWriteComment ?? 'Write a comment...'),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  if (_replyToUserName != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _clearReplyTarget,
                    ),
                ],
              ),
            ),
          ),

          // 发送按钮
          IconButton(
            onPressed: _isSubmittingComment ? null : _sendComment,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _setReplyTarget(MomentComment comment) {
    setState(() {
      _replyToCommentId = comment.id;
      _replyToUserId = comment.userId;
      _replyToUserName = comment.userName;
    });
  }

  void _clearReplyTarget() {
    setState(() {
      _replyToCommentId = null;
      _replyToUserId = null;
      _replyToUserName = null;
    });
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmittingComment) return;

    setState(() {
      _isSubmittingComment = true;
    });

    context.read<MomentBloc>().add(CommentMoment(
          momentId: widget.moment.id,
          content: text,
          replyToCommentId: _replyToCommentId,
          replyToUserId: _replyToUserId,
        ));
  }

  String _formatCommentTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    final s = S.of(context);

    if (diff.inMinutes < 1) return s?.momentJustNow ?? 'just now';
    if (diff.inMinutes < 60) return s?.momentMinutesAgo(diff.inMinutes) ?? '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return s?.momentHoursAgo(diff.inHours) ?? '${diff.inHours}h ago';
    if (diff.inDays < 7) return s?.momentDaysAgo(diff.inDays) ?? '${diff.inDays}d ago';

    return '${timestamp.month}/${timestamp.day}';
  }
}
