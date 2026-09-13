import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/notifications/notification_filter_store.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/notification_filter_rules.dart';
import 'package:n42_chat/src/domain/entities/user_profile_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class RejectingStore extends InMemorySharedPreferencesStore {
  RejectingStore() : super.empty();
  String? failure;
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (failure == 'false') return false;
    if (failure == 'throw') throw StateError('platform rejected write');
    return super.setValue(valueType, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RejectingStore platform;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    platform = RejectingStore();
    SharedPreferencesStorePlatform.instance = platform;
  });
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  for (final failure in ['false', 'throw']) {
    for (final metadata in [false, true]) {
      test(
        'favorite metadata=$metadata rejects $failure and refreshes optimistic cache',
        () async {
          final prefs = PreferencesDataSource();
          final save = metadata
              ? prefs.saveFavoriteMeta
              : prefs.saveFavoriteMessages;
          final read = metadata
              ? prefs.getFavoriteMeta
              : prefs.getFavoriteMessages;
          await save('original');
          platform.failure = failure;
          await expectLater(save('changed'), throwsStateError);
          expect(await read(), 'original');
          platform.failure = null;
          await save('retry');
          expect(await read(), 'retry');
        },
      );
    }

    test(
      'appearance $failure result fails and restores the durable cache',
      () async {
        final prefs = PreferencesDataSource();
        await prefs.saveAppearanceSettingsModel(
          const AppearanceSettings(themeMode: ThemeMode.light),
        );
        platform.failure = failure;
        await expectLater(
          prefs.saveAppearanceSettingsModel(
            const AppearanceSettings(themeMode: ThemeMode.dark),
          ),
          throwsStateError,
        );
        expect(
          (await prefs.getAppearanceSettingsModel()).themeMode,
          ThemeMode.light,
        );
        platform.failure = null;
        await prefs.saveAppearanceSettingsModel(
          const AppearanceSettings(themeMode: ThemeMode.dark),
        );
        expect(
          (await prefs.getAppearanceSettingsModel()).themeMode,
          ThemeMode.dark,
        );
      },
    );

    test(
      'notification $failure result fails and restores the durable cache',
      () async {
        final prefs = PreferencesDataSource();
        await prefs.saveNotificationSettingsModel(
          const NotificationSettings(enabled: true),
        );
        platform.failure = failure;
        await expectLater(
          prefs.saveNotificationSettingsModel(
            const NotificationSettings(enabled: false),
          ),
          throwsStateError,
        );
        expect((await prefs.getNotificationSettingsModel()).enabled, isTrue);
        platform.failure = null;
        await prefs.saveNotificationSettingsModel(
          const NotificationSettings(enabled: false),
        );
        expect((await prefs.getNotificationSettingsModel()).enabled, isFalse);
      },
    );

    test(
      'filter $failure result fails and restores the durable cache',
      () async {
        final store = NotificationFilterStore();
        await store.save(NotificationFilterRules.empty);
        platform.failure = failure;
        await expectLater(
          store.save(
            NotificationFilterRules.empty.copyWith(caseSensitive: true),
          ),
          throwsStateError,
        );
        expect((await store.load()).caseSensitive, isFalse);
        platform.failure = null;
        await store.save(
          NotificationFilterRules.empty.copyWith(caseSensitive: true),
        );
        expect((await store.load()).caseSensitive, isTrue);
      },
    );
  }
}
