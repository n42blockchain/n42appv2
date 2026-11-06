import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_dialogs.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _from = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _to = '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';
const _path = "m/44'/60'/0'/0/0";

class _Wallet extends WalletActionProvider {
  WalletInfo owner = WalletInfo()..mnemonic = 'fixture mnemonic';
  final config = <String, dynamic>{
    'CUSTOM': {
      'baseInfo': {
        'path': {'legacy': _path},
      },
      'pathIndex': 0,
    },
  };
  @override
  bool get isWalletReady => true;
  @override
  String get userUUID => 'fixture-owner';
  @override
  String get walletDataOwnerUuid => 'fixture-owner';
  @override
  WalletInfo get walletInfo => owner;
  @override
  Map<String, dynamic> get walletMap => config;
}

class _Batch extends BatchTransferProvider {
  Future<void> Function()? onBuild;
  int broadcasts = 0;
  bool Function()? broadcastGuard;
  @override
  BatchGasEstimate get gasEstimate => BatchGasEstimate(
    gasLimit: BigInt.one,
    gasPrice: BigInt.one,
    totalFee: BigInt.one,
    isEip1559: false,
  );
  @override
  Future<void> recoverPending() async {}
  @override
  Future<void> estimateGas() async {}
  @override
  Future<Map<String, dynamic>?> buildTransaction() async {
    await onBuild?.call();
    return {'toAddress': _to, 'amount': '1'};
  }

  @override
  Future<bool> broadcastTransaction(
    String signedTx, {
    bool Function()? isOwnerCurrent,
  }) async {
    broadcasts++;
    broadcastGuard = isOwnerCurrent;
    return false; // Stay on the real page without a simulated success sheet.
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('trustdart');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  for (final scenario in [
    'match',
    'private key',
    'mismatch',
    'missing address',
    'owner during derive',
    'key during derive',
    'path during build',
    'owner during sign',
    'key after sign',
  ]) {
    testWidgets('batch signing: $scenario', (tester) async {
      tester.view.physicalSize = const Size(480, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final wallet = _Wallet();
      final batch = _Batch();
      if (scenario == 'private key') {
        wallet.owner.privateKey = 'fixture private key';
      }
      if (scenario == 'path during build') {
        batch.onBuild = () async {
          wallet.config['CUSTOM']['pathIndex'] = 1;
        };
      }
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'generateAddress') {
          if (scenario == 'owner during derive') wallet.owner = WalletInfo();
          if (scenario == 'key during derive') {
            wallet.owner.mnemonic = 'replacement';
          }
          return {
            'legacy': scenario == 'mismatch'
                ? _to
                : scenario == 'missing address'
                ? ''
                : _from.toUpperCase().replaceFirst('0X', '0x'),
          };
        }
        if (call.method == 'signTransaction') {
          if (scenario == 'owner during sign') wallet.owner = WalletInfo();
          return 'fixture signed bytes';
        }
        throw StateError('Unexpected native call ${call.method}');
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      addTearDown(batch.dispose);
      await tester.pumpWidget(
        wrapForTest(
          BatchTransferPage(
            chainSymbol: 'CUSTOM',
            rpcUrl: 'https://offline.invalid',
            chainId: 1,
            fromAddress: _from,
            tokenSymbol: 'ETH',
            decimals: 18,
            balance: BigInt.from(10).pow(20),
            batchTransferProvider: batch,
          ),
          overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), _to);
      await tester.enterText(find.byType(TextField).at(1), '1');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      final l10n = S.of(tester.element(find.byType(BatchTransferPage)));
      await tester.tap(
        find.widgetWithText(ElevatedButton, l10n.g_key_batch_continue),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BatchConfirmDialog), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(BatchConfirmDialog),
          matching: find.widgetWithText(ElevatedButton, l10n.g_key_78),
        ),
      );
      // A blocked old-owner page or fixture broadcast may retain its spinner.
      // Give the async native callbacks and dialog transition finite turns.
      for (var frame = 0; frame < 12; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      final signed = calls
          .where((call) => call.method == 'signTransaction')
          .toList();
      final succeeds = [
        'match',
        'private key',
        'key after sign',
      ].contains(scenario);
      expect(batch.broadcasts, succeeds ? 1 : 0);
      expect(
        signed.length,
        succeeds || scenario == 'owner during sign' ? 1 : 0,
      );
      if (succeeds) {
        final derived = calls.singleWhere(
          (call) => call.method == 'generateAddress',
        );
        expect(derived.arguments['coin'], 'ETH');
        expect(derived.arguments['path'], _path);
        expect(signed.single.arguments['path'], _path);
        expect(
          signed.single.arguments['mnemonic'],
          scenario == 'private key' ? '' : 'fixture mnemonic',
        );
        expect(
          signed.single.arguments['pk'],
          scenario == 'private key' ? 'fixture private key' : '',
        );
        expect(batch.broadcastGuard!(), isTrue);
        if (scenario == 'key after sign') {
          wallet.owner.mnemonic = 'replacement';
          expect(batch.broadcastGuard!(), isFalse);
        }
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
