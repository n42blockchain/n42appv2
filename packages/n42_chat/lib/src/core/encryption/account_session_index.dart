import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locates independent SDK databases. Contains no tokens or encryption keys.
/// The existing single-account database is registered in place on first use.
class AccountSessionIndex {
  static const _key = 'n42_chat_account_session_index_v1';

  static String identity(Uri server, String user, String device) => sha256
      .convert(
        utf8.encode(
          jsonEncode([
            server.removeFragment().toString().replaceFirst(RegExp(r'/+$'), ''),
            user,
            device,
          ]),
        ),
      )
      .toString();

  String newDatabaseName() =>
      'N42Chat_${List.generate(16, (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';

  bool _validName(String name) =>
      RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,127}$').hasMatch(name);

  Future<Map<String, dynamic>> _read() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null)
      return {'active': 'N42Chat', 'sessions': <String, dynamic>{}};
    final value = jsonDecode(raw) as Map<String, dynamic>;
    if (value['sessions'] is! Map ||
        value['active'] is! String ||
        !_validName(value['active'] as String)) {
      throw const FormatException('Invalid account session index');
    }
    return value;
  }

  Future<String> activeDatabaseName() async =>
      (await _read())['active'] as String;

  Future<String?> lookup(Uri server, String user, String device) async {
    final value = (await _read())['sessions'] as Map;
    final name = value[identity(server, user, device)];
    if (name == null) return null;
    if (name is! String || !_validName(name))
      throw const FormatException('Invalid account database');
    return name;
  }

  Future<void> remember(
    Uri server,
    String user,
    String device,
    String name,
  ) async {
    if (!_validName(name)) throw ArgumentError('Invalid account database');
    final value = await _read();
    final sessions = Map<String, dynamic>.from(value['sessions'] as Map);
    final scope = identity(server, user, device);
    // Never associate two different devices/accounts with one SDK database.
    if (sessions.entries.any((e) => e.key != scope && e.value == name)) {
      throw StateError('Account database is already owned');
    }
    sessions[scope] = name;
    if (!await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode({'active': name, 'sessions': sessions}),
    )) {
      throw StateError('Unable to save account session index');
    }
  }

  Future<void> forget(Uri server, String user, String device) async {
    final value = await _read();
    (value['sessions'] as Map).remove(identity(server, user, device));
    if (!await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode(value),
    )) {
      throw StateError('Unable to update account session index');
    }
  }
}
