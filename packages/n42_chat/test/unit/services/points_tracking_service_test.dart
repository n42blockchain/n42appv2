import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/points_tracking_service.dart';
import 'package:n42_chat/src/data/datasources/matrix/matrix_client_manager.dart';
import 'package:n42_chat/src/domain/entities/points/points_config.dart';
import 'package:n42_chat/src/domain/entities/points/reward_rule.dart';
import 'package:n42_chat/src/domain/repositories/points_repository.dart';

class MockPointsRepository extends Mock implements IPointsRepository {}

class MockMatrixClientManager extends Mock implements MatrixClientManager {}

void main() {
  late MockPointsRepository mockRepository;
  late MockMatrixClientManager mockClientManager;
  late PointsTrackingService service;

  setUp(() {
    mockRepository = MockPointsRepository();
    mockClientManager = MockMatrixClientManager();
    service = PointsTrackingService(
      repository: mockRepository,
      clientManager: mockClientManager,
    );
  });

  test(
    'awardDailyLogin uses configured daily login rule instead of hardcoded points',
    () async {
      when(() => mockRepository.getConfig('!room:server.com')).thenAnswer(
        (_) async => const PointsConfig(
          roomId: '!room:server.com',
          rules: [
            RewardRule(
              id: 'daily-login',
              action: PointsAction.dailyLogin,
              points: 12,
              dailyLimit: 1,
            ),
          ],
        ),
      );
      when(
        () => mockRepository.getDailyEarnCount(
          '@alice:server',
          '!room:server.com',
          PointsAction.dailyLogin.name,
        ),
      ).thenAnswer((_) async => 0);
      when(
        () => mockRepository.awardPoints(
          userId: any(named: 'userId'),
          roomId: any(named: 'roomId'),
          amount: any(named: 'amount'),
          actionType: any(named: 'actionType'),
          description: any(named: 'description'),
        ),
      ).thenAnswer((_) async {});

      await service.awardDailyLogin('@alice:server', '!room:server.com');

      verify(
        () => mockRepository.awardPoints(
          userId: '@alice:server',
          roomId: '!room:server.com',
          amount: 12,
          actionType: PointsAction.dailyLogin.name,
          description: 'Daily login bonus',
        ),
      ).called(1);
    },
  );

  test(
    'awardDailyLogin does not award when the configured rule is disabled',
    () async {
      when(() => mockRepository.getConfig('!room:server.com')).thenAnswer(
        (_) async => const PointsConfig(
          roomId: '!room:server.com',
          rules: [
            RewardRule(
              id: 'daily-login',
              action: PointsAction.dailyLogin,
              points: 12,
              dailyLimit: 1,
              isEnabled: false,
            ),
          ],
        ),
      );

      await service.awardDailyLogin('@alice:server', '!room:server.com');

      verifyNever(
        () => mockRepository.awardPoints(
          userId: any(named: 'userId'),
          roomId: any(named: 'roomId'),
          amount: any(named: 'amount'),
          actionType: any(named: 'actionType'),
          description: any(named: 'description'),
        ),
      );
    },
  );
}
