import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/features/loyalty/pages/loyalty_home_page.dart';
import 'package:n42_wallet/features/loyalty/services/loyalty_service.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('shows chain-configured daily points and referral action', (
    tester,
  ) async {
    final client = MockClient((request) async {
      final data = switch (request.url.path) {
        '/account' => {
          'available_points': 25,
          'total_points': 25,
          'used_points': 0,
          'tier': 'bronze',
          'tier_progress': 2,
          'next_tier_points': 975,
        },
        '/tasks' => [
          {
            'id': 'daily-checkin',
            'title': 'Daily Check-in',
            'description': 'Once per UTC day',
            'points': 25,
            'status': 'available',
          },
        ],
        '/rewards' || '/history' || '/referral/list' || '/leaderboard' => [],
        _ => throw StateError('unexpected route ${request.url.path}'),
      };
      return http.Response(jsonEncode({'code': 200, 'data': data}), 200);
    });
    final service = LoyaltyService(client: client, baseUrl: 'https://test');

    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(
          walletAddress: '0x1111111111111111111111111111111111111111',
          service: service,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Earn 25 points'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    await tester.tap(find.text('Referrals'));
    await tester.pumpAndSettle();
    expect(find.text('Invite friends'), findsOneWidget);
    expect(
      find.text('No referrals yet. Share your code to get started.'),
      findsOneWidget,
    );

    service.dispose();
  });
}
