import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fixture_workflow.dart';

const _control = MethodChannel('ai.n42.fixture/datastore_control');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('DataStore fixture'))),
    ),
  );

  final phase = await _control.invokeMethod<String>('phase');
  try {
    final result = switch (phase) {
      'seed' => await runSeed(),
      'verify' => await runVerify(),
      _ => throw StateError('invalid fixture phase: $phase'),
    };
    await _control.invokeMethod<void>('record', {
      'phase': phase,
      'status': 'PASS',
      'counter': result['counter'],
    });
  } catch (error, stack) {
    await _control.invokeMethod<void>('record', {
      'phase': phase,
      'status': 'FAIL',
      'error': error.toString(),
      'stack': stack.toString(),
    });
  }
}
