import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/chat_lock_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ChatLockService service;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    service = ChatLockService();
  });

  group('lockChat / verifyPin', () {
    test('stores salted pin hash for newly locked chats', () async {
      await service.lockChat('room-1', pin: '1234');

      final prefs = await SharedPreferences.getInstance();
      final hash = prefs.getString('chat_lock_pin_room-1');
      final salt = prefs.getString('chat_lock_pin_salt_room-1');
      final legacyHash = sha256.convert(utf8.encode('1234')).toString();

      expect(hash, isNotNull);
      expect(salt, isNotNull);
      expect(hash, isNot(equals(legacyHash)));
      expect(await service.verifyPin('room-1', '1234'), isTrue);
      expect(await service.verifyPin('room-1', '9999'), isFalse);
    });

    test('migrates legacy unsalted pin hashes after successful verification', () async {
      final legacyHash = sha256.convert(utf8.encode('4321')).toString();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'chat_lock_pin_room-legacy': legacyHash,
      });
      service = ChatLockService();

      final verified = await service.verifyPin('room-legacy', '4321');
      final prefs = await SharedPreferences.getInstance();
      final migratedHash = prefs.getString('chat_lock_pin_room-legacy');
      final salt = prefs.getString('chat_lock_pin_salt_room-legacy');

      expect(verified, isTrue);
      expect(salt, isNotNull);
      expect(migratedHash, isNotNull);
      expect(migratedHash, isNot(equals(legacyHash)));
    });
  });
}
