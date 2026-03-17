import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/data/models/user_info.dart';
import 'package:n42_wallet/features/auth/data/services/auth_service_impl.dart';

class FakeAuthSpUtil extends SPUtil {
  FakeAuthSpUtil({this.userInfo});

  Map<String, dynamic>? userInfo;
  UserInfoSaveCall? lastSavedUserInfo;

  @override
  Future<Map<String, dynamic>?> getUserInfo() async => userInfo;

  @override
  Future<void> saveUserInfo(UserInfo? info) async {
    lastSavedUserInfo = UserInfoSaveCall(info);
    if (info == null) {
      userInfo = null;
      return;
    }
    userInfo = info.toJson();
  }
}

class UserInfoSaveCall {
  UserInfoSaveCall(this.value);

  final dynamic value;
}

class FakeAuthSecureStorage extends SecureStorage {
  Map<String, dynamic>? storedUserInfo;
  bool clearUserDataCalled = false;
  String? savedToken;

  @override
  Future<Map<String, dynamic>?> getUserInfo() async => storedUserInfo;

  @override
  Future<void> clearUserData() async {
    clearUserDataCalled = true;
    savedToken = null;
    storedUserInfo = null;
  }

  @override
  Future<void> saveToken(String token) async {
    savedToken = token;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthServiceImpl', () {
    test('initializes current user and token from cached user info', () async {
      final spUtil = FakeAuthSpUtil(
        userInfo: {
          'uuid': 'user-1',
          'email': 'alice@example.com',
          'name': 'Alice',
          'image': 'https://example.com/a.png',
          'token': 'token-1',
        },
      );
      final secureStorage = FakeAuthSecureStorage();
      final service = AuthServiceImpl(spUtil, secureStorage);

      await Future<void>.delayed(Duration.zero);

      expect(service.isLoggedIn(), isTrue);
      expect(service.getCurrentUser()?.uuid, 'user-1');
      expect(await service.getAuthToken(), 'token-1');
      service.dispose();
    });

    test('verifyPassword requires exact stored password match', () async {
      final service = AuthServiceImpl(
        FakeAuthSpUtil(),
        FakeAuthSecureStorage()..storedUserInfo = {'password': 'secret-123'},
      );

      await Future<void>.delayed(Duration.zero);

      expect(await service.verifyPassword('secret-123'), isTrue);
      expect(await service.verifyPassword('wrong'), isFalse);
      expect(await service.verifyPassword(''), isFalse);
      service.dispose();
    });

    test('logout clears cached user state and secure storage', () async {
      final spUtil = FakeAuthSpUtil(
        userInfo: {
          'uuid': 'user-1',
          'email': 'alice@example.com',
          'token': 'token-1',
        },
      );
      final secureStorage = FakeAuthSecureStorage()
        ..storedUserInfo = {'password': 'secret-123'};
      final service = AuthServiceImpl(spUtil, secureStorage);

      await Future<void>.delayed(Duration.zero);
      await service.logout();

      expect(service.isLoggedIn(), isFalse);
      expect(await service.getAuthToken(), isNull);
      expect(spUtil.userInfo, isNull);
      expect(secureStorage.clearUserDataCalled, isTrue);
      service.dispose();
    });
  });
}
