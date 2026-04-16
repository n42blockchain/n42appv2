import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/social_graph_service.dart';
import 'package:n42_chat/src/data/datasources/social/alchemy_social_datasource.dart';
import 'package:n42_chat/src/data/datasources/social/debank_datasource.dart';

class MockDeBankDatasource extends Mock implements DeBankDatasource {}

class MockAlchemySocialDatasource extends Mock
    implements AlchemySocialDatasource {}

void main() {
  late MockDeBankDatasource mockDeBank;
  late MockAlchemySocialDatasource mockAlchemy;
  late SocialGraphService service;

  setUp(() {
    mockDeBank = MockDeBankDatasource();
    mockAlchemy = MockAlchemySocialDatasource();
    service = SocialGraphService(
      debank: mockDeBank,
      alchemy: mockAlchemy,
    );
  });

  void stubSimilarityForCandidates(List<String> candidates) {
    final normalizedCandidates =
        candidates.map((candidate) => candidate.toLowerCase()).toList();

    when(() => mockDeBank.getUsedChains(any())).thenAnswer((invocation) async {
      final address =
          (invocation.positionalArguments.first as String).toLowerCase();
      if (normalizedCandidates.contains(address)) return ['eth'];
      return ['eth'];
    });

    when(() => mockDeBank.getUserTokenList(any(), any())).thenAnswer((
      invocation,
    ) async {
      final address =
          (invocation.positionalArguments.first as String).toLowerCase();
      if (address == '0xbest000000000000000000000000000000000000') {
        return [
          {'symbol': 'N42'},
          {'symbol': 'ETH'},
        ];
      }
      if (normalizedCandidates.contains(address)) {
        return [
          {'symbol': 'N42'},
        ];
      }
      return [
        {'symbol': 'N42'},
      ];
    });

    when(() => mockAlchemy.getUserNFTs(any(), pageSize: any(named: 'pageSize')))
        .thenAnswer((invocation) async {
      final address =
          (invocation.positionalArguments.first as String).toLowerCase();
      if (address == '0xquery000000000000000000000000000000000000') {
        return [
          {
            'contract': {'address': '0xCollection1'}
          },
          {
            'contract': {'address': '0xCollection2'}
          },
          {
            'contract': {'address': '0xCollection3'}
          },
        ];
      }

      if (address == '0xbest000000000000000000000000000000000000') {
        return [
          {
            'contract': {'address': '0xCollection2'}
          },
          {
            'contract': {'address': '0xCollection3'}
          },
        ];
      }

      if (normalizedCandidates.contains(address)) {
        return [
          {
            'contract': {'address': '0xCollection1'}
          },
        ];
      }

      return const [];
    });
  }

  test('getRecommendations filters self candidates case-insensitively',
      () async {
    const query = '0xQuery000000000000000000000000000000000000';
    const peer = '0xpeer000000000000000000000000000000000000';
    stubSimilarityForCandidates([peer]);

    when(() => mockAlchemy.getCollectionOwners('0xCollection1')).thenAnswer(
      (_) async => [
        query.toLowerCase(),
        query.toUpperCase(),
        peer,
      ],
    );
    when(() => mockAlchemy.getCollectionOwners('0xCollection2'))
        .thenAnswer((_) async => [query, peer]);
    when(() => mockAlchemy.getCollectionOwners('0xCollection3'))
        .thenAnswer((_) async => [query, peer]);

    final results = await service.getRecommendations(query);

    expect(results.map((r) => r.profile.address), isNot(contains(query)));
    expect(
      results.map((r) => r.profile.address),
      isNot(contains(query.toLowerCase())),
    );
    expect(results.map((r) => r.profile.address), contains(peer.toLowerCase()));
  });

  test('getRecommendations prioritizes candidates seen in more shared collections',
      () async {
    const query = '0xquery000000000000000000000000000000000000';
    const best = '0xbest000000000000000000000000000000000000';
    final others = List<String>.generate(
      10,
      (i) => '0xother${i.toString().padLeft(2, '0')}0000000000000000000000000000000000',
    );
    stubSimilarityForCandidates([best, ...others]);

    when(() => mockAlchemy.getCollectionOwners('0xCollection1')).thenAnswer(
      (_) async => [query, ...others],
    );
    when(() => mockAlchemy.getCollectionOwners('0xCollection2')).thenAnswer(
      (_) async => [query, best],
    );
    when(() => mockAlchemy.getCollectionOwners('0xCollection3')).thenAnswer(
      (_) async => [query, best],
    );

    final results = await service.getRecommendations(query, limit: 20);

    expect(results.map((r) => r.profile.address), contains(best));
    expect(results.length, lessThanOrEqualTo(10));
  });

  test('getRecommendations degrades to empty when nft discovery fails',
      () async {
    const query = '0xquery000000000000000000000000000000000000';

    when(() => mockAlchemy.getUserNFTs(query, pageSize: 50))
        .thenThrow(Exception('alchemy unavailable'));

    final results = await service.getRecommendations(query);

    expect(results, isEmpty);
    verifyNever(() => mockAlchemy.getCollectionOwners(any()));
  });

  test('calculateSimilarity uses shared chains instead of first chain from A',
      () async {
    const addressA = '0xaaa0000000000000000000000000000000000000';
    const addressB = '0xbbb0000000000000000000000000000000000000';

    when(() => mockDeBank.getUsedChains(addressA))
        .thenAnswer((_) async => ['bsc', 'eth']);
    when(() => mockDeBank.getUsedChains(addressB))
        .thenAnswer((_) async => ['eth']);

    when(() => mockDeBank.getUserTokenList(addressA, 'eth')).thenAnswer(
      (_) async => [
        {'symbol': 'N42'},
        {'symbol': 'ETH'},
      ],
    );
    when(() => mockDeBank.getUserTokenList(addressB, 'eth')).thenAnswer(
      (_) async => [
        {'symbol': 'N42'},
      ],
    );

    when(() => mockAlchemy.getUserNFTs(any(), pageSize: any(named: 'pageSize')))
        .thenAnswer((_) async => const []);

    final similarity = await service.calculateSimilarity(addressA, addressB);

    expect(similarity.commonTokens, contains('N42'));
    expect(similarity.tokenOverlap, greaterThan(0));
    verifyNever(() => mockDeBank.getUserTokenList(addressA, 'bsc'));
    verifyNever(() => mockDeBank.getUserTokenList(addressB, 'bsc'));
  });

  test('getRecommendations fetches collection owners in parallel', () async {
    const query = '0xquery000000000000000000000000000000000000';
    final firstOwners = Completer<List<String>>();
    final secondOwnersStarted = Completer<void>();

    when(() => mockAlchemy.getUserNFTs(query, pageSize: 50)).thenAnswer(
      (_) async => [
        {
          'contract': {'address': '0xCollection1'}
        },
        {
          'contract': {'address': '0xCollection2'}
        },
      ],
    );
    when(() => mockAlchemy.getCollectionOwners('0xCollection1'))
        .thenAnswer((_) => firstOwners.future);
    when(() => mockAlchemy.getCollectionOwners('0xCollection2')).thenAnswer(
      (_) async {
        if (!secondOwnersStarted.isCompleted) {
          secondOwnersStarted.complete();
        }
        return const <String>[];
      },
    );

    final future = service.getRecommendations(query);
    await Future<void>.delayed(Duration.zero);

    expect(
      secondOwnersStarted.isCompleted,
      isTrue,
      reason: 'owner lookups should not block on the first collection',
    );

    firstOwners.complete(const <String>[query]);
    final results = await future;

    expect(results, isEmpty);
  });

  test('getRecommendations starts scoring multiple candidates concurrently',
      () async {
    const query = '0xquery000000000000000000000000000000000000';
    const candidateA = '0xaaa0000000000000000000000000000000000000';
    const candidateB = '0xbbb0000000000000000000000000000000000000';

    final candidateABlocked = Completer<List<String>>();
    final candidateBStarted = Completer<void>();

    when(() => mockAlchemy.getUserNFTs(any(), pageSize: any(named: 'pageSize')))
        .thenAnswer((invocation) async {
      final address =
          (invocation.positionalArguments.first as String).toLowerCase();
      if (address == query) {
        return [
          {
            'contract': {'address': '0xCollection1'}
          },
        ];
      }
      return const [];
    });
    when(() => mockAlchemy.getCollectionOwners('0xCollection1')).thenAnswer(
      (_) async => [query, candidateA, candidateB],
    );

    when(() => mockDeBank.getUsedChains(any())).thenAnswer((invocation) {
      final address =
          (invocation.positionalArguments.first as String).toLowerCase();
      if (address == candidateA) {
        return candidateABlocked.future;
      }
      if (address == candidateB) {
        if (!candidateBStarted.isCompleted) {
          candidateBStarted.complete();
        }
        return Future.value(['eth']);
      }
      return Future.value(['eth']);
    });
    when(() => mockDeBank.getUserTokenList(any(), any())).thenAnswer(
      (_) async => [
        {'symbol': 'N42'},
      ],
    );

    final future = service.getRecommendations(query, limit: 2);
    await Future<void>.delayed(Duration.zero);

    expect(
      candidateBStarted.isCompleted,
      isTrue,
      reason: 'candidate scoring should not wait for the first candidate',
    );

    candidateABlocked.complete(['eth']);
    final results = await future;

    expect(results.map((r) => r.profile.address), contains(candidateA));
    expect(results.map((r) => r.profile.address), contains(candidateB));
  });

  test('getRecommendations reuses source lookups across candidates', () async {
    const query = '0xquery000000000000000000000000000000000000';
    const candidateA = '0xaaa0000000000000000000000000000000000000';
    const candidateB = '0xbbb0000000000000000000000000000000000000';

    when(() => mockAlchemy.getUserNFTs(any(), pageSize: any(named: 'pageSize')))
        .thenAnswer((invocation) async {
      final address =
          (invocation.positionalArguments.first as String).toLowerCase();
      if (address == query) {
        return [
          {
            'contract': {'address': '0xCollection1'}
          },
        ];
      }
      return const [];
    });
    when(() => mockAlchemy.getCollectionOwners('0xCollection1')).thenAnswer(
      (_) async => [query, candidateA, candidateB],
    );
    when(() => mockDeBank.getUsedChains(any())).thenAnswer((_) async => ['eth']);
    when(() => mockDeBank.getUserTokenList(any(), any())).thenAnswer(
      (_) async => [
        {'symbol': 'N42'},
      ],
    );

    final results = await service.getRecommendations(query, limit: 2);

    expect(results, hasLength(2));
    verify(() => mockAlchemy.getUserNFTs(query, pageSize: 50)).called(1);
    verify(() => mockDeBank.getUsedChains(query)).called(1);
    verify(() => mockDeBank.getUserTokenList(query, 'eth')).called(1);
  });

  test('calculateSimilarity normalizes nft contract case before intersecting',
      () async {
    const addressA = '0xaaa0000000000000000000000000000000000000';
    const addressB = '0xbbb0000000000000000000000000000000000000';

    when(() => mockDeBank.getUsedChains(any())).thenAnswer((_) async => const []);
    when(() => mockAlchemy.getUserNFTs(addressA, pageSize: 50)).thenAnswer(
      (_) async => [
        {
          'contract': {'address': '0xAbC123'}
        },
      ],
    );
    when(() => mockAlchemy.getUserNFTs(addressB, pageSize: 50)).thenAnswer(
      (_) async => [
        {
          'contract': {'address': '0xabc123'}
        },
      ],
    );

    final similarity = await service.calculateSimilarity(addressA, addressB);

    expect(similarity.commonNftCollections, contains('0xabc123'));
    expect(similarity.nftOverlap, greaterThan(0));
  });
}
