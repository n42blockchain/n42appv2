import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/unit/datasources/account_homeserver_probe_test.dart'
    as homeserver;
import '../../../packages/n42_chat/test/unit/encryption/account_session_index_test.dart'
    as sessions;
import '../../../packages/n42_chat/test/unit/encryption/token_device_session_test.dart'
    as tokens;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat isolated account databases', sessions.main);
  group('Chat token device identity', tokens.main);
  group('Chat account server probes', homeserver.main);
}
