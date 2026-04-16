import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/data/datasources/points/points_api_datasource.dart';
import 'package:n42_chat/src/data/repositories/points_repository_impl.dart';
import 'package:n42_chat/src/domain/entities/points/reward_rule.dart';

class MockPointsApiDatasource extends Mock implements PointsApiDatasource {}

void main() {
  late MockPointsApiDatasource mockApi;
  late PointsRepositoryImpl repository;

  setUp(() {
    mockApi = MockPointsApiDatasource();
    repository = PointsRepositoryImpl(api: mockApi);
  });

  test(
    'getConfig ignores unknown reward actions instead of remapping them',
    () async {
      when(() => mockApi.getConfig('!room:server.com')).thenAnswer(
        (_) async => {
          'roomId': '!room:server.com',
          'rules': [
            {'id': 'known', 'action': 'sendMessage', 'points': 2},
            {'id': 'unknown', 'action': 'futureAction', 'points': 999},
          ],
        },
      );

      final config = await repository.getConfig('!room:server.com');

      expect(config.rules, hasLength(1));
      expect(config.rules.first.id, 'known');
      expect(config.rules.first.action, PointsAction.sendMessage);
      expect(config.rules.first.points, 2);
    },
  );
}
