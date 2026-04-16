import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/core/services/remark_service.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/contact/contact_state.dart';
import 'package:n42_chat/src/presentation/pages/contact/contact_detail_page.dart';

class MockContactBloc extends Mock implements ContactBloc {}

class MockPreferencesDataSource extends Mock implements PreferencesDataSource {}

Widget _buildTestWidget(Widget child, {ContactBloc? contactBloc}) {
  final app = MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );

  if (contactBloc == null) {
    return app;
  }

  return BlocProvider<ContactBloc>.value(
    value: contactBloc,
    child: app,
  );
}

void main() {
  late MockContactBloc mockContactBloc;
  late StreamController<ContactState> contactStateController;
  late MockPreferencesDataSource mockPreferencesDataSource;

  const userId = '@alice:server.com';
  const contact = ContactEntity(
    userId: userId,
    displayName: 'Alice',
    isFriend: true,
  );

  setUp(() {
    mockContactBloc = MockContactBloc();
    contactStateController = StreamController<ContactState>.broadcast();
    mockPreferencesDataSource = MockPreferencesDataSource();

    when(() => mockContactBloc.state).thenReturn(
      const ContactState(
        status: ContactStatus.loaded,
        contacts: [contact],
      ),
    );
    when(() => mockContactBloc.stream).thenAnswer((_) => contactStateController.stream);
    when(() => mockPreferencesDataSource.setContactRemark(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockPreferencesDataSource.getContactRemarks())
        .thenAnswer((_) async => <String, String>{});

    if (getIt.isRegistered<PreferencesDataSource>()) {
      getIt.unregister<PreferencesDataSource>();
    }
    getIt.registerSingleton<PreferencesDataSource>(mockPreferencesDataSource);
  });

  tearDown(() async {
    await contactStateController.close();
    if (getIt.isRegistered<PreferencesDataSource>()) {
      getIt.unregister<PreferencesDataSource>();
    }
  });

  testWidgets('ContactDetailPage updates display name when bloc remark updates',
      (tester) async {
    await tester.pumpWidget(
      _buildTestWidget(
        const ContactDetailPage(
          userId: userId,
          displayName: 'Alice',
        ),
        contactBloc: mockContactBloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsWidgets);

    contactStateController.add(
      const ContactState(
        status: ContactStatus.remarkUpdated,
        updatedRemarkUserId: userId,
        updatedRemark: 'Buddy',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buddy'), findsWidgets);
  });

  testWidgets('ContactDetailPage updates display name from RemarkService without bloc',
      (tester) async {
    await tester.pumpWidget(
      _buildTestWidget(
        const ContactDetailPage(
          userId: '@remark-only:server.com',
          displayName: 'RemarkOnly',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RemarkOnly'), findsWidgets);

    await RemarkService.instance.setRemark('@remark-only:server.com', 'Cached Remark');
    await tester.pumpAndSettle();

    expect(find.text('Cached Remark'), findsWidgets);
  });
}
