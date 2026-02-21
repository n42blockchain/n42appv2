// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// Tests for EnsService pure-Dart logic:
//   - EnsService.isEnsName() static classifier
//   - EnsService.chainSupportsEns() static classifier
//   - EnsResolutionResult model constructors and factory methods
//   - EnsService cache behaviour (via stub TokenViewApi)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:n42appv2/src/wallet/api/token_view_api.dart';
import 'package:n42appv2/src/wallet/services/ens_service.dart';

// ---------------------------------------------------------------------------
// Stub TokenViewApi — returns controlled responses without network I/O
// ---------------------------------------------------------------------------

class _StubTokenViewApi extends TokenViewApi {
  /// Address returned by forward resolve, or null to simulate "not found"
  String? resolveResult;

  /// Name returned by reverse resolve, or null to simulate "not found"
  String? reverseResult;

  /// If true, all calls throw to simulate network errors
  bool throwOnCall = false;

  int forwardCallCount = 0;
  int reverseCallCount = 0;

  MessageModel _success(dynamic value) {
    final mm = MessageModel();
    mm.error = false;
    mm.data = value;
    return mm;
  }

  MessageModel _failure() => MessageModel.error();

  @override
  Future<MessageModel> getEnsResolve(String domain) async {
    forwardCallCount++;
    if (throwOnCall) throw Exception('network error');
    return resolveResult != null ? _success(resolveResult) : _failure();
  }

  @override
  Future<MessageModel> getN42EnsResolve(String domain) async {
    forwardCallCount++;
    if (throwOnCall) throw Exception('network error');
    return resolveResult != null ? _success(resolveResult) : _failure();
  }

  @override
  Future<MessageModel> getEnsReverseResolve(String address) async {
    reverseCallCount++;
    if (throwOnCall) throw Exception('network error');
    return reverseResult != null ? _success(reverseResult) : _failure();
  }

  @override
  Future<MessageModel> getN42ReverseResolve(String address) async {
    reverseCallCount++;
    if (throwOnCall) throw Exception('network error');
    return reverseResult != null ? _success(reverseResult) : _failure();
  }

  @override
  Future<MessageModel> getEnsAvatar(String domain) async => _failure();

  @override
  Future<MessageModel> getEnsTextRecords(String domain) async => _failure();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ─────────────────────────────────────────────────────────────
  // EnsService.isEnsName — static pure classifier
  // ─────────────────────────────────────────────────────────────

