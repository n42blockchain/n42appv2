import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/live/prediction/data/matrix_prediction_repository.dart';
import 'package:n42_wallet/features/live/prediction/data/prediction_replay.dart';
import 'package:n42_wallet/features/live/prediction/domain/prediction_repository.dart';
import 'package:n42_wallet/features/live/services/live_chat_service.dart';

void main() {
  test('successful create is visible before Matrix timeline echo', () async {
    const roomId = '!room:m.example';
    final chat = _FakeLiveChatService();
    final repo = MatrixPredictionRepository(chat);
    final values = <int>[];
    final initial = Completer<void>();
    final sub = repo.watchMarkets(roomId).listen((markets) {
      values.add(markets.length);
      if (!initial.isCompleted) initial.complete();
    });
    await initial.future;
    await _flush();

    final market = await repo.createMarket(
      roomId: roomId,
      question: 'Will live work?',
      outcomeLabels: const ['Yes', 'No'],
    );
    await _flush();

    expect(chat.sentEvents, hasLength(1));
    final sent = chat.sentEvents.single;
    expect(sent['t'], 'pred');
    expect(sent['a'], 'create');
    expect(sent['m'], isA<String>());
    expect(PredictionLimits.hasValidMarketId(sent['m']! as String), isTrue);
    expect(sent['room'], roomId);
    expect(sent['q'], 'Will live work?');
    expect(sent['o'], const ['Yes', 'No']);
    expect(
      PredEvent.tryParse(
        sender: chat.myUserId!,
        timestamp: DateTime.now(),
        data: sent,
      ),
      isNotNull,
    );
    expect(await repo.watchMarkets(roomId).first, hasLength(1));
    expect(values, contains(1));

    chat.emit([
      LiveEvent(
        id: r'$server-event',
        senderId: chat.myUserId!,
        senderName: 'Host',
        isMe: true,
        timestamp: DateTime.now(),
        data: chat.sentEvents.single,
      ),
    ]);
    await _flush();

    expect(values.last, 1, reason: 'server echo must replace, not duplicate');
    expect(market.id, chat.sentEvents.single['m']);

    await sub.cancel();
    repo.dispose();
    await chat.dispose();
  });

  test('failed send never creates an optimistic market', () async {
    const roomId = '!room:m.example';
    final chat = _FakeLiveChatService(failSend: true);
    final repo = MatrixPredictionRepository(chat);
    final values = <int>[];
    final initial = Completer<void>();
    final sub = repo.watchMarkets(roomId).listen((markets) {
      values.add(markets.length);
      if (!initial.isCompleted) initial.complete();
    });
    await initial.future;
    await _flush();

    await expectLater(
      repo.createMarket(
        roomId: roomId,
        question: 'Will this fail?',
        outcomeLabels: const ['Yes', 'No'],
      ),
      throwsA(isA<StateError>()),
    );
    await _flush();

    expect(values, isNot(contains(1)));

    await sub.cancel();
    repo.dispose();
    await chat.dispose();
  });

  test('another device replays a JSON-decoded create event', () async {
    const roomId = '!room:m.example';
    final chat = _FakeLiveChatService();
    final repo = MatrixPredictionRepository(chat);
    final sub = repo.watchMarkets(roomId).listen((_) {});
    await _flush();

    final decoded =
        jsonDecode(
              jsonEncode({
                't': 'pred',
                'a': 'create',
                'm': '$roomId~server-event',
                'room': roomId,
                'q': 'Visible on the viewer?',
                'o': ['Yes', 'No'],
              }),
            )
            as Map<String, dynamic>;
    chat.emit([
      LiveEvent(
        id: r'$remote-event',
        senderId: '@broadcaster:m.example',
        senderName: 'Broadcaster',
        isMe: false,
        timestamp: DateTime.now(),
        data: decoded,
      ),
    ]);
    await _flush();

    final markets = await repo.watchMarkets(roomId).first;
    expect(markets, hasLength(1));
    expect(markets.single.question, 'Visible on the viewer?');

    await sub.cancel();
    repo.dispose();
    await chat.dispose();
  });
}

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeLiveChatService extends LiveChatService {
  _FakeLiveChatService({this.failSend = false});

  final bool failSend;
  final _events = StreamController<List<LiveEvent>>.broadcast();
  final List<Map<String, dynamic>> sentEvents = [];

  @override
  String? get myUserId => '@host:m.example';

  @override
  Stream<List<LiveEvent>> watchEvents(String roomId) async* {
    yield const <LiveEvent>[];
    yield* _events.stream;
  }

  @override
  Future<void> sendEvent(String roomId, Map<String, dynamic> data) async {
    if (failSend) throw StateError('send failed');
    sentEvents.add(Map<String, dynamic>.from(data));
  }

  void emit(List<LiveEvent> events) => _events.add(events);

  Future<void> dispose() => _events.close();
}
