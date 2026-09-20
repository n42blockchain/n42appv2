import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/unit/datasources/account_homeserver_probe_test.dart'
    as homeserver;
import '../../../packages/n42_chat/test/unit/encryption/account_session_index_test.dart'
    as sessions;
import '../../../packages/n42_chat/test/unit/encryption/token_device_session_test.dart'
    as tokens;

import '../../../packages/n42_chat/test/unit/encryption/session_preserving_client_test.dart'
    as keyRetention;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat durable inbound keys', keyRetention.main);
  group('Chat isolated account databases', sessions.main);
  group('Chat token device identity', tokens.main);
  group('Chat account server probes', homeserver.main);
}
