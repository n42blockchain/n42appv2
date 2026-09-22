import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../n42_chat.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/stored_account_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/common_widgets.dart';
import '../auth/login_page.dart';

class AccountSwitchPage extends StatefulWidget {
  const AccountSwitchPage({super.key});

  @override
  State<AccountSwitchPage> createState() => _AccountSwitchPageState();
}

class _AccountSwitchPageState extends State<AccountSwitchPage> {
  final IAuthRepository _authRepository = getIt<IAuthRepository>();

  List<StoredAccountEntity> _accounts = const [];
  bool _isLoading = true;
  bool _loadFailed = false;
  String? _switchingUserId;
  int _loadVersion = 0;
  bool _addingAccount = false;
  String? _switchError;
  bool get _busy => _switchingUserId != null || _addingAccount;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final loadVersion = ++_loadVersion;
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final accounts = await _authRepository.getStoredAccounts();
      if (!mounted || loadVersion != _loadVersion) return;
      setState(() => _accounts = accounts);
    } catch (_) {
      if (!mounted || loadVersion != _loadVersion) return;
      setState(() => _loadFailed = true);
    } finally {
      if (mounted && loadVersion == _loadVersion) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _canChangeAccount() {
    if (_busy) return false;
    if (N42Chat.callManager?.isInCall == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.chatInCall ?? 'In call')),
      );
      return false;
    }
    return true;
  }

  Future<void> _openAddAccount([StoredAccountEntity? account]) async {
    if (!_canChangeAccount()) return;
    setState(() => _addingAccount = true);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: LoginPage(
            initialUsername: account?.userId,
            initialHomeserver: account?.homeserver,
            allowBiometricLogin: false,
          ),
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() => _addingAccount = false);
    if (result == true) {
      Navigator.of(context).pop(true);
      return;
    }
    await _loadAccounts();
  }

  void _switchAccount(StoredAccountEntity account) {
    if (account.isCurrent || !_canChangeAccount()) {
      return;
    }
    setState(() {
      _switchingUserId = account.userId;
      _switchError = null;
    });
    context.read<AuthBloc>().add(
      AuthSwitchStoredAccountRequested(userId: account.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, state) => _switchingUserId != null || state.hasError,
      listener: (context, state) {
        if (!mounted) {
          return;
        }

        if (_switchingUserId != null &&
            state.status == AuthStatus.authenticated &&
            state.user?.userId == _switchingUserId) {
          setState(() => _switchingUserId = null);
          Navigator.of(context).pop(true);
          return;
        }

        if (_switchingUserId != null && state.status == AuthStatus.error) {
          final failedAccount = _accounts
              .where((a) => a.userId == _switchingUserId)
              .firstOrNull;
          setState(() {
            _switchingUserId = null;
            _switchError = S.of(context)!.accountSwitchFailed;
          });
          if (state.errorType == AuthErrorType.tokenExpired &&
              failedAccount != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _openAddAccount(failedAccount);
            });
          }
        }
      },
      child: PopScope(
        canPop: !_busy,
        child: Scaffold(
          backgroundColor: context.pageBackground,
          appBar: N42AppBar(
            title: l10n?.settingsSwitchAccount ?? 'Switch Account',
            showBackButton: true,
            onBackPressed: () {
              if (!_busy) Navigator.of(context).pop();
            },
          ),
          body: Column(
            children: [
              if (_switchError != null)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacing),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _switchError!,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadFailed
                    ? N42EmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: l10n?.commonLoadFailed ?? 'Failed to load',
                        buttonText: l10n?.commonRetry ?? 'Retry',
                        onButtonPressed: _loadAccounts,
                      )
                    : ListView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.paddingOf(context).bottom,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.spacing,
                            ),
                            child: Text(
                              l10n!.accountSessionsHint,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: context.textSupporting),
                            ),
                          ),
                          if (_accounts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingXL,
                                vertical: AppDimensions.spacingXL * 2,
                              ),
                              child: Text(
                                l10n.accountNoSaved,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.textSupporting,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacing,
                              ),
                              child: Column(
                                children: [
                                  for (final account in _accounts)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppDimensions.spacingS,
                                      ),
                                      child: Material(
                                        color: account.isCurrent
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: .08)
                                            : context.surfaceColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusXL,
                                          ),
                                          side: BorderSide(
                                            color: account.isCurrent
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: .4)
                                                : context.dividerColor,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: _AccountTile(
                                          account: account,
                                          isSwitching:
                                              _switchingUserId ==
                                              account.userId,
                                          onTap: _busy || account.isCurrent
                                              ? null
                                              : () => _switchAccount(account),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          const SizedBox(height: AppDimensions.spacing),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing,
                            ),
                            child: N42Button.primary(
                              text: l10n.accountAdd,
                              onPressed: !_busy ? _openAddAccount : null,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXL),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final StoredAccountEntity account;
  final bool isSwitching;
  final VoidCallback? onTap;

  const _AccountTile({
    required this.account,
    required this.isSwitching,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = context.textSupporting;

    return Semantics(
      selected: account.isCurrent,
      liveRegion: isSwitching,
      child: ListTile(
        key: ValueKey('stored_account_${account.userId}'),
        contentPadding: const EdgeInsets.all(AppDimensions.spacingM),
        minVerticalPadding: AppDimensions.spacingM,
        leading: N42Avatar(
          imageUrl: account.avatarUrl,
          name: account.effectiveDisplayName,
          size: AppDimensions.avatarSizeConversation,
        ),
        title: Text(
          account.effectiveDisplayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyLarge.copyWith(
            color: context.textPrimary,
            fontWeight: account.isCurrent ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.userId,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(color: secondaryColor),
            ),
            Text(
              account.homeserver,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(color: secondaryColor),
            ),
            if (account.isCurrent || isSwitching)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacingXS),
                child: Text(
                  isSwitching
                      ? S.of(context)!.accountSwitching
                      : S.of(context)!.accountCurrent,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: isSwitching
            ? const SizedBox(
                width: AppDimensions.spacingL,
                height: AppDimensions.spacingL,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : account.isCurrent
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : const Icon(AppIcons.chevron),
        onTap: isSwitching ? null : onTap,
      ),
    );
  }
}
