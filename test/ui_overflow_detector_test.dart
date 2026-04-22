// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Automated UI Overflow Detector
///
/// Self-contained test that does NOT import app code (avoids n42_chat compile
/// issues). Instead, it recreates the shared widget patterns and localized
/// string lengths to stress-test layout constraints.
///
/// Run: flutter test test/ui_overflow_detector_test.dart
///
/// Stress axes:
///   - Text length: normal (EN), long (+50%), very long (+100%)
///   - Screen: 320x480 (SE), 375x667 (iPhone 8), 375x812 (iPhone X)
///   - Direction: LTR, RTL
library;


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Overflow capture ────────────────────────────────────────────────────

final List<String> _overflows = [];

void _startCapture() {
  _overflows.clear();
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    final msg = details.exceptionAsString();
    if (msg.contains('overflowed')) {
      _overflows.add(msg);
    } else {
      original?.call(details);
    }
  };
}

List<String> _endCapture() {
  FlutterError.onError = FlutterError.dumpErrorToConsole;
  return List.unmodifiable(_overflows);
}

// ── Simulated localized strings ─────────────────────────────────────────
// Real l10n examples from the app, with German/Russian equivalents.

class _L10n {
  final String amount; // g_key_44
  final String wallet; // g_key_6
  final String settings; // g_key_94
  final String security; // s_key_11
  final String addressBook; // g_key_108
  final String cancel; // g_key_78
  final String confirm; // g_key_79
  final String advancedFeatures;
  final String batchTransaction;
  final String gasPaymentOptions;
  final String startStaking;
  final String sortBy;
  final String apy;
  final String commission;
  final String staked;

  const _L10n({
    required this.amount,
    required this.wallet,
    required this.settings,
    required this.security,
    required this.addressBook,
    required this.cancel,
    required this.confirm,
    required this.advancedFeatures,
    required this.batchTransaction,
    required this.gasPaymentOptions,
    required this.startStaking,
    required this.sortBy,
    required this.apy,
    required this.commission,
    required this.staked,
  });
}

const _en = _L10n(
  amount: 'Amount',
  wallet: 'Wallet',
  settings: 'Settings',
  security: 'Security',
  addressBook: 'Address Book',
  cancel: 'Cancel',
  confirm: 'Confirm',
  advancedFeatures: 'Advanced Features',
  batchTransaction: 'Batch Transaction',
  gasPaymentOptions: 'Gas Payment Options',
  startStaking: 'Start Staking',
  sortBy: 'Sort by',
  apy: 'APY',
  commission: 'Commission',
  staked: 'Staked',
);

const _de = _L10n(
  amount: 'Betrag',
  wallet: 'Geldbörse',
  settings: 'Einstellungen',
  security: 'Sicherheit',
  addressBook: 'Adressbuch',
  cancel: 'Abbrechen',
  confirm: 'Bestätigen',
  advancedFeatures: 'Erweiterte Funktionen',
  batchTransaction: 'Stapeltransaktion',
  gasPaymentOptions: 'Gas-Zahlungsoptionen',
  startStaking: 'Staking starten',
  sortBy: 'Sortieren nach',
  apy: 'Jährliche Rendite',
  commission: 'Provision',
  staked: 'Eingesetzt',
);

const _ru = _L10n(
  amount: 'Сумма',
  wallet: 'Кошелёк',
  settings: 'Настройки',
  security: 'Безопасность',
  addressBook: 'Адресная книга',
  cancel: 'Отменить',
  confirm: 'Подтвердить',
  advancedFeatures: 'Расширенные возможности',
  batchTransaction: 'Пакетная транзакция',
  gasPaymentOptions: 'Варианты оплаты газа',
  startStaking: 'Начать стейкинг',
  sortBy: 'Сортировать по',
  apy: 'Годовая доходность',
  commission: 'Комиссия',
  staked: 'Застейкано',
);

// ── Screen sizes ────────────────────────────────────────────────────────

const _screens = {
  'SE_320x480': Size(320, 480),
  'i8_375x667': Size(375, 667),
  'iX_375x812': Size(375, 812),
};

// ── Test harness ────────────────────────────────────────────────────────

Widget _wrap(Widget child, {TextDirection dir = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: dir,
      child: Scaffold(body: child),
    ),
  );
}

Future<List<String>> _pumpAndDetect(
  WidgetTester tester,
  Widget child, {
  required Size surface,
  TextDirection dir = TextDirection.ltr,
}) async {
  _startCapture();
  await tester.binding.setSurfaceSize(surface);
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(_wrap(child, dir: dir));
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return _endCapture();
}

/// Run widget across all locales & screen sizes. Returns failure map.
Future<Map<String, List<String>>> _stressAll(
  WidgetTester tester,
  String label,
  Widget Function(_L10n l) builder, {
  TextDirection dir = TextDirection.ltr,
}) async {
  final locales = {'en': _en, 'de': _de, 'ru': _ru};
  final results = <String, List<String>>{};

  for (final le in locales.entries) {
    for (final se in _screens.entries) {
      final key = '$label [${le.key} ${se.key}]';
      final errors = await _pumpAndDetect(
        tester,
        builder(le.value),
        surface: se.value,
        dir: dir,
      );
      if (errors.isNotEmpty) results[key] = errors;
    }
  }
  await tester.binding.setSurfaceSize(null);
  return results;
}

String _fmt(Map<String, List<String>> r) {
  if (r.isEmpty) return '';
  final b = StringBuffer();
  for (final e in r.entries) {
    b.writeln('  ${e.key}:');
    for (final m in e.value) {
      b.writeln('    - ${m.split('\n').first}');
    }
  }
  return b.toString();
}

// ── Pattern: AppBar title ───────────────────────────────────────────────

