import '../utils/string_utils.dart';

final RegExp _emailRegExp =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
final RegExp _urlRegExp = RegExp(
  r'^https?://[^\s<>\[\]{}|\\^`"]+',
  caseSensitive: false,
);
final RegExp _htmlTagRegExp = RegExp(r'<[^>]*>');
final RegExp _unsafeFileNameRegExp = RegExp(r'[<>:"/\\|?*]');
final RegExp _chineseRegExp = RegExp(r'[\u4e00-\u9fa5]');
final RegExp _upperLetterRegExp = RegExp(r'[A-Z]');

/// String 扩展方法
extension StringExtension on String {
  /// 是否为空或仅包含空白
  bool get isBlank => trim().isEmpty;

  /// 是否不为空且不仅包含空白
  bool get isNotBlank => !isBlank;

  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 每个单词首字母大写
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// 是否是有效的邮箱
  bool get isValidEmail {
    return _emailRegExp.hasMatch(this);
  }

  /// 是否是有效的URL
  bool get isValidUrl {
    return _urlRegExp.hasMatch(this);
  }

  /// 是否是有效的Matrix用户ID
  bool get isValidMatrixId => StringUtils.isValidMatrixId(this);

  /// 是否是有效的Matrix房间ID
  bool get isValidRoomId => StringUtils.isValidRoomId(this);

  /// 是否是有效的Matrix房间别名
  bool get isValidRoomAlias => StringUtils.isValidRoomAlias(this);

  /// 提取Matrix用户名
  String get matrixUsername => StringUtils.extractUsername(this);

  /// 提取Matrix服务器
  String get matrixServer => StringUtils.extractServer(this);

  /// 截断字符串
  String truncate(int maxLength, {String ellipsis = '...'}) {
    return StringUtils.truncate(this, maxLength, ellipsis: ellipsis);
  }

  /// 获取首字母
  String get initials => StringUtils.getInitials(this);

  /// 是否只包含表情
  bool get isOnlyEmoji => StringUtils.isOnlyEmoji(this);

  /// 提取所有URL
  List<String> get extractUrls => StringUtils.extractUrls(this);

  /// 格式化为消息预览
  String get asMessagePreview => StringUtils.formatMessagePreview(this);

  /// 移除HTML标签
  String get stripHtml {
    return replaceAll(_htmlTagRegExp, '');
  }

  /// 转换为安全的文件名
  String get asSafeFileName {
    return replaceAll(_unsafeFileNameRegExp, '_');
  }

  /// 是否包含中文
  bool get containsChinese {
    return _chineseRegExp.hasMatch(this);
  }

  /// 获取中文拼音首字母（用于通讯录索引）
  /// 注意：这是简化版本，实际应使用pinyin包
  String get firstPinyinLetter {
    if (isEmpty) return '#';
    final first = this[0].toUpperCase();
    if (_upperLetterRegExp.hasMatch(first)) {
      return first;
    }
    // 如果是中文，返回#（实际应转换为拼音）
    return '#';
  }

  /// 高亮关键词
  List<TextPart> highlightKeyword(String keyword) {
    return StringUtils.highlightKeyword(this, keyword);
  }
}

/// 可空String扩展
extension NullableStringExtension on String? {
  /// 是否为null或空
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// 是否不为null且不为空
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// 是否为null、空或仅包含空白
  bool get isNullOrBlank => this == null || this!.isBlank;

  /// 是否不为null、不为空且不仅包含空白
  bool get isNotNullOrBlank => !isNullOrBlank;

  /// 如果为null或空，返回默认值
  String orDefault(String defaultValue) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}

