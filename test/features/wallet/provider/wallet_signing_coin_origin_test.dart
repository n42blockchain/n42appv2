import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/provider/transaction_record_iterms_provider.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/transaction_providers.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

class _Transactions extends TransactionRecordItemProvider {
  @override
  Future<void> selectUndoneTr() async {}
}

class _Wallet extends WalletActionProvider {
  String owner = 'owner-a';
  @override
  String get userUUID => owner;
}

WalletInfo _info(String address) => WalletInfo(walletName: 'fixture')
  ..watchOnly = true
  ..watchAddress = address
  ..coinInfo = {
    'ETH': {
      'baseInfo': {
        'coinType': 'ETH',
        'miniName': 'ETH',
        'isContract': false,
        'blockchainType': 'Ethereum',
      },
      'isTest': false,
      'addrType': 'legacy',
      'mainnets': <String, dynamic>{},
    },
  };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => globalTripInstance = _Transactions());
  late _Wallet wallet;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    app.globalProviderContainer = ProviderContainer();
    wallet = _Wallet()..walletIndex = 0;
    wallet.walletInfoLsit.addAll([_info('address-a'), _info('address-b')]);
    FlutterSecureStorage.setMockInitialValues({
      'walletInfo': jsonEncode({
        wallet.walletDataOwnerUuid: {
          'wallet': wallet.walletInfoLsit.map((w) => w.toJson()).toList(),
          'index': 0,
          'miningIndex': 0,
        },
      }),
    });
  });
  tearDown(() async {
    await Future<void>.delayed(Duration.zero);
    wallet.dispose();
    app.globalProviderContainer.dispose();
  });
  test(
    'only completed models for the selected wallet can be captured',
    () async {
      expect(wallet.captureSigningCoinModels, throwsStateError);
      await wallet.buildCoinModel();
      final old = wallet.captureSigningCoinModels();
      expect(old.models.single.address, 'address-a');
      expect(old.isCurrent(), isTrue);
      wallet.walletIndex = 1;
      expect(old.isCurrent(), isFalse);
      expect(wallet.captureSigningCoinModels, throwsStateError);
      await wallet.buildCoinModel();
      expect(
        wallet.captureSigningCoinModels().models.single.address,
        'address-b',
      );
      expect(old.isCurrent(), isFalse);
    },
  );
  test('account replacement and initialization invalidate captures', () async {
    await wallet.buildCoinModel();
    final snapshot = wallet.captureSigningCoinModels();
    wallet.buildwallet = true;
    expect(snapshot.isCurrent(), isFalse);
    wallet.buildwallet = false;
    wallet.walletInfoLsit[0] = _info('replacement');
    expect(snapshot.isCurrent(), isFalse);
    expect(wallet.captureSigningCoinModels, throwsStateError);
    await wallet.buildCoinModel();
    final replaced = wallet.captureSigningCoinModels();
    wallet.owner = 'owner-b';
    expect(replaced.isCurrent(), isFalse);
    expect(wallet.captureSigningCoinModels, throwsStateError);
  });
  test(
    'selection change during build cannot publish a signing snapshot',
    () async {
      var changed = false;
      wallet.addListener(() {
        if (!changed) {
          changed = true;
          wallet.walletIndex = 1;
        }
      });
      await wallet.buildCoinModel();
      expect(wallet.captureSigningCoinModels, throwsStateError);
      await wallet.buildCoinModel();
      expect(
        wallet.captureSigningCoinModels().models.single.address,
        'address-b',
      );
    },
  );
}
