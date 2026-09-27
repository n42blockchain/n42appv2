import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_models.dart';
import 'package:n42_wallet/features/loyalty/pages/loyalty_home_page.dart';
import 'package:n42_wallet/features/loyalty/services/loyalty_service.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/shared/domain/entities/user_info.dart';

import '../../helpers/test_current_user.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  const walletA = '0x1111111111111111111111111111111111111111';
  const walletB = '0x2222222222222222222222222222222222222222';

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

  testWidgets('late A load cannot replace B after same-State wallet switch', (
    tester,
  ) async {
    final pendingA = Completer<LoyaltySnapshot>();
    final service = _ScriptedLoyaltyService(
      onLoad: (wallet) =>
          wallet == walletA ? pendingA.future : Future.value(_snapshot(42)),
    );
    const pageKey = ValueKey('loyalty-account');

    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(key: pageKey, walletAddress: walletA, service: service),
      ),
    );
    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(key: pageKey, walletAddress: walletB, service: service),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(service.loadedWallets, [walletA, walletB]);
    expect(find.text('42'), findsWidgets);
    pendingA.complete(_snapshot(11));
    await tester.pumpAndSettle();
    expect(find.text('42'), findsWidgets);
    expect(find.text('11'), findsNothing);
    service.dispose();
  });

  testWidgets('late A load failure does not appear under B', (tester) async {
    final pendingA = Completer<LoyaltySnapshot>();
    final service = _ScriptedLoyaltyService(
      onLoad: (wallet) =>
          wallet == walletA ? pendingA.future : Future.value(_snapshot(42)),
    );
    const pageKey = ValueKey('loyalty-account');

    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(key: pageKey, walletAddress: walletA, service: service),
      ),
    );
    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(key: pageKey, walletAddress: walletB, service: service),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(service.loadedWallets, [walletA, walletB]);
    pendingA.completeError(StateError('A account failed'));
    await tester.pumpAndSettle();

    expect(find.text('42'), findsWidgets);
    expect(find.textContaining('A account failed'), findsNothing);
    service.dispose();
  });

  for (final succeeds in [true, false]) {
    testWidgets('late A check-in ${succeeds ? 'success' : 'error'} does not '
        'notify or refresh B', (tester) async {
      final pendingA = Completer<LoyaltyCheckInResult>();
      final service = _ScriptedLoyaltyService(
        onLoad: (wallet) =>
            Future.value(_snapshot(wallet == walletA ? 11 : 42)),
        onCheckIn: (wallet) => wallet == walletA
            ? pendingA.future
            : Future.value(const LoyaltyCheckInResult(points: 25)),
      );
      const pageKey = ValueKey('loyalty-account');

      await tester.pumpWidget(
        wrapForTest(
          LoyaltyHomePage(
            key: pageKey,
            walletAddress: walletA,
            service: service,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(service.checkedInWallets, [walletA]);

      await tester.pumpWidget(
        wrapForTest(
          LoyaltyHomePage(
            key: pageKey,
            walletAddress: walletB,
            service: service,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(service.loadedWallets, [walletA, walletB]);
      if (succeeds) {
        pendingA.complete(const LoyaltyCheckInResult(points: 25));
      } else {
        pendingA.completeError(StateError('A check-in failed'));
      }
      await tester.pumpAndSettle();

      expect(find.text('42'), findsWidgets);
      expect(find.byType(SnackBar), findsNothing);
      expect(service.loadedWallets, [walletA, walletB]);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(service.checkedInWallets, [walletA, walletB]);
      service.dispose();
    });
  }

  testWidgets('late A check-in cannot clear B in-flight check-in', (
    tester,
  ) async {
    final pendingA = Completer<LoyaltyCheckInResult>();
    final pendingB = Completer<LoyaltyCheckInResult>();
    final service = _ScriptedLoyaltyService(
      onLoad: (wallet) => Future.value(_snapshot(wallet == walletA ? 11 : 42)),
      onCheckIn: (wallet) =>
          wallet == walletA ? pendingA.future : pendingB.future,
    );
    const pageKey = ValueKey('loyalty-account');

    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(key: pageKey, walletAddress: walletA, service: service),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(key: pageKey, walletAddress: walletB, service: service),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(service.checkedInWallets, [walletA, walletB]);

    pendingA.complete(const LoyaltyCheckInResult(points: 25));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(service.loadedWallets, [walletA, walletB]);
    pendingB.complete(const LoyaltyCheckInResult(points: 25));
    await tester.pumpAndSettle();
    expect(service.loadedWallets, [walletA, walletB, walletB]);
    service.dispose();
  });

  testWidgets('empty wallet clears old account and disables check-in', (
    tester,
  ) async {
    final service = _ScriptedLoyaltyService(
      onLoad: (_) => Future.value(_snapshot(11)),
    );
    const pageKey = ValueKey('loyalty-account');

    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(key: pageKey, walletAddress: walletA, service: service),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('11'), findsWidgets);
    await tester.pumpWidget(
      wrapForTest(
        LoyaltyHomePage(key: pageKey, walletAddress: '', service: service),
      ),
    );
    await tester.pump();

    expect(find.text('11'), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(service.loadedWallets, [walletA]);
    service.dispose();
  });

  testWidgets('display-only points hide priced catalog but keep used history', (
    tester,
  ) async {
    final service = _ScriptedLoyaltyService(
      onLoad: (_) => Future.value(_snapshot(42, withHistory: true)),
    );
    await tester.pumpWidget(
      wrapForTest(LoyaltyHomePage(walletAddress: walletA, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rewards'), findsNothing);
    expect(find.text('Priced item'), findsNothing);
    expect(find.text('7'), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Historical spend'), findsOneWidget);
    expect(find.text('-7'), findsOneWidget);
    service.dispose();
  });

  testWidgets('route follows wallet selection and blocks a new auth owner', (
    tester,
  ) async {
    final wallet = WalletActionProvider()
      ..publishCoinListForOwner('user-A', [_coin(walletA)]);
    final user = TestCurrentUser('user-A');
    final service = _ScriptedLoyaltyService(
      onLoad: (address) =>
          Future.value(_snapshot(address == walletA ? 11 : 42)),
    );
    final overrides = [
      wapBridgeProvider.overrideWith((ref) => wallet),
      currentUserProvider.overrideWith((ref) => user),
    ];

    await tester.pumpWidget(
      wrapForTest(
        LoyaltyWalletPage(ownerUuid: 'user-A', service: service),
        overrides: overrides,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('11'), findsWidgets);

    wallet.publishCoinListForOwner('user-A', [_coin(walletB)]);
    await tester.pumpAndSettle();
    expect(service.loadedWallets, [walletA, walletB]);
    expect(find.text('42'), findsWidgets);
    expect(find.text('11'), findsNothing);

    user.select('user-B');
    await tester.pumpAndSettle();
    expect(find.text('42'), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
    expect(service.loadedWallets, [walletA, walletB]);
    service.dispose();
  });

  testWidgets('route builder retains tap-time owner after auth switch', (
    tester,
  ) async {
    final wallet = WalletActionProvider()
      ..publishCoinListForOwner('user-A', [_coin(walletA)]);
    final user = TestCurrentUser('user-A');
    final service = _ScriptedLoyaltyService(
      onLoad: (_) => Future.value(_snapshot(11)),
    );
    await tester.pumpWidget(
      wrapForTest(
        Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () =>
                openLoyaltyWalletPage(context, ref, service: service),
            child: const Text('Open loyalty'),
          ),
        ),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => wallet),
          currentUserProvider.overrideWith((ref) => user),
        ],
      ),
    );
    await tester.tap(find.text('Open loyalty'));
    await tester.pumpAndSettle();
    final pageElement = tester.element(find.byType(LoyaltyWalletPage));
    final route = ModalRoute.of(pageElement)! as MaterialPageRoute<void>;
    expect(route.builder(pageElement), isA<LoyaltyWalletPage>());

    user.select('user-B');
    await tester.pumpAndSettle();
    final rebuilt = route.builder(pageElement) as LoyaltyWalletPage;
    expect(rebuilt.ownerUuid, 'user-A');
    expect(find.text('11'), findsNothing);
    expect(service.loadedWallets, [walletA]);
    service.dispose();
  });

  testWidgets('route with no auth owner does not load a selected wallet', (
    tester,
  ) async {
    final wallet = WalletActionProvider()..coinList = [_coin(walletA)];
    final user = TestCurrentUser('');
    final service = _ScriptedLoyaltyService(
      onLoad: (_) => Future.value(_snapshot(11)),
    );
    await tester.pumpWidget(
      wrapForTest(
        LoyaltyWalletPage(ownerUuid: null, service: service),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => wallet),
          currentUserProvider.overrideWith((ref) => user),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(service.loadedWallets, isEmpty);
    expect(find.text('11'), findsNothing);
    service.dispose();
  });

  testWidgets('new B route rejects A list restored by failed B init', (
    tester,
  ) async {
    final previousUser = AppGlobals.userInfo;
    final previousStorage = FlutterSecureStoragePlatform.instance;
    addTearDown(() {
      AppGlobals.userInfo = previousUser;
      FlutterSecureStoragePlatform.instance = previousStorage;
    });
    AppGlobals.userInfo = UserInfo(uuid: 'user-A');
    final wallet = WalletActionProvider()
      ..publishCoinListForOwner('user-A', [_coin(walletA)]);
    FlutterSecureStoragePlatform.instance = _FailingWalletStoragePlatform({});
    AppGlobals.userInfo = UserInfo(uuid: 'user-B');
    await expectLater(wallet.initWallet(), throwsStateError);
    expect(wallet.coinList.single.address, walletA);
    expect(wallet.coinListOwnerUuid, 'user-A');

    final user = TestCurrentUser('user-B');
    final service = _ScriptedLoyaltyService(
      onLoad: (address) =>
          Future.value(_snapshot(address == walletB ? 42 : 11)),
    );
    await tester.pumpWidget(
      wrapForTest(
        LoyaltyWalletPage(ownerUuid: 'user-B', service: service),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => wallet),
          currentUserProvider.overrideWith((ref) => user),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(service.loadedWallets, isEmpty);
    expect(find.byType(FilledButton), findsNothing);
    expect(service.checkedInWallets, isEmpty);

    wallet.publishCoinListForOwner('user-B', [_coin(walletB)]);
    await tester.pumpAndSettle();
    expect(service.loadedWallets, [walletB]);
    expect(find.text('42'), findsWidgets);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(service.checkedInWallets, [walletB]);
    service.dispose();
  });

  testWidgets('same-owner failed init restores usable selection', (
    tester,
  ) async {
    final previousUser = AppGlobals.userInfo;
    final previousStorage = FlutterSecureStoragePlatform.instance;
    addTearDown(() {
      AppGlobals.userInfo = previousUser;
      FlutterSecureStoragePlatform.instance = previousStorage;
    });
    AppGlobals.userInfo = UserInfo(uuid: 'user-A');
    final wallet = WalletActionProvider()
      ..publishCoinListForOwner('user-A', [_coin(walletA)]);
    FlutterSecureStoragePlatform.instance = _FailingWalletStoragePlatform({});
    await expectLater(wallet.initWallet(), throwsStateError);
    expect(wallet.coinListOwnerUuid, 'user-A');
    expect(wallet.coinList.single.address, walletA);

    final service = _ScriptedLoyaltyService(
      onLoad: (_) => Future.value(_snapshot(11)),
    );
    await tester.pumpWidget(
      wrapForTest(
        LoyaltyWalletPage(ownerUuid: 'user-A', service: service),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => wallet),
          currentUserProvider.overrideWith((ref) => TestCurrentUser('user-A')),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(service.loadedWallets, [walletA]);
    expect(find.text('11'), findsWidgets);
    service.dispose();
  });

  test('auth change during wallet storage await cancels publication', () async {
    final previousUser = AppGlobals.userInfo;
    final previousStorage = FlutterSecureStoragePlatform.instance;
    addTearDown(() {
      AppGlobals.userInfo = previousUser;
      FlutterSecureStoragePlatform.instance = previousStorage;
    });
    AppGlobals.userInfo = UserInfo(uuid: 'user-A');
    final wallet = WalletActionProvider()
      ..publishCoinListForOwner('user-A', [_coin(walletA)]);
    final storage = _DelayedWalletStoragePlatform({});
    FlutterSecureStoragePlatform.instance = storage;

    final initializing = wallet.initWallet();
    expect(wallet.buildwallet, isTrue);
    AppGlobals.userInfo = UserInfo(uuid: 'user-B');
    storage.completeWalletRead(
      jsonEncode({
        'user-B': {'index': -1, 'wallet': <Object>[]},
      }),
    );
    await initializing;

    expect(wallet.buildwallet, isFalse);
    expect(wallet.coinList, isEmpty);
    expect(wallet.coinListOwnerUuid, 'user-A');
  });
}

class _FailingWalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _FailingWalletStoragePlatform(super.data);

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => throw StateError('synthetic wallet storage failure');
}

class _DelayedWalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _DelayedWalletStoragePlatform(super.data);

  final _walletRead = Completer<String?>();

  void completeWalletRead(String value) => _walletRead.complete(value);

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) => key == 'walletInfo'
      ? _walletRead.future
      : super.read(key: key, options: options);
}

class _ScriptedLoyaltyService extends LoyaltyService {
  _ScriptedLoyaltyService({
    required this.onLoad,
    Future<LoyaltyCheckInResult> Function(String)? onCheckIn,
  }) : onCheckIn =
           onCheckIn ?? ((_) async => const LoyaltyCheckInResult(points: 25)),
       super(
         client: MockClient((_) async => throw StateError('unexpected HTTP')),
         baseUrl: 'https://test',
       );

  final Future<LoyaltySnapshot> Function(String) onLoad;
  final Future<LoyaltyCheckInResult> Function(String) onCheckIn;
  final loadedWallets = <String>[];
  final checkedInWallets = <String>[];

  @override
  Future<LoyaltySnapshot> load(String walletAddress) {
    loadedWallets.add(walletAddress);
    return onLoad(walletAddress);
  }

  @override
  Future<LoyaltyCheckInResult> checkIn(String walletAddress) {
    checkedInWallets.add(walletAddress);
    return onCheckIn(walletAddress);
  }
}

LoyaltySnapshot _snapshot(int points, {bool withHistory = false}) {
  return LoyaltySnapshot(
    account: LoyaltyAccount(
      totalPoints: points,
      availablePoints: points,
      usedPoints: withHistory ? 7 : 0,
      tier: LoyaltyTier.bronze,
      tierProgress: 0,
      nextTierPoints: 1000,
    ),
    tasks: const [
      LoyaltyTask(
        id: 'daily-checkin',
        title: 'Daily Check-in',
        description: 'Once per UTC day',
        points: 25,
        status: LoyaltyTaskStatus.available,
      ),
    ],
    rewards: withHistory
        ? const [
            LoyaltyReward(
              id: 'priced',
              name: 'Priced item',
              description: 'Unavailable catalog',
              pointsCost: 100,
              isAvailable: true,
            ),
          ]
        : const [],
    history: withHistory
        ? const [
            LoyaltyHistoryItem(
              id: 'old-spend',
              description: 'Historical spend',
              points: -7,
              createdAt: null,
            ),
          ]
        : const [],
    referrals: const [],
    leaderboard: const [],
  );
}

CoinModel _coin(String address) => CoinModel()
  ..coin = {'coinType': 'N'}
  ..address = address;
