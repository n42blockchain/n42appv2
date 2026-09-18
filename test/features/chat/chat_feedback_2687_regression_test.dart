import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/presentation/pages/tag_counts_test.dart'
    as tags;
import '../../../packages/n42_chat/test/unit/blocs/auth_bloc_test.dart'
    as registration;
import '../../../packages/n42_chat/test/unit/datasources/matrix_group_datasource_test.dart'
    as group_creation;
import '../../../packages/n42_chat/test/unit/repositories/group_repository_impl_test.dart'
    as groups;
import '../../../packages/n42_chat/test/unit/services/authenticated_video_source_test.dart'
    as video_downloads;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat registration submission', registration.main);
  group('Chat group creation state', group_creation.main);
  group('Chat group membership', groups.main);
  group('Chat friend tag counts', tags.main);
  group('Chat authenticated video downloads', video_downloads.main);
}
