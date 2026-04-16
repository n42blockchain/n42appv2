import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/governance/snapshot_graphql_datasource.dart';
import 'package:n42_chat/src/data/datasources/governance/snapshot_hub_datasource.dart';
import 'package:n42_chat/src/data/repositories/governance_repository_impl.dart';

class MockSnapshotGraphQLDatasource extends Mock
    implements SnapshotGraphQLDatasource {}

class MockSnapshotHubDatasource extends Mock implements SnapshotHubDatasource {}

void main() {
  late MockSnapshotGraphQLDatasource mockGraphql;
  late MockSnapshotHubDatasource mockHub;
  late GovernanceRepositoryImpl repository;

  setUp(() {
    mockGraphql = MockSnapshotGraphQLDatasource();
    mockHub = MockSnapshotHubDatasource();
    repository = GovernanceRepositoryImpl(graphql: mockGraphql, hub: mockHub);
  });

  test('getSpace preserves Snapshot strategies as a list', () async {
    when(() => mockGraphql.getSpace('n42.eth')).thenAnswer(
      (_) async => {
        'id': 'n42.eth',
        'name': 'N42',
        'network': '1',
        'strategies': [
          {
            'name': 'erc20-balance-of',
            'params': {'symbol': 'N42'},
          },
        ],
        'filters': {'onlyMembers': true},
      },
    );

    final space = await repository.getSpace('n42.eth');

    expect(space.id, 'n42.eth');
    expect(space.strategies, hasLength(1));
    expect(space.strategies.first['name'], 'erc20-balance-of');
    expect(space.filters?['onlyMembers'], isTrue);
  });
}