  group('EnsService.isEnsName', () {
    test('vitalik.eth is recognised as ENS', () {
      expect(EnsService.isEnsName('vitalik.eth'), isTrue);
    });

    test('user.n42 is recognised as ENS', () {
      expect(EnsService.isEnsName('user.n42'), isTrue);
    });

    test('app.xyz is recognised as ENS', () {
      expect(EnsService.isEnsName('app.xyz'), isTrue);
    });

    test('name.app is recognised as ENS', () {
      expect(EnsService.isEnsName('name.app'), isTrue);
    });

    test('name.art is recognised as ENS', () {
      expect(EnsService.isEnsName('name.art'), isTrue);
    });

    test('name.luxe is recognised as ENS', () {
      expect(EnsService.isEnsName('name.luxe'), isTrue);
    });

    test('name.kred is recognised as ENS', () {
      expect(EnsService.isEnsName('name.kred'), isTrue);
    });

    test('0x hex address is NOT ENS', () {
      expect(
        EnsService.isEnsName('0xAbCd1234567890abcdef1234567890ABCDEF1234'),
        isFalse,
      );
    });

    test('plain word without suffix is NOT ENS', () {
      expect(EnsService.isEnsName('vitalik'), isFalse);
    });

    test('empty string is NOT ENS', () {
      expect(EnsService.isEnsName(''), isFalse);
    });

    test('unknown TLD (.com) is NOT ENS', () {
      expect(EnsService.isEnsName('user.com'), isFalse);
    });

    test('recognition is case-insensitive', () {
      expect(EnsService.isEnsName('Vitalik.ETH'), isTrue);
    });

    test('leading/trailing spaces are stripped before check', () {
      expect(EnsService.isEnsName('  vitalik.eth  '), isTrue);
    });

    test('subdomain (alice.vitalik.eth) is recognised', () {
      expect(EnsService.isEnsName('alice.vitalik.eth'), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsService.chainSupportsEns — static pure classifier
  // ─────────────────────────────────────────────────────────────

  group('EnsService.chainSupportsEns', () {
    test('N chain is supported', () {
      expect(EnsService.chainSupportsEns('N'), isTrue);
    });

    test('ETH is supported', () {
      expect(EnsService.chainSupportsEns('ETH'), isTrue);
    });

    test('BNB is supported', () {
      expect(EnsService.chainSupportsEns('BNB'), isTrue);
    });

    test('MATIC is supported', () {
      expect(EnsService.chainSupportsEns('MATIC'), isTrue);
    });

    test('AVAX is supported', () {
      expect(EnsService.chainSupportsEns('AVAX'), isTrue);
    });

    test('OP is supported', () {
      expect(EnsService.chainSupportsEns('OP'), isTrue);
    });

    test('ARB is supported', () {
      expect(EnsService.chainSupportsEns('ARB'), isTrue);
    });

    test('SOL is NOT supported', () {
      expect(EnsService.chainSupportsEns('SOL'), isFalse);
    });

    test('BTC is NOT supported', () {
      expect(EnsService.chainSupportsEns('BTC'), isFalse);
    });

    test('TRX is NOT supported', () {
      expect(EnsService.chainSupportsEns('TRX'), isFalse);
    });

    test('empty string is NOT supported', () {
      expect(EnsService.chainSupportsEns(''), isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsResolutionResult model
  // ─────────────────────────────────────────────────────────────

  group('EnsResolutionResult.success factory', () {
    test('success is true', () {
      final r = EnsResolutionResult.success(address: '0xABC');
      expect(r.success, isTrue);
    });

    test('address is set', () {
      final r = EnsResolutionResult.success(address: '0xABC');
      expect(r.address, '0xABC');
    });

    test('error is null', () {
      final r = EnsResolutionResult.success(address: '0xABC');
      expect(r.error, isNull);
    });

    test('optional fields default to null', () {
      final r = EnsResolutionResult.success(address: '0xABC');
      expect(r.ensName, isNull);
      expect(r.avatar, isNull);
      expect(r.sourceChain, isNull);
    });

    test('optional fields can be set', () {
      final r = EnsResolutionResult.success(
        address: '0xABC',
        ensName: 'vitalik.eth',
        avatar: 'https://avatar.example/v.png',
        sourceChain: 'ETH',
      );
      expect(r.ensName, 'vitalik.eth');
      expect(r.avatar, 'https://avatar.example/v.png');
      expect(r.sourceChain, 'ETH');
    });
  });

  group('EnsResolutionResult.failure factory', () {
    test('success is false', () {
      final r = EnsResolutionResult.failure('not found');
      expect(r.success, isFalse);
    });

    test('error message is set', () {
      final r = EnsResolutionResult.failure('not found');
      expect(r.error, 'not found');
    });

    test('address is null', () {
      final r = EnsResolutionResult.failure('not found');
      expect(r.address, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsService.resolveName — forward resolution with stub API
  // ─────────────────────────────────────────────────────────────

  group('EnsService.resolveName', () {
    late _StubTokenViewApi stub;
    late EnsService service;

    setUp(() {
      stub = _StubTokenViewApi();
      service = EnsService(tokenViewApi: stub);
    });

    test('returns success when API resolves an address', () async {
      stub.resolveResult = '0xDeadBeef';
      final result = await service.resolveName('vitalik.eth');
      expect(result.success, isTrue);
      expect(result.address, '0xDeadBeef');
    });

    test('returns failure when API returns no data', () async {
      stub.resolveResult = null;
      final result = await service.resolveName('unknown.eth');
      expect(result.success, isFalse);
    });

    test('normalises name to lowercase before resolution', () async {
      stub.resolveResult = '0x1234';
      final result = await service.resolveName('VITALIK.ETH');
      expect(result.success, isTrue);
      expect(result.ensName, 'vitalik.eth');
    });

    test('returns failure when API throws', () async {
      stub.throwOnCall = true;
      final result = await service.resolveName('any.eth');
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });

    test('caches successful result — second call does not hit API', () async {
      stub.resolveResult = '0xCached';
      await service.resolveName('cached.eth');
      final callsAfterFirst = stub.forwardCallCount;
      await service.resolveName('cached.eth');
      expect(stub.forwardCallCount, callsAfterFirst); // no extra call
    });

    test('bypasses cache when useCache=false', () async {
      stub.resolveResult = '0xFresh';
      await service.resolveName('fresh.eth');
      final callsAfterFirst = stub.forwardCallCount;
      await service.resolveName('fresh.eth', useCache: false);
      expect(stub.forwardCallCount, greaterThan(callsAfterFirst));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsService.resolveAddress — reverse resolution with stub API
  // ─────────────────────────────────────────────────────────────

  group('EnsService.resolveAddress', () {
    late _StubTokenViewApi stub;
    late EnsService service;

    setUp(() {
      stub = _StubTokenViewApi();
      service = EnsService(tokenViewApi: stub);
    });

    test('returns ENS name when API resolves the address', () async {
      stub.reverseResult = 'vitalik.eth';
      final name =
          await service.resolveAddress('0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045');
      expect(name, 'vitalik.eth');
    });

    test('returns null when API returns no data', () async {
      stub.reverseResult = null;
      final name = await service.resolveAddress('0xUnknown');
      expect(name, isNull);
    });

    test('returns null when API throws', () async {
      stub.throwOnCall = true;
      final name = await service.resolveAddress('0xAny');
      expect(name, isNull);
    });

    test('normalises address to lowercase before cache lookup', () async {
      stub.reverseResult = 'user.eth';
      await service.resolveAddress('0xABCDEF');
      final callsAfterFirst = stub.reverseCallCount;
      // Same address, different case — should still hit cache
      await service.resolveAddress('0xabcdef');
      expect(stub.reverseCallCount, callsAfterFirst);
    });

    test('caches null result to prevent repeated lookups', () async {
      stub.reverseResult = null;
      await service.resolveAddress('0xNoName');
      final callsAfterFirst = stub.reverseCallCount;
      await service.resolveAddress('0xNoName');
      expect(stub.reverseCallCount, callsAfterFirst);
    });

    test('bypasses cache when useCache=false', () async {
      stub.reverseResult = 'user.eth';
      await service.resolveAddress('0xFresh');
      final callsAfterFirst = stub.reverseCallCount;
      await service.resolveAddress('0xFresh', useCache: false);
      expect(stub.reverseCallCount, greaterThan(callsAfterFirst));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsService.resolveAddresses — batch reverse resolution
  // ─────────────────────────────────────────────────────────────

  group('EnsService.resolveAddresses', () {
    late _StubTokenViewApi stub;
    late EnsService service;

    setUp(() {
      stub = _StubTokenViewApi();
      service = EnsService(tokenViewApi: stub);
    });

    test('resolves all provided addresses', () async {
      stub.reverseResult = 'user.eth';
      final results = await service.resolveAddresses(['0x1', '0x2', '0x3']);
      expect(results.keys, containsAll(['0x1', '0x2', '0x3']));
    });

    test('empty list returns empty map', () async {
      final results = await service.resolveAddresses([]);
      expect(results, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsService.clearCache
  // ─────────────────────────────────────────────────────────────

  group('EnsService.clearCache', () {
    test('clearCache forces next resolution to hit API again', () async {
      final stub = _StubTokenViewApi()..reverseResult = 'user.eth';
      final service = EnsService(tokenViewApi: stub);

      await service.resolveAddress('0xClear');
      final callsAfterFirst = stub.reverseCallCount;

      service.clearCache();

      await service.resolveAddress('0xClear');
      expect(stub.reverseCallCount, greaterThan(callsAfterFirst));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsServiceProvider singleton
  // ─────────────────────────────────────────────────────────────

  group('EnsServiceProvider', () {
    setUp(() => EnsServiceProvider.reset());
    tearDown(() => EnsServiceProvider.reset());

    test('instance returns the same object on repeated calls', () {
      final a = EnsServiceProvider.instance;
      final b = EnsServiceProvider.instance;
      expect(identical(a, b), isTrue);
    });

    test('reset causes a new instance to be created', () {
      final a = EnsServiceProvider.instance;
      EnsServiceProvider.reset();
      final b = EnsServiceProvider.instance;
      expect(identical(a, b), isFalse);
    });
  });
}
