import 'package:flutter_test/flutter_test.dart';

import '../../../packages/n42_chat/test/unit/repositories/sticker_repository_behavior_test.dart'
    as stickers;
import '../../../packages/n42_chat/test/unit/services/chat_backup_file_behavior_test.dart'
    as backups;
import '../../../packages/n42_chat/test/unit/services/chat_export_file_behavior_test.dart'
    as exports;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat sticker persistence', stickers.main);
  group('Chat backup file safety', backups.main);
  group('Chat export and sharing', exports.main);
}
