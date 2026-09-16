import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Private, device-local annotations, isolated by server, account and friend.
class FriendDetailsStore {
  final String key;
  FriendDetailsStore(String homeserver, String accountId, String friendId)
    : key =
          'friend_details_${sha256.convert(utf8.encode(jsonEncode([homeserver, accountId, friendId])))}';

  Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    return raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> save(Map<String, dynamic> details) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(key, jsonEncode(details))) {
      throw StateError('Contact details were not saved');
    }
  }

  Future<Directory> _directory() async =>
      Directory('${(await getApplicationSupportDirectory()).path}/$key');

  Future<File> photo(String name) async {
    if (!RegExp(r'^\d+\.jpg$').hasMatch(name)) {
      throw ArgumentError('Invalid contact photo name');
    }
    return File('${(await _directory()).path}/$name');
  }

  Future<String> importPhoto(XFile image) async {
    final directory = await _directory();
    await directory.create(recursive: true);
    final name = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final destination = File('${directory.path}/$name');
    try {
      await image.saveTo(destination.path);
      return name;
    } catch (_) {
      if (await destination.exists()) await destination.delete();
      rethrow;
    }
  }

  Future<void> deletePhoto(String name) async {
    final file = await photo(name);
    if (await file.exists()) await file.delete();
  }
}
