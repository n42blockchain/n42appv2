import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/avatar_decoration_preset.dart';
import '../../../domain/entities/user_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/common_widgets.dart';
import 'nft_avatar_picker_page.dart';

enum _AvatarStudioOperation { decoration, bindNft, clearNft }

class AvatarStudioPage extends StatefulWidget {
  const AvatarStudioPage({super.key});

  @override
  State<AvatarStudioPage> createState() => _AvatarStudioPageState();
}

class _AvatarStudioPageState extends State<AvatarStudioPage> {
  _AvatarStudioOperation? _pendingOperation;
  String? _pendingSuccessMessage;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const LoadUserProfileData());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final backgroundColor = context.pageBackground;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (_pendingOperation == null) return;

        if (state.status == AuthStatus.authenticated) {
          final successMessage = _pendingSuccessMessage;
          setState(() {
            _pendingOperation = null;
            _pendingSuccessMessage = null;
          });
          if (successMessage != null && successMessage.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(successMessage)));
          }
        } else if (state.status == AuthStatus.error) {
          final error = state.errorMessage ?? 'Update avatar studio failed';
          setState(() {
            _pendingOperation = null;
            _pendingSuccessMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final user = state.user;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: N42AppBar(
            title: 'Avatar Studio',
            backgroundColor: context.surfaceColor,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildHeroCard(context, isDark, user),
              const SizedBox(height: 16),
              _buildDecorationSection(context, user),
              const SizedBox(height: 16),
              _buildNftSection(context, user),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isDark, UserEntity? user) {
    final surfaceColor = context.surfaceColor;
    final textColor = context.textPrimary;
    final subtitleColor = context.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          N42Avatar(
            imageUrl: user?.avatarUrl,
            name: user?.displayName,
            size: 88,
            borderRadius: 24,
            isNftAvatar: user?.hasNftAvatar ?? false,
            decorationPreset:
                user?.avatarDecorationPreset ?? AvatarDecorationPreset.none,
          ),
          const SizedBox(height: 14),
          Text(
            user?.effectiveDisplayName ?? 'Me',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: _buildSummaryChips(
              isDark: isDark,
              user: user,
              subtitleColor: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSummaryChips({
    required bool isDark,
    required UserEntity? user,
    required Color subtitleColor,
  }) {
    final labels = <String>[
      if (user?.hasNftAvatar ?? false) 'NFT Avatar',
      if ((user?.avatarDecorationPreset ?? AvatarDecorationPreset.none) !=
          AvatarDecorationPreset.none)
        (user?.avatarDecorationPreset ?? AvatarDecorationPreset.none)
            .displayName,
      if (!(user?.hasNftAvatar ?? false) &&
          (user?.avatarDecorationPreset ?? AvatarDecorationPreset.none) ==
              AvatarDecorationPreset.none)
        'Photo Avatar',
    ];

    return labels
        .map(
          (label) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: subtitleColor),
            ),
          ),
        )
        .toList();
  }

  Widget _buildDecorationSection(
    BuildContext context,
    UserEntity? user,
  ) {
    final surfaceColor = context.surfaceColor;
    final textColor = context.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avatar Styles',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reuse one decoration selector for profile and avatar entry points.',
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AvatarDecorationPreset.values.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.84,
            ),
            itemBuilder: (context, index) {
              final preset = AvatarDecorationPreset.values[index];
              final isSelected = preset == user?.avatarDecorationPreset;
              return _DecorationCard(
                preset: preset,
                isSelected: isSelected,
                imageUrl: user?.avatarUrl,
                name: user?.displayName,
                isNftAvatar: user?.hasNftAvatar ?? false,
                onTap: () => _updateAvatarStyle(preset),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNftSection(BuildContext context, UserEntity? user) {
    final surfaceColor = context.surfaceColor;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _buildActionTile(
            context,
            icon: Icons.token_outlined,
            title: user?.hasNftAvatar ?? false
                ? 'Replace NFT Avatar'
                : (S.of(context)?.profileBindNftAvatar ?? 'Bind NFT Avatar'),
            subtitle: 'Use an on-chain collectible as your avatar.',
            iconColor: const Color(0xFFFFB020),
            onTap: _openNftPicker,
          ),
          if (user?.hasNftAvatar ?? false) ...[
            Divider(
              height: 1,
              indent: 56,
              color: context.dividerColor,
            ),
            _buildActionTile(
              context,
              icon: Icons.restart_alt,
              title: 'Use Photo Avatar',
              subtitle: 'Keep your uploaded avatar and clear the NFT binding.',
              iconColor: AppColors.error,
              onTap: _clearNftAvatar,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: context.textSecondary,
        ),
      ),
      trailing: const Icon(AppIcons.chevron),
      onTap: onTap,
    );
  }

  void _updateAvatarStyle(AvatarDecorationPreset preset) {
    final currentPreset =
        context.read<AuthBloc>().state.user?.avatarDecorationPreset ??
        AvatarDecorationPreset.none;
    if (preset == currentPreset) return;

    _dispatchUpdate(
      operation: _AvatarStudioOperation.decoration,
      successMessage: 'Avatar style set to: ${preset.displayName}',
      event: UpdateUserProfile(avatarDecorationPreset: preset.storageKey),
    );
  }

  Future<void> _openNftPicker() async {
    final authBloc = context.read<AuthBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: authBloc,
          child: NftAvatarPickerPage(
            onConfirm:
                ({
                  required String imageUrl,
                  required String contractAddress,
                  required int tokenId,
                  required int chainId,
                }) {
                  _dispatchUpdate(
                    operation: _AvatarStudioOperation.bindNft,
                    successMessage: 'NFT avatar updated',
                    event: UpdateUserProfile(
                      nftContractAddress: contractAddress,
                      nftTokenId: tokenId,
                      nftChainId: chainId,
                      nftImageUrl: imageUrl,
                    ),
                  );
                },
          ),
        ),
      ),
    );
  }

  void _clearNftAvatar() {
    _dispatchUpdate(
      operation: _AvatarStudioOperation.clearNft,
      successMessage: 'Switched back to photo avatar',
      event: const UpdateUserProfile(clearNftAvatar: true),
    );
  }

  void _dispatchUpdate({
    required _AvatarStudioOperation operation,
    required String successMessage,
    required UpdateUserProfile event,
  }) {
    setState(() {
      _pendingOperation = operation;
      _pendingSuccessMessage = successMessage;
    });
    context.read<AuthBloc>().add(event);
  }
}

class _DecorationCard extends StatelessWidget {
  final AvatarDecorationPreset preset;
  final bool isSelected;
  final String? imageUrl;
  final String? name;
  final bool isNftAvatar;
  final VoidCallback onTap;

  const _DecorationCard({
    required this.preset,
    required this.isSelected,
    required this.imageUrl,
    required this.name,
    required this.isNftAvatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : context.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              N42Avatar(
                imageUrl: imageUrl,
                name: name,
                size: 46,
                decorationPreset: preset,
                isNftAvatar: isNftAvatar,
              ),
              const SizedBox(height: 10),
              Text(
                preset.displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
