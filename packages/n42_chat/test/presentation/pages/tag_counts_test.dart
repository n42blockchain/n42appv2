import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/domain/repositories/contact_repository.dart';
import 'package:n42_chat/src/presentation/pages/contact/tags_management_page.dart';

class _Contacts extends Mock implements IContactRepository {}

void main() {
  testWidgets('counts actual friend assignments without a stored catalog', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({
      'n42_chat_session': jsonEncode({
        'homeserver': 'https://hs.test',
        'userId': '@me:hs',
        'accessToken': 'fixture',
        'deviceId': 'fixture',
      }),
    });
    SharedPreferences.setMockInitialValues({});
    getIt.pushNewScope();
    addTearDown(getIt.popScope);
    final repository = _Contacts();
    getIt.registerSingleton<IContactRepository>(repository);
    when(() => repository.getContacts()).thenAnswer(
      (_) async => const [
        ContactEntity(userId: '@a:hs', displayName: 'A', tags: ['Family']),
        ContactEntity(userId: '@b:hs', displayName: 'B', tags: ['Family']),
      ],
    );
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        locale: Locale('en'),
        home: TagsManagementPage(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Family'), findsOneWidget);
    expect(find.text('2 Contacts'), findsOneWidget);
  });
}
