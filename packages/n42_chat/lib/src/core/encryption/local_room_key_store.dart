import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/encryption/utils/stored_inbound_group_session.dart';

/// Device-local history keys, isolated by homeserver and authenticated user.
/// No access tokens, passwords, Olm identities or outbound ratchets are retained.
class LocalRoomKeyStore {
  final FlutterSecureStorage storage;
  LocalRoomKeyStore({FlutterSecureStorage? storage})
    : storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  String? _scope(Client client) {
    final user = client.userID;
    final server = client.homeserver;
    if (user == null || server == null) return null;
    return _identityScope(server, user);
  }

  String _identityScope(Uri server, String user) {
    final normalized = server.removeFragment().toString().replaceFirst(
      RegExp(r'/+$'),
      '',
    );
    return 'n42_chat_history_keys_${sha256.convert(utf8.encode(jsonEncode([normalized, user])))}';
  }

  Future<List<StoredInboundGroupSession>> _read(String scope) async {
    final raw = await storage.read(key: scope);
    if (raw == null) return [];
    final value = jsonDecode(raw) as Map<String, dynamic>;
    if (value['version'] != 1)
      throw StateError('Unsupported local key snapshot');
    return (value['sessions'] as List)
        .map(
          (item) => StoredInboundGroupSession.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> preserve(Client client) async {
    final scope = _scope(client);
    if (scope == null) return;
    try {
      final current = await client.database.getAllInboundGroupSessions();
      if (current.isEmpty) return;
      final previous = await _read(scope);
      // Preserve old history even if a later login has only a subset of keys.
      final sessions = <String, StoredInboundGroupSession>{};
      for (final session in [...current, ...previous]) {
        final id = jsonEncode([session.roomId, session.sessionId]);
        final latest = sessions[id];
        sessions[id] = latest == null
            ? session
            : StoredInboundGroupSession(
                roomId: session.roomId,
                sessionId: session.sessionId,
                pickle: session.pickle,
                content: session.content,
                // Keep replay detection learned since the previous logout.
                indexes: jsonEncode({
                  ...Map<String, dynamic>.from(
                    jsonDecode(session.indexes) as Map,
                  ),
                  ...Map<String, dynamic>.from(
                    jsonDecode(latest.indexes) as Map,
                  ),
                }),
                allowedAtIndex: session.allowedAtIndex,
                senderKey: session.senderKey,
                senderClaimedKeys: session.senderClaimedKeys,
              );
      }
      final encoded = jsonEncode({
        'version': 1,
        'sessions': sessions.values.map((s) => s.toJson()).toList(),
      });
      await storage.write(key: scope, value: encoded);
      if (await storage.read(key: scope) != encoded) {
        throw StateError('Local key snapshot verification failed');
      }
    } catch (_) {
      // Never include native storage errors or key contents in UI/log output.
      throw LocalRoomKeyPreservationException();
    }
  }

  Future<void> restore(Client client) async {
    final scope = _scope(client);
    if (scope == null) return;
    final sessions = await _read(scope);
    for (final session in sessions) {
      if (_scope(client) != scope) throw StateError('Account changed');
      if (await client.database.getInboundGroupSession(
            session.roomId,
            session.sessionId,
          ) !=
          null)
        continue;
      if (_scope(client) != scope) throw StateError('Account changed');
      await client.database.storeInboundGroupSession(
        session.roomId,
        session.sessionId,
        session.pickle,
        session.content,
        session.indexes,
        session.allowedAtIndex,
        session.senderKey,
        session.senderClaimedKeys,
      );
    }
    if (sessions.isNotEmpty)
      client.encryption?.keyManager.clearInboundGroupSessions();
  }

  Future<void> deleteForIdentity(Uri homeserver, String userId) async {
    await storage.delete(key: _identityScope(homeserver, userId));
  }
}

class LocalRoomKeyPreservationException implements Exception {
  @override
  String toString() =>
      'Unable to preserve encrypted chat history. Please retry logout.';
}
