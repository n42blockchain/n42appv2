import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/features/identity/api/id_hub_api.dart';
import 'package:n42_wallet/features/identity/models/id_hub_models.dart';
import 'package:n42_wallet/features/identity/services/id_hub_wallet_login.dart';
import 'package:n42_wallet/features/identity/services/id_token_store.dart';

/// In-memory SecureStorage that only overrides the ID Hub token helpers.
class _FakeSecureStorage extends SecureStorage {
  final Map<String, String> store = {};

  @override
  Future<void> saveIdHubToken(String did, String tokenJson) async {
    store['n42id_token_$did'] = tokenJson;
  }

  @override
  Future<String?> getIdHubToken(String did) async => store['n42id_token_$did'];

  @override
  Future<void> deleteIdHubToken(String did) async {
    store.remove('n42id_token_$did');
  }
}

class _FakeIdHubApi extends IdHubApi {
  int refreshCalls = 0;
  int challengeCalls = 0;
  int verifyCalls = 0;
  int revokeCalls = 0;
  bool refreshRevoked = false;
  Duration refreshDelay = Duration.zero;
  Object? refreshError;
  Object? revokeError;
  String? resultSub = _did;
  String? revokedAccessToken;
  String? revokedRefreshToken;

  _FakeIdHubApi() : super(baseUrl: 'https://id-test.n42.ai');

  @override
  Future<IdHubTokenResponse> refresh(String refreshToken) async {
    refreshCalls++;
    if (refreshDelay > Duration.zero) await Future.delayed(refreshDelay);
    if (refreshError != null) throw refreshError!;
    if (refreshRevoked) {
      throw IdHubException('revoked', statusCode: 401, code: 'token-revoked');
    }
    return const IdHubTokenResponse(
      accessToken: 'new-access',
      expiresIn: 900,
      refreshToken: 'sid1.next',
    );
  }

  @override
  Future<IdHubChallenge> createWalletChallenge({
    required String address,
    String chain = IdHubApi.defaultChainCaip2,
    String aud = 'wallet-api',
  }) async {
    challengeCalls++;
    return const IdHubChallenge(
      challengeId: 'ch1',
      message: 'N42 ID v1 ...',
      expiresAt: '2099-01-01T00:00:00Z',
    );
  }

  @override
  Future<IdHubWalletLoginResult> verifyWalletLogin({
    required String challengeId,
    required String signature,
    String signerType = 'eoa',
    int? chainId,
  }) async {
    verifyCalls++;
    return IdHubWalletLoginResult(
      token: IdHubTokenResponse(
        accessToken: 'first-access',
        expiresIn: 900,
        refreshToken: 'sid1.secret',
        sub: resultSub,
        sid: 'sid1',
      ),
      didCreated: true,
    );
  }

  @override
  Future<void> revoke({
    required String accessToken,
    String? refreshToken,
  }) async {
    revokeCalls++;
    revokedAccessToken = accessToken;
    revokedRefreshToken = refreshToken;
    if (revokeError != null) throw revokeError!;
  }
}

const _did = 'did:plc:aaaaaaaaaaaaaaaaaaaaaaaa';

String _stored({required int expiresAt, String? refresh}) => jsonEncode({
  'access_token': 'cached',
  'refresh_token': ?refresh,
  'expires_at': expiresAt,
  'sid': 'sid1',
});

