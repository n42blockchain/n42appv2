import '../../../packages/n42_chat/test/unit/utils/optional_video_thumbnail_test.dart'
    as thumbnails;
import 'package:flutter_test/flutter_test.dart';
import '../../../packages/n42_chat/test/presentation/widgets/chat/calendar_event_action_test.dart'
    as calendar;
import '../../../packages/n42_chat/test/presentation/widgets/chat/code_block_message_widget_test.dart'
    as code;
import '../../../packages/n42_chat/test/unit/datasources/matrix_bundled_sticker_sender_test.dart'
    as stickers;
import '../../../packages/n42_chat/test/unit/services/image_translation_coordinator_test.dart'
    as image_translation;
import '../../../packages/n42_chat/test/unit/datasources/ai_proxy_auth_test.dart'
    as vision;
import '../../../packages/n42_chat/test/unit/utils/payment_request_uri_test.dart'
    as payment;

void main() {
  group('Optional gallery thumbnails', thumbnails.main);
  group('Native calendar editing', calendar.main);
  group('Plain and highlighted code', code.main);
  group('Uploaded bundled artwork', stickers.main);
  group('Consented batched image translation', image_translation.main);
  group('Account authorized compressed vision', vision.main);
  group('Host wallet payment QR compatibility', payment.main);
}
