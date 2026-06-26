import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/story_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../helpers/story_interaction_helper.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/moment/moment_bloc.dart';
import '../../blocs/story/story_bloc.dart';
import '../../blocs/story/story_event.dart';
import '../../blocs/story/story_state.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/story/story_bar.dart';
import '../game/game_center_page.dart';
import '../moment/create_moment_page.dart';
import '../moment/moment_list_page.dart';
import '../profile/avatar_studio_page.dart';
import '../story/create_story_page.dart';
import '../story/story_viewer_page.dart';

class SocialHubPage extends StatelessWidget {
  const SocialHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StoryBloc>()
        ..add(const LoadStories())
        ..add(const SubscribeStories()),
      child: const _SocialHubView(),
    );
  }
}

class _SocialHubView extends StatelessWidget {
  const _SocialHubView();

  @override
  Widget build(BuildContext context) {
    final bgColor = context.pageBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: N42AppBar(
        title: 'Stories & Fun',
        backgroundColor: context.surfaceColor,
      ),
      body: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          final authUser = _tryGetAuthUser(context);

          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHero(context),
              ),
              const SizedBox(height: 16),
              StoryBar(
                userStories: state.userStories,
                myStory: _buildMyStory(authUser, state),
                myAvatarUrl: authUser?.avatarUrl,
                myName: authUser?.displayName,
                onMyStoryTap: () => _openMyStory(context, authUser, state),
                onUserStoryTap: (userStory) =>
                    _openUserStory(context, userStory, state),
                onAddStory: () => _openCreateStory(context),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ActionGrid(
                  actions: [
                    _QuickAction(
                      title: 'Create Story',
                      subtitle: 'Post a text or photo status.',
                      icon: Icons.add_circle_outline,
                      color: const Color(0xFF3B82F6),
                      onTap: () => _openCreateStory(context),
                    ),
                    _QuickAction(
                      title: 'Story Camera',
                      subtitle: 'Jump straight into filters and photo editing.',
                      icon: Icons.auto_awesome,
                      color: const Color(0xFF10B981),
                      onTap: () => _openStoryCamera(context),
                    ),
                    _QuickAction(
                      title: S.of(context)?.commonMoments ?? 'Moments',
                      subtitle: 'Open the full feed and comments.',
                      icon: Icons.photo_library_outlined,
                      color: const Color(0xFF6366F1),
                      onTap: () => _openMoments(context),
                    ),
                    _QuickAction(
                      title: 'Moment Camera',
                      subtitle: 'Create a post and pick media immediately.',
                      icon: Icons.camera_alt_outlined,
                      color: const Color(0xFFF59E0B),
                      onTap: () => _openCreateMoment(context),
                    ),
                    _QuickAction(
                      title: S.of(context)?.discoverGames ?? 'Games',
                      subtitle: 'Launch the built-in casual game center.',
                      icon: Icons.sports_esports_outlined,
                      color: const Color(0xFFEF4444),
                      onTap: () => _openGames(context),
                    ),
                    _QuickAction(
                      title: 'Avatar Studio',
                      subtitle: 'Decorations, NFT avatar and identity flair.',
                      icon: Icons.face_retouching_natural,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => _openAvatarStudio(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stories, moments, games and avatars',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reuse the existing social stack instead of scattering entry points across chat, profile and discover.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  UserStories? _buildMyStory(UserEntity? authUser, StoryState state) {
    if (state.myStories.isEmpty) return null;

    final currentUserId = MatrixClientManager.instance.userId;
    if (currentUserId == null) return null;

    return UserStories(
      userId: currentUserId,
      userName: authUser?.displayName ?? currentUserId,
      avatarUrl: authUser?.avatarUrl ?? state.myStories.first.userAvatarUrl,
      stories: state.myStories,
      lastUpdated: state.myStories.first.createdAt,
    );
  }

  UserEntity? _tryGetAuthUser(BuildContext context) {
    try {
      return context.read<AuthBloc>().state.user;
    } catch (_) {
      return null;
    }
  }

  void _openCreateStory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<StoryBloc>(),
          child: const CreateStoryPage(),
        ),
      ),
    );
  }

  void _openStoryCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<StoryBloc>(),
          child: const CreateStoryPage(
            initialMode: StoryMode.photo,
            autoPickMedia: true,
          ),
        ),
      ),
    );
  }

  void _openMoments(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MomentListPage()));
  }

  void _openCreateMoment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<MomentBloc>(),
          child: const CreateMomentPage(autoPickImages: true),
        ),
      ),
    );
  }

  void _openGames(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const GameCenterPage()));
  }

  void _openAvatarStudio(BuildContext context) {
    try {
      final authBloc = context.read<AuthBloc>();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: authBloc,
            child: const AvatarStudioPage(),
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar Studio requires a signed-in user'),
        ),
      );
    }
  }

  void _openMyStory(
    BuildContext context,
    UserEntity? authUser,
    StoryState state,
  ) {
    final myStory = _buildMyStory(authUser, state);
    if (myStory == null) {
      _openCreateStory(context);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(
          allUserStories: [myStory],
          currentUserId:
              authUser?.userId ?? MatrixClientManager.instance.userId,
          onDeleteStory: (story) => _handleStoryDelete(context, story),
        ),
      ),
    );
  }

  void _openUserStory(
    BuildContext context,
    UserStories userStory,
    StoryState state,
  ) {
    final userIndex = state.userStories.indexOf(userStory);
    if (userIndex < 0) return;

    final authUser = _tryGetAuthUser(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoryViewerPage(
          allUserStories: state.userStories,
          initialUserIndex: userIndex,
          currentUserId:
              authUser?.userId ?? MatrixClientManager.instance.userId,
          onStoryViewed: (story) {
            context.read<StoryBloc>().add(ViewStory(story.id));
          },
          onDeleteStory: (story) => _handleStoryDelete(context, story),
          onReply: (userId, storyId, message) {
            return _handleStoryReply(
              context,
              userId: userId,
              storyId: storyId,
              message: message,
            );
          },
        ),
      ),
    );
  }

  Future<bool> _handleStoryReply(
    BuildContext context, {
    required String userId,
    required String storyId,
    required String message,
  }) {
    return StoryInteractionHelper.replyToStory(
      context,
      userId: userId,
      storyId: storyId,
      message: message,
    );
  }

  Future<bool> _handleStoryDelete(BuildContext context, StoryEntity story) {
    return StoryInteractionHelper.deleteStory(
      storyBloc: context.read<StoryBloc>(),
      story: story,
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ActionGrid extends StatelessWidget {
  final List<_QuickAction> actions;

  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: action.onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(action.icon, color: action.color),
                  ),
                  const Spacer(),
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action.subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
