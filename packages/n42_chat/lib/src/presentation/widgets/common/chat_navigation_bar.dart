import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/a11y_l10n.dart';

/// Shared phone/split navigation with full-count screen-reader announcements.
class ChatNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final int unreadCount;
  final int pendingContactCount;
  final ValueChanged<int> onSelected;

  const ChatNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.unreadCount = 0,
    this.pendingContactCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final labels = [
      l10n.commonMessages,
      l10n.commonContacts,
      l10n.commonDiscover,
      l10n.commonMe,
    ];
    const icons = [
      Icons.chat_bubble_outline,
      Icons.contacts_outlined,
      Icons.explore_outlined,
      Icons.person_outline,
    ];
    const activeIcons = [
      Icons.chat_bubble,
      Icons.contacts,
      Icons.explore,
      Icons.person,
    ];
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: context.surfaceColor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.dividerColor,
              width: AppDimensions.dividerThickness,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(labels.length, (index) {
              final selected = index == selectedIndex;
              final count = index == 0
                  ? unreadCount
                  : index == 1
                  ? pendingContactCount
                  : 0;
              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: labels[index],
                  value: count <= 0
                      ? null
                      : index == 0
                      ? A11yL10n.of(context).unreadCount(count)
                      : l10n.contactPendingCount(count),
                  onTap: () => onSelected(index),
                  excludeSemantics: true,
                  child: Tooltip(
                    message: labels[index],
                    child: InkWell(
                      key: ValueKey<String>('chat_tab_$index'),
                      onTap: () => onSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spacingS,
                          horizontal: AppDimensions.spacingXS,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: AppDimensions.animationFast,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacing,
                                vertical: AppDimensions.spacingXS,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? primary.withValues(alpha: .12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: Badge(
                                isLabelVisible: count > 0,
                                label: Text(count > 99 ? '99+' : '$count'),
                                child: Icon(
                                  selected ? activeIcons[index] : icons[index],
                                  size: AppDimensions.iconSizeBottomNav,
                                  color: selected
                                      ? primary
                                      : context.textSupporting,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacingXS),
                            Text(
                              labels[index],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.captionSmall.copyWith(
                                color: selected
                                    ? primary
                                    : context.textSupporting,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
