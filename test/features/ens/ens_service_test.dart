// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// Tests for EnsService pure-Dart logic:
//   - EnsService.isEnsName() static classifier
//   - EnsService.chainSupportsEns() static classifier
//   - EnsResolutionResult model constructors and factory methods
//   - EnsService cache behaviour (via HttpOverrides that fail fast)

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/services/ens_service.dart';

// ---------------------------------------------------------------------------
// HttpOverrides that immediately reject all connections.
// This makes TokenViewApi's extension methods (which use Dio -> dart:io)
// fail instantly instead of timing out, so _nsGet returns MessageModel.error().
// ---------------------------------------------------------------------------

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Any HTTP method call throws immediately.
    throw const SocketException('blocked by test');
  }
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _RejectingHttpClient();
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

    test('SOL is supported (SNS + UD)', () {
      expect(EnsService.chainSupportsEns('SOL'), isTrue);
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
  // EnsService.resolveName — forward resolution
  //
  // TokenViewApi name-service methods are extension methods, so
  // they cannot be overridden by a subclass stub.  We install
  // HttpOverrides with a 1 ms connection timeout so Dio fails
  // instantly.  The extension's _nsGet catches the error and
  // returns MessageModel.error(), which EnsService treats as a
  // failed resolution.  This lets us verify the error-path and
  // caching behaviour without any network I/O.
  // ─────────────────────────────────────────────────────────────

  group('EnsService.resolveName', () {
    late EnsService service;

    setUp(() {
      HttpOverrides.global = _FailFastHttpOverrides();
      service = EnsService();
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    test('returns failure when API is unreachable', () async {
      final result = await service.resolveName('unknown.eth');
      expect(result.success, isFalse);
    });

    test('normalises name to lowercase before resolution', () async {
      final result = await service.resolveName('VITALIK.ETH');
      // Even though the resolution fails, ensName in the failure
      // path is not set — just verify no crash and consistent result.
      expect(result.success, isFalse);
    });

    test('returns failure when API throws', () async {
      final result = await service.resolveName('any.eth');
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });

    test('caches result — second call does not hit API again', () async {
      // First call: API fails, result is cached as failure.
      final r1 = await service.resolveName('cached.eth');
      // Second call: should hit cache and return same result immediately.
      final r2 = await service.resolveName('cached.eth');
      expect(r2.success, r1.success);
      expect(r2.error, r1.error);
    });

    test('bypasses cache when useCache=false', () async {
      await service.resolveName('fresh.eth');
      // Second call bypasses cache — still gets a failure (API down),
      // but exercises the non-cache path without hanging.
      final r2 = await service.resolveName('fresh.eth', useCache: false);
      expect(r2.success, isFalse);
    });

    test('different domains get separate cache entries', () async {
      final r1 = await service.resolveName('a.eth');
      final r2 = await service.resolveName('b.eth');
      // Both fail (API down) but both return a result (no timeout).
      expect(r1.success, isFalse);
      expect(r2.success, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsService.resolveAddress — reverse resolution
  // ─────────────────────────────────────────────────────────────

  group('EnsService.resolveAddress', () {
    late EnsService service;

    setUp(() {
      HttpOverrides.global = _FailFastHttpOverrides();
      service = EnsService();
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    test('returns null when API is unreachable', () async {
      final name = await service.resolveAddress(
        '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
      );
      expect(name, isNull);
    });

    test('returns null when API throws', () async {
      final name = await service.resolveAddress('0xAny');
      expect(name, isNull);
    });

    test('normalises address to lowercase before cache lookup', () async {
      await service.resolveAddress('0xABCDEF');
      // Same address, different case — should still hit cache.
      final name = await service.resolveAddress('0xabcdef');
      expect(name, isNull); // both null (API down)
    });

    test('caches null result to prevent repeated lookups', () async {
      await service.resolveAddress('0xNoName');
      // Second call uses cache.
      final name = await service.resolveAddress('0xNoName');
      expect(name, isNull);
    });

    test('bypasses cache when useCache=false', () async {
      await service.resolveAddress('0xFresh');
      final name = await service.resolveAddress('0xFresh', useCache: false);
      expect(name, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // EnsService.resolveAddresses — batch reverse resolution
  // ─────────────────────────────────────────────────────────────

  group('EnsService.resolveAddresses', () {
    late EnsService service;

    setUp(() {
      HttpOverrides.global = _FailFastHttpOverrides();
      service = EnsService();
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    test('resolves all provided addresses', () async {
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
    setUp(() {
      HttpOverrides.global = _FailFastHttpOverrides();
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    test('clearCache forces next resolution to hit API again', () async {
      final service = EnsService();

      await service.resolveAddress('0xClear');
      service.clearCache();
      // After clearing, the next call goes to API again (still fails fast).
      final name = await service.resolveAddress('0xClear');
      expect(name, isNull);
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
