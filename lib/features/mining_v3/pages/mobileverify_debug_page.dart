// Debug-only page for mining v3 phase 1: runs MobileVerifyProbe once
// against a node's /mobileverify endpoint and shows each step. Reached
// from the settings page in debug builds only.

import 'package:flutter/material.dart';
import 'package:flutter_mining/mobileverify.dart';

import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/core/storage/secure_preferences.dart';
import 'package:n42_wallet/features/mining_v3/mobileverify_probe.dart';
import 'package:n42_wallet/features/mining_v3/mining_v3_engine.dart';

const _defaultBaseUrl = miningV3DefaultEndpoint;
const _defaultChain = miningV3DefaultChain;

class MobileVerifyDebugPage extends StatefulWidget {
  const MobileVerifyDebugPage({super.key});

  @override
  State<MobileVerifyDebugPage> createState() => _MobileVerifyDebugPageState();
}

class _MobileVerifyDebugPageState extends State<MobileVerifyDebugPage> {
  final _baseUrl = TextEditingController(text: _defaultBaseUrl);
  final _chain = TextEditingController(text: _defaultChain);
  final _log = <String>[];
  bool _running = false;
  MobileVerifyProbeResult? _result;

  @override
  void dispose() {
    _baseUrl.dispose();
    _chain.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _result = null;
      _log.clear();
    });
    final probe = MobileVerifyProbe(
      api: MethodChannelMobileVerify(),
      store: FlutterSecureStore(),
    );
    final result = await probe.run(
      MobileVerifyProbeConfig(
        baseUrl: _baseUrl.text.trim(),
        chain: _chain.text.trim(),
      ),
      (line) {
        if (mounted) setState(() => _log.add(line));
      },
    );
    if (mounted) {
      setState(() {
        _running = false;
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final result = _result;
    return Scaffold(
      backgroundColor: colors.bgBase,
      appBar: AppBar(
        title: Text('Mining v3 probe', style: AppTypography.title),
      ),
      body: Padding(
        padding: AppSpacing.pageHorizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.space4),
            TextField(
              controller: _baseUrl,
              enabled: !_running,
              decoration: const InputDecoration(labelText: 'mobileverify URL'),
            ),
            TextField(
              controller: _chain,
              enabled: !_running,
              decoration: const InputDecoration(labelText: 'chain'),
            ),
            SizedBox(height: AppSpacing.space4),
            FilledButton(
              onPressed: _running ? null : _run,
              child: Text(_running ? 'Running…' : 'Verify one block'),
            ),
            if (result != null) ...[
              SizedBox(height: AppSpacing.space4),
              Text(
                result.passed
                    ? 'PASS: ${result.signers} signers'
                    : 'FAIL: ${result.failure}',
                style: AppTypography.bodyStrong.copyWith(
                  color: result.passed ? colors.success : colors.danger,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.space4),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (context, i) => Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.space2 / 2,
                  ),
                  child: Text(
                    _log[i],
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
