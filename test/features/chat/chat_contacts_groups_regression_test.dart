import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/unit/repositories/contact_repository_behavior_test.dart'
    as contacts;
import '../../../packages/n42_chat/test/unit/repositories/conversation_repository_behavior_test.dart'
    as conversations;
import '../../../packages/n42_chat/test/unit/repositories/group_token_gate_behavior_test.dart'
    as gates;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat contact lookup and persistence', contacts.main);
  group('Chat conversation state and lifecycle', conversations.main);
  group('Chat token gate verification and settings', gates.main);
}
