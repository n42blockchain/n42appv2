import 'dart:typed_data';
import 'package:n42_wallet/core/security/secure_memory.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';

/// Wallet information model
///
/// SECURITY NOTE:
/// - Sensitive fields (mnemonic, privateKey, password) should be accessed
///   through secure getter methods when possible
/// - After using sensitive data, call clearSensitiveData() to zero out memory
/// - Use SecureString wrapper for temporary sensitive data handling
class WalletInfo {
  /// Mnemonic phrase (stored encrypted in production)
  ///
  /// SECURITY: Use getMnemonicSecure() for secure access
  String? mnemonic;

  /// Wallet password
  ///
  /// SECURITY: Should be hashed, not stored in plain text in production
  String? password;

  /// Coin sorting cache
  /// assets: 0=descending, 1=ascending, -1=no sort
  /// name: 0=descending, 1=ascending, -1=no sort
  Map<String, dynamic> coinSort = {"assets": 0, "name": -1};

  /// 用户手动置顶的代币标识集合
  /// 主链币：coinType（如 "ETH"），合约代币：coinType_miniName（如 "ETH_USDT"）
  List<String> pinnedCoins = [];

  /// 用户自定义链显示顺序（coinType 字符串列表，按期望顺序排列）
  List<String> chainOrder = [];

  int networkIndex = -1;
  String? walletName;

  /// User login ID
  String? walletUuid;

  /// Coin basic information
  Map<String, dynamic>? coinInfo;

  /// Private key (stored encrypted in production)
  ///
  /// SECURITY: Use getPrivateKeySecure() for secure access
  String? privateKey;

  /// Wallet creation timestamp (unique identifier)
  String? timestamp;

  bool? faceBinding;
  bool mainWallet = false;

  /// 观察钱包标记 — 仅追踪地址余额，无法发起任何签名操作
  bool watchOnly = false;

  /// 观察地址（EVM 格式，如 0x...），仅在 watchOnly=true 时有意义
  String watchAddress = '';

  /// 用户自定义钱包标签（如"交易"、"长期持有"、"DeFi"等），用于分组过滤
  List<String> tags = [];

  /// Account Abstraction (ERC-4337) account information
  AAAccountInfo? aaAccountInfo;

  WalletInfo({
    this.walletName,
    this.mnemonic,
    this.password,
    this.privateKey,
    this.walletUuid,
    this.timestamp,
    this.coinInfo,
  });

  WalletInfo.fromJson(Map<String, dynamic> json) {
    walletName = json['walletName'] as String?;
    mnemonic = json['mnemonic'] as String?;
    password = json['password'] as String?;
    privateKey = json['privateKey'] as String?;
    walletUuid = json['UUID'] as String?;
    timestamp = json['timestamp'] as String?;
    coinInfo = json['coinInfo'] as Map<String, dynamic>?;
    coinSort = json['coinSort'] as Map<String, dynamic>;
    networkIndex = json['networkIndex'] as int;
    pinnedCoins = ((json['pinnedCoins'] as List<dynamic>?)?.cast<String>() ?? []).take(200).toList();
    chainOrder = ((json['chainOrder'] as List<dynamic>?)?.cast<String>() ?? []);
    tags = ((json['tags'] as List<dynamic>?)?.cast<String>() ?? []);
    faceBinding = json['faceBinding'] as bool?;
    mainWallet = json['mainWallet'] as bool;
    watchOnly = (json['watchOnly'] as bool?) ?? false;
    watchAddress = (json['watchAddress'] as String?) ?? '';
    // Parse AA account info if present
    if (json['aaAccountInfo'] != null) {
      aaAccountInfo = AAAccountInfo.fromJson(
        json['aaAccountInfo'] as Map<String, dynamic>,
      );
    }
  }

  /// Serializes ALL fields including sensitive data (mnemonic, password, privateKey).
  /// Use [toJsonPublic] for any non-secure-storage serialization.
  ///
  /// SECURITY: 仅可通过 SPUtil.setWalletInfo() → SecureStorage 路径使用。
  /// 严禁用于日志、网络请求、错误上报或非加密存储。
  Map<String, dynamic> toJson() {
    return {
      "walletName": walletName,
      "mnemonic": mnemonic,
      "password": password,
      "privateKey": privateKey,
      "UUID": walletUuid,
      "timestamp": timestamp,
      "coinInfo": coinInfo,
      "coinSort": coinSort,
      "networkIndex": networkIndex,
      "pinnedCoins": pinnedCoins,
      "chainOrder": chainOrder,
      "tags": tags,
      "faceBinding": faceBinding,
      "mainWallet": mainWallet,
      "watchOnly": watchOnly,
      "watchAddress": watchAddress,
      "aaAccountInfo": aaAccountInfo?.toJson(),
    };
  }

