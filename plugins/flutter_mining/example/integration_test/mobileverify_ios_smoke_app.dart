// Opt-in iOS bridge acceptance app. It writes only public result metadata.
// Build with --dart-define=MINING_V3_IOS_SMOKE=true and this file as --target.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mining/mobileverify.dart';

const _enabled = bool.fromEnvironment('MINING_V3_IOS_SMOKE');
const _node = String.fromEnvironment(
  'MINING_V3_URL',
  defaultValue: 'http://192.168.0.217:21100',
);
const _chain = String.fromEnvironment(
  'MINING_V3_CHAIN',
  defaultValue: 'mainnet_qmdb_staggered',
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _SmokeApp());
}

class _SmokeApp extends StatefulWidget {
  const _SmokeApp();
  @override
  State<_SmokeApp> createState() => _SmokeState();
}

class _SmokeState extends State<_SmokeApp> {
  final api = MethodChannelMobileVerify();
  final checks = <String>[];
  final values = <String, Object?>{};
  String stage = 'Opt in to the iOS smoke test to run network checks.';
  late final directory = Directory(
    '${Directory.systemTemp.path}/n42-mobileverify-ios-smoke',
  );

  @override
  void initState() {
    super.initState();
    if (_enabled && Platform.isIOS) unawaited(run());
  }

  void require(bool condition, String message) {
    if (!condition) throw StateError(message);
  }

  Future<void> record(String next) async {
    if (mounted) setState(() => stage = next);
    await directory.create(recursive: true);
    final temporary = File('${directory.path}/results.tmp');
    await temporary.writeAsString(
      jsonEncode({'stage': next, 'checks': checks, 'values': values}),
    );
    await temporary.rename('${directory.path}/results.json');
  }

  Future<void> rejects(Future<Object?> Function() call) async {
    var rejected = false;
    try {
      await call();
    } on PlatformException catch (e) {
      rejected = e.code == 'MobileVerify';
    }
    require(rejected, 'The native bridge did not reject an invalid call.');
  }

