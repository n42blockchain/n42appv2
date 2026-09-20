import 'package:matrix/matrix.dart';

/// Keeps durable inbound ratchets visible before Matrix processes new room keys.
///
/// Matrix 6.x compares a received key only with its in-memory session. After
/// reopening a device, a re-shared key at index N can otherwise replace the
/// database's index-0 key, making previously readable messages unreadable.
class SessionPreservingClient extends Client {
  SessionPreservingClient(
    super.clientName, {
    required super.database,
    super.httpClient,
    super.supportedLoginTypes,
    super.shareKeysWith,
    super.logLevel,
    super.importantStateEvents,
    super.syncFilter,
  });

  Object? _loadedEncryption;
  Future<void>? _loadingSessions;

  Future<void> _loadStoredSessions() async {
    final current = encryption;
    if (current == null || identical(current, _loadedEncryption)) return;
    final pending = _loadingSessions;
    if (pending != null) return pending;
    final operation = () async {
      final sessions = await database.getAllInboundGroupSessions();
      for (final session in sessions) {
        if (!identical(encryption, current)) {
          throw StateError(
            'Encryption identity changed during session loading',
          );
        }
        await current.keyManager.loadInboundGroupSession(
          session.roomId,
          session.sessionId,
        );
      }
      _loadedEncryption = current;
    }();
    _loadingSessions = operation;
    try {
      await operation;
    } finally {
      _loadingSessions = null;
    }
  }

  @override
  Future<SyncUpdate> sync({
    String? filter,
    String? since,
    bool? fullState,
    PresenceType? setPresence,
    int? timeout,
    bool? useStateAfter,
  }) async {
    // init() starts sync itself. Loading after init returns is already too late.
    // Fail closed if disk loading fails; do not acknowledge/process new keys.
    await _loadStoredSessions();
    return super.sync(
      filter: filter,
      since: since,
      fullState: fullState,
      setPresence: setPresence,
      timeout: timeout,
      useStateAfter: useStateAfter,
    );
  }
}
