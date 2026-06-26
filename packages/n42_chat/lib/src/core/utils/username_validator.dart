/// 用户名验证器
///
/// 规则：3-30 字符，小写字母/数字/下划线，以字母开头。
class UsernameValidator {
  /// 用户名正则模式
  static final RegExp _pattern = RegExp(r'^[a-z][a-z0-9_]{2,29}$');

  /// 保留用户名列表
  static const Set<String> _reserved = {
    'admin',
    'administrator',
    'system',
    'n42',
    'support',
    'help',
    'mod',
    'moderator',
    'root',
    'bot',
    'official',
    'staff',
    'team',
    'security',
    'info',
    'news',
    'update',
    'service',
    'matrix',
    'server',
    'null',
    'undefined',
    'anonymous',
    'everyone',
    'here',
    'channel',
    'group',
    'api',
    'dev',
    'test',
    'demo',
  };

  /// 验证用户名格式
  static UsernameValidationResult validate(String username) {
    if (username.isEmpty) {
      return UsernameValidationResult.invalid('Username cannot be empty');
    }

    if (username.length < 3) {
      return UsernameValidationResult.invalid('Username must be at least 3 characters');
    }

    if (username.length > 30) {
      return UsernameValidationResult.invalid('Username must be at most 30 characters');
    }

    if (username != username.toLowerCase()) {
      return UsernameValidationResult.invalid('Username must be lowercase');
    }

    if (!_pattern.hasMatch(username)) {
      return UsernameValidationResult.invalid(
        'Username must start with a letter and contain only letters, numbers, and underscores',
      );
    }

    if (_reserved.contains(username)) {
      return UsernameValidationResult.reserved('This username is reserved');
    }

    return UsernameValidationResult.valid();
  }

  /// 标准化用户名（小写 + 去除多余空格）
  static String normalize(String username) {
    return username.trim().toLowerCase();
  }
}

/// 用户名验证结果
class UsernameValidationResult {
  final bool isValid;
  final bool isReserved;
  final String? errorMessage;

  const UsernameValidationResult._({
    required this.isValid,
    this.isReserved = false,
    this.errorMessage,
  });

  factory UsernameValidationResult.valid() =>
      const UsernameValidationResult._(isValid: true);

  factory UsernameValidationResult.invalid(String message) =>
      UsernameValidationResult._(isValid: false, errorMessage: message);

  factory UsernameValidationResult.reserved(String message) =>
      UsernameValidationResult._(
        isValid: false,
        isReserved: true,
        errorMessage: message,
      );
}
