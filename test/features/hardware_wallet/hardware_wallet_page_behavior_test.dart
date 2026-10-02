import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/hardware_wallet/models/hardware_wallet_models.dart';
import 'package:n42_wallet/features/hardware_wallet/pages/hardware_wallet_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/widget_test_helpers.dart';

Map<String, dynamic> _device({
  required String id,
  required String name,
  required HardwareWalletType type,
  DateTime? lastConnectedAt,
}) => {
  'id': id,
  'name': name,
  'type': type.name,
  'lastConnectedAt': lastConnectedAt?.toIso8601String(),
};

void main() {
  Future<S> openPage(
    WidgetTester tester, {
    List<Map<String, dynamic>> devices = const [],
  }) async {
    SharedPreferences.setMockInitialValues({
      'hardware_wallet_devices': jsonEncode(devices),
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(wrapForTest(const HardwareWalletPage()));
    await tester.pumpAndSettle();
    return S.of(tester.element(find.byType(HardwareWalletPage)));
  }

  testWidgets(
    'empty state describes connection choices and supported wallets',
    (tester) async {
      final l10n = await openPage(tester);

      expect(find.text(l10n.g_key_hw_not_connected_label), findsOneWidget);
      expect(find.text(l10n.g_key_hw_connect_new_device), findsOneWidget);
      expect(find.text(l10n.g_key_hw_connect_new_ledger), findsOneWidget);
      expect(find.text(l10n.g_key_hw_connect_new_trezor), findsOneWidget);
      expect(find.text(l10n.g_key_hw_connect_new_keystone), findsOneWidget);
      expect(find.text(l10n.g_key_hw_supported_devices), findsOneWidget);
      expect(find.text('Ledger Nano X'), findsOneWidget);
      expect(find.text('Trezor Model T'), findsOneWidget);
      expect(find.text('Keystone Pro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'saved device cards format recent and old dates and support removal',
    (tester) async {
      final now = DateTime.now();
      final l10n = await openPage(
        tester,
        devices: [
          _device(
            id: 'ledger-today',
            name: 'Ledger now',
            type: HardwareWalletType.ledgerNanoX,
            lastConnectedAt: now,
          ),
          _device(
            id: 'trezor-old',
            name: 'Trezor old',
            type: HardwareWalletType.trezorOne,
            lastConnectedAt: DateTime(2020, 2, 3),
          ),
        ],
      );

      expect(find.text(l10n.g_key_hw_saved_devices), findsOneWidget);
      expect(find.text('Ledger now'), findsOneWidget);
      expect(find.text('Trezor old'), findsOneWidget);
      expect(
        find.text(l10n.g_key_hw_last_connected(l10n.g_key_hw_today)),
        findsOneWidget,
      );
      expect(
        find.text(l10n.g_key_hw_last_connected('3/2/2020')),
        findsOneWidget,
      );

      await tester.ensureVisible(find.byIcon(Icons.delete_outline).first);
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.g_key_hw_remove_device_confirm('Ledger now')),
        findsOneWidget,
      );
      await tester.tap(find.text(l10n.g_key_79));
      await tester.pumpAndSettle();
      expect(find.text('Ledger now'), findsOneWidget);

      await tester.ensureVisible(find.byIcon(Icons.delete_outline).first);
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.g_key_hw_remove));
      await tester.pumpAndSettle();

      expect(find.text('Ledger now'), findsNothing);
      expect(find.text('Trezor old'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      final saved =
          jsonDecode(prefs.getString('hardware_wallet_devices')!) as List;
      expect(saved.map((item) => item['id']), ['trezor-old']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reconnecting saved Keystone updates status without hardware IO',
    (tester) async {
      final l10n = await openPage(
        tester,
        devices: [
          _device(
            id: 'keystone-1',
            name: 'Keystone wallet',
            type: HardwareWalletType.keystoneModel,
          ),
        ],
      );

      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(find.text(l10n.g_key_hw_connected), findsWidgets);
      expect(find.text('Keystone'), findsWidgets);
      expect(find.text(l10n.g_key_hw_view_accounts), findsOneWidget);
      expect(find.text(l10n.g_key_hw_check_app), findsNothing);
      expect(find.text(l10n.g_key_hw_disconnect), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
