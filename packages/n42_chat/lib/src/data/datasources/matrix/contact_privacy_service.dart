import 'dart:async';
import 'dart:convert';

import 'package:matrix/matrix.dart' as matrix;

import 'matrix_client_manager.dart';
import '../../../core/utils/timed_status_utils.dart';

/// Account-scoped social permissions. Outbound access uses room membership;
/// room state also filters content already held by cooperating clients.
class ContactPrivacyService {
  static const accountType = 'n42.contact.permissions';
  static const policyType = 'n42.social.permissions';
  static const momentTag = 'n42.moments';
  static const storyTag = 'n42.stories';
  static const momentReason = 'n42_moments';
  static const storyReason = 'n42_stories';
  static final _instances = Expando<ContactPrivacyService>();
  factory ContactPrivacyService(MatrixClientManager manager) =>
      _instances[manager] ??= ContactPrivacyService._(manager);
  ContactPrivacyService._(this._manager);
  final MatrixClientManager _manager;
  final _changes = StreamController<void>.broadcast();
  Stream<void> get changes => _changes.stream;
  matrix.Client? get _client => _manager.client;

  Map<String, dynamic> get all => Map<String, dynamic>.from(
    _client?.accountData[accountType]?.content ?? const {},
  );
  Map<String, dynamic> forUser(String userId) =>
      Map<String, dynamic>.from(all[userId] as Map? ?? const {});
  bool hides(String userId, {bool story = false, bool incoming = false}) {
    final data = forUser(userId);
    if (data['chatOnly'] == true) return true;
    if (incoming) return !story && data['hideTheirMoments'] == true;
    return data[story ? 'hideMyStatus' : 'hideMyMoments'] == true;
  }

  static bool isSocialRoom(matrix.Room room) =>
      room.tags.containsKey(momentTag) ||
      room.tags.containsKey(storyTag) ||
      room.getState('n42.social.type') != null;

  String? owner(matrix.Room room) =>
      room.getState(matrix.EventTypes.RoomCreate)?.senderId;
  bool isOwn(matrix.Room room) =>
      _client?.userID != null &&
      owner(room) == _client!.userID &&
      room.membership == matrix.Membership.join;

  bool canView(matrix.Room room, String author, {bool story = false}) {
    final me = _client?.userID;
    if (me == null || room.membership != matrix.Membership.join) return false;
    if (author == me) return true;
    if (hides(author, incoming: true, story: story)) return false;
    final policy = room.getState(policyType)?.content;
    final blocked = policy?[story ? 'status' : 'moments'];
    return blocked is! List || !blocked.contains(me);
  }

