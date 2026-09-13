import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/widgets/chat/poll_create_sheet.dart';

void main() {
  PollComposerResult? result;
  Future<void> open(
    WidgetTester tester, {
    bool scheduling = true,
    String language = 'en',
  }) async {
    if (tester.view.physicalSize.width != 320) {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    result = null;
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(language),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              child: const Text('Open'),
              onPressed: () async {
                result = await showModalBottomSheet<PollComposerResult>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => PollCreateSheet(allowScheduling: scheduling),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, int index, String text) async {
    final target = find.byType(TextField).at(index);
    await tester.ensureVisible(target);
    await tester.enterText(target, text);
    await tester.pump();
  }

  Future<void> fill(WidgetTester tester) async {
    await enter(tester, 0, '  Where?  ');
    await enter(tester, 1, ' Home ');
    await enter(tester, 2, ' Park ');
  }

  testWidgets('rejects missing question and fewer than two nonempty options', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, find.text('Submit'));
    expect(result, isNull);
    await enter(tester, 0, 'Question');
    await enter(tester, 1, 'One');
    await tap(tester, find.text('Submit'));
    expect(result, isNull);
    expect(find.byType(PollCreateSheet), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
  testWidgets('send returns trimmed question and choices and closes sheet', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);
    await tap(tester, find.text('Submit'));
    expect(result!.question, 'Where?');
    expect(result!.options, ['Home', 'Park']);
    expect(result!.maxSelections, 1);
    expect(result!.action, PollComposerAction.sendNow);
    expect(result!.quizCorrectIndex, isNull);
    expect(find.byType(PollCreateSheet), findsNothing);
  });
  testWidgets('schedule preserves multiple selection and anonymous settings', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);
    await tap(tester, find.text('Multi'));
    await tap(tester, find.byType(Switch).first);
    await tap(tester, find.text('Schedule'));
    expect(result!.action, PollComposerAction.schedule);
    expect(result!.isAnonymous, isTrue);
    expect(result!.maxSelections, 0);
  });
  testWidgets('scheduling can be disabled and cancel produces no poll', (
    tester,
  ) async {
    await open(tester, scheduling: false);
    expect(find.text('Schedule'), findsNothing);
    await tap(tester, find.text('Cancel'));
    expect(result, isNull);
    expect(find.byType(PollCreateSheet), findsNothing);
  });
  testWidgets('quiz remaps the correct answer when blank options are omitted', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);
    await tap(tester, find.byIcon(Icons.add_circle_outline));
    await enter(tester, 1, ' ');
    await enter(tester, 3, ' Beach ');
    await tap(tester, find.byType(Switch).last);
    await tap(tester, find.byTooltip('Correct answer').at(2));
    await enter(tester, 4, ' Explanation ');
    await tap(tester, find.text('Submit'));
    expect(result!.options, ['Park', 'Beach']);
    expect(result!.quizCorrectIndex, 1);
    expect(result!.quizExplanation, 'Explanation');
  });
  testWidgets(
    'quiz rejects a blank correct answer without dropping the draft',
    (tester) async {
      await open(tester);
      await fill(tester);
      await tap(tester, find.byIcon(Icons.add_circle_outline));
      await enter(tester, 1, '');
      await enter(tester, 3, 'Beach');
      await tap(tester, find.byType(Switch).last);
      await tap(tester, find.text('Submit'));
      expect(result, isNull);
      expect(find.text('Mark a non-empty correct answer'), findsOneWidget);
    },
  );
  testWidgets(
    'removing an earlier option preserves the selected correct answer',
    (tester) async {
      await open(tester);
      await fill(tester);
      await tap(tester, find.byIcon(Icons.add_circle_outline));
      await enter(tester, 3, 'Beach');
      await tap(tester, find.byType(Switch).last);
      await tap(tester, find.byTooltip('Correct answer').at(2));
      await tap(tester, find.byIcon(Icons.remove_circle_outline).first);
      await tap(tester, find.text('Submit'));
      expect(result!.options, ['Park', 'Beach']);
      expect(result!.quizCorrectIndex, 1);
    },
  );
  testWidgets(
    'removing the correct option resets selection to the first remaining answer',
    (tester) async {
      await open(tester);
      await fill(tester);
      await tap(tester, find.byIcon(Icons.add_circle_outline));
      await enter(tester, 3, 'Beach');
      await tap(tester, find.byType(Switch).last);
      await tap(tester, find.byTooltip('Correct answer').at(2));
      await tap(tester, find.byIcon(Icons.remove_circle_outline).last);
      await tap(tester, find.text('Submit'));
      expect(result!.options, ['Home', 'Park']);
      expect(result!.quizCorrectIndex, 0);
    },
  );
  testWidgets(
    'quiz cannot be changed back to multiple selection while enabled',
    (tester) async {
      await open(tester);
      await fill(tester);
      await tap(tester, find.byType(Switch).last);
      await tap(tester, find.text('Multi'));
      await tap(tester, find.text('Submit'));
      expect(result!.quizCorrectIndex, 0);
      expect(result!.maxSelections, 1);
    },
  );
  for (final language in ['en', 'ar']) {
    testWidgets('poll controls fit a narrow $language screen', (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester, language: language);
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
