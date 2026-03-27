// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Pseudo-Localization Overflow Test
///
/// Reads pseudo-localized strings (intl_qps.arb — all EN strings padded +50%
/// with accents) and renders real app layout patterns with them to detect
/// overflow.
///
/// This catches issues that per-locale testing misses, because pseudo strings
/// are *uniformly* longer than any single real locale.
///
/// Run: flutter test test/pseudo_locale_overflow_test.dart
///
/// Prerequisites: python scripts/generate_pseudo_locale.py (generates intl_qps.arb)

import 'dart:convert';
import 'dart:io';

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
      _overflows.add(
          '${msg.split('\n').first}');
    } else {
      original?.call(details);
    }
  };
}

List<String> _endCapture() {
  FlutterError.onError = FlutterError.dumpErrorToConsole;
  return List.unmodifiable(_overflows);
}

// ── Load pseudo strings ─────────────────────────────────────────────────

late Map<String, String> _pseudo;
late Map<String, String> _english;

void _loadArb() {
  final pseudoFile = File('lib/l10n/intl_qps.arb');
  final enFile = File('lib/l10n/intl_en.arb');

  if (!pseudoFile.existsSync()) {
    fail('intl_qps.arb not found. Run: python scripts/generate_pseudo_locale.py');
  }

  final pseudoRaw = json.decode(pseudoFile.readAsStringSync()) as Map<String, dynamic>;
  final enRaw = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;

  _pseudo = {};
  _english = {};
  for (final e in pseudoRaw.entries) {
    if (!e.key.startsWith('@') && e.value is String) {
      _pseudo[e.key] = e.value as String;
    }
  }
  for (final e in enRaw.entries) {
    if (!e.key.startsWith('@') && e.value is String) {
      _english[e.key] = e.value as String;
    }
  }
}

/// Get pseudo string, replacing {placeholders} with sample values
String _ps(String key) {
  var s = _pseudo[key] ?? _english[key] ?? key;
  // Replace remaining {param} with sample values
  s = s.replaceAllMapped(RegExp(r'\{[a-zA-Z_]\w*\}'), (m) => '12345');
  return s;
}

// ── Screen sizes ────────────────────────────────────────────────────────

const _smallPhone = Size(320, 568); // iPhone SE
const _normalPhone = Size(375, 812); // iPhone X

// ── Test harness ────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

Future<List<String>> _pumpAndDetect(
  WidgetTester tester,
  Widget child,
  Size surface,
) async {
  _startCapture();
  await tester.binding.setSurfaceSize(surface);
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(_wrap(child));
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return _endCapture();
}

/// Test a widget on small + normal screens, collect overflows
Future<Map<String, List<String>>> _stress(
  WidgetTester tester,
  String label,
  Widget widget,
) async {
  final results = <String, List<String>>{};
  for (final e in {'SE': _smallPhone, 'iX': _normalPhone}.entries) {
    final errors = await _pumpAndDetect(tester, widget, e.value);
    if (errors.isNotEmpty) {
      results['$label [${e.key}]'] = errors;
    }
  }
  await tester.binding.setSurfaceSize(null);
  return results;
}

String _fmt(Map<String, List<String>> r) {
  if (r.isEmpty) return '';
  return r.entries.map((e) => '  ${e.key}: ${e.value.join('; ')}').join('\n');
}

// ── Layout patterns matching real app code ──────────────────────────────

/// Pattern: AppBar title (tests AppBarWidget fix)
Widget _appBar(String key) => AppBar(
  title: Text(_ps(key), maxLines: 1, overflow: TextOverflow.ellipsis),
);

