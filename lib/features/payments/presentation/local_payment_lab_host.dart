import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/local_payment_client.dart';
import 'local_payment_lab_page.dart';

/// Explicit developer opt-in. Never exposed by a release build.
class LocalPaymentLabHost extends StatefulWidget {
  const LocalPaymentLabHost({super.key});

  static const isEnabled =
      !kReleaseMode &&
      bool.fromEnvironment('N42_LOCAL_PAYMENT_LAB', defaultValue: false);

  @override
  State<LocalPaymentLabHost> createState() => _LocalPaymentLabHostState();
}

class _LocalPaymentLabHostState extends State<LocalPaymentLabHost> {
  http.Client? _transport;
  LocalPaymentClient? _client;

  @override
  void initState() {
    super.initState();
    if (LocalPaymentLabHost.isEnabled) {
      _transport = http.Client();
      try {
        _client = LocalPaymentClient(
          endpoint: Uri.parse(
            const String.fromEnvironment(
              'N42_LOCAL_PAYMENT_ENDPOINT',
              defaultValue: 'http://127.0.0.1:8765',
            ),
          ),
          transport: _transport!,
          enabled: true,
        );
      } on ArgumentError {
        _transport!.close();
        _transport = null;
      } on FormatException {
        _transport!.close();
        _transport = null;
      }
    }
  }

  @override
  void dispose() {
    _client?.close();
    _transport?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;
    if (client == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'Local payment lab is disabled or has an invalid endpoint.',
            ),
          ),
        ),
      );
    }
    return LocalPaymentLabPage(client: client);
  }
}
