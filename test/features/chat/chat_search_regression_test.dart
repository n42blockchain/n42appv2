import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/unit/repositories/search_archive_filter_behavior_test.dart'
    as archive;
import '../../../packages/n42_chat/test/unit/repositories/search_repository_behavior_test.dart'
    as search;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat discovery and search navigation', search.main);
  group('Chat archive search on SQLite', archive.main);
}
