import 'package:flutter_test/flutter_test.dart';
import '../../../packages/n42_chat/test/presentation/pages/chat_ux_regression_test.dart'
    as ux;
import '../../../packages/n42_chat/test/unit/widgets/chat_more_panel_pagination_test.dart'
    as media;

import '../../../packages/n42_chat/test/unit/blocs/contact_interaction_regression_test.dart'
    as contacts;
import '../../../packages/n42_chat/test/unit/datasources/conversation_preview_recovery_test.dart'
    as previews;
import '../../../packages/n42_chat/test/unit/datasources/ai_proxy_auth_test.dart'
    as aiAuth;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat interaction flows', ux.main);
  group('Chat attachment access', media.main);
  group('Contact search and refresh', contacts.main);
  group('Conversation key recovery', previews.main);
  group('AI account authentication', aiAuth.main);
}
