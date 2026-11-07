// ignore: depend_on_referenced_packages
import 'package:matrix/matrix.dart';

/// Create the broadcast marker atomically with the room, before any token can
/// be requested. An inactive marker reserves publisher-only room semantics
/// without advertising a stream that has not started yet.
Future<String> createLiveBroadcastRoom(Client client, {required String name}) {
  return client.createRoom(
    name: name.trim().isEmpty ? '直播' : name.trim(),
    preset: CreateRoomPreset.publicChat,
    visibility: Visibility.public,
    initialState: [
      StateEvent(
        type: 'n42.live.status',
        stateKey: '',
        content: {'live': false},
      ),
    ],
  );
}
