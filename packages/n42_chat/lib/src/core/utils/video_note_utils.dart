/// 圆形视频留言（Video Note，对标 Telegram）的标识工具。
///
/// 为避免改动 Matrix 事件 mapper / 元数据模型层，视频留言用**文件名前缀**
/// 作为标记——文件名是 `m.video` 事件原生字段、收发双向天然往返，渲染端据此
/// 判定是否圆形渲染。纯逻辑、可单测。
class VideoNoteUtils {
  VideoNoteUtils._();

  /// 视频留言文件名前缀。
  static const String prefix = 'n42note_';

  /// 生成一个视频留言文件名（毫秒时间戳避免冲突）。
  static String buildFilename(int timestampMs) => '$prefix$timestampMs.mp4';

  /// 判定某文件名是否为视频留言。
  static bool isVideoNote(String? fileName) =>
      fileName != null && fileName.startsWith(prefix);
}
