import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/presentation/widgets/chat/video_sticker_view.dart';

void main() {
  group('VideoStickerView.isVideoSticker', () {
    test('true for video mimeType', () {
      expect(VideoStickerView.isVideoSticker(mimeType: 'video/webm'), isTrue);
      expect(VideoStickerView.isVideoSticker(mimeType: 'video/mp4'), isTrue);
    });

    test('true for webm/mp4 url (with query strings)', () {
      expect(
        VideoStickerView.isVideoSticker(url: 'https://x/s.webm'),
        isTrue,
      );
      expect(
        VideoStickerView.isVideoSticker(url: 'https://x/s.mp4?token=abc'),
        isTrue,
      );
    });

    test('false for images', () {
      expect(VideoStickerView.isVideoSticker(mimeType: 'image/png'), isFalse);
      expect(VideoStickerView.isVideoSticker(url: 'https://x/s.webp'), isFalse);
      expect(VideoStickerView.isVideoSticker(url: 'https://x/s.gif'), isFalse);
      expect(VideoStickerView.isVideoSticker(url: 'https://x/s.png'), isFalse);
    });

    test('false when nothing provided', () {
      expect(VideoStickerView.isVideoSticker(), isFalse);
    });
  });
}
