import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_models.dart';
import 'package:n42_wallet/features/loyalty/services/loyalty_service.dart';

void main() {
  test('loads account, daily task, referrals, history, and leaderboard', () async {
    final service = LoyaltyService(
      baseUrl: 'https://api.example/loyalty/v1/',
      client: MockClient((request) async {
        expect(request.url.queryParameters['wallet'], '0xabc');
        final body = switch (request.url.path) {
          '/loyalty/v1/account' =>
            '{"code":200,"data":{"total_points":120,"available_points":100,"used_points":20,"tier":"bronze","tier_progress":12,"next_tier_points":880}}',
          '/loyalty/v1/tasks' =>
            '{"code":200,"data":[{"id":"daily-checkin","title":"Daily Check-in","description":"Once daily","points":10,"status":"completed"}]}',
          '/loyalty/v1/rewards' => '{"code":200,"data":[]}',
          '/loyalty/v1/history' =>
            '{"code":200,"data":[{"id":"h1","action":"earn","points":10,"description":"Daily check-in","created_at":"2026-07-14T12:00:00Z"}]}',
          '/loyalty/v1/referral/list' =>
            '{"code":200,"data":[{"referred_address":"0xdef","points_earned":100,"created_at":"2026-07-13T12:00:00Z"}]}',
          '/loyalty/v1/leaderboard' =>
            '{"code":200,"data":[{"rank":1,"wallet_address":"0xabc","points":100}]}',
          _ => throw StateError('unexpected path ${request.url.path}'),
        };
        return http.Response(body, 200);
      }),
    );

    final snapshot = await service.load('0xabc');

    expect(snapshot.account.availablePoints, 100);
    expect(snapshot.checkedInToday, isTrue);
    expect(snapshot.history.single.points, 10);
    expect(snapshot.referrals.single.address, '0xdef');
    expect(snapshot.leaderboard.single.rank, 1);
    service.dispose();
  });

  test('a failing supplementary endpoint degrades to an empty section', () async {
    // 排行榜挂掉不该把整页（含签到入口）一起打没。
    final service = LoyaltyService(
      baseUrl: 'https://api.example/loyalty/v1/',
      client: MockClient((request) async {
        final body = switch (request.url.path) {
          '/loyalty/v1/account' =>
            '{"code":200,"data":{"total_points":120,"available_points":100,"used_points":20,"tier":"bronze","tier_progress":12,"next_tier_points":880}}',
          '/loyalty/v1/tasks' =>
            '{"code":200,"data":[{"id":"daily-checkin","title":"Daily Check-in","description":"Once daily","points":10,"status":"pending"}]}',
          '/loyalty/v1/leaderboard' => throw StateError('leaderboard is down'),
          _ => '{"code":200,"data":[]}',
        };
        return http.Response(body, 200);
      }),
    );

    final snapshot = await service.load('0xabc');

    expect(snapshot.account.availablePoints, 100);
    expect(snapshot.tasks.single.id, 'daily-checkin');
    expect(snapshot.leaderboard, isEmpty);
    service.dispose();
  });

  test('a failing account endpoint still surfaces an error', () async {
    final service = LoyaltyService(
      baseUrl: 'https://api.example/loyalty/v1/',
      client: MockClient((request) async {
        if (request.url.path == '/loyalty/v1/account') {
          return http.Response('{"code":500}', 500);
        }
        return http.Response('{"code":200,"data":[]}', 200);
      }),
    );

    await expectLater(
      service.load('0xabc'),
      throwsA(isA<LoyaltyServiceException>()),
    );
    service.dispose();
  });

  test('returns confirmed points and relayer transaction hash', () async {
    final service = LoyaltyService(
      baseUrl: 'https://api.example/loyalty/v1',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/loyalty/v1/check-in');
        return http.Response(
          '{"code":200,"data":{"points_earned":10,"tx_hash":"0x1234"}}',
          200,
        );
      }),
    );

    final result = await service.checkIn('0xabc');

    expect(result.points, 10);
    expect(result.transactionHash, '0x1234');
    service.dispose();
  });

  test('rejects a success envelope without a positive chain award', () async {
    final service = LoyaltyService(
      baseUrl: 'https://api.example/loyalty/v1',
      client: MockClient(
        (_) async =>
            http.Response('{"code":200,"data":{"points_earned":0}}', 200),
      ),
    );

    await expectLater(
      service.checkIn('0xabc'),
      throwsA(isA<LoyaltyServiceException>()),
    );
    service.dispose();
  });

  test('normalizes signed spend history', () {
    final item = LoyaltyHistoryItem.fromJson({
      'id': 'spent',
      'action': 'spend',
      'points': 25,
      'description': 'Reward',
    });
    expect(item.points, -25);
  });
}
