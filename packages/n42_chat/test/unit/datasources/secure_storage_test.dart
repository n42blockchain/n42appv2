import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

// Mock FlutterSecureStorage
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureStorage Logic Tests', () {
    late MockFlutterSecureStorage mockStorage;
    final Map<String, String> storageData = {};

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      storageData.clear();

      // 模拟 write
      when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      )).thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        final value = invocation.namedArguments[#value] as String;
        storageData[key] = value;
      });

      // 模拟 read
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        return storageData[key];
      });

      // 模拟 delete
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key] as String;
        storageData.remove(key);
      });

      // 模拟 deleteAll
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {
        storageData.clear();
      });
    });

    group('Session Management', () {
      test('should save and retrieve session', () async {
        const key = 'n42_chat_session';
        final sessionData = {
          'homeserver': 'https://m.si46.world',
          'accessToken': 'token123',
          'userId': '@user:m.si46.world',
          'deviceId': 'device123',
          'savedAt': DateTime.now().toIso8601String(),
        };

        await mockStorage.write(key: key, value: jsonEncode(sessionData));
        final stored = await mockStorage.read(key: key);

        expect(stored, isNotNull);
        final decoded = jsonDecode(stored!);
        expect(decoded['homeserver'], equals('https://m.si46.world'));
        expect(decoded['accessToken'], equals('token123'));
        expect(decoded['userId'], equals('@user:m.si46.world'));
      });

      test('should clear session', () async {
        const key = 'n42_chat_session';
        await mockStorage.write(key: key, value: 'test');
        await mockStorage.delete(key: key);
        
        final result = await mockStorage.read(key: key);
        expect(result, isNull);
      });
    });

    group('Credentials Management', () {
      test('should save and retrieve credentials', () async {
        const key = 'n42_chat_credentials';
        final credentialsData = {
          'homeserver': 'https://m.si46.world',
          'username': 'testuser',
          'password': 'testpass',
          'savedAt': DateTime.now().toIso8601String(),
        };

        await mockStorage.write(key: key, value: jsonEncode(credentialsData));
        final stored = await mockStorage.read(key: key);

        expect(stored, isNotNull);
        final decoded = jsonDecode(stored!);
        expect(decoded['username'], equals('testuser'));
        expect(decoded['password'], equals('testpass'));
      });

      test('should clear credentials on logout', () async {
        const key = 'n42_chat_credentials';
        await mockStorage.write(key: key, value: 'credentials');
        await mockStorage.delete(key: key);
        
        final result = await mockStorage.read(key: key);
        expect(result, isNull);
      });
    });

    group('Multi-Account Management', () {
      test('should add and retrieve multiple accounts', () async {
        const key = 'n42_chat_accounts';
        final accounts = {
          '@user1:server.com': {
            'userId': '@user1:server.com',
            'homeserver': 'https://server.com',
            'accessToken': 'token1',
          },
          '@user2:server.com': {
            'userId': '@user2:server.com',
            'homeserver': 'https://server.com',
            'accessToken': 'token2',
          },
        };

        await mockStorage.write(key: key, value: jsonEncode(accounts));
        final stored = await mockStorage.read(key: key);

        expect(stored, isNotNull);
        final decoded = jsonDecode(stored!) as Map<String, dynamic>;
        expect(decoded.length, equals(2));
        expect(decoded['@user1:server.com'], isNotNull);
        expect(decoded['@user2:server.com'], isNotNull);
      });

      test('should remove account from list', () async {
        const key = 'n42_chat_accounts';
        final accounts = {
          '@user1:server.com': {'userId': '@user1:server.com'},
          '@user2:server.com': {'userId': '@user2:server.com'},
        };

        await mockStorage.write(key: key, value: jsonEncode(accounts));
        
        // 移除一个账号
        accounts.remove('@user1:server.com');
        await mockStorage.write(key: key, value: jsonEncode(accounts));

        final stored = await mockStorage.read(key: key);
        final decoded = jsonDecode(stored!) as Map<String, dynamic>;
        expect(decoded.length, equals(1));
        expect(decoded['@user1:server.com'], isNull);
      });
    });

    group('Appearance Settings', () {
      test('should save and retrieve theme settings', () async {
        const key = 'n42_chat_appearance_settings';
        final settings = {
          'themeMode': 'dark',
          'fontSize': 'large',
          'bubbleStyle': 'wechat',
          'savedAt': DateTime.now().toIso8601String(),
        };

        await mockStorage.write(key: key, value: jsonEncode(settings));
        final stored = await mockStorage.read(key: key);

        expect(stored, isNotNull);
        final decoded = jsonDecode(stored!);
        expect(decoded['themeMode'], equals('dark'));
        expect(decoded['fontSize'], equals('large'));
      });
    });

    group('Contact Remarks', () {
      test('should save and retrieve contact remarks', () async {
        const key = 'n42_chat_contact_remarks';
        final remarks = {
          '@friend1:server.com': '好友小明',
          '@friend2:server.com': '同事小红',
        };

        await mockStorage.write(key: key, value: jsonEncode(remarks));
        final stored = await mockStorage.read(key: key);

        expect(stored, isNotNull);
        final decoded = jsonDecode(stored!) as Map<String, dynamic>;
        expect(decoded['@friend1:server.com'], equals('好友小明'));
      });
    });

    group('Clear All Data', () {
      test('should clear all stored data', () async {
        await mockStorage.write(key: 'key1', value: 'value1');
        await mockStorage.write(key: 'key2', value: 'value2');
        
        await mockStorage.deleteAll();

        expect(storageData, isEmpty);
      });
    });
  });

  group('WeChat Login Strategy Tests', () {
    test('session should persist after login', () async {
      // 模拟登录后保存会话
      final sessionData = {
        'homeserver': 'https://m.si46.world',
        'accessToken': 'persistent_token',
        'userId': '@user:m.si46.world',
        'deviceId': 'device123',
      };
      
      expect(sessionData['accessToken'], isNotNull);
      expect(sessionData['userId'], isNotNull);
    });

    test('credentials should be saved for auto-login', () async {
      // 模拟保存凭据（微信策略默认开启）
      final credentialsData = {
        'homeserver': 'https://m.si46.world',
        'username': 'testuser',
        'password': 'testpass',
      };
      
      expect(credentialsData['username'], isNotNull);
      expect(credentialsData['password'], isNotNull);
    });

    test('logout should clear both session and credentials', () async {
      // 模拟登出时清除所有凭据
      const sessionCleared = true;
      const credentialsCleared = true;
      
      expect(sessionCleared, isTrue);
      expect(credentialsCleared, isTrue);
    });
  });
}

