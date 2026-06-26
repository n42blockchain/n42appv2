final RegExp _matrixIdRegExp =
    RegExp(r'^@[a-zA-Z0-9._=\-/]+:[a-zA-Z0-9.\-]+$');
final RegExp _roomIdRegExp =
    RegExp(r'^![a-zA-Z0-9]+:[a-zA-Z0-9.\-]+$');
final RegExp _roomAliasRegExp =
    RegExp(r'^#[a-zA-Z0-9._=\-]+:[a-zA-Z0-9.\-]+$');
final RegExp _whitespaceRegExp = RegExp(r'\s+');
final RegExp _urlExtractRegExp = RegExp(
  r'https?://[^\s<>\[\]{}|\\^`"]+',
  caseSensitive: false,
);
final RegExp _emojiRegExp = RegExp(
  r'[\u{1F600}-\u{1F64F}]|'
  r'[\u{1F300}-\u{1F5FF}]|'
  r'[\u{1F680}-\u{1F6FF}]|'
  r'[\u{1F1E0}-\u{1F1FF}]|'
  r'[\u{2600}-\u{26FF}]|'
  r'[\u{2700}-\u{27BF}]',
  unicode: true,
);

/// 字符串工具类
abstract class StringUtils {
  StringUtils._();

  /// 提取Matrix用户ID中的用户名部分
  ///
  /// @user:server.com -> user
  static String extractUsername(String matrixId) {
    if (matrixId.isEmpty) return '';
    if (matrixId.startsWith('@')) {
      final colonIndex = matrixId.indexOf(':');
      if (colonIndex > 1) {
        return matrixId.substring(1, colonIndex);
      }
      return matrixId.substring(1);
    }
    return matrixId;
  }

  /// 提取Matrix用户ID中的服务器部分
  ///
  /// @user:server.com -> server.com
  static String extractServer(String matrixId) {
    if (matrixId.isEmpty) return '';
    final colonIndex = matrixId.indexOf(':');
    if (colonIndex > 0 && colonIndex < matrixId.length - 1) {
      return matrixId.substring(colonIndex + 1);
    }
    return '';
  }

  /// 生成Matrix用户ID
  ///
  /// user, server.com -> @user:server.com
  static String createMatrixId(String username, String server) {
    final cleanUsername = username.startsWith('@') ? username.substring(1) : username;
    final cleanServer = server.startsWith(':') ? server.substring(1) : server;
    return '@$cleanUsername:$cleanServer';
  }

  /// 截断字符串
  ///
  /// 超过maxLength时添加省略号
  static String truncate(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// 获取显示名称（如果为空则使用用户名）
  static String getDisplayName(String? displayName, String userId) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return extractUsername(userId);
  }

  /// 获取姓名首字母（用于头像）
  static String getInitials(String name, {int maxLength = 2}) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      // 单个词，取前两个字符
      return name.substring(0, name.length.clamp(0, maxLength)).toUpperCase();
    }

    // 多个词，取每个词的首字母
    final initials = words
        .where((w) => w.isNotEmpty)
        .take(maxLength)
        .map((w) => w[0].toUpperCase())
        .join();

    return initials;
  }

  /// 检查是否是有效的Matrix用户ID
  static bool isValidMatrixId(String id) {
    return _matrixIdRegExp.hasMatch(id);
  }

  /// 检查是否是有效的Matrix房间ID
  static bool isValidRoomId(String id) {
    return _roomIdRegExp.hasMatch(id);
  }

  /// 检查是否是有效的Matrix房间别名
  static bool isValidRoomAlias(String alias) {
    return _roomAliasRegExp.hasMatch(alias);
  }

  /// 消息预览处理
  ///
  /// 替换换行为空格，限制长度
  static String formatMessagePreview(String content, {int maxLength = 50}) {
    final preview = content
        .replaceAll(_whitespaceRegExp, ' ')
        .trim();
    return truncate(preview, maxLength);
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 解析链接
  static List<String> extractUrls(String text) {
    return _urlExtractRegExp.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// 检查文本是否只包含表情
  static bool isOnlyEmoji(String text) {
    final withoutEmoji = text.replaceAll(_emojiRegExp, '');
    return withoutEmoji.trim().isEmpty && text.trim().isNotEmpty;
  }

  /// 高亮搜索关键词
  ///
  /// 返回带有特殊标记的文本，需要后续渲染
  static List<TextPart> highlightKeyword(String text, String keyword) {
    if (keyword.isEmpty) {
      return [TextPart(text, isHighlight: false)];
    }

    final parts = <TextPart>[];
    final lowerText = text.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();

    var start = 0;
    var index = lowerText.indexOf(lowerKeyword, start);

    while (index >= 0) {
      if (index > start) {
        parts.add(TextPart(text.substring(start, index), isHighlight: false));
      }
      parts.add(TextPart(
        text.substring(index, index + keyword.length),
        isHighlight: true,
      ));
      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }

    if (start < text.length) {
      parts.add(TextPart(text.substring(start), isHighlight: false));
    }

    return parts;
  }
}

/// 文本片段，用于高亮显示
class TextPart {
  final String text;
  final bool isHighlight;

  const TextPart(this.text, {required this.isHighlight});
}

