import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/unit/services/room_join_service_test.dart'
    as admission;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat room admission and join concurrency', admission.main);
}