  Future<Map<String, dynamic>> load(String userId) async {
    final client = _client;
    if (client == null || client.userID == null)
      throw StateError('No active account');
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(
        await client.getAccountData(client.userID!, accountType),
      );
    } on matrix.MatrixException catch (e) {
      if (e.errcode != 'M_NOT_FOUND') rethrow;
      data = {};
    }
    if (!identical(client, _client)) throw StateError('Account changed');
    client.accountData[accountType] = matrix.BasicEvent(
      type: accountType,
      content: data,
    );
    return forUser(userId);
  }

  Future<void>? _saveQueue;
  Future<void> save(String userId, Map<String, dynamic> permissions) {
    final client = _client;
    final accountId = client?.userID;
    Future<void> run() async {
      if (!identical(client, _client) || accountId != _client?.userID)
        throw StateError('Account changed');
      await _save(userId, permissions);
    }

    final operation = _saveQueue == null
        ? run()
        : _saveQueue!.then((_) => run());
    _saveQueue = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> _save(String userId, Map<String, dynamic> permissions) async {
    final client = _client;
    if (client == null || client.userID == null)
      throw StateError('No active account');
    if (!userId.startsWith('@') || userId == client.userID)
      throw ArgumentError('Invalid friend');
    final accountId = client.userID!;
    // Refresh before merging to preserve settings changed on another device.
    await load(userId);
    if (!identical(client, _client) || client.userID != accountId)
      throw StateError('Account changed');
    final next = {...all, userId: permissions};
    await client.setAccountData(client.userID!, accountType, next);
    if (!identical(client, _client)) throw StateError('Account changed');
    client.accountData[accountType] = matrix.BasicEvent(
      type: accountType,
      content: next,
    );
    _changes.add(null);
    final legacy = client.rooms
        .where((room) => isOwn(room) && room.tags.containsKey(momentTag))
        .toList();
    if ((legacy.isNotEmpty && permissions['hideMyMoments'] == true) ||
        permissions['chatOnly'] == true ||
        permissions['hideMyStatus'] == true) {
      final statusRoom = await ownRoom(story: true);
      if (statusRoom == null) throw StateError('Status room unavailable');
      await apply(statusRoom, story: true, restoreUser: userId);
      await _separateLegacyStatuses(legacy, statusRoom);
      if (permissions['hideMyStatus'] == true ||
          permissions['chatOnly'] == true) {
        final presence = await client.getPresence(client.userID!);
        Map<String, dynamic> status;
        try {
          status = Map<String, dynamic>.from(
            await client.getAccountData(client.userID!, 'n42.user.status'),
          );
        } on matrix.MatrixException catch (e) {
          if (e.errcode != 'M_NOT_FOUND') rethrow;
          status = TimedStatusMetadata(message: presence.statusMsg).toJson();
        }
        await publishStatus(status, presenceType: presence.presence);
      }
    }
    // Do not report success before server membership and policy updates succeed.
    for (final room in client.rooms.where(isOwn).toList()) {
      if (room.tags.containsKey(momentTag) || room.tags.containsKey(storyTag)) {
        await apply(
          room,
          story: room.tags.containsKey(storyTag),
          restoreUser: userId,
        );
      }
    }
  }

  /// Personal text status must not remain globally readable through presence.
  Future<void> publishStatus(
    Map<String, dynamic> status, {
    matrix.PresenceType? presenceType,
  }) async {
    final client = _client;
    if (client == null || client.userID == null)
      throw StateError('No active account');
    final presence =
        presenceType ?? (await client.getPresence(client.userID!)).presence;
    final room = await ownRoom(story: true);
    if (room == null) throw StateError('Status room unavailable');
    await apply(room, story: true);
    final metadata = TimedStatusMetadata.fromJson(status);
    await client.setRoomStateWithKey(
      room.id,
      'n42.user.status',
      '',
      metadata.isExpired ? {} : status,
    );
    await client.setPresence(client.userID!, presence, statusMsg: '');
  }

  Future<void> _separateLegacyStatuses(
    List<matrix.Room> rooms,
    matrix.Room destination,
  ) async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final target = await destination.getTimeline();
    try {
      final copied = target.events
          .where((e) => e.type == 'n42.story' && !e.redacted)
          .map((e) => e.content['story_id'])
          .toSet();
      for (final room in rooms) {
        final timeline = await room.getTimeline();
        try {
          while (timeline.canRequestHistory &&
              (timeline.events.isEmpty ||
                  !timeline.events.any(
                    (e) => e.originServerTs.isBefore(cutoff),
                  ))) {
            final previousCount = timeline.events.length;
            await timeline.requestHistory();
            if (timeline.canRequestHistory &&
                timeline.events.length == previousCount) {
              throw StateError('Status history synchronization stalled');
            }
          }
          for (final event in List<matrix.Event>.of(timeline.events)) {
            if (event.type != 'n42.story' ||
                event.redacted ||
                event.senderId != _client?.userID)
              continue;
            final expiry = DateTime.tryParse(
              event.content['expires_at'] as String? ?? '',
            );
            if (expiry != null && expiry.isAfter(DateTime.now())) {
              final id = event.content['story_id'];
              if (!copied.contains(id)) {
                await destination.sendEvent(event.content, type: 'n42.story');
                copied.add(id);
              }
            }
            // Revoke the legacy shared-room copy only after the replacement was sent.
            await room.redactEvent(event.eventId);
          }
        } finally {
          timeline.cancelSubscriptions();
        }
      }
    } finally {
      target.cancelSubscriptions();
    }
  }

  Future<void> apply(
    matrix.Room room, {
    bool story = false,
    String? restoreUser,
  }) async {
    final client = _client;
    if (client == null || !isOwn(room))
      throw StateError('Not an owned social room');
    final policy = {
      'moments': all.keys.where((id) => hides(id)).toList()..sort(),
      'status': all.keys.where((id) => hides(id, story: true)).toList()..sort(),
    };
    if (jsonEncode(room.getState(policyType)?.content) != jsonEncode(policy)) {
      await client.setRoomStateWithKey(room.id, policyType, '', policy);
    }
    // A removed reader must not be able to rejoin or fetch later history.
    if (room.getState(matrix.EventTypes.RoomJoinRules)?.content['join_rule'] !=
        'invite') {
      await client.setRoomStateWithKey(
        room.id,
        matrix.EventTypes.RoomJoinRules,
        '',
        {'join_rule': 'invite'},
      );
    }
    if (room
            .getState('m.room.history_visibility')
            ?.content['history_visibility'] !=
        'joined') {
      await client.setRoomStateWithKey(
        room.id,
        'm.room.history_visibility',
        '',
        {'history_visibility': 'joined'},
      );
    }
    for (final id in all.keys) {
      if (id == client.userID) continue;
      final membership = room
          .getState(matrix.EventTypes.RoomMember, id)
          ?.content['membership'];
      if (hides(id, story: story)) {
        if (membership != 'ban')
          await client.ban(room.id, id, reason: 'Contact privacy');
      } else if (id == restoreUser && membership == 'ban') {
        await client.unban(room.id, id);
        await client.inviteUser(
          room.id,
          id,
          reason: story ? storyReason : momentReason,
        );
      }
    }
  }

  Future<matrix.Room?> ownRoom({bool story = false}) async {
    final client = _client;
    if (client == null || client.userID == null) return null;
    final tag = story ? storyTag : momentTag;
    for (final room in client.rooms) {
      if (room.tags.containsKey(tag) && isOwn(room)) return room;
    }
    if (!identical(_creationClient, client)) {
      _creationClient = client;
      _creating.clear();
    }
    final pending = _creating[story];
    if (pending != null) return pending;
    final future = _createRoom(client, story: story);
    _creating[story] = future;
    try {
      return await future;
    } finally {
      if (identical(_creating[story], future)) _creating.remove(story);
    }
  }

  matrix.Client? _creationClient;
  final Map<bool, Future<matrix.Room?>> _creating = {};
  Future<matrix.Room?> _createRoom(
    matrix.Client client, {
    required bool story,
  }) async {
    final tag = story ? storyTag : momentTag;
    final id = await client.createRoom(
      name: story ? 'My Status' : 'My Moments',
      visibility: matrix.Visibility.private,
      preset: matrix.CreateRoomPreset.privateChat,
      initialState: [
        matrix.StateEvent(
          type: 'n42.social.type',
          stateKey: '',
          content: {'kind': story ? 'status' : 'moments'},
        ),
        matrix.StateEvent(
          type: 'm.room.history_visibility',
          stateKey: '',
          content: {'history_visibility': 'joined'},
        ),
      ],
      powerLevelContentOverride: {
        'events': {'n42.moment': 50, 'n42.story': 50, policyType: 100},
        'events_default': 0,
        'state_default': 100,
        'invite': 100,
        'ban': 100,
        'kick': 100,
        'redact': 100,
      },
    );
    matrix.Room? room;
    for (var i = 0; i < 30; i++) {
      if (!identical(client, _client)) throw StateError('Account changed');
      room = client.getRoomById(id);
      if (room != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    if (room == null) throw StateError('Social room sync timed out');
    await room.addTag(tag);
    await apply(room, story: story);
    // Give the separate status room the same friends as the existing moment room,
    // excluding readers denied status access.
    if (story) {
      for (final other in client.rooms.where(isOwn)) {
        if (!other.tags.containsKey(momentTag)) continue;
        final members = await other.requestParticipants();
        for (final user in members) {
          if (user.id != client.userID &&
              !hides(user.id, story: true) &&
              (user.membership == matrix.Membership.join ||
                  user.membership == matrix.Membership.invite)) {
            await client.inviteUser(room.id, user.id, reason: storyReason);
          }
        }
      }
    }
    return room;
  }
}
