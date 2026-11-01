// Opt-in device harness. Uses only public test input and an isolated app ID.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_cache_utils.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_plugin_utils.dart';
import 'package:n42_wallet/features/mining_v3/pages/mobileverify_debug_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: _NativeRegressionPage()));
}

class _NativeRegressionPage extends StatefulWidget {
  const _NativeRegressionPage();

  @override
  State<_NativeRegressionPage> createState() => _NativeRegressionPageState();
}

class _NativeRegressionPageState extends State<_NativeRegressionPage> {
  final _lines = <String>[];
  bool _done = false;

  @override
  void initState() {
    super.initState();
    if (const bool.fromEnvironment('T30_NATIVE_SMOKE')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  void _record(String line) {
    debugPrint('T30_V1 $line');
    if (mounted) setState(() => _lines.add(line));
  }

  Map<String, dynamic> _checked(String method, Map<String, dynamic>? value) {
    if (value == null || value['code'] is! num) {
      throw StateError('$method did not return native JSON');
    }
    _record(jsonEncode({'method': method, 'response': value}));
    return value;
  }

  void _require(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  Future<void> _run() async {
    // This is the public fixture from the Go SDK's Emit dispatch test.
    // Never read a wallet's private key for this bridge regression.
    const key =
        '202cbf36864a88e348c8f573aa0bc79f5a7119e58251c3580bb08af70cb2dfed';
    try {
      final path = await MiningCacheUtils.getMiningCachePath();
      final endpoint = await MiningCacheUtils.getCurrentSocketUrl();
      _require(path != null, 'no application data directory');
      _record('server $endpoint');
      _checked('stop-before', await MiningPluginUtils.stop());
      final initial = _checked(
        'state-before',
        await MiningPluginUtils.status(),
      );
      _require(
        initial['code'] == 0 && initial['data'] == 'stopped',
        'initial state',
      );
      final setting = _checked(
        'setting',
        await MiningPluginUtils.initSetting(
          '0x0000000000000000000000000000000000000000',
          path!,
          key,
          endpoint,
        ),
      );
      _require(setting['code'] == 0, 'setting failed');
      final pub = _checked('blspubk', await MiningPluginUtils.getPubKey(key));
      _require(
        pub['code'] == 0 &&
            RegExp(r'^[0-9a-f]{96}$').hasMatch('${pub['data']}'),
        'invalid public key response',
      );
      final sign = _checked(
        'blssign',
        await MiningPluginUtils.blsSign(key, '8ac7230489e80000'),
      );
      _require(
        sign['code'] == 0 &&
            RegExp(r'^[0-9a-f]{192}$').hasMatch('${sign['data']}'),
        'invalid signature response',
      );
      final start = _checked('start', await MiningPluginUtils.start());
      await Future<void>.delayed(const Duration(seconds: 2));
      final state = _checked('state-after', await MiningPluginUtils.status());
      _require(state['code'] == 0, 'state read failed');
      if (start['code'] == 0) {
        _require(state['data'] == 'started', 'start did not change state');
      } else {
        _require('${start['message'] ?? ''}'.isNotEmpty, 'missing start error');
      }
      _checked('stop-after', await MiningPluginUtils.stop());
      final stopped = _checked(
        'state-stopped',
        await MiningPluginUtils.status(),
      );
      _require(stopped['data'] == 'stopped', 'stop did not change state');
      _record('PASS: v1 native bridge; no funded mining acceptance');
    } on Object catch (error) {
      _record('FAIL: $error');
      await MiningPluginUtils.stop();
    } finally {
      if (mounted) setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('T30 native regression')),
    body: Column(
      children: [
        FilledButton(
          onPressed: _done
              ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MobileVerifyDebugPage(),
                  ),
                )
              : null,
          child: const Text('Open production probe'),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SelectableText(_lines.join('\n')),
          ),
        ),
      ],
    ),
  );
}
