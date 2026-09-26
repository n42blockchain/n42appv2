import 'package:reown_core/store/i_generic_store.dart';
import 'package:reown_core/store/i_store.dart';
import 'package:reown_core/utils/constants.dart';
import 'package:reown_walletkit/reown_walletkit.dart'
    show
        Event,
        StoreCreateEvent,
        StoreUpdateEvent,
        StoreDeleteEvent,
        StoreErrorEvent,
        StoreSyncEvent;

/// Reown's keychain contract with persistence before observable state changes.
class N42ReownKeychain implements IGenericStore<String> {
  N42ReownKeychain({required this.storage, this.onPersistenceFailure});

  /// Called after this instance becomes unusable; host disconnects its client.
  Future<void> Function(Object error)? onPersistenceFailure;

  @override
  final IStore<Map<String, dynamic>> storage;
  @override
  String get context => StoreVersions.CONTEXT_KEYCHAIN;
  @override
  String get version => StoreVersions.VERSION_KEYCHAIN;
  @override
  String get storageKey => '$version//$context';
  @override
  String Function(dynamic) get fromJson =>
      (dynamic value) => value as String;

  @override
  final Event<StoreCreateEvent<String>> onCreate = Event();
  @override
  final Event<StoreUpdateEvent<String>> onUpdate = Event();
  @override
  final Event<StoreDeleteEvent<String>> onDelete = Event();
  @override
  final Event<StoreErrorEvent<String>> onError = Event();
  @override
  final Event<StoreSyncEvent> onSync = Event();

  Map<String, String> _data = {};
  Future<void> _pending = Future<void>.value();
  bool _initialized = false;
  bool _failed = false;

  bool get isUnusable => _failed;

  @override
  Future<void> init() async {
    if (_initialized) {
      _checkReady();
      return;
    }
    if (_failed) throw StateError('Reown keychain is unusable');
    try {
      await storage.init();
      await restore();
      _initialized = true;
    } catch (error) {
      _failed = true;
      throw StateError('Reown keychain restore failed: $error');
    }
  }

  @override
  Future<void> restore() async {
    if (_failed) throw StateError('Reown keychain is unusable');
    final metadata = storage.get(context);
    final records = storage.get(storageKey);
    if (metadata == null) {
      if (records != null) {
        throw StateError('Reown keychain data has no version');
      }
      await storage.set(context, {'version': version});
      _data = {};
      return;
    }
    if (metadata['version'] != version) {
      throw StateError('Unsupported Reown keychain version');
    }
    final restored = <String, String>{};
    for (final entry in (records ?? <String, dynamic>{}).entries) {
      restored[entry.key] = fromJson(entry.value);
    }
    _data = restored;
  }

  @override
  bool has(String key) {
    _checkReady();
    return _data.containsKey(key);
  }

  @override
  String? get(String key) {
    _checkReady();
    return _data[key];
  }

  @override
  List<String> getAll() {
    _checkReady();
    return List.unmodifiable(_data.values);
  }

  @override
  Future<void> set(String key, String value) => _serialize(() async {
    final wasPresent = _data.containsKey(key);
    final candidate = Map<String, String>.of(_data)..[key] = value;
    await storage.set(storageKey, candidate);
    _data = candidate;
    if (wasPresent) {
      onUpdate.broadcast(StoreUpdateEvent(key, value));
    } else {
      onCreate.broadcast(StoreCreateEvent(key, value));
    }
    onSync.broadcast(StoreSyncEvent());
  });

  @override
  Future<void> delete(String key) => _serialize(() async {
    final oldValue = _data[key];
    if (oldValue == null) return;
    final candidate = Map<String, String>.of(_data)..remove(key);
    await storage.set(storageKey, candidate);
    _data = candidate;
    onDelete.broadcast(StoreDeleteEvent(key, oldValue));
    onSync.broadcast(StoreSyncEvent());
  });

  @override
  Future<void> persist() => _serialize(() async {
    await storage.set(storageKey, Map<String, String>.of(_data));
    onSync.broadcast(StoreSyncEvent());
  });

  Future<void> _serialize(Future<void> Function() action) {
    _checkReady();
    final operation = _pending.then((_) async {
      _checkReady();
      try {
        await action();
      } catch (error) {
        _failed = true;
        try {
          await onPersistenceFailure?.call(error);
        } catch (_) {
          // Preserve the original storage failure for the SDK caller.
        }
        rethrow;
      }
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  void _checkReady() {
    if (!_initialized || _failed)
      throw StateError('Reown keychain is unusable');
  }
}
