import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/video_note_utils.dart';

/// Roadmap #31 圆形视频留言 —— 文件名前缀标识(收发往返)测试。
void main() {
  test('buildFilename carries the note prefix and mp4 ext', () {
    final name = VideoNoteUtils.buildFilename(1700000000000);
    expect(name, 'n42note_1700000000000.mp4');
    expect(VideoNoteUtils.isVideoNote(name), isTrue);
  });

  test('isVideoNote only for prefixed names', () {
    expect(VideoNoteUtils.isVideoNote('n42note_1.mp4'), isTrue);
    expect(VideoNoteUtils.isVideoNote('video_1.mp4'), isFalse);
    expect(VideoNoteUtils.isVideoNote('IMG_0001.mov'), isFalse);
    expect(VideoNoteUtils.isVideoNote(''), isFalse);
    expect(VideoNoteUtils.isVideoNote(null), isFalse);
  });
}
