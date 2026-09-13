import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/chat_coverage_device_cases.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerChatCoverageDeviceCases((tester, _) => tester.pumpAndSettle());
}
