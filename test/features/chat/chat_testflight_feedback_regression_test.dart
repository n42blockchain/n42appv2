import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/presentation/pages/contact_detail_page_test.dart'
    as contact_details;
import '../../../packages/n42_chat/test/unit/blocs/auth_bloc_extended_test.dart'
    as biometric_auth;
import '../../../packages/n42_chat/test/presentation/pages/auth_forms_behavior_test.dart'
    as auth_forms;
import '../../../packages/n42_chat/test/presentation/pages/chat_file_lifecycle_test.dart'
    as chat_routes;
import '../../../packages/n42_chat/test/presentation/pages/settings/settings_navigation_test.dart'
    as settings;
import '../../../packages/n42_chat/test/presentation/pages/settings/security_restore_feedback_test.dart'
    as recovery_feedback;
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

import '../../../packages/n42_chat/test/presentation/pages/friend_info_edit_test.dart'
    as friend_info;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat friend profile annotations', friend_info.main);
  group('Chat account biometric authentication', biometric_auth.main);
  group('Chat friend identity and detail actions', contact_details.main);
  group('Chat registration UIA', registration.main);
  group('Chat auth forms', auth_forms.main);
  group('Chat auth session and registration errors', auth_session.main);
  group('Chat accepted friendship and sending', friendship.main);
  group('Chat contact invitation policy', contacts.main);
  group('Chat key backup and verified restoration', key_backup.main);
  group('Chat recovery result and backup status', recovery_feedback.main);
  group('Chat timeline session and decryption', messages.main);
  group('Chat file action lifetime and recovery bubbles', chat_routes.main);
  group('Chat settings navigation and logout backup', settings.main);
}
