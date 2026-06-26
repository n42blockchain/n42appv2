import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
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
  String? _switchingUserId;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final loadVersion = ++_loadVersion;
    setState(() => _isLoading = true);
    final accounts = await _authRepository.getStoredAccounts();
    if (!mounted || loadVersion != _loadVersion) {
      return;
    }
    setState(() {
      _accounts = accounts;
      _isLoading = false;
    });
  }

  Future<void> _openAddAccount() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    if (result == true) {
      Navigator.of(context).pop(true);
      return;
    }
    await _loadAccounts();
  }

  void _switchAccount(StoredAccountEntity account) {
    if (account.isCurrent || _switchingUserId != null) {
      return;
    }
    setState(() => _switchingUserId = account.userId);
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
          final message = state.errorMessage ?? 'Failed to switch account';
          setState(() => _switchingUserId = null);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Scaffold(
        backgroundColor: context.pageBackground,
        appBar: N42AppBar(
          title: 'Accounts',
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const SizedBox(height: 16),
                  if (_accounts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      child: Text(
                        'No saved accounts yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textSecondary,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: context.surfaceColor,
                      child: Column(
                        children: [
                          for (var i = 0; i < _accounts.length; i++) ...[
                            _AccountTile(
                              account: _accounts[i],
                              isSwitching:
                                  _switchingUserId == _accounts[i].userId,
                              onTap: () => _switchAccount(_accounts[i]),
                            ),
                            if (i != _accounts.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 72),
                                child: Divider(
                                  height: 1,
                                  color: context.dividerColor,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: N42Button.primary(
                      text: l10n?.commonAdd ?? 'Add Account',
                      onPressed: _switchingUserId == null
                          ? _openAddAccount
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final StoredAccountEntity account;
  final bool isSwitching;
  final VoidCallback onTap;

  const _AccountTile({
    required this.account,
    required this.isSwitching,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = context.textSecondary;

    return ListTile(
      leading: N42Avatar(
        imageUrl: account.avatarUrl,
        name: account.effectiveDisplayName,
        size: 44,
      ),
      title: Text(
        account.effectiveDisplayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          height: 1.3,
          color: context.textPrimary,
          fontWeight: account.isCurrent ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${account.userId}\n${account.homeserver}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: secondaryColor,
        ),
      ),
      trailing: isSwitching
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : account.isCurrent
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(AppIcons.chevron),
      onTap: isSwitching ? null : onTap,
    );
  }
}
