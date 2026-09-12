import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../widgets/common/common_widgets.dart';
import 'auto_download_settings_page.dart';
import 'chat_background_page.dart';
import 'quick_replies_page.dart';
import 'settings_navigation.dart';
import 'translation_settings_page.dart';

/// Chat-wide options; conversation-specific options remain in room settings.
class ChatSettingsPage extends StatelessWidget {
  const ChatSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    Widget entry(IconData icon, String label, WidgetBuilder builder) =>
        Material(
          color: context.surfaceColor,
          child: ListTile(
            leading: Icon(icon),
            title: Text(label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (!getIt.isRegistered<PreferencesDataSource>()) {
                SettingsNavigation.unavailable(context);
                return;
              }
              SettingsNavigation.page(context, builder(context));
            },
          ),
        );
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: l10n?.commonChat ?? 'Chat',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        children: [
          entry(
            Icons.wallpaper,
            l10n?.chatBackground ?? 'Chat Background',
            (_) => const ChatBackgroundPage(),
          ),
          entry(
            Icons.flash_on_outlined,
            l10n?.settingsQuickReply ?? 'Quick Reply',
            (_) => QuickRepliesPage(
              storageDataSource: getIt<PreferencesDataSource>(),
            ),
          ),
          entry(
            Icons.translate,
            l10n?.settingsTranslation ?? 'Translation',
            (_) => const TranslationSettingsPage(),
          ),
          entry(
            Icons.download_outlined,
            l10n?.autoDownload ?? 'Auto-Download',
            (_) => const AutoDownloadSettingsPage(),
          ),
        ],
      ),
    );
  }
}
