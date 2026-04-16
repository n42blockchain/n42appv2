import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';
import 'package:n42_chat/src/domain/entities/search_result_entity.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_bloc.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_event.dart';
import 'package:n42_chat/src/presentation/blocs/search/search_state.dart';
import 'package:n42_chat/src/presentation/pages/search/chat_search_page.dart';

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

Widget _buildPage({required SearchBloc bloc, required Widget child}) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: BlocProvider<SearchBloc>.value(value: bloc, child: child),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ClearSearch());
    registerFallbackValue(const SearchInitial());
  });

  group('ChatSearchPage', () {
    late MockSearchBloc bloc;

    setUp(() {
      bloc = MockSearchBloc();
      when(() => bloc.state).thenReturn(const SearchInitial());
      whenListen(
        bloc,
        const Stream<SearchState>.empty(),
        initialState: const SearchInitial(),
      );
    });

    testWidgets('prefills the query and dispatches room search', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildPage(
          bloc: bloc,
          child: const ChatSearchPage(
            roomId: '!room:test',
            initialQuery: 'hello',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('hello'), findsOneWidget);
      verify(
        () => bloc.add(const SearchInChat('!room:test', 'hello')),
      ).called(1);
    });

    testWidgets('returns the selected message id when configured to pop', (
      tester,
    ) async {
      final message = MessageEntity(
        id: 'm1',
        roomId: '!room:test',
        senderId: '@alice:test',
        senderName: 'Alice',
        content: 'hello world',
        type: MessageType.text,
        timestamp: DateTime(2026, 3, 22, 9, 30),
      );

      final searchState = ChatSearchState(
        results: ChatSearchResults(
          roomId: '!room:test',
          query: 'hello',
          messages: [message],
        ),
      );
      when(() => bloc.state).thenReturn(searchState);
      whenListen(
        bloc,
        Stream<SearchState>.fromIterable([searchState]),
        initialState: searchState,
      );

      String? selectedMessageId;

      await tester.pumpWidget(
        _buildPage(
          bloc: bloc,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    selectedMessageId = await Navigator.of(context)
                        .push<String>(
                          MaterialPageRoute<String>(
                            builder: (_) => BlocProvider<SearchBloc>.value(
                              value: bloc,
                              child: const ChatSearchPage(
                                roomId: '!room:test',
                                returnSelectedMessageId: true,
                              ),
                            ),
                          ),
                        );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('hello world'), findsOneWidget);

      await tester.tap(find.text('hello world'));
      await tester.pumpAndSettle();

      expect(selectedMessageId, 'm1');
    });
  });
}
