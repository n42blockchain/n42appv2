import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/unit/repositories/email_change_repository_regression_test.dart'
    as email_repository;
import '../../../packages/n42_chat/test/unit/repositories/favorite_record_persistence_test.dart'
    as favorites;
import '../../../packages/n42_chat/test/unit/repositories/message_action_persistence_test.dart'
    as actions;
import '../../../packages/n42_chat/test/unit/services/email_change_service_test.dart'
    as email_service;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat favorite record persistence', favorites.main);
  group('Chat favorite actions', actions.main);
  group('Chat email verification repository', email_repository.main);
  group('Chat email verification and retry', email_service.main);
}
