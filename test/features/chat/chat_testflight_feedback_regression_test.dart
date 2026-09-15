import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/presentation/pages/auth_forms_behavior_test.dart'
    as auth_forms;
import '../../../packages/n42_chat/test/presentation/pages/chat_file_lifecycle_test.dart'
    as chat_routes;
import '../../../packages/n42_chat/test/presentation/pages/settings/settings_navigation_test.dart'
    as settings;
import '../../../packages/n42_chat/test/unit/datasources/direct_friendship_test.dart'
    as friendship;
import '../../../packages/n42_chat/test/unit/datasources/registration_uia_test.dart'
    as registration;
import '../../../packages/n42_chat/test/unit/encryption/key_backup_behavior_test.dart'
    as key_backup;
import '../../../packages/n42_chat/test/unit/repositories/auth_session_behavior_test.dart'
    as auth_session;
import '../../../packages/n42_chat/test/unit/repositories/contact_repository_impl_test.dart'
    as contacts;
import '../../../packages/n42_chat/test/unit/repositories/message_repository_impl_test.dart'
    as messages;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat registration UIA', registration.main);
  group('Chat auth forms', auth_forms.main);
  group('Chat auth session and registration errors', auth_session.main);
  group('Chat accepted friendship and sending', friendship.main);
  group('Chat contact invitation policy', contacts.main);
  group('Chat key backup and verified restoration', key_backup.main);
  group('Chat timeline session and decryption', messages.main);
  group('Chat file action lifetime and recovery bubbles', chat_routes.main);
  group('Chat settings navigation and logout backup', settings.main);
}
