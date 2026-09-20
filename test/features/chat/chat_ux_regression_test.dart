import 'package:flutter_test/flutter_test.dart';
import '../../../packages/n42_chat/test/presentation/pages/chat_ux_regression_test.dart' as ux;
import '../../../packages/n42_chat/test/unit/widgets/chat_more_panel_pagination_test.dart' as media;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Chat interaction flows', ux.main);
  group('Chat attachment access', media.main);
}
