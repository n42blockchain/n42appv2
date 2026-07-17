import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/identity/api/id_hub_api.dart';
import 'package:n42_wallet/features/identity/models/id_hub_models.dart';
import 'package:n42_wallet/features/identity/services/id_hub_bind_signer.dart';

class _FakeApi extends IdHubApi {
  _FakeApi() : super(baseUrl: 'https://id.n42.ai');

  String sessionStatus = 'pending';
  bool completed = false;
  String? completedSignature;
  Object? completeThrows;

  @override
  Future<IdHubBindSession> getBindSession(String sessionId) async =>
      IdHubBindSession(
        sessionId: sessionId,
        type: 'wallet-binding',
        status: sessionStatus,
      );

  @override
  Future<IdHubChallenge> prepareBindSession({
    required String sessionId,
    required String address,
    String chain = IdHubApi.defaultChainCaip2,
  }) async =>
      const IdHubChallenge(
        challengeId: 'ch1',
        message: 'N42 ID v1 bind ...',
        expiresAt: '2099-01-01T00:00:00Z',
      );

  @override
  Future<void> completeBindSession({
    required String sessionId,
    required String challengeId,
    required String signature,
    String signerType = 'eoa',
    int? chainId,
  }) async {
    if (completeThrows != null) throw completeThrows!;
    completed = true;
    completedSignature = signature;
  }
}

void main() {
  group('isHubAllowed', () {
    test('accepts allowlisted hosts and subdomains over https', () {
      expect(IdHubBindSigner.isHubAllowed('https://id.n42.ai'), isTrue);
      expect(IdHubBindSigner.isHubAllowed('https://id-dev.n42.ai'), isTrue);
      expect(IdHubBindSigner.isHubAllowed('https://a.id.n42.ai'), isTrue);
    });

    test('rejects unknown hosts, http, and garbage', () {
      expect(IdHubBindSigner.isHubAllowed('https://evil.com'), isFalse);
      expect(IdHubBindSigner.isHubAllowed('https://id.n42.ai.evil.com'), isFalse);
      expect(IdHubBindSigner.isHubAllowed('http://id.n42.ai'), isFalse);
      expect(IdHubBindSigner.isHubAllowed('not a url'), isFalse);
    });
  });

  group('IdHubBindSigner.completeBind', () {
    test('pulls message from hub, signs, and completes', () async {
      final api = _FakeApi();
      final signer = IdHubBindSigner();
      String? signed;
      final out = await signer.completeBind(
        sessionId: 'sid1',
        hubUrl: 'https://id.n42.ai',
        address: '0xABC',
        apiFactory: (_) => api,
        sign: (msg) async {
          signed = msg;
          return '0xsig';
        },
      );
      expect(out.success, isTrue);
      expect(signed, 'N42 ID v1 bind ...');
      expect(api.completed, isTrue);
      expect(api.completedSignature, '0xsig');
    });

    test('refuses an untrusted hub without calling the api', () async {
      final api = _FakeApi();
      final out = await IdHubBindSigner().completeBind(
        sessionId: 'sid1',
        hubUrl: 'https://evil.com',
        address: '0xABC',
        apiFactory: (_) => api,
        sign: (_) async => '0xsig',
      );
      expect(out.success, isFalse);
      expect(out.code, 'untrusted-hub');
      expect(api.completed, isFalse);
    });

    test('fails when the session is not pending', () async {
      final api = _FakeApi()..sessionStatus = 'expired';
      final out = await IdHubBindSigner().completeBind(
        sessionId: 'sid1',
        hubUrl: 'https://id.n42.ai',
        address: '0xABC',
        apiFactory: (_) => api,
        sign: (_) async => '0xsig',
      );
      expect(out.success, isFalse);
      expect(out.code, 'session-expired');
      expect(api.completed, isFalse);
    });

    test('fails (declined) and does not complete when signing returns null',
        () async {
      final api = _FakeApi();
      final out = await IdHubBindSigner().completeBind(
        sessionId: 'sid1',
        hubUrl: 'https://id.n42.ai',
        address: '0xABC',
        apiFactory: (_) => api,
        sign: (_) async => null,
      );
      expect(out.success, isFalse);
      expect(out.code, 'declined');
      expect(api.completed, isFalse);
    });

    test('surfaces the hub error code on completion (binding-conflict)',
        () async {
      final api = _FakeApi()
        ..completeThrows =
            IdHubException('already bound', statusCode: 409, code: 'binding-conflict');
      final out = await IdHubBindSigner().completeBind(
        sessionId: 'sid1',
        hubUrl: 'https://id.n42.ai',
        address: '0xABC',
        apiFactory: (_) => api,
        sign: (_) async => '0xsig',
      );
      expect(out.success, isFalse);
      expect(out.code, 'binding-conflict');
    });
  });
}
