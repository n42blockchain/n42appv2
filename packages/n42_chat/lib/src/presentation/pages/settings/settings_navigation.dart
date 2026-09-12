import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../n42_chat.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import 'appearance_settings_page.dart';
import 'change_email_page.dart';
import 'change_password_page.dart';
import 'notification_settings_page.dart';

/// Shared composition for direct routes, Profile and embedded settings.
class SettingsNavigation {
  static AuthBloc? authBloc(BuildContext context) =>
      context.read<AuthBloc?>() ??
      (N42Chat.isInitialized ? N42Chat.authBloc : null);

  static void unavailable(BuildContext context, {bool login = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          login
              ? (S.of(context)?.authLoginNow ?? 'Log in now')
              : (S.of(context)?.commonLoadFailed ?? 'Failed to load'),
        ),
      ),
    );
  }

  static Future<void> run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) unavailable(context);
    }
  }

  static Future<void> page(
    BuildContext context,
    Widget page, {
    bool needsPreferences = false,
    bool needsAuth = false,
  }) async {
    if (needsPreferences && !getIt.isRegistered<PreferencesDataSource>()) {
      unavailable(context);
      return;
    }
    final auth = authBloc(context);
    if (needsAuth && (auth == null || !auth.state.isAuthenticated)) {
      unavailable(context, login: true);
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            auth == null ? page : BlocProvider.value(value: auth, child: page),
      ),
    );
  }

  static Future<void> notifications(BuildContext context) =>
      run(context, () async {
        final settings = await N42Chat.getSavedNotificationSettings();
        if (!context.mounted) return;
        await page(context, NotificationSettingsPage(settings: settings));
      });

  static Future<void> appearance(BuildContext context) =>
      run(context, () async {
        final settings = await N42Chat.getSavedAppearanceSettings();
        if (!context.mounted) return;
        await page(context, AppearanceSettingsPage(settings: settings));
      });

  static Future<void> password(BuildContext context) =>
      page(context, const ChangePasswordPage(), needsAuth: true);

  static Future<void> email(BuildContext context) =>
      page(context, const ChangeEmailPage(), needsAuth: true);

  static void logout(BuildContext context) {
    final auth = authBloc(context);
    if (auth == null || !auth.state.isAuthenticated) {
      unavailable(context, login: true);
      return;
    }
    auth.add(const AuthLogoutRequested());
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }
}