/// Pattern: Row with label + value (tests send pages fix)
Widget _labelValueRow(String labelKey) => Padding(
  padding: const EdgeInsets.all(16),
  child: Row(children: [
    Flexible(
      child: Text(_ps(labelKey),
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

/// Pattern: Icon + text row (tests section headers)
Widget _iconTextRow(String key) => Padding(
  padding: const EdgeInsets.all(16),
  child: Row(children: [
    const Icon(Icons.info_outline, size: 24),
    const SizedBox(width: 8),
    Flexible(
      child: Text(_ps(key),
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  ]),
);

/// Pattern: Button pair (tests buttonStyle1/2 fix)
Widget _buttonPair(String cancelKey, String confirmKey) => Padding(
  padding: const EdgeInsets.all(16),
  child: Row(children: [
    Expanded(
      child: OutlinedButton(
        onPressed: () {},
        child: Text(_ps(cancelKey),
          maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: ElevatedButton(
        onPressed: () {},
        child: Text(_ps(confirmKey),
          maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
        ),
      ),
    ),
  ]),
);

/// Pattern: Full-width button
Widget _fullButton(String key) => Padding(
  padding: const EdgeInsets.all(16),
  child: SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: () {},
      child: Text(_ps(key), maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  ),
);

/// Pattern: Checkbox + label
Widget _checkboxRow(String key) => Padding(
  padding: const EdgeInsets.all(16),
  child: Row(children: [
    Checkbox(value: false, onChanged: (_) {}),
    Expanded(
      child: Text(_ps(key), overflow: TextOverflow.ellipsis),
    ),
  ]),
);

/// Pattern: Drawer menu item
Widget _drawerItem(String key) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Row(children: [
    Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.settings, size: 24),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: Text(_ps(key),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
    ),
    const Icon(Icons.chevron_right, size: 24),
  ]),
);

/// Pattern: Sort bar with chips (Wrap)
Widget _sortBar(List<String> chipKeys) => Padding(
  padding: const EdgeInsets.all(16),
  child: Wrap(
    spacing: 8, runSpacing: 4,
    children: chipKeys.map((k) =>
      Chip(label: Text(_ps(k), style: const TextStyle(fontSize: 12)))
    ).toList(),
  ),
);

/// Pattern: Dialog body with long text + scrollable
Widget _dialogBody(List<String> textKeys) => SingleChildScrollView(
  padding: const EdgeInsets.all(24),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: textKeys.map((k) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(_ps(k), style: const TextStyle(fontSize: 14)),
    )).toList(),
  ),
);

/// Pattern: TabBar
Widget _tabBar(List<String> tabKeys) => DefaultTabController(
  length: tabKeys.length,
  child: Column(children: [
    TabBar(
      isScrollable: true,
      tabs: tabKeys.map((k) => Tab(text: _ps(k))).toList(),
    ),
    Expanded(
      child: TabBarView(
        children: tabKeys.map((_) => const SizedBox()).toList(),
      ),
    ),
  ]),
);

// ── Tests ───────────────────────────────────────────────────────────────

void main() {
  setUpAll(_loadArb);

  group('Pseudo-Locale — AppBar titles', () {
    for (final key in [
      'g_key_94', 'g_key_108', 'g_key_6', 's_key_11',
      'g_key_ex_keystore_1', 'g_key_batch_title', 'g_key_manage_chains',
      'g_portfolio_title', 'g_browser_key5',
    ]) {
      testWidgets('AppBar: $key', (t) async {
        final r = await _stress(t, key, _appBar(key));
        expect(r, isEmpty, reason: _fmt(r));
      });
    }
  });

  group('Pseudo-Locale — Label-Value Rows', () {
    for (final key in [
      'g_key_44', 'g_key_29', 'g_key_43', 'g_key_101',
      'g_key_75', 'g_key_38', 'g_key_xml_0',
    ]) {
      testWidgets('LabelValue: $key', (t) async {
        final r = await _stress(t, key, _labelValueRow(key));
        expect(r, isEmpty, reason: _fmt(r));
      });
    }
  });

  group('Pseudo-Locale — Icon+Text Rows', () {
    for (final key in [
      'g_key_aa_batch_transaction', 'g_key_aa_gas_payment_options',
      'g_key_advanced_features', 'g_key_ens_resolving',
      'g_key_aa_address_calculating',
    ]) {
      testWidgets('IconText: $key', (t) async {
        final r = await _stress(t, key, _iconTextRow(key));
        expect(r, isEmpty, reason: _fmt(r));
      });
    }
  });

  group('Pseudo-Locale — Button Pairs', () {
    testWidgets('Cancel/Confirm', (t) async {
      final r = await _stress(t, 'buttons', _buttonPair('g_key_78', 'g_key_79'));
      expect(r, isEmpty, reason: _fmt(r));
    });
  });

  group('Pseudo-Locale — Full-width Buttons', () {
    for (final key in [
      'g_key_stake_start_staking', 'g_key_stake_go_to_swap',
      'g_mining_key62', 'g_mining_key_79',
    ]) {
      testWidgets('FullBtn: $key', (t) async {
        final r = await _stress(t, key, _fullButton(key));
        expect(r, isEmpty, reason: _fmt(r));
      });
    }
  });

  group('Pseudo-Locale — Checkbox Rows', () {
    for (final key in ['g_key_aa_session_amount_limit', 'g_key_aa_permission']) {
      testWidgets('Checkbox: $key', (t) async {
        final r = await _stress(t, key, _checkboxRow(key));
        expect(r, isEmpty, reason: _fmt(r));
      });
    }
  });

  group('Pseudo-Locale — Drawer Items', () {
    for (final key in ['g_key_94', 's_key_11', 'g_key_108', 's_key_1', 's_key_10']) {
      testWidgets('Drawer: $key', (t) async {
        final r = await _stress(t, key, _drawerItem(key));
        expect(r, isEmpty, reason: _fmt(r));
      });
    }
  });

  group('Pseudo-Locale — Sort/Filter Bars', () {
    testWidgets('Staking sort bar', (t) async {
      final r = await _stress(t, 'sort',
        _sortBar(['g_key_stake_sort_by', 'g_key_stake_apy',
                   'g_key_stake_commission', 'g_key_stake_staked']));
      expect(r, isEmpty, reason: _fmt(r));
    });
  });

  group('Pseudo-Locale — TabBars', () {
    testWidgets('Loyalty tabs', (t) async {
      final r = await _stress(t, 'loyaltyTabs',
        _tabBar(['g_key_loyalty_tasks', 'g_key_loyalty_rewards', 'g_key_loyalty_history']));
      expect(r, isEmpty, reason: _fmt(r));
    });
    testWidgets('Session key tabs', (t) async {
      final r = await _stress(t, 'sessionTabs',
        _tabBar(['g_key_aa_active', 'g_key_aa_expired', 'g_key_aa_revoked_status']));
      expect(r, isEmpty, reason: _fmt(r));
    });
  });

  group('Pseudo-Locale — Dialog Bodies', () {
    testWidgets('Mining confirm dialog', (t) async {
      final r = await _stress(t, 'miningDialog',
        _dialogBody(['g_mining_key_114', 'g_mining_key_45', 'g_mining_key_46']));
      expect(r, isEmpty, reason: _fmt(r));
    });
    testWidgets('Burn NFT dialog', (t) async {
      final r = await _stress(t, 'burnNft',
        _dialogBody(['g_key_burn_nft_title', 'g_key_burn_nft_tip',
                     'g_key_burn_nft_step1', 'g_key_burn_nft_step2',
                     'g_key_burn_nft_step3', 'g_key_burn_nft_step4']));
      expect(r, isEmpty, reason: _fmt(r));
    });
  });

  group('Pseudo-Locale — Composite Pages', () {
    testWidgets('Send page layout', (t) async {
      final r = await _stress(t, 'sendPage', ListView(children: [
        _appBar('g_key_48'),
        _labelValueRow('g_key_44'),
        _labelValueRow('g_key_43'),
        _labelValueRow('g_key_101'),
        _buttonPair('g_key_79', 'g_key_78'),
      ]));
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Earn page layout', (t) async {
      final r = await _stress(t, 'earnPage', ListView(children: [
        _iconTextRow('g_key_stake_start_staking'),
        _iconTextRow('g_key_earn_batch'),
        _iconTextRow('g_key_earn_mining'),
        _fullButton('g_key_stake_go_to_swap'),
        _sortBar(['g_key_stake_apy', 'g_key_stake_commission', 'g_key_stake_staked']),
      ]));
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('Drawer layout', (t) async {
      final r = await _stress(t, 'drawer', ListView(children: [
        _drawerItem('g_key_94'),
        _drawerItem('s_key_11'),
        _drawerItem('g_key_108'),
        _drawerItem('s_key_1'),
        _drawerItem('s_key_10'),
        _drawerItem('g_browser_key11'),
        _buttonPair('g_key_79', 'g_key_78'),
      ]));
      expect(r, isEmpty, reason: _fmt(r));
    });

    testWidgets('High-risk keys composite', (t) async {
      // Top expansion keys from stress report
      final r = await _stress(t, 'highRisk', ListView(children: [
        _labelValueRow('g_key_stake_avg_apy'),  // 5.7x
        _iconTextRow('g_key_ex_keystore_1'),    // 3.8x
        _fullButton('g_key_aa_retry'),           // 5.6x
        _checkboxRow('g_key_feedback_8'),        // 3.7x
        _drawerItem('g_key_105'),                // 3.7x
      ]));
      expect(r, isEmpty, reason: _fmt(r));
    });
  });
}