Widget _appBarTitle(_L10n l) {
  return AppBar(
    title: Text(
      l.settings,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

// ── Pattern: Label + Value Row (send pages) ─────────────────────────────

Widget _labelValueRow(_L10n l) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Flexible(
        child: Text(l.amount,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 8),
      const Expanded(
        child: Text('0.00000000 ETH',
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]),
  );
}

// ── Pattern: Button Row (cancel / confirm) ──────────────────────────────

Widget _buttonRow(_L10n l) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () {},
          child: Text(l.cancel, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: () {},
          child: Text(l.confirm, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
    ]),
  );
}

// ── Pattern: Icon + Text Row (section headers) ──────────────────────────

Widget _iconTextRow(_L10n l) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      const Icon(Icons.layers, size: 24),
      const SizedBox(width: 8),
      Flexible(
        child: Text(l.batchTransaction,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    ]),
  );
}

// ── Pattern: Checkbox + Text Row (form fields) ──────────────────────────

Widget _checkboxRow(_L10n l) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Checkbox(value: false, onChanged: (_) {}),
      Expanded(
        child: Text(l.gasPaymentOptions, overflow: TextOverflow.ellipsis),
      ),
    ]),
  );
}

// ── Pattern: Sort bar with multiple chips ───────────────────────────────

Widget _sortBar(_L10n l) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        Text(l.sortBy, style: const TextStyle(fontSize: 14)),
        Chip(label: Text(l.apy, style: const TextStyle(fontSize: 12))),
        Chip(label: Text(l.commission, style: const TextStyle(fontSize: 12))),
        Chip(label: Text(l.staked, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}

// ── Pattern: Full-width button ──────────────────────────────────────────

Widget _fullWidthButton(_L10n l) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        child: Text(l.startStaking,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}

// ── Pattern: Drawer menu item ───────────────────────────────────────────

Widget _drawerItem(_L10n l) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.security, color: Colors.blue, size: 24),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(l.security,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
    ]),
  );
}

// ── Pattern: TabBar ─────────────────────────────────────────────────────

Widget _tabBar(_L10n l) {
  return DefaultTabController(
    length: 3,
    child: Column(children: [
      TabBar(
        isScrollable: true,
        tabs: [
          Tab(text: l.settings),
          Tab(text: l.security),
          Tab(text: l.addressBook),
        ],
      ),
      const Expanded(child: TabBarView(
        children: [SizedBox(), SizedBox(), SizedBox()],
      )),
    ]),
  );
}

// ── Pattern: Dialog body with long text ─────────────────────────────────

Widget _dialogBody(_L10n l) {
  final longText = '${l.advancedFeatures}\n\n'
      '${l.gasPaymentOptions}: ${l.batchTransaction}\n\n'
      '${l.startStaking}\n${l.sortBy} ${l.apy}, ${l.commission}, ${l.staked}';
  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l.settings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(longText, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        const TextField(decoration: InputDecoration(hintText: 'Input...')),
      ],
    ),
  );
}

// ── Pattern: Composite page (simulates a real page) ─────────────────────

Widget _compositePage(_L10n l) {
  return ListView(children: [
    _labelValueRow(l),
    _iconTextRow(l),
    _checkboxRow(l),
    _sortBar(l),
    _buttonRow(l),
    _fullWidthButton(l),
    _drawerItem(l),
  ]);
}

// ── Tests ───────────────────────────────────────────────────────────────

void main() {
  group('Overflow Detector — Individual Patterns', () {
    testWidgets('AppBar title', (t) async {
      final r = await _stressAll(t, 'AppBar', _appBarTitle);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Label-Value Row', (t) async {
      final r = await _stressAll(t, 'LabelValue', _labelValueRow);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Button Row', (t) async {
      final r = await _stressAll(t, 'Buttons', _buttonRow);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Icon + Text Row', (t) async {
      final r = await _stressAll(t, 'IconText', _iconTextRow);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Checkbox + Text Row', (t) async {
      final r = await _stressAll(t, 'Checkbox', _checkboxRow);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Sort bar (Wrap)', (t) async {
      final r = await _stressAll(t, 'SortBar', _sortBar);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Full-width button', (t) async {
      final r = await _stressAll(t, 'FullBtn', _fullWidthButton);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Drawer menu item', (t) async {
      final r = await _stressAll(t, 'DrawerItem', _drawerItem);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('TabBar', (t) async {
      final r = await _stressAll(t, 'TabBar', _tabBar);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Dialog body with ScrollView', (t) async {
      final r = await _stressAll(t, 'DialogBody', _dialogBody);
      expect(r, isEmpty, reason: _fmt(r));
    });
  });

  group('Overflow Detector — Composite Stress', () {
    testWidgets('Full page composite (LTR)', (t) async {
      final r = await _stressAll(t, 'Composite-LTR', _compositePage);
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Full page composite (RTL)', (t) async {
      final r = await _stressAll(
        t, 'Composite-RTL', _compositePage,
        dir: TextDirection.rtl,
      );
      expect(r, isEmpty, reason: _fmt(r));
    });
  });

  group('Overflow Detector — Regression: broken patterns', () {
    testWidgets('UNPROTECTED Row label should overflow on small screen', (t) async {
      // This intentionally tests a BROKEN pattern to verify the detector works
      final r = await _stressAll(t, 'BrokenRow', (l) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Intentionally NO Flexible wrapping — should overflow
            Text(l.gasPaymentOptions,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(l.batchTransaction,
              style: const TextStyle(fontSize: 16),
            ),
          ]),
        );
      });
      // We EXPECT this to overflow on small screens with long locales
      expect(r.isNotEmpty, isTrue,
        reason: 'Detector should catch unprotected Row overflow');
    });
  });
}
