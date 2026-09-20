import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/core/di/injection.dart';
import 'package:n42_chat/src/data/datasources/local/preferences_datasource.dart';
import 'package:n42_chat/src/domain/entities/conversation_entity.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_event.dart';
import 'package:n42_chat/src/presentation/blocs/chat/chat_state.dart';
import 'package:n42_chat/src/presentation/pages/chat/chat_page.dart';
import 'package:n42_chat/src/presentation/pages/chat/message_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Chat extends MockBloc<ChatEvent, ChatState> implements ChatBloc {}

void main() {
  for (final locale in [
    const Locale('en'),
    const Locale('zh'),
    const Locale('ar'),
  ]) {
    testWidgets(
      'encrypted message exposes recovery on narrow ${locale.languageCode} screens',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: S.localizationsDelegates,
            supportedLocales: S.supportedLocales,
            home: Scaffold(
              body: MessageItem(
                message: MessageEntity(
                  id: 'encrypted',
                  roomId: '!room:test',
                  senderId: '@bob:test',
                  senderName: 'Bob',
                  content: '',
                  type: MessageType.encrypted,
                  timestamp: DateTime(2026),
                ),
                onTap: () => tapped = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final placeholder = find.byKey(
          const ValueKey<String>('chat_encrypted_placeholder'),
        );
        expect(placeholder, findsOneWidget);
        final label = S.of(tester.element(placeholder))!.chatMessageUnavailable;
        expect(find.textContaining(label), findsOneWidget);
        await tester.tap(placeholder);
        expect(tapped, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'leaving chat removes its file action and keeps parent notifications',
    (tester) async {
      await getIt.reset();
      SharedPreferences.setMockInitialValues({});
      getIt.registerSingleton<PreferencesDataSource>(PreferencesDataSource());
      final chat = _Chat();
      when(() => chat.state).thenReturn(
        ChatState(
          messages: [
            MessageEntity(
              id: 'file',
              roomId: '!room:test',
              senderId: '@bob:test',
              senderName: 'Bob',
              content: 'archive.zip',
              type: MessageType.file,
              timestamp: DateTime(2026),
              metadata: const MessageMetadata(
                fileName: 'archive.zip',
                httpUrl: 'https://files.test/archive.zip',
              ),
            ),
          ],
          canSendMessages: false,
        ),
      );
      final navigator = GlobalKey<NavigatorState>();
      final rootMessenger = GlobalKey<ScaffoldMessengerState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          scaffoldMessengerKey: rootMessenger,
          locale: const Locale('en'),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Open chat'),
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<ChatBloc>.value(
                      value: chat,
                      child: const ChatPage(
                        conversation: ConversationEntity(
                          id: '!room:test',
                          name: 'Bob',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open chat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('archive.zip'));
      await tester.pump();
      expect(find.text('Download'), findsOneWidget);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('Download'), findsNothing);
      expect(find.textContaining('Download file:'), findsNothing);
      rootMessenger.currentState!.showSnackBar(
        const SnackBar(content: Text('Parent notification')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Parent notification'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await getIt.reset();
    },
  );
}