  Future<void> waitForFlag(String flag) async {
    final deadline = DateTime.now().add(const Duration(minutes: 3));
    while (!await File('${directory.path}/$flag').exists()) {
      require(
        DateTime.now().isBefore(deadline),
        'The external lifecycle driver did not return.',
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> run() async {
    try {
      final uri = Uri.parse(_node);
      require(
        ['http', 'https'].contains(uri.scheme) &&
            uri.host.isNotEmpty &&
            uri.userInfo.isEmpty &&
            !uri.hasQuery &&
            !uri.hasFragment,
        'Invalid smoke node.',
      );
      await record('starting');
      final platform = await const MethodChannel(
        'flutter_mining',
      ).invokeMethod<String>('getPlatformVersion');
      require(
        platform?.startsWith('iOS ') == true,
        'Legacy platform channel failed.',
      );
      checks.add('legacy-platform-channel');
      await rejects(() => api.latest());
      await rejects(
        () => const MethodChannel(
          'n42/mobileverify',
        ).invokeMethod('open', {'baseUrl': _node}),
      );
      var unsupported = false;
      try {
        await const MethodChannel(
          'n42/mobileverify',
        ).invokeMethod('unsupported-smoke-method');
      } on MissingPluginException {
        unsupported = true;
      }
      require(unsupported, 'Unknown methods were not reported as unsupported.');
      checks.add('error-and-unsupported-methods');
      final key = await api.generateKey();
      require(key.length == 64, 'BLS key size was invalid.');
      final publicKey = await api.publicKey(key);
      require(publicKey.length == 96, 'BLS public key size was invalid.');
      require(
        await api.open(baseUrl: _node, privHex: key, chain: _chain) ==
            publicKey,
        'The opened session used a different identity.',
      );
      checks.add('key-and-session-identity');
      final health = await api.health();
      values['registryBefore'] = health['registry'];
      checks.add('node-health');
      await record('registering');
      final registrationDeadline = DateTime.now().add(
        const Duration(minutes: 3),
      );
      var registration = await api.register();
      while (!registration.committed) {
        require(
          DateTime.now().isBefore(registrationDeadline),
          'Device registration did not commit.',
        );
        await Future<void>.delayed(const Duration(seconds: 10));
        registration = await api.register();
      }
      values['deviceIndex'] = registration.index;
      checks.add('committed-registration');
      final packetDeadline = DateTime.now().add(const Duration(minutes: 1));
      var head = await api.latest();
      while (!head.packet) {
        require(
          DateTime.now().isBefore(packetDeadline),
          'No verifiable head packet was available.',
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        head = await api.latest();
      }
      final verified = await api.verifyBlock(head.hash);
      values['probeBlock'] = verified.blockNumber;
      values['probeTransactions'] = verified.txs;
      values['probeElapsedMs'] = verified.elapsedMs;
      values['certificatesAtProbe'] = (await api.cert(head.hash)).length;
      checks.add('latest-verify-and-certificate-query');
      await api.close();
      await rejects(() => api.latest());
      checks.add('session-close');
      await api.minerStart(baseUrl: _node, privHex: key, chain: _chain);
      final minerDeadline = DateTime.now().add(const Duration(minutes: 3));
      var before = await api.minerStatus();
      while (before.verified == 0 || before.certified == 0) {
        require(
          DateTime.now().isBefore(minerDeadline),
          'The miner did not verify and certify a block.',
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        before = await api.minerStatus();
      }
      require(
        before.running &&
            before.sessionId != null &&
            before.activeDurationMs != null,
        'iOS miner metadata was missing.',
      );
      checks.add('native-miner-verification-and-certification');
      values['verifiedBeforeBackground'] = before.verified;
      values['certifiedBeforeBackground'] = before.certified;
      final wallStart = DateTime.now();
      await record('ready-for-background');
      await waitForFlag('resume.request');
      await Future<void>.delayed(const Duration(seconds: 2));
      final after = await api.minerStatus();
      final wall = DateTime.now().difference(wallStart).inMilliseconds;
      final active = after.activeDurationMs! - before.activeDurationMs!;
      require(
        after.running && !after.pausedForBackground,
        'Miner did not resume on activation.',
      );
      require(
        after.sessionId == before.sessionId &&
            after.verified >= before.verified,
        'Foreground resume reset the user session or counters.',
      );
      require(
        wall - active >= 5000,
        'Background time was counted as active mining time.',
      );
      values['lifecycleWallMs'] = wall;
      values['lifecycleActiveMs'] = active;
      values['excludedBackgroundMs'] = wall - active;
      checks.add('real-background-pause-and-foreground-resume');
      await api.minerStop();
      final stopped = await api.minerStatus();
      require(
        !stopped.running && !stopped.pausedForBackground,
        'Miner did not stop.',
      );
      final frozen = stopped.activeDurationMs;
      await record('ready-after-stop');
      await waitForFlag('stopped-resume.request');
      await Future<void>.delayed(const Duration(seconds: 1));
      final finalStatus = await api.minerStatus();
      require(
        !finalStatus.running &&
            !finalStatus.pausedForBackground &&
            finalStatus.activeDurationMs == frozen,
        'A stopped miner resumed or its time kept increasing.',
      );
      checks.add('manual-stop-survives-background-and-return');
      values['finalVerified'] = finalStatus.verified;
      values['finalCertified'] = finalStatus.certified;
      values['finalActiveDurationMs'] = frozen;
      await record('passed');
    } catch (error) {
      try {
        await api.close();
        await api.minerStop();
      } catch (_) {}
      values['failure'] = error.toString();
      await record('failed');
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('N42 iOS bridge acceptance')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Text(
            '$stage\n\n${checks.join('\n')}\n\n${jsonEncode(values)}',
          ),
        ),
      ),
    ),
  );
}
