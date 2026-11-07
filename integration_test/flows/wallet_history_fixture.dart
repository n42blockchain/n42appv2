import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/core_providers.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/sqlite/app_database.dart';
import 'package:n42_wallet/features/wallet/data/transaction_history_repository.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/transation_record_model.dart';
import 'package:n42_wallet/features/wallet/pages/transactions/transaction_history_list.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_transactions_item.dart';
import 'package:n42_wallet/shared/domain/entities/wallet_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../test/helpers/widget_test_helpers.dart';

const _enabled = bool.fromEnvironment('N42_DISPOSABLE_WALLET_QA');

class _HistoryPreferences extends SPUtil {
  @override
  Future<Map<String, dynamic>?> getUserInfo() async => null;
  @override
  Future<void> saveUserInfoJson(Map<String, dynamic> info) async {}
}

class _HistoryDatabase extends AppDatabase {
  _HistoryDatabase(this.native);
  final Database native;
  @override
  Future<Database> get database async => native;
}

void registerWalletHistoryFixture() {
  testWidgets('TX-13 renders native SQLite history with account isolation', (
    tester,
  ) async {
    final info = DeviceInfoPlugin();
    final virtual = Platform.isAndroid
        ? !(await info.androidInfo).isPhysicalDevice
        : Platform.isIOS && !(await info.iosInfo).isPhysicalDevice;
    expect(virtual, isTrue, reason: 'Requires a disposable simulator.');
    if (!virtual) return;
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final owner = 'native-history-owner-$suffix';
    final other = 'native-history-other-$suffix';
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/n42-history-$suffix.db';
    expect(await File(path).exists(), isFalse);
    final database = await openDatabase(path, singleInstance: false);
    addTearDown(() async {
      await database.close();
      await deleteDatabase(path);
      expect(await File(path).exists(), isFalse);
    });
    // Copy the installed production DDL, never production records.
    final schema = await (await AppDatabase().database).query(
      'sqlite_master',
      columns: ['sql'],
      where: 'name=?',
      whereArgs: ['TransationRecord'],
    );
    await database.execute(schema.single['sql'] as String);
    const address = '0x1111111111111111111111111111111111111111';
    const recipient = '0x2222222222222222222222222222222222222222';
    final coin = CoinModel()
      ..address = address
      ..coin = {
        'coinType': 'ETH',
        'blockchainType': 'Ethereum',
        'unit': 'ETH',
        'decimals': 18,
        'contract': '',
      };
    for (final fixture in [
      (owner, address, 0, 1, 'owner'),
      (other, address, 0, 7, 'other'),
      (owner, recipient, 0, 9, 'address'),
      (owner, address, 1, 5, 'network'),
    ]) {
      final record = TransationRecordModel()
        ..userUuid = fixture.$1
        ..address = fixture.$2
        ..isTest = fixture.$3
        ..price = BigInt.from(fixture.$4) * BigInt.from(10).pow(18)
        ..txHash = 'qa-${fixture.$5}-$suffix'
        ..state = 1
        ..from1 = address
        ..to1 = recipient
        ..coinMiniName = 'ETH'
        ..coin = Map<String, dynamic>.from(coin.coin);
      await database.insert('TransationRecord', record.toMapDb());
    }
    final user = CurrentUserNotifier(_HistoryPreferences());
    await user.setUser(
      SharedUserInfo(uuid: owner, email: 'qa@example.invalid'),
    );
    await tester.pumpWidget(
      wrapForTest(
        TransactionHistoryList(
          coin,
          repository: TransactionHistoryRepository(
            database: _HistoryDatabase(database),
          ),
        ),
        overrides: [currentUserProvider.overrideWith((ref) => user)],
      ),
    );
    Future<void> expectOwner(String selected, int amount) async {
      for (var attempt = 0; attempt < 300; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
        final rows = tester
            .widgetList<WalletChainInfoTransactionsItem>(
              find.byType(WalletChainInfoTransactionsItem),
            )
            .toList();
        if (rows.length == 1 &&
            rows.single.transactionModel.userUuid == selected) {
          break;
        }
      }
      final rows = tester
          .widgetList<WalletChainInfoTransactionsItem>(
            find.byType(WalletChainInfoTransactionsItem),
          )
          .toList();
      expect(rows, hasLength(1));
      expect(rows.single.transactionModel.userUuid, selected);
      expect(
        rows.single.transactionModel.price ==
            BigInt.from(amount) * BigInt.from(10).pow(18),
        isTrue,
      );
      expect(find.text('$amount ETH'), findsOneWidget);
    }

    await expectOwner(owner, 1);
    await user.setUser(
      SharedUserInfo(uuid: other, email: 'qa@example.invalid'),
    );
    await expectOwner(other, 7);
    expect(find.text('1 ETH'), findsNothing);
    expect(find.text('9 ETH'), findsNothing);
    expect(find.text('5 ETH'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }, skip: !_enabled);
}
