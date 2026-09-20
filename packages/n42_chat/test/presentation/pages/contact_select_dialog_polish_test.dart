import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/contact_entity.dart';
import 'package:n42_chat/src/presentation/widgets/chat/contact_select_dialog.dart';

const contacts = [
  ContactEntity(userId: '@alice:example.org', displayName: 'Alice'),
  ContactEntity(userId: '@bob:example.org', displayName: 'Bob'),
];

Future<void> openDialog(
  WidgetTester tester, {
  List<ContactEntity> available = contacts,
  Brightness brightness = Brightness.light,
  double scale = 1,
  double keyboardInset = 0,
  ValueChanged<List<String>?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      locale: const Locale('en'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await showDialog<List<String>>(
                context: context,
                builder: (_) => ContactSelectDialog(
                  contacts: available,
                  title: 'Add Members',
                ),
              );
              onResult?.call(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no results can be cleared without losing selected contacts', (
    tester,
  ) async {
    List<String>? result;
    await openDialog(tester, onResult: (value) => result = value);
    await tester.tap(find.text('Alice'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'missing-person');
    await tester.pump();
    expect(find.text('No Results'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(find.text('Confirm (1)'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();
    expect(find.text('No Results'), findsNothing);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    expect(
      tester
          .widget<CheckboxListTile>(find.byType(CheckboxListTile).first)
          .value,
      isTrue,
    );
    await tester.tap(find.text('Confirm (1)'));
    await tester.pumpAndSettle();
    expect(result, ['@alice:example.org']);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'no available contacts has an explicit empty state and disabled confirm',
    (tester) async {
      await openDialog(tester, available: []);
      expect(find.text('No contacts'), findsOneWidget);
      final confirm = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Confirm (0)'),
      );
      expect(confirm.onPressed, isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(ContactSelectDialog), findsNothing);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'narrow large-text dialog keeps cancel reachable ${brightness.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await openDialog(
          tester,
          brightness: brightness,
          scale: 2,
          keyboardInset: 220,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(ContactSelectDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
