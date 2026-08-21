// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot: (name, bytes, [args]) async {
      final output = File(
        'docs/device-test-reports/assets/'
        '2026-08-21-chat-discover-live/$name.png',
      );
      await output.parent.create(recursive: true);
      await output.writeAsBytes(bytes, flush: true);
      return true;
    },
  );
}
