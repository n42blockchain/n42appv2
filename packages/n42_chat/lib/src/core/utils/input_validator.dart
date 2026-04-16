/// 集中式输入验证器
///
/// 遵循"不信任边界"原则：凡是拼接到 URL/GraphQL/SQL 的外部输入必须先验证。
class InputValidator {
  InputValidator._();

  /// 安全的 handle/username 格式：字母、数字、下划线、点、连字符
  static final _safeHandle = RegExp(r'^[a-zA-Z0-9_.\-]+$');

  /// 以太坊地址格式：0x 开头 + 40 位十六进制
  static final _ethAddress = RegExp(r'^0x[a-fA-F0-9]{40}$');

  /// ENS 名称格式：字母数字开头，可含点和连字符
  static final _ensName = RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9.\-]*$');

  /// 验证 handle/username 是否安全（用于 Lens、Farcaster、ENS 等）
  static bool isValidHandle(String input) =>
      input.isNotEmpty && _safeHandle.hasMatch(input);

  /// 验证以太坊地址格式
  static bool isValidEthAddress(String input) =>
      input.isNotEmpty && _ethAddress.hasMatch(input);

  /// 验证 ENS 名称格式
  static bool isValidEnsName(String input) =>
      input.isNotEmpty && _ensName.hasMatch(input);

  /// 验证 URL 是否为 HTTPS（用于 homeserver 等配置）
  static bool isValidHttpsUrl(String input) {
    final uri = Uri.tryParse(input);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty;
  }
}
