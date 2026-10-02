import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/aa/repository/session_key_repository.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_manage_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/session_key_models.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _Repository extends SessionKeyRepository {
  _Repository(this.keys) : super(AppDatabase());

  List<SessionKeyData> keys;
  bool revokeResult = true;
  bool throwOnLoad = false;
  final revokedAddresses = <String>[];
  int? loadedChainId;

  @override
  Future<List<SessionKeyData>> loadKeys(int chainId) async {
    loadedChainId = chainId;
    if (throwOnLoad) throw StateError('storage unavailable');
    return keys;
  }

  @override
  Future<bool> revokeKey(String keyAddress, int chainId) async {
    revokedAddresses.add('$keyAddress:$chainId');
    if (!revokeResult) return false;
    keys = keys
        .map(
          (key) => key.keyAddress == keyAddress
              ? key.copyWith(status: SessionKeyStatus.revoked)
              : key,
        )
        .toList();
    return true;
  }
}

final _account = SmartAccount(
  address: '0x${'a' * 40}',
  type: SmartAccountType.simpleAccount,
  ownerAddress: '0x${'b' * 40}',
  state: SmartAccountState.deployed,
  chainId: 8453,
  salt: BigInt.one,
  factoryAddress: '0x${'f' * 40}',
  createdAt: DateTime(2026, 1, 1),
  label: 'Primary account',
);

SessionKeyData _key(String label, SessionKeyStatus status, String suffix) =>
    SessionKeyData(
      keyAddress: '0x${suffix * 40}',
      label: label,
      permission: SessionKeyPermission.transfer,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      expiresAt: DateTime.now().add(const Duration(days: 20)),
      chainId: 8453,
      transactionCount: 3,
    );

void main() {
  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> openPage(WidgetTester tester, _Repository repository) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      wrapForTest(
        SessionKeyManagePage(
          account: _account,
          repositoryForTesting: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loading keys scopes by chain and filters tabs by status', (
    tester,
  ) async {
    final repository = _Repository([
      _key('Active transfer', SessionKeyStatus.active, '1'),
      _key('Expired contract', SessionKeyStatus.expired, '2'),
      _key('Revoked delegation', SessionKeyStatus.revoked, '3'),
    ]);
    await openPage(tester, repository);

    final context = tester.element(find.byType(SessionKeyManagePage));
    final strings = S.of(context);
    expect(repository.loadedChainId, 8453);
    expect(find.text('Active transfer'), findsOneWidget);
    expect(find.text('${strings.g_key_aa_active} (1)'), findsOneWidget);
    expect(find.text('${strings.g_key_aa_expired} (1)'), findsOneWidget);
    expect(find.text('${strings.g_key_aa_revoked_status} (1)'), findsOneWidget);
    expect(find.text(strings.g_key_aa_revoke), findsOneWidget);

    await tester.tap(find.text('${strings.g_key_aa_expired} (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Expired contract'), findsOneWidget);
    expect(find.text(strings.g_key_aa_revoke), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmed revoke moves the key into revoked history', (
    tester,
  ) async {
    final activeKey = _key('Daily spend', SessionKeyStatus.active, '5');
    final repository = _Repository([activeKey]);
    await openPage(tester, repository);

    final context = tester.element(find.byType(SessionKeyManagePage));
    final strings = S.of(context);
    await tester.tap(find.text(strings.g_key_aa_revoke));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.g_key_aa_revoke).last);
    await tester.pumpAndSettle();

    expect(repository.revokedAddresses, ['${activeKey.keyAddress}:8453']);
    expect(find.text('${strings.g_key_aa_active} (0)'), findsOneWidget);
    expect(find.text('${strings.g_key_aa_revoked_status} (1)'), findsOneWidget);

    final revokedTab = find.text('${strings.g_key_aa_revoked_status} (1)');
    await tester.ensureVisible(revokedTab);
    await tester.tap(revokedTab);
    await tester.pumpAndSettle();
    expect(find.text('Daily spend'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed local revoke restores the active key', (tester) async {
    final activeKey = _key('Limited transfer', SessionKeyStatus.active, '4');
    final repository = _Repository([activeKey])..revokeResult = false;
    await openPage(tester, repository);

    final context = tester.element(find.byType(SessionKeyManagePage));
    final strings = S.of(context);
    await tester.tap(find.text(strings.g_key_aa_revoke));
    await tester.pumpAndSettle();
    expect(find.text(strings.g_key_aa_revoke_confirm), findsOneWidget);
    await tester.tap(find.text(strings.g_key_aa_revoke).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(repository.revokedAddresses, ['${activeKey.keyAddress}:8453']);
    expect(find.text('Limited transfer'), findsOneWidget);
    expect(find.text('${strings.g_key_aa_active} (1)'), findsOneWidget);
    expect(find.text('${strings.g_key_aa_revoked_status} (0)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed key storage load exits loading and shows empty state', (
    tester,
  ) async {
    final repository = _Repository(const [])..throwOnLoad = true;
    await openPage(tester, repository);

    final context = tester.element(find.byType(SessionKeyManagePage));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(S.of(context).g_key_aa_no_session_keys), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
