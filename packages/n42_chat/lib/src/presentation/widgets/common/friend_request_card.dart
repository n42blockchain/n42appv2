import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/repositories/contact_repository.dart';
import 'n42_avatar.dart';

/// Keep request identity and actions readable on narrow screens and large text.
class FriendRequestCard extends StatelessWidget {
  final FriendRequest request;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onProfile;
  const FriendRequestCard({
    super.key,
    required this.request,
    required this.busy,
    required this.onAccept,
    required this.onReject,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final actionStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(0, AppDimensions.buttonHeight),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),
    );
    return Card(
      key: ValueKey('friend_request_${request.id}'),
      elevation: 0,
      color: context.surfaceColor,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing,
        vertical: AppDimensions.spacingXS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: N42Avatar(
                name: request.userName,
                imageUrl: request.userAvatarUrl,
              ),
              title: Text(
                request.userName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                request.userId,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: busy ? null : onProfile,
            ),
            if (request.isOutgoing) ...[
              Text(
                l10n.contactRequestPending,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                l10n.contactRequestHint,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.textSecondary),
              ),
            ] else if (busy)
              const LinearProgressIndicator()
            else
              Wrap(
                spacing: AppDimensions.spacingS,
                runSpacing: AppDimensions.spacingS,
                children: [
                  FilledButton(
                    style: actionStyle,
                    onPressed: onAccept,
                    child: Text(l10n.commonAccept),
                  ),
                  OutlinedButton(
                    style: actionStyle,
                    onPressed: onReject,
                    child: Text(l10n.commonReject),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
