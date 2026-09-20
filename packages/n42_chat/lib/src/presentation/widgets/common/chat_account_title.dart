import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../pages/settings/account_switch_page.dart';

/// Show the active chat identity without replacing the host's Back action.
class ChatAccountTitle extends StatelessWidget {
  final String title;
  const ChatAccountTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc?>();
    if (auth == null)
      return Text(title, maxLines: 1, overflow: TextOverflow.ellipsis);
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: auth,
      builder: (context, state) {
        final identity = state.user?.userId;
        return Tooltip(
          message: S.of(context)!.settingsSwitchAccount,
          child: InkWell(
            key: const ValueKey('chat_account_selector'),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            onTap: state.status == AuthStatus.loading
                ? null
                : () {
                    Navigator.of(context).push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => BlocProvider.value(
                          value: auth,
                          child: const AccountSwitchPage(),
                        ),
                      ),
                    );
                  },
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppDimensions.buttonHeight,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (identity != null)
                          Text(
                            identity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: context.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.expand_more,
                    size: AppDimensions.iconSizeSmall,
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