void main() {
  group('IdTokenStore', () {
    test('returns the cached token when still fresh (no refresh)', () async {
      final api = _FakeIdHubApi();
      final storage = _FakeSecureStorage();
      storage.store['n42id_token_$_did'] = _stored(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 900000,
        refresh: 'sid1.r',
      );
      final store = IdTokenStore(api: api, storage: storage);
      expect(await store.getValidToken(_did), 'cached');
      expect(api.refreshCalls, 0);
    });

    test('refreshes when within the skew window', () async {
      final api = _FakeIdHubApi();
      final storage = _FakeSecureStorage();
      storage.store['n42id_token_$_did'] = _stored(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 10000,
        refresh: 'sid1.r',
      );
      final store = IdTokenStore(api: api, storage: storage);
      expect(await store.getValidToken(_did), 'new-access');
      expect(api.refreshCalls, 1);
    });

    test('single-flights concurrent refreshes into one call', () async {
      final api = _FakeIdHubApi()
        ..refreshDelay = const Duration(milliseconds: 20);
      final storage = _FakeSecureStorage();
      storage.store['n42id_token_$_did'] = _stored(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 10000,
        refresh: 'sid1.r',
      );
      final store = IdTokenStore(api: api, storage: storage);
      final results = await Future.wait([
        store.getValidToken(_did),
        store.getValidToken(_did),
      ]);
      expect(results, ['new-access', 'new-access']);
      expect(api.refreshCalls, 1);
    });

    test(
      'clears storage and returns null when refresh is revoked (401)',
      () async {
        final api = _FakeIdHubApi()..refreshRevoked = true;
        final storage = _FakeSecureStorage();
        storage.store['n42id_token_$_did'] = _stored(
          expiresAt: DateTime.now().millisecondsSinceEpoch + 10000,
          refresh: 'sid1.r',
        );
        final store = IdTokenStore(api: api, storage: storage);
        expect(await store.getValidToken(_did), isNull);
        expect(storage.store.containsKey('n42id_token_$_did'), isFalse);
      },
    );

    test('returns null when nothing is cached', () async {
      final store = IdTokenStore(
        api: _FakeIdHubApi(),
        storage: _FakeSecureStorage(),
      );
      expect(await store.getValidToken(_did), isNull);
    });

    test('treats corrupt persisted JSON as an empty cache', () async {
      final storage = _FakeSecureStorage();
      storage.store['n42id_token_$_did'] = '{not-json';
      final api = _FakeIdHubApi();

      expect(
        await IdTokenStore(api: api, storage: storage).getValidToken(_did),
        isNull,
      );
      expect(api.refreshCalls, 0);
    });

    test(
      'returns null without a network call when an expired token cannot refresh',
      () async {
        final storage = _FakeSecureStorage();
        storage.store['n42id_token_$_did'] = _stored(
          expiresAt: DateTime.now().millisecondsSinceEpoch - 1,
        );
        final api = _FakeIdHubApi();

        expect(
          await IdTokenStore(api: api, storage: storage).getValidToken(_did),
          isNull,
        );
        expect(api.refreshCalls, 0);
      },
    );

    test(
      'keeps the cached session on recoverable Hub refresh failure',
      () async {
        final storage = _FakeSecureStorage();
        storage.store['n42id_token_$_did'] = _stored(
          expiresAt: DateTime.now().millisecondsSinceEpoch + 10000,
          refresh: 'sid1.r',
        );
        final api = _FakeIdHubApi()
          ..refreshError = IdHubException(
            'unavailable',
            statusCode: 503,
            code: 'unavailable',
          );

        expect(
          await IdTokenStore(api: api, storage: storage).getValidToken(_did),
          isNull,
        );
        expect(storage.store.containsKey('n42id_token_$_did'), isTrue);
      },
    );

    test(
      'contains unexpected refresh errors without clearing the cache',
      () async {
        final storage = _FakeSecureStorage();
        storage.store['n42id_token_$_did'] = _stored(
          expiresAt: DateTime.now().millisecondsSinceEpoch + 10000,
          refresh: 'sid1.r',
        );
        final api = _FakeIdHubApi()..refreshError = StateError('offline');

        expect(
          await IdTokenStore(api: api, storage: storage).getValidToken(_did),
          isNull,
        );
        expect(storage.store.containsKey('n42id_token_$_did'), isTrue);
      },
    );

    test('revoke sends both tokens and always clears local storage', () async {
      final storage = _FakeSecureStorage();
      storage.store['n42id_token_$_did'] = _stored(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 900000,
        refresh: 'sid1.r',
      );
      final api = _FakeIdHubApi();

      await IdTokenStore(api: api, storage: storage).revokeAndClear(_did);

      expect(api.revokeCalls, 1);
      expect(api.revokedAccessToken, 'cached');
      expect(api.revokedRefreshToken, 'sid1.r');
      expect(storage.store.containsKey('n42id_token_$_did'), isFalse);
    });

    test('revoke transport failure still clears local storage', () async {
      final storage = _FakeSecureStorage();
      storage.store['n42id_token_$_did'] = _stored(
        expiresAt: DateTime.now().millisecondsSinceEpoch + 900000,
        refresh: 'sid1.r',
      );
      final api = _FakeIdHubApi()..revokeError = StateError('offline');

      await IdTokenStore(api: api, storage: storage).revokeAndClear(_did);

      expect(api.revokeCalls, 1);
      expect(storage.store.containsKey('n42id_token_$_did'), isFalse);
    });
  });

  group('IdHubWalletLogin', () {
    test('default client reports disabled without a configured Hub host', () {
      expect(IdHubWalletLogin().isEnabled, isFalse);
    });

    test(
      'challenge -> sign -> verify stores the token and returns result',
      () async {
        final api = _FakeIdHubApi();
        final storage = _FakeSecureStorage();
        final login = IdHubWalletLogin(
          api: api,
          store: IdTokenStore(api: api, storage: storage),
        );
        String? signed;
        final result = await login.login(
          address: '0xABCDEF0000000000000000000000000000000001',
          sign: (msg) async {
            signed = msg;
            return '0xsignature';
          },
        );
        expect(api.challengeCalls, 1);
        expect(api.verifyCalls, 1);
        expect(signed, 'N42 ID v1 ...');
        expect(result.didCreated, isTrue);
        expect(storage.store.containsKey('n42id_token_$_did'), isTrue);
      },
    );

    test('throws when the wallet declines to sign', () async {
      final api = _FakeIdHubApi();
      final login = IdHubWalletLogin(
        api: api,
        store: IdTokenStore(api: api, storage: _FakeSecureStorage()),
      );
      expect(
        () => login.login(address: '0x1', sign: (_) async => null),
        throwsStateError,
      );
      expect(api.verifyCalls, 0);
    });

    test('throws when the wallet returns an empty signature', () async {
      final api = _FakeIdHubApi();
      final login = IdHubWalletLogin(
        api: api,
        store: IdTokenStore(api: api, storage: _FakeSecureStorage()),
      );

      await expectLater(
        login.login(address: '0x1', sign: (_) async => ''),
        throwsStateError,
      );
      expect(api.verifyCalls, 0);
    });

    test('does not cache a successful response without a root DID', () async {
      final api = _FakeIdHubApi()..resultSub = null;
      final storage = _FakeSecureStorage();
      final login = IdHubWalletLogin(
        api: api,
        store: IdTokenStore(api: api, storage: storage),
      );

      final result = await login.login(
        address: '0x1',
        sign: (_) async => '0xsignature',
      );

      expect(result.token.sub, isNull);
      expect(storage.store, isEmpty);
    });
  });
}
