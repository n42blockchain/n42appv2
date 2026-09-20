import 'dart:io';
import 'dart:math' as math;
import 'package:n42_chat/src/core/extensions/context_extension.dart';
import 'package:n42_chat/src/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/presentation/pages/conversation/conversation_tile.dart';
import 'package:n42_chat/src/presentation/widgets/chat/chat_input_bar.dart';
import 'package:n42_chat/src/presentation/widgets/common/chat_navigation_bar.dart';
import 'package:n42_chat/src/presentation/widgets/common/contact_index_bar.dart';
import 'package:n42_chat/src/presentation/widgets/common/n42_empty_state.dart';
import 'package:n42_chat/src/presentation/widgets/common/n42_search_bar.dart';
import 'chat_ux_regression_test.dart' as review;

void main() {
  setUpAll(() async {
    if (Platform.environment['N42_UX_SCREENSHOTS'] == null) return;
    for (final entry in {
      'UXReview': '/System/Library/Fonts/Supplemental/Arial.ttf',
      'MaterialIcons':
          '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key);
      loader.addFont(
        File(entry.value).readAsBytes().then(ByteData.sublistView),
      );
      await loader.load();
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets('supporting text has readable contrast ${brightness.name}', (
      tester,
    ) async {
      double contrast(Color foreground, Color background) {
        final a = foreground.computeLuminance();
        final b = background.computeLuminance();
        return (math.max(a, b) + .05) / (math.min(a, b) + .05);
      }

      await tester.pumpWidget(
        review.app(
          Builder(
            builder: (context) {
              expect(
                contrast(context.textSupporting, context.surfaceColor),
                greaterThanOrEqualTo(4.5),
              );
              expect(
                contrast(
                  context.textSupporting,
                  AppColors.inputBgOf(context.isDarkMode),
                ),
                greaterThanOrEqualTo(4.5),
              );
              return const SizedBox();
            },
          ),
          brightness: brightness,
        ),
      );
    });
  }

  testWidgets('search detaches external controllers and binds replacements', (
    tester,
  ) async {
    final first = TextEditingController();
    final second = TextEditingController(text: 'Bob');
    final focus = FocusNode();
    final values = <String>[];
    Widget widget(TextEditingController controller) => review.app(
      Scaffold(
        body: N42SearchBar(
          controller: controller,
          focusNode: focus,
          onChanged: values.add,
        ),
      ),
    );
    await tester.pumpWidget(widget(first));
    await tester.enterText(find.byType(TextField), 'Alice');
    expect(values.last, 'Alice');
    await tester.pumpWidget(widget(second));
    first.text = 'ignored';
    await tester.pump();
    expect(values.last, 'Alice');
    expect(find.text('Bob'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();
    expect(values.last, '');
    await tester.pumpWidget(const SizedBox());
    second.text = 'after disposal';
    focus.requestFocus();
    await tester.pump();
    expect(tester.takeException(), isNull);
    first.dispose();
    second.dispose();
    focus.dispose();
  });

  testWidgets(
    'readonly search respects disabled state and has a large hit target',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        review.app(
          Scaffold(body: N42SearchBar(onTap: () => taps++, enabled: false)),
        ),
      );
      expect(
        tester.getSize(find.byType(N42SearchBar)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('Search'));
      expect(taps, 0);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'navigation badges update and expose full counts ${brightness.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final semantics = tester.ensureSemantics();

        var selected = 0;
        Widget scene(int pending) => review.app(
          Scaffold(
            bottomNavigationBar: ChatNavigationBar(
              selectedIndex: selected,
              unreadCount: 128,
              pendingContactCount: pending,
              onSelected: (value) => selected = value,
            ),
          ),
          brightness: brightness,
          scale: 2,
        );
        await tester.pumpWidget(scene(7));
        expect(find.text('99+'), findsOneWidget);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Contacts')).value,
          '7 pending requests',
        );
        expect(
          tester.getSemantics(find.bySemanticsLabel('Messages')).value,
          '128 unread',
        );
        final tab = find.byKey(const ValueKey('chat_tab_1'));
        expect(tester.getSize(tab).height, greaterThanOrEqualTo(48));
        await tester.tap(tab);
        expect(selected, 1);
        await tester.pumpWidget(scene(0));
        await tester.pumpAndSettle();
        expect(find.text('7'), findsNothing);
        expect(
          tester
              .getSemantics(find.bySemanticsLabel('Contacts'))
              .hasFlag(SemanticsFlag.isSelected),
          isTrue,
        );
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );

    testWidgets(
      'composer controls and conversation rows fit enlarged text ${brightness.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        String? sent;
        final key = GlobalKey();
        await tester.pumpWidget(
          review.app(
            RepaintBoundary(
              key: key,
              child: Scaffold(
                body: const Column(
                  children: [
                    Padding(padding: EdgeInsets.all(16), child: N42SearchBar()),
                    ConversationTile(
                      conversation: ConversationEntity(
                        id: 'fixture',
                        name: 'Design team',
                        type: ConversationType.group,
                        lastMessage: 'Ready for tomorrow',
                        draft: 'Review the new design',
                        unreadCount: 4,
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: ChatInputBar(
                  showVoiceButton: true,
                  onQuickReplyPressed: () {},
                  onEmojiPressed: () {},
                  onCameraPressed: () {},
                  onMorePressed: () {},
                  onSendText: (text) => sent = text,
                ),
              ),
            ),
            brightness: brightness,
            scale: 1.5,
          ),
        );
        final attachment = find.byKey(
          const ValueKey('chat_input_attachment_toggle'),
        );
        expect(tester.getSize(attachment).width, greaterThanOrEqualTo(48));
        final input = find.descendant(
          of: find.byType(ChatInputBar),
          matching: find.byType(TextField),
        );
        await tester.enterText(input, 'Hello');
        await tester.pump();
        final send = find
            .ancestor(
              of: find.byIcon(Icons.send),
              matching: find.byType(InkWell),
            )
            .first;
        expect(tester.getSize(send).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(send).height, greaterThanOrEqualTo(48));
        await review.capture(tester, key, 'composer-${brightness.name}');
        await tester.tap(send);
        expect(sent, 'Hello');
        expect(find.text('Draft '), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'short-screen contact index keeps all letters and supports accessibility adjustment',
    (tester) async {
      final semantics = tester.ensureSemantics();

      final letters = [
        '🔍',
        '☆',
        ...List.generate(26, (i) => String.fromCharCode(65 + i)),
        '#',
      ];
      String? selected;
      await tester.pumpWidget(
        review.app(
          Scaffold(
            body: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 48,
                height: 240,
                child: ContactIndexBar(
                  letters: letters,
                  onLetterTap: (letter) => selected = letter,
                ),
              ),
            ),
          ),
        ),
      );
      for (final letter in letters.skip(2)) {
        expect(find.text(letter), findsOneWidget);
      }
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.star_outline), findsOneWidget);
      await tester.tap(find.text('Z'));
      await tester.pump();
      expect(selected, 'Z');
      final node = tester.getSemantics(find.bySemanticsLabel('Contact index'));
      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.increase,
      );
      await tester.pump();
      expect(selected, '#');
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('empty-state retry remains reachable on short screens', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      review.app(
        Scaffold(
          body: SizedBox(
            height: 180,
            child: N42EmptyState(
              icon: Icons.cloud_off,
              title: 'Connection interrupted',
              description: 'Check the connection and try again.',
              buttonText: 'Retry',
              onButtonPressed: () => retried = true,
            ),
          ),
        ),
        scale: 2,
      ),
    );
    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
    expect(tester.takeException(), isNull);
  });
}