  /// 不含敏感字段的序列化方法，用于 UI 展示、日志、分析等场景。
  Map<String, dynamic> toJsonPublic() {
    return {
      "walletName": walletName,
      "UUID": walletUuid,
      "timestamp": timestamp,
      "coinSort": coinSort,
      "networkIndex": networkIndex,
      "pinnedCoins": pinnedCoins,
      "chainOrder": chainOrder,
      "tags": tags,
      "faceBinding": faceBinding,
      "mainWallet": mainWallet,
      "watchOnly": watchOnly,
      "watchAddress": watchAddress,
    };
  }

  // ==================== Secure Access Methods ====================

  /// Get mnemonic as secure wrapper
  ///
  /// SECURITY: Remember to call dispose() on the returned SecureString
  /// after use to zero out memory
  ///
  /// Example:
  /// ```dart
  /// final secure = walletInfo.getMnemonicSecure();
  /// if (secure != null) {
  ///   try {
  ///     // Use secure.value
  ///   } finally {
  ///     secure.dispose();
  ///   }
  /// }
  /// ```
  SecureString? getMnemonicSecure() => _wrapSecure(mnemonic);

  /// Get private key as secure wrapper
  ///
  /// SECURITY: Remember to call dispose() on the returned SecureString
  /// after use to zero out memory
  SecureString? getPrivateKeySecure() => _wrapSecure(privateKey);

  /// Get password as secure wrapper
  ///
  /// SECURITY: Remember to call dispose() on the returned SecureString
  /// after use to zero out memory
  SecureString? getPasswordSecure() => _wrapSecure(password);

  /// Wrap a nullable string as a SecureString, returning null if empty
  static SecureString? _wrapSecure(String? value) {
    if (value == null || value.isEmpty) return null;
    return SecureString(value);
  }

  /// Check if wallet has mnemonic without exposing it
  bool get hasMnemonic => mnemonic != null && mnemonic!.isNotEmpty;

  /// Check if wallet has private key without exposing it
  bool get hasPrivateKey => privateKey != null && privateKey!.isNotEmpty;

  /// Clear sensitive data from memory
  ///
  /// SECURITY: Call this when wallet info is no longer needed
  /// to prevent sensitive data from remaining in memory
  void clearSensitiveData() {
    // Overwrite with zeros before nullifying
    mnemonic = _zeroOutAndNull(mnemonic);
    privateKey = _zeroOutAndNull(privateKey);
    password = _zeroOutAndNull(password);
  }

  /// Zero out string bytes via SecureMemory, return null for reassignment
  static String? _zeroOutAndNull(String? value) {
    if (value != null) {
      SecureMemory.zeroOut(Uint8List.fromList(value.codeUnits));
    }
    return null;
  }

  @override
  String toString() {
    // SECURITY: Prevent accidental logging of sensitive data
    return 'WalletInfo(name: $walletName, uuid: $walletUuid, hasMnemonic: $hasMnemonic, hasPrivateKey: $hasPrivateKey)';
  }

  // ==================== Account Abstraction Methods ====================

  /// Check if AA is enabled for this wallet
  bool get hasAAAccounts =>
      aaAccountInfo != null && aaAccountInfo!.totalAccounts > 0;

  /// Check if AA is preferred for transfers
  bool get prefersAA => aaAccountInfo?.preferAA ?? false;

  /// Set AA preference
  set prefersAA(bool value) {
    aaAccountInfo ??= AAAccountInfo(smartAccounts: {});
    aaAccountInfo!.preferAA = value;
  }

  /// Get smart accounts for a specific chain
  List<SmartAccount> getSmartAccountsForChain(int chainId) {
    return aaAccountInfo?.getAccountsForChain(chainId) ?? [];
  }

  /// Get the primary smart account for a chain
  SmartAccount? getPrimarySmartAccount(int chainId) {
    return aaAccountInfo?.getPrimaryAccount(chainId);
  }

  /// Add a smart account
  void addSmartAccount(SmartAccount account) {
    aaAccountInfo ??= AAAccountInfo(smartAccounts: {});
    aaAccountInfo!.addAccount(account);
  }

  /// Remove a smart account
  bool removeSmartAccount(String address, int chainId) {
    return aaAccountInfo?.removeAccount(address, chainId) ?? false;
  }

  /// Find a smart account by address across all chains
  SmartAccount? findSmartAccount(String address) {
    return aaAccountInfo?.findAccount(address);
  }

  /// Update a smart account's state
  void updateSmartAccountState(String address, int chainId, SmartAccountState newState) {
    final accounts = aaAccountInfo?.smartAccounts[chainId];
    if (accounts == null) return;

    final index = accounts.indexWhere(
      (a) => a.address.toLowerCase() == address.toLowerCase(),
    );
    if (index >= 0) {
      accounts[index] = accounts[index].copyWith(
        state: newState,
        lastActivityAt: DateTime.now(),
      );
    }
  }

  /// Initialize AA account info if not present
  void initAAAccountInfo() {
    aaAccountInfo ??= AAAccountInfo(smartAccounts: {});
  }
}
