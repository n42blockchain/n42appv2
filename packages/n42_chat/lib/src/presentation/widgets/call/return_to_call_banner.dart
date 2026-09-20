import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';

class ReturnToCallBanner extends StatelessWidget {
  final VoidCallback onReturn;
  const ReturnToCallBanner({super.key, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.primaryContainer,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      child: InkWell(
        key: const ValueKey('return_to_active_call'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        onTap: onReturn,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Row(
            children: [
              Icon(Icons.call, color: colors.onPrimaryContainer),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Text(
                  S.of(context)!.callReturnToCall,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              Icon(Icons.open_in_full, color: colors.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
